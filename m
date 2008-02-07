From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Feb 2008 21:34:50 +0000
Subject: RE: [PATCH] Multiple outstanding ptc.g instructions support
Message-Id: <1FE6DD409037234FAB833C420AA843EC8823A9@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I made a few changes to this:

1) Updated w.r.t. latest kernel (mostly due to cleanups in efi.c)
2) Dropped the palinfo.c piece that provided the PALO values for
   number of purges.  I think that /proc/pal/cpu*/* should just
   return the values that PAL provides.  If we need to provide an
   API to get at the PALO values, then a new interface is needed
   (/proc/pal/palo perhaps?)
3) Removed some global variables.
4) Added code to act on max_purge values found from PAL_VM_SUMMARY.
   This got a bit messy.  See setup_ptcg_sem() in arch/ia64/mm/tlb.c,
   suggestions on how to make this simpler gratefully received.

-Tony

---

commit bf454b2d048f7fd27cb834af87806c85a760d60c
Author: Fenghua Yu <fenghua.yu@intel.com>
Date:   Thu Feb 7 12:59:04 2008 -0800

    [IA64] Multiple outstanding ptc.g instruction support
    
    According to SDM2.2, Itanium supports multiple outstanding ptc.g instructions.
    But current kernel function ia64_global_tlb_purge() uses a spinlock to serialize
    ptc.g instructions issued by multiple processors. This serialization might have
    scalability issue on a big SMP machine where many processors could purge TLB
    in parallel.
    
    The patch fixes this problem by issuing multiple ptc.g instructions in
    ia64_global_tlb_purge(). It also adds support for the "PALO" table to get
    a platform view of the max number of outstanding ptc.g instructions (which
    may be different from the processor view found from PAL_VM_SUMMARY).
    
    PALO specification can be found at: http://www.dig64.org/home/DIG64_PALO_R1_0.pdf
    
    Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 919070a..5ce6523 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -37,6 +37,7 @@
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/mca.h>
+#include <asm/tlbflush.h>
 
 #define EFI_DEBUG	0
 
@@ -403,6 +404,41 @@ efi_get_pal_addr (void)
 	return NULL;
 }
 
+
+static u8 __init palo_checksum(u8 *buffer, u32 length)
+{
+	u8 sum = 0;
+	u8 *end = buffer + length;
+
+	while (buffer < end)
+		sum = (u8) (sum + *(buffer++));
+
+	return sum;
+}
+
+/*
+ * Parse and handle PALO table which is published at:
+ * http://www.dig64.org/home/DIG64_PALO_R1_0.pdf
+ */
+static void __init handle_palo(unsigned long palo_phys)
+{
+	struct palo_table *palo = __va(palo_phys);
+	u8  checksum;
+
+	if (strncmp(palo->signature, PALO_SIG, sizeof(PALO_SIG) - 1)) {
+		printk(KERN_INFO "PALO signature incorrect.\n");
+		return;
+	}
+
+	checksum = palo_checksum((u8 *)palo, palo->length);
+	if (checksum) {
+		printk(KERN_INFO "PALO checksum incorrect.\n");
+		return;
+	}
+
+	setup_ptcg_sem(palo->max_tlb_purges, 1);
+}
+
 void
 efi_map_pal_code (void)
 {
@@ -432,6 +468,7 @@ efi_init (void)
 	u64 efi_desc_size;
 	char *cp, vendor[100] = "unknown";
 	int i;
+	unsigned long palo_phys;
 
 	/*
 	 * It's too early to be able to use the standard kernel command line
@@ -496,6 +533,8 @@ efi_init (void)
 	efi.hcdp       = EFI_INVALID_TABLE_ADDR;
 	efi.uga        = EFI_INVALID_TABLE_ADDR;
 
+	palo_phys      = EFI_INVALID_TABLE_ADDR;
+
 	for (i = 0; i < (int) efi.systab->nr_tables; i++) {
 		if (efi_guidcmp(config_tables[i].guid, MPS_TABLE_GUID) = 0) {
 			efi.mps = config_tables[i].table;
@@ -515,10 +554,17 @@ efi_init (void)
 		} else if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) = 0) {
 			efi.hcdp = config_tables[i].table;
 			printk(" HCDP=0x%lx", config_tables[i].table);
+		} else if (efi_guidcmp(config_tables[i].guid,
+			 PROCESSOR_ABSTRACTION_LAYER_OVERWRITE_GUID) = 0) {
+			palo_phys = config_tables[i].table;
+			printk(" PALO=0x%lx", config_tables[i].table);
 		}
 	}
 	printk("\n");
 
+	if (palo_phys != EFI_INVALID_TABLE_ADDR)
+		handle_palo(palo_phys);
+
 	runtime = __va(efi.systab->runtime);
 	efi.get_time = phys_get_time;
 	efi.set_time = phys_set_time;
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index ebd1a09..93ce69d 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -59,6 +59,7 @@
 #include <asm/setup.h>
 #include <asm/smp.h>
 #include <asm/system.h>
+#include <asm/tlbflush.h>
 #include <asm/unistd.h>
 #include <asm/hpsim.h>
 
@@ -946,9 +947,10 @@ cpu_init (void)
 #endif
 
 	/* set ia64_ctx.max_rid to the maximum RID that is supported by all CPUs: */
-	if (ia64_pal_vm_summary(NULL, &vmi) = 0)
+	if (ia64_pal_vm_summary(NULL, &vmi) = 0) {
 		max_ctx = (1U << (vmi.pal_vm_info_2_s.rid_size - 3)) - 1;
-	else {
+		setup_ptcg_sem(vmi.pal_vm_info_2_s.max_purges, 0);
+	} else {
 		printk(KERN_WARNING "cpu_init: PAL VM summary failed, assuming 18 RID bits\n");
 		max_ctx = (1U << 15) - 1;	/* use architected minimum */
 	}
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 655da24..78767e5 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -11,6 +11,9 @@
  * Rohit Seth <rohit.seth@intel.com>
  * Ken Chen <kenneth.w.chen@intel.com>
  * Christophe de Dinechin <ddd@hp.com>: Avoid ptc.e on memory allocation
+ * Copyright (C) 2007 Intel Corp
+ *	Fenghua Yu <fenghua.yu@intel.com>
+ *	Add multiple ptc.g/ptc.ga instruction support in global tlb purge.
  */
 #include <linux/module.h>
 #include <linux/init.h>
@@ -26,6 +29,7 @@
 #include <asm/pal.h>
 #include <asm/tlbflush.h>
 #include <asm/dma.h>
+#include <asm/sal.h>
 
 static struct {
 	unsigned long mask;	/* mask of supported purge page-sizes */
@@ -84,14 +88,78 @@ wrap_mmu_context (struct mm_struct *mm)
 	local_flush_tlb_all();
 }
 
+static __DECLARE_SEMAPHORE_GENERIC(ptcg_sem, 1);
+static u16 nptcg = 1;
+static int need_ptcg_sem = 1;
+static int toolatetochangeptcgsem = 0;
+
+/*
+ * Maximum number of simultaneous ptc.g purges in the system can
+ * be defined by PAL_VM_SUMMARY (in which case we should take
+ * the smallest value for any cpu in the system) or by the PAL
+ * override table (in which case we should ignore the value from
+ * PAL_VM_SUMMARY).
+ *
+ * Complicating the logic here is the fact that num_possible_cpus()
+ * isn't fully setup until we start bringing cpus online.
+ */
+void
+setup_ptcg_sem(int max_purges, int from_palo)
+{
+	static int have_palo;
+	static int firstcpu = 1;
+
+	if (toolatetochangeptcgsem) {
+		BUG_ON(max_purges < nptcg);
+		return;
+	}
+
+	if (from_palo) {
+		have_palo = 1;
+
+		/* In PALO max_purges = 0 really means it! */
+		if (max_purges = 0)
+			panic("Whoa! Platform does not support global TLB purges.\n");
+		nptcg = max_purges;
+		if (nptcg = PALO_MAX_TLB_PURGES) {
+			need_ptcg_sem = 0;
+			return;
+		}
+		goto resetsema;
+	}
+	if (have_palo) {
+		if (nptcg != PALO_MAX_TLB_PURGES)
+			need_ptcg_sem = (num_possible_cpus() > nptcg);
+		return;
+	}
+
+	/* In PAL_VM_SUMMARY max_purges = 0 actually means 1 */
+	if (max_purges = 0) max_purges = 1;
+
+	if (firstcpu) {
+		nptcg = max_purges;
+		firstcpu = 0;
+	}
+	if (max_purges < nptcg)
+		nptcg = max_purges;
+	if (nptcg = PAL_MAX_PURGES) {
+		need_ptcg_sem = 0;
+		return;
+	} else
+		need_ptcg_sem = (num_possible_cpus() > nptcg);
+
+resetsema:
+	sema_init(&ptcg_sem, max_purges);
+}
+
 void
 ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
 		       unsigned long end, unsigned long nbits)
 {
-	static DEFINE_SPINLOCK(ptcg_lock);
-
 	struct mm_struct *active_mm = current->active_mm;
 
+	toolatetochangeptcgsem = 1;
+
 	if (mm != active_mm) {
 		/* Restore region IDs for mm */
 		if (mm && active_mm) {
@@ -102,19 +170,20 @@ ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
 		}
 	}
 
-	/* HW requires global serialization of ptc.ga.  */
-	spin_lock(&ptcg_lock);
-	{
-		do {
-			/*
-			 * Flush ALAT entries also.
-			 */
-			ia64_ptcga(start, (nbits<<2));
-			ia64_srlz_i();
-			start += (1UL << nbits);
-		} while (start < end);
-	}
-	spin_unlock(&ptcg_lock);
+	if (need_ptcg_sem)
+		down(&ptcg_sem);
+
+	do {
+		/*
+		 * Flush ALAT entries also.
+		 */
+		ia64_ptcga(start, (nbits << 2));
+		ia64_srlz_i();
+		start += (1UL << nbits);
+	} while (start < end);
+
+	if (need_ptcg_sem)
+		up(&ptcg_sem);
 
         if (mm != active_mm) {
                 activate_context(active_mm);
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 2251118..7bf168a 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -296,6 +296,9 @@ enum {
     EFI_GUID(0xe429faf8, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81)
 #define SAL_PLAT_BUS_ERR_SECT_GUID  \
     EFI_GUID(0xe429faf9, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81)
+#define PROCESSOR_ABSTRACTION_LAYER_OVERWRITE_GUID \
+    EFI_GUID(0x6cb0a200, 0x893a, 0x11da, 0x96, 0xd2, 0x0, 0x10, 0x83, 0xff, \
+		0xca, 0x4d)
 
 #define MAX_CACHE_ERRORS	6
 #define MAX_TLB_ERRORS		6
@@ -875,6 +878,20 @@ extern void ia64_jump_to_sal(struct sal_to_os_boot *);
 
 extern void ia64_sal_handler_init(void *entry_point, void *gpval);
 
+#define PALO_MAX_TLB_PURGES	0xFFFF
+#define PALO_SIG	"PALO"
+
+struct palo_table {
+	u8  signature[4];	/* Should be "PALO" */
+	u32 length;
+	u8  minor_revision;
+	u8  major_revision;
+	u8  checksum;
+	u8  reserved1[5];
+	u16 max_tlb_purges;
+	u8  reserved2[6];
+};
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_IA64_SAL_H */
diff --git a/include/asm-ia64/tlbflush.h b/include/asm-ia64/tlbflush.h
index 7774a1c..3be25df 100644
--- a/include/asm-ia64/tlbflush.h
+++ b/include/asm-ia64/tlbflush.h
@@ -17,6 +17,7 @@
  * Now for some TLB flushing routines.  This is the kind of stuff that
  * can be very expensive, so try to avoid them whenever possible.
  */
+extern void setup_ptcg_sem(int max_purges, int from_palo);
 
 /*
  * Flush everything (kernel mapping may also have changed due to

