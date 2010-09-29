From: Rahul Ruikar <rahul.ruikar@gmail.com>
Date: Wed, 29 Sep 2010 04:53:19 +0000
Subject: [PATCH] serial: ioc3_serial: release resources in error return path
Message-Id: <1285735279-2952-1-git-send-email-rahul.ruikar@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>, Greg Kroah-Hartman <gregkh@suse.de>, Alan Cox <alan@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rahul Ruikar <rahul.ruikar@gmail.com>

In ioc3uart_probe()
resources were not released during error return path
- ports[phys_port]

Signed-off-by: Rahul Ruikar <rahul.ruikar@gmail.com>
---
 drivers/serial/ioc3_serial.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/serial/ioc3_serial.c b/drivers/serial/ioc3_serial.c
index 93de907..1a182cf 100644
--- a/drivers/serial/ioc3_serial.c
+++ b/drivers/serial/ioc3_serial.c
@@ -2017,6 +2017,7 @@ ioc3uart_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 	struct ioc3_port *port;
 	struct ioc3_port *ports[PORTS_PER_CARD];
 	int phys_port;
+	int cnt;
 
 	DPRINT_CONFIG(("%s (0x%p, 0x%p)\n", __func__, is, idd));
 
@@ -2044,7 +2045,7 @@ ioc3uart_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 		if (!port) {
 			printk(KERN_WARNING
 			       "IOC3 serial memory not available for port\n");
-			goto out4;
+			goto out3;
 		}
 		spin_lock_init(&port->ip_lock);
 
@@ -2138,13 +2139,16 @@ ioc3uart_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 	/* register port with the serial core */
 
 	if ((ret = ioc3_serial_core_attach(is, idd)))
-		goto out4;
+		goto out3;
 
 	Num_of_ioc3_cards++;
 
 	return ret;
 
 	/* error exits that give back resources */
+out3:
+	for (cnt = 0; cnt < phys_port; cnt++)
+		kfree(ports[cnt]);
 out4:
 	kfree(card_ptr);
 	return ret;
-- 
1.7.2.3

