From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 16 Jul 2003 22:24:41 +0000
Subject: [PATCH] fix generic compile
Message-Id: <marc-linux-ia64-105839457407771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This will fix the generic compile by removing sn2 from the list of
targets, since it depends on the new discontig code, which hasn't gone
in yet.

Thanks,
Jesse


=== arch/ia64/Makefile 1.55 vs edited ==--- 1.55/arch/ia64/Makefile	Wed Jun 18 22:09:21 2003
+++ edited/arch/ia64/Makefile	Wed Jul 16 15:22:34 2003
@@ -66,8 +66,7 @@
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
-drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ \
-				   arch/ia64/sn/
+drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
 
 boot := arch/ia64/boot
 
