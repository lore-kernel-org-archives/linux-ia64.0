From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 23 Jun 2004 18:35:18 +0000
Subject: [PATCH] make sn2 use 16MB granules too
Message-Id: <200406231435.18939.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_m1c2A9CfDoXrqKg"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_m1c2A9CfDoXrqKg
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Altix needs to use 16MB granules to prevent attribute aliasing in low memory 
space.  This patch makes the kernel configuration system enforce that 
requirement.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_m1c2A9CfDoXrqKg
Content-Type: text/x-diff;
  charset="us-ascii";
  name="force-16m-granules.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="force-16m-granules.patch"

===== arch/ia64/Kconfig 1.75 vs edited =====
--- 1.75/arch/ia64/Kconfig	2004-06-07 06:03:19 -04:00
+++ edited/arch/ia64/Kconfig	2004-06-23 14:19:08 -04:00
@@ -388,7 +388,7 @@
 
 config IA64_GRANULE_64MB
 	bool "64MB"
-	depends on !(IA64_GENERIC || IA64_HP_ZX1)
+	depends on !(IA64_GENERIC || IA64_HP_ZX1 || IA64_SGI_SN2)
 
 endchoice
 

--Boundary-00=_m1c2A9CfDoXrqKg--
