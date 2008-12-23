From: Steven Rostedt <srostedt@redhat.com>
Date: Tue, 23 Dec 2008 14:35:49 +0000
Subject: Re: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <1230042949.30177.103.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


On Tue, 2008-12-23 at 14:08 +0800, Shaohua Li wrote:
> IA64 dynamic ftrace support. The main tricky thing here is to support mod=
ule.
> In a module, each routine's mcount call will call a PLT stub, which
> will call kernel mcount. We can't simply make the mcount call call into
> kernel mcount, as kernel and mocule have different gp and the
> instruction just supports 25bit offset. So I introduced a new PLT stub,
> which will call into kernel ftrace_caller. When module loading, all
> mcount call will be converted to nop. When the nop is converted to call,
> we make the call to the new PLT stub instead of old mcount PLT stub.
>=20
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> ---
>  arch/ia64/Kconfig              |    2=20
>  arch/ia64/include/asm/ftrace.h |   17 ++
>  arch/ia64/include/asm/module.h |    4=20
>  arch/ia64/kernel/Makefile      |    5=20
>  arch/ia64/kernel/entry.S       |   37 ++++++
>  arch/ia64/kernel/ftrace.c      |  234 ++++++++++++++++++++++++++++++++++=
+++++++
>  arch/ia64/kernel/module.c      |   15 ++
>  scripts/recordmcount.pl        |    7 +
>  8 files changed, 321 insertions(+)
>=20
> Index: linux/arch/ia64/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/Kconfig	2008-12-23 13=
:13:17.000000000 +0800
> +++ linux/arch/ia64/Kconfig	2008-12-23 13:30:09.000000000 +0800
> @@ -21,6 +21,8 @@ config IA64
>  	select HAVE_OPROFILE
>  	select HAVE_KPROBES
>  	select HAVE_KRETPROBES
> +	select HAVE_FTRACE_MCOUNT_RECORD
> +	select HAVE_DYNAMIC_FTRACE
>  	select HAVE_FUNCTION_TRACER
>  	select HAVE_DMA_ATTRS
>  	select HAVE_KVM
> Index: linux/arch/ia64/kernel/Makefile
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/kernel/Makefile	2008-=
12-23 13:11:27.000000000 +0800
> +++ linux/arch/ia64/kernel/Makefile	2008-12-23 13:30:09.000000000 +0800
> @@ -2,6 +2,10 @@
>  # Makefile for the linux kernel.
>  #
> =20
> +ifdef CONFIG_DYNAMIC_FTRACE
> +CFLAGS_REMOVE_ftrace.o =3D -pg
> +endif
> +
>  extra-y	:=3D head.o init_task.o vmlinux.lds
> =20
>  obj-y :=3D acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms=
.o irq.o irq_ia64.o	\
> @@ -28,6 +32,7 @@ obj-$(CONFIG_IA64_CYCLONE)	+=3D cyclone.o
>  obj-$(CONFIG_CPU_FREQ)		+=3D cpufreq/
>  obj-$(CONFIG_IA64_MCA_RECOVERY)	+=3D mca_recovery.o
>  obj-$(CONFIG_KPROBES)		+=3D kprobes.o jprobes.o
> +obj-$(CONFIG_DYNAMIC_FTRACE)	+=3D ftrace.o
>  obj-$(CONFIG_KEXEC)		+=3D machine_kexec.o relocate_kernel.o crash.o
>  obj-$(CONFIG_CRASH_DUMP)	+=3D crash_dump.o
>  obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+=3D uncached.o
> Index: linux/arch/ia64/kernel/ftrace.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- /dev/null	1970-01-01 00:00:00.000000000 +0=
000
> +++ linux/arch/ia64/kernel/ftrace.c	2008-12-23 13:30:09.000000000 +0800
> @@ -0,0 +1,234 @@
> +/*
> + * Dynamic function tracing support.
> + *
> + * Copyright (C) 2008 Shaohua Li <shaohua.li@intel.com>
> + *
> + * For licencing details, see COPYING.
> + *
> + * Defines low-level handling of mcount calls when the kernel
> + * is compiled with the -pg flag. When using dynamic ftrace, the
> + * mcount call-sites get patched lazily with NOP till they are
> + * enabled. All code mutation routines here take effect atomically.
> + */
> +
> +#include <linux/uaccess.h>
> +#include <linux/ftrace.h>
> +
> +#include <asm/cacheflush.h>
> +#include <asm/ftrace.h>
> +
> +static unsigned char ftrace_nop_code[MCOUNT_INSN_SIZE] =3D {
> +	0x00, 0x00, 0x00, 0x00, 0x01, 0x00,	/* nop.m 0x0 */
> +	0x00, 0x00, 0x00, 0x02, 0x00, 0x00,	/* nop.i 0x0 */
> +	0x00, 0x00, 0x04, 0x00,			/* nop.i 0x0 */
> +	0x01, 0x00, 0x00, 0x00, 0x01, 0x00,	/* nop.m 0x0 */
> +	0x00, 0x00, 0x00, 0x02, 0x00, 0x00,	/* nop.i 0x0 */
> +	0x00, 0x00, 0x04, 0x00			/* nop.i 0x0;; */
> +};

