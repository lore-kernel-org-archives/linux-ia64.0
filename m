From: Christoph Hellwig <hch@lst.de>
Date: Mon, 12 Aug 2019 06:55:24 +0000
Subject: [PATCH 4/4] kernel: only define task_struct_whitelist conditionally
Message-Id: <20190812065524.19959-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190812065524.19959-1-hch@lst.de>
In-Reply-To: <20190812065524.19959-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

If CONFIG_ARCH_TASK_STRUCT_ALLOCATOR is set task_struct_whitelist is
never called, and thus generates a compiler warning.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/fork.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/fork.c b/kernel/fork.c
index 2852d0e76ea3..f79e3da0caaf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -768,6 +768,7 @@ static void set_max_threads(unsigned int max_threads_suggested)
 int arch_task_struct_size __read_mostly;
 #endif
 
+#ifndef CONFIG_ARCH_TASK_STRUCT_ALLOCATOR
 static void task_struct_whitelist(unsigned long *offset, unsigned long *size)
 {
 	/* Fetch thread_struct whitelist for the architecture. */
@@ -782,6 +783,7 @@ static void task_struct_whitelist(unsigned long *offset, unsigned long *size)
 	else
 		*offset += offsetof(struct task_struct, thread);
 }
+#endif /* CONFIG_ARCH_TASK_STRUCT_ALLOCATOR */
 
 void __init fork_init(void)
 {
-- 
2.20.1
