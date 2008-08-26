From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:58:19 +0000
Subject: [PATCH 07/30] ia64/xen: add a necessary header file to compile include/xen/interface/xen.h
Message-Id: <1219730322-11687-8-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Create include/asm-ia64/pvclock-abi.h to compile which includes
include/asm-x86/pvclock-abi.h because ia64/xen uses same structure.
Hopefully include/asm-x86/pvclock-abi.h would be moved to somewhere
more generic.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/pvclock-abi.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/pvclock-abi.h

diff --git a/arch/ia64/include/asm/pvclock-abi.h b/arch/ia64/include/asm/pvclock-abi.h
new file mode 100644
index 0000000..63cbcca
--- /dev/null
+++ b/arch/ia64/include/asm/pvclock-abi.h
@@ -0,0 +1,5 @@
+/*
+ * use same structure to x86's
+ * Hopefully asm-x86/pvclock-abi.h would be moved to somewhere more generic.
+ */
+#include <asm-x86/pvclock-abi.h>
-- 
1.6.0.rc0.42.g186458

