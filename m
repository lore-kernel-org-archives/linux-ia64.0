From: Greg Edwards <edwardsg@sgi.com>
Date: Tue, 30 Aug 2005 20:34:46 +0000
Subject: execute sn2 early console setup only on sn2s
Message-Id: <20050830203446.GA7680@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Encapsulate the sn2 early console setup in a platform check.
HP reported this causing some problems with console setup on some of
their boxes.

Signed-off-by: Greg Edwards <edwardsg@sgi.com>


Index: git-linus/arch/ia64/kernel/setup.c
=================================--- git-linus.orig/arch/ia64/kernel/setup.c	2005-08-30 15:13:11.399460142 -0500
+++ git-linus/arch/ia64/kernel/setup.c	2005-08-30 15:15:53.959188707 -0500
@@ -288,7 +288,7 @@ early_console_setup (char *cmdline)
 	int earlycons = 0;
 
 #ifdef CONFIG_SERIAL_SGI_L1_CONSOLE
-	{
+	if (ia64_platform_is("sn2")) {
 		extern int sn_serial_console_early_setup(void);
 		if (!sn_serial_console_early_setup())
 			earlycons++;
