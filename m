From: Erich Focht <efocht@ess.nec.de>
Date: Thu, 26 Sep 2002 15:40:37 +0000
Subject: [Linux-ia64] [PATCH] acpi-numa for ia64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------Boundary-00=_P7Y1XS4EJNWGVG3AQI8G"
Message-Id: <marc-linux-ia64-105590701906070@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--------------Boundary-00=_P7Y1XS4EJNWGVG3AQI8G
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable

Hi David,

attached is the IA64 architecture specific code for the ACPI-NUMA
infrastructure which is meanwhile present in the 2.5 baseline
kernels. It provides the interpreters for the ACPI SLIT (System
Locality Information Table) and the SRAT (System Ressource Affinity
Table). These build three data structures with the NUMA characteristics
of the machine:
 - node_memblk : memory blocks and the nodes to which they belong,
 - node_cpuid  : hardware CPUID and corresponding node ID,
 - numa_slit AKA node_distance : distance matrix between nodes.

We need these things for both discontigmem and NUMA scheduler setup,
it would be great to have it in the baseline kernels.

Thanks,
Erich

--------------Boundary-00=_P7Y1XS4EJNWGVG3AQI8G
Content-Type: text/x-diff;
  charset="iso-8859-15";
  name="acpi_numa_ia64-2.5.35.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="acpi_numa_ia64-2.5.35.patch"

diff -urNp linux-2.5.35-ia64/arch/ia64/kernel/acpi.c linux-2.5.35-ia64-acpi/arch/ia64/kernel/acpi.c
--- linux-2.5.35-ia64/arch/ia64/kernel/acpi.c	Mon Sep 16 04:18:29 2002
+++ linux-2.5.35-ia64-acpi/arch/ia64/kernel/acpi.c	Thu Sep 26 18:34:26 2002
@@ -8,6 +8,9 @@
  *  Copyright (C) 2000 Intel Corp.
  *  Copyright (C) 2000,2001 J.I. Lee <jung-ik.lee@intel.com>
  *  Copyright (C) 2001 Paul Diefenbaugh <paul.s.diefenbaugh@intel.com>
+ *  Copyright (C) 2001 Jenna Hall <jenna.s.hall@intel.com>
+ *  Copyright (C) 2001 Takayoshi Kochi <t-kouchi@cq.jp.nec.com>
+ *  Copyright (C) 2002 Erich Focht <efocht@ess.nec.de>
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *
@@ -43,6 +46,7 @@
 #include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/system.h>
+#include <asm/numa.h>
 
 
 #define PREFIX			"ACPI: "
@@ -445,6 +449,152 @@ acpi_parse_madt (unsigned long phys_addr
 }
 
 
