From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:02 +0000
Subject: [PATCH 21/41] drivers: tty: serial: cpm_uart: fix includes
Message-Id: <1556369542-13247-22-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fixing checkpatch warning:

    WARNING: Use #include <linux/io.h> instead of <asm/io.h>
    #25: FILE: drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c:25:
    +#include <asm/io.h>

    WARNING: Use #include <linux/io.h> instead of <asm/io.h>
    +#include <asm/io.h>

    WARNING: Use #include <linux/delay.h> instead of <asm/delay.h>
    +#include <asm/delay.h>

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/cpm_uart/cpm_uart_core.c | 4 ++--
 drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_core.c b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
index 374b8bb..c831d31 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_core.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
@@ -33,10 +33,10 @@
 #include <linux/gpio.h>
 #include <linux/of_gpio.h>
 #include <linux/clk.h>
+#include <linux/io.h>
+#include <linux/delay.h>
 
-#include <asm/io.h>
 #include <asm/irq.h>
-#include <asm/delay.h>
 #include <asm/fs_pd.h>
 #include <asm/udbg.h>
 
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
index ef1ae08..40cfcf4 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
@@ -21,8 +21,8 @@
 #include <linux/device.h>
 #include <linux/memblock.h>
 #include <linux/dma-mapping.h>
+#include <linux/io.h>
 
-#include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/fs_pd.h>
 #include <asm/prom.h>
-- 
1.9.1
