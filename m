From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 09 Dec 2017 18:05:13 +0000
Subject: [PATCH 2/3] serial: ioc3: Improve size determinations in ioc3uart_probe()
Message-Id: <e1d44286-d7e9-d118-ef02-fd4b1cd3a330@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <962f1172-3f27-c6b5-653f-c09f2e8fe431@users.sourceforge.net>
In-Reply-To: <962f1172-3f27-c6b5-653f-c09f2e8fe431@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Pat Gefre <pfg@sgi.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 9 Dec 2017 18:38:13 +0100

Replace the specification of two data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/tty/serial/ioc3_serial.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/serial/ioc3_serial.c b/drivers/tty/serial/ioc3_serial.c
index 0007c2d65028..d211bb1407d3 100644
--- a/drivers/tty/serial/ioc3_serial.c
+++ b/drivers/tty/serial/ioc3_serial.c
@@ -2016,7 +2016,7 @@ ioc3uart_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 
 	DPRINT_CONFIG(("%s (0x%p, 0x%p)\n", __func__, is, idd));
 
-	card_ptr = kzalloc(sizeof(struct ioc3_card), GFP_KERNEL);
+	card_ptr = kzalloc(sizeof(*card_ptr), GFP_KERNEL);
 	if (!card_ptr)
 		return -ENOMEM;
 
@@ -2034,7 +2034,7 @@ ioc3uart_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 
 	/* Create port structures for each port */
 	for (phys_port = 0; phys_port < PORTS_PER_CARD; phys_port++) {
-		port = kzalloc(sizeof(struct ioc3_port), GFP_KERNEL);
+		port = kzalloc(sizeof(*port), GFP_KERNEL);
 		if (!port) {
 			ret = -ENOMEM;
 			goto out4;
-- 
2.15.1

