From: Julia Lawall <julia@diku.dk>
Date: Fri, 15 Oct 2010 12:54:48 +0000
Subject: [PATCH 6/7] drivers/serial/ioc3_serial.c: Return -ENOMEM on memory allocation failure
Message-Id: <1287147610-8041-6-git-send-email-julia@diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org

From: Julia Lawall <julia@diku.dk>

In this code, 0 is returned on memory allocation failure, even though other
failures return -ENOMEM or other similar values.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression ret;
expression x,e1,e2,e3;
@@

ret = 0
... when != ret = e1
*x = \(kmalloc\|kcalloc\|kzalloc\)(...)
... when != ret = e2
if (x = NULL) { ... when != ret = e3
  return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/serial/ioc3_serial.c |    1 +
 1 file changed, 1 insertion(+)

diff -u -p a/drivers/serial/ioc3_serial.c b/drivers/serial/ioc3_serial.c
--- a/drivers/serial/ioc3_serial.c
+++ b/drivers/serial/ioc3_serial.c
@@ -2045,6 +2045,7 @@ ioc3uart_probe(struct ioc3_submodule *is
 		if (!port) {
 			printk(KERN_WARNING
 			       "IOC3 serial memory not available for port\n");
+			ret = -ENOMEM;
 			goto out4;
 		}
 		spin_lock_init(&port->ip_lock);

