From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 17 Jul 2008 02:10:34 +0000
Subject: [PATCH 02/29] ia64/xen: reserve "break" numbers used for xen hypercalls.
Message-Id: <1216260662682-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

reserve "break" numbers used for xen hypercalls to avoid
reuse for something else.

Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/break.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/asm-ia64/break.h b/include/asm-ia64/break.h
index f034020..e90c40e 100644
--- a/include/asm-ia64/break.h
+++ b/include/asm-ia64/break.h
@@ -20,4 +20,13 @@
  */
 #define __IA64_BREAK_SYSCALL		0x100000
 
+/*
+ * Xen specific break numbers:
+ */
+#define __IA64_XEN_HYPERCALL		0x1000
+/* [__IA64_XEN_HYPERPRIVOP_START, __IA64_XEN_HYPERPRIVOP_MAX] is used
+   for xen hyperprivops */
+#define __IA64_XEN_HYPERPRIVOP_START	0x1
+#define __IA64_XEN_HYPERPRIVOP_MAX	0x1a
+
 #endif /* _ASM_IA64_BREAK_H */
-- 
1.5.3

