From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 26 Feb 2004 20:31:32 +0000
Subject: RE: HUGEPAGE SIZE a boottime option
Message-Id: <B05667366EE6204181EABE9C1B1C0EB501F2AB38@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> What about huge-page page-faults?  Before, HPAGE_SHIFT, HPAGE_SIZE,
> and HPAGE_MASK all were constant, now they have to be fetched from
> memory/recalculated each time. I suppose it's rare enough that it's
> not worth worrying about

Yeah, the penalty is paid at setup time, not runtime.


> did you verify that there is at least not anything really gross
> going on (like someone doing a modulo operation against HPAGE_SIZE)?

Just checked, doesn't look like any misuse for HPAGE_SIZE.


> How about replacing 0x8000000000000000 with (REGION_HPAGE <<
> REGION_SHIFT) or a manifest constant defined to this value (perhaps
> HUGETLB_REGION_ADDR)?

There is a similar TASK_HPAGE_BASE defined in hugetlbpage.c, I have
moved it into page.h and updated the patch.  Can't change the 0x800...
in reload_context because it would then need #if CONFIG_HUGETLB_PAGE.


> Why does the region register get initialized both in mm/init.c and
> hugetlb_setup_sz()?  Couldn't this be done once in hugetlb_init()?

The hpage_shift is stored in rr4.ps on each CPU, so on context
switch, we get current hpage_shfit from rr4 instead of memory
reference.  Since initialization needs to be done on all CPU,
mm/init.c is the logical place.  However, when BP executes
hugetlb_setup_sz, it already loaded rr4.ps with compile time
default (AP aren't online yet). In case we need to change the
size, rr4 on BP needs to be re-initialized.  Once all setup code
finishes, AP goes online and they load rr4.ps with the correct
value.  This should also cover hot-plug cpu pretty nicely.

(patch attached)
(p.s. I'm trying something new with mailer to include patch
      in the message body.  If my mailer screws up, please
      let me know.  I will resent.)


diff -Nurp linux-2.6.3/arch/ia64/Kconfig
linux-2.6.3.htlb/arch/ia64/Kconfig
--- linux-2.6.3/arch/ia64/Kconfig	2004-02-17 19:59:33.000000000
-0800
+++ linux-2.6.3.htlb/arch/ia64/Kconfig	2004-02-26 12:18:51.000000000
-0800
@@ -282,39 +282,6 @@ config FORCE_MAX_ZONEORDER
 	int
 	default "18"
 
-choice
-	prompt "Huge TLB page size"
-	depends on HUGETLB_PAGE
-	default HUGETLB_PAGE_SIZE_16MB
-
-config HUGETLB_PAGE_SIZE_4GB
-	depends on MCKINLEY
-	bool "4GB"
-
-config HUGETLB_PAGE_SIZE_1GB
-	depends on MCKINLEY
-	bool "1GB"
-
-config HUGETLB_PAGE_SIZE_256MB
-	bool "256MB"
-
-config HUGETLB_PAGE_SIZE_64MB
-	bool "64MB"
-
-config HUGETLB_PAGE_SIZE_16MB
-	bool "16MB"
-
-config HUGETLB_PAGE_SIZE_4MB
-	bool "4MB"
-
-config HUGETLB_PAGE_SIZE_1MB
-	bool "1MB"
-
-config HUGETLB_PAGE_SIZE_256KB
-	bool "256KB"
-
-endchoice
-
 config IA64_PAL_IDLE
 	bool "Use PAL_HALT_LIGHT in idle loop"
 	help
diff -Nurp linux-2.6.3/arch/ia64/kernel/ivt.S
linux-2.6.3.htlb/arch/ia64/kernel/ivt.S
--- linux-2.6.3/arch/ia64/kernel/ivt.S	2004-02-17 19:57:16.000000000
-0800
+++ linux-2.6.3.htlb/arch/ia64/kernel/ivt.S	2004-02-26
12:18:51.000000000 -0800
@@ -118,10 +118,11 @@ ENTRY(vhpt_miss)
 #ifdef CONFIG_HUGETLB_PAGE
 	extr.u r26=r25,2,6
 	;;
-	cmp.eq p8,p0=HPAGE_SHIFT,r26
+	cmp.ne p8,p0=r18,r26
+	sub r27=r26,r18
 	;;
 (p8)	dep r25=r18,r25,2,6
-(p8)	shr r22=r22,HPAGE_SHIFT-PAGE_SHIFT
+(p8)	shr r22=r22,r27
 #endif
 	;;
 	cmp.eq p6,p7=5,r17			// is IFA pointing into
to region 5?
diff -Nurp linux-2.6.3/arch/ia64/mm/hugetlbpage.c
linux-2.6.3.htlb/arch/ia64/mm/hugetlbpage.c
--- linux-2.6.3/arch/ia64/mm/hugetlbpage.c	2004-02-17
19:58:01.000000000 -0800
+++ linux-2.6.3.htlb/arch/ia64/mm/hugetlbpage.c	2004-02-26
12:18:51.000000000 -0800
@@ -1,7 +1,11 @@
 /*
  * IA-64 Huge TLB Page Support for Kernel.
  *
- * Copyright (C) 2002, Rohit Seth <rohit.seth@intel.com>
+ * Copyright (C) 2002-2004 Rohit Seth <rohit.seth@intel.com>
+ * Copyright (C) 2003-2004 Ken Chen <kenneth.w.chen@intel.com>
+ *
+ * Sep, 2003: add numa support
+ * Feb, 2004: dynamic hugetlb page size via boot parameter
  */
 
 #include <linux/config.h>
@@ -18,11 +22,10 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
-#define TASK_HPAGE_BASE (REGION_HPAGE << REGION_SHIFT)
-
 static long	htlbpagemem;
 int		htlbpage_max;
 static long	htlbzone_pages;
+unsigned int	hpage_shift=HPAGE_SHIFT_DEFAULT;
 
 static struct list_head hugepage_freelists[MAX_NUMNODES];
 static spinlock_t htlbpage_lock = SPIN_LOCK_UNLOCKED;
@@ -407,7 +410,7 @@ unsigned long hugetlb_get_unmapped_area(
 		return -EINVAL;
 	/* This code assumes that REGION_HPAGE != 0. */
 	if ((REGION_NUMBER(addr) != REGION_HPAGE) || (addr & (HPAGE_SIZE
- 1)))
-		addr = TASK_HPAGE_BASE;
+		addr = HPAGE_REGION_BASE;
 	else
 		addr = ALIGN(addr, HPAGE_SIZE);
 	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
@@ -520,6 +523,35 @@ static int __init hugetlb_setup(char *s)
 }
 __setup("hugepages=", hugetlb_setup);
 
+static int __init hugetlb_setup_sz(char *str)
+{
+	u64 tr_pages;
+	unsigned long long size;
+
+	if (ia64_pal_vm_page_size(&tr_pages, NULL) != 0)
+		/*
+		 * shouldn't happen, but just in case.
+		 */
+		tr_pages = 0x15557000UL;
+
+	size = memparse(str, &str);
+	if (*str || (size & (size-1)) || !(tr_pages & size) ||
+		size <= PAGE_SIZE ||
+		size >= (1UL << PAGE_SHIFT << MAX_ORDER)) {
+		printk(KERN_WARNING "Invalid huge page size
specified\n");
+		return 1;
+	}
+
+	hpage_shift = __ffs(size);
+	/*
+	 * boot cpu already executed ia64_mmu_init, and has
HPAGE_SHIFT_DEFAULT
+	 * override here with new page shift.
+	 */
+	ia64_set_rr(HPAGE_REGION_BASE, hpage_shift << 2);
+	return 1;
+}
+__setup("hugepagesz=", hugetlb_setup_sz);
+
 static int __init hugetlb_init(void)
 {
 	int i;
@@ -540,7 +572,7 @@ static int __init hugetlb_init(void)
 	printk("Total HugeTLB memory allocated, %ld\n", htlbpagemem);
 	return 0;
 }
-module_init(hugetlb_init);
+__initcall(hugetlb_init);
 
 int hugetlb_report_meminfo(char *buf)
 {
diff -Nurp linux-2.6.3/arch/ia64/mm/init.c
linux-2.6.3.htlb/arch/ia64/mm/init.c
--- linux-2.6.3/arch/ia64/mm/init.c	2004-02-17 19:57:39.000000000
-0800
+++ linux-2.6.3.htlb/arch/ia64/mm/init.c	2004-02-26
12:18:51.000000000 -0800
@@ -342,6 +342,10 @@ ia64_mmu_init (void *my_cpu_data)
 
 	ia64_tlb_init();
 
+#ifdef	CONFIG_HUGETLB_PAGE
+	ia64_set_rr(HPAGE_REGION_BASE, HPAGE_SHIFT << 2);
+#endif
+
 #ifdef	CONFIG_IA64_MCA
 	cpu = smp_processor_id();
 
diff -Nurp linux-2.6.3/include/asm-ia64/mmu_context.h
linux-2.6.3.htlb/include/asm-ia64/mmu_context.h
--- linux-2.6.3/include/asm-ia64/mmu_context.h	2004-02-17
19:57:16.000000000 -0800
+++ linux-2.6.3.htlb/include/asm-ia64/mmu_context.h	2004-02-26
12:18:51.000000000 -0800
@@ -140,8 +140,9 @@ reload_context (mm_context_t context)
 {
 	unsigned long rid;
 	unsigned long rid_incr = 0;
-	unsigned long rr0, rr1, rr2, rr3, rr4;
+	unsigned long rr0, rr1, rr2, rr3, rr4, old_rr4;
 
+	old_rr4 = ia64_get_rr(0x8000000000000000);
 	rid = context << 3;	/* make space for encoding the region
number */
 	rid_incr = 1 << 8;
 
@@ -152,7 +153,7 @@ reload_context (mm_context_t context)
 	rr3 = rr0 + 3*rid_incr;
 	rr4 = rr0 + 4*rid_incr;
 #ifdef  CONFIG_HUGETLB_PAGE
-	rr4 = (rr4 & (~(0xfcUL))) | (HPAGE_SHIFT << 2);
+	rr4 = (rr4 & (~(0xfcUL))) | (old_rr4 & 0xfc);
 #endif
 
 	ia64_set_rr(0x0000000000000000, rr0);
diff -Nurp linux-2.6.3/include/asm-ia64/page.h
linux-2.6.3.htlb/include/asm-ia64/page.h
--- linux-2.6.3/include/asm-ia64/page.h	2004-02-17 19:57:16.000000000
-0800
+++ linux-2.6.3.htlb/include/asm-ia64/page.h	2004-02-26
12:18:51.000000000 -0800
@@ -37,31 +37,14 @@
 #define RGN_MAP_LIMIT	((1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)
/* per region addr limit */
 
 #ifdef CONFIG_HUGETLB_PAGE
+# define REGION_HPAGE		(4UL)	/* note: this is hardcoded in
reload_context()!*/
+# define REGION_SHIFT		61
+# define HPAGE_REGION_BASE	(REGION_HPAGE << REGION_SHIFT)
+# define HPAGE_SHIFT		hpage_shift
+# define HPAGE_SHIFT_DEFAULT	28	/* check ia64 SDM for
architecture supported size */
+# define HPAGE_SIZE		(__IA64_UL_CONST(1) << HPAGE_SHIFT)
+# define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 
-# if defined(CONFIG_HUGETLB_PAGE_SIZE_4GB)
-#  define HPAGE_SHIFT	32
-# elif defined(CONFIG_HUGETLB_PAGE_SIZE_1GB)
-#  define HPAGE_SHIFT	30
-# elif defined(CONFIG_HUGETLB_PAGE_SIZE_256MB)
-#  define HPAGE_SHIFT	28
-# elif defined(CONFIG_HUGETLB_PAGE_SIZE_64MB)
-#  define HPAGE_SHIFT	26
-# elif defined(CONFIG_HUGETLB_PAGE_SIZE_16MB)
-#  define HPAGE_SHIFT	24
-# elif defined(CONFIG_HUGETLB_PAGE_SIZE_4MB)
-#  define HPAGE_SHIFT	22
-# elif defined(CONFIG_HUGETLB_PAGE_SIZE_1MB)
-#  define HPAGE_SHIFT	20
-# elif defined(CONFIG_HUGETLB_PAGE_SIZE_256KB)
-#  define HPAGE_SHIFT	18
-# else
-#  error Unsupported IA-64 HugeTLB Page Size!
-# endif
-
-# define REGION_HPAGE	(4UL)	/* note: this is hardcoded in
mmu_context.h:reload_context()!*/
-# define REGION_SHIFT	61
-# define HPAGE_SIZE	(__IA64_UL_CONST(1) << HPAGE_SHIFT)
-# define HPAGE_MASK	(~(HPAGE_SIZE - 1))
 # define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 # define ARCH_HAS_HUGEPAGE_ONLY_RANGE
 #endif /* CONFIG_HUGETLB_PAGE */
@@ -140,6 +123,7 @@ typedef union ia64_va {
 # define is_hugepage_only_range(addr, len)		\
 	 (REGION_NUMBER(addr) = REGION_HPAGE &&	\
 	  REGION_NUMBER((addr)+(len)) = REGION_HPAGE)
+extern unsigned int hpage_shift;
 #endif
 
 static __inline__ int
