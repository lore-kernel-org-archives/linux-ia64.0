From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 06 Apr 2004 22:22:49 +0000
Subject: [PATCH] don't offer GEN_RTC on ia64
Message-Id: <200404061622.49260.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: p_gortmaker@yahoo.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

gen_rtc.c doesn't work on ia64 (we don't have asm/rtc.h, for starters),
so don't offer it there.

=== drivers/char/Kconfig 1.32 vs edited ==--- 1.32/drivers/char/Kconfig	Tue Mar 16 03:10:34 2004
+++ edited/drivers/char/Kconfig	Tue Apr  6 15:58:28 2004
@@ -768,7 +768,7 @@
 
 config GEN_RTC
 	tristate "Generic /dev/rtc emulation"
-	depends on RTC!=y
+	depends on RTC!=y && !IA64
 	---help---
 	  If you say Y here and create a character special file /dev/rtc with
 	  major number 10 and minor number 135 using mknod ("man mknod"), you
