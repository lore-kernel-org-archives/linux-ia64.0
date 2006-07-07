From: Horms <horms@verge.net.au>
Date: Fri, 07 Jul 2006 04:13:20 +0000
Subject: [PATCH] ia64, kexec: tidy up declaration of relocate_new_kernel_t
Message-Id: <20060707041318.GA32296@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This brings the style of the declearation of relocate_new_kernel_t into line
with other architectures (x86_64 and i386). In aprticular, the parameters
now have names, and the function is asmlinkage NORET_TYPE.

Signed-off-by: Horms <horms@verge.net.au>
---
 arch/ia64/kernel/machine_kexec.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index f30aa87..302a9f4 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -26,8 +26,11 @@ #include <asm/tlbflush.h>
 #include <asm/delay.h>
 #include <asm/meminit.h>
 
-typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
-		struct ia64_boot_param *, unsigned long);
+typedef asmlinkage NORET_TYPE void (*relocate_new_kernel_t)(
+					unsigned long indirection_page,
+					unsigned long start_address,
+					struct ia64_boot_param *boot_param,
+					unsigned long pal_addr) ATTRIB_NORET;
 
 /*
  * Do what every setup is needed on image and the
-- 
1.4.1.rc1.g1ef9

