From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Jun 2003 16:22:35 +0000
Subject: [PATCH] generic kernel support for sn2
MIME-Version: 1
Content-Type: multipart/mixed; boundary="AH+kv8CCoFf6qPuz"
Message-Id: <marc-linux-ia64-105595335915515@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--AH+kv8CCoFf6qPuz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I _think_ I got this one right (at least, it booted on hw).  It should
allow generic kernels to include the sn2 code.

Thanks,
Jesse

--AH+kv8CCoFf6qPuz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-generic-2.5.69-ia64-bk.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1142  -> 1.1143 
#	  arch/ia64/Makefile	1.53    -> 1.54   
#	arch/ia64/sn/kernel/machvec.c	1.6     -> 1.7    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/17	jbarnes@tomahawk.engr.sgi.com	1.1143
# CONFIG_IA64_GENERIC fixes
# --------------------------------------------
#
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Tue Jun 17 14:44:53 2003
+++ b/arch/ia64/Makefile	Tue Jun 17 14:44:53 2003
@@ -66,7 +66,8 @@
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
-drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/
+drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ \
+				   arch/ia64/sn/
 
 boot := arch/ia64/boot
 
diff -Nru a/arch/ia64/sn/kernel/machvec.c b/arch/ia64/sn/kernel/machvec.c
--- a/arch/ia64/sn/kernel/machvec.c	Tue Jun 17 14:44:53 2003
+++ b/arch/ia64/sn/kernel/machvec.c	Tue Jun 17 14:44:53 2003
@@ -31,4 +31,5 @@
  */
 
 #define MACHVEC_PLATFORM_NAME	sn2
+#define MACHVEC_PLATFORM_HEADER	<asm/machvec_sn2.h>
 #include <asm/machvec_init.h>

--AH+kv8CCoFf6qPuz--
