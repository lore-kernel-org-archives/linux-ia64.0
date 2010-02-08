From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Feb 2010 19:29:08 +0000
Subject: [PATCH] Remove COMPAT_IA32 support from ia64.
Message-Id: <4b706604317715a28@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This has been broken since May 2008 when Al Viro killed altroot support.
Since nobody has complained, it would appear that there are no users of
this code (A plausible theory since the main OSVs that support ia64 prefer
to use the IA32-EL software emulation).

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

xargs rm -f << 'EOF'
arch/ia64/ia32/Makefile
arch/ia64/ia32/audit.c
arch/ia64/ia32/binfmt_elf32.c
arch/ia64/ia32/elfcore32.h
arch/ia64/ia32/ia32_entry.S
arch/ia64/ia32/ia32_ldt.c
arch/ia64/ia32/ia32_signal.c
arch/ia64/ia32/ia32_support.c
arch/ia64/ia32/ia32_traps.c
arch/ia64/ia32/ia32priv.h
arch/ia64/ia32/sys_ia32.c
arch/ia64/include/asm/ia32.h
EOF

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 2d7f56a..9a50d7d 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -499,23 +499,6 @@ config ARCH_PROC_KCORE_TEXT
 	def_bool y
 	depends on PROC_KCORE
=20
-config IA32_SUPPORT
-	bool "Support for Linux/x86 binaries"
-	help
-	  IA-64 processors can execute IA-32 (X86) instructions.  By
-	  saying Y here, the kernel will include IA-32 system call
-	  emulation support which makes it possible to transparently
-	  run IA-32 Linux binaries on an IA-64 Linux system.
-	  If in doubt, say Y.
-
-config COMPAT
-	bool
-	depends on IA32_SUPPORT
-	default y
-
-config COMPAT_FOR_U64_ALIGNMENT
-	def_bool COMPAT
-
 config IA64_MCA_RECOVERY
 	tristate "MCA recovery from errors other than TLB."
=20
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 475e272..8ae0d26 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -46,7 +46,6 @@ head-y :=3D arch/ia64/kernel/head.o arch/ia64/kernel/init=
_task.o
=20
 libs-y				+=3D arch/ia64/lib/
 core-y				+=3D arch/ia64/kernel/ arch/ia64/mm/
-core-$(CONFIG_IA32_SUPPORT)	+=3D arch/ia64/ia32/
 core-$(CONFIG_IA64_DIG) 	+=3D arch/ia64/dig/
 core-$(CONFIG_IA64_DIG_VTD) 	+=3D arch/ia64/dig/
 core-$(CONFIG_IA64_GENERIC) 	+=3D arch/ia64/dig/
diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_=
defconfig
index ace4109..312b120 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -131,8 +131,6 @@ CONFIG_ARCH_DISCONTIGMEM_ENABLE=3Dy
 CONFIG_ARCH_FLATMEM_ENABLE=3Dy
 CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
 # CONFIG_VIRTUAL_MEM_MAP is not set
-CONFIG_IA32_SUPPORT=3Dy
-CONFIG_COMPAT=3Dy
 # CONFIG_IA64_MCA_RECOVERY is not set
 CONFIG_PERFMON=3Dy
 CONFIG_IA64_PALINFO=3Dy
diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generi=
c_defconfig
index 7564549..6a4cc50 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -205,8 +205,6 @@ CONFIG_VIRTUAL_MEM_MAP=3Dy
 CONFIG_HOLES_IN_ZONE=3Dy
 CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=3Dy
 CONFIG_HAVE_ARCH_NODEDATA_EXTENSION=3Dy
-CONFIG_IA32_SUPPORT=3Dy
-CONFIG_COMPAT=3Dy
 CONFIG_COMPAT_FOR_U64_ALIGNMENT=3Dy
 CONFIG_IA64_MCA_RECOVERY=3Dy
 CONFIG_PERFMON=3Dy
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gens=
parse_defconfig
index e86fbd3..2dc185b 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -139,8 +139,6 @@ CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
 CONFIG_ARCH_DISCONTIGMEM_DEFAULT=3Dy
 CONFIG_NUMA=3Dy
 CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=3Dy
-CONFIG_IA32_SUPPORT=3Dy
-CONFIG_COMPAT=3Dy
 CONFIG_IA64_MCA_RECOVERY=3Dy
 CONFIG_PERFMON=3Dy
 CONFIG_IA64_PALINFO=3Dy
diff --git a/arch/ia64/configs/sim_defconfig b/arch/ia64/configs/sim_defcon=
fig
index 546a772..21a23cd 100644
--- a/arch/ia64/configs/sim_defconfig
+++ b/arch/ia64/configs/sim_defconfig
@@ -130,8 +130,6 @@ CONFIG_ARCH_DISCONTIGMEM_ENABLE=3Dy
 CONFIG_ARCH_FLATMEM_ENABLE=3Dy
 CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
 # CONFIG_VIRTUAL_MEM_MAP is not set
-CONFIG_IA32_SUPPORT=3Dy
-CONFIG_COMPAT=3Dy
 # CONFIG_IA64_MCA_RECOVERY is not set
 # CONFIG_PERFMON is not set
 CONFIG_IA64_PALINFO=3Dm
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_de=
fconfig
index c522edf..c5a5ea9 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -154,7 +154,6 @@ CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
 CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
 CONFIG_VIRTUAL_MEM_MAP=3Dy
 CONFIG_HOLES_IN_ZONE=3Dy
-# CONFIG_IA32_SUPPORT is not set
 CONFIG_IA64_MCA_RECOVERY=3Dy
 CONFIG_PERFMON=3Dy
 CONFIG_IA64_PALINFO=3Dy
