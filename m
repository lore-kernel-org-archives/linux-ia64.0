From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 15 Sep 2004 21:07:10 +0000
Subject: [PATCH] help text for CONFIG_IA64_SGI_SN2
Message-Id: <200409151407.10154.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_+7KSBrtYq403nGZ"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_+7KSBrtYq403nGZ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Mark Goodwin suggested that we document our platform a bit.  This patch adds 
help text for the sn2 specific kernel option.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_+7KSBrtYq403nGZ
Content-Type: text/plain;
  charset="us-ascii";
  name="sn2-kconfig-desc-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-kconfig-desc-2.patch"

===== arch/ia64/Kconfig 1.80 vs edited =====
--- 1.80/arch/ia64/Kconfig	2004-09-13 11:31:52 -07:00
+++ edited/arch/ia64/Kconfig	2004-09-15 11:24:28 -07:00
@@ -76,6 +76,12 @@
 
 config IA64_SGI_SN2
 	bool "SGI-SN2"
+	help
+	  Selecting this option will optimize the kernel for use on sn2 based
+	  systems, but the resulting kernel binary will not run on other
+	  types of ia64 systems.  If you have an SGI Altix system, it's safe
+	  to select this option.  If in doubt, select ia64 generic support
+	  instead.
 
 config IA64_HP_SIM
 	bool "Ski-simulator"

--Boundary-00=_+7KSBrtYq403nGZ--
