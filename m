From: Mark Goodwin <markgw@sgi.com>
Date: Tue, 16 Aug 2005 07:50:10 +0000
Subject: [PATCH 1/3] - SGI SN hwperf enhancements - export_pci_topology
Message-Id: <Pine.LNX.4.62.0508161731530.7676@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Bugfix to export PCI topology information in /proc/sgi_sn/sn_topology.

Signed-off-by: Mark Goodwin <markgw@sgi.com>


Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-06-18 05:48:29.000000000 +1000
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-08-11 14:38:27.102784018 +1000
@@ -174,29 +174,22 @@
 	return slabname;
 }
 
-static void print_pci_topology(struct seq_file *s,
-	struct sn_hwperf_object_info *obj, int *ordinal,
-	u64 rack, u64 bay, u64 slot, u64 slab)
-{
-	char *p1;
-	char *p2;
-	char *pg;
-
-	if (!(pg = (char *)get_zeroed_page(GFP_KERNEL)))
-		return; /* ignore */
-	if (ia64_sn_ioif_get_pci_topology(rack, bay, slot, slab,
-		__pa(pg), PAGE_SIZE) = SN_HWPERF_OP_OK) {
-		for (p1=pg; *p1 && p1 < pg + PAGE_SIZE;) {
-			if (!(p2 = strchr(p1, '\n')))
-				break;
-			*p2 = '\0';
-			seq_printf(s, "pcibus %d %s-%s\n",
-				*ordinal, obj->location, p1);
-			(*ordinal)++;
-			p1 = p2 + 1;
-		}
+static void print_pci_topology(struct seq_file *s)
+{
+	char *p;
+	size_t sz;
+	int e;
+
+	for (sz = PAGE_SIZE; sz < 16 * PAGE_SIZE; sz += PAGE_SIZE) {
+		if (!(p = (char *)kmalloc(sz, GFP_KERNEL)))
+			break;
+		e = ia64_sn_ioif_get_pci_topology(__pa(p), sz);
+		if (e = SALRET_OK)
+			seq_puts(s, p);
+		kfree(p);
+		if (e = SALRET_OK || e = SALRET_NOT_IMPLEMENTED)
+			break;
 	}
-	free_page((unsigned long)pg);
 }
 
 static int sn_topology_show(struct seq_file *s, void *d)
@@ -215,7 +208,6 @@
 	struct sn_hwperf_object_info *p;
 	struct sn_hwperf_object_info *obj = d;	/* this object */
 	struct sn_hwperf_object_info *objs = s->private; /* all objects */
-	int rack, bay, slot, slab;
 	u8 shubtype;
 	u8 system_size;
 	u8 sharing_size;
@@ -225,7 +217,6 @@
 	u8 region_size;
 	u16 nasid_mask;
 	int nasid_msb;
-	int pci_bus_ordinal = 0;
 
 	if (obj = objs) {
 		seq_printf(s, "# sn_topology version 2\n");
@@ -253,6 +244,8 @@
 			shubtype ? "shub2" : "shub1", 
 			(u64)nasid_mask << nasid_shift, nasid_msb, nasid_shift,
 			system_size, sharing_size, coher, region_size);
+
+		print_pci_topology(s);
 	}
 
 	if (SN_HWPERF_FOREIGN(obj)) {
@@ -300,17 +293,6 @@
 				seq_putc(s, '\n');
 			}
 		}
-
-		/*
-		 * PCI busses attached to this node, if any
-		 */
-		if (sn_hwperf_location_to_bpos(obj->location,
-			&rack, &bay, &slot, &slab)) {
-			/* export pci bus info */
-			print_pci_topology(s, obj, &pci_bus_ordinal,
-				rack, bay, slot, slab);
-
-		}
 	}
 
 	if (obj->ports) {
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-08-11 14:38:13.405511380 +1000
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-08-11 14:40:34.055974018 +1000
@@ -78,7 +78,8 @@
 
 #define SN_SAL_HUB_ERROR_INTERRUPT		   0x02000060
 #define SN_SAL_BTE_RECOVER			   0x02000061
-#define SN_SAL_IOIF_GET_PCI_TOPOLOGY	           0x02000062
+#define SN_SAL_RESERVED_DO_NOT_USE		   0x02000062
+#define SN_SAL_IOIF_GET_PCI_TOPOLOGY		   0x02000064
 
 /*
  * Service-specific constants
@@ -1068,12 +1069,10 @@
 }
 
 static inline int
-ia64_sn_ioif_get_pci_topology(u64 rack, u64 bay, u64 slot, u64 slab,
-			      u64 buf, u64 len)
+ia64_sn_ioif_get_pci_topology(u64 buf, u64 len)
 {
 	struct ia64_sal_retval rv;
-	SAL_CALL_NOLOCK(rv, SN_SAL_IOIF_GET_PCI_TOPOLOGY,
-		rack, bay, slot, slab, buf, len, 0);
+	SAL_CALL_NOLOCK(rv, SN_SAL_IOIF_GET_PCI_TOPOLOGY, buf, len, 0, 0, 0, 0, 0);
 	return (int) rv.status;
 }
 
