From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 29 Jul 2004 16:54:05 +0000
Subject: [PATCH] minor cyclone cleanup
Message-Id: <200407291054.05720.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trivial cleanup.  BTW, the ia64 cyclone code has no copyright or license.

There's also an arch/i386/kernel/timers/timer_cyclone.c that looks
suspiciously similar, and few if any actual architecture dependencies
in either the i386 or the ia64 files.  Why are they different?


Make cyclone_setup() take no args, rather than an ignored "char *"
and return void.  Fix typos and whitespace.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/Kconfig 1.76 vs edited ==--- 1.76/arch/ia64/Kconfig	2004-06-23 12:19:08 -06:00
+++ edited/arch/ia64/Kconfig	2004-07-29 10:48:05 -06:00
@@ -179,10 +179,10 @@
 	  See <file:Documentation/vm/numa> for more.
 
 config IA64_CYCLONE
-	bool "Support Cyclone(EXA) Time Source"
+	bool "Cyclone (EXA) Time Source support"
 	help
-		Say Y here to enable support for IBM EXA Cyclone time source.
-		If you're unsure, answer N.
+	  Say Y here to enable support for IBM EXA Cyclone time source.
+	  If you're unsure, answer N.
 
 config IOSAPIC
 	bool
=== arch/ia64/kernel/acpi.c 1.72 vs edited ==--- 1.72/arch/ia64/kernel/acpi.c	2004-07-15 15:41:29 -06:00
+++ edited/arch/ia64/kernel/acpi.c	2004-07-29 10:34:27 -06:00
@@ -293,20 +293,20 @@
 	return 0;
 }
 
-/* Hook from generic ACPI tables.c */
-void __init acpi_madt_oem_check(char *oem_id, char *oem_table_id)
+static void __init
+acpi_madt_oem_check (char *oem_id, char *oem_table_id)
 {
 	if (!strncmp(oem_id, "IBM", 3) &&
-	    (!strncmp(oem_table_id, "SERMOW", 6))){
+	    (!strncmp(oem_table_id, "SERMOW", 6))) {
 
-		/* Unfortunatly ITC_DRIFT is not yet part of the
+		/*
+		 * Unfortunately ITC_DRIFT is not yet part of the
 		 * official SAL spec, so the ITC_DRIFT bit is not
 		 * set by the BIOS on this hardware.
 		 */
 		sal_platform_features |= IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT;
 
-		/*Start cyclone clock*/
-		cyclone_setup(0);
+		cyclone_setup();
 	}
 }
 
=== arch/ia64/kernel/cyclone.c 1.1 vs edited ==--- 1.1/arch/ia64/kernel/cyclone.c	2004-02-18 08:10:58 -07:00
+++ edited/arch/ia64/kernel/cyclone.c	2004-07-29 10:33:52 -06:00
@@ -10,10 +10,9 @@
 #define CYCLONE_TIMER_FREQ 100000000
 
 int use_cyclone;
-int __init cyclone_setup(char *str)
+void __init cyclone_setup(void)
 {
 	use_cyclone = 1;
-	return 1;
 }
 
 static u32* volatile cyclone_timer;	/* Cyclone MPMC0 register */
=== include/asm-ia64/cyclone.h 1.1 vs edited ==--- 1.1/include/asm-ia64/cyclone.h	2004-02-18 08:10:58 -07:00
+++ edited/include/asm-ia64/cyclone.h	2004-07-29 10:33:53 -06:00
@@ -3,10 +3,10 @@
 
 #ifdef	CONFIG_IA64_CYCLONE
 extern int use_cyclone;
-extern int __init cyclone_setup(char*);
+extern void __init cyclone_setup(void);
 #else	/* CONFIG_IA64_CYCLONE */
 #define use_cyclone 0
-static inline void cyclone_setup(char* s)
+static inline void cyclone_setup(void)
 {
 	printk(KERN_ERR "Cyclone Counter: System not configured"
 					" w/ CONFIG_IA64_CYCLONE.\n");
