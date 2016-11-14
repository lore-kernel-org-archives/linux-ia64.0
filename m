From: Baoquan He <bhe@redhat.com>
Date: Mon, 14 Nov 2016 05:36:27 +0000
Subject: Re: [PATCH 1/3] crash: move crashkernel parsing and vmcore related code under CONFIG_CRASH_CORE
Message-Id: <20161114053627.GC19995@x1>
List-Id: <linux-ia64.vger.kernel.org>
References: <147877899077.31483.3740501843050856595.stgit@hbathini.in.ibm.com>
 <147877904646.31483.2251653505359017982.stgit@hbathini.in.ibm.com>
In-Reply-To: <147877904646.31483.2251653505359017982.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, kexec@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, ebiederm@xmission.com, Michael Ellerman <mpe@ellerman.id.au>, dyoung@redhat.com, vgoyal@redhat.com

On 11/10/16 at 05:27pm, Hari Bathini wrote:
> Traditionally, kdump is used to save vmcore in case of a crash. Some
> architectures like powerpc can save vmcore using architecture specific
> support instead of kexec/kdump mechanism. Such architecture specific
> support also needs to reserve memory, to be used by dump capture kernel.
> crashkernel parameter can be a reused, for memory reservation, by such
> architecture specific infrastructure.
> 
> But currently, code related to vmcoreinfo and parsing of crashkernel
> parameter is built under CONFIG_KEXEC_CORE. This patch introduces
> CONFIG_CRASH_CORE and moves the above mentioned code under this config,
> allowing code reuse without dependency on CONFIG_KEXEC. While here,
> removing the multiple definitions of append_elf_note() and final_note()
> for one defined under CONFIG_CONFIG_CORE. There is no functional change
> with this patch.

Can't think of a reason to object.

Could it be that do the moving from kexec_core.c to crash_core.c only,
then do the arch specific clean up in another patch?

Besides there's already a file crash_dump.h, can we reuse that?

