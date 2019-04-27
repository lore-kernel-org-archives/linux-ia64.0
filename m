From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:03 +0000
Subject: [PATCH 22/41] drivers: tty: serial: cpm_uart: fix logging calls
Message-Id: <1556369542-13247-23-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Fix checkpatch warnings by using pr_err():

    WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    #109: FILE: drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c:109:
    +		printk(KERN_ERR

    WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    #128: FILE: drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c:128:
    +		printk(KERN_ERR

    WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    +           printk(KERN_ERR

    WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    +           printk(KERN_ERR

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c | 6 ++----
 drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c | 6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
index 56fc527..aed61e9 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
@@ -71,8 +71,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
 	dpmemsz = sizeof(cbd_t) * (pinfo->rx_nrfifos + pinfo->tx_nrfifos);
 	dp_offset = cpm_dpalloc(dpmemsz, 8);
 	if (IS_ERR_VALUE(dp_offset)) {
-		printk(KERN_ERR
-		       "cpm_uart_cpm1.c: could not allocate buffer descriptors\n");
+		pr_err("cpm_uart_cpm1.c: could not allocate buffer descriptors\n");
 		return -ENOMEM;
 	}
 	dp_mem = cpm_dpram_addr(dp_offset);
@@ -90,8 +89,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
 
 	if (mem_addr = NULL) {
 		cpm_dpfree(dp_offset);
-		printk(KERN_ERR
-		       "cpm_uart_cpm1.c: could not allocate coherent memory\n");
+		pr_err("cpm_uart_cpm1.c: could not allocate coherent memory\n");
 		return -ENOMEM;
 	}
 
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
index 40cfcf4..a0fccda 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
@@ -106,8 +106,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
 	dpmemsz = sizeof(cbd_t) * (pinfo->rx_nrfifos + pinfo->tx_nrfifos);
 	dp_offset = cpm_dpalloc(dpmemsz, 8);
 	if (IS_ERR_VALUE(dp_offset)) {
-		printk(KERN_ERR
-		       "cpm_uart_cpm.c: could not allocate buffer descriptors\n");
+		pr_err("cpm_uart_cpm.c: could not allocate buffer descriptors\n");
 		return -ENOMEM;
 	}
 
@@ -125,8 +124,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
 
 	if (mem_addr = NULL) {
 		cpm_dpfree(dp_offset);
-		printk(KERN_ERR
-		       "cpm_uart_cpm.c: could not allocate coherent memory\n");
+		pr_err("cpm_uart_cpm.c: could not allocate coherent memory\n");
 		return -ENOMEM;
 	}
 
-- 
1.9.1