+#ifdef CONFIG_ACPI_NUMA
+
+#define SLIT_DEBUG
+
+#define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
+
+static int __initdata srat_num_cpus = 0;		/* number of cpus */
+static u32 __initdata pxm_flag[PXM_FLAG_LEN] = { [0 ... PXM_FLAG_LEN-1] = 0};
+#define PXM_BIT_SET(bit)	(set_bit(bit,(void *)pxm_flag))
+#define PXM_BIT_CLEAR(bit)	(clear_bit(bit,(void *)pxm_flag))
+#define PXM_BIT_TEST(bit)	(test_bit(bit,(void *)pxm_flag))
+/* maps to convert between proximity domain and logical node ID */
+int pxm_to_nid_map[MAX_PXM_DOMAINS] = { [0 ... MAX_PXM_DOMAINS-1] = -1};
+int nid_to_pxm_map[NR_NODES] = { [0 ... NR_NODES-1] = -1};
+
+/*
+ * ACPI 2.0 SLIT (System Locality Information Table)
+ * http://devresource.hp.com/devresource/Docs/TechPapers/IA64/
+ */
+void __init
+acpi_numa_slit_init (struct acpi_table_slit *slit)
+{
+	int i, j, node_from, node_to;
+	u32 len;
+
+	len = sizeof(struct acpi_table_header) + 8 
+		+ slit->localities * slit->localities;
+	if (slit->header.length != len) {
+		printk("ACPI 2.0 SLIT: size mismatch: %d expected, %d actual\n",
+		      len, slit->header.length);
+		memset(numa_slit, 10, sizeof(numa_slit));
+		return;
+	}
+
+	memset(numa_slit, -1, sizeof(numa_slit));
+	for (i=0; i<slit->localities; i++) {
+		if (!PXM_BIT_TEST(i))
+			continue;
+		node_from = pxm_to_nid_map[i];
+		for (j=0; j<slit->localities; j++) {
+			if (!PXM_BIT_TEST(j))
+				continue;
+			node_to = pxm_to_nid_map[j];
+			node_distance(node_from, node_to) = 
+				slit->entry[i*slit->localities + j];
+		}
+	}
+
+#ifdef SLIT_DEBUG
+	printk("ACPI 2.0 SLIT locality table:\n");
+	for (i = 0; i < numnodes; i++) {
+		for (j = 0; j < numnodes; j++)
+			printk("%03d ", node_distance(i,j));
+		printk("\n");
+	}
+#endif
+}
+
+void __init
+acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *pa)
+{
+	/* record this node in proximity bitmap */
+	PXM_BIT_SET(pa->proximity_domain);
+
+	node_cpuid[srat_num_cpus].phys_id = (pa->apic_id << 8) | (pa->lsapic_eid);
+	/* nid should be overridden as logical node id later */
+	node_cpuid[srat_num_cpus].nid = pa->proximity_domain;
+	srat_num_cpus++;
+}
+
+void __init
+acpi_numa_memory_affinity_init (struct acpi_table_memory_affinity *ma)
+{
+	unsigned long paddr, size;
+	u8 pxm;
+	struct node_memblk_s *p, *q, *pend;
+
+	pxm = ma->proximity_domain;
+
+	/* record this node in proximity bitmap */
+	PXM_BIT_SET(pxm);
+
+	/* fill node memory chunk structure */
+	paddr = ma->base_addr_hi;
+	paddr = (paddr << 32) | ma->base_addr_lo;
+	size = ma->length_hi;
+	size = (size << 32) | ma->length_lo;
+
+	if (num_memblks >= NR_MEMBLKS) {
+		printk("Too many mem chunks in SRAT. Ignoring %ld MBytes at %lx\n",
+			size/(1024*1024), paddr);
+		return;
+	}
+
+	/* Insertion sort based on base address */
+	pend = &node_memblk[num_memblks];
+	for (p = &node_memblk[0]; p < pend; p++) {
+		if (paddr < p->start_paddr)
+			break;
+	}
+	if (p < pend) {
+		for (q = pend; q >= p; q--)
+			*(q + 1) = *q;
+	}
+	p->start_paddr = paddr;
+	p->size = size;
+	p->nid = pxm;
+	num_memblks++;
+}
+
+void __init
+acpi_numa_arch_fixup(void)
+{
+	int i, j;
+
+	/* calculate total number of nodes in system from PXM bitmap */
+	numnodes = 0;		/* init total nodes in system */
+	for (i = 0; i < MAX_PXM_DOMAINS; i++) {
+		if (PXM_BIT_TEST(i)) {
+			pxm_to_nid_map[i] = numnodes;
+			nid_to_pxm_map[numnodes++] = i;
+		}
+	}
+
+	/* set logical node id in memory chunk structure */
+	for (i = 0; i < num_memblks; i++)
+		node_memblk[i].nid = pxm_to_nid_map[node_memblk[i].nid];
+
+	/* assign memory bank numbers for each chunk on each node */
+	for (i = 0; i < numnodes; i++) {
+		int bank;
+
+		bank = 0;
+		for (j = 0; j < num_memblks; j++)
+			if (node_memblk[j].nid == i)
+				node_memblk[j].bank = bank++;
+	}
+
+	/* set logical node id in cpu structure */
+	for (i = 0; i < srat_num_cpus; i++)
+		node_cpuid[i].nid = pxm_to_nid_map[node_cpuid[i].nid];
+
+	printk("Number of logical nodes in system = %d\n", numnodes);
+	printk("Number of memory chunks in system = %d\n", num_memblks);
+}
+#endif /* CONFIG_ACPI_NUMA */
 static int __init
 acpi_parse_fadt (unsigned long phys_addr, unsigned long size)
 {
@@ -554,12 +704,6 @@ acpi_parse_spcr (unsigned long phys_addr
 int __init
 acpi_boot_init (char *cmdline)
 {
-	int result;
-
-	/* Initialize the ACPI boot-time table parser */
-	result = acpi_table_init(cmdline);
-	if (result)
-		return result;
 
 	/*
 	 * MADT
diff -urNp linux-2.5.35-ia64/arch/ia64/kernel/setup.c linux-2.5.35-ia64-acpi/arch/ia64/kernel/setup.c
--- linux-2.5.35-ia64/arch/ia64/kernel/setup.c	Mon Sep 16 04:18:21 2002
+++ linux-2.5.35-ia64-acpi/arch/ia64/kernel/setup.c	Thu Sep 26 18:12:52 2002
@@ -296,6 +296,16 @@ setup_arch (char **cmdline_p)
 
 	efi_init();
 
+#ifdef CONFIG_ACPI_BOOT
+	/* Initialize the ACPI boot-time table parser */
+	acpi_table_init(*cmdline_p);
+
+#ifdef CONFIG_ACPI_NUMA
+	acpi_numa_init();
+#endif
+
+#endif /* CONFIG_APCI_BOOT */
+
 	find_memory();
 
 #if 0
diff -urNp linux-2.5.35-ia64/arch/ia64/mm/Makefile linux-2.5.35-ia64-acpi/arch/ia64/mm/Makefile
--- linux-2.5.35-ia64/arch/ia64/mm/Makefile	Mon Sep 23 21:17:07 2002
+++ linux-2.5.35-ia64-acpi/arch/ia64/mm/Makefile	Thu Sep 26 18:14:16 2002
@@ -11,5 +11,6 @@ O_TARGET := mm.o
 
 obj-y	 := init.o fault.o tlb.o extable.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
+obj-$(CONFIG_NUMA) += numa.o
 
 include $(TOPDIR)/Rules.make
diff -urNp linux-2.5.35-ia64/arch/ia64/mm/numa.c linux-2.5.35-ia64-acpi/arch/ia64/mm/numa.c
--- linux-2.5.35-ia64/arch/ia64/mm/numa.c	Thu Jan  1 01:00:00 1970
+++ linux-2.5.35-ia64-acpi/arch/ia64/mm/numa.c	Thu Sep 26 18:12:52 2002
@@ -0,0 +1,46 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * This file contains NUMA specific variables and functions which can
+ * be split away from DISCONTIGMEM and are used on NUMA machines with
+ * contiguous memory.
+ * 
+ *                         2002/08/07 Erich Focht <efocht@ess.nec.de>
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/init.h>
+#include <linux/bootmem.h>
+#include <linux/mmzone.h>
+#include <asm/numa.h>
+
+/*
+ * The following structures are usually initialized by ACPI or
+ * similar mechanisms and describe the NUMA characteristics of the machine.
+ */
+int num_memblks = 0;
+struct node_memblk_s node_memblk[NR_MEMBLKS];
+struct node_cpuid_s node_cpuid[NR_CPUS];
+/*
+ * This is a matrix with "distances" between nodes, they should be
+ * proportional to the memory access latency ratios.
+ */
+u8 numa_slit[NR_NODES * NR_NODES];
+
+/* Identify which cnode a physical address resides on */
+int
+paddr_to_nid(unsigned long paddr)
+{
+	int	i;
+
+	for (i = 0; i < num_memblks; i++)
+		if (paddr >= node_memblk[i].start_paddr &&
+		    paddr < node_memblk[i].start_paddr + node_memblk[i].size)
+			break;
+
+	return (i < num_memblks) ? node_memblk[i].nid : -1;
+}
diff -urNp linux-2.5.35-ia64/include/asm-ia64/acpi.h linux-2.5.35-ia64-acpi/include/asm-ia64/acpi.h
--- linux-2.5.35-ia64/include/asm-ia64/acpi.h	Mon Sep 16 04:18:25 2002
+++ linux-2.5.35-ia64-acpi/include/asm-ia64/acpi.h	Thu Sep 26 18:16:04 2002
@@ -97,17 +97,17 @@
 	} while (0)
 
 const char *acpi_get_sysname (void);
-int acpi_boot_init (char *cdline);
 int acpi_request_vector (u32 int_type);
 int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
 int acpi_get_interrupt_model (int *type);
 int acpi_irq_to_vector (u32 irq);
 
-#ifdef CONFIG_DISCONTIGMEM
-#define NODE_ARRAY_INDEX(x)	((x) / 8)	/* 8 bits/char */
-#define NODE_ARRAY_OFFSET(x)	((x) % 8)	/* 8 bits/char */
-#define MAX_PXM_DOMAINS		(256)
-#endif /* CONFIG_DISCONTIGMEM */
+#ifdef CONFIG_ACPI_NUMA
+/* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
+#define MAX_PXM_DOMAINS (256)
+extern int pxm_to_nid_map[MAX_PXM_DOMAINS];
+extern int nid_to_pxm_map[NR_NODES];
+#endif
 
 #endif /*__KERNEL__*/
 
diff -urNp linux-2.5.35-ia64/include/asm-ia64/numa.h linux-2.5.35-ia64-acpi/include/asm-ia64/numa.h
--- linux-2.5.35-ia64/include/asm-ia64/numa.h	Thu Jan  1 01:00:00 1970
+++ linux-2.5.35-ia64-acpi/include/asm-ia64/numa.h	Thu Sep 26 18:12:52 2002
@@ -0,0 +1,64 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * This file contains NUMA specific prototypes and definitions.
+ * 
+ * 2002/08/05 Erich Focht <efocht@ess.nec.de>
+ *
+ */
+#ifndef _ASM_IA64_NUMA_H
+#define _ASM_IA64_NUMA_H
+
+#ifdef CONFIG_NUMA
+
+#ifdef CONFIG_DISCONTIGMEM
+# include <asm/mmzone.h>
+# define NR_NODES     (PLAT_MAX_COMPACT_NODES)
+# define NR_MEMBLKS   (PLAT_MAXCLUMPS)
+#else
+# define NR_NODES     (8)
+# define NR_MEMBLKS   (NR_NODES * 8)
+#endif
+
+/* Stuff below this line could be architecture independent */
+
+extern int num_memblks;		/* total number of memory chunks */
+
+/*
+ * List of node memory chunks. Filled when parsing SRAT table to
+ * obtain information about memory nodes.
+*/
+
+struct node_memblk_s {
+	unsigned long start_paddr;
+	unsigned long size;
+	int nid;		/* which logical node contains this chunk? */
+	int bank;		/* which mem bank on this node */
+};
+
+struct node_cpuid_s {
+	u16	phys_id;	/* id << 8 | eid */
+	int	nid;		/* logical node containing this CPU */
+};
+
+extern struct node_memblk_s node_memblk[NR_MEMBLKS];
+extern struct node_cpuid_s node_cpuid[NR_CPUS];
+
+/*
+ * ACPI 2.0 SLIT (System Locality Information Table)
+ * http://devresource.hp.com/devresource/Docs/TechPapers/IA64/
+ *
+ * This is a matrix with "distances" between nodes, they should be
+ * proportional to the memory access latency ratios.
+ */
+
+extern u8 numa_slit[NR_NODES * NR_NODES];
+#define node_distance(from,to) (numa_slit[from * numnodes + to])
+
+extern int paddr_to_nid(unsigned long paddr);
+
+#endif /* CONFIG_NUMA */
+
+#endif /* _ASM_IA64_NUMA_H */

--------------Boundary-00=_P7Y1XS4EJNWGVG3AQI8G--


