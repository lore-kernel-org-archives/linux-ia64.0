From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 03 Jul 2008 07:09:52 +0000
Subject: [PATCH] xen: compilation fix for ia64 support.
Message-Id: <20080703070952.GB15683%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jeremy@goop.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, xen-ia64-devel@lists.xensource.com, linux-ia64@vger.kernel.org

don't include asm/pvclock-abi.h directly, but asm/xen/pvclock-abi.h
At this moment linux ia64 won't accept asm/pvclock-abi.h because
there's no user of it. Instead make it include asm/xen/pvclock-abi.h
and create asm-x86/xen/pvclock-abi.h which includes asm-x86/pvclock-abi.h.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-x86/xen/pvclock-abi.h |    6 ++++++
 include/xen/interface/xen.h       |    2 +-
 2 files changed, 7 insertions(+), 1 deletions(-)
 create mode 100644 include/asm-x86/xen/pvclock-abi.h

diff --git a/include/asm-x86/xen/pvclock-abi.h b/include/asm-x86/xen/pvclock-abi.h
new file mode 100644
index 0000000..a4476db
--- /dev/null
+++ b/include/asm-x86/xen/pvclock-abi.h
@@ -0,0 +1,6 @@
+#ifndef __XEN_PVCLOCK_ABI_H
+#define __XEN_PVCLOCK_ABI_H
+
+#include <asm-x86/pvclock-abi.h>
+
+#endif /* __XEN_PVCLOCK_ABI_H */
diff --git a/include/xen/interface/xen.h b/include/xen/interface/xen.h
index 2befa3e..c36888b 100644
--- a/include/xen/interface/xen.h
+++ b/include/xen/interface/xen.h
@@ -10,7 +10,7 @@
 #define __XEN_PUBLIC_XEN_H__
 
 #include <asm/xen/interface.h>
-#include <asm/pvclock-abi.h>
+#include <asm/xen/pvclock-abi.h>
 
 /*
  * XEN "SYSTEM CALLS" (a.k.a. HYPERCALLS).
-- 
1.5.3

