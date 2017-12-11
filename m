From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:22 +0000
Subject: [PATCH 10/13] sysfs: do not use print_symbol()
Message-Id: <20171211125025.2270-11-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

print_symbol() uses extra stack space to sprintf() symbol
information and then to feed that buffer to printk()

  char buffer[KSYM_SYMBOL_LEN];

  sprint_symbol(buffer, address);
  printk(fmt, buffer);

Replace print_symbol() with a direct printk("%pS") call.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 fs/sysfs/file.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 39c75a86c67f..bfcbe486d385 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -12,7 +12,6 @@
 
 #include <linux/module.h>
 #include <linux/kobject.h>
-#include <linux/kallsyms.h>
 #include <linux/slab.h>
 #include <linux/list.h>
 #include <linux/mutex.h>
@@ -70,8 +69,8 @@ static int sysfs_kf_seq_show(struct seq_file *sf, void *v)
 	 * indicate truncated result or overflow in normal use cases.
 	 */
 	if (count >= (ssize_t)PAGE_SIZE) {
-		print_symbol("fill_read_buffer: %s returned bad count\n",
-			(unsigned long)ops->show);
+		printk("fill_read_buffer: %pS returned bad count\n",
+				ops->show);
 		/* Try to struggle along */
 		count = PAGE_SIZE - 1;
 	}
-- 
2.15.1

