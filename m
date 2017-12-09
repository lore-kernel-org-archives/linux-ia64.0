From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 09 Dec 2017 18:06:28 +0000
Subject: [PATCH 3/3] serial: ioc3: Adjust two function calls together with a variable assignment
Message-Id: <cb8e7643-bc3d-780e-58cf-497874305574@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <962f1172-3f27-c6b5-653f-c09f2e8fe431@users.sourceforge.net>
In-Reply-To: <962f1172-3f27-c6b5-653f-c09f2e8fe431@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Pat Gefre <pfg@sgi.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 9 Dec 2017 18:48:57 +0100

The script "checkpatch.pl" pointed information out like the following.

ERROR: do not use assignment in if condition

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/tty/serial/ioc3_serial.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/tty/serial/ioc3_serial.c b/drivers/tty/serial/ioc3_serial.c
index d211bb1407d3..0170d6f2bcdf 100644
--- a/drivers/tty/serial/ioc3_serial.c
+++ b/drivers/tty/serial/ioc3_serial.c
@@ -1540,8 +1540,8 @@ ioc3uart_intr_one(struct ioc3_submodule *is,
 			 * hasn't been delivered to the cpu yet anyway, even
 			 * though we see it as asserted when we read the sio_ir.
 			 */
-			if ((sio_ir = PENDING(card_ptr, idd))
-					& hooks->intr_rx_high) {
+			sio_ir = PENDING(card_ptr, idd);
+			if (sio_ir & hooks->intr_rx_high) {
 				if (port->ip_flags & READ_ABORTED) {
 					rx_high_rd_aborted++;
 				}
@@ -2162,10 +2162,10 @@ static struct ioc3_submodule ioc3uart_ops = {
  */
 static int __init ioc3uart_init(void)
 {
-	int ret;
-
 	/* register with serial core */
-	if ((ret = uart_register_driver(&ioc3_uart)) < 0) {
+	int ret = uart_register_driver(&ioc3_uart);
+
+	if (ret < 0) {
 		printk(KERN_WARNING
 		       "%s: Couldn't register IOC3 uart serial driver\n",
 		       __func__);
-- 
2.15.1

