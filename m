From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 24 Aug 2005 10:57:38 +0000
Subject: [2.6 patch] arch/ia64/hp/sim/boot/fw-emu.c: remove egcs workaround
Message-Id: <20050824105738.GK5603@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <davidm@hpl.hp.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Kernel 2.6 doesn't support egcs, and I didn't find any user of this 
function.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

Note: I haven't tested the compilation of this patch.

--- linux-2.6.13-rc6-mm2-full/arch/ia64/hp/sim/boot/fw-emu.c.old	2005-08-24 12:38:22.000000000 +0200
+++ linux-2.6.13-rc6-mm2-full/arch/ia64/hp/sim/boot/fw-emu.c	2005-08-24 12:38:58.000000000 +0200
@@ -237,17 +237,6 @@
 	return ((struct sal_ret_values) {status, r9, r10, r11});
 }
 
-
-/*
- * This is here to work around a bug in egcs-1.1.1b that causes the
- * compiler to crash (seems like a bug in the new alias analysis code.
- */
-void *
-id (long addr)
-{
-	return (void *) addr;
-}
-
 struct ia64_boot_param *
 sys_fw_init (const char *args, int arglen)
 {

