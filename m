From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 06:13:23 +0000
Subject: Re: [PATCH 04/28] ia64/xen: introduce synch bitops which is necessary for ia64/xen support.
Message-Id: <20080222061323.GC16685%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036570474076-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036570474076-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 21, 2008 at 11:42:28PM -0600, Robin Holt wrote:
> > +#define ADDR (*(volatile long *) addr)
> 
> This seems like a leftover #define.  Additionally, ADDR seems a bit
> vague and easily misused.  Since I don't see it used anywhere else in
> that patch, I will assume it should be tossed, but reserve the right to
> rescind this comment later.

It's a leftover from i386 version so that I eliminated it.


ia64/xen: introduce synch bitops which is necessary for ia64/xen support.


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/sync_bitops.h |   59 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/sync_bitops.h

diff --git a/include/asm-ia64/sync_bitops.h b/include/asm-ia64/sync_bitops.h
new file mode 100644
index 0000000..f56cd90
--- /dev/null
+++ b/include/asm-ia64/sync_bitops.h
@@ -0,0 +1,59 @@
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
+#define sync_cmpxchg	ia64_cmpxchg4_acq
+
+#define sync_test_bit(nr,addr)			\
+	(__builtin_constant_p(nr) ?		\
+	 sync_const_test_bit((nr), (addr)) :	\
+	 sync_var_test_bit((nr), (addr)))
+
+#define sync_cmpxchg_subword sync_cmpxchg
+
+#endif /* _ASM_IA64_SYNC_BITOPS_H */
-- 
1.5.3



-- 
yamahata