diff --git a/arch/ia64/configs/xen_domu_defconfig b/arch/ia64/configs/xen_d=
omu_defconfig
index 0bb0714..c67eafc 100644
--- a/arch/ia64/configs/xen_domu_defconfig
+++ b/arch/ia64/configs/xen_domu_defconfig
@@ -200,8 +200,6 @@ CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
 CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
 CONFIG_VIRTUAL_MEM_MAP=3Dy
 CONFIG_HOLES_IN_ZONE=3Dy
-# CONFIG_IA32_SUPPORT is not set
-# CONFIG_COMPAT_FOR_U64_ALIGNMENT is not set
 CONFIG_IA64_MCA_RECOVERY=3Dy
 CONFIG_PERFMON=3Dy
 CONFIG_IA64_PALINFO=3Dy
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defcon=
fig
index 514f063..3cec65b 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -150,8 +150,6 @@ CONFIG_ARCH_DISCONTIGMEM_DEFAULT=3Dy
 CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
 CONFIG_VIRTUAL_MEM_MAP=3Dy
 CONFIG_HOLES_IN_ZONE=3Dy
-CONFIG_IA32_SUPPORT=3Dy
-CONFIG_COMPAT=3Dy
 CONFIG_IA64_MCA_RECOVERY=3Dy
 CONFIG_PERFMON=3Dy
 CONFIG_IA64_PALINFO=3Dy
diff --git a/arch/ia64/include/asm/processor.h b/arch/ia64/include/asm/proc=
essor.h
index 7fa90f7..348e44d 100644
--- a/arch/ia64/include/asm/processor.h
+++ b/arch/ia64/include/asm/processor.h
@@ -270,23 +270,6 @@ typedef struct {
 		 (int __user *) (addr));							\
 })
=20
-#ifdef CONFIG_IA32_SUPPORT
-struct desc_struct {
-	unsigned int a, b;
-};
-
-#define desc_empty(desc)		(!((desc)->a | (desc)->b))
-#define desc_equal(desc1, desc2)	(((desc1)->a =3D (desc2)->a) && ((desc1)-=
>b =3D (desc2)->b))
-
-#define GDT_ENTRY_TLS_ENTRIES	3
-#define GDT_ENTRY_TLS_MIN	6
-#define GDT_ENTRY_TLS_MAX 	(GDT_ENTRY_TLS_MIN + GDT_ENTRY_TLS_ENTRIES - 1)
-
-#define TLS_SIZE (GDT_ENTRY_TLS_ENTRIES * 8)
-
-struct ia64_partial_page_list;
-#endif
-
 struct thread_struct {
 	__u32 flags;			/* various thread flags (see IA64_THREAD_*) */
 	/* writing on_ustack is performance-critical, so it's worth spending 8 bi=
ts on it... */
@@ -298,29 +281,6 @@ struct thread_struct {
 	__u64 rbs_bot;			/* the base address for the RBS */
 	int last_fph_cpu;		/* CPU that may hold the contents of f32-f127 */
=20
-#ifdef CONFIG_IA32_SUPPORT
-	__u64 eflag;			/* IA32 EFLAGS reg */
-	__u64 fsr;			/* IA32 floating pt status reg */
-	__u64 fcr;			/* IA32 floating pt control reg */
-	__u64 fir;			/* IA32 fp except. instr. reg */
-	__u64 fdr;			/* IA32 fp except. data reg */
-	__u64 old_k1;			/* old value of ar.k1 */
-	__u64 old_iob;			/* old IOBase value */
-	struct ia64_partial_page_list *ppl; /* partial page list for 4K page size=
 issue */
-        /* cached TLS descriptors. */
-	struct desc_struct tls_array[GDT_ENTRY_TLS_ENTRIES];
-
-# define INIT_THREAD_IA32	.eflag =3D	0,			\
-				.fsr =3D		0,			\
-				.fcr =3D		0x17800000037fULL,	\
-				.fir =3D		0,			\
-				.fdr =3D		0,			\
-				.old_k1 =3D	0,			\
-				.old_iob =3D	0,			\
-				.ppl =3D		NULL,
-#else
-# define INIT_THREAD_IA32
-#endif /* CONFIG_IA32_SUPPORT */
 #ifdef CONFIG_PERFMON
 	void *pfm_context;		     /* pointer to detailed PMU context */
 	unsigned long pfm_needs_checking;    /* when >0, pending perfmon work on =
kernel exit */
@@ -342,7 +302,6 @@ struct thread_struct {
 	.rbs_bot =3D	STACK_TOP - DEFAULT_USER_STACK_SIZE,	\
 	.task_size =3D	DEFAULT_TASK_SIZE,			\
 	.last_fph_cpu =3D  -1,					\
-	INIT_THREAD_IA32					\
 	INIT_THREAD_PM						\
 	.dbr =3D		{0, },					\
 	.ibr =3D		{0, },					\
@@ -485,11 +444,6 @@ extern void __ia64_load_fpu (struct ia64_fpreg *fph);
 extern void ia64_save_debug_regs (unsigned long *save_area);
 extern void ia64_load_debug_regs (unsigned long *save_area);
=20
-#ifdef CONFIG_IA32_SUPPORT
-extern void ia32_save_state (struct task_struct *task);
-extern void ia32_load_state (struct task_struct *task);
-#endif
-
 #define ia64_fph_enable()	do { ia64_rsm(IA64_PSR_DFH); ia64_srlz_d(); } wh=
ile (0)
 #define ia64_fph_disable()	do { ia64_ssm(IA64_PSR_DFH); ia64_srlz_d(); } w=
hile (0)
=20
diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscal=
l.h
index 2f758a4..a7ff1c6 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -22,33 +22,18 @@ static inline long syscall_get_nr(struct task_struct *t=
ask,
 	if ((long)regs->cr_ifs < 0) /* Not a syscall */
 		return -1;
=20
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(regs))
-		return regs->r1;
-#endif
-
 	return regs->r15;
 }
=20
 static inline void syscall_rollback(struct task_struct *task,
 				    struct pt_regs *regs)
 {
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(regs))
-		regs->r8 =3D regs->r1;
-#endif
-
 	/* do nothing */
 }
=20
 static inline long syscall_get_error(struct task_struct *task,
 				     struct pt_regs *regs)
 {
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(regs))
-		return regs->r8;
-#endif
-
 	return regs->r10 =3D -1 ? regs->r8:0;
 }
