From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 19 Jun 2008 12:05:56 +0000
Subject: Re: [PATCH 02/27] ia64/xen: introduce synch bitops which is necessary for ia64/xen support.
Message-Id: <20080619120556.GN11378%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1213084043534-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1213084043534-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 17, 2008 at 04:24:10PM -0700, Luck, Tony wrote:

> +/*
> + * Copyright 1992, Linus Torvalds.
> + * Heavily modified to provide guaranteed strong synchronisation
> + * when communicating with Xen or other guest OSes running on other CPUs.
> + */
> 
> Presumably Linus didn't write this in 1992.  Perhaps this file
> contains enough new material to warrant your own copyright?

Ah yes, I carried out the comment from old files.
I had hesited to eliminated the copyright.

> +static inline int sync_const_test_bit(int nr, const volatile void *addr)
> +{
> +       return test_bit(nr, addr);
> +}
> +
> +static inline int sync_var_test_bit(int nr, volatile void *addr)
> +{
> +       return test_bit(nr, addr);
> +}
>  ...
> +#define sync_test_bit(nr,addr)                 \
> +       (__builtin_constant_p(nr) ?             \
> +        sync_const_test_bit((nr), (addr)) :    \
> +        sync_var_test_bit((nr), (addr)))
> 
> What use is this?  It doesn't matter whether "nr" is constant or
> not you still end up using "test_bit" ... so why make the compiler
> do all the extra work when you just mean this?

Yes.

From 45188e8d0d45b12ac7293098bf115874caf7bb5f Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 19 Jun 2008 18:31:07 +0900
Subject: [PATCH] ia64/xen: introduce synch bitops which is necessary for ia64/xen support.

define sync bitops which is necessary for ia64/xen.

Cc: Robin Holt <holt@sgi.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>
---
 include/asm-ia64/sync_bitops.h |   50 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/sync_bitops.h

diff --git a/include/asm-ia64/sync_bitops.h b/include/asm-ia64/sync_bitops.h
new file mode 100644
index 0000000..8d4b9af
--- /dev/null
+++ b/include/asm-ia64/sync_bitops.h
@@ -0,0 +1,50 @@
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
+#define sync_cmpxchg(ptr, old, new) cmpxchg_acq((ptr), (old), (new))
+
+#endif /* _ASM_IA64_SYNC_BITOPS_H */
-- 
1.5.3



-- 
yamahata
