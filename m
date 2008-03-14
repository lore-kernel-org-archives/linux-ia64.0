From: Fenghua Yu <fenghua.yu@intel.com>
Date: Fri, 14 Mar 2008 20:57:08 +0000
Subject: [PATCH] Kernel parameter for max number of concurrent global TLB purges
Message-Id: <20080314205708.GA30518@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The patch defines kernel parameter "nptcg=". The parameter overrides max number
of concurrent global TLB purges which is reported from either PAL_VM_SUMMARY or
SAL PALO.

This patch is on the top of patch sent before:

http://www.gelato.unsw.edu.au/archives/linux-ia64/0801/21684.html

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---

 Documentation/kernel-parameters.txt |    4 +++
 arch/ia64/kernel/efi.c              |    2 -
 arch/ia64/kernel/setup.c            |    2 -
 arch/ia64/mm/tlb.c                  |   46 ++++++++++++++++++++++++++++++++----
 include/asm-ia64/sal.h              |    4 +++
 5 files changed, 51 insertions(+), 7 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 533e67f..3477a8b 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1337,6 +1337,10 @@ and is between 256 and 4096 characters. It is defined in the file
 
 	nowb		[ARM]
 
+	nptcg=		[IA64] Override max number of concurrent global TLB
+			purges which is reported from either PAL_VM_SUMMARY or
+			SAL PALO.
+
 	numa_zonelist_order= [KNL, BOOT] Select zonelist order for NUMA.
 			one of ['zone', 'node', 'default'] can be specified
 			This can be set from sysctl after boot.
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 003cd09..d45f215 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -436,7 +436,7 @@ static void __init handle_palo(unsigned long palo_phys)
 		return;
 	}
 
-	setup_ptcg_sem(palo->max_tlb_purges, 1);
+	setup_ptcg_sem(palo->max_tlb_purges, NPTCG_FROM_PALO);
 }
 
 void
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 1cbd263..f798c07 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -949,7 +949,7 @@ cpu_init (void)
 	/* set ia64_ctx.max_rid to the maximum RID that is supported by all CPUs: */
 	if (ia64_pal_vm_summary(NULL, &vmi) = 0) {
 		max_ctx = (1U << (vmi.pal_vm_info_2_s.rid_size - 3)) - 1;
-		setup_ptcg_sem(vmi.pal_vm_info_2_s.max_purges, 0);
+		setup_ptcg_sem(vmi.pal_vm_info_2_s.max_purges, NPTCG_FROM_PAL);
 	} else {
 		printk(KERN_WARNING "cpu_init: PAL VM summary failed, assuming 18 RID bits\n");
 		max_ctx = (1U << 15) - 1;	/* use architected minimum */
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 78767e5..2bafe7f 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -94,19 +94,45 @@ static int need_ptcg_sem = 1;
 static int toolatetochangeptcgsem = 0;
 
 /*
+ * Kernel parameter "nptcg=" overrides max number of concurrent global TLB
+ * purges which is reported from either PAL or SAL PALO.
+ *
+ * We don't have sanity checking for nptcg value. It's the user's responsibility
+ * for valid nptcg value on the platform. Otherwise, kernel may hang in some
+ * cases.
+ */
+static int __init
+set_nptcg(char *str)
+{
+	int value = 0;
+
+	get_option(&str, &value);
+	setup_ptcg_sem(value, NPTCG_FROM_KERNEL_PARAMETER);
+
+	return 1;
+}
+
+__setup("nptcg=", set_nptcg);
+
+/*
  * Maximum number of simultaneous ptc.g purges in the system can
  * be defined by PAL_VM_SUMMARY (in which case we should take
  * the smallest value for any cpu in the system) or by the PAL
  * override table (in which case we should ignore the value from
  * PAL_VM_SUMMARY).
  *
+ * Kernel parameter "nptcg=" overrides maximum number of simultanesous ptc.g
+ * purges defined in either PAL_VM_SUMMARY or PAL override table. In this case,
+ * we should ignore the value from either PAL_VM_SUMMARY or PAL override table.
+ *
  * Complicating the logic here is the fact that num_possible_cpus()
  * isn't fully setup until we start bringing cpus online.
  */
 void
-setup_ptcg_sem(int max_purges, int from_palo)
+setup_ptcg_sem(int max_purges, int nptcg_from)
 {
-	static int have_palo;
+	static int kp_override;
+	static int palo_override;
 	static int firstcpu = 1;
 
 	if (toolatetochangeptcgsem) {
@@ -114,8 +140,18 @@ setup_ptcg_sem(int max_purges, int from_palo)
 		return;
 	}
 
-	if (from_palo) {
-		have_palo = 1;
+	if (nptcg_from = NPTCG_FROM_KERNEL_PARAMETER) {
+		kp_override = 1;
+		nptcg = max_purges;
+		goto resetsema;
+	}
+	if (kp_override) {
+		need_ptcg_sem = num_possible_cpus() > nptcg;
+		return;
+	}
+
+	if (nptcg_from = NPTCG_FROM_PALO) {
+		palo_override = 1;
 
 		/* In PALO max_purges = 0 really means it! */
 		if (max_purges = 0)
@@ -127,7 +163,7 @@ setup_ptcg_sem(int max_purges, int from_palo)
 		}
 		goto resetsema;
 	}
-	if (have_palo) {
+	if (palo_override) {
 		if (nptcg != PALO_MAX_TLB_PURGES)
 			need_ptcg_sem = (num_possible_cpus() > nptcg);
 		return;
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 3cd637a..89594b4 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -896,6 +896,10 @@ struct palo_table {
 	u8  reserved2[6];
 };
 
+#define NPTCG_FROM_PAL			0
+#define NPTCG_FROM_PALO			1
+#define NPTCG_FROM_KERNEL_PARAMETER	2
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_IA64_SAL_H */
