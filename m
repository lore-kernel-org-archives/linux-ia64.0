From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 29 Jun 2004 16:46:32 +0000
Subject: [PATCH] update early printk for new console driver
Message-Id: <200406290946.32162.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_ozZ4ANVuNa31Zd7"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_ozZ4ANVuNa31Zd7
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The Altix console driver has been replaced in Andrew's tree by a new one that 
uses the serial core API.  Update the early_console_setup routine to use the 
new config option so that it's ready when the driver hits Linus' tree.  This 
will also fix a build bug since the old driver hasn't been updated.

Jesse

--Boundary-00=_ozZ4ANVuNa31Zd7
Content-Type: text/plain;
  charset="us-ascii";
  name="early-printk-update.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="early-printk-update.patch"

===== arch/ia64/kernel/setup.c 1.75 vs edited =====
--- 1.75/arch/ia64/kernel/setup.c	2004-06-22 10:51:27 -07:00
+++ edited/arch/ia64/kernel/setup.c	2004-06-29 09:38:30 -07:00
@@ -292,7 +292,7 @@
 static int __init
 early_console_setup (void)
 {
-#ifdef CONFIG_SGI_L1_SERIAL_CONSOLE
+#ifdef CONFIG_SERIAL_SGI_L1_CONSOLE
 	{
 		extern int sn_serial_console_early_setup(void);
 		if(!sn_serial_console_early_setup())

--Boundary-00=_ozZ4ANVuNa31Zd7--
