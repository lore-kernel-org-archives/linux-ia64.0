From: "Bob Picco" <bob.picco@hp.com>
Date: Thu, 26 Jan 2006 16:25:27 +0000
Subject: [PATCH] ia64 fix for -mm unify-mapping-from-pxm-to-node-id
Message-Id: <20060126162527.GJ7306@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew:

I was unable to build ia64. I didn't check closely but assume one of the
x86-x86_64-ia64-unify-mapping-from-pxm-to-node* patches in -mm caused
this issue.

I boot tested this on rx2600 ia64.  The sn2 change was only compile
tested using sn2_defconfig config.

thanks,

bob


Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/hp/common/sba_iommu.c |    2 +-
 arch/ia64/sn/kernel/setup.c     |    4 ++--
 include/asm-ia64/acpi.h         |    2 --
 3 files changed, 3 insertions(+), 5 deletions(-)

Index: linux-2.6.16-rc1-mm3/include/asm-ia64/acpi.h
=================================--- linux-2.6.16-rc1-mm3.orig/include/asm-ia64/acpi.h	2006-01-02 22:21:10.000000000 -0500
+++ linux-2.6.16-rc1-mm3/include/asm-ia64/acpi.h	2006-01-26 06:30:35.000000000 -0500
@@ -110,8 +110,6 @@ extern unsigned int get_cpei_target_cpu(
 #ifdef CONFIG_ACPI_NUMA
 /* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
 #define MAX_PXM_DOMAINS (256)
-extern int __devinitdata pxm_to_nid_map[MAX_PXM_DOMAINS];
-extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
 #endif
 
 extern u16 ia64_acpiid_to_sapicid[];
Index: linux-2.6.16-rc1-mm3/arch/ia64/hp/common/sba_iommu.c
=================================--- linux-2.6.16-rc1-mm3.orig/arch/ia64/hp/common/sba_iommu.c	2006-01-26 10:15:16.000000000 -0500
+++ linux-2.6.16-rc1-mm3/arch/ia64/hp/common/sba_iommu.c	2006-01-26 10:16:25.000000000 -0500
@@ -1958,7 +1958,7 @@ sba_map_ioc_to_node(struct ioc *ioc, acp
 	if (pxm < 0)
 		return;
 
-	node = pxm_to_nid_map[pxm];
+	node = pxm_to_node_map[pxm];
 
 	if (node >= MAX_NUMNODES || !node_online(node))
 		return;
Index: linux-2.6.16-rc1-mm3/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.16-rc1-mm3.orig/arch/ia64/sn/kernel/setup.c	2006-01-26 10:15:49.000000000 -0500
+++ linux-2.6.16-rc1-mm3/arch/ia64/sn/kernel/setup.c	2006-01-26 11:17:04.000000000 -0500
@@ -152,7 +152,7 @@ static int __init pxm_to_nasid(int pxm)
 	int i;
 	int nid;
 
-	nid = pxm_to_nid_map[pxm];
+	nid = pxm_to_node_map[pxm];
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

