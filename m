From: Mark Maule <maule@sgi.com>
Date: Tue, 26 Apr 2005 15:00:40 +0000
Subject: [PATCH 2.6.12 1/1] altix: enable vgacon support
Message-Id: <20050426150040.10738.56345.77906@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Altix patch to enable use of vgacon driver on that platform.  Depends on the
PCDP generalization patch discussed at:

	http://marc.theaimsgroup.com/?l=linux-ia64&m1446235101939&w=2

Signed-off-by: Mark Maule <maule@sgi.com>

diff -Nru a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
--- a/arch/ia64/configs/sn2_defconfig	2005-04-26 09:56:26 -05:00
+++ b/arch/ia64/configs/sn2_defconfig	2005-04-26 09:56:26 -05:00
@@ -99,7 +99,7 @@
 # Firmware Drivers
 #
 CONFIG_EFI_VARS=y
-# CONFIG_EFI_PCDP is not set
+CONFIG_EFI_PCDP=y
 CONFIG_BINFMT_ELF=y
 # CONFIG_BINFMT_MISC is not set
 
@@ -649,7 +649,7 @@
 #
 # Console display driver support
 #
-# CONFIG_VGA_CONSOLE is not set
+CONFIG_VGA_CONSOLE=y
 CONFIG_DUMMY_CONSOLE=y
 
 #
diff -Nru a/arch/ia64/sn/kernel/iomv.c b/arch/ia64/sn/kernel/iomv.c
--- a/arch/ia64/sn/kernel/iomv.c	2005-04-26 09:56:26 -05:00
+++ b/arch/ia64/sn/kernel/iomv.c	2005-04-26 09:56:26 -05:00
@@ -9,12 +9,16 @@
 #include <linux/module.h>
 #include <asm/io.h>
 #include <asm/delay.h>
+#include <asm/vga.h>
 #include <asm/sn/nodepda.h>
 #include <asm/sn/simulator.h>
 #include <asm/sn/pda.h>
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/shub_mmr.h>
 
+#define IS_LEGACY_VGA_IOPORT(p) \
+	(((p) >= 0x3b0 && (p) <= 0x3bb) || ((p) >= 0x3c0 && (p) <= 0x3df))
+
 /**
  * sn_io_addr - convert an in/out port to an i/o address
  * @port: port to convert
@@ -26,6 +30,8 @@
 void *sn_io_addr(unsigned long port)
 {
 	if (!IS_RUNNING_ON_SIMULATOR()) {
+		if (IS_LEGACY_VGA_IOPORT(port))
+			port += vga_console_iobase;
 		/* On sn2, legacy I/O ports don't point at anything */
 		if (port < (64 * 1024))
 			return NULL;
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	2005-04-26 09:56:26 -05:00
+++ b/arch/ia64/sn/kernel/setup.c	2005-04-26 09:56:26 -05:00
@@ -36,6 +36,7 @@
 #include <asm/machvec.h>
 #include <asm/system.h>
 #include <asm/processor.h>
+#include <asm/vga.h>
 #include <asm/sn/arch.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/pda.h>
@@ -265,14 +266,17 @@
 	int major = sn_sal_rev_major(), minor = sn_sal_rev_minor();
 	extern void sn_cpu_init(void);
 
+#if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
 	/*
-	 * If the generic code has enabled vga console support - lets
-	 * get rid of it again. This is a kludge for the fact that ACPI
-	 * currtently has no way of informing us if legacy VGA is available
-	 * or not.
+	 * If there was a primary vga adapter identified through the
+	 * EFI PCDP table, make it the preferred console.  Otherwise
+	 * zero out conswitchp.
 	 */
-#if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
-	if (conswitchp = &vga_con) {
+
+	if (vga_console_membase) {
+		/* usable vga ... make tty0 the preferred default console */
+		add_preferred_console("tty", 0, NULL);
+	} else {
 		printk(KERN_DEBUG "SGI: Disabling VGA console\n");
 #ifdef CONFIG_DUMMY_CONSOLE
 		conswitchp = &dummy_con;
