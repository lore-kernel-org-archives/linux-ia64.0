From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jun 2008 23:24:10 +0000
Subject: RE: [PATCH 02/27] ia64/xen: introduce synch bitops which is
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3061C5BF1@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1213084043534-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1213084043534-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just started digging through these ... part 01/27 was fine. But here
are a couple of comments for part 02/27

+/*
+ * Copyright 1992, Linus Torvalds.
+ * Heavily modified to provide guaranteed strong synchronisation
+ * when communicating with Xen or other guest OSes running on other CPUs.
+ */

Presumably Linus didn't write this in 1992.  Perhaps this file
contains enough new material to warrant your own copyright?

+static inline int sync_const_test_bit(int nr, const volatile void *addr)
+{
+       return test_bit(nr, addr);
+}
+
+static inline int sync_var_test_bit(int nr, volatile void *addr)
+{
+       return test_bit(nr, addr);
+}
 ...
+#define sync_test_bit(nr,addr)                 \
+       (__builtin_constant_p(nr) ?             \
+        sync_const_test_bit((nr), (addr)) :    \
+        sync_var_test_bit((nr), (addr)))

What use is this?  It doesn't matter whether "nr" is constant or
not you still end up using "test_bit" ... so why make the compiler
do all the extra work when you just mean this?

static inline int sync_test_bit(int nr, volatile void *addr)
{
        return test_bit(nr, addr);
}

-Tony
