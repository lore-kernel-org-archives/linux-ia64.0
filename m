From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 11 May 2004 18:42:24 +0000
Subject: [PATCH] kill warnings in sn2 specific pci init
Message-Id: <200405111142.24110.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Q6RoAUMB/adMTvx"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_Q6RoAUMB/adMTvx
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

A couple of unused variable warnings cropped up in the sn2 pci init routine.  
This patch kills the unused variables.

Jesse

--Boundary-00=_Q6RoAUMB/adMTvx
Content-Type: text/plain;
  charset="us-ascii";
  name="kill-sn-pci-init-warnings.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="kill-sn-pci-init-warnings.patch"

===== arch/ia64/sn/io/machvec/pci_bus_cvlink.c 1.38 vs edited =====
--- 1.38/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Wed Apr 28 09:20:53 2004
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Tue May 11 11:08:47 2004
@@ -791,8 +791,7 @@
 	struct list_head *ln;
 	struct pci_bus *pci_bus = NULL;
 	struct pci_dev *pci_dev = NULL;
-	extern int numnodes;
-	int cnode, ret;
+	int ret;
 #ifdef CONFIG_PROC_FS
 	extern void register_sn_procfs(void);
 #endif

--Boundary-00=_Q6RoAUMB/adMTvx--
