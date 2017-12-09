From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 09 Dec 2017 18:03:54 +0000
Subject: [PATCH 1/3] serial: ioc3: Delete error messages for a failed memory allocation in ioc3uart_probe()
Message-Id: <3975ebe3-f1fa-a545-696d-06d701e707cc@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <962f1172-3f27-c6b5-653f-c09f2e8fe431@users.sourceforge.net>
In-Reply-To: <962f1172-3f27-c6b5-653f-c09f2e8fe431@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Pat Gefre <pfg@sgi.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 9 Dec 2017 18:34:36 +0100

Omit extra messages for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/tty/serial/ioc3_serial.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/tty/serial/ioc3_serial.c b/drivers/tty/serial/ioc3_serial.c
index d8a1cdd6a53d..0007c2d65028 100644
--- a/drivers/tty/serial/ioc3_serial.c
+++ b/drivers/tty/serial/ioc3_serial.c
@@ -2017,11 +2017,9 @@ ioc3uart_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 	DPRINT_CONFIG(("%s (0x%p, 0x%p)\n", __func__, is, idd));
 
 	card_ptr = kzalloc(sizeof(struct ioc3_card), GFP_KERNEL);
-	if (!card_ptr) {
-		printk(KERN_WARNING "ioc3_attach_one"
-		       ": unable to get memory for the IOC3\n");
+	if (!card_ptr)
 		return -ENOMEM;
-	}
+
 	idd->data[is->id] = card_ptr;
 	Submodule_slot = is->id;
 
@@ -2038,8 +2036,6 @@ ioc3uart_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 	for (phys_port = 0; phys_port < PORTS_PER_CARD; phys_port++) {
 		port = kzalloc(sizeof(struct ioc3_port), GFP_KERNEL);
 		if (!port) {
-			printk(KERN_WARNING
-			       "IOC3 serial memory not available for port\n");
 			ret = -ENOMEM;
 			goto out4;
 		}
-- 
2.15.1

