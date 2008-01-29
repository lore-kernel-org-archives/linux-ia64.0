From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 29 Jan 2008 23:49:20 +0000
Subject: [PATCH] Multiple outstanding ptc.g instructions support
Message-Id: <20080129234920.GA21517@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


According to SDM2.2, Itanium supports multiple outstanding ptc.g instructions.
But current kernel function ia64_global_tlb_purge() uses a spinlock to serialize
ptc.g instructions issued by multiple processors. This serialization might have
scalability issue on a big SMP machine where many processors could purge TLB
in parallel.

The patch fixes this problem by issuing multiple ptc.g instructions in
ia64_global_tlb_purge(). It queries PALO table to get max number of outstanding
ptc.g instructions. PALO specification can be found at: 
http://www.dig64.org/home/DIG64_PALO_R1_0.pdf

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---

 arch/ia64/kernel/efi.c     |   61 +++++++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/palinfo.c |   21 +++++++++++----
 arch/ia64/mm/tlb.c         |   44 +++++++++++++++++++++-----------
 include/asm-ia64/sal.h     |   21 +++++++++++++++
 4 files changed, 126 insertions(+), 21 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 242d793..bdb079a 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -388,6 +388,58 @@ efi_get_pal_addr (void)
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
+static int __init handle_palo(unsigned long palo_phys)
+{
+	struct palo_table *tmp;
+	u8  checksum;
+
+	if (palo_phys = EFI_INVALID_TABLE_ADDR) {
+		printk(KERN_INFO "PALO not found.\n");
+		nptcg = 1;
+		goto exit_nptcg;
+	}
+
+	tmp = (struct palo_table *)__va(palo_phys);
+	if (strncmp(tmp->signature, PALO_SIG, sizeof(PALO_SIG) - 1)) {
+		printk(KERN_INFO "PALO signature incorrect.\n");
+		nptcg = 1;
+		goto exit_nptcg;
+	}
+
+	checksum = palo_checksum((u8 *)tmp, tmp->length);
+	if (checksum) {
+		printk(KERN_INFO "PALO checksum incorrect.\n");
+		nptcg = 1;
+		goto exit_nptcg;
+	}
+
+	/* When getting to here, palo points to a valid PALO table. */
+	palo = tmp;
+	nptcg = palo->max_tlb_purges;
+	if (nptcg = 0)
+		panic("Woah! Don't support global TLB purges.\n");
+
+exit_nptcg:
+	sema_init(&ptcg_sem, nptcg);
+	return nptcg;
+}
+
 void
 efi_map_pal_code (void)
 {
@@ -417,6 +469,7 @@ efi_init (void)
 	u64 efi_desc_size;
 	char *cp, vendor[100] = "unknown";
 	int i;
+	unsigned long palo_phys;
 
 	/* it's too early to be able to use the standard kernel command line support... */
 	for (cp = boot_command_line; *cp; ) {
@@ -475,6 +528,8 @@ efi_init (void)
 	efi.hcdp       = EFI_INVALID_TABLE_ADDR;
 	efi.uga        = EFI_INVALID_TABLE_ADDR;
 
+	palo_phys      = EFI_INVALID_TABLE_ADDR;
+
 	for (i = 0; i < (int) efi.systab->nr_tables; i++) {
 		if (efi_guidcmp(config_tables[i].guid, MPS_TABLE_GUID) = 0) {
 			efi.mps = config_tables[i].table;
@@ -494,10 +549,16 @@ efi_init (void)
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
 
+	handle_palo(palo_phys);
+
 	runtime = __va(efi.systab->runtime);
 	efi.get_time = phys_get_time;
 	efi.set_time = phys_set_time;
diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index 396004e..6fe8570 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -323,12 +323,21 @@ vm_info(char *page)
 		     vm_info_1.pal_vm_info_1_s.key_size,
 		     vm_info_1.pal_vm_info_1_s.hash_tag_id,
 		     vm_info_2.pal_vm_info_2_s.rid_size);
-		if (vm_info_2.pal_vm_info_2_s.max_purges = PAL_MAX_PURGES)
-			p += sprintf(p, "unlimited\n");
-		else
-			p += sprintf(p, "%d\n",
-		     		vm_info_2.pal_vm_info_2_s.max_purges ?
-				vm_info_2.pal_vm_info_2_s.max_purges : 1);
+		if (!palo) {
+			if (vm_info_2.pal_vm_info_2_s.max_purges
+				 = PAL_MAX_PURGES)
+				p += sprintf(p, "unlimited\n");
+			else
+				p += sprintf(p, "%d\n",
+					vm_info_2.pal_vm_info_2_s.max_purges ?
+					vm_info_2.pal_vm_info_2_s.max_purges:1);
+		} else {
+			if (palo->max_tlb_purges = PALO_MAX_TLB_PURGES)
+				p += sprintf(p, "unlimited\n");
+			else
+				p += sprintf(p, "%d\n",
+					palo->max_tlb_purges);
+		}
 	}
 
 	if (ia64_pal_mem_attrib(&attrib) = 0) {
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 655da24..e3935d3 100644
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
@@ -84,12 +88,15 @@ wrap_mmu_context (struct mm_struct *mm)
 	local_flush_tlb_all();
 }
 
+struct palo_table *palo;
+struct semaphore ptcg_sem;
+u16 nptcg = 1;
+
 void
 ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
 		       unsigned long end, unsigned long nbits)
 {
-	static DEFINE_SPINLOCK(ptcg_lock);
-
+	int do_ptcg_sem;
 	struct mm_struct *active_mm = current->active_mm;
 
 	if (mm != active_mm) {
@@ -102,19 +109,26 @@ ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
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
+	/*
+	 * If unlimited outstanding ptc.g (nptcg=0xffff), it's unnecessary to
+	 * serialize ptc.g instructions.
+	 */
+	do_ptcg_sem = nptcg = PALO_MAX_TLB_PURGES ? 0 : 1;
+	if (do_ptcg_sem)
+		/* This might put the process into sleep. */
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
+	if (do_ptcg_sem)
+		up(&ptcg_sem);
 
         if (mm != active_mm) {
                 activate_context(active_mm);
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 1f5412d..ad63ac7 100644
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
@@ -883,6 +886,24 @@ extern void ia64_jump_to_sal(struct sal_to_os_boot *);
 
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
+extern struct palo_table *palo;
+extern struct semaphore ptcg_sem;
+extern u16 nptcg;
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_IA64_SAL_H */
