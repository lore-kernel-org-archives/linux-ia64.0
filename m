From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 24 Mar 2004 21:35:09 +0000
Subject: [PATCH] don't offer BLK_DEV_FD for ia64
Message-Id: <200403241435.09692.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We can't build floppy.o on ia64, so why bother asking?  I know this
is outside arch/ia64, but I'm not the right person to send this to
Andrew.

=== drivers/block/Kconfig 1.20 vs edited ==--- 1.20/drivers/block/Kconfig	Fri Mar 19 13:39:25 2004
+++ edited/drivers/block/Kconfig	Tue Mar 23 17:04:33 2004
@@ -6,7 +6,7 @@
 
 config BLK_DEV_FD
 	tristate "Normal floppy disk support"
-	depends on (!X86_PC9800 && !ARCH_S390 && !M68K) || Q40 || (SUN3X && BROKEN)
+	depends on (!X86_PC9800 && !ARCH_S390 && !M68K && !IA64) || Q40 || (SUN3X && BROKEN)
 	---help---
 	  If you want to use the floppy disk drive(s) of your PC under Linux,
 	  say Y. Information about this driver, especially important for IBM
