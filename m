From: Jingoo Han <jg1.han@samsung.com>
Date: Thu, 08 Aug 2013 08:36:27 +0000
Subject: [PATCH 06/10] serial: ioc4_serial: Staticize ioc4_serial_attach_one()
Message-Id: <006101ce9412$5f9eae00$1edc0a00$@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>
Cc: 'Jiri Slaby' <jslaby@suse.cz>, linux-serial@vger.kernel.org, 'Pat Gefre' <pfg@sgi.com>, linux-ia64@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>

ioc4_serial_attach_one() is used only in this file.
Also, ioc4_serial is not used; it can be removed.
Fix the following sparse warnings:

drivers/tty/serial/ioc4_serial.c:300:3: warning: symbol 'ioc4_serial' was not declared. Should it be static?
drivers/tty/serial/ioc4_serial.c:2771:1: warning: symbol 'ioc4_serial_attach_one' was not declared. Should it be static?

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/tty/serial/ioc4_serial.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/serial/ioc4_serial.c b/drivers/tty/serial/ioc4_serial.c
index e2520ab..1274499 100644
--- a/drivers/tty/serial/ioc4_serial.c
+++ b/drivers/tty/serial/ioc4_serial.c
@@ -297,7 +297,7 @@ struct ioc4_serial {
 	struct ioc4_uartregs uart_1;
 	struct ioc4_uartregs uart_2;
 	struct ioc4_uartregs uart_3;
-} ioc4_serial;
+};
 
 /* UART clock speed */
 #define IOC4_SER_XIN_CLK_66     66666667
@@ -2767,7 +2767,7 @@ ioc4_serial_core_attach(struct pci_dev *pdev, int port_type)
  *		called per card found from IOC4 master module.
  * @idd: Master module data for this IOC4
  */
-int
+static int
 ioc4_serial_attach_one(struct ioc4_driver_data *idd)
 {
 	unsigned long tmp_addr1;
-- 
1.7.10.4


