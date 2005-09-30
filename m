From: Greg Edwards <edwardsg@sgi.com>
Date: Fri, 30 Sep 2005 20:04:22 +0000
Subject: [PATCH] set altix preferred console
Message-Id: <20050930200422.GD13855@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Set the preferred console on Altix, if no console=<console> was passed
on the boot line.

Bjorn, the hunk I removed in pcdp.c broke the vga console on Altix and
the virtual terminal if any console= was passed in.  For example, if
you booted with console=ttySG0 (the L1 serial console), there would be
no login prompt on tty1 when you got to multiuser, even though a getty
was running.  Is removing this ok?


Signed-off-by: Greg Edwards <edwardsg@sgi.com>


 arch/ia64/sn/kernel/setup.c |   12 +++++++++---
 drivers/firmware/pcdp.c     |    3 ---
 2 files changed, 9 insertions(+), 6 deletions(-)

Index: git-linus/arch/ia64/sn/kernel/setup.c
=================================--- git-linus.orig/arch/ia64/sn/kernel/setup.c	2005-09-12 11:34:36.342472611 -0500
+++ git-linus/arch/ia64/sn/kernel/setup.c	2005-09-30 14:49:50.941056190 -0500
@@ -281,15 +281,21 @@ void __init sn_setup(char **cmdline_p)
 #if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
 	/*
 	 * If there was a primary vga adapter identified through the
-	 * EFI PCDP table, make it the preferred console.  Otherwise
+	 * EFI PCDP table, and no console was specified on the boot
+	 * line, make vga the preferred console.
+	 *
+	 * If no vga adapter was found, and no console was specified on
+	 * the boot line, make the L1 console the preferred console and
 	 * zero out conswitchp.
 	 */
 
 	if (vga_console_membase) {
-		/* usable vga ... make tty0 the preferred default console */
-		add_preferred_console("tty", 0, NULL);
+		if (!strstr(*cmdline_p, "console="))
+			add_preferred_console("tty", 0, NULL);
 	} else {
 		printk(KERN_DEBUG "SGI: Disabling VGA console\n");
+		if (!strstr(*cmdline_p, "console="))
+			add_preferred_console("ttySG", 0, NULL);
 #ifdef CONFIG_DUMMY_CONSOLE
 		conswitchp = &dummy_con;
 #else
Index: git-linus/drivers/firmware/pcdp.c
=================================--- git-linus.orig/drivers/firmware/pcdp.c	2005-08-24 16:06:59.911622221 -0500
+++ git-linus/drivers/firmware/pcdp.c	2005-09-30 14:49:50.998667555 -0500
@@ -99,9 +99,6 @@ efi_setup_pcdp_console(char *cmdline)
 	if (strstr(cmdline, "console=hcdp")) {
 		if (pcdp->rev < 3)
 			serial = 1;
-	} else if (strstr(cmdline, "console=")) {
-		printk(KERN_INFO "Explicit \"console=\"; ignoring PCDP\n");
-		return -ENODEV;
 	}
 
 	if (pcdp->rev < 3 && efi_uart_console_only())
