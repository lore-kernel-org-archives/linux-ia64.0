From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Thu, 03 Apr 2003 13:04:35 +0000
Subject: Re: [Linux-ia64] module support for 2.5 kernel
Message-Id: <marc-linux-ia64-105590723705390@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705330@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705330@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi David,

Thanks for providing this important functionality.

We found the following (minor :-) problems:

1) missing module.o in arch/ia64/kernel/Makefile.

2) using CONFIG_MODVERSIONS, the per-cpu-check.awk script fails with
__crc_xxx symbols:

000000004d13d7e9 A __crc_page_states__per_cpu not in per-cpu section
00000000b4f8f003 A __crc_cpu_info__per_cpu not in per-cpu section
make: *** [vmlinux] Error 1

Just changing the script to ignore them fixes the problem.

3) with CONFIG_NUMA set, there are undefined symbols building modules:

scripts/modpost vmlinux drivers/md/dm-mod.o drivers/net/e1000/e1000.o drive=
rs/net/eepro100.o drivers/md/md.o drivers/net/mii.o fs/xfs/xfs.o
*** Warning: "cpu_info__per_cpu" [fs/xfs/xfs.ko] undefined!
*** Warning: "cpu_info__per_cpu" [drivers/md/md.ko] undefined!
*** Warning: "cpu_to_node_map" [drivers/md/md.ko] undefined!

exporting them in ia64_ksyms.c fixes the problem.

Hereafter a possible patch that applies on top of yours:
---------------------------------------------------------------------------=
----
diff --exclude-from /users1/xb/proc/diff.exclude -Nur /users1/cr/2564/linux=
-2.5.64/arch/ia64/kernel/ia64_ksyms.c 64/arch/ia64/kerneel/ia64_ksyms.c
--- /users1/cr/2564/linux-2.5.64/arch/ia64/kernel/ia64_ksyms.c	2003-03-28 1=
6:40:12.000000000 +0100
+++ 64/arch/ia64/kernel/ia64_ksyms.c	2003-04-03 10:35:03.000000000 +0200
@@ -63,9 +63,7 @@
 #endif
=20
 #include <asm/processor.h>
-# ifndef CONFIG_NUMA
 EXPORT_SYMBOL(cpu_info__per_cpu);
-# endif
 EXPORT_SYMBOL(kernel_thread);
=20
 #include <asm/system.h>
@@ -154,6 +152,11 @@
 EXPORT_SYMBOL(pfm_remove_alternate_syswide_subsystem);
 #endif
=20
+#ifdef CONFIG_NUMA
+#include <asm/numa.h>
+EXPORT_SYMBOL(cpu_to_node_map);
+#endif
+
 #include <asm/unwind.h>
 EXPORT_SYMBOL(unw_init_from_blocked_task);
 EXPORT_SYMBOL(unw_init_running);
diff --exclude-from /users1/xb/proc/diff.exclude -Nur /users1/cr/2564/linux=
-2.5.64/scripts/per-cpu-check.awk 64/scripts/per-cpu-cheeck.awk
--- /users1/cr/2564/linux-2.5.64/scripts/per-cpu-check.awk	2003-03-05 04:29=
:34.000000000 +0100
+++ 64/scripts/per-cpu-check.awk	2003-04-03 11:38:13.000000000 +0200
@@ -6,7 +6,7 @@
 	IN_PER_CPU=3D0
 }