> 
> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
> ---
>  arch/Kconfig                       |    4 
>  arch/ia64/kernel/crash.c           |   22 --
>  arch/powerpc/Kconfig               |   10 -
>  arch/powerpc/include/asm/fadump.h  |    2 
>  arch/powerpc/kernel/crash.c        |    2 
>  arch/powerpc/kernel/fadump.c       |   34 ---
>  arch/powerpc/kernel/setup-common.c |    5 
>  include/linux/crash_core.h         |   75 ++++++
>  include/linux/kexec.h              |   63 -----
>  kernel/Makefile                    |    1 
>  kernel/crash_core.c                |  450 ++++++++++++++++++++++++++++++++++++
>  kernel/kexec_core.c                |  435 -----------------------------------
>  12 files changed, 550 insertions(+), 553 deletions(-)
>  create mode 100644 include/linux/crash_core.h
>  create mode 100644 kernel/crash_core.c
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 659bdd0..4ad34b9 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -2,7 +2,11 @@
>  # General architecture dependent options
>  #
>  
> +config CRASH_CORE
> +	bool
> +
>  config KEXEC_CORE
> +	select CRASH_CORE
>  	bool
>  
>  config OPROFILE
> diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
> index 2955f35..75859a0 100644
> --- a/arch/ia64/kernel/crash.c
> +++ b/arch/ia64/kernel/crash.c
> @@ -27,28 +27,6 @@ static int kdump_freeze_monarch;
>  static int kdump_on_init = 1;
>  static int kdump_on_fatal_mca = 1;
>  
> -static inline Elf64_Word
> -*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
> -		size_t data_len)
> -{
> -	struct elf_note *note = (struct elf_note *)buf;
> -	note->n_namesz = strlen(name) + 1;
> -	note->n_descsz = data_len;
> -	note->n_type   = type;
> -	buf += (sizeof(*note) + 3)/4;
> -	memcpy(buf, name, note->n_namesz);
> -	buf += (note->n_namesz + 3)/4;
> -	memcpy(buf, data, data_len);
> -	buf += (data_len + 3)/4;
> -	return buf;
> -}
> -
> -static void
> -final_note(void *buf)
> -{
> -	memset(buf, 0, sizeof(struct elf_note));
> -}
> -
>  extern void ia64_dump_cpu_regs(void *);
>  
>  static DEFINE_PER_CPU(struct elf_prstatus, elf_prstatus);
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 65fba4c..644703f 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -479,21 +479,23 @@ config RELOCATABLE
>  	  load address of the kernel (eg. u-boot/mkimage).
>  
>  config CRASH_DUMP
> -	bool "Build a kdump crash kernel"
> +	bool "Build a dump capture kernel"
>  	depends on PPC64 || 6xx || FSL_BOOKE || (44x && !SMP)
>  	select RELOCATABLE if (PPC64 && !COMPILE_TEST) || 44x || FSL_BOOKE
>  	help
> -	  Build a kernel suitable for use as a kdump capture kernel.
> +	  Build a kernel suitable for use as a dump capture kernel.
>  	  The same kernel binary can be used as production kernel and dump
>  	  capture kernel.
>  
>  config FA_DUMP
>  	bool "Firmware-assisted dump"
> -	depends on PPC64 && PPC_RTAS && CRASH_DUMP && KEXEC
> +	depends on PPC64 && PPC_RTAS
> +	select CRASH_CORE
> +	select CRASH_DUMP
>  	help
>  	  A robust mechanism to get reliable kernel crash dump with
>  	  assistance from firmware. This approach does not use kexec,
> -	  instead firmware assists in booting the kdump kernel
> +	  instead firmware assists in booting the capture kernel
>  	  while preserving memory contents. Firmware-assisted dump
>  	  is meant to be a kdump replacement offering robustness and
>  	  speed not possible without system firmware assistance.
> diff --git a/arch/powerpc/include/asm/fadump.h b/arch/powerpc/include/asm/fadump.h
> index 0031806..60b9108 100644
> --- a/arch/powerpc/include/asm/fadump.h
> +++ b/arch/powerpc/include/asm/fadump.h
> @@ -73,6 +73,8 @@
>  	reg_entry++;							\
>  })
>  
> +extern int crashing_cpu;
> +
>  /* Kernel Dump section info */
>  struct fadump_section {
>  	__be32	request_flag;
> diff --git a/arch/powerpc/kernel/crash.c b/arch/powerpc/kernel/crash.c
> index 47b63de..cbabb5a 100644
> --- a/arch/powerpc/kernel/crash.c
> +++ b/arch/powerpc/kernel/crash.c
> @@ -43,8 +43,6 @@
>  #define IPI_TIMEOUT		10000
>  #define REAL_MODE_TIMEOUT	10000
>  
> -/* This keeps a track of which one is the crashing cpu. */
> -int crashing_cpu = -1;
>  static int time_to_dump;
>  
>  #define CRASH_HANDLER_MAX 3
> diff --git a/arch/powerpc/kernel/fadump.c b/arch/powerpc/kernel/fadump.c
> index 8f0c7c5..db0b339 100644
> --- a/arch/powerpc/kernel/fadump.c
> +++ b/arch/powerpc/kernel/fadump.c
> @@ -486,34 +486,6 @@ fadump_read_registers(struct fadump_reg_entry *reg_entry, struct pt_regs *regs)
>  	return reg_entry;
>  }
>  
> -static u32 *fadump_append_elf_note(u32 *buf, char *name, unsigned type,
> -						void *data, size_t data_len)
> -{
> -	struct elf_note note;
> -
> -	note.n_namesz = strlen(name) + 1;
> -	note.n_descsz = data_len;
> -	note.n_type   = type;
> -	memcpy(buf, &note, sizeof(note));
> -	buf += (sizeof(note) + 3)/4;
> -	memcpy(buf, name, note.n_namesz);
> -	buf += (note.n_namesz + 3)/4;
> -	memcpy(buf, data, note.n_descsz);
> -	buf += (note.n_descsz + 3)/4;
> -
> -	return buf;
> -}
> -
> -static void fadump_final_note(u32 *buf)
> -{
> -	struct elf_note note;
> -
> -	note.n_namesz = 0;
> -	note.n_descsz = 0;
> -	note.n_type   = 0;
> -	memcpy(buf, &note, sizeof(note));
> -}
> -
>  static u32 *fadump_regs_to_elf_notes(u32 *buf, struct pt_regs *regs)
>  {
>  	struct elf_prstatus prstatus;
> @@ -524,8 +496,8 @@ static u32 *fadump_regs_to_elf_notes(u32 *buf, struct pt_regs *regs)
>  	 * prstatus.pr_pid = ????
>  	 */
>  	elf_core_copy_kernel_regs(&prstatus.pr_reg, regs);
> -	buf = fadump_append_elf_note(buf, KEXEC_CORE_NOTE_NAME, NT_PRSTATUS,
> -				&prstatus, sizeof(prstatus));
> +	buf = append_elf_note(buf, CRASH_CORE_NOTE_NAME, NT_PRSTATUS,
> +			      &prstatus, sizeof(prstatus));
>  	return buf;
>  }
>  
> @@ -666,7 +638,7 @@ static int __init fadump_build_cpu_notes(const struct fadump_mem_struct *fdm)
>  			note_buf = fadump_regs_to_elf_notes(note_buf, &regs);
>  		}
>  	}
> -	fadump_final_note(note_buf);
> +	final_note(note_buf);
>  
>  	if (fdh) {
>  		pr_debug("Updating elfcore header (%llx) with cpu notes\n",
> diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
> index 270ee30..d322527 100644
> --- a/arch/powerpc/kernel/setup-common.c
> +++ b/arch/powerpc/kernel/setup-common.c
> @@ -116,6 +116,11 @@ int ppc_do_canonicalize_irqs;
>  EXPORT_SYMBOL(ppc_do_canonicalize_irqs);
>  #endif
>  
> +#if defined(CONFIG_KEXEC) || defined(CONFIG_FA_DUMP)
> +/* This keeps a track of which one is the crashing cpu. */
> +int crashing_cpu = -1;
> +#endif
> +
>  /* also used by kexec */
>  void machine_shutdown(void)
>  {
> diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
> new file mode 100644
> index 0000000..2ae20b1
> --- /dev/null
> +++ b/include/linux/crash_core.h
> @@ -0,0 +1,75 @@
> +#ifndef LINUX_CRASH_CORE_H
> +#define LINUX_CRASH_CORE_H
> +
> +#include <linux/linkage.h>
> +#include <linux/elfcore.h>
> +#include <linux/elf.h>
> +
> +#define CRASH_CORE_NOTE_NAME	   "CORE"
> +#define CRASH_CORE_NOTE_HEAD_BYTES ALIGN(sizeof(struct elf_note), 4)
> +#define CRASH_CORE_NOTE_NAME_BYTES ALIGN(sizeof(CRASH_CORE_NOTE_NAME), 4)
> +#define CRASH_CORE_NOTE_DESC_BYTES ALIGN(sizeof(struct elf_prstatus), 4)
> +
> +#define CRASH_CORE_NOTE_BYTES	   ((CRASH_CORE_NOTE_HEAD_BYTES * 2) +	\
> +				     CRASH_CORE_NOTE_NAME_BYTES +	\
> +				     CRASH_CORE_NOTE_DESC_BYTES)
> +
> +#define VMCOREINFO_BYTES	   (4096)
> +#define VMCOREINFO_NOTE_NAME	   "VMCOREINFO"
> +#define VMCOREINFO_NOTE_NAME_BYTES ALIGN(sizeof(VMCOREINFO_NOTE_NAME), 4)
> +#define VMCOREINFO_NOTE_SIZE	   ((CRASH_CORE_NOTE_HEAD_BYTES * 2) +	\
> +				     VMCOREINFO_NOTE_NAME_BYTES +	\
> +				     VMCOREINFO_BYTES)
> +
> +typedef u32 note_buf_t[CRASH_CORE_NOTE_BYTES/4];
> +
> +void crash_save_vmcoreinfo(void);
> +void arch_crash_save_vmcoreinfo(void);
> +__printf(1, 2)
> +void vmcoreinfo_append_str(const char *fmt, ...);
> +phys_addr_t paddr_vmcoreinfo_note(void);
> +
> +#define VMCOREINFO_OSRELEASE(value) \
> +	vmcoreinfo_append_str("OSRELEASE=%s\n", value)
> +#define VMCOREINFO_PAGESIZE(value) \
> +	vmcoreinfo_append_str("PAGESIZE=%ld\n", value)
> +#define VMCOREINFO_SYMBOL(name) \
> +	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)&name)
> +#define VMCOREINFO_SIZE(name) \
> +	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
> +			      (unsigned long)sizeof(name))
> +#define VMCOREINFO_STRUCT_SIZE(name) \
> +	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
> +			      (unsigned long)sizeof(struct name))
> +#define VMCOREINFO_OFFSET(name, field) \
> +	vmcoreinfo_append_str("OFFSET(%s.%s)=%lu\n", #name, #field, \
> +			      (unsigned long)offsetof(struct name, field))
> +#define VMCOREINFO_LENGTH(name, value) \
> +	vmcoreinfo_append_str("LENGTH(%s)=%lu\n", #name, (unsigned long)value)
> +#define VMCOREINFO_NUMBER(name) \
> +	vmcoreinfo_append_str("NUMBER(%s)=%ld\n", #name, (long)name)
> +#define VMCOREINFO_CONFIG(name) \
> +	vmcoreinfo_append_str("CONFIG_%s=y\n", #name)
> +#define VMCOREINFO_PAGE_OFFSET(value) \
> +	vmcoreinfo_append_str("PAGE_OFFSET=%lx\n", (unsigned long)value)
> +#define VMCOREINFO_VMALLOC_START(value) \
> +	vmcoreinfo_append_str("VMALLOC_START=%lx\n", (unsigned long)value)
> +#define VMCOREINFO_VMEMMAP_START(value) \
> +	vmcoreinfo_append_str("VMEMMAP_START=%lx\n", (unsigned long)value)
> +
> +extern u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
> +extern size_t vmcoreinfo_size;
> +extern size_t vmcoreinfo_max_size;
> +
> +u32 *append_elf_note(u32 *buf, char *name, unsigned int type,
> +		     void *data, size_t data_len);
> +void final_note(u32 *buf);
> +
> +int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
> +		unsigned long long *crash_size, unsigned long long *crash_base);
> +int parse_crashkernel_high(char *cmdline, unsigned long long system_ram,
> +		unsigned long long *crash_size, unsigned long long *crash_base);
> +int parse_crashkernel_low(char *cmdline, unsigned long long system_ram,
> +		unsigned long long *crash_size, unsigned long long *crash_base);
> +
> +#endif /* LINUX_CRASH_CORE_H */
> diff --git a/include/linux/kexec.h b/include/linux/kexec.h
> index 406c33d..aa3c747 100644
> --- a/include/linux/kexec.h
> +++ b/include/linux/kexec.h
> @@ -14,17 +14,15 @@
>  
>  #if !defined(__ASSEMBLY__)
>  
> +#include <linux/crash_core.h>
>  #include <asm/io.h>
>  
>  #include <uapi/linux/kexec.h>
>  
>  #ifdef CONFIG_KEXEC_CORE
>  #include <linux/list.h>
> -#include <linux/linkage.h>
>  #include <linux/compat.h>
>  #include <linux/ioport.h>
> -#include <linux/elfcore.h>
> -#include <linux/elf.h>
>  #include <linux/module.h>
>  #include <asm/kexec.h>
>  
> @@ -62,19 +60,15 @@
>  #define KEXEC_CRASH_MEM_ALIGN PAGE_SIZE
>  #endif
>  
> -#define KEXEC_NOTE_HEAD_BYTES ALIGN(sizeof(struct elf_note), 4)
> -#define KEXEC_CORE_NOTE_NAME "CORE"
> -#define KEXEC_CORE_NOTE_NAME_BYTES ALIGN(sizeof(KEXEC_CORE_NOTE_NAME), 4)
> -#define KEXEC_CORE_NOTE_DESC_BYTES ALIGN(sizeof(struct elf_prstatus), 4)
> +#define KEXEC_CORE_NOTE_NAME	CRASH_CORE_NOTE_NAME
> +
>  /*
>   * The per-cpu notes area is a list of notes terminated by a "NULL"
>   * note header.  For kdump, the code in vmcore.c runs in the context
>   * of the second kernel to combine them into one note.
>   */
>  #ifndef KEXEC_NOTE_BYTES
> -#define KEXEC_NOTE_BYTES ( (KEXEC_NOTE_HEAD_BYTES * 2) +		\
> -			    KEXEC_CORE_NOTE_NAME_BYTES +		\
> -			    KEXEC_CORE_NOTE_DESC_BYTES )
> +#define KEXEC_NOTE_BYTES	CRASH_CORE_NOTE_BYTES
>  #endif
>  
>  /*
> @@ -232,39 +226,6 @@ extern void crash_kexec(struct pt_regs *);
>  int kexec_should_crash(struct task_struct *);
>  int kexec_crash_loaded(void);
>  void crash_save_cpu(struct pt_regs *regs, int cpu);
> -void crash_save_vmcoreinfo(void);
> -void arch_crash_save_vmcoreinfo(void);
> -__printf(1, 2)
> -void vmcoreinfo_append_str(const char *fmt, ...);
> -phys_addr_t paddr_vmcoreinfo_note(void);
> -
> -#define VMCOREINFO_OSRELEASE(value) \
> -	vmcoreinfo_append_str("OSRELEASE=%s\n", value)
> -#define VMCOREINFO_PAGESIZE(value) \
> -	vmcoreinfo_append_str("PAGESIZE=%ld\n", value)
> -#define VMCOREINFO_SYMBOL(name) \
> -	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)&name)
> -#define VMCOREINFO_SIZE(name) \
> -	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
> -			      (unsigned long)sizeof(name))
> -#define VMCOREINFO_STRUCT_SIZE(name) \
> -	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
> -			      (unsigned long)sizeof(struct name))
> -#define VMCOREINFO_OFFSET(name, field) \
> -	vmcoreinfo_append_str("OFFSET(%s.%s)=%lu\n", #name, #field, \
> -			      (unsigned long)offsetof(struct name, field))
> -#define VMCOREINFO_LENGTH(name, value) \
> -	vmcoreinfo_append_str("LENGTH(%s)=%lu\n", #name, (unsigned long)value)
> -#define VMCOREINFO_NUMBER(name) \
> -	vmcoreinfo_append_str("NUMBER(%s)=%ld\n", #name, (long)name)
> -#define VMCOREINFO_CONFIG(name) \
> -	vmcoreinfo_append_str("CONFIG_%s=y\n", #name)
> -#define VMCOREINFO_PAGE_OFFSET(value) \
> -	vmcoreinfo_append_str("PAGE_OFFSET=%lx\n", (unsigned long)value)
> -#define VMCOREINFO_VMALLOC_START(value) \
> -	vmcoreinfo_append_str("VMALLOC_START=%lx\n", (unsigned long)value)
> -#define VMCOREINFO_VMEMMAP_START(value) \
> -	vmcoreinfo_append_str("VMEMMAP_START=%lx\n", (unsigned long)value)
>  
>  extern struct kimage *kexec_image;
>  extern struct kimage *kexec_crash_image;
> @@ -285,31 +246,15 @@ extern int kexec_load_disabled;
>  #define KEXEC_FILE_FLAGS	(KEXEC_FILE_UNLOAD | KEXEC_FILE_ON_CRASH | \
>  				 KEXEC_FILE_NO_INITRAMFS)
>  
> -#define VMCOREINFO_BYTES           (4096)
> -#define VMCOREINFO_NOTE_NAME       "VMCOREINFO"
> -#define VMCOREINFO_NOTE_NAME_BYTES ALIGN(sizeof(VMCOREINFO_NOTE_NAME), 4)
> -#define VMCOREINFO_NOTE_SIZE       (KEXEC_NOTE_HEAD_BYTES*2 + VMCOREINFO_BYTES \
> -				    + VMCOREINFO_NOTE_NAME_BYTES)
> -
>  /* Location of a reserved region to hold the crash kernel.
>   */
>  extern struct resource crashk_res;
>  extern struct resource crashk_low_res;
> -typedef u32 note_buf_t[KEXEC_NOTE_BYTES/4];
>  extern note_buf_t __percpu *crash_notes;
> -extern u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
> -extern size_t vmcoreinfo_size;
> -extern size_t vmcoreinfo_max_size;
>  
>  /* flag to track if kexec reboot is in progress */
>  extern bool kexec_in_progress;
>  
> -int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
> -		unsigned long long *crash_size, unsigned long long *crash_base);
> -int parse_crashkernel_high(char *cmdline, unsigned long long system_ram,
> -		unsigned long long *crash_size, unsigned long long *crash_base);
> -int parse_crashkernel_low(char *cmdline, unsigned long long system_ram,
> -		unsigned long long *crash_size, unsigned long long *crash_base);
>  int crash_shrink_memory(unsigned long new_size);
>  size_t crash_get_memory_size(void);
>  void crash_free_reserved_phys_range(unsigned long begin, unsigned long end);
> diff --git a/kernel/Makefile b/kernel/Makefile
> index eb26e12c..017e092 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -59,6 +59,7 @@ obj-$(CONFIG_MODULES) += module.o
>  obj-$(CONFIG_MODULE_SIG) += module_signing.o
>  obj-$(CONFIG_KALLSYMS) += kallsyms.o
>  obj-$(CONFIG_BSD_PROCESS_ACCT) += acct.o
> +obj-$(CONFIG_CRASH_CORE) += crash_core.o
>  obj-$(CONFIG_KEXEC_CORE) += kexec_core.o
>  obj-$(CONFIG_KEXEC) += kexec.o
>  obj-$(CONFIG_KEXEC_FILE) += kexec_file.o
> diff --git a/kernel/crash_core.c b/kernel/crash_core.c
> new file mode 100644
> index 0000000..9223976
> --- /dev/null
> +++ b/kernel/crash_core.c
> @@ -0,0 +1,450 @@
> +/*
> + * crash.c - kernel crash support code.
> + * Copyright (C) 2002-2004 Eric Biederman  <ebiederm@xmission.com>
> + *
> + * This source code is licensed under the GNU General Public License,
> + * Version 2.  See the file COPYING for more details.
> + */
> +
> +#include <linux/crash_core.h>
> +#include <linux/utsname.h>
> +#include <linux/vmalloc.h>
> +
> +#include <asm/page.h>
> +#include <asm/sections.h>
> +
> +/* vmcoreinfo stuff */
> +static unsigned char vmcoreinfo_data[VMCOREINFO_BYTES];
> +u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
> +size_t vmcoreinfo_size;
> +size_t vmcoreinfo_max_size = sizeof(vmcoreinfo_data);
> +
> +/*
> + * parsing the "crashkernel" commandline
> + *
> + * this code is intended to be called from architecture specific code
> + */
> +
> +
> +/*
> + * This function parses command lines in the format
> + *
> + *   crashkernel=ramsize-range:size[,...][@offset]
> + *
> + * The function returns 0 on success and -EINVAL on failure.
> + */
> +static int __init parse_crashkernel_mem(char *cmdline,
> +					unsigned long long system_ram,
> +					unsigned long long *crash_size,
> +					unsigned long long *crash_base)
> +{
> +	char *cur = cmdline, *tmp;
> +
> +	/* for each entry of the comma-separated list */
> +	do {
> +		unsigned long long start, end = ULLONG_MAX, size;
> +
> +		/* get the start of the range */
> +		start = memparse(cur, &tmp);
> +		if (cur = tmp) {
> +			pr_warn("crashkernel: Memory value expected\n");
> +			return -EINVAL;
> +		}
> +		cur = tmp;
> +		if (*cur != '-') {
> +			pr_warn("crashkernel: '-' expected\n");
> +			return -EINVAL;
> +		}
> +		cur++;
> +
> +		/* if no ':' is here, than we read the end */
> +		if (*cur != ':') {
> +			end = memparse(cur, &tmp);
> +			if (cur = tmp) {
> +				pr_warn("crashkernel: Memory value expected\n");
> +				return -EINVAL;
> +			}
> +			cur = tmp;
> +			if (end <= start) {
> +				pr_warn("crashkernel: end <= start\n");
> +				return -EINVAL;
> +			}
> +		}
> +
> +		if (*cur != ':') {
> +			pr_warn("crashkernel: ':' expected\n");
> +			return -EINVAL;
> +		}
> +		cur++;
> +
> +		size = memparse(cur, &tmp);
> +		if (cur = tmp) {
> +			pr_warn("Memory value expected\n");
> +			return -EINVAL;
> +		}
> +		cur = tmp;
> +		if (size >= system_ram) {
> +			pr_warn("crashkernel: invalid size\n");
> +			return -EINVAL;
> +		}
> +
> +		/* match ? */
> +		if (system_ram >= start && system_ram < end) {
> +			*crash_size = size;
> +			break;
> +		}
> +	} while (*cur++ = ',');
> +
> +	if (*crash_size > 0) {
> +		while (*cur && *cur != ' ' && *cur != '@')
> +			cur++;
> +		if (*cur = '@') {
> +			cur++;
> +			*crash_base = memparse(cur, &tmp);
> +			if (cur = tmp) {
> +				pr_warn("Memory value expected after '@'\n");
> +				return -EINVAL;
> +			}
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * That function parses "simple" (old) crashkernel command lines like
> + *
> + *	crashkernel=size[@offset]
> + *
> + * It returns 0 on success and -EINVAL on failure.
> + */
> +static int __init parse_crashkernel_simple(char *cmdline,
> +					   unsigned long long *crash_size,
> +					   unsigned long long *crash_base)
> +{
> +	char *cur = cmdline;
> +
> +	*crash_size = memparse(cmdline, &cur);
> +	if (cmdline = cur) {
> +		pr_warn("crashkernel: memory value expected\n");
> +		return -EINVAL;
> +	}
> +
> +	if (*cur = '@')
> +		*crash_base = memparse(cur+1, &cur);
> +	else if (*cur != ' ' && *cur != '\0') {
> +		pr_warn("crashkernel: unrecognized char: %c\n", *cur);
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +#define SUFFIX_HIGH 0
> +#define SUFFIX_LOW  1
> +#define SUFFIX_NULL 2
> +static __initdata char *suffix_tbl[] = {
> +	[SUFFIX_HIGH] = ",high",
> +	[SUFFIX_LOW]  = ",low",
> +	[SUFFIX_NULL] = NULL,
> +};
> +
> +/*
> + * That function parses "suffix"  crashkernel command lines like
> + *
> + *	crashkernel=size,[high|low]
> + *
> + * It returns 0 on success and -EINVAL on failure.
> + */
> +static int __init parse_crashkernel_suffix(char *cmdline,
> +					   unsigned long long	*crash_size,
> +					   const char *suffix)
> +{
> +	char *cur = cmdline;
> +
> +	*crash_size = memparse(cmdline, &cur);
> +	if (cmdline = cur) {
> +		pr_warn("crashkernel: memory value expected\n");
> +		return -EINVAL;
> +	}
> +
> +	/* check with suffix */
> +	if (strncmp(cur, suffix, strlen(suffix))) {
> +		pr_warn("crashkernel: unrecognized char: %c\n", *cur);
> +		return -EINVAL;
> +	}
> +	cur += strlen(suffix);
> +	if (*cur != ' ' && *cur != '\0') {
> +		pr_warn("crashkernel: unrecognized char: %c\n", *cur);
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +static __init char *get_last_crashkernel(char *cmdline,
> +			     const char *name,
> +			     const char *suffix)
> +{
> +	char *p = cmdline, *ck_cmdline = NULL;
> +
> +	/* find crashkernel and use the last one if there are more */
> +	p = strstr(p, name);
> +	while (p) {
> +		char *end_p = strchr(p, ' ');
> +		char *q;
> +
> +		if (!end_p)
> +			end_p = p + strlen(p);
> +
> +		if (!suffix) {
> +			int i;
> +
> +			/* skip the one with any known suffix */
> +			for (i = 0; suffix_tbl[i]; i++) {
> +				q = end_p - strlen(suffix_tbl[i]);
> +				if (!strncmp(q, suffix_tbl[i],
> +					     strlen(suffix_tbl[i])))
> +					goto next;
> +			}
> +			ck_cmdline = p;
> +		} else {
> +			q = end_p - strlen(suffix);
> +			if (!strncmp(q, suffix, strlen(suffix)))
> +				ck_cmdline = p;
> +		}
> +next:
> +		p = strstr(p+1, name);
> +	}
> +
> +	if (!ck_cmdline)
> +		return NULL;
> +
> +	return ck_cmdline;
> +}
> +
> +static int __init __parse_crashkernel(char *cmdline,
> +			     unsigned long long system_ram,
> +			     unsigned long long *crash_size,
> +			     unsigned long long *crash_base,
> +			     const char *name,
> +			     const char *suffix)
> +{
> +	char	*first_colon, *first_space;
> +	char	*ck_cmdline;
> +
> +	BUG_ON(!crash_size || !crash_base);
> +	*crash_size = 0;
> +	*crash_base = 0;
> +
> +	ck_cmdline = get_last_crashkernel(cmdline, name, suffix);
> +
> +	if (!ck_cmdline)
> +		return -EINVAL;
> +
> +	ck_cmdline += strlen(name);
> +
> +	if (suffix)
> +		return parse_crashkernel_suffix(ck_cmdline, crash_size,
> +				suffix);
> +	/*
> +	 * if the commandline contains a ':', then that's the extended
> +	 * syntax -- if not, it must be the classic syntax
> +	 */
> +	first_colon = strchr(ck_cmdline, ':');
> +	first_space = strchr(ck_cmdline, ' ');
> +	if (first_colon && (!first_space || first_colon < first_space))
> +		return parse_crashkernel_mem(ck_cmdline, system_ram,
> +				crash_size, crash_base);
> +
> +	return parse_crashkernel_simple(ck_cmdline, crash_size, crash_base);
> +}
> +
> +/*
> + * That function is the entry point for command line parsing and should be
> + * called from the arch-specific code.
> + */
> +int __init parse_crashkernel(char *cmdline,
> +			     unsigned long long system_ram,
> +			     unsigned long long *crash_size,
> +			     unsigned long long *crash_base)
> +{
> +	return __parse_crashkernel(cmdline, system_ram, crash_size, crash_base,
> +					"crashkernel=", NULL);
> +}
> +
> +int __init parse_crashkernel_high(char *cmdline,
> +			     unsigned long long system_ram,
> +			     unsigned long long *crash_size,
> +			     unsigned long long *crash_base)
> +{
> +	return __parse_crashkernel(cmdline, system_ram, crash_size, crash_base,
> +				"crashkernel=", suffix_tbl[SUFFIX_HIGH]);
> +}
> +
> +int __init parse_crashkernel_low(char *cmdline,
> +			     unsigned long long system_ram,
> +			     unsigned long long *crash_size,
> +			     unsigned long long *crash_base)
> +{
> +	return __parse_crashkernel(cmdline, system_ram, crash_size, crash_base,
> +				"crashkernel=", suffix_tbl[SUFFIX_LOW]);
> +}
> +
> +u32 *append_elf_note(u32 *buf, char *name, unsigned int type,
> +		     void *data, size_t data_len)
> +{
> +	struct elf_note note;
> +
> +	note.n_namesz = strlen(name) + 1;
> +	note.n_descsz = data_len;
> +	note.n_type   = type;
> +	memcpy(buf, &note, sizeof(note));
> +	buf += (sizeof(note) + 3)/4;
> +	memcpy(buf, name, note.n_namesz);
> +	buf += (note.n_namesz + 3)/4;
> +	memcpy(buf, data, note.n_descsz);
> +	buf += (note.n_descsz + 3)/4;
> +
> +	return buf;
> +}
> +
> +void final_note(u32 *buf)
> +{
> +	struct elf_note note;
> +
> +	note.n_namesz = 0;
> +	note.n_descsz = 0;
> +	note.n_type   = 0;
> +	memcpy(buf, &note, sizeof(note));
> +}
> +
> +static void update_vmcoreinfo_note(void)
> +{
> +	u32 *buf = vmcoreinfo_note;
> +
> +	if (!vmcoreinfo_size)
> +		return;
> +	buf = append_elf_note(buf, VMCOREINFO_NOTE_NAME, 0, vmcoreinfo_data,
> +			      vmcoreinfo_size);
> +	final_note(buf);
> +}
> +
> +void crash_save_vmcoreinfo(void)
> +{
> +	vmcoreinfo_append_str("CRASHTIME=%ld\n", get_seconds());
> +	update_vmcoreinfo_note();
> +}
> +
> +void vmcoreinfo_append_str(const char *fmt, ...)
> +{
> +	va_list args;
> +	char buf[0x50];
> +	size_t r;
> +
> +	va_start(args, fmt);
> +	r = vscnprintf(buf, sizeof(buf), fmt, args);
> +	va_end(args);
> +
> +	r = min(r, vmcoreinfo_max_size - vmcoreinfo_size);
> +
> +	memcpy(&vmcoreinfo_data[vmcoreinfo_size], buf, r);
> +
> +	vmcoreinfo_size += r;
> +}
> +
> +/*
> + * provide an empty default implementation here -- architecture
> + * code may override this
> + */
> +void __weak arch_crash_save_vmcoreinfo(void)
> +{}
> +
> +phys_addr_t __weak paddr_vmcoreinfo_note(void)
> +{
> +	return __pa((unsigned long)(char *)&vmcoreinfo_note);
> +}
> +
> +static int __init crash_save_vmcoreinfo_init(void)
> +{
> +	VMCOREINFO_OSRELEASE(init_uts_ns.name.release);
> +	VMCOREINFO_PAGESIZE(PAGE_SIZE);
> +
> +	VMCOREINFO_SYMBOL(init_uts_ns);
> +	VMCOREINFO_SYMBOL(node_online_map);
> +#ifdef CONFIG_MMU
> +	VMCOREINFO_SYMBOL(swapper_pg_dir);
> +#endif
> +	VMCOREINFO_SYMBOL(_stext);
> +	VMCOREINFO_SYMBOL(vmap_area_list);
> +
> +#ifndef CONFIG_NEED_MULTIPLE_NODES
> +	VMCOREINFO_SYMBOL(mem_map);
> +	VMCOREINFO_SYMBOL(contig_page_data);
> +#endif
> +#ifdef CONFIG_SPARSEMEM
> +	VMCOREINFO_SYMBOL(mem_section);
> +	VMCOREINFO_LENGTH(mem_section, NR_SECTION_ROOTS);
> +	VMCOREINFO_STRUCT_SIZE(mem_section);
> +	VMCOREINFO_OFFSET(mem_section, section_mem_map);
> +#endif
> +	VMCOREINFO_STRUCT_SIZE(page);
> +	VMCOREINFO_STRUCT_SIZE(pglist_data);
> +	VMCOREINFO_STRUCT_SIZE(zone);
> +	VMCOREINFO_STRUCT_SIZE(free_area);
> +	VMCOREINFO_STRUCT_SIZE(list_head);
> +	VMCOREINFO_SIZE(nodemask_t);
> +	VMCOREINFO_OFFSET(page, flags);
> +	VMCOREINFO_OFFSET(page, _refcount);
> +	VMCOREINFO_OFFSET(page, mapping);
> +	VMCOREINFO_OFFSET(page, lru);
> +	VMCOREINFO_OFFSET(page, _mapcount);
> +	VMCOREINFO_OFFSET(page, private);
> +	VMCOREINFO_OFFSET(page, compound_dtor);
> +	VMCOREINFO_OFFSET(page, compound_order);
> +	VMCOREINFO_OFFSET(page, compound_head);
> +	VMCOREINFO_OFFSET(pglist_data, node_zones);
> +	VMCOREINFO_OFFSET(pglist_data, nr_zones);
> +#ifdef CONFIG_FLAT_NODE_MEM_MAP
> +	VMCOREINFO_OFFSET(pglist_data, node_mem_map);
> +#endif
> +	VMCOREINFO_OFFSET(pglist_data, node_start_pfn);
> +	VMCOREINFO_OFFSET(pglist_data, node_spanned_pages);
> +	VMCOREINFO_OFFSET(pglist_data, node_id);
> +	VMCOREINFO_OFFSET(zone, free_area);
> +	VMCOREINFO_OFFSET(zone, vm_stat);
> +	VMCOREINFO_OFFSET(zone, spanned_pages);
> +	VMCOREINFO_OFFSET(free_area, free_list);
> +	VMCOREINFO_OFFSET(list_head, next);
> +	VMCOREINFO_OFFSET(list_head, prev);
> +	VMCOREINFO_OFFSET(vmap_area, va_start);
> +	VMCOREINFO_OFFSET(vmap_area, list);
> +	VMCOREINFO_LENGTH(zone.free_area, MAX_ORDER);
> +#ifdef CONFIG_KEXEC
> +	log_buf_kexec_setup();
> +#endif
> +	VMCOREINFO_LENGTH(free_area.free_list, MIGRATE_TYPES);
> +	VMCOREINFO_NUMBER(NR_FREE_PAGES);
> +	VMCOREINFO_NUMBER(PG_lru);
> +	VMCOREINFO_NUMBER(PG_private);
> +	VMCOREINFO_NUMBER(PG_swapcache);
> +	VMCOREINFO_NUMBER(PG_slab);
> +#ifdef CONFIG_MEMORY_FAILURE
> +	VMCOREINFO_NUMBER(PG_hwpoison);
> +#endif
> +	VMCOREINFO_NUMBER(PG_head_mask);
> +	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
> +#ifdef CONFIG_X86
> +	VMCOREINFO_NUMBER(KERNEL_IMAGE_SIZE);
> +#endif
> +#ifdef CONFIG_HUGETLB_PAGE
> +	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
> +#endif
> +
> +	arch_crash_save_vmcoreinfo();
> +	update_vmcoreinfo_note();
> +
> +	return 0;
> +}
> +
> +subsys_initcall(crash_save_vmcoreinfo_init);
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index 5616755..596cb32 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -51,12 +51,6 @@ DEFINE_MUTEX(kexec_mutex);
>  /* Per cpu memory for storing cpu states in case of system crash. */
>  note_buf_t __percpu *crash_notes;
>  
> -/* vmcoreinfo stuff */
> -static unsigned char vmcoreinfo_data[VMCOREINFO_BYTES];
> -u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
> -size_t vmcoreinfo_size;
> -size_t vmcoreinfo_max_size = sizeof(vmcoreinfo_data);
> -
>  /* Flag to indicate we are going to kexec a new kernel */
>  bool kexec_in_progress = false;
>  
> @@ -994,34 +988,6 @@ int crash_shrink_memory(unsigned long new_size)
>  	return ret;
>  }
>  
> -static u32 *append_elf_note(u32 *buf, char *name, unsigned type, void *data,
> -			    size_t data_len)
> -{
> -	struct elf_note note;
> -
> -	note.n_namesz = strlen(name) + 1;
> -	note.n_descsz = data_len;
> -	note.n_type   = type;
> -	memcpy(buf, &note, sizeof(note));
> -	buf += (sizeof(note) + 3)/4;
> -	memcpy(buf, name, note.n_namesz);
> -	buf += (note.n_namesz + 3)/4;
> -	memcpy(buf, data, note.n_descsz);
> -	buf += (note.n_descsz + 3)/4;
> -
> -	return buf;
> -}
> -
> -static void final_note(u32 *buf)
> -{
> -	struct elf_note note;
> -
> -	note.n_namesz = 0;
> -	note.n_descsz = 0;
> -	note.n_type   = 0;
> -	memcpy(buf, &note, sizeof(note));
> -}
> -
>  void crash_save_cpu(struct pt_regs *regs, int cpu)
>  {
>  	struct elf_prstatus prstatus;
> @@ -1081,407 +1047,6 @@ static int __init crash_notes_memory_init(void)
>  }
>  subsys_initcall(crash_notes_memory_init);
>  
> -
> -/*
> - * parsing the "crashkernel" commandline
> - *
> - * this code is intended to be called from architecture specific code
> - */
> -
> -
> -/*
> - * This function parses command lines in the format
> - *
> - *   crashkernel=ramsize-range:size[,...][@offset]
> - *
> - * The function returns 0 on success and -EINVAL on failure.
> - */
> -static int __init parse_crashkernel_mem(char *cmdline,
> -					unsigned long long system_ram,
> -					unsigned long long *crash_size,
> -					unsigned long long *crash_base)
> -{
> -	char *cur = cmdline, *tmp;
> -
> -	/* for each entry of the comma-separated list */
> -	do {
> -		unsigned long long start, end = ULLONG_MAX, size;
> -
> -		/* get the start of the range */
> -		start = memparse(cur, &tmp);
> -		if (cur = tmp) {
> -			pr_warn("crashkernel: Memory value expected\n");
> -			return -EINVAL;
> -		}
> -		cur = tmp;
> -		if (*cur != '-') {
> -			pr_warn("crashkernel: '-' expected\n");
> -			return -EINVAL;
> -		}
> -		cur++;
> -
> -		/* if no ':' is here, than we read the end */
> -		if (*cur != ':') {
> -			end = memparse(cur, &tmp);
> -			if (cur = tmp) {
> -				pr_warn("crashkernel: Memory value expected\n");
> -				return -EINVAL;
> -			}
> -			cur = tmp;
> -			if (end <= start) {
> -				pr_warn("crashkernel: end <= start\n");
> -				return -EINVAL;
> -			}
> -		}
> -
> -		if (*cur != ':') {
> -			pr_warn("crashkernel: ':' expected\n");
> -			return -EINVAL;
> -		}
> -		cur++;
> -
> -		size = memparse(cur, &tmp);
> -		if (cur = tmp) {
> -			pr_warn("Memory value expected\n");
> -			return -EINVAL;
> -		}
> -		cur = tmp;
> -		if (size >= system_ram) {
> -			pr_warn("crashkernel: invalid size\n");
> -			return -EINVAL;
> -		}
> -
> -		/* match ? */
> -		if (system_ram >= start && system_ram < end) {
> -			*crash_size = size;
> -			break;
> -		}
> -	} while (*cur++ = ',');
> -
> -	if (*crash_size > 0) {
> -		while (*cur && *cur != ' ' && *cur != '@')
> -			cur++;
> -		if (*cur = '@') {
> -			cur++;
> -			*crash_base = memparse(cur, &tmp);
> -			if (cur = tmp) {
> -				pr_warn("Memory value expected after '@'\n");
> -				return -EINVAL;
> -			}
> -		}
> -	}
> -
> -	return 0;
> -}
> -
> -/*
> - * That function parses "simple" (old) crashkernel command lines like
> - *
> - *	crashkernel=size[@offset]
> - *
> - * It returns 0 on success and -EINVAL on failure.
> - */
> -static int __init parse_crashkernel_simple(char *cmdline,
> -					   unsigned long long *crash_size,
> -					   unsigned long long *crash_base)
> -{
> -	char *cur = cmdline;
> -
> -	*crash_size = memparse(cmdline, &cur);
> -	if (cmdline = cur) {
> -		pr_warn("crashkernel: memory value expected\n");
> -		return -EINVAL;
> -	}
> -
> -	if (*cur = '@')
> -		*crash_base = memparse(cur+1, &cur);
> -	else if (*cur != ' ' && *cur != '\0') {
> -		pr_warn("crashkernel: unrecognized char: %c\n", *cur);
> -		return -EINVAL;
> -	}
> -
> -	return 0;
> -}
> -
> -#define SUFFIX_HIGH 0
> -#define SUFFIX_LOW  1
> -#define SUFFIX_NULL 2
> -static __initdata char *suffix_tbl[] = {
> -	[SUFFIX_HIGH] = ",high",
> -	[SUFFIX_LOW]  = ",low",
> -	[SUFFIX_NULL] = NULL,
> -};
> -
> -/*
> - * That function parses "suffix"  crashkernel command lines like
> - *
> - *	crashkernel=size,[high|low]
> - *
> - * It returns 0 on success and -EINVAL on failure.
> - */
> -static int __init parse_crashkernel_suffix(char *cmdline,
> -					   unsigned long long	*crash_size,
> -					   const char *suffix)
> -{
> -	char *cur = cmdline;
> -
> -	*crash_size = memparse(cmdline, &cur);
> -	if (cmdline = cur) {
> -		pr_warn("crashkernel: memory value expected\n");
> -		return -EINVAL;
> -	}
> -
> -	/* check with suffix */
> -	if (strncmp(cur, suffix, strlen(suffix))) {
> -		pr_warn("crashkernel: unrecognized char: %c\n", *cur);
> -		return -EINVAL;
> -	}
> -	cur += strlen(suffix);
> -	if (*cur != ' ' && *cur != '\0') {
> -		pr_warn("crashkernel: unrecognized char: %c\n", *cur);
> -		return -EINVAL;
> -	}
> -
> -	return 0;
> -}
> -
> -static __init char *get_last_crashkernel(char *cmdline,
> -			     const char *name,
> -			     const char *suffix)
> -{
> -	char *p = cmdline, *ck_cmdline = NULL;
> -
> -	/* find crashkernel and use the last one if there are more */
> -	p = strstr(p, name);
> -	while (p) {
> -		char *end_p = strchr(p, ' ');
> -		char *q;
> -
> -		if (!end_p)
> -			end_p = p + strlen(p);
> -
> -		if (!suffix) {
> -			int i;
> -
> -			/* skip the one with any known suffix */
> -			for (i = 0; suffix_tbl[i]; i++) {
> -				q = end_p - strlen(suffix_tbl[i]);
> -				if (!strncmp(q, suffix_tbl[i],
> -					     strlen(suffix_tbl[i])))
> -					goto next;
> -			}
> -			ck_cmdline = p;
> -		} else {
> -			q = end_p - strlen(suffix);
> -			if (!strncmp(q, suffix, strlen(suffix)))
> -				ck_cmdline = p;
> -		}
> -next:
> -		p = strstr(p+1, name);
> -	}
> -
> -	if (!ck_cmdline)
> -		return NULL;
> -
> -	return ck_cmdline;
> -}
> -
> -static int __init __parse_crashkernel(char *cmdline,
> -			     unsigned long long system_ram,
> -			     unsigned long long *crash_size,
> -			     unsigned long long *crash_base,
> -			     const char *name,
> -			     const char *suffix)
> -{
> -	char	*first_colon, *first_space;
> -	char	*ck_cmdline;
> -
> -	BUG_ON(!crash_size || !crash_base);
> -	*crash_size = 0;
> -	*crash_base = 0;
> -
> -	ck_cmdline = get_last_crashkernel(cmdline, name, suffix);
> -
> -	if (!ck_cmdline)
> -		return -EINVAL;
> -
> -	ck_cmdline += strlen(name);
> -
> -	if (suffix)
> -		return parse_crashkernel_suffix(ck_cmdline, crash_size,
> -				suffix);
> -	/*
> -	 * if the commandline contains a ':', then that's the extended
> -	 * syntax -- if not, it must be the classic syntax
> -	 */
> -	first_colon = strchr(ck_cmdline, ':');
> -	first_space = strchr(ck_cmdline, ' ');
> -	if (first_colon && (!first_space || first_colon < first_space))
> -		return parse_crashkernel_mem(ck_cmdline, system_ram,
> -				crash_size, crash_base);
> -
> -	return parse_crashkernel_simple(ck_cmdline, crash_size, crash_base);
> -}
> -
> -/*
> - * That function is the entry point for command line parsing and should be
> - * called from the arch-specific code.
> - */
> -int __init parse_crashkernel(char *cmdline,
> -			     unsigned long long system_ram,
> -			     unsigned long long *crash_size,
> -			     unsigned long long *crash_base)
> -{
> -	return __parse_crashkernel(cmdline, system_ram, crash_size, crash_base,
> -					"crashkernel=", NULL);
> -}
> -
> -int __init parse_crashkernel_high(char *cmdline,
> -			     unsigned long long system_ram,
> -			     unsigned long long *crash_size,
> -			     unsigned long long *crash_base)
> -{
> -	return __parse_crashkernel(cmdline, system_ram, crash_size, crash_base,
> -				"crashkernel=", suffix_tbl[SUFFIX_HIGH]);
> -}
> -
> -int __init parse_crashkernel_low(char *cmdline,
> -			     unsigned long long system_ram,
> -			     unsigned long long *crash_size,
> -			     unsigned long long *crash_base)
> -{
> -	return __parse_crashkernel(cmdline, system_ram, crash_size, crash_base,
> -				"crashkernel=", suffix_tbl[SUFFIX_LOW]);
> -}
> -
> -static void update_vmcoreinfo_note(void)
> -{
> -	u32 *buf = vmcoreinfo_note;
> -
> -	if (!vmcoreinfo_size)
> -		return;
> -	buf = append_elf_note(buf, VMCOREINFO_NOTE_NAME, 0, vmcoreinfo_data,
> -			      vmcoreinfo_size);
> -	final_note(buf);
> -}
> -
> -void crash_save_vmcoreinfo(void)
> -{
> -	vmcoreinfo_append_str("CRASHTIME=%ld\n", get_seconds());
> -	update_vmcoreinfo_note();
> -}
> -
> -void vmcoreinfo_append_str(const char *fmt, ...)
> -{
> -	va_list args;
> -	char buf[0x50];
> -	size_t r;
> -
> -	va_start(args, fmt);
> -	r = vscnprintf(buf, sizeof(buf), fmt, args);
> -	va_end(args);
> -
> -	r = min(r, vmcoreinfo_max_size - vmcoreinfo_size);
> -
> -	memcpy(&vmcoreinfo_data[vmcoreinfo_size], buf, r);
> -
> -	vmcoreinfo_size += r;
> -}
> -
> -/*
> - * provide an empty default implementation here -- architecture
> - * code may override this
> - */
> -void __weak arch_crash_save_vmcoreinfo(void)
> -{}
> -
> -phys_addr_t __weak paddr_vmcoreinfo_note(void)
> -{
> -	return __pa((unsigned long)(char *)&vmcoreinfo_note);
> -}
> -
> -static int __init crash_save_vmcoreinfo_init(void)
> -{
> -	VMCOREINFO_OSRELEASE(init_uts_ns.name.release);
> -	VMCOREINFO_PAGESIZE(PAGE_SIZE);
> -
> -	VMCOREINFO_SYMBOL(init_uts_ns);
> -	VMCOREINFO_SYMBOL(node_online_map);
> -#ifdef CONFIG_MMU
> -	VMCOREINFO_SYMBOL(swapper_pg_dir);
> -#endif
> -	VMCOREINFO_SYMBOL(_stext);
> -	VMCOREINFO_SYMBOL(vmap_area_list);
> -
> -#ifndef CONFIG_NEED_MULTIPLE_NODES
> -	VMCOREINFO_SYMBOL(mem_map);
> -	VMCOREINFO_SYMBOL(contig_page_data);
> -#endif
> -#ifdef CONFIG_SPARSEMEM
> -	VMCOREINFO_SYMBOL(mem_section);
> -	VMCOREINFO_LENGTH(mem_section, NR_SECTION_ROOTS);
> -	VMCOREINFO_STRUCT_SIZE(mem_section);
> -	VMCOREINFO_OFFSET(mem_section, section_mem_map);
> -#endif
> -	VMCOREINFO_STRUCT_SIZE(page);
> -	VMCOREINFO_STRUCT_SIZE(pglist_data);
> -	VMCOREINFO_STRUCT_SIZE(zone);
> -	VMCOREINFO_STRUCT_SIZE(free_area);
> -	VMCOREINFO_STRUCT_SIZE(list_head);
> -	VMCOREINFO_SIZE(nodemask_t);
> -	VMCOREINFO_OFFSET(page, flags);
> -	VMCOREINFO_OFFSET(page, _refcount);
> -	VMCOREINFO_OFFSET(page, mapping);
> -	VMCOREINFO_OFFSET(page, lru);
> -	VMCOREINFO_OFFSET(page, _mapcount);
> -	VMCOREINFO_OFFSET(page, private);
> -	VMCOREINFO_OFFSET(page, compound_dtor);
> -	VMCOREINFO_OFFSET(page, compound_order);
> -	VMCOREINFO_OFFSET(page, compound_head);
> -	VMCOREINFO_OFFSET(pglist_data, node_zones);
> -	VMCOREINFO_OFFSET(pglist_data, nr_zones);
> -#ifdef CONFIG_FLAT_NODE_MEM_MAP
> -	VMCOREINFO_OFFSET(pglist_data, node_mem_map);
> -#endif
> -	VMCOREINFO_OFFSET(pglist_data, node_start_pfn);
> -	VMCOREINFO_OFFSET(pglist_data, node_spanned_pages);
> -	VMCOREINFO_OFFSET(pglist_data, node_id);
> -	VMCOREINFO_OFFSET(zone, free_area);
> -	VMCOREINFO_OFFSET(zone, vm_stat);
> -	VMCOREINFO_OFFSET(zone, spanned_pages);
> -	VMCOREINFO_OFFSET(free_area, free_list);
> -	VMCOREINFO_OFFSET(list_head, next);
> -	VMCOREINFO_OFFSET(list_head, prev);
> -	VMCOREINFO_OFFSET(vmap_area, va_start);
> -	VMCOREINFO_OFFSET(vmap_area, list);
> -	VMCOREINFO_LENGTH(zone.free_area, MAX_ORDER);
> -	log_buf_kexec_setup();
> -	VMCOREINFO_LENGTH(free_area.free_list, MIGRATE_TYPES);
> -	VMCOREINFO_NUMBER(NR_FREE_PAGES);
> -	VMCOREINFO_NUMBER(PG_lru);
> -	VMCOREINFO_NUMBER(PG_private);
> -	VMCOREINFO_NUMBER(PG_swapcache);
> -	VMCOREINFO_NUMBER(PG_slab);
> -#ifdef CONFIG_MEMORY_FAILURE
> -	VMCOREINFO_NUMBER(PG_hwpoison);
> -#endif
> -	VMCOREINFO_NUMBER(PG_head_mask);
> -	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
> -#ifdef CONFIG_X86
> -	VMCOREINFO_NUMBER(KERNEL_IMAGE_SIZE);
> -#endif
> -#ifdef CONFIG_HUGETLB_PAGE
> -	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
> -#endif
> -
> -	arch_crash_save_vmcoreinfo();
> -	update_vmcoreinfo_note();
> -
> -	return 0;
> -}
> -
> -subsys_initcall(crash_save_vmcoreinfo_init);
> -
>  /*
>   * Move into place and start executing a preloaded standalone
>   * executable.  If nothing was preloaded return an error.
> 
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