=20
@@ -62,13 +47,6 @@ static inline void syscall_set_return_value(struct task_=
struct *task,
 					    struct pt_regs *regs,
 					    int error, long val)
 {
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(regs)) {
-		regs->r8 =3D (long) error ? error : val;
-		return;
-	}
-#endif
-
 	if (error) {
 		/* error < 0, but ia64 uses > 0 return value */
 		regs->r8 =3D -error;
@@ -89,37 +67,6 @@ static inline void syscall_get_arguments(struct task_str=
uct *task,
 {
 	BUG_ON(i + n > 6);
=20
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(regs)) {
-		switch (i + n) {
-		case 6:
-			if (!n--) break;
-			*args++ =3D regs->r13;
-		case 5:
-			if (!n--) break;
-			*args++ =3D regs->r15;
-		case 4:
-			if (!n--) break;
-			*args++ =3D regs->r14;
-		case 3:
-			if (!n--) break;
-			*args++ =3D regs->r10;
-		case 2:
-			if (!n--) break;
-			*args++ =3D regs->r9;
-		case 1:
-			if (!n--) break;
-			*args++ =3D regs->r11;
-		case 0:
-			if (!n--) break;
-		default:
-			BUG();
-			break;
-		}
-
-		return;
-	}
-#endif
 	ia64_syscall_get_set_arguments(task, regs, i, n, args, 0);
 }
=20
@@ -130,34 +77,6 @@ static inline void syscall_set_arguments(struct task_st=
ruct *task,
 {
 	BUG_ON(i + n > 6);
=20
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(regs)) {
-		switch (i + n) {
-		case 6:
-			if (!n--) break;
-			regs->r13 =3D *args++;
-		case 5:
-			if (!n--) break;
-			regs->r15 =3D *args++;
-		case 4:
-			if (!n--) break;
-			regs->r14 =3D *args++;
-		case 3:
-			if (!n--) break;
-			regs->r10 =3D *args++;
-		case 2:
-			if (!n--) break;
-			regs->r9 =3D *args++;
-		case 1:
-			if (!n--) break;
-			regs->r11 =3D *args++;
-		case 0:
-			if (!n--) break;
-		}
-
-		return;
-	}
-#endif
 	ia64_syscall_get_set_arguments(task, regs, i, n, args, 1);
 }
 #endif	/* _ASM_SYSCALL_H */
diff --git a/arch/ia64/include/asm/system.h b/arch/ia64/include/asm/system.h
index 927a381..9f342a5 100644
--- a/arch/ia64/include/asm/system.h
+++ b/arch/ia64/include/asm/system.h
@@ -191,15 +191,6 @@ do {								\
=20
 #ifdef __KERNEL__
=20
-#ifdef CONFIG_IA32_SUPPORT
-# define IS_IA32_PROCESS(regs)	(ia64_psr(regs)->is !=3D 0)
-#else
-# define IS_IA32_PROCESS(regs)		0
-struct task_struct;
-static inline void ia32_save_state(struct task_struct *t __attribute__((un=
used))){}
-static inline void ia32_load_state(struct task_struct *t __attribute__((un=
used))){}
-#endif
-
 /*
  * Context switch from one thread to another.  If the two threads have
  * different address spaces, schedule() has already taken care of
@@ -233,7 +224,7 @@ extern void ia64_account_on_switch (struct task_struct =
*prev, struct task_struct
=20
 #define IA64_HAS_EXTRA_STATE(t)							\
 	((t)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID)	\
-	 || IS_IA32_PROCESS(task_pt_regs(t)) || PERFMON_IS_SYSWIDE())
+	 || PERFMON_IS_SYSWIDE())
=20
 #define __switch_to(prev,next,last) do {							 \
 	IA64_ACCOUNT_ON_SWITCH(prev, next);							 \
diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 10a8f21..bb8b0ff 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -335,20 +335,6 @@
 #define __ARCH_WANT_SYS_RT_SIGACTION
 #define __ARCH_WANT_SYS_RT_SIGSUSPEND
=20
-#ifdef CONFIG_IA32_SUPPORT
-# define __ARCH_WANT_SYS_FADVISE64
-# define __ARCH_WANT_SYS_GETPGRP
-# define __ARCH_WANT_SYS_LLSEEK
-# define __ARCH_WANT_SYS_NICE
-# define __ARCH_WANT_SYS_OLD_GETRLIMIT
-# define __ARCH_WANT_SYS_OLDUMOUNT
-# define __ARCH_WANT_SYS_PAUSE
-# define __ARCH_WANT_SYS_SIGPENDING
-# define __ARCH_WANT_SYS_SIGPROCMASK
-# define __ARCH_WANT_COMPAT_SYS_RT_SIGSUSPEND
-# define __ARCH_WANT_COMPAT_SYS_TIME
-#endif
-
 #if !defined(__ASSEMBLY__) && !defined(ASSEMBLER)
=20
 #include <linux/types.h>
diff --git a/arch/ia64/kernel/audit.c b/arch/ia64/kernel/audit.c
index f3802ae..96a9d18 100644
--- a/arch/ia64/kernel/audit.c
+++ b/arch/ia64/kernel/audit.c
@@ -30,20 +30,11 @@ static unsigned signal_class[] =3D {
=20
 int audit_classify_arch(int arch)
 {
-#ifdef CONFIG_IA32_SUPPORT
-	if (arch =3D AUDIT_ARCH_I386)
-		return 1;
-#endif
 	return 0;
 }
=20
 int audit_classify_syscall(int abi, unsigned syscall)
 {
-#ifdef CONFIG_IA32_SUPPORT
-	extern int ia32_classify_syscall(unsigned);
-	if (abi =3D AUDIT_ARCH_I386)
-		return ia32_classify_syscall(syscall);
-#endif
 	switch(syscall) {
 	case __NR_open:
 		return 2;
@@ -58,18 +49,6 @@ int audit_classify_syscall(int abi, unsigned syscall)
=20
 static int __init audit_classes_init(void)
 {
-#ifdef CONFIG_IA32_SUPPORT
-	extern __u32 ia32_dir_class[];
-	extern __u32 ia32_write_class[];
-	extern __u32 ia32_read_class[];
-	extern __u32 ia32_chattr_class[];
-	extern __u32 ia32_signal_class[];
-	audit_register_class(AUDIT_CLASS_WRITE_32, ia32_write_class);
-	audit_register_class(AUDIT_CLASS_READ_32, ia32_read_class);
-	audit_register_class(AUDIT_CLASS_DIR_WRITE_32, ia32_dir_class);
-	audit_register_class(AUDIT_CLASS_CHATTR_32, ia32_chattr_class);
-	audit_register_class(AUDIT_CLASS_SIGNAL_32, ia32_signal_class);
-#endif
 	audit_register_class(AUDIT_CLASS_WRITE, write_class);
 	audit_register_class(AUDIT_CLASS_READ, read_class);
 	audit_register_class(AUDIT_CLASS_DIR_WRITE, dir_class);
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index d75b872..9a260b3 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -71,15 +71,6 @@ ENTRY(ia64_execve)
 	add out3=16,sp			// regs
 	br.call.sptk.many rp=3Dsys_execve
 .ret0:
-#ifdef CONFIG_IA32_SUPPORT
-	/*
-	 * Check if we're returning to ia32 mode. If so, we need to restore ia32 =
registers
-	 * from pt_regs.
-	 */
-	adds r16=3DPT(CR_IPSR)+16,sp
-	;;
-	ld8 r16=3D[r16]
-#endif
 	cmp4.ge p6,p7=3Dr8,r0
 	mov ar.pfs=3Dloc1			// restore ar.pfs
 	sxt4 r8=3Dr8			// return 64-bit result
@@ -108,12 +99,6 @@ ENTRY(ia64_execve)
 	ldf.fill f23=3D[sp];	ldf.fill f24=3D[sp];	mov f25=F0
 	ldf.fill f26=3D[sp];	ldf.fill f27=3D[sp];	mov f28=F0
 	ldf.fill f29=3D[sp];	ldf.fill f30=3D[sp];	mov f31=F0
-#ifdef CONFIG_IA32_SUPPORT
-	tbit.nz p6,p0=3Dr16, IA64_PSR_IS_BIT
-	movl loc0=3Dia64_ret_from_ia32_execve
-	;;
-(p6)	mov rp=3Dloc0
-#endif
 	br.ret.sptk.many rp
 END(ia64_execve)
=20
@@ -848,30 +833,6 @@ __paravirt_work_processed_syscall:
 	br.cond.sptk.many rbs_switch	// B
 END(__paravirt_leave_syscall)
=20
-#ifdef __IA64_ASM_PARAVIRTUALIZED_NATIVE
-#ifdef CONFIG_IA32_SUPPORT
-GLOBAL_ENTRY(ia64_ret_from_ia32_execve)
-	PT_REGS_UNWIND_INFO(0)
-	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
-	adds r3=3DPT(R10)+16,sp			// r3 =3D &pt_regs.r10
-	;;
-	.mem.offset 0,0
-	st8.spill [r2]=3Dr8	// store return value in slot for r8 and set unat bit
-	.mem.offset 8,0
-	st8.spill [r3]=3Dr0	// clear error indication in slot for r10 and set una=
t bit
-#ifdef CONFIG_PARAVIRT
-	;;
-	// don't fall through, ia64_leave_kernel may be #define'd
-	br.cond.sptk.few ia64_leave_kernel
-	;;
-#endif /* CONFIG_PARAVIRT */
-END(ia64_ret_from_ia32_execve)
-#ifndef CONFIG_PARAVIRT
-	// fall through
-#endif
-#endif /* CONFIG_IA32_SUPPORT */
-#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
-
 GLOBAL_ENTRY(__paravirt_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 	/*
diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index ec9a5fd..179fd12 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -49,7 +49,6 @@
=20
 #include <asm/asmmacro.h>
 #include <asm/break.h>
-#include <asm/ia32.h>
 #include <asm/kregs.h>
 #include <asm/asm-offsets.h>
 #include <asm/pgtable.h>
@@ -1386,28 +1385,6 @@ END(ia32_exception)
 // 0x6a00 Entry 46 (size 16 bundles) IA-32 Intercept  (30,31,59,70,71)
 ENTRY(ia32_intercept)
 	DBG_FAULT(46)
-#ifdef	CONFIG_IA32_SUPPORT
-	mov r31=3Dpr
-	MOV_FROM_ISR(r16)
-	;;
-	extr.u r17=3Dr16,16,8	// get ISR.code
-	mov r18=3Dar.eflag
-	MOV_FROM_IIM(r19)	// old eflag value
-	;;
-	cmp.ne p6,p0=3D2,r17
-(p6)	br.cond.spnt 1f		// not a system flag fault
-	xor r16=3Dr18,r19
-	;;
-	extr.u r17=3Dr16,18,1	// get the eflags.ac bit
-	;;
-	cmp.eq p6,p0=3D0,r17
-(p6)	br.cond.spnt 1f		// eflags.ac bit didn't change
-	;;
-	mov pr=3Dr31,-1		// restore predicate registers
-	RFI
-
-1:
-#endif	// CONFIG_IA32_SUPPORT
 	FAULT(46)
 END(ia32_intercept)
=20
@@ -1416,12 +1393,7 @@ END(ia32_intercept)
 // 0x6b00 Entry 47 (size 16 bundles) IA-32 Interrupt  (74)
 ENTRY(ia32_interrupt)
 	DBG_FAULT(47)
-#ifdef CONFIG_IA32_SUPPORT
-	mov r31=3Dpr
-	br.sptk.many dispatch_to_ia32_handler
-#else
 	FAULT(47)
-#endif
 END(ia32_interrupt)
=20
 	.org ia64_ivt+0x6c00
@@ -1715,89 +1687,3 @@ ENTRY(dispatch_illegal_op_fault)
 (p6)	br.call.dpnt.many b6=B6		// call returns to ia64_leave_kernel
 	br.sptk.many ia64_leave_kernel
 END(dispatch_illegal_op_fault)
-
-#ifdef CONFIG_IA32_SUPPORT
-
-	/*
-	 * There is no particular reason for this code to be here, other than that
-	 * there happens to be space here that would go unused otherwise.  If this
-	 * fault ever gets "unreserved", simply moved the following code to a more
-	 * suitable spot...
-	 */
-
-	// IA32 interrupt entry point
-
-ENTRY(dispatch_to_ia32_handler)
-	SAVE_MIN
-	;;
-	MOV_FROM_ISR(r14)
-	SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(r3, r24)
-				// guarantee that interruption collection is on
-	;;
-	SSM_PSR_I(p15, p15, r3)
-	adds r3=3D8,r2		// Base pointer for SAVE_REST
-	;;
-	SAVE_REST
-	;;
-	mov r15=3D0x80
-	shr r14=3Dr14,16		// Get interrupt number
-	;;
-	cmp.ne p6,p0=3Dr14,r15
-(p6)	br.call.dpnt.many b6=3Dnon_ia32_syscall
-
-	adds r14=3DIA64_PT_REGS_R8_OFFSET + 16,sp	// 16 byte hole per SW conventi=
ons
-	adds r15=3DIA64_PT_REGS_R1_OFFSET + 16,sp
-	;;
-	cmp.eq pSys,pNonSys=3Dr0,r0 // set pSys=3D1, pNonSys=3D0
-	ld8 r8=3D[r14]		// get r8
-	;;
-	st8 [r15]=3Dr8		// save original EAX in r1 (IA32 procs don't use the GP)
-	;;
-	alloc r15=3Dar.pfs,0,0,6,0	// must first in an insn group
-	;;
-	ld4 r8=3D[r14],8		// r8 =3D eax (syscall number)
-	mov r15=3DIA32_NR_syscalls
-	;;
-	cmp.ltu.unc p6,p7=3Dr8,r15
-	ld4 out1=3D[r14],8	// r9 =3D ecx
-	;;
-	ld4 out2=3D[r14],8	// r10 =3D edx
-	;;
-	ld4 out0=3D[r14]		// r11 =3D ebx
-	adds r14=3D(IA64_PT_REGS_R13_OFFSET) + 16,sp
-	;;
-	ld4 out5=3D[r14],PT(R14)-PT(R13)	// r13 =3D ebp
-	;;
-	ld4 out3=3D[r14],PT(R15)-PT(R14)	// r14 =3D esi
-	adds r2=3DTI_FLAGS+IA64_TASK_SIZE,r13
-	;;
-	ld4 out4=3D[r14]		// r15 =3D edi
-	movl r16=3Dia32_syscall_table
-	;;
-(p6)	shladd r16=3Dr8,3,r16	// force ni_syscall if not valid syscall number
-	ld4 r2=3D[r2]		// r2 =3D current_thread_info()->flags
-	;;
-	ld8 r16=3D[r16]
-	and r2=3D_TIF_SYSCALL_TRACEAUDIT,r2	// mask trace or audit
-	;;
-	mov b6=3Dr16
-	movl r15=3Dia32_ret_from_syscall
-	cmp.eq p8,p0=3Dr2,r0
-	;;
-	mov rp=3Dr15
-(p8)	br.call.sptk.many b6=B6
-	br.cond.sptk ia32_trace_syscall
-
-non_ia32_syscall:
-	alloc r15=3Dar.pfs,0,0,2,0
-	mov out0=3Dr14				// interrupt #
-	add out1=16,sp				// pointer to pt_regs
-	;;			// avoid WAW on CFM
-	br.call.sptk.many rp=3Dia32_bad_interrupt
-.ret1:	movl r15=3Dia64_leave_kernel
-	;;
-	mov rp=3Dr15
-	br.ret.sptk.many rp
-END(dispatch_to_ia32_handler)
-
-#endif /* CONFIG_IA32_SUPPORT */
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 9bcec99..883ecc9 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -33,7 +33,6 @@
 #include <asm/cpu.h>
 #include <asm/delay.h>
 #include <asm/elf.h>
-#include <asm/ia32.h>
 #include <asm/irq.h>
 #include <asm/kexec.h>
 #include <asm/pgalloc.h>
@@ -358,11 +357,6 @@ ia64_save_extra (struct task_struct *task)
 	if (info & PFM_CPUINFO_SYST_WIDE)
 		pfm_syst_wide_update_task(task, info, 0);
 #endif
-
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(task_pt_regs(task)))
-		ia32_save_state(task);
-#endif
 }
=20
 void
@@ -383,11 +377,6 @@ ia64_load_extra (struct task_struct *task)
 	if (info & PFM_CPUINFO_SYST_WIDE)=20
 		pfm_syst_wide_update_task(task, info, 1);
 #endif
-
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(task_pt_regs(task)))
-		ia32_load_state(task);
-#endif
 }
