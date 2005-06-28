From: Greg Edwards <edwardsg@sgi.com>
Date: Tue, 28 Jun 2005 18:12:32 +0000
Subject: [PATCH] remove CONFIG_IA64_SGI_SN_SIM
Message-Id: <20050628181231.GA31665@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch removes the CONFIG_IA64_SGI_SN_SIM option entirely, allowing
any kernel bootable on sn2 to also be booted in the simulator.  This
applies on top of Jack's patch:

	[PATCH] - Updated macros for SGI simulator
	http://marc.theaimsgroup.com/?l=linux-ia64&m1997806519069&w=2

Boot tested on Altix and HP rx2600.

Signed-off-by: Greg Edwards <edwardsg@sgi.com>

 arch/ia64/Kconfig               |    7 -------
 arch/ia64/configs/sn2_defconfig |    1 -
 include/asm-ia64/sn/simulator.h |    9 +--------
 3 files changed, 1 insertion(+), 16 deletions(-)

Index: git-linus/arch/ia64/Kconfig
=================================--- git-linus.orig/arch/ia64/Kconfig	2005-06-28 12:27:43.208466306 -0500
+++ git-linus/arch/ia64/Kconfig	2005-06-28 12:28:06.424871741 -0500
@@ -220,13 +220,6 @@ config IOSAPIC
 	depends on !IA64_HP_SIM
 	default y
 
-config IA64_SGI_SN_SIM
-	bool "SGI Medusa Simulator Support"
-	depends on IA64_SGI_SN2 || IA64_GENERIC
-	help
-	  If you are compiling a kernel that will run under SGI's IA-64
-	  simulator (Medusa) then say Y, otherwise say N.
-
 config IA64_SGI_SN_XP
 	tristate "Support communication between SGI SSIs"
 	select IA64_UNCACHED_ALLOCATOR
Index: git-linus/include/asm-ia64/sn/simulator.h
=================================--- git-linus.orig/include/asm-ia64/sn/simulator.h	2005-06-28 12:27:58.599490117 -0500
+++ git-linus/include/asm-ia64/sn/simulator.h	2005-06-28 12:28:58.772124861 -0500
@@ -13,16 +13,9 @@
 #define SNMAGIC 0xaeeeeeee8badbeefL
 #define IS_MEDUSA()			({long sn; asm("mov %0=cpuid[%1]" : "=r"(sn) : "r"(2)); sn = SNMAGIC;})
 
-#ifdef CONFIG_IA64_SGI_SN_SIM
 #define SIMULATOR_SLEEP()		asm("nop.i 0x8beef")
-#define IS_RUNNING_ON_SIMULATOR() 	(sn_prom_type)
+#define IS_RUNNING_ON_SIMULATOR()	(sn_prom_type)
 #define IS_RUNNING_ON_FAKE_PROM()	(sn_prom_type = 2)
 extern int sn_prom_type;		/* 0=hardware, 1=medusa/realprom, 2=medusa/fakeprom */
-#else
-#define IS_RUNNING_ON_SIMULATOR()	(0)
-#define IS_RUNNING_ON_FAKE_PROM()	(0)
-#define SIMULATOR_SLEEP()
-
-#endif
 
 #endif /* _ASM_IA64_SN_SIMULATOR_H */
Index: git-linus/arch/ia64/configs/sn2_defconfig
=================================--- git-linus.orig/arch/ia64/configs/sn2_defconfig	2005-06-28 10:12:06.468948546 -0500
+++ git-linus/arch/ia64/configs/sn2_defconfig	2005-06-28 12:35:15.616887071 -0500
@@ -81,7 +81,6 @@ CONFIG_HOLES_IN_ZONE=y
 CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
-CONFIG_IA64_SGI_SN_SIM=y
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
