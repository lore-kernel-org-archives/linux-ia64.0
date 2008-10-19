From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 19 Oct 2008 08:21:15 +0000
Subject: [PATCH] Convert ia64 to use int-ll64.h
Message-Id: <20081019082115.GB26184@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


It is generally agreed that it would be beneficial for u64 to be an
unsigned long long on all architectures.  ia64 (in common with several
other 64-bit architectures) currently uses unsigned long.  Migrating
piecemeal is too painful; this giant patch fixes all compilation warnings
and errors that come as a result of switching to use int-ll64.h.

Note that userspace will still see __u64 defined as unsigned long.  This
is important as it affects C++ name mangling.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iomm=
u.c
index 4956be4..e3ab268 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1771,7 +1771,7 @@ static struct ioc_iommu ioc_iommu_info[] __initdata =
=3D {
 };
=20
 static struct ioc * __init
-ioc_init(u64 hpa, void *handle)
+ioc_init(unsigned long hpa, void *handle)
 {
 	struct ioc *ioc;
 	struct ioc_iommu *info;
diff --git a/arch/ia64/include/asm/gcc_intrin.h b/arch/ia64/include/asm/gcc=
_intrin.h
index 0f5b559..d258064 100644
--- a/arch/ia64/include/asm/gcc_intrin.h
+++ b/arch/ia64/include/asm/gcc_intrin.h
@@ -387,7 +387,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
=20
 #define ia64_native_thash(addr)							\
 ({										\
-	__u64 ia64_intri_res;							\
+	unsigned long ia64_intri_res;						\
 	asm volatile ("thash %0=3D%1" : "=3Dr"(ia64_intri_res) : "r" (addr));	\
 	ia64_intri_res;								\
 })
@@ -418,7 +418,7 @@ register unsigned long ia64_r13 asm ("r13") __used;
=20
 #define ia64_tpa(addr)								\
 ({										\
-	__u64 ia64_pa;								\
+	unsigned long ia64_pa;							\
 	asm volatile ("tpa %0 =3D %1" : "=3Dr"(ia64_pa) : "r"(addr) : "memory");	\
 	ia64_pa;								\
 })
@@ -443,35 +443,35 @@ register unsigned long ia64_r13 asm ("r13") __used;
=20
 #define ia64_native_get_cpuid(index)							\
 ({											\
-	__u64 ia64_intri_res;								\
+	unsigned long ia64_intri_res;							\
 	asm volatile ("mov %0=3Dcpuid[%r1]" : "=3Dr"(ia64_intri_res) : "rO"(index=
));	\
 	ia64_intri_res;									\
 })
=20
 #define __ia64_get_dbr(index)							\
 ({										\
-	__u64 ia64_intri_res;							\
+	unsigned long ia64_intri_res;						\
 	asm volatile ("mov %0=DBr[%1]" : "=3Dr"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
=20
 #define ia64_get_ibr(index)							\
 ({										\
-	__u64 ia64_intri_res;							\
+	unsigned long ia64_intri_res;						\
 	asm volatile ("mov %0=3Dibr[%1]" : "=3Dr"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
=20
 #define ia64_get_pkr(index)							\
 ({										\
-	__u64 ia64_intri_res;							\
+	unsigned long ia64_intri_res;						\
 	asm volatile ("mov %0=3Dpkr[%1]" : "=3Dr"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
=20
 #define ia64_get_pmc(index)							\
 ({										\
-	__u64 ia64_intri_res;							\
+	unsigned long ia64_intri_res;						\
 	asm volatile ("mov %0=3Dpmc[%1]" : "=3Dr"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
@@ -479,14 +479,14 @@ register unsigned long ia64_r13 asm ("r13") __used;
=20
 #define ia64_native_get_pmd(index)						\
 ({										\
-	__u64 ia64_intri_res;							\
+	unsigned long ia64_intri_res;						\
 	asm volatile ("mov %0=3Dpmd[%1]" : "=3Dr"(ia64_intri_res) : "r"(index));	\
 	ia64_intri_res;								\
 })
=20
 #define ia64_native_get_rr(index)						\
 ({										\
-	__u64 ia64_intri_res;							\
+	unsigned long ia64_intri_res;						\
 	asm volatile ("mov %0=3Drr[%1]" : "=3Dr"(ia64_intri_res) : "r" (index));	\
 	ia64_intri_res;								\
 })
diff --git a/arch/ia64/include/asm/mca.h b/arch/ia64/include/asm/mca.h
index 18a4321..44a0b53 100644
--- a/arch/ia64/include/asm/mca.h
+++ b/arch/ia64/include/asm/mca.h
@@ -72,39 +72,39 @@ typedef struct ia64_mc_info_s {
 struct ia64_sal_os_state {
=20
 	/* SAL to OS */
-	u64			os_gp;			/* GP of the os registered with the SAL, physical */
-	u64			pal_proc;		/* PAL_PROC entry point, physical */
-	u64			sal_proc;		/* SAL_PROC entry point, physical */
-	u64			rv_rc;			/* MCA - Rendezvous state, INIT - reason code */
-	u64			proc_state_param;	/* from R18 */
-	u64			monarch;		/* 1 for a monarch event, 0 for a slave */
+	unsigned long		os_gp;			/* GP of the os registered with the SAL, physical=
 */
+	unsigned long		pal_proc;		/* PAL_PROC entry point, physical */
+	unsigned long		sal_proc;		/* SAL_PROC entry point, physical */
+	unsigned long		rv_rc;			/* MCA - Rendezvous state, INIT - reason code */
+	unsigned long		proc_state_param;	/* from R18 */
+	unsigned long		monarch;		/* 1 for a monarch event, 0 for a slave */
=20
 	/* common */
-	u64			sal_ra;			/* Return address in SAL, physical */
-	u64			sal_gp;			/* GP of the SAL - physical */
+	unsigned long		sal_ra;			/* Return address in SAL, physical */
+	unsigned long		sal_gp;			/* GP of the SAL - physical */
 	pal_min_state_area_t	*pal_min_state;		/* from R17.  physical in asm, virt=
ual in C */
 	/* Previous values of IA64_KR(CURRENT) and IA64_KR(CURRENT_STACK).
 	 * Note: if the MCA/INIT recovery code wants to resume to a new context
 	 * then it must change these values to reflect the new kernel stack.
 	 */
-	u64			prev_IA64_KR_CURRENT;	/* previous value of IA64_KR(CURRENT) */
-	u64			prev_IA64_KR_CURRENT_STACK;
+	unsigned long		prev_IA64_KR_CURRENT;	/* previous value of IA64_KR(CURRENT=
) */
+	unsigned long		prev_IA64_KR_CURRENT_STACK;
 	struct task_struct	*prev_task;		/* previous task, NULL if it is not usefu=
l */
 	/* Some interrupt registers are not saved in minstate, pt_regs or
 	 * switch_stack.  Because MCA/INIT can occur when interrupts are
 	 * disabled, we need to save the additional interrupt registers over
 	 * MCA/INIT and resume.
 	 */
-	u64			isr;
-	u64			ifa;
-	u64			itir;
-	u64			iipa;
-	u64			iim;
-	u64			iha;
+	unsigned long		isr;
+	unsigned long		ifa;
+	unsigned long		itir;
+	unsigned long		iipa;
+	unsigned long		iim;
+	unsigned long		iha;
=20
 	/* OS to SAL */
-	u64			os_status;		/* OS status to SAL, enum below */
-	u64			context;		/* 0 if return to same context
+	unsigned long		os_status;		/* OS status to SAL, enum below */
+	unsigned long		context;		/* 0 if return to same context
 							   1 if return to new context */
 };
=20
@@ -150,7 +150,7 @@ extern void ia64_slave_init_handler(void);
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_st=
ate *));
 extern void ia64_unreg_MCA_extension(void);
-extern u64 ia64_get_rnat(u64 *);
+extern unsigned long ia64_get_rnat(unsigned long *);
 extern void ia64_mca_printk(const char * fmt, ...)
 	 __attribute__ ((format (printf, 1, 2)));
=20
diff --git a/arch/ia64/include/asm/meminit.h b/arch/ia64/include/asm/memini=
t.h
index 7245a57..5525053 100644
--- a/arch/ia64/include/asm/meminit.h
+++ b/arch/ia64/include/asm/meminit.h
@@ -63,8 +63,10 @@ extern int register_active_ranges(u64 start, u64 len, in=
t nid);
 # define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than thi=
s */
   extern unsigned long vmalloc_end;
   extern struct page *vmem_map;
-  extern int find_largest_hole (u64 start, u64 end, void *arg);
-  extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
+  extern int find_largest_hole(unsigned long start, unsigned long end,
+								void *arg);
+  extern int create_mem_map_page_table(unsigned long start, unsigned long =
end,
+								void *arg);
   extern int vmemmap_find_next_valid_pfn(int, int);
 #else
 static inline int vmemmap_find_next_valid_pfn(int node, int i)
diff --git a/arch/ia64/include/asm/pal.h b/arch/ia64/include/asm/pal.h
index 67b0290..6a29250 100644
--- a/arch/ia64/include/asm/pal.h
+++ b/arch/ia64/include/asm/pal.h
@@ -989,8 +989,8 @@ ia64_pal_cache_read (pal_cache_line_id_u_t line_id, u64=
 physical_addr)
 }
=20
 /* Return summary information about the hierarchy of caches controlled by =
the processor */
-static inline s64
-ia64_pal_cache_summary (u64 *cache_levels, u64 *unique_caches)
+static inline long ia64_pal_cache_summary(unsigned long *cache_levels,
+						unsigned long *unique_caches)
 {
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_CACHE_SUMMARY, 0, 0, 0);
@@ -1038,8 +1038,8 @@ ia64_pal_copy_pal (u64 target_addr, u64 alloc_size, u=
64 processor, u64 *pal_proc
 }
=20
 /* Return the number of instruction and data debug register pairs */
-static inline s64
-ia64_pal_debug_info (u64 *inst_regs,  u64 *data_regs)
+static inline long ia64_pal_debug_info(unsigned long *inst_regs,
+						unsigned long *data_regs)
 {
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_DEBUG_INFO, 0, 0, 0);
@@ -1074,8 +1074,7 @@ ia64_pal_fixed_addr (u64 *global_unique_addr)
 }
=20
 /* Get base frequency of the platform if generated by the processor */
-static inline s64
-ia64_pal_freq_base (u64 *platform_base_freq)
+static inline long ia64_pal_freq_base(unsigned long *platform_base_freq)
 {
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_FREQ_BASE, 0, 0, 0);
@@ -1437,7 +1436,7 @@ ia64_pal_proc_set_features (u64 feature_select)
  * possible.
  */
 typedef struct ia64_ptce_info_s {
-	u64		base;
+	unsigned long	base;
 	u32		count[2];
 	u32		stride[2];
 } ia64_ptce_info_t;
@@ -1478,9 +1477,9 @@ ia64_pal_register_info (u64 info_request, u64 *reg_in=
fo_1, u64 *reg_info_2)
 }
=20
 typedef union pal_hints_u {
-	u64			ph_data;
+	unsigned long		ph_data;
 	struct {
-	       u64		si		: 1,
+	       unsigned long	si		: 1,
 				li		: 1,
 				reserved	: 62;
 	} pal_hints_s;
@@ -1489,8 +1488,8 @@ typedef union pal_hints_u {
 /* Return information about the register stack and RSE for this processor
  * implementation.
  */
-static inline s64
-ia64_pal_rse_info (u64 *num_phys_stacked, pal_hints_u_t *hints)
+static inline long ia64_pal_rse_info(unsigned long *num_phys_stacked,
+							pal_hints_u_t *hints)
 {
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_RSE_INFO, 0, 0, 0);
@@ -1608,8 +1607,7 @@ ia64_pal_vm_info (u64 tc_level, u64 tc_type,  pal_tc_=
info_u_t *tc_info, u64 *tc_
 /* Get page size information about the virtual memory characteristics of t=
he processor
  * implementation.
  */
-static inline s64
-ia64_pal_vm_page_size (u64 *tr_pages, u64 *vw_pages)
+static inline s64 ia64_pal_vm_page_size(u64 *tr_pages, u64 *vw_pages)
 {
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_VM_PAGE_SIZE, 0, 0, 0);
diff --git a/arch/ia64/include/asm/processor.h b/arch/ia64/include/asm/proc=
essor.h
index f88fa05..3eaeedf 100644
--- a/arch/ia64/include/asm/processor.h
+++ b/arch/ia64/include/asm/processor.h
@@ -187,40 +187,40 @@ union  ia64_rr {
  * state comes earlier:
  */
 struct cpuinfo_ia64 {
-	__u32 softirq_pending;
-	__u64 itm_delta;	/* # of clock cycles between clock ticks */
-	__u64 itm_next;		/* interval timer mask value to use for next clock tick =
*/
-	__u64 nsec_per_cyc;	/* (1000000000<<IA64_NSEC_PER_CYC_SHIFT)/itc_freq */
-	__u64 unimpl_va_mask;	/* mask of unimplemented virtual address bits (from=
 PAL) */
-	__u64 unimpl_pa_mask;	/* mask of unimplemented physical address bits (fro=
m PAL) */
-	__u64 itc_freq;		/* frequency of ITC counter */
-	__u64 proc_freq;	/* frequency of processor */
-	__u64 cyc_per_usec;	/* itc_freq/1000000 */
-	__u64 ptce_base;
-	__u32 ptce_count[2];
-	__u32 ptce_stride[2];
+	unsigned int softirq_pending;
+	unsigned long itm_delta;	/* # of clock cycles between clock ticks */
+	unsigned long itm_next;		/* interval timer mask value to use for next clo=
ck tick */
+	unsigned long nsec_per_cyc;	/* (1000000000<<IA64_NSEC_PER_CYC_SHIFT)/itc_=
freq */
+	unsigned long unimpl_va_mask;	/* mask of unimplemented virtual address bi=
ts (from PAL) */
+	unsigned long unimpl_pa_mask;	/* mask of unimplemented physical address b=
its (from PAL) */
+	unsigned long itc_freq;		/* frequency of ITC counter */
+	unsigned long proc_freq;	/* frequency of processor */
+	unsigned long cyc_per_usec;	/* itc_freq/1000000 */
+	unsigned long ptce_base;
+	unsigned int ptce_count[2];
+	unsigned int ptce_stride[2];
 	struct task_struct *ksoftirqd;	/* kernel softirq daemon for this CPU */
=20
 #ifdef CONFIG_SMP
-	__u64 loops_per_jiffy;
+	unsigned long loops_per_jiffy;
 	int cpu;
-	__u32 socket_id;	/* physical processor socket id */
-	__u16 core_id;		/* core id */
-	__u16 thread_id;	/* thread id */
-	__u16 num_log;		/* Total number of logical processors on
+	unsigned int socket_id;	/* physical processor socket id */
+	unsigned short core_id;	/* core id */
+	unsigned short thread_id; /* thread id */
+	unsigned short num_log;	/* Total number of logical processors on
 				 * this socket that were successfully booted */
-	__u8  cores_per_socket;	/* Cores per processor socket */
-	__u8  threads_per_core;	/* Threads per core */
+	unsigned char cores_per_socket;	/* Cores per processor socket */
+	unsigned char threads_per_core;	/* Threads per core */
 #endif
=20
 	/* CPUID-derived information: */
-	__u64 ppn;
-	__u64 features;
-	__u8 number;
-	__u8 revision;
-	__u8 model;
-	__u8 family;
-	__u8 archrev;
+	unsigned long ppn;
+	unsigned long features;
+	unsigned char number;
+	unsigned char revision;
+	unsigned char model;
+	unsigned char family;
+	unsigned char archrev;
 	char vendor[16];
 	char *model_name;
=20
@@ -329,8 +329,8 @@ struct thread_struct {
 #else
 # define INIT_THREAD_PM
 #endif
-	__u64 dbr[IA64_NUM_DBG_REGS];
-	__u64 ibr[IA64_NUM_DBG_REGS];
+	unsigned long dbr[IA64_NUM_DBG_REGS];
+	unsigned long ibr[IA64_NUM_DBG_REGS];
 	struct ia64_fpreg fph[96];	/* saved/loaded on demand */
 };
=20
diff --git a/arch/ia64/include/asm/sal.h b/arch/ia64/include/asm/sal.h
index ea310c0..b87210d 100644
--- a/arch/ia64/include/asm/sal.h
+++ b/arch/ia64/include/asm/sal.h
@@ -106,10 +106,10 @@ struct ia64_sal_retval {
 	 * informational value should be printed (e.g., "reboot for
 	 * change to take effect").
 	 */
-	s64 status;
-	u64 v0;
-	u64 v1;
-	u64 v2;
+	long status;
+	unsigned long v0;
+	unsigned long v1;
+	unsigned long v2;
 };
=20
 typedef struct ia64_sal_retval (*ia64_sal_handler) (u64, ...);
diff --git a/arch/ia64/include/asm/types.h b/arch/ia64/include/asm/types.h
index e36b371..835ceb9 100644
--- a/arch/ia64/include/asm/types.h
+++ b/arch/ia64/include/asm/types.h
@@ -2,10 +2,11 @@
 #define _ASM_IA64_TYPES_H
=20
 /*
- * This file is never included by application software unless explicitly r=
equested (e.g.,
- * via linux/types.h) in which case the application is Linux specific so (=
user-) name
- * space pollution is not a major issue.  However, for interoperability, l=
ibraries still
- * need to be careful to avoid a name clashes.
+ * This file is never included by application software unless explicitly
+ * requested (e.g., via linux/types.h) in which case the application is
+ * Linux specific so (user-) name space pollution is not a major issue.
+ * However, for interoperability, libraries still need to be careful to
+ * avoid naming clashes.
  *
  * Based on <asm-alpha/types.h>.
  *
@@ -13,7 +14,11 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
  */
=20
+#ifdef __KERNEL__
+#include <asm-generic/int-ll64.h>
+#else
 #include <asm-generic/int-l64.h>
+#endif
=20
 #ifdef __ASSEMBLY__
 # define __IA64_UL(x)		(x)
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 51b75ce..6e47645 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -46,7 +46,7 @@ extern efi_status_t efi_call_phys (void *, ...);
 struct efi efi;
 EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
-static unsigned long mem_limit =3D ~0UL, max_addr =3D ~0UL, min_addr =3D 0=
UL;
+static u64 mem_limit =3D ~0UL, max_addr =3D ~0UL, min_addr =3D 0UL;
=20
 #define efi_call_virt(f, args...)	(*(f))(args)
=20
@@ -356,7 +356,7 @@ efi_get_pal_addr (void)
=20
 		if (++pal_code_count > 1) {
 			printk(KERN_ERR "Too many EFI Pal Code memory ranges, "
-			       "dropped @ %lx\n", md->phys_addr);
+			       "dropped @ %llx\n", md->phys_addr);
 			continue;
 		}
 		/*
@@ -489,10 +489,10 @@ efi_init (void)
 		}
 	}
 	if (min_addr !=3D 0UL)
-		printk(KERN_INFO "Ignoring memory below %luMB\n",
+		printk(KERN_INFO "Ignoring memory below %lluMB\n",
 		       min_addr >> 20);
 	if (max_addr !=3D ~0UL)
-		printk(KERN_INFO "Ignoring memory above %luMB\n",
+		printk(KERN_INFO "Ignoring memory above %lluMB\n",
 		       max_addr >> 20);
=20
 	efi.systab =3D __va(ia64_boot_param->efi_systab);
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 7dd96c1..22ec6a0 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -850,7 +850,7 @@ EXPORT_SYMBOL(ia64_unreg_MCA_extension);
=20
=20
 static inline void
-copy_reg(const u64 *fr, u64 fnat, u64 *tr, u64 *tnat)
+copy_reg(const u64 *fr, u64 fnat, unsigned long *tr, unsigned long *tnat)
 {
 	u64 fslot, tslot, nat;
 	*tr =3D *fr;
@@ -914,9 +914,9 @@ ia64_mca_modify_original_stack(struct pt_regs *regs,
 	struct switch_stack *old_sw;
 	unsigned size =3D sizeof(struct pt_regs) +
 			sizeof(struct switch_stack) + 16;
-	u64 *old_bspstore, *old_bsp;
-	u64 *new_bspstore, *new_bsp;
-	u64 old_unat, old_rnat, new_rnat, nat;
+	unsigned long *old_bspstore, *old_bsp;
+	unsigned long *new_bspstore, *new_bsp;
+	unsigned long old_unat, old_rnat, new_rnat, nat;
 	u64 slots, loadrs =3D regs->loadrs;
 	u64 r12 =3D ms->pmsa_gr[12-1], r13 =3D ms->pmsa_gr[13-1];
 	u64 ar_bspstore =3D regs->ar_bspstore;
@@ -968,10 +968,10 @@ ia64_mca_modify_original_stack(struct pt_regs *regs,
 	 * loadrs for the new stack and save it in the new pt_regs, where
 	 * ia64_old_stack() can get it.
 	 */
-	old_bspstore =3D (u64 *)ar_bspstore;
-	old_bsp =3D (u64 *)ar_bsp;
+	old_bspstore =3D (unsigned long *)ar_bspstore;
+	old_bsp =3D (unsigned long *)ar_bsp;
 	slots =3D ia64_rse_num_regs(old_bspstore, old_bsp);
-	new_bspstore =3D (u64 *)((u64)current + IA64_RBS_OFFSET);
+	new_bspstore =3D (unsigned long *)((u64)current + IA64_RBS_OFFSET);
 	new_bsp =3D ia64_rse_skip_regs(new_bspstore, slots);
 	regs->loadrs =3D (new_bsp - new_bspstore) * 8 << 16;
=20
@@ -1918,9 +1918,9 @@ ia64_mca_init(void)
 	ia64_fptr_t *init_hldlr_ptr_slave =3D (ia64_fptr_t *)ia64_os_init_dispatc=
h_slave;
 	ia64_fptr_t *mca_hldlr_ptr =3D (ia64_fptr_t *)ia64_os_mca_dispatch;
 	int i;
-	s64 rc;
+	long rc;
 	struct ia64_sal_retval isrv;
-	u64 timeout =3D IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
+	unsigned long timeout =3D IA64_MCA_RENDEZ_TIMEOUT; /* platform specific */
 	static struct notifier_block default_init_monarch_nb =3D {
 		.notifier_call =3D default_monarch_init_process,
 		.priority =3D 0/* we need to notified last */
diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index aaa7d90..c0cb1d0 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -171,7 +171,8 @@ apply_imm60 (struct module *mod, struct insn *insn, uin=
t64_t val)
 		return 0;
 	}
 	if (val + ((uint64_t) 1 << 59) >=3D (1UL << 60)) {
-		printk(KERN_ERR "%s: value %ld out of IMM60 range\n", mod->name, (int64_=
t) val);
+		printk(KERN_ERR "%s: value %ld out of IMM60 range\n",
+			mod->name, (long) val);
 		return 0;
 	}
 	ia64_patch_imm60((u64) insn, val);
@@ -182,7 +183,8 @@ static int
 apply_imm22 (struct module *mod, struct insn *insn, uint64_t val)
 {
 	if (val + (1 << 21) >=3D (1 << 22)) {
-		printk(KERN_ERR "%s: value %li out of IMM22 range\n", mod->name, (int64_=
t)val);
+		printk(KERN_ERR "%s: value %li out of IMM22 range\n",
+			mod->name, (long)val);
 		return 0;
 	}
 	ia64_patch((u64) insn, 0x01fffcfe000UL, (  ((val & 0x200000UL) << 15) /* =
bit 21 -> 36 */
@@ -196,7 +198,8 @@ static int
 apply_imm21b (struct module *mod, struct insn *insn, uint64_t val)
 {
 	if (val + (1 << 20) >=3D (1 << 21)) {
-		printk(KERN_ERR "%s: value %li out of IMM21b range\n", mod->name, (int64=
_t)val);
+		printk(KERN_ERR "%s: value %li out of IMM21b range\n",
+			mod->name, (long)val);
 		return 0;
 	}
 	ia64_patch((u64) insn, 0x11ffffe000UL, (  ((val & 0x100000UL) << 16) /* b=
it 20 -> 36 */
@@ -694,8 +697,9 @@ do_reloc (struct module *mod, uint8_t r_type, Elf64_Sym=
 *sym, uint64_t addend,
 	      case RV_PCREL2:
 		if (r_type =3D R_IA64_PCREL21BI) {
 			if (!is_internal(mod, val)) {
-				printk(KERN_ERR "%s: %s reloc against non-local symbol (%lx)\n",
-				       __func__, reloc_name[r_type], val);
+				printk(KERN_ERR "%s: %s reloc against "
+					"non-local symbol (%lx)\n", __func__,
+					reloc_name[r_type], (unsigned long)val);
 				return -ENOEXEC;
 			}
 			format =3D RF_INSN21B;
diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index e5c57f4..03063a4 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -218,10 +218,10 @@ static int
 cache_info(char *page)
 {
 	char *p =3D page;
-	u64 i, levels, unique_caches;
+	unsigned long i, levels, unique_caches;
 	pal_cache_config_info_t cci;
 	int j, k;
-	s64 status;
+	long status;
=20
 	if ((status =3D ia64_pal_cache_summary(&levels, &unique_caches)) !=3D 0) {
 		printk(KERN_ERR "ia64_pal_cache_summary=3D%ld\n", status);
@@ -303,7 +303,7 @@ vm_info(char *page)
 	ia64_ptce_info_t ptce;
 	const char *sep;
 	int i, j;
-	s64 status;
+	long status;
=20
 	if ((status =3D ia64_pal_vm_summary(&vm_info_1, &vm_info_2)) !=3D0) {
 		printk(KERN_ERR "ia64_pal_vm_summary=3D%ld\n", status);
@@ -431,9 +431,9 @@ register_info(char *page)
 	char *p =3D page;
 	u64 reg_info[2];
 	u64 info;
-	u64 phys_stacked;
+	unsigned long phys_stacked;
 	pal_hints_u_t hints;
-	u64 iregs, dregs;
+	unsigned long iregs, dregs;
 	char *info_type[]=3D{
 		"Implemented AR(s)",
 		"AR(s) with read side-effects",
@@ -530,8 +530,8 @@ static char **proc_features[]=3D{
 	NULL, NULL, NULL, NULL,
 };
=20
-static char *
-feature_set_info(char *page, u64 avail, u64 status, u64 control, u64 set)
+static char * feature_set_info(char *page, u64 avail, u64 status, u64 cont=
rol,
+							unsigned long set)
 {
 	char *p =3D page;
 	char **vf, **v;
@@ -714,7 +714,7 @@ frequency_info(char *page)
 {
 	char *p =3D page;
 	struct pal_freq_ratio proc, itc, bus;
-	u64 base;
+	unsigned long base;
=20
 	if (ia64_pal_freq_base(&base) =3D -1)
 		p +=3D sprintf(p, "Output clock            : not implemented\n");
@@ -736,43 +736,43 @@ static int
 tr_info(char *page)
 {
 	char *p =3D page;
-	s64 status;
+	long status;
 	pal_tr_valid_u_t tr_valid;
 	u64 tr_buffer[4];
 	pal_vm_info_1_u_t vm_info_1;
 	pal_vm_info_2_u_t vm_info_2;
-	u64 i, j;
-	u64 max[3], pgm;
+	unsigned long i, j;
+	unsigned long max[3], pgm;
 	struct ifa_reg {
-		u64 valid:1;
-		u64 ig:11;
-		u64 vpn:52;
+		unsigned long valid:1;
+		unsigned long ig:11;
+		unsigned long vpn:52;
 	} *ifa_reg;
 	struct itir_reg {
-		u64 rv1:2;
-		u64 ps:6;
-		u64 key:24;
-		u64 rv2:32;
+		unsigned long rv1:2;
+		unsigned long ps:6;
+		unsigned long key:24;
+		unsigned long rv2:32;
 	} *itir_reg;
 	struct gr_reg {
-		u64 p:1;
-		u64 rv1:1;
-		u64 ma:3;
-		u64 a:1;
-		u64 d:1;
-		u64 pl:2;
-		u64 ar:3;
-		u64 ppn:38;
-		u64 rv2:2;
-		u64 ed:1;
-		u64 ig:11;
+		unsigned long p:1;
+		unsigned long rv1:1;
+		unsigned long ma:3;
+		unsigned long a:1;
+		unsigned long d:1;
+		unsigned long pl:2;
+		unsigned long ar:3;
+		unsigned long ppn:38;
+		unsigned long rv2:2;
+		unsigned long ed:1;
+		unsigned long ig:11;
 	} *gr_reg;
 	struct rid_reg {
-		u64 ig1:1;
-		u64 rv1:1;
-		u64 ig2:6;
-		u64 rid:24;
-		u64 rv2:32;
+		unsigned long ig1:1;
+		unsigned long rv1:1;
+		unsigned long ig2:6;
+		unsigned long rid:24;
+		unsigned long rv2:32;
 	} *rid_reg;
=20
 	if ((status =3D ia64_pal_vm_summary(&vm_info_1, &vm_info_2)) !=3D0) {
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index fc8f350..3330197 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -311,7 +311,7 @@ typedef struct pfm_context {
 	unsigned long		th_pmcs[PFM_NUM_PMC_REGS];	/* PMC thread save state */
 	unsigned long		th_pmds[PFM_NUM_PMD_REGS];	/* PMD thread save state */
=20
-	u64			ctx_saved_psr_up;	/* only contains psr.up value */
+	unsigned long		ctx_saved_psr_up;	/* only contains psr.up value */
=20
 	unsigned long		ctx_last_activation;	/* context last activation number for=
 last_cpu */
 	unsigned int		ctx_last_cpu;		/* CPU id of current or last CPU used (SMP o=
nly) */
@@ -5208,8 +5208,8 @@ pfm_end_notify_user(pfm_context_t *ctx)
  * main overflow processing routine.
  * it can be called from the interrupt path or explicitly during the conte=
xt switch code
  */
-static void
-pfm_overflow_handler(struct task_struct *task, pfm_context_t *ctx, u64 pmc=
0, struct pt_regs *regs)
+static void pfm_overflow_handler(struct task_struct *task, pfm_context_t *=
ctx,
+				unsigned long pmc0, struct pt_regs *regs)
 {
 	pfm_ovfl_arg_t *ovfl_arg;
 	unsigned long mask;
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index de636b2..7769985 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -389,7 +389,7 @@ find_initrd (void)
 		initrd_start =3D (unsigned long)__va(ia64_boot_param->initrd_start);
 		initrd_end   =3D initrd_start+ia64_boot_param->initrd_size;
=20
-		printk(KERN_INFO "Initial ramdisk at: 0x%lx (%lu bytes)\n",
+		printk(KERN_INFO "Initial ramdisk at: 0x%lx (%llu bytes)\n",
 		       initrd_start, ia64_boot_param->initrd_size);
 	}
 #endif
@@ -570,7 +570,7 @@ setup_arch (char **cmdline_p)
 	ia64_patch_rse((u64) __start___rse_patchlist, (u64) __end___rse_patchlist=
);
 #else
 	{
-		u64 num_phys_stacked;
+		unsigned long num_phys_stacked;
=20
 		if (ia64_pal_rse_info(&num_phys_stacked, 0) =3D 0 && num_phys_stacked > =
96)
 			ia64_patch_rse((u64) __start___rse_patchlist, (u64) __end___rse_patchli=
st);
@@ -856,9 +856,9 @@ static void __cpuinit
 get_max_cacheline_size (void)
 {
 	unsigned long line_size, max =3D 1;
-	u64 l, levels, unique_caches;
-        pal_cache_config_info_t cci;
-        s64 status;
+	unsigned long l, levels, unique_caches;
+	pal_cache_config_info_t cci;
+	long status;
=20
         status =3D ia64_pal_cache_summary(&levels, &unique_caches);
         if (status !=3D 0) {
@@ -874,9 +874,9 @@ get_max_cacheline_size (void)
 		status =3D ia64_pal_cache_config_info(l, /* cache_type (data_or_unified)=
=3D */ 2,
 						    &cci);
 		if (status !=3D 0) {
-			printk(KERN_ERR
-			       "%s: ia64_pal_cache_config_info(l=3D%lu, 2) failed (status=3D%ld=
)\n",
-			       __func__, l, status);
+			printk(KERN_ERR "%s: ia64_pal_cache_config_info"
+				"(l=3D%lu, 2) failed (status=3D%ld)\n",
+				__func__, l, status);
 			max =3D SMP_CACHE_BYTES;
 			/* The safest setup for "flush_icache_range()" */
 			cci.pcci_stride =3D I_CACHE_STRIDE_SHIFT;
@@ -890,10 +890,10 @@ get_max_cacheline_size (void)
 						    /* cache_type (instruction)=3D */ 1,
 						    &cci);
 			if (status !=3D 0) {
-				printk(KERN_ERR
-				"%s: ia64_pal_cache_config_info(l=3D%lu, 1) failed (status=3D%ld)\n",
+				printk(KERN_ERR "%s: ia64_pal_cache_config_info"
+					"(l=3D%lu, 1) failed (status=3D%ld)\n",
 					__func__, l, status);
-				/* The safest setup for "flush_icache_range()" */
+				/* The safest setup for flush_icache_range() */
 				cci.pcci_stride =3D I_CACHE_STRIDE_SHIFT;
 			}
 		}
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index da8f020..6ab104e 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -66,7 +66,7 @@ static DEFINE_PER_CPU(unsigned short, shadow_flush_counts=
[NR_CPUS]) ____cachelin
 #define IPI_KDUMP_CPU_STOP	3
=20
 /* This needs to be cacheline aligned because it is written to by *other* =
CPUs.  */
-static DEFINE_PER_CPU_SHARED_ALIGNED(u64, ipi_operation);
+static DEFINE_PER_CPU_SHARED_ALIGNED(unsigned long, ipi_operation);
=20
 extern void cpu_halt (void);
=20
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 1dcbb85..f5a50ea 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -873,7 +873,7 @@ init_smp_config(void)
 void __devinit
 identify_siblings(struct cpuinfo_ia64 *c)
 {
-	s64 status;
+	long status;
 	u16 pltid;
 	pal_logical_to_physical_t info;
=20
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 65c10a4..efb8866 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -373,7 +373,7 @@ ia64_init_itm (void)
=20
 static cycle_t itc_get_cycles(void)
 {
-	u64 lcycle, now, ret;
+	unsigned long lcycle, now, ret;
=20
 	if (!itc_jitter_data.itc_jitter)
 		return get_cycles();
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 26228e2..ace2282 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -304,10 +304,10 @@ static void __cpuinit cpu_cache_sysfs_exit(unsigned i=
nt cpu)
=20
 static int __cpuinit cpu_cache_sysfs_init(unsigned int cpu)
 {
-	u64 i, levels, unique_caches;
+	unsigned long i, levels, unique_caches;
 	pal_cache_config_info_t cci;
 	int j;
-	s64 status;
+	long status;
 	struct cache_info *this_cache;
 	int num_cache_leaves =3D 0;
=20
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 0ee085e..a6cce9d 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -229,8 +229,7 @@ find_memory (void)
 	alloc_per_cpu_data();
 }
=20
-static int
-count_pages (u64 start, u64 end, void *arg)
+static int count_pages(unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long *count =3D arg;
=20
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index f482a90..1710517 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -419,8 +419,8 @@ retry_pte:
 	return hole_next_pfn - pgdat->node_start_pfn;
 }
=20
-int __init
-create_mem_map_page_table (u64 start, u64 end, void *arg)
+int __init create_mem_map_page_table(unsigned long start, unsigned long en=
d,
+								void *arg)
 {
 	unsigned long address, start_page, end_page;
 	struct page *map_start, *map_end;
@@ -466,7 +466,7 @@ struct memmap_init_callback_data {
 };
=20
 static int __meminit
-virtual_memmap_init (u64 start, u64 end, void *arg)
+virtual_memmap_init(unsigned long start, unsigned long end, void *arg)
 {
 	struct memmap_init_callback_data *args;
 	struct page *map_start, *map_end;
@@ -528,8 +528,7 @@ ia64_pfn_valid (unsigned long pfn)
 }
 EXPORT_SYMBOL(ia64_pfn_valid);
=20
-int __init
-find_largest_hole (u64 start, u64 end, void *arg)
+int __init find_largest_hole(unsigned long start, unsigned long end, void =
*arg)
 {
 	u64 *max_gap =3D arg;
=20
@@ -545,8 +544,8 @@ find_largest_hole (u64 start, u64 end, void *arg)
=20
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
=20
-int __init
-register_active_ranges(u64 start, u64 len, int nid)
+int __init register_active_ranges(unsigned long start, unsigned long len,
+								int nid)
 {
 	u64 end =3D start + len;
=20
@@ -564,7 +563,7 @@ register_active_ranges(u64 start, u64 len, int nid)
 }
=20
 static int __init
-count_reserved_pages (u64 start, u64 end, void *arg)
+count_reserved_pages(unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long num_reserved =3D 0;
 	unsigned long *count =3D arg;
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 8caf424..6569b71 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -34,7 +34,7 @@
 #include <asm/tlb.h>
=20
 static struct {
-	unsigned long mask;	/* mask of supported purge page-sizes */
+	u64 mask;		/* mask of supported purge page-sizes */
 	unsigned long max_bits;	/* log2 of largest supported purge page-size */
 } purge;
=20
@@ -328,7 +328,7 @@ void __devinit
 ia64_tlb_init (void)
 {
 	ia64_ptce_info_t uninitialized_var(ptce_info); /* GCC be quiet */
-	unsigned long tr_pgbits;
+	u64 tr_pgbits;
 	long status;
 	pal_vm_info_1_u_t vm_info_1;
 	pal_vm_info_2_u_t vm_info_2;
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 7545037..9fe85a0 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -162,7 +162,7 @@ add_io_space (struct pci_root_info *info, struct acpi_r=
esource_address64 *addr)
 {
 	struct resource *resource;
 	char *name;
-	u64 base, min, max, base_port;
+	unsigned long base, min, max, base_port;
 	unsigned int sparse =3D 0, space_nr, len;
=20
 	resource =3D kzalloc(sizeof(*resource), GFP_KERNEL);
@@ -291,7 +291,7 @@ static __devinit acpi_status add_window(struct acpi_res=
ource *res, void *data)
 	window->offset =3D offset;
=20
 	if (insert_resource(root, &window->resource)) {
-		printk(KERN_ERR "alloc 0x%lx-0x%lx from %s for %s failed\n",
+		printk(KERN_ERR "alloc 0x%llx-0x%llx from %s for %s failed\n",
 			window->resource.start, window->resource.end,
 			root->name, info->name);
 	}
@@ -313,8 +313,8 @@ pcibios_setup_root_windows(struct pci_bus *bus, struct =
pci_controller *ctrl)
 		    (res->end - res->start < 16))
 			continue;
 		if (j >=3D PCI_BUS_NUM_RESOURCES) {
-			printk("Ignoring range [%lx-%lx] (%lx)\n", res->start,
-					res->end, res->flags);
+			printk("Ignoring range [%#llx-%#llx] (%lx)\n",
+					res->start, res->end, res->flags);
 			continue;
 		}
 		bus->resource[j++] =3D res;
@@ -722,8 +722,8 @@ extern u8 pci_cache_line_size;
  */
 static void __init set_pci_cacheline_size(void)
 {
-	u64 levels, unique_caches;
-	s64 status;
+	unsigned long levels, unique_caches;
+	long status;
 	pal_cache_config_info_t cci;
=20
 	status =3D ia64_pal_cache_summary(&levels, &unique_caches);
diff --git a/drivers/char/agp/hp-agp.c b/drivers/char/agp/hp-agp.c
index 183ac3f..9c7e234 100644
--- a/drivers/char/agp/hp-agp.c
+++ b/drivers/char/agp/hp-agp.c
@@ -518,8 +518,9 @@ zx1_gart_probe (acpi_handle obj, u32 depth, void *conte=
xt, void **ret)
 	if (hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa))
 		return AE_OK;
=20
-	printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset (ioc=3D%lx, lba=3D%l=
x)\n",
-		(char *) context, sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
+	printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset "
+		"(ioc=3D%llx, lba=3D%llx)\n", (char *)context,
+		sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
=20
 	hp_zx1_gart_found =3D 1;
 	return AE_CTRL_TERMINATE; /* we only support one bridge; quit looking */
diff --git a/drivers/firmware/pcdp.c b/drivers/firmware/pcdp.c
index 58e9f8e..51e0e2d 100644
--- a/drivers/firmware/pcdp.c
+++ b/drivers/firmware/pcdp.c
@@ -28,10 +28,10 @@ setup_serial_console(struct pcdp_uart *uart)
 	char parity;
=20
 	mmio =3D (uart->addr.space_id =3D ACPI_ADR_SPACE_SYSTEM_MEMORY);
-	p +=3D sprintf(p, "uart8250,%s,0x%lx",
+	p +=3D sprintf(p, "uart8250,%s,0x%llx",
 		mmio ? "mmio" : "io", uart->addr.address);
 	if (uart->baud) {
-		p +=3D sprintf(p, ",%lu", uart->baud);
+		p +=3D sprintf(p, ",%llu", uart->baud);
 		if (uart->bits) {
 			switch (uart->parity) {
 			    case 0x2: parity =3D 'e'; break;

--=20
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
