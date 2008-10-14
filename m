From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 14 Oct 2008 05:51:20 +0000
Subject: [PATCH 05/32] ia64/xen: introduce sync bitops which is necessary for ia64/xen support.
Message-Id: <1223963507-28056-6-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define sync bitops which is necessary for ia64/xen.
This bit operation is used to communicate with VMM or other guest kernel
Even when this kernel is built for UP, VMM might be SMP so that those operation
must always use atomic operation.

Cc: Robin Holt <holt@sgi.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>
---
 arch/ia64/include/asm/sync_bitops.h |   51 +++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/sync_bitops.h

diff --git a/arch/ia64/include/asm/sync_bitops.h b/arch/ia64/include/asm/sync_bitops.h
new file mode 100644
index 0000000..593c12e
--- /dev/null
+++ b/arch/ia64/include/asm/sync_bitops.h
@@ -0,0 +1,51 @@
+#ifndef _ASM_IA64_SYNC_BITOPS_H
+#define _ASM_IA64_SYNC_BITOPS_H
+
+/*
+ * Copyright (C) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *
+ * Based on synch_bitops.h which Dan Magenhaimer wrote.
+ *
+ * bit operations which provide guaranteed strong synchronisation
+ * when communicating with Xen or other guest OSes running on other CPUs.
+ */
+
+static inline void sync_set_bit(int nr, volatile void *addr)
+{
+	set_bit(nr, addr);
+}
+
+static inline void sync_clear_bit(int nr, volatile void *addr)
+{
+	clear_bit(nr, addr);
+}
+
+static inline void sync_change_bit(int nr, volatile void *addr)
+{
+	change_bit(nr, addr);
+}
+
+static inline int sync_test_and_set_bit(int nr, volatile void *addr)
+{
+	return test_and_set_bit(nr, addr);
+}
+
+static inline int sync_test_and_clear_bit(int nr, volatile void *addr)
+{
+	return test_and_clear_bit(nr, addr);
+}
+
+static inline int sync_test_and_change_bit(int nr, volatile void *addr)
+{
+	return test_and_change_bit(nr, addr);
+}
+
+static inline int sync_test_bit(int nr, const volatile void *addr)
+{
+	return test_bit(nr, addr);
+}
+
+#define sync_cmpxchg(ptr, old, new)				\
+	((__typeof__(*(ptr)))cmpxchg_acq((ptr), (old), (new)))
+
+#endif /* _ASM_IA64_SYNC_BITOPS_H */
-- 
1.6.0.2