As I stated before, you can not have a multi-line nop. The best you can
do is add a jump over the entire call, and only if that jump is a single
instruction.

Think about it, lets do a simple scenario.

Some process is running inside the kernel and starts to execute one of
these 'nop' sequences. After executing the third nop, it is preempted
(before finishing the other nops). During this preemption, you happen to
start the tracer. Kstop_machine is called and all processes are now
stopped.  The kstop_machine changes the nop to the call of a function
tracer and resumes.  Now that original process gets scheduled back in,
but the code is no longer nops, it has actual code and a call. But we
missed the first 3 commands. Not to mention, it looks like the op codes
are not even 4 or 8 byte aligned. So we could be executing something
that is not even a command. BAM! Crash! kernel oops! ;-)


> +
> +static unsigned char *ftrace_nop_replace(void)
> +{
> +	return ftrace_nop_code;
> +}
> +
> +/* In IA64, each function will be added below two bundles with -pg optio=
n */
> +static unsigned char __attribute__((aligned(8)))
> +ftrace_call_code[MCOUNT_INSN_SIZE] =3D {
> +	0x02, 0x40, 0x31, 0x10, 0x80, 0x05, /* alloc r40=3Dar.pfs,12,8,0 */
> +	0xb0, 0x02, 0x00, 0x00, 0x42, 0x40, /* mov r43=3Dr0;; */
> +	0x05, 0x00, 0xc4, 0x00,             /* mov r42=B0 */
> +	0x11, 0x48, 0x01, 0x02, 0x00, 0x21, /* mov r41=3Dr1 */
> +	0x00, 0x00, 0x00, 0x02, 0x00, 0x00, /* nop.i 0x0 */

If you made your own PLT stub, could you just change the one line to
jump to that stub?


> +	0x08, 0x00, 0x00, 0x50              /* br.call.sptk.many b0 =3D _mcount=
;; */
> +};
> +
> +struct ftrace_call_insn {
> +	u64 dummy1, dummy2, dummy3;
> +	u64 dummy4:64-41+13;
> +	u64 imm20:20;
> +	u64 dummy5:3;
> +	u64 sign:1;
> +	u64 dummy6:4;
> +};
> +
> +static void calculate_offset(unsigned long ip, unsigned long addr,
> +	unsigned long *offset, int *sign)
> +{
> +	long of =3D addr - (ip + 0x10);
> +	if (of < 0)
> +		*sign =3D 1;
> +	else
> +		*sign =3D 0;
> +	*offset =3D of >> 4;
> +}
> +
> +static unsigned char *ftrace_call_replace(unsigned long ip, unsigned lon=
g addr)
> +{
> +	struct ftrace_call_insn *code =3D (void *)ftrace_call_code;
> +	unsigned long offset;
> +	int sign;
> +
> +	calculate_offset(ip, addr, &offset, &sign);
> +	code->sign =3D sign;
> +	code->imm20 =3D offset;
> +
> +	return ftrace_call_code;
> +}
> +
> +static int
> +ftrace_modify_code(unsigned long ip, unsigned char *old_code,
> +		   unsigned char *new_code, int do_check)
> +{
> +	unsigned char replaced[MCOUNT_INSN_SIZE];
> +
> +	/*
> +	 * Note: Due to modules and __init, code can
> +	 *  disappear and change, we need to protect against faulting
> +	 *  as well as code changing. We do this by using the
> +	 *  probe_kernel_* functions.
> +	 *
> +	 * No real locking needed, this code is run through
> +	 * kstop_machine, or before SMP starts.
> +	 */
> +
> +	if (!do_check)
> +		goto skip_check;
> +
> +	/* read the text we want to modify */
> +	if (probe_kernel_read(replaced, (void *)ip, MCOUNT_INSN_SIZE))
> +		return -EFAULT;
> +
> +	/* Make sure it is what we expect it to be */
> +	if (memcmp(replaced, old_code, MCOUNT_INSN_SIZE) !=3D 0)
> +		return -EINVAL;
> +
> +skip_check:
> +	/* replace the text with the new text */
> +	if (probe_kernel_write((void *)ip, new_code, MCOUNT_INSN_SIZE))
> +		return -EPERM;
> +
> +	flush_icache_range(ip, ip + MCOUNT_INSN_SIZE);
> +
> +	return 0;
> +}
> +
> +int ftrace_make_nop(struct module *mod,
> +		    struct dyn_ftrace *rec, unsigned long addr)
> +{
> +	unsigned char __attribute__((aligned(8))) replaced[MCOUNT_INSN_SIZE];
> +	struct ftrace_call_insn *call_insn =3D (void *)ftrace_call_code, *tmp_c=
all;
> +	unsigned long ip =3D rec->ip;
> +	int is_kernel_address =3D core_kernel_text(ip);
> +	unsigned char *old, *new;
> +	int do_check =3D 0;
> +
> +	if (is_kernel_address) {
> +		do_check =3D 1;
> +		old =3D ftrace_call_replace(ip, addr);
> +		goto modify;
> +	}
> +
> +	if (!rec->arch.mod) {
> +		if (!mod) {
> +			printk(KERN_ERR "No module loaded addr=3D%lx\n",
> +			       addr);
> +			return -EFAULT;
> +		}
> +		rec->arch.mod =3D mod;
> +	} else if (mod) {
> +		if (mod !=3D rec->arch.mod) {
> +			printk(KERN_ERR
> +			       "Record mod %p not equal to passed in mod %p\n",
> +			       rec->arch.mod, mod);
> +			return -EINVAL;
> +		}
> +		/* nothing to do if mod =3D rec->arch.mod */
> +	} else
> +		mod =3D rec->arch.mod;
> +
> +	/* the mcount call is a call to a PLT entry */
> +	if (probe_kernel_read(replaced, (void *)ip, MCOUNT_INSN_SIZE))
> +		return -EFAULT;
> +	tmp_call =3D (void *)replaced;
> +	call_insn->sign =3D tmp_call->sign;
> +	call_insn->imm20 =3D tmp_call->imm20;
> +	if (memcmp(replaced, ftrace_call_code, MCOUNT_INSN_SIZE) !=3D 0)
> +		return -EINVAL;
> +	old =3D ftrace_call_code;
> +
> +modify:
> +	new =3D ftrace_nop_replace();
> +	return ftrace_modify_code(ip, old, new, do_check);
> +}
> +
> +int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
> +{
> +	unsigned long ip =3D rec->ip;
> +	int is_kernel_address =3D core_kernel_text(ip);
> +	struct module *mod;
> +	unsigned char *old, *new;
> +
> +	if (is_kernel_address)
> +		goto modify;
> +
> +	if (!rec->arch.mod) {
> +		printk(KERN_ERR "No module loaded\n");
> +		return -EINVAL;
> +	}
> +	mod =3D rec->arch.mod;
> +	if (!mod->arch.ftrace_caller_plt) {
> +		printk(KERN_ERR "No mcount PLT entry for module %s\n",
> +			mod->name);
> +		return -EINVAL;
> +	}
> +	addr =3D mod->arch.ftrace_caller_plt;
> +modify:
> +	old=3D  ftrace_nop_replace();
> +	new =3D ftrace_call_replace(ip, addr);
> +	return ftrace_modify_code(ip, old, new, 1);
> +}
> +
> +struct ftrace_caller_code {
> +	u64 dummy1:46;
> +	u64 imm41_18:64-46;
> +	u64 imm41_23:41-(64-46);
> +	u64 dummy2:13;
> +	u64 imm7b:7;
> +	u64 dummy3:1;
> +	u64 ic:1;
> +	u64 imm5c:5;
> +	u64 imm9d:9;
> +	u64 i:1;
> +	u64 dummy4:4;
> +};
> +
> +/* in IA64, _mcount can't directly call ftrace_stub. Only jump is ok */
> +int ftrace_update_ftrace_func(ftrace_func_t func)
> +{
> +	unsigned long ip;
> +	unsigned long addr =3D ((struct fnptr *)ftrace_call)->ip;
> +	struct ftrace_caller_code *code =3D  (void *)addr;
> +
> +	if (func =3D ftrace_stub)
> +		return 0;
> +	ip =3D ((struct fnptr *)func)->ip;
> +
> +	code->i =3D ip >> 63;
> +	code->imm9d =3D ip >> 7;
> +	code->imm5c =3D ip >> 16;
> +	code->ic =3D ip >> 21;
> +	code->imm7b =3D ip & 0x7f;
> +	code->imm41_18 =3D ip >> 22;
> +	code->imm41_23 =3D ip >> 40;
> +
> +	flush_icache_range(addr, addr + 16);
> +	return 0;
> +}
> +
> +/* run from kstop_machine */
> +int __init ftrace_dyn_arch_init(void *data)
> +{
> +	*(unsigned long *)data =3D 0;
> +
> +	return 0;
> +}
> Index: linux/scripts/recordmcount.pl
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/scripts/recordmcount.pl	2008-12=
-23 13:24:59.000000000 +0800
> +++ linux/scripts/recordmcount.pl	2008-12-23 13:30:09.000000000 +0800
> @@ -206,6 +206,13 @@ if ($arch eq "x86_64") {
>      $alignment =3D 2;
>      $section_type =3D '%progbits';
> =20
> +} elsif ($arch eq "ia64") {
> +    $mcount_regex =3D "^\\s*([0-9a-fA-F]+):.*\\s_mcount\$";
> +    $type =3D "data8";
> +
> +    if ($is_module eq "0") {
> +        $cc .=3D " -mconstant-gp";
> +    }

I wonder if it would be better to pass in CFLAGS and then be able to
parse that instead. Then we can find out a lot more about what we are
working on.

-- Steve



>  } else {
>      die "Arch $arch is not supported with CONFIG_FTRACE_MCOUNT_RECORD";
>  }
> Index: linux/arch/ia64/include/asm/ftrace.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/include/asm/ftrace.h	=
2008-12-23 13:13:17.000000000 +0800
> +++ linux/arch/ia64/include/asm/ftrace.h	2008-12-23 13:30:09.000000000 +0=
800
> @@ -7,6 +7,23 @@
>  #ifndef __ASSEMBLY__
>  extern void _mcount(unsigned long pfs, unsigned long r1, unsigned long b=
0, unsigned long r0);
>  #define mcount _mcount
> +#define ftrace_call ftrace_caller
> +
> +#include <asm/kprobes.h>
> +/* In IA64, MCOUNT_ADDR is set in link time, so it's not a constant at c=
ompile time */
> +#define MCOUNT_ADDR (((struct fnptr *)mcount)->ip)
> +#define FTRACE_ADDR (((struct fnptr *)ftrace_caller)->ip)
> +
> +static inline unsigned long ftrace_call_adjust(unsigned long addr)
> +{
> +	/* second bundle, insn 2 */
> +	return addr - 0x12;
> +}
> +
> +
> +struct dyn_arch_ftrace {
> +	struct module *mod;
> +};
> =20
>  #endif
> =20
> Index: linux/arch/ia64/include/asm/module.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/include/asm/module.h	=
2008-12-23 13:11:27.000000000 +0800
> +++ linux/arch/ia64/include/asm/module.h	2008-12-23 13:30:09.000000000 +0=
800
> @@ -21,6 +21,10 @@ struct mod_arch_specific {
>  	void *core_unw_table;		/* core unwind-table cookie returned by unwinder=
 */
>  	void *init_unw_table;		/* init unwind-table cookie returned by unwinder=
 */
>  	unsigned int next_got_entry;	/* index of next available got entry */
> +
> +#ifdef CONFIG_DYNAMIC_FTRACE
> +	uint64_t ftrace_caller_plt;
> +#endif
>  };
> =20
>  #define Elf_Shdr	Elf64_Shdr
> Index: linux/arch/ia64/kernel/module.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/kernel/module.c	2008-=
12-23 13:11:27.000000000 +0800
> +++ linux/arch/ia64/kernel/module.c	2008-12-23 13:30:09.000000000 +0800
> @@ -32,6 +32,7 @@
>  #include <linux/moduleloader.h>
>  #include <linux/string.h>
>  #include <linux/vmalloc.h>
> +#include <linux/ftrace.h>
> =20
>  #include <asm/patch.h>
>  #include <asm/unaligned.h>
> @@ -468,6 +469,9 @@ module_frob_arch_sections (Elf_Ehdr *ehd
>  			core_plts +=3D count_plts(rels, numrels);
>  	}
> =20
> +#ifdef CONFIG_DYNAMIC_FTRACE
> +	core_plts++;
> +#endif
>  	mod->arch.core_plt->sh_type =3D SHT_NOBITS;
>  	mod->arch.core_plt->sh_flags =3D SHF_EXECINSTR | SHF_ALLOC;
>  	mod->arch.core_plt->sh_addralign =3D 16;
> @@ -839,6 +843,17 @@ apply_relocate_add (Elf64_Shdr *sechdrs,
>  		if (ret < 0)
>  			return ret;
>  	}
> +#ifdef CONFIG_DYNAMIC_FTRACE
> +	if (!mod->arch.ftrace_caller_plt) {
> +		int ok =3D 1;
> +		/* fake a 'struct insn' for get_plt, which is in module core */
> +		uint64_t fake_insn =3D (uint64_t)mod->module_init + mod->init_size;
> +		mod->arch.ftrace_caller_plt =3D get_plt(mod,
> +			(struct insn *)fake_insn, (uint64_t)ftrace_caller, &ok);
> +		if (!ok)
> +			mod->arch.ftrace_caller_plt =3D 0;
> +	}
> +#endif
>  	return 0;
>  }
> =20
> Index: linux/arch/ia64/kernel/entry.S
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/kernel/entry.S	2008-1=
2-23 13:13:17.000000000 +0800
> +++ linux/arch/ia64/kernel/entry.S	2008-12-23 13:30:09.000000000 +0800
> @@ -1406,6 +1406,42 @@ GLOBAL_ENTRY(unw_init_running)
>  END(unw_init_running)
> =20
>  #ifdef CONFIG_FUNCTION_TRACER
> +#ifdef CONFIG_DYNAMIC_FTRACE
> +GLOBAL_ENTRY(_mcount)
> +	br ftrace_stub
> +END(_mcount)
> +
> +.here:
> +	br.ret.sptk.many b0
> +
> +GLOBAL_ENTRY(ftrace_caller)
> +{
> +	.mlx
> +	nop.m 0x0
> +	movl r3 =3D .here;;
> +}
> +	alloc loc0 =3D ar.pfs, 4, 4, 2, 0
> +	;;
> +	mov loc1 =3D b0
> +	mov out0 =3D b0
> +	mov loc2 =3D r8
> +	mov loc3 =3D r15
> +	;;
> +	adds out0 =3D -MCOUNT_INSN_SIZE, out0
> +	mov out1 =3D in2
> +	mov b6 =3D r3
> +
> +	br.call.sptk.many b0 =3D b6
> +	;;
> +	mov ar.pfs =3D loc0
> +	mov b0 =3D loc1
> +	mov r8 =3D loc2
> +	mov r15 =3D loc3
> +	br ftrace_stub
> +	;;
> +END(ftrace_caller)
> +
> +#else
>  GLOBAL_ENTRY(_mcount)
>  	movl r2 =3D ftrace_stub
>  	movl r3 =3D ftrace_trace_function;;
> @@ -1435,6 +1471,7 @@ GLOBAL_ENTRY(_mcount)
>  	br ftrace_stub
>  	;;
>  END(_mcount)
> +#endif
> =20
>  GLOBAL_ENTRY(ftrace_stub)
>  	mov r3 =3D b0
>=20
>=20

