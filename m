From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 11 Dec 2017 12:50:21 +0000
Subject: [PATCH 09/13] drivers: do not use print_symbol()
Message-Id: <20171211125025.2270-10-sergey.senozhatsky@gmail.com>
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
 drivers/base/core.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index bf45587bcb46..36e20498159b 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -20,7 +20,6 @@
 #include <linux/of.h>
 #include <linux/of_device.h>
 #include <linux/genhd.h>
-#include <linux/kallsyms.h>
 #include <linux/mutex.h>
 #include <linux/pm_runtime.h>
 #include <linux/netdevice.h>
@@ -685,8 +684,8 @@ static ssize_t dev_attr_show(struct kobject *kobj, struct attribute *attr,
 	if (dev_attr->show)
 		ret = dev_attr->show(dev, dev_attr, buf);
 	if (ret >= (ssize_t)PAGE_SIZE) {
-		print_symbol("dev_attr_show: %s returned bad count\n",
-				(unsigned long)dev_attr->show);
+		printk("dev_attr_show: %pS returned bad count\n",
+				dev_attr->show);
 	}
 	return ret;
 }
-- 
2.15.1

