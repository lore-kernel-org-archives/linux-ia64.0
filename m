From: Jack Steiner <steiner@sgi.com>
Date: Fri, 20 Feb 2004 01:07:31 +0000
Subject: HUGEPAGE SIZE a boottime option
Message-Id: <20040220010731.GA28820@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Here is a preliminary version of a patch that makes the size of
HUGEPAGES a boottime option. Only ia64-specific files are changed (except
for the Documentation file).

We have a number of customers using large pages. Unfortunately, 
the "optimum" size of a large page is application & configuration
dependent. Rather that having each customer recompile to specify their
own HUGEPAGESIZE, this patch make the size a boottime option.


Does this patch look reasonable? If so, I will incorporate feedback,
finish testing it, update it to 2.6.3 & resubmit.

-------------------------------------------------------------------------

Based on 2.6.2-mm.

--- linux.base/Documentation/vm/hugetlbpage.txt	Tue Feb  3 21:43:11 2004
+++ linux/Documentation/vm/hugetlbpage.txt	Thu Feb 19 16:17:16 2004
@@ -63,6 +63,22 @@
 kernel to request huge pages early in the boot process (when the possibility
 of getting physical contiguous pages is still very high).
 
+Another option is to add the following boot command line option:
+
+	hugepages=xxxx
+
+The value xxxx specifies the number of hugepages that should be reserved
+at boot time.                                                          
+
+Some architectures (ia64) support an additional boot line option to specify
+the hugepage size at boot time. If this option is not specified, the hugepage 
+size defaults to the value specified in the .config file.
+
+	hugepagesz=xxxx                                                                                                            
+
+The value of xxxx is any valid pagesize (256k, ... 256m, etc).
+
+
 If the user applications are going to request hugepages using mmap system
 call, then it is required that system administrator mount a file system of
 type hugetlbfs:


--- linux.base/arch/ia64/kernel/ivt.S	Tue Feb  3 21:43:15 2004
+++ linux/arch/ia64/kernel/ivt.S	Thu Feb 19 16:10:01 2004
@@ -118,10 +118,8 @@
 #ifdef CONFIG_HUGETLB_PAGE
 	extr.u r26=r25,2,6
 	;;
-	cmp.eq p8,p0=HPAGE_SHIFT,r26
-	;;
+	UPDATE_HPAGE_REGISTERS(p8, r26, r22)	// if hugepage, set p8 & update pte index
 (p8)	dep r25=r18,r25,2,6
-(p8)	shr r22=r22,HPAGE_SHIFT-PAGE_SHIFT
 #endif
 	;;
 	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?


--- linux.base/arch/ia64/kernel/patch.c	Tue Feb  3 21:44:04 2004
+++ linux/arch/ia64/kernel/patch.c	Thu Feb 19 15:39:02 2004
@@ -107,6 +107,24 @@
 	ia64_srlz_i();
 }
 
+/*
+ * Patch the vhpt_miss handler with the actual size of huge pages.
+ */
+void __init
+ia64_patch_hugepage(unsigned long addr, long hpageshift)
+{
+	s32 *offp = (s32 *) addr;
+	u64 ip;
+	
+	ip = (u64) offp + *offp;
+	ia64_patch(ip, 0x000fe000UL, hpageshift << 13);
+	ia64_patch(ip+2, 0xfc0fc000UL, ((64-hpageshift+PAGE_SHIFT-1) << 27) 
+		| ((hpageshift-PAGE_SHIFT) << 14));
+
+	ia64_sync_i();
+	ia64_srlz_i();
+}
+
 void
 ia64_patch_mckinley_e9 (unsigned long start, unsigned long end)
 {


--- linux.base/arch/ia64/kernel/vmlinux.lds.S	Tue Feb  3 21:44:27 2004
+++ linux/arch/ia64/kernel/vmlinux.lds.S	Thu Feb 19 09:01:31 2004
@@ -56,6 +56,13 @@
 	  __stop___ex_table = .;
 	}
 
+  .data.patch.hugepage : AT(ADDR(.data.patch.hugepage) - LOAD_OFFSET)
+	{
+	  __start___hugepage_patchlist = .;
+	  *(.data.patch.hugepage)
+	  __end___hugepage_patchlist = .;
+	}
+
   .data.patch.vtop : AT(ADDR(.data.patch.vtop) - LOAD_OFFSET)
 	{
 	  __start___vtop_patchlist = .;


--- linux.base/arch/ia64/mm/hugetlbpage.c	Tue Feb  3 21:43:49 2004
+++ linux/arch/ia64/mm/hugetlbpage.c	Thu Feb 19 12:25:51 2004
@@ -13,16 +13,20 @@
 #include <linux/smp_lock.h>
 #include <linux/slab.h>
 #include <linux/sysctl.h>
+#include <linux/module.h>
 #include <asm/mman.h>
 #include <asm/pgalloc.h>
+#include <asm/pal.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
+#include <asm/sections.h>
 
 #define TASK_HPAGE_BASE (REGION_HPAGE << REGION_SHIFT)
 
 static long	htlbpagemem;
 int		htlbpage_max;
 static long	htlbzone_pages;
+int 		hpage_shift=HPAGE_SHIFT_DEFAULT;
 
 static struct list_head hugepage_freelists[MAX_NUMNODES];
 static spinlock_t htlbpage_lock = SPIN_LOCK_UNLOCKED;
@@ -520,6 +524,35 @@
 }
 __setup("hugepages=", hugetlb_setup);
 
