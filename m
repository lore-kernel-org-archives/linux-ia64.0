From: jbarnes@sgi.com (Jesse Barnes)
Date: Sat, 11 Oct 2003 01:11:31 +0000
Subject: [PATCH] enable sn2 in generic builds
Message-Id: <marc-linux-ia64-106583470315652@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that it works, we can enable sn2 in generic builds.  This should not
only allow generic kernels to work on sn2, but also fix the build
problems people have been seeing with the qla1280 driver.  I tested a
generic kernel built with this patch on zx1 and it worked.

Jesse

diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Fri Oct 10 18:08:59 2003
+++ b/arch/ia64/Makefile	Fri Oct 10 18:08:59 2003
@@ -64,7 +64,7 @@
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
-drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
+drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ arch/ia64/sn/
 drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
 boot := arch/ia64/hp/sim/boot