=20
-/__per_cpu$$/ && ! ( / __ksymtab_/ || / __kstrtab_/ || / __kcrctab_/ ) {
+/__per_cpu$$/ && ! (/ __crc_/ || / __ksymtab_/ || / __kstrtab_/ || / __kcr=
ctab_/ ) {
 	if (!IN_PER_CPU) {
 		print $$3 " not in per-cpu section" > "/dev/stderr";
 		FOUND=3D1;
diff --exclude-from /users/xb/proc/diff.exclude -Nur 64r/arch/ia64/kernel/M=
akefile 64/arch/ia64/kernel/Makefile
--- 64r/arch/ia64/kernel/Makefile	2003-03-05 04:29:54.000000000 +0100
+++ 64/arch/ia64/kernel/Makefile	2003-04-03 14:36:05.000000000 +0200
@@ -17,3 +17,4 @@
 obj-$(CONFIG_SMP) +=3D smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) +=3D mca.o mca_asm.o
 obj-$(CONFIG_IA64_BRL_EMU) +=3D brl_emu.o
+obj-$(CONFIG_MODULES) +=3D module.o

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

David writes:

 >=20
 > Here is a quick patch to add back module-support in the 2.5 kernel.
 > It could stand some more testing, but the basics seem to be working.
 > In particular, the loader should support all relocs that can occur in
 > a module.  Even the LDXMOV/LTOFF22X relocs are fully supported, which
 > is nice because with gcc 3.4, this will usually let us turn GOT
 > addressing into GPREL addressing.  Also, this module loader optimizes
 > the procedure-linkage stubs needed to call routines outside of a
 > module and takes advantage of "brl" when running on CPUs other than
 > Merced.  This is nice because that way, a non-local call comes out as:
 >=20
 > 	br plt
 >=20
 > plt:	movl gp=3DKERNEL_GP
 > 	brl ENTRY_POINT
 >=20
 > which means that there are no branch-target misprediction penalties.
 >=20
 > The module loader also handles unwind info, so that you can backtrace
 > etc., across module code.
 >=20
 > The way GOT-entry allocation is handled is certainly not optimal (the
 > algorithms are quadratic in the number of relocation-entries), but I
 > doubt it's going to be an issue in practice and what's there is simple
 > and hard to get wrong.  If someone is interested in improving the ia64
 > module loader, that might be a place to start, however.
 >=20
 > Oh, you need module-init-tools-0.9.10.tar.gz
 > (http://www.kernel.org/pub/linux/kernel/people/rusty/modules/) to load
 > the new modules.  Also, note that the way modules need to be built
 > changed completely.  It's easiest to build a kernel module to see what
 > needs to be done.
 >=20
 > Oh, and since I don't really care for modules much myself, anyone want
 > to volunteer as the maintainer for this code?
 >=20
 > Enjoy,
 >=20
 > 	--david
 >=20
 > diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
 > --- a/arch/ia64/Makefile	Wed Mar 26 12:21:11 2003
 > +++ b/arch/ia64/Makefile	Wed Mar 26 12:21:12 2003
 > @@ -14,6 +14,7 @@
 > =20
 >  OBJCOPYFLAGS	:=3D --strip-all
 >  LDFLAGS_vmlinux	:=3D -static
 > +LDFLAGS_MODULE	+=3D -T arch/ia64/module.lds
 >  AFLAGS_KERNEL	:=3D -mconstant-gp
 >  EXTRA		:=3D
 > =20
 > diff -Nru a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
 > --- a/arch/ia64/kernel/ia64_ksyms.c	Wed Mar 26 12:21:12 2003
 > +++ b/arch/ia64/kernel/ia64_ksyms.c	Wed Mar 26 12:21:12 2003
 > @@ -147,3 +153,14 @@
 >  EXPORT_SYMBOL(pfm_install_alternate_syswide_subsystem);
 >  EXPORT_SYMBOL(pfm_remove_alternate_syswide_subsystem);
 >  #endif
 > +
 > +#include <asm/unwind.h>
 > +EXPORT_SYMBOL(unw_init_from_blocked_task);
 > +EXPORT_SYMBOL(unw_init_running);
 > +EXPORT_SYMBOL(unw_unwind);
 > +EXPORT_SYMBOL(unw_unwind_to_user);
 > +EXPORT_SYMBOL(unw_access_gr);
 > +EXPORT_SYMBOL(unw_access_br);
 > +EXPORT_SYMBOL(unw_access_fr);
 > +EXPORT_SYMBOL(unw_access_ar);
 > +EXPORT_SYMBOL(unw_access_pr);
 > diff -Nru a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
 > --- /dev/null	Wed Dec 31 16:00:00 1969
 > +++ b/arch/ia64/kernel/module.c	Wed Mar 26 12:21:12 2003
 > @@ -0,0 +1,889 @@
 > +/*
 > + * IA-64-specific support for kernel module loader.
 > + *
 > + * Copyright (C) 2003 Hewlett-Packard Co
 > + *	David Mosberger-Tang <davidm@hpl.hp.com>
 > + *
 > + * Loosely based on patch by Rusty Russell.
 > + */
 > +
 > +/* relocs tested so far:
 > +
 > +   DIR64LSB
 > +   FPTR64LSB
 > +   GPREL22
 > +   LDXMOV
 > +   LDXMOV
 > +   LTOFF22
 > +   LTOFF22X
 > +   LTOFF22X
 > +   LTOFF_FPTR22
 > +   PCREL21B
 > +   PCREL64LSB
 > +   SECREL32LSB
 > +   SEGREL64LSB
 > + */
 > +
 > +#include <linux/config.h>
 > +
 > +#include <linux/kernel.h>
 > +#include <linux/sched.h>
 > +#include <linux/elf.h>
 > +#include <linux/moduleloader.h>
 > +#include <linux/string.h>
 > +#include <linux/vmalloc.h>
 > +
 > +#include <asm/unaligned.h>
 > +
 > +#define ARCH_MODULE_DEBUG 0
 > +
 > +#if ARCH_MODULE_DEBUG
 > +# define DEBUGP printk
 > +# define inline
 > +#else
 > +# define DEBUGP(fmt , a...)
 > +#endif
 > +
 > +#ifdef CONFIG_ITANIUM
 > +# define USE_BRL	0
 > +#else
 > +# define USE_BRL	1
 > +#endif
 > +
 > +#define MAX_LTOFF	((uint64_t) (1 << 22))	/* max. allowable linkage-tabl=
e offset */
 > +
 > +/* Define some relocation helper macros/types: */
 > +
 > +#define FORMAT_SHIFT	0
 > +#define FORMAT_BITS	3
 > +#define FORMAT_MASK	((1 << FORMAT_BITS) - 1)
 > +#define VALUE_SHIFT	3
 > +#define VALUE_BITS	5
 > +#define VALUE_MASK	((1 << VALUE_BITS) - 1)
 > +
 > +enum reloc_target_format {
 > +	/* direct encoded formats: */
 > +	RF_NONE =3D 0,
 > +	RF_INSN14 =3D 1,
 > +	RF_INSN22 =3D 2,
 > +	RF_INSN64 =3D 3,
 > +	RF_32MSB =3D 4,
 > +	RF_32LSB =3D 5,
 > +	RF_64MSB =3D 6,
 > +	RF_64LSB =3D 7,
 > +
 > +	/* formats that cannot be directly decoded: */
 > +	RF_INSN60,
 > +	RF_INSN21B,	/* imm21 form 1 */
 > +	RF_INSN21M,	/* imm21 form 2 */
 > +	RF_INSN21F	/* imm21 form 3 */
 > +};
 > +
 > +enum reloc_value_formula {
 > +	RV_DIRECT =3D 4,		/* S + A */
 > +	RV_GPREL =3D 5,		/* @gprel(S + A) */
 > +	RV_LTREL =3D 6,		/* @ltoff(S + A) */
 > +	RV_PLTREL =3D 7,		/* @pltoff(S + A) */
 > +	RV_FPTR =3D 8,		/* @fptr(S + A) */
 > +	RV_PCREL =3D 9,		/* S + A - P */
 > +	RV_LTREL_FPTR =3D 10,	/* @ltoff(@fptr(S + A)) */
 > +	RV_SEGREL =3D 11,		/* @segrel(S + A) */
 > +	RV_SECREL =3D 12,		/* @secrel(S + A) */
 > +	RV_BDREL =3D 13,		/* BD + A */
 > +	RV_LTV =3D 14,		/* S + A (like RV_DIRECT, except frozen at static link=
-time) */
 > +	RV_PCREL2 =3D 15,		/* S + A - P */
 > +	RV_SPECIAL =3D 16,	/* various (see below) */
 > +	RV_RSVD17 =3D 17,
 > +	RV_TPREL =3D 18,		/* @tprel(S + A) */
 > +	RV_LTREL_TPREL =3D 19,	/* @ltoff(@tprel(S + A)) */
 > +	RV_DTPMOD =3D 20,		/* @dtpmod(S + A) */
 > +	RV_LTREL_DTPMOD =3D 21,	/* @ltoff(@dtpmod(S + A)) */
 > +	RV_DTPREL =3D 22,		/* @dtprel(S + A) */
 > +	RV_LTREL_DTPREL =3D 23,	/* @ltoff(@dtprel(S + A)) */
 > +	RV_RSVD24 =3D 24,
 > +	RV_RSVD25 =3D 25,
 > +	RV_RSVD26 =3D 26,
 > +	RV_RSVD27 =3D 27
 > +	/* 28-31 reserved for implementation-specific purposes.  */
 > +};
 > +
 > +#define N(reloc)	[R_IA64_##reloc] =3D #reloc
 > +
 > +static const char *reloc_name[256] =3D {
 > +	N(NONE),		N(IMM14),		N(IMM22),		N(IMM64),
 > +	N(DIR32MSB),		N(DIR32LSB),		N(DIR64MSB),		N(DIR64LSB),
 > +	N(GPREL22),		N(GPREL64I),		N(GPREL32MSB),		N(GPREL32LSB),
 > +	N(GPREL64MSB),		N(GPREL64LSB),		N(LTOFF22),		N(LTOFF64I),
 > +	N(PLTOFF22),		N(PLTOFF64I),		N(PLTOFF64MSB),		N(PLTOFF64LSB),
 > +	N(FPTR64I),		N(FPTR32MSB),		N(FPTR32LSB),		N(FPTR64MSB),
 > +	N(FPTR64LSB),		N(PCREL60B),		N(PCREL21B),		N(PCREL21M),
 > +	N(PCREL21F),		N(PCREL32MSB),		N(PCREL32LSB),		N(PCREL64MSB),
 > +	N(PCREL64LSB),		N(LTOFF_FPTR22),	N(LTOFF_FPTR64I),	N(LTOFF_FPTR32MSB),
 > +	N(LTOFF_FPTR32LSB),	N(LTOFF_FPTR64MSB),	N(LTOFF_FPTR64LSB),	N(SEGREL32=
MSB),
 > +	N(SEGREL32LSB),		N(SEGREL64MSB),		N(SEGREL64LSB),		N(SECREL32MSB),
 > +	N(SECREL32LSB),		N(SECREL64MSB),		N(SECREL64LSB),		N(REL32MSB),
 > +	N(REL32LSB),		N(REL64MSB),		N(REL64LSB),		N(LTV32MSB),
 > +	N(LTV32LSB),		N(LTV64MSB),		N(LTV64LSB),		N(PCREL21BI),
 > +	N(PCREL22),		N(PCREL64I),		N(IPLTMSB),		N(IPLTLSB),
 > +	N(COPY),		N(LTOFF22X),		N(LDXMOV),		N(TPREL14),
 > +	N(TPREL22),		N(TPREL64I),		N(TPREL64MSB),		N(TPREL64LSB),
 > +	N(LTOFF_TPREL22),	N(DTPMOD64MSB),		N(DTPMOD64LSB),		N(LTOFF_DTPMOD22),
 > +	N(DTPREL14),		N(DTPREL22),		N(DTPREL64I),		N(DTPREL32MSB),
 > +	N(DTPREL32LSB),		N(DTPREL64MSB),		N(DTPREL64LSB),		N(LTOFF_DTPREL22)
 > +};
 > +
 > +#undef N
 > +
 > +struct got_entry {
 > +	uint64_t val;
 > +};
 > +
 > +struct fdesc {
 > +	uint64_t ip;
 > +	uint64_t gp;
 > +};
 > +
 > +/* Opaque struct for insns, to protect against derefs. */
 > +struct insn;
 > +
 > +static inline uint64_t
 > +bundle (const struct insn *insn)
 > +{
 > +	return (uint64_t) insn & ~0xfUL;
 > +}
 > +
 > +static inline int
 > +slot (const struct insn *insn)
 > +{
 > +	return (uint64_t) insn & 0x3;
 > +}
 > +
 > +/* Patch instruction with "val" where "mask" has 1 bits. */
 > +static void
 > +apply (struct insn *insn, uint64_t mask, uint64_t val)
 > +{
 > +	uint64_t m0, m1, v0, v1, b0, b1, *b =3D (uint64_t *) bundle(insn);
 > +#	define insn_mask ((1UL << 41) - 1)
 > +	unsigned long shift;
 > +
 > +	b0 =3D b[0]; b1 =3D b[1];
 > +	shift =3D 5 + 41 * slot(insn); /* 5 bits of template, then 3 x 41-bit =
instructions */
 > +	if (shift >=3D 64) {
 > +		m1 =3D mask << (shift - 64);
 > +		v1 =3D val << (shift - 64);
 > +	} else {
 > +		m0 =3D mask << shift; m1 =3D mask >> (64 - shift);
 > +		v0 =3D val  << shift; v1 =3D val >> (64 - shift);
 > +		b[0] =3D (b0 & ~m0) | (v0 & m0);
 > +	}
 > +	b[1] =3D (b1 & ~m1) | (v1 & m1);
 > +}
 > +
 > +static int
 > +apply_imm64 (struct module *mod, struct insn *insn, uint64_t val)
 > +{
 > +	if (slot(insn) !=3D 2) {
 > +		printk(KERN_ERR "%s: illegal slot number %d for IMM64\n",
 > +		       mod->name, slot(insn));
 > +		return 0;
 > +	}
 > +	apply(insn, 0x01fffefe000, (  ((val & 0x8000000000000000) >> 27) /* bi=
t 63 -> 36 */
 > +				    | ((val & 0x0000000000200000) <<  0) /* bit 21 -> 21 */
 > +				    | ((val & 0x00000000001f0000) <<  6) /* bit 16 -> 22 */
 > +				    | ((val & 0x000000000000ff80) << 20) /* bit  7 -> 27 */
 > +				    | ((val & 0x000000000000007f) << 13) /* bit  0 -> 13 */));
 > +	apply((void *) insn - 1, 0x1ffffffffff, val >> 22);
 > +	return 1;
 > +}
 > +
 > +static int
 > +apply_imm60 (struct module *mod, struct insn *insn, uint64_t val)
 > +{
 > +	if (slot(insn) !=3D 2) {
 > +		printk(KERN_ERR "%s: illegal slot number %d for IMM60\n",
 > +		       mod->name, slot(insn));
 > +		return 0;
 > +	}
 > +	if (val + ((uint64_t) 1 << 59) >=3D (1UL << 60)) {
 > +		printk(KERN_ERR "%s: value %ld out of IMM60 range\n", mod->name, (int=
64_t) val);
 > +		return 0;
 > +	}
 > +	apply(insn, 0x011ffffe000, (  ((val & 0x1000000000000000) >> 24) /* bi=
t 60 -> 36 */
 > +				    | ((val & 0x00000000000fffff) << 13) /* bit  0 -> 13 */));
 > +	apply((void *) insn - 1, 0x1fffffffffc, val >> 18);
 > +	return 1;
 > +}
 > +
 > +static int
 > +apply_imm22 (struct module *mod, struct insn *insn, uint64_t val)
 > +{
 > +	if (val + (1 << 21) >=3D (1 << 22)) {
 > +		printk(KERN_ERR "%s: value %li out of IMM22 range\n", mod->name, (int=
64_t)val);
 > +		return 0;
 > +	}
 > +	apply(insn, 0x01fffcfe000, (  ((val & 0x200000) << 15) /* bit 21 -> 36=
 */
 > +				    | ((val & 0x1f0000)	<<  6) /* bit 16 -> 22 */
 > +				    | ((val & 0x00ff80) << 20) /* bit  7 -> 27 */
 > +				    | ((val & 0x00007f)	<< 13) /* bit  0 -> 13 */));
 > +	return 1;
 > +}
 > +
 > +static int
 > +apply_imm21b (struct module *mod, struct insn *insn, uint64_t val)
 > +{
 > +	if (val + (1 << 20) >=3D (1 << 21)) {
 > +		printk(KERN_ERR "%s: value %li out of IMM21b range\n", mod->name, (in=
t64_t)val);
 > +		return 0;
 > +	}
 > +	apply(insn, 0x11ffffe000, (  ((val & 0x100000) << 16) /* bit 20 -> 36 =
*/
 > +				   | ((val & 0x0fffff) << 13) /* bit  0 -> 13 */));
 > +	return 1;
 > +}
 > +
 > +#if USE_BRL
 > +
 > +struct plt_entry {
 > +	/* Three instruction bundles in PLT. */
 > + 	unsigned char bundle[2][16];
 > +};
 > +
 > +static const struct plt_entry ia64_plt_template =3D {
 > +	{
 > +		{
 > +			0x04, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0 */
 > +			0x00, 0x00, 0x00, 0x00, 0x00, 0x20, /*	     movl gp=3DTARGET_GP */
 > +			0x00, 0x00, 0x00, 0x60
 > +		},
 > +		{
 > +			0x05, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0 */
 > +			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /*	     brl.many gp=3DTARGET_GP =
*/
 > +			0x08, 0x00, 0x00, 0xc0
 > +		}
 > +	}
 > +};
 > +
 > +static int
 > +patch_plt (struct module *mod, struct plt_entry *plt, long target_ip, u=
nsigned long target_gp)
 > +{
 > +	if (apply_imm64(mod, (struct insn *) (plt->bundle[0] + 2), target_gp)
 > +	    && apply_imm60(mod, (struct insn *) (plt->bundle[1] + 2),
 > +			   (target_ip - (int64_t) plt->bundle[1]) / 16))
 > +		return 1;
 > +	return 0;
 > +}
 > +
 > +unsigned long
 > +plt_target (struct plt_entry *plt)
 > +{
 > +	uint64_t b0, b1, *b =3D (uint64_t *) plt->bundle[1];
 > +	long off;
 > +
 > +	b0 =3D b[0]; b1 =3D b[1];
 > +	off =3D (  ((b1 & 0x00fffff000000000) >> 36)		/* imm20b -> bit 0 */
 > +	       | ((b0 >> 48) << 20) | ((b1 & 0x7fffff) << 36)	/* imm39 -> bit =
20 */
 > +	       | ((b1 & 0x0800000000000000) << 1));		/* i -> bit 60 */
 > +	return (long) plt->bundle[1] + 16*off;
 > +}
 > +
 > +#else /* !USE_BRL */
 > +
 > +struct plt_entry {
 > +	/* Three instruction bundles in PLT. */
 > + 	unsigned char bundle[3][16];
 > +};
 > +
 > +static const struct plt_entry ia64_plt_template =3D {
 > +	{
 > +		{
 > +			0x05, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0 */
 > +			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /*	     movl r16=3DTARGET_IP */
 > +			0x02, 0x00, 0x00, 0x60
 > +		},
 > +		{
 > +			0x04, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0 */
 > +			0x00, 0x00, 0x00, 0x00, 0x00, 0x20, /*	     movl gp=3DTARGET_GP */
 > +			0x00, 0x00, 0x00, 0x60
 > +		},
 > +		{
 > +			0x11, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MIB] nop.m 0 */
 > +			0x60, 0x80, 0x04, 0x80, 0x03, 0x00, /*	     mov b6=3Dr16 */
 > +			0x60, 0x00, 0x80, 0x00		    /*	     br.few b6 */
 > +		}
 > +	}
 > +};
 > +
 > +static int
 > +patch_plt (struct module *mod, struct plt_entry *plt, long target_ip, u=
nsigned long target_gp)
 > +{
 > +	if (apply_imm64(mod, (struct insn *) (plt->bundle[0] + 2), target_ip)
 > +	    && apply_imm64(mod, (struct insn *) (plt->bundle[1] + 2), target_g=
p))
 > +		return 1;
 > +	return 0;
 > +}
 > +
 > +unsigned long
 > +plt_target (struct plt_entry *plt)
 > +{
 > +	uint64_t b0, b1, *b =3D (uint64_t *) plt->bundle[0];
 > +
 > +	b0 =3D b[0]; b1 =3D b[1];
 > +	return (  ((b1 & 0x000007f000000000) >> 36)		/* imm7b -> bit 0 */
 > +		| ((b1 & 0x07fc000000000000) >> 43)		/* imm9d -> bit 7 */
 > +		| ((b1 & 0x0003e00000000000) >> 29)		/* imm5c -> bit 16 */
 > +		| ((b1 & 0x0000100000000000) >> 23)		/* ic -> bit 21 */
 > +		| ((b0 >> 46) << 22) | ((b1 & 0x7fffff) << 40)	/* imm41 -> bit 22 */
 > +		| ((b1 & 0x0800000000000000) <<  4));		/* i -> bit 63 */
 > +}
 > +
 > +#endif /* !USE_BRL */
 > +
 > +void *
 > +module_alloc (unsigned long size)
 > +{
 > +	if (!size)
 > +		return NULL;
 > +	return vmalloc(size);
 > +}
 > +
 > +void
 > +module_free (struct module *mod, void *module_region)
 > +{
 > +	vfree(module_region);
 > +}
 > +
 > +/* Have we already seen one of these relocations? */
 > +/* FIXME: we could look in other sections, too --RR */
 > +static int
 > +duplicate_reloc (const Elf64_Rela *rela, unsigned int num)
 > +{
 > +	unsigned int i;
 > +
 > +	for (i =3D 0; i < num; i++) {
 > +		if (rela[i].r_info =3D=3D rela[num].r_info && rela[i].r_addend =3D=3D=
 rela[num].r_addend)
 > +			return 1;
 > +	}
 > +	return 0;
 > +}
 > +
 > +/* Count how many GOT entries we may need */
 > +static unsigned int
 > +count_gots (const Elf64_Rela *rela, unsigned int num)
 > +{
 > +	unsigned int i, ret =3D 0;
 > +
 > +	/* Sure, this is order(n^2), but it's usually short, and not
 > +           time critical */
 > +	for (i =3D 0; i < num; i++) {
 > +		switch (ELF64_R_TYPE(rela[i].r_info)) {
 > +		      case R_IA64_LTOFF22:
 > +		      case R_IA64_LTOFF22X:
 > +		      case R_IA64_LTOFF64I:
 > +		      case R_IA64_LTOFF_FPTR22:
 > +		      case R_IA64_LTOFF_FPTR64I:
 > +		      case R_IA64_LTOFF_FPTR32MSB:
 > +		      case R_IA64_LTOFF_FPTR32LSB:
 > +		      case R_IA64_LTOFF_FPTR64MSB:
 > +		      case R_IA64_LTOFF_FPTR64LSB:
 > +			if (!duplicate_reloc(rela, i))
 > +				ret++;
 > +			break;
 > +		}
 > +	}
 > +	return ret;
 > +}
 > +
 > +/* Count how many PLT entries we may need */
 > +static unsigned int
 > +count_plts (const Elf64_Rela *rela, unsigned int num)
 > +{
 > +	unsigned int i, ret =3D 0;
 > +
 > +	/* Sure, this is order(n^2), but it's usually short, and not
 > +           time critical */
 > +	for (i =3D 0; i < num; i++) {
 > +		switch (ELF64_R_TYPE(rela[i].r_info)) {
 > +		      case R_IA64_PCREL21B:
 > +		      case R_IA64_PLTOFF22:
 > +		      case R_IA64_PLTOFF64I:
 > +		      case R_IA64_PLTOFF64MSB:
 > +		      case R_IA64_PLTOFF64LSB:
 > +		      case R_IA64_IPLTMSB:
 > +		      case R_IA64_IPLTLSB:
 > +			if (!duplicate_reloc(rela, i))
 > +				ret++;
 > +			break;
 > +		}
 > +	}
 > +	return ret;
 > +}
 > +
 > +/* We need to create an function-descriptors for any internal function
 > +   which is referenced. */
 > +static unsigned int
 > +count_fdescs (const Elf64_Rela *rela, unsigned int num)
 > +{
 > +	unsigned int i, ret =3D 0;
 > +
 > +	/* Sure, this is order(n^2), but it's usually short, and not time crit=
ical.  */
 > +	for (i =3D 0; i < num; i++) {
 > +		switch (ELF64_R_TYPE(rela[i].r_info)) {
 > +		      case R_IA64_FPTR64I:
 > +		      case R_IA64_FPTR32LSB:
 > +		      case R_IA64_FPTR32MSB:
 > +		      case R_IA64_FPTR64LSB:
 > +		      case R_IA64_FPTR64MSB:
 > +		      case R_IA64_LTOFF_FPTR22:
 > +		      case R_IA64_LTOFF_FPTR32LSB:
 > +		      case R_IA64_LTOFF_FPTR32MSB:
 > +		      case R_IA64_LTOFF_FPTR64I:
 > +		      case R_IA64_LTOFF_FPTR64LSB:
 > +		      case R_IA64_LTOFF_FPTR64MSB:
 > +		      case R_IA64_IPLTMSB:
 > +		      case R_IA64_IPLTLSB:
 > +			/*
 > +			 * Jumps to static functions sometimes go straight to their
 > +			 * offset.  Of course, that may not be possible if the jump is
 > +			 * from init -> core or vice. versa, so we need to generate an
 > +			 * FDESC (and PLT etc) for that.
 > +			 */
 > +		      case R_IA64_PCREL21B:
 > +			if (!duplicate_reloc(rela, i))
 > +				ret++;
 > +			break;
 > +		}
 > +	}
 > +	return ret;
 > +}
 > +
 > +int
 > +module_frob_arch_sections (Elf_Ehdr *ehdr, Elf_Shdr *sechdrs, char *sec=
strings,
 > +			   struct module *mod)
 > +{
 > +	unsigned long core_plts =3D 0, init_plts =3D 0, gots =3D 0, fdescs =3D=
 0;
 > +	Elf64_Shdr *s, *sechdrs_end =3D sechdrs + ehdr->e_shnum;
 > +
 > +	/*
 > +	 * To store the PLTs and function-descriptors, we expand the .text sec=
tion for
 > +	 * core module-code and the .init.text section for initialization code.
 > +	 */
 > +	for (s =3D sechdrs; s < sechdrs_end; ++s)
 > +		if (strcmp(".core.plt", secstrings + s->sh_name) =3D=3D 0)
 > +			mod->arch.core_plt =3D s;
 > +		else if (strcmp(".init.plt", secstrings + s->sh_name) =3D=3D 0)
 > +			mod->arch.init_plt =3D s;
 > +		else if (strcmp(".got", secstrings + s->sh_name) =3D=3D 0)
 > +			mod->arch.got =3D s;
 > +		else if (strcmp(".opd", secstrings + s->sh_name) =3D=3D 0)
 > +			mod->arch.opd =3D s;
 > +		else if (strcmp(".IA_64.unwind", secstrings + s->sh_name) =3D=3D 0)
 > +			mod->arch.unwind =3D s;
 > +
 > +	if (!mod->arch.core_plt || !mod->arch.init_plt || !mod->arch.got || !m=
od->arch.opd) {
 > +		printk(KERN_ERR "%s: sections missing\n", mod->name);
 > +		return -ENOEXEC;
 > +	}
 > +
 > +	/* GOT and PLTs can occur in any relocated section... */
 > +	for (s =3D sechdrs + 1; s < sechdrs_end; ++s) {
 > +		const Elf64_Rela *rels =3D (void *)ehdr + s->sh_offset;
 > +		unsigned long numrels =3D s->sh_size/sizeof(Elf64_Rela);
 > +
 > +		if (s->sh_type !=3D SHT_RELA)
 > +			continue;
 > +
 > +		gots +=3D count_gots(rels, numrels);
 > +		fdescs +=3D count_fdescs(rels, numrels);
 > +		if (strstr(secstrings + s->sh_name, ".init"))
 > +			init_plts +=3D count_plts(rels, numrels);
 > +		else
 > +			core_plts +=3D count_plts(rels, numrels);
 > +	}
 > +
 > +	mod->arch.core_plt->sh_type =3D SHT_NOBITS;
 > +	mod->arch.core_plt->sh_flags =3D SHF_EXECINSTR | SHF_ALLOC;
 > +	mod->arch.core_plt->sh_addralign =3D 16;
 > +	mod->arch.core_plt->sh_size =3D core_plts * sizeof(struct plt_entry);
 > +	mod->arch.init_plt->sh_type =3D SHT_NOBITS;
 > +	mod->arch.init_plt->sh_flags =3D SHF_EXECINSTR | SHF_ALLOC;
 > +	mod->arch.init_plt->sh_addralign =3D 16;
 > +	mod->arch.init_plt->sh_size =3D init_plts * sizeof(struct plt_entry);
 > +	mod->arch.got->sh_type =3D SHT_NOBITS;
 > +	mod->arch.got->sh_flags =3D ARCH_SHF_SMALL | SHF_ALLOC;
 > +	mod->arch.got->sh_addralign =3D 8;
 > +	mod->arch.got->sh_size =3D gots * sizeof(struct got_entry);
 > +	mod->arch.opd->sh_type =3D SHT_NOBITS;
 > +	mod->arch.opd->sh_flags =3D SHF_ALLOC;
 > +	mod->arch.opd->sh_addralign =3D 8;
 > +	mod->arch.opd->sh_size =3D fdescs * sizeof(struct fdesc);
 > +	DEBUGP("%s: core.plt=3D%lx, init.plt=3D%lx, got=3D%lx, fdesc=3D%lx\n",
 > +	       __FUNCTION__, mod->arch.core_plt->sh_size, mod->arch.init_plt->=
sh_size,
 > +	       mod->arch.got->sh_size, mod->arch.opd->sh_size);
 > +	return 0;
 > +}
 > +
 > +static inline int
 > +in_init (const struct module *mod, uint64_t addr)
 > +{
 > +	return addr - (uint64_t) mod->module_init < mod->init_size;
 > +}
 > +
 > +static inline int
 > +in_core (const struct module *mod, uint64_t addr)
 > +{
 > +	return addr - (uint64_t) mod->module_core < mod->core_size;
 > +}
 > +
 > +static inline int
 > +is_internal (const struct module *mod, uint64_t value)
 > +{
 > +	return in_init(mod, value) || in_core(mod, value);
 > +}
 > +
 > +/*
 > + * Get gp-relative offset for the linkage-table entry of VALUE.
 > + */
 > +static uint64_t
 > +get_ltoff (struct module *mod, uint64_t value, int *okp)
 > +{
 > +	struct got_entry *got, *e;
 > +
 > +	if (!*okp)
 > +		return 0;
 > +
 > +	got =3D (void *) mod->arch.got->sh_addr;
 > +	for (e =3D got; e < got + mod->arch.next_got_entry; ++e)
 > +		if (e->val =3D=3D value)
 > +			goto found;
 > +
 > +	/* Not enough GOT entries? */
 > +	if (e >=3D (struct got_entry *) (mod->arch.got->sh_addr + mod->arch.go=
t->sh_size))
 > +		BUG();
 > +
 > +	e->val =3D value;
 > +	++mod->arch.next_got_entry;
 > +  found:
 > +	return (uint64_t) e - mod->arch.gp;
 > +}
 > +
 > +static inline int
 > +gp_addressable (struct module *mod, uint64_t value)
 > +{
 > +	return value - mod->arch.gp + MAX_LTOFF/2 < MAX_LTOFF;
 > +}
 > +
 > +/* Get PC-relative PLT entry for this value.  Returns 0 on failure. */
 > +static uint64_t
 > +get_plt (struct module *mod, const struct insn *insn, uint64_t value, i=
nt *okp)
 > +{
 > +	struct plt_entry *plt, *plt_end;
 > +	uint64_t target_ip, target_gp;
 > +
 > +	if (!*okp)
 > +		return 0;
 > +
 > +	if (in_init(mod, (uint64_t) insn)) {
 > +		plt =3D (void *) mod->arch.init_plt->sh_addr;
 > +		plt_end =3D (void *) plt + mod->arch.init_plt->sh_size;
 > +	} else {
 > +		plt =3D (void *) mod->arch.core_plt->sh_addr;
 > +		plt_end =3D (void *) plt + mod->arch.core_plt->sh_size;
 > +	}
 > +
 > +	/* "value" is a pointer to a function-descriptor; fetch the target ip/=
gp from it: */
 > +	target_ip =3D ((uint64_t *) value)[0];
 > +	target_gp =3D ((uint64_t *) value)[1];
 > +
 > +	/* Look for existing PLT entry. */
 > +	while (plt->bundle[0][0]) {
 > +		if (plt_target(plt) =3D=3D target_ip)
 > +			goto found;
 > +		if (++plt >=3D plt_end)
 > +			BUG();
 > +	}
 > +	*plt =3D ia64_plt_template;
 > +	if (!patch_plt(mod, plt, target_ip, target_gp)) {
 > +		*okp =3D 0;
 > +		return 0;
 > +	}
 > +#if ARCH_MODULE_DEBUG
 > +	if (plt_target(plt) !=3D target_ip) {
 > +		printk("%s: mistargeted PLT: wanted %lx, got %lx\n",
 > +		       __FUNCTION__, target_ip, plt_target(plt));
 > +		*okp =3D 0;
 > +		return 0;
 > +	}
 > +#endif
 > +  found:
 > +	return (uint64_t) plt;
 > +}
 > +
 > +/* Get function descriptor for VALUE. */
 > +static uint64_t
 > +get_fdesc (struct module *mod, uint64_t value, int *okp)
 > +{
 > +	struct fdesc *fdesc =3D (void *) mod->arch.opd->sh_addr;
 > +
 > +	if (!*okp)
 > +		return 0;
 > +
 > +	if (!value) {
 > +		printk(KERN_ERR "%s: fdesc for zero requested!\n", mod->name);
 > +		return 0;
 > +	}
 > +
 > +	if (!is_internal(mod, value))
 > +		/*
 > +		 * If it's not a module-local entry-point, "value" already points to a
 > +		 * function-descriptor.
 > +		 */
 > +		return value;
 > +
 > +	/* Look for existing function descriptor. */
 > +	while (fdesc->ip) {
 > +		if (fdesc->ip =3D=3D value)
 > +			return (uint64_t)fdesc;
 > +		if ((uint64_t) ++fdesc >=3D mod->arch.opd->sh_addr + mod->arch.opd->s=
h_size)
 > +			BUG();
 > +	}
 > +
 > +	/* Create new one */
 > +	fdesc->ip =3D value;
 > +	fdesc->gp =3D mod->arch.gp;
 > +	return (uint64_t) fdesc;
 > +}
 > +
 > +static inline int
 > +do_reloc (struct module *mod, uint8_t r_type, Elf64_Sym *sym, uint64_t =
addend,
 > +	  Elf64_Shdr *sec, void *location)
 > +{
 > +	enum reloc_target_format format =3D (r_type >> FORMAT_SHIFT) & FORMAT_=
MASK;
 > +	enum reloc_value_formula formula =3D (r_type >> VALUE_SHIFT) & VALUE_M=
ASK;
 > +	uint64_t val;
 > +	int ok =3D 1;
 > +
 > +	val =3D sym->st_value + addend;
 > +
 > +	switch (formula) {
 > +	      case RV_SEGREL:	/* segment base is arbitrarily chosen to be 0 fo=
r kernel modules */
 > +	      case RV_DIRECT:
 > +		break;
 > +
 > +	      case RV_GPREL:	  val -=3D mod->arch.gp; break;
 > +	      case RV_LTREL:	  val =3D get_ltoff(mod, val, &ok); break;
 > +	      case RV_PLTREL:	  val =3D get_plt(mod, location, val, &ok); brea=
k;
 > +	      case RV_FPTR:	  val =3D get_fdesc(mod, val, &ok); break;
 > +	      case RV_SECREL:	  val -=3D sec->sh_addr; break;
 > +	      case RV_LTREL_FPTR: val =3D get_ltoff(mod, get_fdesc(mod, val, &=
ok), &ok); break;
 > +
 > +	      case RV_PCREL:
 > +		switch (r_type) {
 > +		      case R_IA64_PCREL21B:
 > +			/* special because it can cross into other module/kernel-core.  */
 > +			if (!is_internal(mod, val))
 > +				val =3D get_plt(mod, location, val, &ok);
 > +			/* FALL THROUGH */
 > +		      default:
 > +			val -=3D bundle(location);
 > +			break;
 > +
 > +		      case R_IA64_PCREL32MSB:
 > +		      case R_IA64_PCREL32LSB:
 > +		      case R_IA64_PCREL64MSB:
 > +		      case R_IA64_PCREL64LSB:
 > +			val -=3D (uint64_t) location;
 > +			break;
 > +
 > +		}
 > +		switch (r_type) {
 > +		      case R_IA64_PCREL60B: format =3D RF_INSN60; break;
 > +		      case R_IA64_PCREL21B: format =3D RF_INSN21B; break;
 > +		      case R_IA64_PCREL21M: format =3D RF_INSN21M; break;
 > +		      case R_IA64_PCREL21F: format =3D RF_INSN21F; break;
 > +		      default: break;
 > +		}
 > +		break;
 > +
 > +	      case RV_BDREL:
 > +		val -=3D (uint64_t) (in_init(mod, val) ? mod->module_init : mod->modu=
le_core);
 > +		break;
 > +
 > +	      case RV_LTV:
 > +		/* can link-time value relocs happen here?  */
 > +		BUG();
 > +		break;
 > +
 > +	      case RV_PCREL2:
 > +		if (r_type =3D=3D R_IA64_PCREL21BI) {
 > +			if (!is_internal(mod, val)) {
 > +				printk(KERN_ERR "%s: %s reloc against non-local symbol (%lx)\n",
 > +				       __FUNCTION__, reloc_name[r_type], val);
 > +				return -ENOEXEC;
 > +			}
 > +			format =3D RF_INSN21B;
 > +		}
 > +		val -=3D bundle(location);
 > +		break;
 > +
 > +	      case RV_SPECIAL:
 > +		switch (r_type) {
 > +		      case R_IA64_IPLTMSB:
 > +		      case R_IA64_IPLTLSB:
 > +			val =3D get_fdesc(mod, get_plt(mod, location, val, &ok), &ok);
 > +			format =3D RF_64LSB;
 > +			if (r_type =3D=3D R_IA64_IPLTMSB)
 > +				format =3D RF_64MSB;
 > +			break;
 > +
 > +		      case R_IA64_SUB:
 > +			val =3D addend - sym->st_value;
 > +			format =3D RF_INSN64;
 > +			break;
 > +
 > +		      case R_IA64_LTOFF22X:
 > +			if (gp_addressable(mod, val))
 > +				val -=3D mod->arch.gp;
 > +			else
 > +				val =3D get_ltoff(mod, val, &ok);
 > +			format =3D RF_INSN22;
 > +			break;
 > +
 > +		      case R_IA64_LDXMOV:
 > +			if (gp_addressable(mod, val)) {
 > +				/* turn "ld8" into "mov": */
 > +				DEBUGP("%s: patching ld8 at %p to mov\n", __FUNCTION__, location);
 > +				apply(location, 0x1fff80fe000, 0x10000000000);
 > +			}
 > +			return 0;
 > +
 > +		      default:
 > +			if (reloc_name[r_type])
 > +				printk(KERN_ERR "%s: special reloc %s not supported",
 > +				       mod->name, reloc_name[r_type]);
 > +			else
 > +				printk(KERN_ERR "%s: unknown special reloc %x\n",
 > +				       mod->name, r_type);
 > +			return -ENOEXEC;
 > +		}
 > +		break;
 > +
 > +	      case RV_TPREL:
 > +	      case RV_LTREL_TPREL:
 > +	      case RV_DTPMOD:
 > +	      case RV_LTREL_DTPMOD:
 > +	      case RV_DTPREL:
 > +	      case RV_LTREL_DTPREL:
 > +		printk(KERN_ERR "%s: %s reloc not supported\n",
 > +		       mod->name, reloc_name[r_type] ? reloc_name[r_type] : "?");
 > +		return -ENOEXEC;
 > +
 > +	      default:
 > +		printk(KERN_ERR "%s: unknown reloc %x\n", mod->name, r_type);
 > +		return -ENOEXEC;
 > +	}
 > +
 > +	if (!ok)
 > +		return -ENOEXEC;
 > +
 > +	DEBUGP("%s: [%p]<-%016lx =3D %s(%lx)\n", __FUNCTION__, location, val,
 > +	       reloc_name[r_type] ? reloc_name[r_type] : "?", sym->st_value + =
addend);
 > +
 > +	switch (format) {
 > +	      case RF_INSN21B:	ok =3D apply_imm21b(mod, location, (int64_t) va=
l / 16); break;
 > +	      case RF_INSN22:	ok =3D apply_imm22(mod, location, val); break;
 > +	      case RF_INSN64:	ok =3D apply_imm64(mod, location, val); break;
 > +	      case RF_INSN60:	ok =3D apply_imm60(mod, location, (int64_t) val =
/ 16); break;
 > +	      case RF_32LSB:	put_unaligned(val, (uint32_t *) location); break;
 > +	      case RF_64LSB:	put_unaligned(val, (uint64_t *) location); break;
 > +	      case RF_32MSB:	/* ia64 Linux is little-endian... */
 > +	      case RF_64MSB:	/* ia64 Linux is little-endian... */
 > +	      case RF_INSN14:	/* must be within-module, i.e., resolved by "ld =
-r" */
 > +	      case RF_INSN21M:	/* must be within-module, i.e., resolved by "ld=
 -r" */
 > +	      case RF_INSN21F:	/* must be within-module, i.e., resolved by "ld=
 -r" */
 > +		printk(KERN_ERR "%s: format %u needed by %s reloc is not supported\n",
 > +		       mod->name, format, reloc_name[r_type] ? reloc_name[r_type] : "=
?");
 > +		return -ENOEXEC;
 > +
 > +	      default:
 > +		printk(KERN_ERR "%s: relocation %s resulted in unknown format %u\n",
 > +		       mod->name, reloc_name[r_type] ? reloc_name[r_type] : "?", form=
at);
 > +		return -ENOEXEC;
 > +	}
 > +	return ok ? 0 : -ENOEXEC;
 > +}
 > +
 > +int
 > +apply_relocate_add (Elf64_Shdr *sechdrs, const char *strtab, unsigned i=
nt symindex,
 > +		    unsigned int relsec, struct module *mod)
 > +{
 > +	unsigned int i, n =3D sechdrs[relsec].sh_size / sizeof(Elf64_Rela);
 > +	Elf64_Rela *rela =3D (void *) sechdrs[relsec].sh_addr;
 > +	Elf64_Shdr *target_sec;
 > +	int ret;
 > +
 > +	DEBUGP("%s: applying section %u (%u relocs) to %u\n", __FUNCTION__,
 > +	       relsec, n, sechdrs[relsec].sh_info);
 > +
 > +	target_sec =3D sechdrs + sechdrs[relsec].sh_info;
 > +
 > +	if (target_sec->sh_entsize =3D=3D ~0UL)
 > +		/*
 > +		 * If target section wasn't allocated, we don't need to relocate it.
 > +		 * Happens, e.g., for debug sections.
 > +		 */
 > +		return 0;
 > +
 > +	if (!mod->arch.gp) {
 > +		/*
 > +		 * XXX Should have an arch-hook for running this after final section
 > +		 *     addresses have been selected...
 > +		 */
 > +		/* See if gp can cover the entire core module:  */
 > +		uint64_t gp =3D (uint64_t) mod->module_core + MAX_LTOFF / 2;
 > +		if (mod->core_size >=3D MAX_LTOFF)
 > +			/*
 > +			 * This takes advantage of fact that SHF_ARCH_SMALL gets allocated
 > +			 * at the end of the module.
 > +			 */
 > +			gp =3D (uint64_t) mod->module_core + mod->core_size - MAX_LTOFF / 2;
 > +		mod->arch.gp =3D gp;
 > +		DEBUGP("%s: placing gp at 0x%lx\n", __FUNCTION__, gp);
 > +	}
 > +
 > +	for (i =3D 0; i < n; i++) {
 > +		ret =3D do_reloc(mod, ELF64_R_TYPE(rela[i].r_info),
 > +			       ((Elf64_Sym *) sechdrs[symindex].sh_addr
 > +				+ ELF64_R_SYM(rela[i].r_info)),
 > +			       rela[i].r_addend, target_sec,
 > +			       (void *) target_sec->sh_addr + rela[i].r_offset);
 > +		if (ret < 0)
 > +			return ret;
 > +	}
 > +	return 0;
 > +}
 > +
 > +int
 > +apply_relocate (Elf64_Shdr *sechdrs, const char *strtab, unsigned int s=
ymindex,
 > +		unsigned int relsec, struct module *mod)
 > +{
 > +	printk(KERN_ERR "module %s: REL relocs in section %u unsupported\n", m=
od->name, relsec);
 > +	return -ENOEXEC;
 > +}
 > +
 > +int
 > +module_finalize (const Elf_Ehdr *hdr, const Elf_Shdr *sechdrs, struct m=
odule *mod)
 > +{
 > +	DEBUGP("%s: init: entry=3D%p\n", __FUNCTION__, mod->init);
 > +	if (mod->arch.unwind)
 > +		mod->arch.unw_table =3D unw_add_unwind_table(mod->name, 0, mod->arch.=
gp,
 > +							   (void *) mod->arch.unwind->sh_addr,
 > +							   ((void *) mod->arch.unwind->sh_addr
 > +							    + mod->arch.unwind->sh_size));
 > +	return 0;
 > +}
 > +
 > +void
 > +module_arch_cleanup (struct module *mod)
 > +{
 > +	if (mod->arch.unwind)
 > +		unw_remove_unwind_table(mod->arch.unw_table);
 > +}
 > diff -Nru a/arch/ia64/module.lds b/arch/ia64/module.lds
 > --- /dev/null	Wed Dec 31 16:00:00 1969
 > +++ b/arch/ia64/module.lds	Wed Mar 26 12:21:12 2003
 > @@ -0,0 +1,13 @@
 > +SECTIONS {
 > +	/* Group unwind sections into a single section: */
 > +	.IA_64.unwind_info : { *(.IA_64.unwind_info*) }
 > +	.IA_64.unwind : { *(.IA_64.unwind*) }
 > +	/*
 > +	 * Create place-holder sections to hold the PLTs, GOT, and
 > +	 * official procedure-descriptors (.opd).
 > +	 */
 > +	.core.plt : { BYTE(0) }
 > +	.init.plt : { BYTE(0) }
 > +	.got : { BYTE(0) }
 > +	.opd : { BYTE(0) }
 > +}
 > diff -Nru a/include/asm-ia64/module.h b/include/asm-ia64/module.h
 > --- a/include/asm-ia64/module.h	Wed Mar 26 12:21:12 2003
 > +++ b/include/asm-ia64/module.h	Wed Mar 26 12:21:12 2003
 > @@ -1,6 +1,34 @@
 >  #ifndef _ASM_IA64_MODULE_H
 >  #define _ASM_IA64_MODULE_H
 > =20
 > -/* Module support currently broken (due to in-kernel module loader).  */
 > +/*
 > + * IA-64-specific support for kernel module loader.
 > + *
 > + * Copyright (C) 2003 Hewlett-Packard Co
 > + *	David Mosberger-Tang <davidm@hpl.hp.com>
 > + */
 > +
 > +struct elf64_shdr;			/* forward declration */
 > +
 > +struct mod_arch_specific {
 > +	struct elf64_shdr *core_plt;	/* core PLT section */
 > +	struct elf64_shdr *init_plt;	/* init PLT section */
 > +	struct elf64_shdr *got;		/* global offset table */
 > +	struct elf64_shdr *opd;		/* official procedure descriptors */
 > +	struct elf64_shdr *unwind;	/* unwind-table section */
 > +	unsigned long gp;		/* global-pointer for module */
 > +
 > +	void *unw_table;		/* unwind-table cookie returned by unwinder */
 > +	unsigned int next_got_entry;	/* index of next available got entry */
 > +};
 > +
 > +#define Elf_Shdr	Elf64_Shdr
 > +#define Elf_Sym		Elf64_Sym
 > +#define Elf_Ehdr	Elf64_Ehdr
 > +
 > +#define MODULE_PROC_FAMILY	"ia64"
 > +#define MODULE_ARCH_VERMAGIC	MODULE_PROC_FAMILY
 > +
 > +#define ARCH_SHF_SMALL	SHF_IA_64_SHORT
 > =20
 >  #endif /* _ASM_IA64_MODULE_H */
 > diff -Nru a/include/asm-ia64/unaligned.h b/include/asm-ia64/unaligned.h
 > --- a/include/asm-ia64/unaligned.h	Wed Mar 26 12:21:12 2003
 > +++ b/include/asm-ia64/unaligned.h	Wed Mar 26 12:21:12 2003
 > @@ -7,8 +7,8 @@
 >   * The main single-value unaligned transfer routines.  Derived from
 >   * the Linux/Alpha version.
 >   *
 > - * Copyright (C) 1998, 1999 Hewlett-Packard Co
 > - * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
 > + * Copyright (C) 1998, 1999, 2003 Hewlett-Packard Co
 > + *	David Mosberger-Tang <davidm@hpl.hp.com>
 >   */
 >  #define get_unaligned(ptr) \
 >  	((__typeof__(*(ptr)))ia64_get_unaligned((ptr), sizeof(*(ptr))))
 > @@ -16,110 +16,105 @@
 >  #define put_unaligned(x,ptr) \
 >  	ia64_put_unaligned((unsigned long)(x), (ptr), sizeof(*(ptr)))
 > =20
 > -/*
 > - * EGCS 1.1 knows about arbitrary unaligned loads.  Define some
 > - * packed structures to talk about such things with.
 > - */
 >  struct __una_u64 { __u64 x __attribute__((packed)); };
 >  struct __una_u32 { __u32 x __attribute__((packed)); };
 >  struct __una_u16 { __u16 x __attribute__((packed)); };
 > =20
 >  static inline unsigned long
 > -__uldq (const unsigned long * r11)
 > +__uld8 (const unsigned long * addr)
 >  {
 > -	const struct __una_u64 *ptr =3D (const struct __una_u64 *) r11;
 > +	const struct __una_u64 *ptr =3D (const struct __una_u64 *) addr;
 >  	return ptr->x;
 >  }
 > =20
 >  static inline unsigned long
 > -__uldl (const unsigned int * r11)
 > +__uld4 (const unsigned int * addr)
 >  {
 > -	const struct __una_u32 *ptr =3D (const struct __una_u32 *) r11;
 > +	const struct __una_u32 *ptr =3D (const struct __una_u32 *) addr;
 >  	return ptr->x;
 >  }
 > =20
 >  static inline unsigned long
 > -__uldw (const unsigned short * r11)
 > +__uld2 (const unsigned short * addr)
 >  {
 > -	const struct __una_u16 *ptr =3D (const struct __una_u16 *) r11;
 > +	const struct __una_u16 *ptr =3D (const struct __una_u16 *) addr;
 >  	return ptr->x;
 >  }
 > =20
 >  static inline void
 > -__ustq (unsigned long r5, unsigned long * r11)
 > +__ust8 (unsigned long val, unsigned long * addr)
 >  {
 > -	struct __una_u64 *ptr =3D (struct __una_u64 *) r11;
 > -	ptr->x =3D r5;
 > +	struct __una_u64 *ptr =3D (struct __una_u64 *) addr;
 > +	ptr->x =3D val;
 >  }
 > =20
 >  static inline void
 > -__ustl (unsigned long r5, unsigned int * r11)
 > +__ust4 (unsigned long val, unsigned int * addr)
 >  {
 > -	struct __una_u32 *ptr =3D (struct __una_u32 *) r11;
 > -	ptr->x =3D r5;
 > +	struct __una_u32 *ptr =3D (struct __una_u32 *) addr;
 > +	ptr->x =3D val;
 >  }
 > =20
 >  static inline void
 > -__ustw (unsigned long r5, unsigned short * r11)
 > +__ust2 (unsigned long val, unsigned short * addr)
 >  {
 > -	struct __una_u16 *ptr =3D (struct __una_u16 *) r11;
 > -	ptr->x =3D r5;
 > +	struct __una_u16 *ptr =3D (struct __una_u16 *) addr;
 > +	ptr->x =3D val;
 >  }
 > =20
 > =20
 >  /*
 > - * This function doesn't actually exist.  The idea is that when
 > - * someone uses the macros below with an unsupported size (datatype),
 > - * the linker will alert us to the problem via an unresolved reference
 > - * error.
 > + * This function doesn't actually exist.  The idea is that when someone=
 uses the macros
 > + * below with an unsupported size (datatype), the linker will alert us =
to the problem via
 > + * an unresolved reference error.
 >   */
 >  extern unsigned long ia64_bad_unaligned_access_length (void);
 > =20
 > -#define ia64_get_unaligned(_ptr,size)				\
 > -({								\
 > -	const void *ptr =3D (_ptr);				\
 > -	unsigned long val;					\
 > -								\
 > -	switch (size) {						\
 > -	      case 1:						\
 > -		val =3D *(const unsigned char *) ptr;		\
 > -		break;						\
 > -	      case 2:						\
 > -		val =3D __uldw((const unsigned short *)ptr);	\
 > -		break;						\
 > -	      case 4:						\
 > -		val =3D __uldl((const unsigned int *)ptr);	\
 > -		break;						\
 > -	      case 8:						\
 > -		val =3D __uldq((const unsigned long *)ptr);	\
 > -		break;						\
 > -	      default:						\
 > -		val =3D ia64_bad_unaligned_access_length();	\
 > -	}							\
 > -	val;							\
 > +#define ia64_get_unaligned(_ptr,size)						\
 > +({										\
 > +	const void *__ia64_ptr =3D (_ptr);					\
 > +	unsigned long __ia64_val;						\
 > +										\
 > +	switch (size) {								\
 > +	      case 1:								\
 > +		__ia64_val =3D *(const unsigned char *) __ia64_ptr;		\
 > +		break;								\
 > +	      case 2:								\
 > +		__ia64_val =3D __uld2((const unsigned short *)__ia64_ptr);	\
 > +		break;								\
 > +	      case 4:								\
 > +		__ia64_val =3D __uld4((const unsigned int *)__ia64_ptr);		\
 > +		break;								\
 > +	      case 8:								\
 > +		__ia64_val =3D __uld8((const unsigned long *)__ia64_ptr);		\
 > +		break;								\
 > +	      default:								\
 > +		__ia64_val =3D ia64_bad_unaligned_access_length();		\
 > +	}									\
 > +	__ia64_val;								\
 >  })
 > =20
 > -#define ia64_put_unaligned(_val,_ptr,size)		\
 > -do {							\
 > -	const void *ptr =3D (_ptr);			\
 > -	unsigned long val =3D (_val);			\
 > -							\
 > -	switch (size) {					\
 > -	      case 1:					\
 > -		*(unsigned char *)ptr =3D (val);		\
 > -	        break;					\
 > -	      case 2:					\
 > -		__ustw(val, (unsigned short *)ptr);	\
 > -		break;					\
 > -	      case 4:					\
 > -		__ustl(val, (unsigned int *)ptr);	\
 > -		break;					\
 > -	      case 8:					\
 > -		__ustq(val, (unsigned long *)ptr);	\
 > -		break;					\
 > -	      default:					\
 > -	    	ia64_bad_unaligned_access_length();	\
 > -	}						\
 > +#define ia64_put_unaligned(_val,_ptr,size)				\
 > +do {									\
 > +	const void *__ia64_ptr =3D (_ptr);				\
 > +	unsigned long __ia64_val =3D (_val);				\
 > +									\
 > +	switch (size) {							\
 > +	      case 1:							\
 > +		*(unsigned char *)__ia64_ptr =3D (__ia64_val);		\
 > +	        break;							\
 > +	      case 2:							\
 > +		__ust2(__ia64_val, (unsigned short *)__ia64_ptr);	\
 > +		break;							\
 > +	      case 4:							\
 > +		__ust4(__ia64_val, (unsigned int *)__ia64_ptr);		\
 > +		break;							\
 > +	      case 8:							\
 > +		__ust8(__ia64_val, (unsigned long *)__ia64_ptr);	\
 > +		break;							\
 > +	      default:							\
 > +	    	ia64_bad_unaligned_access_length();			\
 > +	}								\
 >  } while (0)
 > =20
 >  #endif /* _ASM_IA64_UNALIGNED_H */
 > diff -Nru a/include/linux/elf.h b/include/linux/elf.h
 > --- a/include/linux/elf.h	Wed Mar 26 12:21:12 2003
 > +++ b/include/linux/elf.h	Wed Mar 26 12:21:12 2003
 > @@ -224,6 +224,90 @@
 >  #define R_386_GOTPC	10
 >  #define R_386_NUM	11
 > =20
 > +#define R_IA64_NONE		0x00	/* none */
 > +#define R_IA64_IMM14		0x21	/* symbol + addend, add imm14 */
 > +#define R_IA64_IMM22		0x22	/* symbol + addend, add imm22 */
 > +#define R_IA64_IMM64		0x23	/* symbol + addend, mov imm64 */
 > +#define R_IA64_DIR32MSB		0x24	/* symbol + addend, data4 MSB */
 > +#define R_IA64_DIR32LSB		0x25	/* symbol + addend, data4 LSB */
 > +#define R_IA64_DIR64MSB		0x26	/* symbol + addend, data8 MSB */
 > +#define R_IA64_DIR64LSB		0x27	/* symbol + addend, data8 LSB */
 > +#define R_IA64_GPREL22		0x2a	/* @gprel(sym+add), add imm22 */
 > +#define R_IA64_GPREL64I		0x2b	/* @gprel(sym+add), mov imm64 */
 > +#define R_IA64_GPREL32MSB	0x2c	/* @gprel(sym+add), data4 MSB */
 > +#define R_IA64_GPREL32LSB	0x2d	/* @gprel(sym+add), data4 LSB */
 > +#define R_IA64_GPREL64MSB	0x2e	/* @gprel(sym+add), data8 MSB */
 > +#define R_IA64_GPREL64LSB	0x2f	/* @gprel(sym+add), data8 LSB */
 > +#define R_IA64_LTOFF22		0x32	/* @ltoff(sym+add), add imm22 */
 > +#define R_IA64_LTOFF64I		0x33	/* @ltoff(sym+add), mov imm64 */
 > +#define R_IA64_PLTOFF22		0x3a	/* @pltoff(sym+add), add imm22 */
 > +#define R_IA64_PLTOFF64I	0x3b	/* @pltoff(sym+add), mov imm64 */
 > +#define R_IA64_PLTOFF64MSB	0x3e	/* @pltoff(sym+add), data8 MSB */
 > +#define R_IA64_PLTOFF64LSB	0x3f	/* @pltoff(sym+add), data8 LSB */
 > +#define R_IA64_FPTR64I		0x43	/* @fptr(sym+add), mov imm64 */
 > +#define R_IA64_FPTR32MSB	0x44	/* @fptr(sym+add), data4 MSB */
 > +#define R_IA64_FPTR32LSB	0x45	/* @fptr(sym+add), data4 LSB */
 > +#define R_IA64_FPTR64MSB	0x46	/* @fptr(sym+add), data8 MSB */
 > +#define R_IA64_FPTR64LSB	0x47	/* @fptr(sym+add), data8 LSB */
 > +#define R_IA64_PCREL60B		0x48	/* @pcrel(sym+add), brl */
 > +#define R_IA64_PCREL21B		0x49	/* @pcrel(sym+add), ptb, call */
 > +#define R_IA64_PCREL21M		0x4a	/* @pcrel(sym+add), chk.s */
 > +#define R_IA64_PCREL21F		0x4b	/* @pcrel(sym+add), fchkf */
 > +#define R_IA64_PCREL32MSB	0x4c	/* @pcrel(sym+add), data4 MSB */
 > +#define R_IA64_PCREL32LSB	0x4d	/* @pcrel(sym+add), data4 LSB */
 > +#define R_IA64_PCREL64MSB	0x4e	/* @pcrel(sym+add), data8 MSB */
 > +#define R_IA64_PCREL64LSB	0x4f	/* @pcrel(sym+add), data8 LSB */
 > +#define R_IA64_LTOFF_FPTR22	0x52	/* @ltoff(@fptr(s+a)), imm22 */
 > +#define R_IA64_LTOFF_FPTR64I	0x53	/* @ltoff(@fptr(s+a)), imm64 */
 > +#define R_IA64_LTOFF_FPTR32MSB	0x54	/* @ltoff(@fptr(s+a)), 4 MSB */
 > +#define R_IA64_LTOFF_FPTR32LSB	0x55	/* @ltoff(@fptr(s+a)), 4 LSB */
 > +#define R_IA64_LTOFF_FPTR64MSB	0x56	/* @ltoff(@fptr(s+a)), 8 MSB */
 > +#define R_IA64_LTOFF_FPTR64LSB	0x57	/* @ltoff(@fptr(s+a)), 8 LSB */
 > +#define R_IA64_SEGREL32MSB	0x5c	/* @segrel(sym+add), data4 MSB */
 > +#define R_IA64_SEGREL32LSB	0x5d	/* @segrel(sym+add), data4 LSB */
 > +#define R_IA64_SEGREL64MSB	0x5e	/* @segrel(sym+add), data8 MSB */
 > +#define R_IA64_SEGREL64LSB	0x5f	/* @segrel(sym+add), data8 LSB */
 > +#define R_IA64_SECREL32MSB	0x64	/* @secrel(sym+add), data4 MSB */
 > +#define R_IA64_SECREL32LSB	0x65	/* @secrel(sym+add), data4 LSB */
 > +#define R_IA64_SECREL64MSB	0x66	/* @secrel(sym+add), data8 MSB */
 > +#define R_IA64_SECREL64LSB	0x67	/* @secrel(sym+add), data8 LSB */
 > +#define R_IA64_REL32MSB		0x6c	/* data 4 + REL */
 > +#define R_IA64_REL32LSB		0x6d	/* data 4 + REL */
 > +#define R_IA64_REL64MSB		0x6e	/* data 8 + REL */
 > +#define R_IA64_REL64LSB		0x6f	/* data 8 + REL */
 > +#define R_IA64_LTV32MSB		0x74	/* symbol + addend, data4 MSB */
 > +#define R_IA64_LTV32LSB		0x75	/* symbol + addend, data4 LSB */
 > +#define R_IA64_LTV64MSB		0x76	/* symbol + addend, data8 MSB */
 > +#define R_IA64_LTV64LSB		0x77	/* symbol + addend, data8 LSB */
 > +#define R_IA64_PCREL21BI	0x79	/* @pcrel(sym+add), ptb, call */
 > +#define R_IA64_PCREL22		0x7a	/* @pcrel(sym+add), imm22 */
 > +#define R_IA64_PCREL64I		0x7b	/* @pcrel(sym+add), imm64 */
 > +#define R_IA64_IPLTMSB		0x80	/* dynamic reloc, imported PLT, MSB */
 > +#define R_IA64_IPLTLSB		0x81	/* dynamic reloc, imported PLT, LSB */
 > +#define R_IA64_COPY		0x84	/* dynamic reloc, data copy */
 > +#define R_IA64_SUB		0x85	/* -symbol + addend, add imm22 */
 > +#define R_IA64_LTOFF22X		0x86	/* LTOFF22, relaxable.  */
 > +#define R_IA64_LDXMOV		0x87	/* Use of LTOFF22X.  */
 > +#define R_IA64_TPREL14		0x91	/* @tprel(sym+add), add imm14 */
 > +#define R_IA64_TPREL22		0x92	/* @tprel(sym+add), add imm22 */
 > +#define R_IA64_TPREL64I		0x93	/* @tprel(sym+add), add imm64 */
 > +#define R_IA64_TPREL64MSB	0x96	/* @tprel(sym+add), data8 MSB */
 > +#define R_IA64_TPREL64LSB	0x97	/* @tprel(sym+add), data8 LSB */
 > +#define R_IA64_LTOFF_TPREL22	0x9a	/* @ltoff(@tprel(s+a)), add imm22 */
 > +#define R_IA64_DTPMOD64MSB	0xa6	/* @dtpmod(sym+add), data8 MSB */
 > +#define R_IA64_DTPMOD64LSB	0xa7	/* @dtpmod(sym+add), data8 LSB */
 > +#define R_IA64_LTOFF_DTPMOD22	0xaa	/* @ltoff(@dtpmod(s+a)), imm22 */
 > +#define R_IA64_DTPREL14		0xb1	/* @dtprel(sym+add), imm14 */
 > +#define R_IA64_DTPREL22		0xb2	/* @dtprel(sym+add), imm22 */
 > +#define R_IA64_DTPREL64I	0xb3	/* @dtprel(sym+add), imm64 */
 > +#define R_IA64_DTPREL32MSB	0xb4	/* @dtprel(sym+add), data4 MSB */
 > +#define R_IA64_DTPREL32LSB	0xb5	/* @dtprel(sym+add), data4 LSB */
 > +#define R_IA64_DTPREL64MSB	0xb6	/* @dtprel(sym+add), data8 MSB */
 > +#define R_IA64_DTPREL64LSB	0xb7	/* @dtprel(sym+add), data8 LSB */
 > +#define R_IA64_LTOFF_DTPREL22	0xba	/* @ltoff(@dtprel(s+a)), imm22 */
 > +
 > +#define SHF_IA_64_SHORT		0x10000000	/* section near gp */
 > +
 >  #define R_MIPS_NONE		0
 >  #define R_MIPS_16		1
 >  #define R_MIPS_32		2
 > diff -Nru a/include/linux/moduleloader.h b/include/linux/moduleloader.h
 > --- a/include/linux/moduleloader.h	Wed Mar 26 12:21:12 2003
 > +++ b/include/linux/moduleloader.h	Wed Mar 26 12:21:12 2003
 > @@ -41,4 +41,7 @@
 >  		    const Elf_Shdr *sechdrs,
 >  		    struct module *mod);
 > =20
 > +/* Any cleanup needed when module leaves. */
 > +void module_arch_cleanup(struct module *mod);
 > +
 >  #endif
 > diff -Nru a/kernel/module.c b/kernel/module.c
 > --- a/kernel/module.c	Wed Mar 26 12:21:12 2003
 > +++ b/kernel/module.c	Wed Mar 26 12:21:12 2003
 > @@ -868,6 +868,9 @@
 >  	list_del(&mod->extable.list);
 >  	spin_unlock_irq(&modlist_lock);
 > =20
 > +	/* Arch-specific cleanup. */
 > +	module_arch_cleanup(mod);
 > +
 >  	/* Module unload stuff */
 >  	module_unload_free(mod);
 > =20
 > @@ -1199,6 +1202,7 @@
 >  	mod->module_init =3D ptr;
 > =20
 >  	/* Transfer each section which specifies SHF_ALLOC */
 > +	DEBUGP("final section addresses:\n");
 >  	for (i =3D 0; i < hdr->e_shnum; i++) {
 >  		void *dest;
 > =20
 > @@ -1216,6 +1220,7 @@
 >  			       sechdrs[i].sh_size);
 >  		/* Update sh_addr to point to copy in image. */
 >  		sechdrs[i].sh_addr =3D (unsigned long)dest;
 > +		DEBUGP("\t0x%lx %s\n", sechdrs[i].sh_addr, secstrings + sechdrs[i].sh=
_name);
 >  	}
 >  	/* Module has been moved. */
 >  	mod =3D (void *)sechdrs[modindex].sh_addr;
 >=20
 >=20
 >=20
 > --__--__--
 >=20
 > _______________________________________________
 > Linux-IA64 mailing list
 > Linux-IA64@linuxia64.org
 > http://lists.linuxia64.org/lists/listinfo/linux-ia64
 >=20
 >=20
 > End of Linux-IA64 Digest

