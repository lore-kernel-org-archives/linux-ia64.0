From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 21 Mar 2005 17:43:54 +0000
Subject: [PATCH] fix ia64 Kconfig to allow CONFIG_PM on sn2
Message-Id: <200503210943.54731.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_afwPCDl6wc/ngRY"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_afwPCDl6wc/ngRY
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This probably should have been fixed when I fixed up the generic build for 
discontig+numa machines, but oh well.

CONFIG_PM is allowable for generic builds but not for sn2 builds, which 
doesn't make much sense, and in fact breaks the build if recent ACPI bits are 
added to the tree.  It looks like the only arch that needs to prevent 
CONFIG_PM stuff is the ski simulator (though those options could probably use 
some cleanup as well), so remove the big conditional and replace it with a 
simple test for IA64_HP_SIM instead.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_afwPCDl6wc/ngRY
Content-Type: text/plain;
  charset="us-ascii";
  name="ia64-kconfig-pm-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ia64-kconfig-pm-fix.patch"

===== arch/ia64/Kconfig 1.85 vs edited =====
--- 1.85/arch/ia64/Kconfig	2005-01-28 15:32:25 -08:00
+++ edited/arch/ia64/Kconfig	2005-03-21 09:38:29 -08:00
@@ -328,7 +328,7 @@
 
 config PM
 	bool "Power Management support"
-	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB
+	depends on !IA64_HP_SIM
 	default y
 	help
 	  "Power Management" means that parts of your computer are shut

--Boundary-00=_afwPCDl6wc/ngRY--
