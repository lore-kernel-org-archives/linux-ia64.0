From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Sat, 27 Apr 2019 12:52:12 +0000
Subject: [PATCH 31/41] drivers: tty: serial: ioc4_serial: use pr_*() instead of printk()
Message-Id: <1556369542-13247-32-git-send-email-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

This fixes a bunch of checkpatch warnings:

    WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    #930: FILE: drivers/tty/serial/ioc4_serial.c:930:
    +		printk(KERN_ERR

    WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    #945: FILE: drivers/tty/serial/ioc4_serial.c:945:
    +			printk(KERN_ERR

    WARNING: printk() should include KERN_<LEVEL> facility level
    #1028: FILE: drivers/tty/serial/ioc4_serial.c:1028:
    +		printk ("%s : %d : mem 0x%p sio_ir 0x%x sio_ies 0x%x "

    WARNING: space prohibited between function name and open parenthesis '('
    #1028: FILE: drivers/tty/serial/ioc4_serial.c:1028:
    +		printk ("%s : %d : mem 0x%p sio_ir 0x%x sio_ies 0x%x "

    WARNING: Prefer [subsystem eg: netdev]_info([subsystem]dev, ... then dev_info(dev, ... then pr_info(...  to printk(KERN_INFO ...
    #1064: FILE: drivers/tty/serial/ioc4_serial.c:1064:
    +	printk(KERN_INFO "IOC4 firmware revision %d\n", ioc4_revid);

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #1066: FILE: drivers/tty/serial/ioc4_serial.c:1066:
    +		printk(KERN_WARNING

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #1080: FILE: drivers/tty/serial/ioc4_serial.c:1080:
    +			printk(KERN_WARNING

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #1870: FILE: drivers/tty/serial/ioc4_serial.c:1870:
    +			printk(KERN_WARNING "IOC4 serial: "

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #2170: FILE: drivers/tty/serial/ioc4_serial.c:2170:
+			printk(KERN_WARNING "IOC4 serial: "

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #2796: FILE: drivers/tty/serial/ioc4_serial.c:2796:
    +		printk(KERN_WARNING

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #2804: FILE: drivers/tty/serial/ioc4_serial.c:2804:
    +		printk(KERN_WARNING

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #2818: FILE: drivers/tty/serial/ioc4_serial.c:2818:
    +		printk(KERN_WARNING "ioc4_attach_one"

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #2828: FILE: drivers/tty/serial/ioc4_serial.c:2828:
    +		printk(KERN_WARNING

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #2861: FILE: drivers/tty/serial/ioc4_serial.c:2861:
    +		printk(KERN_WARNING

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #2917: FILE: drivers/tty/serial/ioc4_serial.c:2917:
    +		printk(KERN_WARNING

    WARNING: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    #2923: FILE: drivers/tty/serial/ioc4_serial.c:2923:
    +		printk(KERN_WARNING

Signed-off-by: Enrico Weigelt <info@metux.net>
---
 drivers/tty/serial/ioc4_serial.c | 39 +++++++++++++++------------------------
 1 file changed, 15 insertions(+), 24 deletions(-)

diff --git a/drivers/tty/serial/ioc4_serial.c b/drivers/tty/serial/ioc4_serial.c
index 21c1b8f..4ab67f1 100644
--- a/drivers/tty/serial/ioc4_serial.c
+++ b/drivers/tty/serial/ioc4_serial.c
@@ -927,8 +927,7 @@ static void handle_dma_error_intr(void *arg, uint32_t other_ir)
 	writel(hooks->intr_dma_error, &port->ip_mem->other_ir.raw);
 
 	if (readl(&port->ip_mem->pci_err_addr_l.raw) & IOC4_PCI_ERR_ADDR_VLD) {
-		printk(KERN_ERR
-			"PCI error address is 0x%llx, "
+		pr_err("PCI error address is 0x%llx, "
 				"master is serial port %c %s\n",
 		     (((uint64_t)readl(&port->ip_mem->pci_err_addr_h)
 							 << 32)
@@ -942,8 +941,7 @@ static void handle_dma_error_intr(void *arg, uint32_t other_ir)
 
 		if (readl(&port->ip_mem->pci_err_addr_l.raw)
 						& IOC4_PCI_ERR_ADDR_MUL_ERR) {
-			printk(KERN_ERR
-				"Multiple errors occurred\n");
+			pr_err("Multiple errors occurred\n");
 		}
 	}
 	spin_unlock_irqrestore(&port->ip_lock, flags);
@@ -1025,7 +1023,7 @@ static irqreturn_t ioc4_intr(int irq, void *arg)
 		unsigned long flag;
 
 		spin_lock_irqsave(&soft->is_ir_lock, flag);
-		printk ("%s : %d : mem 0x%p sio_ir 0x%x sio_ies 0x%x "
+		pr_debug("%s : %d : mem 0x%p sio_ir 0x%x sio_ies 0x%x "
 				"other_ir 0x%x other_ies 0x%x mask 0x%x\n",
 		     __func__, __LINE__,
 		     (void *)mem, readl(&mem->sio_ir.raw),
@@ -1061,9 +1059,9 @@ static inline int ioc4_attach_local(struct ioc4_driver_data *idd)
 	/* IOC4 firmware must be at least rev 62 */
 	pci_read_config_word(pdev, PCI_COMMAND_SPECIAL, &ioc4_revid);
 
-	printk(KERN_INFO "IOC4 firmware revision %d\n", ioc4_revid);
+	pr_info("IOC4 firmware revision %d\n", ioc4_revid);
 	if (ioc4_revid < ioc4_revid_min) {
-		printk(KERN_WARNING
+		pr_warn(
 		    "IOC4 serial not supported on firmware rev %d, "
 				"please upgrade to rev %d or higher\n",
 				ioc4_revid, ioc4_revid_min);
@@ -1077,8 +1075,7 @@ static inline int ioc4_attach_local(struct ioc4_driver_data *idd)
 							port_number++) {
 		port = kzalloc(sizeof(struct ioc4_port), GFP_KERNEL);
 		if (!port) {
-			printk(KERN_WARNING
-				"IOC4 serial memory not available for port\n");
+			pr_warn("IOC4 serial memory not available for port\n");
 			goto free;
 		}
 		spin_lock_init(&port->ip_lock);
@@ -1867,7 +1864,7 @@ static void handle_intr(void *arg, uint32_t sio_ir)
 		uint32_t shadow;
 
 		if ( loop_counter-- <= 0 ) {
-			printk(KERN_WARNING "IOC4 serial: "
+			pr_warn("IOC4 serial: "
 					"possible hang condition/"
 					"port stuck on interrupt.\n");
 			break;
@@ -2167,7 +2164,7 @@ static inline int do_read(struct uart_port *the_port, unsigned char *buf,
 		entry = (struct ring_entry *)((caddr_t)inring + cons_ptr);
 
 		if ( loop_counter-- <= 0 ) {
-			printk(KERN_WARNING "IOC4 serial: "
+			pr_warn("IOC4 serial: "
 					"possible hang condition/"
 					"port stuck on read.\n");
 			break;
@@ -2793,16 +2790,14 @@ static int ioc4_serial_remove_one(struct ioc4_driver_data *idd)
 
 	if (!request_mem_region(tmp_addr1, sizeof(struct ioc4_serial),
 					"sioc4_uart")) {
-		printk(KERN_WARNING
-			"ioc4 (%p): unable to get request region for "
+		pr_warn("ioc4 (%p): unable to get request region for "
 				"uart space\n", (void *)idd->idd_pdev);
 		ret = -ENODEV;
 		goto out1;
 	}
 	serial = ioremap(tmp_addr1, sizeof(struct ioc4_serial));
 	if (!serial) {
-		printk(KERN_WARNING
-			 "ioc4 (%p) : unable to remap ioc4 serial register\n",
+		pr_warn("ioc4 (%p) : unable to remap ioc4 serial register\n",
 				(void *)idd->idd_pdev);
 		ret = -ENODEV;
 		goto out2;
@@ -2815,7 +2810,7 @@ static int ioc4_serial_remove_one(struct ioc4_driver_data *idd)
 	control = kzalloc(sizeof(struct ioc4_control), GFP_KERNEL);
 
 	if (!control) {
-		printk(KERN_WARNING "ioc4_attach_one"
+		pr_warn("ioc4_attach_one"
 		       ": unable to get memory for the IOC4\n");
 		ret = -ENOMEM;
 		goto out2;
@@ -2825,8 +2820,7 @@ static int ioc4_serial_remove_one(struct ioc4_driver_data *idd)
 	/* Allocate the soft structure */
 	soft = kzalloc(sizeof(struct ioc4_soft), GFP_KERNEL);
 	if (!soft) {
-		printk(KERN_WARNING
-		       "ioc4 (%p): unable to get memory for the soft struct\n",
+		pr_warn("ioc4 (%p): unable to get memory for the soft struct\n",
 		       (void *)idd->idd_pdev);
 		ret = -ENOMEM;
 		goto out3;
@@ -2858,8 +2852,7 @@ static int ioc4_serial_remove_one(struct ioc4_driver_data *idd)
 				"sgi-ioc4serial", soft)) {
 		control->ic_irq = idd->idd_pdev->irq;
 	} else {
-		printk(KERN_WARNING
-		    "%s : request_irq fails for IRQ 0x%x\n ",
+		pr_warn("%s : request_irq fails for IRQ 0x%x\n ",
 			__func__, idd->idd_pdev->irq);
 	}
 	ret = ioc4_attach_local(idd);
@@ -2914,14 +2907,12 @@ static int __init ioc4_serial_init(void)
 
 	/* register with serial core */
 	if ((ret = uart_register_driver(&ioc4_uart_rs232)) < 0) {
-		printk(KERN_WARNING
-			"%s: Couldn't register rs232 IOC4 serial driver\n",
+		pr_warn("%s: Couldn't register rs232 IOC4 serial driver\n",
 			__func__);
 		goto out;
 	}
 	if ((ret = uart_register_driver(&ioc4_uart_rs422)) < 0) {
-		printk(KERN_WARNING
-			"%s: Couldn't register rs422 IOC4 serial driver\n",
+		pr_warn("%s: Couldn't register rs422 IOC4 serial driver\n",
 			__func__);
 		goto out_uart_rs232;
 	}
-- 
1.9.1
