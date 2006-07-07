From: Horms <horms@verge.net.au>
Date: Fri, 07 Jul 2006 03:49:37 +0000
Subject: [PATCH] ia64, kexec: Remove inline declaration of efi_get_pal_addr()
Message-Id: <20060707034935.GA15342@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

efi_get_pal_addr() is already declared in linux/efi.h (which is already
indirectly included). This patch removes the inline declaration and
includes linux/efi.h directly for good measure.

Signed-Off-By: Horms <horms@verge.net.au>
---
 arch/ia64/kernel/machine_kexec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 573a6b8..f30aa87 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -16,6 +16,7 @@ #include <linux/mm.h>
 #include <linux/kexec.h>
 #include <linux/pci.h>
 #include <linux/cpu.h>
+#include <linux/efi.h>
 #include <asm/mmu_context.h>
 #include <asm/setup.h>
 #include <asm/mca.h>
@@ -98,7 +99,6 @@ #endif
  * Do not allocate memory (or fail in any way) in machine_kexec().
  * We are past the point of no return, committed to rebooting now. 
  */
-extern void *efi_get_pal_addr(void);
 void machine_kexec(struct kimage *image)
 {
 	relocate_new_kernel_t rnk;
-- 
1.4.1.rc1.g1ef9