=20
 /*
@@ -426,7 +415,7 @@ copy_thread(unsigned long clone_flags,
 	     unsigned long user_stack_base, unsigned long user_stack_size,
 	     struct task_struct *p, struct pt_regs *regs)
 {
-	extern char ia64_ret_from_clone, ia32_ret_from_clone;
+	extern char ia64_ret_from_clone;
 	struct switch_stack *child_stack, *stack;
 	unsigned long rbs, child_rbs, rbs_size;
 	struct pt_regs *child_ptregs;
@@ -457,7 +446,7 @@ copy_thread(unsigned long clone_flags,
 	memcpy((void *) child_rbs, (void *) rbs, rbs_size);
=20
 	if (likely(user_mode(child_ptregs))) {
-		if ((clone_flags & CLONE_SETTLS) && !IS_IA32_PROCESS(regs))
+		if (clone_flags & CLONE_SETTLS)
 			child_ptregs->r13 =3D regs->r16;	/* see sys_clone2() in entry.S */
 		if (user_stack_base) {
 			child_ptregs->r12 =3D user_stack_base + user_stack_size - 16;
@@ -477,10 +466,7 @@ copy_thread(unsigned long clone_flags,
 		child_ptregs->r13 =3D (unsigned long) p;		/* set `current' pointer */
 	}
 	child_stack->ar_bspstore =3D child_rbs + rbs_size;
-	if (IS_IA32_PROCESS(regs))
-		child_stack->b0 =3D (unsigned long) &ia32_ret_from_clone;
-	else
-		child_stack->b0 =3D (unsigned long) &ia64_ret_from_clone;
+	child_stack->b0 =3D (unsigned long) &ia64_ret_from_clone;
=20
 	/* copy parts of thread_struct: */
 	p->thread.ksp =3D (unsigned long) child_stack - 16;
@@ -515,22 +501,6 @@ copy_thread(unsigned long clone_flags,
 	p->thread.flags =3D ((current->thread.flags & ~THREAD_FLAGS_TO_CLEAR)
 			   | THREAD_FLAGS_TO_SET);
 	ia64_drop_fpu(p);	/* don't pick up stale state from a CPU's fph */
-#ifdef CONFIG_IA32_SUPPORT
-	/*
-	 * If we're cloning an IA32 task then save the IA32 extra
-	 * state from the current task to the new task
-	 */
-	if (IS_IA32_PROCESS(task_pt_regs(current))) {
-		ia32_save_state(p);
-		if (clone_flags & CLONE_SETTLS)
-			retval =3D ia32_clone_tls(p, child_ptregs);
-
-		/* Copy partially mapped page list */
-		if (!retval)
-			retval =3D ia32_copy_ia64_partial_page_list(p,
-								clone_flags);
-	}
-#endif
=20
 #ifdef CONFIG_PERFMON
 	if (current->thread.pfm_context)
@@ -704,15 +674,6 @@ EXPORT_SYMBOL(kernel_thread);
 int
 kernel_thread_helper (int (*fn)(void *), void *arg)
 {
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(task_pt_regs(current))) {
-		/* A kernel thread is always a 64-bit process. */
-		current->thread.map_base  =3D DEFAULT_MAP_BASE;
-		current->thread.task_size =3D DEFAULT_TASK_SIZE;
-		ia64_set_kr(IA64_KR_IO_BASE, current->thread.old_iob);
-		ia64_set_kr(IA64_KR_TSSD, current->thread.old_k1);
-	}
-#endif
 	return (*fn)(arg);
 }
=20
@@ -725,14 +686,6 @@ flush_thread (void)
 	/* drop floating-point and debug-register state if it exists: */
 	current->thread.flags &=3D ~(IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALI=
D);
 	ia64_drop_fpu(current);
-#ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(task_pt_regs(current))) {
-		ia32_drop_ia64_partial_page_list(current);
-		current->thread.task_size =3D IA32_PAGE_OFFSET;
-		set_fs(USER_DS);
-		memset(current->thread.tls_array, 0, sizeof(current->thread.tls_array));
-	}
-#endif
 }
