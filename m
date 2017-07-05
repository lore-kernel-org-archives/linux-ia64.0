From: Joe Perches <joe@perches.com>
Date: Wed, 05 Jul 2017 20:02:22 +0000
Subject: [PATCH 13/18] drivers: tty: serial: Move inline before return type
Message-Id: <55d3e89d50bb03d603bfb28019fab07f48bdc714.1499284835.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1499284835.git.joe@perches.com>
In-Reply-To: <cover.1499284835.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Pat Gefre <pfg@sgi.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Make the code like the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/tty/serial/ioc3_serial.c | 4 ++--
 drivers/tty/serial/ioc4_serial.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/tty/serial/ioc3_serial.c b/drivers/tty/serial/ioc3_serial.c
index 2a61dd6b4009..906ee770ff4a 100644
--- a/drivers/tty/serial/ioc3_serial.c
+++ b/drivers/tty/serial/ioc3_serial.c
@@ -377,7 +377,7 @@ static struct ioc3_port *get_ioc3_port(struct uart_port *the_port)
  *			called per port from attach...
  * @port: port to initialize
  */
-static int inline port_init(struct ioc3_port *port)
+static inline int port_init(struct ioc3_port *port)
 {
 	uint32_t sio_cr;
 	struct port_hooks *hooks = port->ip_hooks;
@@ -1430,7 +1430,7 @@ static int receive_chars(struct uart_port *the_port)
  * @pending: interrupts to handle
  */
 
-static int inline
+static inline int
 ioc3uart_intr_one(struct ioc3_submodule *is,
 			struct ioc3_driver_data *idd,
 			unsigned int pending)
diff --git a/drivers/tty/serial/ioc4_serial.c b/drivers/tty/serial/ioc4_serial.c
index f96bcf9bee25..43d7d32eb150 100644
--- a/drivers/tty/serial/ioc4_serial.c
+++ b/drivers/tty/serial/ioc4_serial.c
@@ -824,7 +824,7 @@ pending_intrs(struct ioc4_soft *soft, int type)
  *			called per port from attach...
  * @port: port to initialize
  */
-static int inline port_init(struct ioc4_port *port)
+static inline int port_init(struct ioc4_port *port)
 {
 	uint32_t sio_cr;
 	struct hooks *hooks = port->ip_hooks;
@@ -1048,7 +1048,7 @@ static irqreturn_t ioc4_intr(int irq, void *arg)
  *			IOC4 with serial ports in the system.
  * @idd: Master module data for this IOC4
  */
-static int inline ioc4_attach_local(struct ioc4_driver_data *idd)
+static inline int ioc4_attach_local(struct ioc4_driver_data *idd)
 {
 	struct ioc4_port *port;
 	struct ioc4_port *ports[IOC4_NUM_SERIAL_PORTS];
-- 
2.10.0.rc2.1.g053435c

