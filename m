From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:30:32 +0000
Subject: [PATCH 01/23] ia64/xen: introduce synch bitops which is necessary for ia64/xen support.
Message-Id: <12095586542642-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077166303062-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077166303062-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define sync bitops which is necessary for ia64/xen.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/sync_bitops.h |   57 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 57 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/sync_bitops.h

diff --git a/include/asm-ia64/sync_bitops.h b/include/asm-ia64/sync_bitops.h
new file mode 100644
index 0000000..27dc777
--- /dev/null
+++ b/include/asm-ia64/sync_bitops.h
@@ -0,0 +1,57 @@
+#ifndef _ASM_IA64_SYNC_BITOPS_H
+#define _ASM_IA64_SYNC_BITOPS_H
+
+/*
+ * Copyright 1992, Linus Torvalds.
+ * Heavily modified to provide guaranteed strong synchronisation
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
+#define sync_cmpxchg(ptr, old, new) cmpxchg_acq((ptr), (old), (new))
+
+#define sync_test_bit(nr,addr)			\
+	(__builtin_constant_p(nr) ?		\
+	 sync_const_test_bit((nr), (addr)) :	\
+	 sync_var_test_bit((nr), (addr)))
+
+#endif /* _ASM_IA64_SYNC_BITOPS_H */
-- 
1.5.3