=20
 /*
@@ -753,8 +706,6 @@ exit_thread (void)
 	if (current->thread.flags & IA64_THREAD_DBG_VALID)
 		pfm_release_debug_registers(current);
 #endif
-	if (IS_IA32_PROCESS(task_pt_regs(current)))
-		ia32_drop_ia64_partial_page_list(current);
 }
=20
 unsigned long
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 9daa87f..b61afbb 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1250,13 +1250,8 @@ syscall_trace_enter (long arg0, long arg1, long arg2=
, long arg3,
 		long syscall;
 		int arch;
=20
-		if (IS_IA32_PROCESS(&regs)) {
-			syscall =3D regs.r1;
-			arch =3D AUDIT_ARCH_I386;
-		} else {
-			syscall =3D regs.r15;
-			arch =3D AUDIT_ARCH_IA64;
-		}
+		syscall =3D regs.r15;
+		arch =3D AUDIT_ARCH_IA64;
=20
 		audit_syscall_entry(arch, syscall, arg0, arg1, arg2, arg3);
 	}
@@ -2172,11 +2167,6 @@ static const struct user_regset_view user_ia64_view =
=3D {
=20
 const struct user_regset_view *task_user_regset_view(struct task_struct *t=
sk)
 {
-#ifdef CONFIG_IA32_SUPPORT
-	extern const struct user_regset_view user_ia32_view;
-	if (IS_IA32_PROCESS(task_pt_regs(tsk)))
-		return &user_ia32_view;
-#endif
 	return &user_ia64_view;
 }
=20
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index a1ea879..41ae6a5 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -46,7 +46,6 @@
 #include <linux/kexec.h>
 #include <linux/crash_dump.h>
=20
-#include <asm/ia32.h>
 #include <asm/machvec.h>
 #include <asm/mca.h>
 #include <asm/meminit.h>
@@ -1016,10 +1015,6 @@ cpu_init (void)
 	ia64_mmu_init(ia64_imva(cpu_data));
 	ia64_mca_cpu_init(ia64_imva(cpu_data));
=20
-#ifdef CONFIG_IA32_SUPPORT
-	ia32_cpu_init();
-#endif
-
 	/* Clear ITC to eliminate sched_clock() overflows in human time.  */
 	ia64_set_itc(0);
