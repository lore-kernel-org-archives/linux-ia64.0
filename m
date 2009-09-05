From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Sat, 05 Sep 2009 00:04:28 +0000
Subject: [PATCH] ioc4_serial: fix printk format warnings
Message-Id: <20090904170428.bda55420.randy.dunlap@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

ia64:
drivers/serial/ioc4_serial.c:943: warning: format '%lx' expects type 'long unsigned int', but argument 2 has type 'long long unsigned int'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Pat Gefre <pfg@sgi.com>
---
 drivers/serial/ioc4_serial.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.31-rc8-git1.orig/drivers/serial/ioc4_serial.c
+++ linux-2.6.31-rc8-git1/drivers/serial/ioc4_serial.c
@@ -930,7 +930,7 @@ static void handle_dma_error_intr(void *
 
 	if (readl(&port->ip_mem->pci_err_addr_l.raw) & IOC4_PCI_ERR_ADDR_VLD) {
 		printk(KERN_ERR
-			"PCI error address is 0x%lx, "
+			"PCI error address is 0x%llx, "
 				"master is serial port %c %s\n",
 		     (((uint64_t)readl(&port->ip_mem->pci_err_addr_h)
 							 << 32)




---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
