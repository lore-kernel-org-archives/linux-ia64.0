From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 29 Oct 2004 23:58:13 +0000
Subject: [PATCH] remove redundant macros
Message-Id: <200410291658.13048.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_VktgBskSDJC9udv"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_VktgBskSDJC9udv
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch removes some redundant nasid conversion macros from arch.h and 
updates callers to use the version they were defined to instead.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_VktgBskSDJC9udv
Content-Type: text/plain;
  charset="us-ascii";
  name="remove-redundant-nasid-macros.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="remove-redundant-nasid-macros.patch"

===== arch/ia64/sn/kernel/io_init.c 1.5 vs edited =====
--- 1.5/arch/ia64/sn/kernel/io_init.c	2004-10-26 16:43:02 -07:00
+++ edited/arch/ia64/sn/kernel/io_init.c	2004-10-29 16:01:27 -07:00
@@ -136,7 +136,7 @@
 
 	for (i = 0; i < numionodes; i++) {
 		hubdev = (struct hubdev_info *)(NODEPDA(i)->pdinfo);
-		nasid = COMPACT_TO_NASID_NODEID(i);
+		nasid = cnodeid_to_nasid(i);
 		status = sal_get_hubdev_info(nasid, (uint64_t) __pa(hubdev));
 		if (status)
 			continue;
@@ -313,7 +313,7 @@
 	SN_PCIBUS_BUSSOFT(bus) = provider_soft;
 
 	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
-	cnode = NASID_TO_COMPACT_NODEID(nasid);
+	cnode = nasid_to_cnodeid(nasid);
 	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
 	SN_PCIBUS_BUSSOFT(bus)->bs_xwidget_info =
 	    &(hubdev_info->hdi_xwidget_info[SN_PCIBUS_BUSSOFT(bus)->bs_xid]);
===== arch/ia64/sn/pci/pcibr/pcibr_dma.c 1.2 vs edited =====
--- 1.2/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2004-10-20 13:25:07 -07:00
+++ edited/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2004-10-29 16:00:49 -07:00
@@ -226,10 +226,10 @@
 		return;
 
 	nasid = NASID_GET(addr);
-	if (-1 == NASID_TO_COMPACT_NODEID(nasid))
+	if (-1 == nasid_to_cnodeid(nasid))
 		return;
 
-	hubinfo = (NODEPDA(NASID_TO_COMPACT_NODEID(nasid)))->pdinfo;
+	hubinfo = (NODEPDA(nasid_to_cnodeid(nasid)))->pdinfo;
 
 	if (!hubinfo) {
 		BUG();
===== arch/ia64/sn/pci/pcibr/pcibr_provider.c 1.1 vs edited =====
--- 1.1/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2004-10-11 13:03:57 -07:00
+++ edited/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2004-10-29 16:01:03 -07:00
@@ -98,7 +98,7 @@
 	}
 
 	nasid = NASID_GET(soft->pbi_buscommon.bs_base);
-	cnode = NASID_TO_COMPACT_NODEID(nasid);
+	cnode = nasid_to_cnodeid(nasid);
 	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
 
 	if (hubdev_info->hdi_flush_nasid_list.widget_p) {
===== include/asm-ia64/sn/arch.h 1.12 vs edited =====
--- 1.12/include/asm-ia64/sn/arch.h	2004-10-29 16:02:43 -07:00
+++ edited/include/asm-ia64/sn/arch.h	2004-10-29 16:03:13 -07:00
@@ -24,9 +24,6 @@
 
 typedef u64	nic_t;
 
-#define NASID_TO_COMPACT_NODEID(nasid)  (nasid_to_cnodeid(nasid))
-#define COMPACT_TO_NASID_NODEID(cnode)  (cnodeid_to_nasid(cnode))
-
 extern void sn_flush_all_caches(long addr, long bytes);
 
 #endif /* _ASM_IA64_SN_ARCH_H */

--Boundary-00=_VktgBskSDJC9udv--