=20
diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index e1821ca..7bdafc8 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -21,7 +21,6 @@
 #include <linux/unistd.h>
 #include <linux/wait.h>
=20
-#include <asm/ia32.h>
 #include <asm/intrinsics.h>
 #include <asm/uaccess.h>
 #include <asm/rse.h>
@@ -425,14 +424,8 @@ static long
 handle_signal (unsigned long sig, struct k_sigaction *ka, siginfo_t *info,=
 sigset_t *oldset,
 	       struct sigscratch *scr)
 {
-	if (IS_IA32_PROCESS(&scr->pt)) {
-		/* send signal to IA-32 process */
-		if (!ia32_setup_frame1(sig, ka, info, oldset, &scr->pt))
-			return 0;
-	} else
-		/* send signal to IA-64 process */
-		if (!setup_frame(sig, ka, info, oldset, scr))
-			return 0;
+	if (!setup_frame(sig, ka, info, oldset, scr))
+		return 0;
=20
 	spin_lock_irq(&current->sighand->siglock);
 	sigorsets(&current->blocked, &current->blocked, &ka->sa.sa_mask);
@@ -462,7 +455,6 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 	siginfo_t info;
 	long restart =3D in_syscall;
 	long errno =3D scr->pt.r8;
-#	define ERR_CODE(c)	(IS_IA32_PROCESS(&scr->pt) ? -(c) : (c))
=20
 	/*
 	 * In the ia64_leave_kernel code path, we want the common case to go fast=
, which
@@ -490,14 +482,7 @@ ia64_do_signal (struct sigscratch *scr, long in_syscal=
l)
 		 * inferior call), thus it's important to check for restarting _after_
 		 * get_signal_to_deliver().
 		 */
-		if (IS_IA32_PROCESS(&scr->pt)) {
-			if (in_syscall) {
-				if (errno >=3D 0)
-					restart =3D 0;
-				else
-					errno =3D -errno;
-			}
-		} else if ((long) scr->pt.r10 !=3D -1)
+		if ((long) scr->pt.r10 !=3D -1)
 			/*
 			 * A system calls has to be restarted only if one of the error codes
 			 * ERESTARTNOHAND, ERESTARTSYS, or ERESTARTNOINTR is returned.  If r10
@@ -513,22 +498,18 @@ ia64_do_signal (struct sigscratch *scr, long in_sysca=
ll)
 			switch (errno) {
 			      case ERESTART_RESTARTBLOCK:
 			      case ERESTARTNOHAND:
-				scr->pt.r8 =3D ERR_CODE(EINTR);
+				scr->pt.r8 =3D EINTR;
 				/* note: scr->pt.r10 is already -1 */
 				break;
=20
 			      case ERESTARTSYS:
 				if ((ka.sa.sa_flags & SA_RESTART) =3D 0) {
-					scr->pt.r8 =3D ERR_CODE(EINTR);
+					scr->pt.r8 =3D EINTR;
 					/* note: scr->pt.r10 is already -1 */
 					break;
 				}
 			      case ERESTARTNOINTR:
-				if (IS_IA32_PROCESS(&scr->pt)) {
-					scr->pt.r8 =3D scr->pt.r1;
-					scr->pt.cr_iip -=3D 2;
-				} else
-					ia64_decrement_ip(&scr->pt);
+				ia64_decrement_ip(&scr->pt);
 				restart =3D 0; /* don't restart twice if handle_signal() fails... */
 			}
 		}