+static int __init hugetlb_setup_sz(char *s)
+{
+	long long size;
+	u64 tr_pages;
+	long pageshift;
+	char *rest;
+	extern void ia64_patch_hugepage(unsigned long, long);
+
+	if (ia64_pal_vm_page_size(&tr_pages, 0) !=0)
+		return 1;
+	size = memparse(s, &rest);
+	if (*rest || (size & (size-1)))
+		goto bad;
+
+	pageshift = __ffs(size);
+	if (!(tr_pages & (1UL<<pageshift)))
+		goto bad;
+
+	hpage_shift = pageshift;
+	ia64_patch_hugepage((u64)__start___hugepage_patchlist, pageshift);
+	return 1;
+
+
+bad:
+	printk(KERN_WARNING "%s is not a valid huge page size\n", s);
+	return 1;
+}
+__setup("hugepagesz=", hugetlb_setup_sz);
+
 static int __init hugetlb_init(void)
 {
 	int i;
@@ -537,7 +570,7 @@
 		spin_unlock(&htlbpage_lock);
 	}
 	htlbpage_max = htlbpagemem = htlbzone_pages = i;
-	printk("Total HugeTLB memory allocated, %ld\n", htlbpagemem);
+	printk("Total HugeTLB memory allocated %ld pages, pagesize %ldkB\n", htlbpagemem, (1UL<<(hpage_shift-10)));
 	return 0;
 }
 module_init(hugetlb_init);


--- linux.base/include/asm-ia64/asmmacro.h	Tue Feb  3 21:43:19 2004
+++ linux/include/asm-ia64/asmmacro.h	Thu Feb 19 16:11:11 2004
@@ -64,6 +64,25 @@
 	.xdata4 ".data.patch.vtop", 1b-.
 
 /*
+ * If faulted pagesize is a HUGE page, shift pte index by
+ * the difference in base pagesize & hugepagesize.
+ * 	pr - predicate register to set TRUE if huge page
+ * 	ps - register that holds faulted pagesize
+ * 	idx - pte index
+ */
+	.section ".data.patch.hugepage", "a"	// declare section & section attributes
+	.previous
+
+#define UPDATE_HPAGE_REGISTERS(pr, ps, idx)	\
+[1:]{ .mmi;					\
+     cmp.eq pr,p0=HPAGE_SHIFT_DEFAULT,ps;;	\
+     nop.m 0;					\
+(pr) shr idx=idx,HPAGE_SHIFT_DEFAULT-PAGE_SHIFT;\
+};						\
+	.xdata4 ".data.patch.hugepage", 1b-.
+
+
+/*
  * For now, we always put in the McKinley E9 workaround.  On CPUs that don't need it,
  * we'll patch out the work-around bundles with NOPs, so their impact is minimal.
  */


--- linux.base/include/asm-ia64/page.h	Tue Feb  3 21:43:11 2004
+++ linux/include/asm-ia64/page.h	Wed Feb 18 16:21:58 2004
@@ -39,24 +39,25 @@
 #ifdef CONFIG_HUGETLB_PAGE
 
 # if defined(CONFIG_HUGETLB_PAGE_SIZE_4GB)
-#  define HPAGE_SHIFT	32
+#  define HPAGE_SHIFT_DEFAULT	32
 # elif defined(CONFIG_HUGETLB_PAGE_SIZE_1GB)
-#  define HPAGE_SHIFT	30
+#  define HPAGE_SHIFT_DEFAULT	30
 # elif defined(CONFIG_HUGETLB_PAGE_SIZE_256MB)
-#  define HPAGE_SHIFT	28
+#  define HPAGE_SHIFT_DEFAULT	28
 # elif defined(CONFIG_HUGETLB_PAGE_SIZE_64MB)
-#  define HPAGE_SHIFT	26
+#  define HPAGE_SHIFT_DEFAULT	26
 # elif defined(CONFIG_HUGETLB_PAGE_SIZE_16MB)
-#  define HPAGE_SHIFT	24
+#  define HPAGE_SHIFT_DEFAULT	24
 # elif defined(CONFIG_HUGETLB_PAGE_SIZE_4MB)
-#  define HPAGE_SHIFT	22
+#  define HPAGE_SHIFT_DEFAULT	22
 # elif defined(CONFIG_HUGETLB_PAGE_SIZE_1MB)
-#  define HPAGE_SHIFT	20
+#  define HPAGE_SHIFT_DEFAULT	20
 # elif defined(CONFIG_HUGETLB_PAGE_SIZE_256KB)
-#  define HPAGE_SHIFT	18
+#  define HPAGE_SHIFT_DEFAULT	18
 # else
 #  error Unsupported IA-64 HugeTLB Page Size!
 # endif
+#define HPAGE_SHIFT hpage_shift
 
 # define REGION_HPAGE	(4UL)	/* note: this is hardcoded in mmu_context.h:reload_context()!*/
 # define REGION_SHIFT	61
@@ -75,6 +76,7 @@
 
 extern void clear_page (void *page);
 extern void copy_page (void *to, void *from);
+extern int hpage_shift;
 
 /*
  * clear_user_page() and copy_user_page() can't be inline functions because


--- linux.base/include/asm-ia64/sections.h	Tue Feb  3 21:43:47 2004
+++ linux/include/asm-ia64/sections.h	Thu Feb 19 12:22:19 2004
@@ -10,6 +10,7 @@
 
 extern char __per_cpu_start[], __per_cpu_end[], __phys_per_cpu_start[];
 extern char __start___vtop_patchlist[], __end___vtop_patchlist[];
+extern char __start___hugepage_patchlist[], __end___hugepage_patchlist[];
 extern char __start___mckinley_e9_bundles[], __end___mckinley_e9_bundles[];
 extern char __start_gate_section[];
 extern char __start_gate_mckinley_e9_patchlist[], __end_gate_mckinley_e9_patchlist[];
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


