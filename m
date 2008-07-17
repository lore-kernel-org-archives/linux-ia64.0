From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 17 Jul 2008 02:10:39 +0000
Subject: [PATCH 07/29] ia64/xen: add a neccessary header file to copmle include/xen/interface/xen.h
Message-Id: <1216260662692-git-send-email-yamahata@valinux.co.jp>
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
 include/asm-ia64/pvclock-abi.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/pvclock-abi.h

diff --git a/include/asm-ia64/pvclock-abi.h b/include/asm-ia64/pvclock-abi.h
new file mode 100644
index 0000000..1c34d11
--- /dev/null
+++ b/include/asm-ia64/pvclock-abi.h
@@ -0,0 +1,5 @@
+/*
+ * use same streucute to x86's
+ * Hopefully asm-x86/pvclock-abi.h would be moved to somewhere more generic.
+ */
+#include <asm-x86/pvclock-abi.h>
-- 
1.5.3

