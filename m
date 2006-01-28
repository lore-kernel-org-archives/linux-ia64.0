From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Sat, 28 Jan 2006 03:34:46 +0000
Subject: [PATCH 003/003]Fix unify mapping from pxm to node id.
Message-Id: <20060128122935.CF56.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060123165644.C147.Y-GOTO@jp.fujitsu.com> <20060126074846.1a6dd300.pj@sgi.com>
In-Reply-To: <20060126074846.1a6dd300.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, Andy Whitcroft <apw@shadowen.org>, Bob Picco <bob.picco@hp.com>, Paul Jackson <pj@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, ak@suse.de, len.brown@intel.com, discuss@x86-64.org


This is to fix/remove old pxm_to_nid_map[] for ia64(hp and SN).

Signed-off-by: Bob Picco <bob.picco@hp.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: fix_pxm/include/asm-ia64/acpi.h
=================================--- fix_pxm.orig/include/asm-ia64/acpi.h	2006-01-28 10:45:46.000000000 +0900
+++ fix_pxm/include/asm-ia64/acpi.h	2006-01-28 11:45:04.000000000 +0900
@@ -107,13 +107,6 @@ extern unsigned int is_cpu_cpei_target(u
 extern void set_cpei_target_cpu(unsigned int cpu);
 extern unsigned int get_cpei_target_cpu(void);
 
-#ifdef CONFIG_ACPI_NUMA
-/* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
-#define MAX_PXM_DOMAINS (256)
-extern int __devinitdata pxm_to_nid_map[MAX_PXM_DOMAINS];
-extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
-#endif
-
 extern u16 ia64_acpiid_to_sapicid[];
 
 /*
Index: fix_pxm/arch/ia64/hp/common/sba_iommu.c
=================================--- fix_pxm.orig/arch/ia64/hp/common/sba_iommu.c	2006-01-28 10:45:46.000000000 +0900
+++ fix_pxm/arch/ia64/hp/common/sba_iommu.c	2006-01-28 10:58:18.000000000 +0900
@@ -1958,7 +1958,7 @@ sba_map_ioc_to_node(struct ioc *ioc, acp
 	if (pxm < 0)
 		return;
 
-	node = pxm_to_nid_map[pxm];
+	node = pxm_to_node(pxm);
 
 	if (node >= MAX_NUMNODES || !node_online(node))
 		return;
Index: fix_pxm/arch/ia64/sn/kernel/setup.c
=================================--- fix_pxm.orig/arch/ia64/sn/kernel/setup.c	2006-01-28 10:49:30.000000000 +0900
+++ fix_pxm/arch/ia64/sn/kernel/setup.c	2006-01-28 10:58:18.000000000 +0900
@@ -152,7 +152,7 @@ static int __init pxm_to_nasid(int pxm)
 	int i;
 	int nid;
 
-	nid = pxm_to_nid_map[pxm];
+	nid = pxm_to_node(pxm);
 	for (i = 0; i < num_node_memblks; i++) {
 		if (node_memblk[i].nid = nid) {
 			return NASID_GET(node_memblk[i].start_paddr);
@@ -696,7 +696,7 @@ void __init build_cnode_tables(void)
 	 * cnode = node for all C & M bricks.
 	 */
 	for_each_online_node(node) {
-		nasid = pxm_to_nasid(nid_to_pxm_map[node]);
+		nasid = pxm_to_nasid(node_to_pxm(node));
 		sn_cnodeid_to_nasid[node] = nasid;
 		physical_node_map[nasid] = node;
 	}


