From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 19 May 2008 13:13:29 +0000
Subject: [PATCH 02/17] ia64/pv_ops: preparation: move the constants, LOAD_OFFSET, to a header file.
Message-Id: <12112028253631-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Move the LOAD_OFFSET definition from vmlinux.lds.S into system.h.
On paravirtualized environments, it is necessary to detect the
execution environment. One of the solutions is the multi entry point.
The multi entry point allows a boot loader to start the kernel execution
from the entry point which is different from the ELF entry point.
The non standard entry point will defined as the specialized elf note
which contains the LMA of the entry point symbol.
The constant, LOAD_OFFSET, is necessary to calculate the symbol's LMA.
Move the definition into the public header file to make it available
to the multi entry point support.

Cc: "He, Qing" <qing.he@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/vmlinux.lds.S |    1 -
 include/asm-ia64/system.h      |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 80622ac..98dcd9c 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -4,7 +4,6 @@
 #include <asm/system.h>
 #include <asm/pgtable.h>
 
-#define LOAD_OFFSET	(KERNEL_START - KERNEL_TR_PAGE_SIZE)
 #include <asm-generic/vmlinux.lds.h>
 
 #define IVT_TEXT							\
diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
index 26e250b..0db8c98 100644
--- a/include/asm-ia64/system.h
+++ b/include/asm-ia64/system.h
@@ -26,6 +26,7 @@
  */
 #define KERNEL_START		 (GATE_ADDR+__IA64_UL_CONST(0x100000000))
 #define PERCPU_ADDR		(-PERCPU_PAGE_SIZE)
+#define LOAD_OFFSET		(KERNEL_START - KERNEL_TR_PAGE_SIZE)
 
 #ifndef __ASSEMBLY__
 
-- 
1.5.3

