From: Andrzej Hajda <andrzej.hajda@intel.com>
Date: Wed, 18 Jan 2023 15:44:47 +0000
Subject: [PATCH v5 4/7] llist: simplify __llist_del_all
Message-Id: <20230118154450.73842-4-andrzej.hajda@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230118153529.57695-1-andrzej.hajda@intel.com>
 <20230118154450.73842-1-andrzej.hajda@intel.com>
In-Reply-To: <20230118154450.73842-1-andrzej.hajda@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org
Cc: Andrzej Hajda <andrzej.hajda@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, Mark Rutland <mark.rutland@arm.com>

llist_del_all uses xchg, let's use __xchg here.

Signed-off-by: Andrzej Hajda <andrzej.hajda@intel.com>
---
 include/linux/llist.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/llist.h b/include/linux/llist.h
index 85bda2d02d65be..4dc1d185ea98ab 100644
--- a/include/linux/llist.h
+++ b/include/linux/llist.h
@@ -50,6 +50,7 @@
 
 #include <linux/atomic.h>
 #include <linux/container_of.h>
+#include <linux/non-atomic/xchg.h>
 #include <linux/stddef.h>
 #include <linux/types.h>
 
@@ -241,10 +242,7 @@ static inline struct llist_node *llist_del_all(struct llist_head *head)
 
 static inline struct llist_node *__llist_del_all(struct llist_head *head)
 {
-	struct llist_node *first = head->first;
-
-	head->first = NULL;
-	return first;
+	return __xchg(&head->first, NULL);
 }
 
 extern struct llist_node *llist_del_first(struct llist_head *head);
-- 
2.34.1
