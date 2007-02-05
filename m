From: Horms <horms@verge.net.au>
Date: Mon, 05 Feb 2007 01:16:20 +0000
Subject: [PATCH] [IA64] kexec: Remove inline declaration of efi_get_pal_addr()
Message-Id: <20070205011617.GA31046@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove the Remove inline declaration of efi_get_pal_addr() as it is
declared in linux/efi.h.
		       
Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2006-12-18 11:14:44.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2006-12-18 11:22:35.000000000 +0900
@@ -14,6 +14,7 @@
 #include <linux/kexec.h>
 #include <linux/cpu.h>
 #include <linux/irq.h>
+#include <linux/efi.h>
 #include <asm/mmu_context.h>
 #include <asm/setup.h>
 #include <asm/delay.h>
@@ -83,7 +84,6 @@
  * Do not allocate memory (or fail in any way) in machine_kexec().
  * We are past the point of no return, committed to rebooting now.
  */
-extern void *efi_get_pal_addr(void);
 static void ia64_machine_kexec(struct unw_frame_info *info, void *arg)
 {
 	struct kimage *image = arg;
