From: Andrzej Hajda <andrzej.hajda@intel.com>
Date: Wed, 18 Jan 2023 15:44:48 +0000
Subject: [PATCH v5 5/7] io_uring: use __xchg if possible
Message-Id: <20230118154450.73842-5-andrzej.hajda@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230118153529.57695-1-andrzej.hajda@intel.com>
 <20230118154450.73842-1-andrzej.hajda@intel.com>
In-Reply-To: <20230118154450.73842-1-andrzej.hajda@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org
Cc: Andrzej Hajda <andrzej.hajda@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, Mark Rutland <mark.rutland@arm.com>

Recently introduced helper simplifies the code.

Signed-off-by: Andrzej Hajda <andrzej.hajda@intel.com>
---
 io_uring/io_uring.c | 7 ++-----
 io_uring/slist.h    | 6 ++----
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/io_uring/io_uring.c b/io_uring/io_uring.c
index 2ac1cd8d23ea62..2b46a692d69022 100644
--- a/io_uring/io_uring.c
+++ b/io_uring/io_uring.c
@@ -54,6 +54,7 @@
 #include <linux/fdtable.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/non-atomic/xchg.h>
 #include <linux/percpu.h>
 #include <linux/slab.h>
 #include <linux/bvec.h>
@@ -1095,8 +1096,6 @@ static void __io_req_find_next_prep(struct io_kiocb *req)
 
 static inline struct io_kiocb *io_req_find_next(struct io_kiocb *req)
 {
-	struct io_kiocb *nxt;
-
 	/*
 	 * If LINK is set, we have dependent requests in this chain. If we
 	 * didn't fail this request, queue the first one up, moving any other
@@ -1105,9 +1104,7 @@ static inline struct io_kiocb *io_req_find_next(struct io_kiocb *req)
 	 */
 	if (unlikely(req->flags & IO_DISARM_MASK))
 		__io_req_find_next_prep(req);
-	nxt = req->link;
-	req->link = NULL;
-	return nxt;
+	return __xchg(&req->link, NULL);
 }
 
 static void ctx_flush_and_put(struct io_ring_ctx *ctx, bool *locked)
diff --git a/io_uring/slist.h b/io_uring/slist.h
index f27601fa46607b..d3a743a1adc626 100644
--- a/io_uring/slist.h
+++ b/io_uring/slist.h
@@ -2,6 +2,7 @@
 #define INTERNAL_IO_SLIST_H
 
 #include <linux/io_uring_types.h>
+#include <linux/non-atomic/xchg.h>
 
 #define wq_list_for_each(pos, prv, head)			\
 	for (pos = (head)->first, prv = NULL; pos; prv = pos, pos = (pos)->next)
@@ -121,10 +122,7 @@ static inline void wq_list_del(struct io_wq_work_list *list,
 static inline
 struct io_wq_work_node *wq_stack_extract(struct io_wq_work_node *stack)
 {
-	struct io_wq_work_node *node = stack->next;
-
-	stack->next = node->next;
-	return node;
+	return __xchg(&stack->next, stack->next->next);
 }
 
 static inline struct io_wq_work *wq_next_work(struct io_wq_work *work)
-- 
2.34.1
