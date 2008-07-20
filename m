From: roel kluin <roel.kluin@gmail.com>
Date: Sun, 20 Jul 2008 09:14:20 +0000
Subject: [PATCH] Altix serial: fix
Message-Id: <488301EC.7070204@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: pfg@sgi.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Patch was not tested on hardware
---
In function sn_sal_switch_to_asynch(): drivers/serial/sn_console.c:713:

HZ * SN_SAL_UART_FIFO_DEPTH / SN_SAL_UART_FIFO_SPEED_CPS;

After preprocessing (see defines in patch) this becomes HZ * 16 / 9600 / 10
(associativity from left to right), not equivalent to HZ * 16 / 960.
---
diff --git a/drivers/serial/sn_console.c b/drivers/serial/sn_console.c
index 019da2e..3a2683b 100644
--- a/drivers/serial/sn_console.c
+++ b/drivers/serial/sn_console.c
@@ -61,7 +61,7 @@
 #define SN_SAL_BUFFER_SIZE (64 * (1 << 10))
 
 #define SN_SAL_UART_FIFO_DEPTH 16
-#define SN_SAL_UART_FIFO_SPEED_CPS 9600/10
+#define SN_SAL_UART_FIFO_SPEED_CPS (9600/10)
 
 /* sn_transmit_chars() calling args */
 #define TRANSMIT_BUFFERED    0

