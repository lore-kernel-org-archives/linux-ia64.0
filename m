From: Martin Pool <mbp@samba.org>
Date: Wed, 06 Aug 2003 06:00:28 +0000
Subject: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106014965332221@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As of linux-2.6.0-test2-ia64-030729, there seems to be no
asm-ia64/floppy.h, and so the fd driver won't work.  

Might this patch to make sure it does not accidentally get configured
on be accepted?  

--- linux-2.6.0test2-ia64/drivers/block/Kconfig.~1~	2003-07-29 12:07:02.000000000 +1000
+++ linux-2.6.0test2-ia64/drivers/block/Kconfig	2003-08-06 15:55:16.000000000 +1000
@@ -6,7 +6,7 @@ menu "Block devices"
 
 config BLK_DEV_FD
 	tristate "Normal floppy disk support"
-	depends on !X86_PC9800
+	depends on !X86_PC9800 && !IA64
 	---help---
 	  If you want to use the floppy disk drive(s) of your PC under Linux,
 	  say Y. Information about this driver, especially important for IBM


-- 
Martin 