@@ -555,21 +536,14 @@ ia64_do_signal (struct sigscratch *scr, long in_sysca=
ll)
 		if (errno =3D ERESTARTNOHAND || errno =3D ERESTARTSYS || errno =3D EREST=
ARTNOINTR
 		    || errno =3D ERESTART_RESTARTBLOCK)
 		{
-			if (IS_IA32_PROCESS(&scr->pt)) {
-				scr->pt.r8 =3D scr->pt.r1;
-				scr->pt.cr_iip -=3D 2;
-				if (errno =3D ERESTART_RESTARTBLOCK)
-					scr->pt.r8 =3D 0;	/* x86 version of __NR_restart_syscall */
-			} else {
-				/*
-				 * Note: the syscall number is in r15 which is saved in
-				 * pt_regs so all we need to do here is adjust ip so that
-				 * the "break" instruction gets re-executed.
-				 */
-				ia64_decrement_ip(&scr->pt);
-				if (errno =3D ERESTART_RESTARTBLOCK)
-					scr->pt.r15 =3D __NR_restart_syscall;
-			}
+			/*
+			 * Note: the syscall number is in r15 which is saved in
+			 * pt_regs so all we need to do here is adjust ip so that
+			 * the "break" instruction gets re-executed.
+			 */
+			ia64_decrement_ip(&scr->pt);
+			if (errno =3D ERESTART_RESTARTBLOCK)
+				scr->pt.r15 =3D __NR_restart_syscall;
 		}
 	}
=20
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index de100aa..e5230b2 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -44,7 +44,6 @@
 #include <asm/cache.h>
 #include <asm/current.h>
 #include <asm/delay.h>
-#include <asm/ia32.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/machvec.h>
@@ -443,10 +442,6 @@ smp_callin (void)
 		calibrate_delay();
 	local_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
=20
-#ifdef CONFIG_IA32_SUPPORT
-	ia32_gdt_init();
-#endif
-
 	/*
 	 * Allow the master to continue.
 	 */
diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index f0cda76..fd80e70 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -19,7 +19,6 @@
 #include <linux/kdebug.h>
=20
 #include <asm/fpswa.h>
-#include <asm/ia32.h>
 #include <asm/intrinsics.h>
 #include <asm/processor.h>
 #include <asm/uaccess.h>
@@ -626,10 +625,6 @@ ia64_fault (unsigned long vector, unsigned long isr, u=
nsigned long ifa,
 		break;
=20
 	      case 45:
-#ifdef CONFIG_IA32_SUPPORT
-		if (ia32_exception(&regs, isr) =3D 0)
-			return;
-#endif
 		printk(KERN_ERR "Unexpected IA-32 exception (Trap 45)\n");
 		printk(KERN_ERR "  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx\n",
 		       iip, ifa, isr);
@@ -637,10 +632,6 @@ ia64_fault (unsigned long vector, unsigned long isr, u=
nsigned long ifa,
 		break;
=20
 	      case 46:
-#ifdef CONFIG_IA32_SUPPORT
-		if (ia32_intercept(&regs, isr) =3D 0)
-			return;
-#endif
 		printk(KERN_ERR "Unexpected IA-32 intercept trap (Trap 46)\n");
 		printk(KERN_ERR "  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx, iim - 0x%lx\n",
 		       iip, ifa, isr, iim);
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 7c0d481..ca3335e 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -22,7 +22,6 @@
 #include <linux/kexec.h>
=20
 #include <asm/dma.h>
-#include <asm/ia32.h>
 #include <asm/io.h>
 #include <asm/machvec.h>
 #include <asm/numa.h>
@@ -668,10 +667,6 @@ mem_init (void)
 			fsyscall_table[i] =3D sys_call_table[i] | 1;
 	}
 	setup_gate();
-
-#ifdef CONFIG_IA32_SUPPORT
-	ia32_mem_init();
-#endif
 }
=20
 #ifdef CONFIG_MEMORY_HOTPLUG
diff --git a/arch/ia64/xen/hypercall.S b/arch/ia64/xen/hypercall.S
index e32dae4..08847aa 100644
--- a/arch/ia64/xen/hypercall.S
+++ b/arch/ia64/xen/hypercall.S
@@ -58,11 +58,6 @@ __HCALL2(xen_ptcga, HYPERPRIVOP_PTC_GA)
 __HCALL2(xen_set_rr, HYPERPRIVOP_SET_RR)
 __HCALL2(xen_set_kr, HYPERPRIVOP_SET_KR)
=20
-#ifdef CONFIG_IA32_SUPPORT
-__HCALL0(xen_get_eflag, HYPERPRIVOP_GET_EFLAG)
-__HCALL1(xen_set_eflag, HYPERPRIVOP_SET_EFLAG)	// refer SDM vol1 3.1.8
-#endif /* CONFIG_IA32_SUPPORT */
-
 GLOBAL_ENTRY(xen_set_rr0_to_rr4)
 	mov r8=3Dr32
 	mov r9=3Dr33
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 5e2270a..8adc6a1 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -301,11 +301,6 @@ static void xen_setreg(int regnum, unsigned long val)
 	case _IA64_REG_AR_KR0 ... _IA64_REG_AR_KR7:
 		xen_set_kr(regnum - _IA64_REG_AR_KR0, val);
 		break;
-#ifdef CONFIG_IA32_SUPPORT
-	case _IA64_REG_AR_EFLAG:
-		xen_set_eflag(val);
-		break;
-#endif
 	case _IA64_REG_AR_ITC:
 		xen_set_itc(val);
 		break;
@@ -332,11 +327,6 @@ static unsigned long xen_getreg(int regnum)
 	case _IA64_REG_PSR:
 		res =3D xen_get_psr();
 		break;
-#ifdef CONFIG_IA32_SUPPORT
-	case _IA64_REG_AR_EFLAG:
-		res =3D xen_get_eflag();
-		break;
-#endif
 	case _IA64_REG_AR_ITC:
 		res =3D xen_get_itc();
 		break;
@@ -710,9 +700,6 @@ extern unsigned long xen_getreg(int regnum);
=20
 __DEFINE_FUNC(getreg,
 	      __DEFINE_GET_REG(PSR, PSR)
-#ifdef CONFIG_IA32_SUPPORT
-	      __DEFINE_GET_REG(AR_EFLAG, EFLAG)
-#endif
=20
 	      /* get_itc */
 	      "mov r2 =3D " __stringify(_IA64_REG_AR_ITC) "\n"
@@ -789,9 +776,6 @@ __DEFINE_FUNC(setreg,
 	      ";;\n"
 	      "(p6) br.cond.spnt xen_set_itc\n"
=20
-#ifdef CONFIG_IA32_SUPPORT
-	      __DEFINE_SET_REG(AR_EFLAG, SET_EFLAG)
-#endif
 	      __DEFINE_SET_REG(CR_TPR, SET_TPR)
 	      __DEFINE_SET_REG(CR_EOI, EOI)
=20
diff --git a/drivers/input/input-compat.h b/drivers/input/input-compat.h
index 47cd9ea..4d8ea32 100644
--- a/drivers/input/input-compat.h
+++ b/drivers/input/input-compat.h
@@ -21,8 +21,6 @@
    you why the ifdefs are needed? Think about it again. -AK */
 #ifdef CONFIG_X86_64
 #  define INPUT_COMPAT_TEST is_compat_task()
-#elif defined(CONFIG_IA64)
-#  define INPUT_COMPAT_TEST IS_IA32_PROCESS(task_pt_regs(current))
 #elif defined(CONFIG_S390)
 #  define INPUT_COMPAT_TEST test_thread_flag(TIF_31BIT)
 #elif defined(CONFIG_MIPS)
