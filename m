From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Mar 2006 22:02:25 +0000
Subject: PATCH[2/4] - Increase max node count on SN platforms
Message-Id: <20060302220224.GA17134@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add support in IA64 acpi for platforms that support more than 
256 nodes. Currently, ACPI is limited to 256 nodes because the
proximity domain number is 8-bits.

Long term, we expect to use ACPI3.0 to support >256 nodes. 
This patch is an interim solution that works with platforms 
that pass the  high order bits of the proximity domain in 
"reserved" fields of the ACPI tables. This code is enabled 
ONLY on SN platforms.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


 arch/ia64/kernel/acpi.c |   32 ++++++++++++++++++++++++++++----
 include/asm-ia64/acpi.h |    4 ++++
 2 files changed, 32 insertions(+), 4 deletions(-)




Index: linux/arch/ia64/kernel/acpi.c
=================================--- linux.orig/arch/ia64/kernel/acpi.c	2006-03-01 16:07:24.179876869 -0600
+++ linux/arch/ia64/kernel/acpi.c	2006-03-02 13:21:53.345807130 -0600
@@ -414,6 +414,26 @@ int __devinitdata pxm_to_nid_map[MAX_PXM
 int __initdata nid_to_pxm_map[MAX_NUMNODES];
 static struct acpi_table_slit __initdata *slit_table;
 
+static int get_processor_proximity_domain(struct acpi_table_processor_affinity *pa)
+{
+	int pxm;
+
+	pxm = pa->proximity_domain;
+	if (ia64_platform_is("sn2"))
+		pxm += pa->reserved[0] << 8;
+	return pxm;
+}
+
+static int get_memory_proximity_domain(struct acpi_table_memory_affinity *ma)
+{
+	int pxm;
+
+	pxm = ma->proximity_domain;
+	if (ia64_platform_is("sn2"))
+		pxm += ma->reserved1[0] << 8;
+	return pxm;
+}
+
 /*
  * ACPI 2.0 SLIT (System Locality Information Table)
  * http://devresource.hp.com/devresource/Docs/TechPapers/IA64/slit.pdf
@@ -437,13 +457,17 @@ void __init acpi_numa_slit_init(struct a
 void __init
 acpi_numa_processor_affinity_init(struct acpi_table_processor_affinity *pa)
 {
+	int pxm;
+
+	pxm = get_processor_proximity_domain(pa);
+
 	/* record this node in proximity bitmap */
-	pxm_bit_set(pa->proximity_domain);
+	pxm_bit_set(pxm);
 
 	node_cpuid[srat_num_cpus].phys_id  	    (pa->apic_id << 8) | (pa->lsapic_eid);
 	/* nid should be overridden as logical node id later */
-	node_cpuid[srat_num_cpus].nid = pa->proximity_domain;
+	node_cpuid[srat_num_cpus].nid = pxm;
 	srat_num_cpus++;
 }
 
@@ -451,10 +475,10 @@ void __init
 acpi_numa_memory_affinity_init(struct acpi_table_memory_affinity *ma)
 {
 	unsigned long paddr, size;
-	u8 pxm;
+	int pxm;
 	struct node_memblk_s *p, *q, *pend;
 
-	pxm = ma->proximity_domain;
+	pxm = get_memory_proximity_domain(ma);
 
 	/* fill node memory chunk structure */
 	paddr = ma->base_addr_hi;
Index: linux/include/asm-ia64/acpi.h
=================================--- linux.orig/include/asm-ia64/acpi.h	2006-03-01 16:07:30.037695249 -0600
+++ linux/include/asm-ia64/acpi.h	2006-03-02 13:21:53.356548273 -0600
@@ -111,7 +111,11 @@ extern int additional_cpus;
 
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
+#ifdef CONFIG_IA64_NR_NODES
+#define MAX_PXM_DOMAINS CONFIG_IA64_NR_NODES
+#else
 #define MAX_PXM_DOMAINS (256)
+#endif
 extern int __devinitdata pxm_to_nid_map[MAX_PXM_DOMAINS];
 extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
 #endif
