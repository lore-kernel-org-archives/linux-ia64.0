From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 26 Oct 2004 21:34:16 +0000
Subject: [PATCH] fix generic_defconfig build breakage
Message-Id: <200410261534.16809.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Include uaccess.h in elfcore32.h

This makes generic_defconfig build again.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/ia32/elfcore32.h 1.4 vs edited ==--- 1.4/arch/ia64/ia32/elfcore32.h 2004-10-06 23:55:22 -06:00
+++ edited/arch/ia64/ia32/elfcore32.h 2004-10-26 15:02:27 -06:00
@@ -9,6 +9,7 @@
 #define _ELFCORE32_H_
 
 #include <asm/intrinsics.h>
+#include <asm/uaccess.h>
 
 #define USE_ELF_CORE_DUMP 1
 
