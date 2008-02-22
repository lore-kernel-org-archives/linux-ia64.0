From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:20 +0000
Subject: [PATCH 04/28] ia64/xen: introduce synch bitops which is necessary for ia64/xen support.
Message-Id: <12036570474076-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/sync_bitops.h |   61 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 61 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/sync_bitops.h

diff --git a/include/asm-ia64/sync_bitops.h b/include/asm-ia64/sync_bitops.h
new file mode 100644
index 0000000..dc402be
--- /dev/null
+++ b/include/asm-ia64/sync_bitops.h
@@ -0,0 +1,61 @@
+#ifndef __XEN_SYNC_BITOPS_H__
+#define __XEN_SYNC_BITOPS_H__
+
+/*
+ * Copyright 1992, Linus Torvalds.
+ * Heavily modified to provide guaranteed strong synchronisation
+ * when communicating with Xen or other guest OSes running on other CPUs.
+ */
+
+#define ADDR (*(volatile long *) addr)
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
+static inline int sync_const_test_bit(int nr, const volatile void *addr)
+{
+	return test_bit(nr, addr);
+}
+
+static inline int sync_var_test_bit(int nr, volatile void *addr)
+{
+	return test_bit(nr, addr);
+}
+
+#define sync_cmpxchg	ia64_cmpxchg4_acq
+
+#define sync_test_bit(nr,addr)			\
+	(__builtin_constant_p(nr) ?		\
+	 sync_const_test_bit((nr), (addr)) :	\
+	 sync_var_test_bit((nr), (addr)))
+
+#define sync_cmpxchg_subword sync_cmpxchg
+
+#endif /* __XEN_SYNC_BITOPS_H__ */
-- 
1.5.3

