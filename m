From: Bill Pemberton <wfp5p@virginia.edu>
Date: Mon, 19 Nov 2012 18:21:50 +0000
Subject: [PATCH 161/493] tty: remove use of __devinit
Message-Id: <1353349642-3677-161-git-send-email-wfp5p@virginia.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Jiri Slaby <jirislaby@gmail.com> 
Cc: Alan Cox <alan@linux.intel.com> 
Cc: Tobias Klauser <tklauser@distanz.ch> 
Cc: Lucas Tavares <lucaskt@linux.vnet.ibm.com> 
Cc: "David S. Miller" <davem@davemloft.net> 
Cc: Peter Korsgaard <jacmet@sunsite.dk> 
Cc: Tony Prisk <linux@prisktech.co.nz> 
Cc: linuxppc-dev@lists.ozlabs.org 
Cc: linux-serial@vger.kernel.org 
Cc: nios2-dev@sopc.et.ntust.edu.tw 
Cc: linux-ia64@vger.kernel.org 
Cc: sparclinux@vger.kernel.org 
Cc: linux-arm-kernel@lists.infradead.org 
---
 drivers/tty/cyclades.c                      | 16 ++++++++--------
 drivers/tty/ehv_bytechan.c                  |  2 +-
 drivers/tty/hvc/hvc_opal.c                  |  2 +-
 drivers/tty/hvc/hvc_vio.c                   |  2 +-
 drivers/tty/hvc/hvc_xen.c                   |  2 +-
 drivers/tty/hvc/hvcs.c                      |  8 ++++----
 drivers/tty/isicom.c                        |  6 +++---
 drivers/tty/moxa.c                          |  2 +-
 drivers/tty/mxser.c                         |  6 +++---
 drivers/tty/nozomi.c                        |  2 +-
 drivers/tty/serial/8250/8250.c              |  2 +-
 drivers/tty/serial/8250/8250_acorn.c        |  2 +-
 drivers/tty/serial/8250/8250_dw.c           |  2 +-
 drivers/tty/serial/8250/8250_em.c           |  2 +-
 drivers/tty/serial/8250/8250_hp300.c        |  4 ++--
 drivers/tty/serial/8250/8250_pci.c          |  4 ++--
 drivers/tty/serial/8250/8250_pnp.c          |  8 ++++----
 drivers/tty/serial/altera_jtaguart.c        |  2 +-
 drivers/tty/serial/altera_uart.c            |  2 +-
 drivers/tty/serial/apbuart.c                |  2 +-
 drivers/tty/serial/ar933x_uart.c            |  2 +-
 drivers/tty/serial/arc_uart.c               | 10 +++++-----
 drivers/tty/serial/atmel_serial.c           |  6 +++---
 drivers/tty/serial/bcm63xx_uart.c           |  2 +-
 drivers/tty/serial/bfin_sport_uart.c        |  2 +-
 drivers/tty/serial/clps711x.c               |  2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_core.c |  2 +-
 drivers/tty/serial/efm32-uart.c             |  2 +-
 drivers/tty/serial/icom.c                   | 10 +++++-----
 drivers/tty/serial/ioc3_serial.c            |  2 +-
 drivers/tty/serial/jsm/jsm_driver.c         |  2 +-
 drivers/tty/serial/jsm/jsm_tty.c            |  2 +-
 drivers/tty/serial/lpc32xx_hs.c             |  2 +-
 drivers/tty/serial/max3100.c                |  2 +-
 drivers/tty/serial/max310x.c                |  6 +++---
 drivers/tty/serial/mcf.c                    |  2 +-
 drivers/tty/serial/mpc52xx_uart.c           |  2 +-
 drivers/tty/serial/mrst_max3110.c           |  2 +-
 drivers/tty/serial/msm_serial_hs.c          |  4 ++--
 drivers/tty/serial/mxs-auart.c              |  2 +-
 drivers/tty/serial/of_serial.c              |  4 ++--
 drivers/tty/serial/omap-serial.c            |  6 +++---
 drivers/tty/serial/pch_uart.c               |  2 +-
 drivers/tty/serial/sa1100.c                 |  2 +-
 drivers/tty/serial/sc26xx.c                 |  4 ++--
 drivers/tty/serial/sccnxp.c                 |  2 +-
 drivers/tty/serial/serial_txx9.c            |  6 +++---
 drivers/tty/serial/sh-sci.c                 | 14 +++++++-------
 drivers/tty/serial/sunhv.c                  |  2 +-
 drivers/tty/serial/sunsab.c                 |  4 ++--
 drivers/tty/serial/sunsu.c                  |  6 +++---
 drivers/tty/serial/sunzilog.c               |  8 ++++----
 drivers/tty/serial/timbuart.c               |  2 +-
 drivers/tty/serial/uartlite.c               |  6 +++---
 drivers/tty/serial/vr41xx_siu.c             |  4 ++--
 drivers/tty/serial/vt8500_serial.c          |  2 +-
 drivers/tty/serial/xilinx_uartps.c          |  2 +-
 drivers/tty/synclink.c                      |  2 +-
 drivers/tty/synclink_gt.c                   |  2 +-
 drivers/tty/synclinkmp.c                    |  2 +-
 60 files changed, 113 insertions(+), 113 deletions(-)

diff --git a/drivers/tty/cyclades.c b/drivers/tty/cyclades.c
index 0244acf..444b544 100644
--- a/drivers/tty/cyclades.c
+++ b/drivers/tty/cyclades.c
@@ -3099,7 +3099,7 @@ static const struct tty_port_operations cyz_port_ops = {
  * ---------------------------------------------------------------------
  */
 
-static int __devinit cy_init_card(struct cyclades_card *cinfo)
+static int cy_init_card(struct cyclades_card *cinfo)
 {
 	struct cyclades_port *info;
 	unsigned int channel, port;
@@ -3196,7 +3196,7 @@ static int __devinit cy_init_card(struct cyclades_card *cinfo)
 
 /* initialize chips on Cyclom-Y card -- return number of valid
    chips (which is number of ports/4) */
-static unsigned short __devinit cyy_init_card(void __iomem *true_base_addr,
+static unsigned short cyy_init_card(void __iomem *true_base_addr,
 		int index)
 {
 	unsigned int chip_number;
@@ -3405,7 +3405,7 @@ static int __init cy_detect_isa(void)
 }				/* cy_detect_isa */
 
 #ifdef CONFIG_PCI
-static inline int __devinit cyc_isfwstr(const char *str, unsigned int size)
+static inline int cyc_isfwstr(const char *str, unsigned int size)
 {
 	unsigned int a;
 
@@ -3420,7 +3420,7 @@ static inline int __devinit cyc_isfwstr(const char *str, unsigned int size)
 	return 0;
 }
 
-static inline void __devinit cyz_fpga_copy(void __iomem *fpga, const u8 *data,
+static inline void cyz_fpga_copy(void __iomem *fpga, const u8 *data,
 		unsigned int size)
 {
 	for (; size > 0; size--) {
@@ -3429,7 +3429,7 @@ static inline void __devinit cyz_fpga_copy(void __iomem *fpga, const u8 *data,
 	}
 }
 
-static void __devinit plx_init(struct pci_dev *pdev, int irq,
+static void plx_init(struct pci_dev *pdev, int irq,
 		struct RUNTIME_9060 __iomem *addr)
 {
 	/* Reset PLX */
@@ -3449,7 +3449,7 @@ static void __devinit plx_init(struct pci_dev *pdev, int irq,
 	pci_write_config_byte(pdev, PCI_INTERRUPT_LINE, irq);
 }
 
-static int __devinit __cyz_load_fw(const struct firmware *fw,
+static int __cyz_load_fw(const struct firmware *fw,
 		const char *name, const u32 mailbox, void __iomem *base,
 		void __iomem *fpga)
 {
@@ -3526,7 +3526,7 @@ static int __devinit __cyz_load_fw(const struct firmware *fw,
 	return 0;
 }
 
-static int __devinit cyz_load_fw(struct pci_dev *pdev, void __iomem *base_addr,
+static int cyz_load_fw(struct pci_dev *pdev, void __iomem *base_addr,
 		struct RUNTIME_9060 __iomem *ctl_addr, int irq)
 {
 	const struct firmware *fw;
@@ -3692,7 +3692,7 @@ err:
 	return retval;
 }
 
-static int __devinit cy_pci_probe(struct pci_dev *pdev,
+static int cy_pci_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent)
 {
 	struct cyclades_card *card;
diff --git a/drivers/tty/ehv_bytechan.c b/drivers/tty/ehv_bytechan.c
index 4ab936b..65d4320 100644
--- a/drivers/tty/ehv_bytechan.c
+++ b/drivers/tty/ehv_bytechan.c
@@ -699,7 +699,7 @@ static const struct tty_port_operations ehv_bc_tty_port_ops = {
 	.shutdown = ehv_bc_tty_port_shutdown,
 };
 
-static int __devinit ehv_bc_tty_probe(struct platform_device *pdev)
+static int ehv_bc_tty_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct ehv_bc_data *bc;
diff --git a/drivers/tty/hvc/hvc_opal.c b/drivers/tty/hvc/hvc_opal.c
index f39337f..5ddd6f5 100644
--- a/drivers/tty/hvc/hvc_opal.c
+++ b/drivers/tty/hvc/hvc_opal.c
@@ -161,7 +161,7 @@ static const struct hv_ops hvc_opal_hvsi_ops = {
 	.tiocmset = hvc_opal_hvsi_tiocmset,
 };
 
-static int __devinit hvc_opal_probe(struct platform_device *dev)
+static int hvc_opal_probe(struct platform_device *dev)
 {
 	const struct hv_ops *ops;
 	struct hvc_struct *hp;
diff --git a/drivers/tty/hvc/hvc_vio.c b/drivers/tty/hvc/hvc_vio.c
index 1a5894c..f7333e3 100644
--- a/drivers/tty/hvc/hvc_vio.c
+++ b/drivers/tty/hvc/hvc_vio.c
@@ -293,7 +293,7 @@ static int udbg_hvc_getc(void)
 	}
 }
 
-static int __devinit hvc_vio_probe(struct vio_dev *vdev,
+static int hvc_vio_probe(struct vio_dev *vdev,
 				   const struct vio_device_id *id)
 {
 	const struct hv_ops *ops;
diff --git a/drivers/tty/hvc/hvc_xen.c b/drivers/tty/hvc/hvc_xen.c
index f4abfe2..19843ec 100644
--- a/drivers/tty/hvc/hvc_xen.c
+++ b/drivers/tty/hvc/hvc_xen.c
@@ -422,7 +422,7 @@ static int xencons_connect_backend(struct xenbus_device *dev,
 	return ret;
 }
 
-static int __devinit xencons_probe(struct xenbus_device *dev,
+static int xencons_probe(struct xenbus_device *dev,
 				  const struct xenbus_device_id *id)
 {
 	int ret, devid;
diff --git a/drivers/tty/hvc/hvcs.c b/drivers/tty/hvc/hvcs.c
index 888af58..506a28e 100644
--- a/drivers/tty/hvc/hvcs.c
+++ b/drivers/tty/hvc/hvcs.c
@@ -330,12 +330,12 @@ static int hvcs_open(struct tty_struct *tty, struct file *filp);
 static void hvcs_close(struct tty_struct *tty, struct file *filp);
 static void hvcs_hangup(struct tty_struct * tty);
 
-static int __devinit hvcs_probe(struct vio_dev *dev,
+static int hvcs_probe(struct vio_dev *dev,
 		const struct vio_device_id *id);
 static int __devexit hvcs_remove(struct vio_dev *dev);
 static int __init hvcs_module_init(void);
 static void __exit hvcs_module_exit(void);
-static int __devinit hvcs_initialize(void);
+static int hvcs_initialize(void);
 
 #define HVCS_SCHED_READ	0x00000001
 #define HVCS_QUICK_READ	0x00000002
@@ -756,7 +756,7 @@ static int hvcs_get_index(void)
 	return -1;
 }
 
-static int __devinit hvcs_probe(
+static int hvcs_probe(
 	struct vio_dev *dev,
 	const struct vio_device_id *id)
 {
@@ -1478,7 +1478,7 @@ static void hvcs_free_index_list(void)
 	hvcs_index_count = 0;
 }
 
-static int __devinit hvcs_initialize(void)
+static int hvcs_initialize(void)
 {
 	int rc, num_ttys_to_alloc;
 
diff --git a/drivers/tty/isicom.c b/drivers/tty/isicom.c
index 4775747..d1c1fef 100644
--- a/drivers/tty/isicom.c
+++ b/drivers/tty/isicom.c
@@ -1307,7 +1307,7 @@ static const struct tty_port_operations isicom_port_ops = {
 	.shutdown		= isicom_shutdown,
 };
 
-static int __devinit reset_card(struct pci_dev *pdev,
+static int reset_card(struct pci_dev *pdev,
 	const unsigned int card, unsigned int *signature)
 {
 	struct isi_board *board = pci_get_drvdata(pdev);
@@ -1368,7 +1368,7 @@ end:
 	return retval;
 }
 
-static int __devinit load_firmware(struct pci_dev *pdev,
+static int load_firmware(struct pci_dev *pdev,
 	const unsigned int index, const unsigned int signature)
 {
 	struct isi_board *board = pci_get_drvdata(pdev);
@@ -1548,7 +1548,7 @@ end:
  */
 static unsigned int card_count;
 
-static int __devinit isicom_probe(struct pci_dev *pdev,
+static int isicom_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	unsigned int uninitialized_var(signature), index;
diff --git a/drivers/tty/moxa.c b/drivers/tty/moxa.c
index c2d0cc3..0998773 100644
--- a/drivers/tty/moxa.c
+++ b/drivers/tty/moxa.c
@@ -941,7 +941,7 @@ static void moxa_board_deinit(struct moxa_board_conf *brd)
 }
 
 #ifdef CONFIG_PCI
-static int __devinit moxa_pci_probe(struct pci_dev *pdev,
+static int moxa_pci_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent)
 {
 	struct moxa_board_conf *board;
diff --git a/drivers/tty/mxser.c b/drivers/tty/mxser.c
index f026797..9de9753 100644
--- a/drivers/tty/mxser.c
+++ b/drivers/tty/mxser.c
@@ -487,7 +487,7 @@ static void mxser_disable_must_rx_software_flow_control(unsigned long baseio)
 }
 
 #ifdef CONFIG_PCI
-static int __devinit CheckIsMoxaMust(unsigned long io)
+static int CheckIsMoxaMust(unsigned long io)
 {
 	u8 oldmcr, hwid;
 	int i;
@@ -2369,7 +2369,7 @@ static void mxser_release_ISA_res(struct mxser_board *brd)
 	mxser_release_vector(brd);
 }
 
-static int __devinit mxser_initbrd(struct mxser_board *brd,
+static int mxser_initbrd(struct mxser_board *brd,
 		struct pci_dev *pdev)
 {
 	struct mxser_port *info;
@@ -2534,7 +2534,7 @@ err_irqconflict:
 	return -EIO;
 }
 
-static int __devinit mxser_probe(struct pci_dev *pdev,
+static int mxser_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent)
 {
 #ifdef CONFIG_PCI
diff --git a/drivers/tty/nozomi.c b/drivers/tty/nozomi.c
index dc0213e..645f54a 100644
--- a/drivers/tty/nozomi.c
+++ b/drivers/tty/nozomi.c
@@ -1360,7 +1360,7 @@ static void remove_sysfs_files(struct nozomi *dc)
 }
 
 /* Allocate memory for one device */
-static int __devinit nozomi_card_init(struct pci_dev *pdev,
+static int nozomi_card_init(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
 	resource_size_t start;
diff --git a/drivers/tty/serial/8250/8250.c b/drivers/tty/serial/8250/8250.c
index 870c5f2..40ba8cc 100644
--- a/drivers/tty/serial/8250/8250.c
+++ b/drivers/tty/serial/8250/8250.c
@@ -2989,7 +2989,7 @@ void serial8250_resume_port(int line)
  * list is terminated with a zero flags entry, which means we expect
  * all entries to have at least UPF_BOOT_AUTOCONF set.
  */
-static int __devinit serial8250_probe(struct platform_device *dev)
+static int serial8250_probe(struct platform_device *dev)
 {
 	struct plat_serial8250_port *p = dev->dev.platform_data;
 	struct uart_8250_port uart;
diff --git a/drivers/tty/serial/8250/8250_acorn.c b/drivers/tty/serial/8250/8250_acorn.c
index b5e4b49..ed095eb 100644
--- a/drivers/tty/serial/8250/8250_acorn.c
+++ b/drivers/tty/serial/8250/8250_acorn.c
@@ -38,7 +38,7 @@ struct serial_card_info {
 	void __iomem *vaddr;
 };
 
-static int __devinit
+static int
 serial_card_probe(struct expansion_card *ec, const struct ecard_id *id)
 {
 	struct serial_card_info *info;
diff --git a/drivers/tty/serial/8250/8250_dw.c b/drivers/tty/serial/8250/8250_dw.c
index 2db80d0..7664750 100644
--- a/drivers/tty/serial/8250/8250_dw.c
+++ b/drivers/tty/serial/8250/8250_dw.c
@@ -87,7 +87,7 @@ static int dw8250_handle_irq(struct uart_port *p)
 	return 0;
 }
 
-static int __devinit dw8250_probe(struct platform_device *pdev)
+static int dw8250_probe(struct platform_device *pdev)
 {
 	struct uart_8250_port uart = {};
 	struct resource *regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
diff --git a/drivers/tty/serial/8250/8250_em.c b/drivers/tty/serial/8250/8250_em.c
index 80c0a62..f59bff5 100644
--- a/drivers/tty/serial/8250/8250_em.c
+++ b/drivers/tty/serial/8250/8250_em.c
@@ -89,7 +89,7 @@ static void serial8250_em_serial_dl_write(struct uart_8250_port *up, int value)
 	serial_out(up, UART_DLM_EM, value >> 8 & 0xff);
 }
 
-static int __devinit serial8250_em_probe(struct platform_device *pdev)
+static int serial8250_em_probe(struct platform_device *pdev)
 {
 	struct resource *regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	struct resource *irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
diff --git a/drivers/tty/serial/8250/8250_hp300.c b/drivers/tty/serial/8250/8250_hp300.c
index 89e8855..2b94505 100644
--- a/drivers/tty/serial/8250/8250_hp300.c
+++ b/drivers/tty/serial/8250/8250_hp300.c
@@ -36,7 +36,7 @@ static struct hp300_port *hp300_ports;
 
 #ifdef CONFIG_HPDCA
 
-static int __devinit hpdca_init_one(struct dio_dev *d,
+static int hpdca_init_one(struct dio_dev *d,
 					const struct dio_device_id *ent);
 static void __devexit hpdca_remove_one(struct dio_dev *d);
 
@@ -159,7 +159,7 @@ int __init hp300_setup_serial_console(void)
 #endif /* CONFIG_SERIAL_8250_CONSOLE */
 
 #ifdef CONFIG_HPDCA
-static int __devinit hpdca_init_one(struct dio_dev *d,
+static int hpdca_init_one(struct dio_dev *d,
 				const struct dio_device_id *ent)
 {
 	struct uart_8250_port uart;
diff --git a/drivers/tty/serial/8250/8250_pci.c b/drivers/tty/serial/8250/8250_pci.c
index c049cfa..a5acb57 100644
--- a/drivers/tty/serial/8250/8250_pci.c
+++ b/drivers/tty/serial/8250/8250_pci.c
@@ -2691,7 +2691,7 @@ static const struct pci_device_id blacklist[] = {
  * guess what the configuration might be, based on the pitiful PCI
  * serial specs.  Returns 0 on success, 1 on failure.
  */
-static int __devinit
+static int
 serial_pci_guess_board(struct pci_dev *dev, struct pciserial_board *board)
 {
 	const struct pci_device_id *bldev;
@@ -2917,7 +2917,7 @@ EXPORT_SYMBOL_GPL(pciserial_resume_ports);
  * Probe one serial board.  Unfortunately, there is no rhyme nor reason
  * to the arrangement of serial ports on a PCI card.
  */
-static int __devinit
+static int
 pciserial_init_one(struct pci_dev *dev, const struct pci_device_id *ent)
 {
 	struct pci_serial_quirk *quirk;
diff --git a/drivers/tty/serial/8250/8250_pnp.c b/drivers/tty/serial/8250/8250_pnp.c
index e566220..2b8a6ac 100644
--- a/drivers/tty/serial/8250/8250_pnp.c
+++ b/drivers/tty/serial/8250/8250_pnp.c
@@ -377,7 +377,7 @@ static char *modem_names[] __devinitdata = {
 	"33600", "28800", "14400", "V.90", "V.34", "V.32", NULL
 };
 
-static int __devinit check_name(char *name)
+static int check_name(char *name)
 {
 	char **tmp;
 
@@ -388,7 +388,7 @@ static int __devinit check_name(char *name)
 	return 0;
 }
 
-static int __devinit check_resources(struct pnp_dev *dev)
+static int check_resources(struct pnp_dev *dev)
 {
 	resource_size_t base[] = {0x2f8, 0x3f8, 0x2e8, 0x3e8};
 	int i;
@@ -412,7 +412,7 @@ static int __devinit check_resources(struct pnp_dev *dev)
  * PnP modems, alternatively we must hardcode all modems in pnp_devices[]
  * table.
  */
-static int __devinit serial_pnp_guess_board(struct pnp_dev *dev)
+static int serial_pnp_guess_board(struct pnp_dev *dev)
 {
 	if (!(check_name(pnp_dev_name(dev)) ||
 		(dev->card && check_name(dev->card->name))))
@@ -424,7 +424,7 @@ static int __devinit serial_pnp_guess_board(struct pnp_dev *dev)
 	return -ENODEV;
 }
 
-static int __devinit
+static int
 serial_pnp_probe(struct pnp_dev *dev, const struct pnp_device_id *dev_id)
 {
 	struct uart_8250_port uart;
diff --git a/drivers/tty/serial/altera_jtaguart.c b/drivers/tty/serial/altera_jtaguart.c
index ef16b0a..ef5c705 100644
--- a/drivers/tty/serial/altera_jtaguart.c
+++ b/drivers/tty/serial/altera_jtaguart.c
@@ -406,7 +406,7 @@ static struct uart_driver altera_jtaguart_driver = {
 	.cons		= ALTERA_JTAGUART_CONSOLE,
 };
 
-static int __devinit altera_jtaguart_probe(struct platform_device *pdev)
+static int altera_jtaguart_probe(struct platform_device *pdev)
 {
 	struct altera_jtaguart_platform_uart *platp = pdev->dev.platform_data;
 	struct uart_port *port;
diff --git a/drivers/tty/serial/altera_uart.c b/drivers/tty/serial/altera_uart.c
index 117ea2c..066b503 100644
--- a/drivers/tty/serial/altera_uart.c
+++ b/drivers/tty/serial/altera_uart.c
@@ -532,7 +532,7 @@ static int altera_uart_get_of_uartclk(struct platform_device *pdev,
 }
 #endif /* CONFIG_OF */
 
-static int __devinit altera_uart_probe(struct platform_device *pdev)
+static int altera_uart_probe(struct platform_device *pdev)
 {
 	struct altera_uart_platform_uart *platp = pdev->dev.platform_data;
 	struct uart_port *port;
diff --git a/drivers/tty/serial/apbuart.c b/drivers/tty/serial/apbuart.c
index 7162f70..59ae2b5 100644
--- a/drivers/tty/serial/apbuart.c
+++ b/drivers/tty/serial/apbuart.c
@@ -554,7 +554,7 @@ static struct uart_driver grlib_apbuart_driver = {
 /* OF Platform Driver                                                       */
 /* ==================================== */
 
-static int __devinit apbuart_probe(struct platform_device *op)
+static int apbuart_probe(struct platform_device *op)
 {
 	int i;
 	struct uart_port *port = NULL;
diff --git a/drivers/tty/serial/ar933x_uart.c b/drivers/tty/serial/ar933x_uart.c
index 33122f9..fab0a91 100644
--- a/drivers/tty/serial/ar933x_uart.c
+++ b/drivers/tty/serial/ar933x_uart.c
@@ -554,7 +554,7 @@ static struct uart_driver ar933x_uart_driver = {
 	.cons		= AR933X_SERIAL_CONSOLE,
 };
 
-static int __devinit ar933x_uart_probe(struct platform_device *pdev)
+static int ar933x_uart_probe(struct platform_device *pdev)
 {
 	struct ar933x_uart_platform_data *pdata;
 	struct ar933x_uart_port *up;
diff --git a/drivers/tty/serial/arc_uart.c b/drivers/tty/serial/arc_uart.c
index d652569..158d798 100644
--- a/drivers/tty/serial/arc_uart.c
+++ b/drivers/tty/serial/arc_uart.c
@@ -525,7 +525,7 @@ static struct uart_ops arc_serial_pops = {
 #endif
 };
 
-static int __devinit
+static int
 arc_uart_init_one(struct platform_device *pdev, struct arc_uart_port *uart)
 {
 	struct resource *res, *res2;
@@ -577,7 +577,7 @@ arc_uart_init_one(struct platform_device *pdev, struct arc_uart_port *uart)
 
 #ifdef CONFIG_SERIAL_ARC_CONSOLE
 
-static int __devinit arc_serial_console_setup(struct console *co, char *options)
+static int arc_serial_console_setup(struct console *co, char *options)
 {
 	struct uart_port *port;
 	int baud = 115200;
@@ -655,7 +655,7 @@ static struct __initdata console arc_early_serial_console = {
 	.index = -1
 };
 
-static int __devinit arc_serial_probe_earlyprintk(struct platform_device *pdev)
+static int arc_serial_probe_earlyprintk(struct platform_device *pdev)
 {
 	arc_early_serial_console.index = pdev->id;
 
@@ -667,13 +667,13 @@ static int __devinit arc_serial_probe_earlyprintk(struct platform_device *pdev)
 	return 0;
 }
 #else
-static int __devinit arc_serial_probe_earlyprintk(struct platform_device *pdev)
+static int arc_serial_probe_earlyprintk(struct platform_device *pdev)
 {
 	return -ENODEV;
 }
 #endif	/* CONFIG_SERIAL_ARC_CONSOLE */
 
-static int __devinit arc_serial_probe(struct platform_device *pdev)
+static int arc_serial_probe(struct platform_device *pdev)
 {
 	struct arc_uart_port *uart;
 	int rc;
diff --git a/drivers/tty/serial/atmel_serial.c b/drivers/tty/serial/atmel_serial.c
index 7f91d08..c1f6c0b 100644
--- a/drivers/tty/serial/atmel_serial.c
+++ b/drivers/tty/serial/atmel_serial.c
@@ -1424,7 +1424,7 @@ static struct uart_ops atmel_pops = {
 #endif
 };
 
-static void __devinit atmel_of_init_port(struct atmel_uart_port *atmel_port,
+static void atmel_of_init_port(struct atmel_uart_port *atmel_port,
 					 struct device_node *np)
 {
 	u32 rs485_delay[2];
@@ -1459,7 +1459,7 @@ static void __devinit atmel_of_init_port(struct atmel_uart_port *atmel_port,
 /*
  * Configure the port from the platform device resource info.
  */
-static void __devinit atmel_init_port(struct atmel_uart_port *atmel_port,
+static void atmel_init_port(struct atmel_uart_port *atmel_port,
 				      struct platform_device *pdev)
 {
 	struct uart_port *port = &atmel_port->uart;
@@ -1767,7 +1767,7 @@ static int atmel_serial_resume(struct platform_device *pdev)
 #define atmel_serial_resume NULL
 #endif
 
-static int __devinit atmel_serial_probe(struct platform_device *pdev)
+static int atmel_serial_probe(struct platform_device *pdev)
 {
 	struct atmel_uart_port *port;
 	struct device_node *np = pdev->dev.of_node;
diff --git a/drivers/tty/serial/bcm63xx_uart.c b/drivers/tty/serial/bcm63xx_uart.c
index 7f631d4..e54d170 100644
--- a/drivers/tty/serial/bcm63xx_uart.c
+++ b/drivers/tty/serial/bcm63xx_uart.c
@@ -801,7 +801,7 @@ static struct uart_driver bcm_uart_driver = {
 /*
  * platform driver probe/remove callback
  */
-static int __devinit bcm_uart_probe(struct platform_device *pdev)
+static int bcm_uart_probe(struct platform_device *pdev)
 {
 	struct resource *res_mem, *res_irq;
 	struct uart_port *port;
diff --git a/drivers/tty/serial/bfin_sport_uart.c b/drivers/tty/serial/bfin_sport_uart.c
index b4a18c7..a47e00b 100644
--- a/drivers/tty/serial/bfin_sport_uart.c
+++ b/drivers/tty/serial/bfin_sport_uart.c
@@ -740,7 +740,7 @@ static struct dev_pm_ops bfin_sport_uart_dev_pm_ops = {
 };
 #endif
 
-static int __devinit sport_uart_probe(struct platform_device *pdev)
+static int sport_uart_probe(struct platform_device *pdev)
 {
 	struct resource *res;
 	struct sport_uart_port *sport;
diff --git a/drivers/tty/serial/clps711x.c b/drivers/tty/serial/clps711x.c
index d631ef5..006d283 100644
--- a/drivers/tty/serial/clps711x.c
+++ b/drivers/tty/serial/clps711x.c
@@ -429,7 +429,7 @@ static int uart_clps711x_console_setup(struct console *co, char *options)
 }
 #endif
 
-static int __devinit uart_clps711x_probe(struct platform_device *pdev)
+static int uart_clps711x_probe(struct platform_device *pdev)
 {
 	struct clps711x_port *s;
 	int ret, i;
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_core.c b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
index d0dd919..de3f0f6 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_core.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
@@ -1373,7 +1373,7 @@ static struct uart_driver cpm_reg = {
 
 static int probe_index;
 
-static int __devinit cpm_uart_probe(struct platform_device *ofdev)
+static int cpm_uart_probe(struct platform_device *ofdev)
 {
 	int index = probe_index++;
 	struct uart_cpm_port *pinfo = &cpm_uart_ports[index];
diff --git a/drivers/tty/serial/efm32-uart.c b/drivers/tty/serial/efm32-uart.c
index 1e8bacf..833c33a 100644
--- a/drivers/tty/serial/efm32-uart.c
+++ b/drivers/tty/serial/efm32-uart.c
@@ -690,7 +690,7 @@ static int efm32_uart_probe_dt(struct platform_device *pdev,
 
 }
 
-static int __devinit efm32_uart_probe(struct platform_device *pdev)
+static int efm32_uart_probe(struct platform_device *pdev)
 {
 	struct efm32_uart_port *efm_port;
 	struct resource *res;
diff --git a/drivers/tty/serial/icom.c b/drivers/tty/serial/icom.c
index 82671b5..8c5ad58 100644
--- a/drivers/tty/serial/icom.c
+++ b/drivers/tty/serial/icom.c
@@ -175,7 +175,7 @@ static void free_port_memory(struct icom_port *icom_port)
 	}
 }
 
-static int __devinit get_port_memory(struct icom_port *icom_port)
+static int get_port_memory(struct icom_port *icom_port)
 {
 	int index;
 	unsigned long stgAddr;
@@ -1314,7 +1314,7 @@ static struct uart_driver icom_uart_driver = {
 	.cons = ICOM_CONSOLE,
 };
 
-static int __devinit icom_init_ports(struct icom_adapter *icom_adapter)
+static int icom_init_ports(struct icom_adapter *icom_adapter)
 {
 	u32 subsystem_id = icom_adapter->subsystem_id;
 	int i;
@@ -1381,7 +1381,7 @@ static void icom_port_active(struct icom_port *icom_port, struct icom_adapter *i
 			    0x8024 + 2 - 2 * (icom_port->port - 2);
 	}
 }
-static int __devinit icom_load_ports(struct icom_adapter *icom_adapter)
+static int icom_load_ports(struct icom_adapter *icom_adapter)
 {
 	struct icom_port *icom_port;
 	int port_num;
@@ -1407,7 +1407,7 @@ static int __devinit icom_load_ports(struct icom_adapter *icom_adapter)
 	return 0;
 }
 
-static int __devinit icom_alloc_adapter(struct icom_adapter
+static int icom_alloc_adapter(struct icom_adapter
 					**icom_adapter_ref)
 {
 	int adapter_count = 0;
@@ -1487,7 +1487,7 @@ static void icom_kref_release(struct kref *kref)
 	icom_remove_adapter(icom_adapter);
 }
 
-static int __devinit icom_probe(struct pci_dev *dev,
+static int icom_probe(struct pci_dev *dev,
 				const struct pci_device_id *ent)
 {
 	int index;
diff --git a/drivers/tty/serial/ioc3_serial.c b/drivers/tty/serial/ioc3_serial.c
index 5ac5289..d8f1d1d 100644
--- a/drivers/tty/serial/ioc3_serial.c
+++ b/drivers/tty/serial/ioc3_serial.c
@@ -2010,7 +2010,7 @@ static int ioc3uart_remove(struct ioc3_submodule *is,
  * @idd: ioc3 driver data for this card
  */
 
-static int __devinit
+static int
 ioc3uart_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 {
 	struct pci_dev *pdev = idd->pdev;
diff --git a/drivers/tty/serial/jsm/jsm_driver.c b/drivers/tty/serial/jsm/jsm_driver.c
index bbd4592..5b57c8e 100644
--- a/drivers/tty/serial/jsm/jsm_driver.c
+++ b/drivers/tty/serial/jsm/jsm_driver.c
@@ -64,7 +64,7 @@ int jsm_debug;
 module_param(jsm_debug, int, 0);
 MODULE_PARM_DESC(jsm_debug, "Driver debugging level");
 
-static int __devinit jsm_probe_one(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int jsm_probe_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int rc = 0;
 	struct jsm_board *brd;
diff --git a/drivers/tty/serial/jsm/jsm_tty.c b/drivers/tty/serial/jsm/jsm_tty.c
index 7d2c1f3..4c00c55 100644
--- a/drivers/tty/serial/jsm/jsm_tty.c
+++ b/drivers/tty/serial/jsm/jsm_tty.c
@@ -371,7 +371,7 @@ static struct uart_ops jsm_ops = {
  * Init the tty subsystem.  Called once per board after board has been
  * downloaded and init'ed.
  */
-int __devinit jsm_tty_init(struct jsm_board *brd)
+int jsm_tty_init(struct jsm_board *brd)
 {
 	int i;
 	void __iomem *vaddr;
diff --git a/drivers/tty/serial/lpc32xx_hs.c b/drivers/tty/serial/lpc32xx_hs.c
index 7b0f5b4..3651dab 100644
--- a/drivers/tty/serial/lpc32xx_hs.c
+++ b/drivers/tty/serial/lpc32xx_hs.c
@@ -686,7 +686,7 @@ static struct uart_ops serial_lpc32xx_pops = {
 /*
  * Register a set of serial devices attached to a platform device
  */
-static int __devinit serial_hs_lpc32xx_probe(struct platform_device *pdev)
+static int serial_hs_lpc32xx_probe(struct platform_device *pdev)
 {
 	struct lpc32xx_hsuart_port *p = &lpc32xx_hs_ports[uarts_registered];
 	int ret = 0;
diff --git a/drivers/tty/serial/max3100.c b/drivers/tty/serial/max3100.c
index 2ffd7f0..8dd6189 100644
--- a/drivers/tty/serial/max3100.c
+++ b/drivers/tty/serial/max3100.c
@@ -742,7 +742,7 @@ static struct uart_driver max3100_uart_driver = {
 };
 static int uart_driver_registered;
 
-static int __devinit max3100_probe(struct spi_device *spi)
+static int max3100_probe(struct spi_device *spi)
 {
 	int i, retval;
 	struct plat_max3100 *pdata;
diff --git a/drivers/tty/serial/max310x.c b/drivers/tty/serial/max310x.c
index a332327..88a227f 100644
--- a/drivers/tty/serial/max310x.c
+++ b/drivers/tty/serial/max310x.c
@@ -378,7 +378,7 @@ static void max310x_wait_pll(struct max310x_port *s)
 	}
 }
 
-static int __devinit max310x_update_best_err(unsigned long f, long *besterr)
+static int max310x_update_best_err(unsigned long f, long *besterr)
 {
 	/* Use baudrate 115200 for calculate error */
 	long err = f % (115200 * 16);
@@ -391,7 +391,7 @@ static int __devinit max310x_update_best_err(unsigned long f, long *besterr)
 	return 1;
 }
 
-static int __devinit max310x_set_ref_clk(struct max310x_port *s)
+static int max310x_set_ref_clk(struct max310x_port *s)
 {
 	unsigned int div, clksrc, pllcfg = 0;
 	long besterr = -1;
@@ -995,7 +995,7 @@ static struct max310x_pdata generic_plat_data = {
 	.frequency	= 26000000,
 };
 
-static int __devinit max310x_probe(struct spi_device *spi)
+static int max310x_probe(struct spi_device *spi)
 {
 	struct max310x_port *s;
 	struct device *dev = &spi->dev;
diff --git a/drivers/tty/serial/mcf.c b/drivers/tty/serial/mcf.c
index e3de785..e2b93d2 100644
--- a/drivers/tty/serial/mcf.c
+++ b/drivers/tty/serial/mcf.c
@@ -571,7 +571,7 @@ static struct uart_driver mcf_driver = {
 
 /****************************************************************************/
 
-static int __devinit mcf_probe(struct platform_device *pdev)
+static int mcf_probe(struct platform_device *pdev)
 {
 	struct mcf_platform_uart *platp = pdev->dev.platform_data;
 	struct uart_port *port;
diff --git a/drivers/tty/serial/mpc52xx_uart.c b/drivers/tty/serial/mpc52xx_uart.c
index 8cf5770..7c23c4f 100644
--- a/drivers/tty/serial/mpc52xx_uart.c
+++ b/drivers/tty/serial/mpc52xx_uart.c
@@ -1308,7 +1308,7 @@ static struct of_device_id mpc52xx_uart_of_match[] = {
 	{},
 };
 
-static int __devinit mpc52xx_uart_of_probe(struct platform_device *op)
+static int mpc52xx_uart_of_probe(struct platform_device *op)
 {
 	int idx = -1;
 	unsigned int uartclk;
diff --git a/drivers/tty/serial/mrst_max3110.c b/drivers/tty/serial/mrst_max3110.c
index 649ce12..41497fd 100644
--- a/drivers/tty/serial/mrst_max3110.c
+++ b/drivers/tty/serial/mrst_max3110.c
@@ -773,7 +773,7 @@ static int serial_m3110_resume(struct spi_device *spi)
 #define serial_m3110_resume	NULL
 #endif
 
-static int __devinit serial_m3110_probe(struct spi_device *spi)
+static int serial_m3110_probe(struct spi_device *spi)
 {
 	struct uart_max3110 *max;
 	void *buffer;
diff --git a/drivers/tty/serial/msm_serial_hs.c b/drivers/tty/serial/msm_serial_hs.c
index 1361ad5..02fb63e 100644
--- a/drivers/tty/serial/msm_serial_hs.c
+++ b/drivers/tty/serial/msm_serial_hs.c
@@ -1521,7 +1521,7 @@ err_msm_hs_init_clk:
 }
 
 /* Initialize tx and rx data structures */
-static int __devinit uartdm_init_port(struct uart_port *uport)
+static int uartdm_init_port(struct uart_port *uport)
 {
 	int ret = 0;
 	struct msm_hs_port *msm_uport = UARTDM_TO_MSM(uport);
@@ -1614,7 +1614,7 @@ err_tx_command_ptr_ptr:
 	return ret;
 }
 
-static int __devinit msm_hs_probe(struct platform_device *pdev)
+static int msm_hs_probe(struct platform_device *pdev)
 {
 	int ret;
 	struct uart_port *uport;
diff --git a/drivers/tty/serial/mxs-auart.c b/drivers/tty/serial/mxs-auart.c
index 7554045..ed09bd4 100644
--- a/drivers/tty/serial/mxs-auart.c
+++ b/drivers/tty/serial/mxs-auart.c
@@ -704,7 +704,7 @@ static int serial_mxs_probe_dt(struct mxs_auart_port *s,
 	return 0;
 }
 
-static int __devinit mxs_auart_probe(struct platform_device *pdev)
+static int mxs_auart_probe(struct platform_device *pdev)
 {
 	struct mxs_auart_port *s;
 	u32 version;
diff --git a/drivers/tty/serial/of_serial.c b/drivers/tty/serial/of_serial.c
index b9fdccb2..1bce344 100644
--- a/drivers/tty/serial/of_serial.c
+++ b/drivers/tty/serial/of_serial.c
@@ -52,7 +52,7 @@ EXPORT_SYMBOL_GPL(tegra_serial_handle_break);
 /*
  * Fill a struct uart_port for a given device node
  */
-static int __devinit of_platform_serial_setup(struct platform_device *ofdev,
+static int of_platform_serial_setup(struct platform_device *ofdev,
 			int type, struct uart_port *port,
 			struct of_serial_info *info)
 {
@@ -138,7 +138,7 @@ out:
  * Try to register a serial port
  */
 static struct of_device_id of_platform_serial_table[];
-static int __devinit of_platform_serial_probe(struct platform_device *ofdev)
+static int of_platform_serial_probe(struct platform_device *ofdev)
 {
 	const struct of_device_id *match;
 	struct of_serial_info *info;
diff --git a/drivers/tty/serial/omap-serial.c b/drivers/tty/serial/omap-serial.c
index 624e6b5..1e988f7 100644
--- a/drivers/tty/serial/omap-serial.c
+++ b/drivers/tty/serial/omap-serial.c
@@ -1307,7 +1307,7 @@ static int serial_omap_resume(struct device *dev)
 }
 #endif
 
-static void __devinit omap_serial_fill_features_erratas(struct uart_omap_port *up)
+static void omap_serial_fill_features_erratas(struct uart_omap_port *up)
 {
 	u32 mvr, scheme;
 	u16 revision, major, minor;
@@ -1360,7 +1360,7 @@ static void __devinit omap_serial_fill_features_erratas(struct uart_omap_port *u
 	}
 }
 
-static __devinit struct omap_uart_port_info *of_get_uart_port_info(struct device *dev)
+static struct omap_uart_port_info *of_get_uart_port_info(struct device *dev)
 {
 	struct omap_uart_port_info *omap_up_info;
 
@@ -1373,7 +1373,7 @@ static __devinit struct omap_uart_port_info *of_get_uart_port_info(struct device
 	return omap_up_info;
 }
 
-static int __devinit serial_omap_probe(struct platform_device *pdev)
+static int serial_omap_probe(struct platform_device *pdev)
 {
 	struct uart_omap_port	*up;
 	struct resource		*mem, *irq;
diff --git a/drivers/tty/serial/pch_uart.c b/drivers/tty/serial/pch_uart.c
index f5fb9bd..8318925 100644
--- a/drivers/tty/serial/pch_uart.c
+++ b/drivers/tty/serial/pch_uart.c
@@ -1839,7 +1839,7 @@ static DEFINE_PCI_DEVICE_TABLE(pch_uart_pci_id) = {
 	{0,},
 };
 
-static int __devinit pch_uart_pci_probe(struct pci_dev *pdev,
+static int pch_uart_pci_probe(struct pci_dev *pdev,
 					const struct pci_device_id *id)
 {
 	int ret;
diff --git a/drivers/tty/serial/sa1100.c b/drivers/tty/serial/sa1100.c
index 2ca5959..da56c8a 100644
--- a/drivers/tty/serial/sa1100.c
+++ b/drivers/tty/serial/sa1100.c
@@ -637,7 +637,7 @@ static void __init sa1100_init_ports(void)
 	PPSR |= PPC_TXD1 | PPC_TXD3;
 }
 
-void __devinit sa1100_register_uart_fns(struct sa1100_port_fns *fns)
+void sa1100_register_uart_fns(struct sa1100_port_fns *fns)
 {
 	if (fns->get_mctrl)
 		sa1100_pops.get_mctrl = fns->get_mctrl;
diff --git a/drivers/tty/serial/sc26xx.c b/drivers/tty/serial/sc26xx.c
index 9a40659..aced1dd 100644
--- a/drivers/tty/serial/sc26xx.c
+++ b/drivers/tty/serial/sc26xx.c
@@ -621,7 +621,7 @@ static u8 sc26xx_flags2mask(unsigned int flags, unsigned int bitpos)
 	return bit ? (1 << (bit - 1)) : 0;
 }
 
-static void __devinit sc26xx_init_masks(struct uart_sc26xx_port *up,
+static void sc26xx_init_masks(struct uart_sc26xx_port *up,
 					int line, unsigned int data)
 {
 	up->dtr_mask[line] = sc26xx_flags2mask(data,  0);
@@ -632,7 +632,7 @@ static void __devinit sc26xx_init_masks(struct uart_sc26xx_port *up,
 	up->ri_mask[line]  = sc26xx_flags2mask(data, 20);
 }
 
-static int __devinit sc26xx_probe(struct platform_device *dev)
+static int sc26xx_probe(struct platform_device *dev)
 {
 	struct resource *res;
 	struct uart_sc26xx_port *up;
diff --git a/drivers/tty/serial/sccnxp.c b/drivers/tty/serial/sccnxp.c
index 810853f..1ddace8 100644
--- a/drivers/tty/serial/sccnxp.c
+++ b/drivers/tty/serial/sccnxp.c
@@ -740,7 +740,7 @@ static int sccnxp_console_setup(struct console *co, char *options)
 }
 #endif
 
-static int __devinit sccnxp_probe(struct platform_device *pdev)
+static int sccnxp_probe(struct platform_device *pdev)
 {
 	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	int chiptype = pdev->id_entry->driver_data;
diff --git a/drivers/tty/serial/serial_txx9.c b/drivers/tty/serial/serial_txx9.c
index 9d979a9..23b28b8 100644
--- a/drivers/tty/serial/serial_txx9.c
+++ b/drivers/tty/serial/serial_txx9.c
@@ -1030,7 +1030,7 @@ static DEFINE_MUTEX(serial_txx9_mutex);
  *
  *	On success the port is ready to use and the line number is returned.
  */
-static int __devinit serial_txx9_register_port(struct uart_port *port)
+static int serial_txx9_register_port(struct uart_port *port)
 {
 	int i;
 	struct uart_txx9_port *uart;
@@ -1096,7 +1096,7 @@ static void __devexit serial_txx9_unregister_port(int line)
 /*
  * Register a set of serial devices attached to a platform device.
  */
-static int __devinit serial_txx9_probe(struct platform_device *dev)
+static int serial_txx9_probe(struct platform_device *dev)
 {
 	struct uart_port *p = dev->dev.platform_data;
 	struct uart_port port;
@@ -1187,7 +1187,7 @@ static struct platform_driver serial_txx9_plat_driver = {
  * Probe one serial board.  Unfortunately, there is no rhyme nor reason
  * to the arrangement of serial ports on a PCI card.
  */
-static int __devinit
+static int
 pciserial_txx9_init_one(struct pci_dev *dev, const struct pci_device_id *ent)
 {
 	struct uart_port port;
diff --git a/drivers/tty/serial/sh-sci.c b/drivers/tty/serial/sh-sci.c
index 6ee5900..390fdc7 100644
--- a/drivers/tty/serial/sh-sci.c
+++ b/drivers/tty/serial/sh-sci.c
@@ -1132,7 +1132,7 @@ static const char *sci_gpio_str(unsigned int index)
 	return sci_gpio_names[index];
 }
 
-static void __devinit sci_init_gpios(struct sci_port *port)
+static void sci_init_gpios(struct sci_port *port)
 {
 	struct uart_port *up = &port->port;
 	int i;
@@ -2064,7 +2064,7 @@ static struct uart_ops sci_uart_ops = {
 #endif
 };
 
-static int __devinit sci_init_single(struct platform_device *dev,
+static int sci_init_single(struct platform_device *dev,
 				     struct sci_port *sci_port,
 				     unsigned int index,
 				     struct plat_sci_port *p)
@@ -2220,7 +2220,7 @@ static void serial_console_write(struct console *co, const char *s,
 	sci_port_disable(sci_port);
 }
 
-static int __devinit serial_console_setup(struct console *co, char *options)
+static int serial_console_setup(struct console *co, char *options)
 {
 	struct sci_port *sci_port;
 	struct uart_port *port;
@@ -2278,7 +2278,7 @@ static struct console early_serial_console = {
 
 static char early_serial_buf[32];
 
-static int __devinit sci_probe_earlyprintk(struct platform_device *pdev)
+static int sci_probe_earlyprintk(struct platform_device *pdev)
 {
 	struct plat_sci_port *cfg = pdev->dev.platform_data;
 
@@ -2341,7 +2341,7 @@ static int sci_runtime_resume(struct device *dev)
 #define SCI_CONSOLE	(&serial_console)
 
 #else
-static inline int __devinit sci_probe_earlyprintk(struct platform_device *pdev)
+static inline int sci_probe_earlyprintk(struct platform_device *pdev)
 {
 	return -EINVAL;
 }
@@ -2379,7 +2379,7 @@ static int sci_remove(struct platform_device *dev)
 	return 0;
 }
 
-static int __devinit sci_probe_single(struct platform_device *dev,
+static int sci_probe_single(struct platform_device *dev,
 				      unsigned int index,
 				      struct plat_sci_port *p,
 				      struct sci_port *sciport)
@@ -2409,7 +2409,7 @@ static int __devinit sci_probe_single(struct platform_device *dev,
 	return 0;
 }
 
-static int __devinit sci_probe(struct platform_device *dev)
+static int sci_probe(struct platform_device *dev)
 {
 	struct plat_sci_port *p = dev->dev.platform_data;
 	struct sci_port *sp = &sci_ports[dev->id];
diff --git a/drivers/tty/serial/sunhv.c b/drivers/tty/serial/sunhv.c
index 949b2d3..cb58867 100644
--- a/drivers/tty/serial/sunhv.c
+++ b/drivers/tty/serial/sunhv.c
@@ -519,7 +519,7 @@ static struct console sunhv_console = {
 	.data	=	&sunhv_reg,
 };
 
-static int __devinit hv_probe(struct platform_device *op)
+static int hv_probe(struct platform_device *op)
 {
 	struct uart_port *port;
 	unsigned long minor;
diff --git a/drivers/tty/serial/sunsab.c b/drivers/tty/serial/sunsab.c
index bbb07bc..9a13c54 100644
--- a/drivers/tty/serial/sunsab.c
+++ b/drivers/tty/serial/sunsab.c
@@ -954,7 +954,7 @@ static inline struct console *SUNSAB_CONSOLE(void)
 #define sunsab_console_init()	do { } while (0)
 #endif
 
-static int __devinit sunsab_init_one(struct uart_sunsab_port *up,
+static int sunsab_init_one(struct uart_sunsab_port *up,
 				     struct platform_device *op,
 				     unsigned long offset,
 				     int line)
@@ -1007,7 +1007,7 @@ static int __devinit sunsab_init_one(struct uart_sunsab_port *up,
 	return 0;
 }
 
-static int __devinit sab_probe(struct platform_device *op)
+static int sab_probe(struct platform_device *op)
 {
 	static int inst;
 	struct uart_sunsab_port *up;
diff --git a/drivers/tty/serial/sunsu.c b/drivers/tty/serial/sunsu.c
index c0658f0..049bbc5 100644
--- a/drivers/tty/serial/sunsu.c
+++ b/drivers/tty/serial/sunsu.c
@@ -1185,7 +1185,7 @@ static struct uart_driver sunsu_reg = {
 	.major			= TTY_MAJOR,
 };
 
-static int __devinit sunsu_kbd_ms_init(struct uart_sunsu_port *up)
+static int sunsu_kbd_ms_init(struct uart_sunsu_port *up)
 {
 	int quot, baud;
 #ifdef CONFIG_SERIO
@@ -1391,7 +1391,7 @@ static inline struct console *SUNSU_CONSOLE(void)
 #define sunsu_serial_console_init()	do { } while (0)
 #endif
 
-static enum su_type __devinit su_get_type(struct device_node *dp)
+static enum su_type su_get_type(struct device_node *dp)
 {
 	struct device_node *ap = of_find_node_by_path("/aliases");
 
@@ -1412,7 +1412,7 @@ static enum su_type __devinit su_get_type(struct device_node *dp)
 	return SU_PORT_PORT;
 }
 
-static int __devinit su_probe(struct platform_device *op)
+static int su_probe(struct platform_device *op)
 {
 	static int inst;
 	struct device_node *dp = op->dev.of_node;
diff --git a/drivers/tty/serial/sunzilog.c b/drivers/tty/serial/sunzilog.c
index c2ef475..02c058f 100644
--- a/drivers/tty/serial/sunzilog.c
+++ b/drivers/tty/serial/sunzilog.c
@@ -1282,7 +1282,7 @@ static inline struct console *SUNZILOG_CONSOLE(void)
 #define SUNZILOG_CONSOLE()	(NULL)
 #endif
 
-static void __devinit sunzilog_init_kbdms(struct uart_sunzilog_port *up)
+static void sunzilog_init_kbdms(struct uart_sunzilog_port *up)
 {
 	int baud, brg;
 
@@ -1302,7 +1302,7 @@ static void __devinit sunzilog_init_kbdms(struct uart_sunzilog_port *up)
 }
 
 #ifdef CONFIG_SERIO
-static void __devinit sunzilog_register_serio(struct uart_sunzilog_port *up)
+static void sunzilog_register_serio(struct uart_sunzilog_port *up)
 {
 	struct serio *serio = &up->serio;
 
@@ -1331,7 +1331,7 @@ static void __devinit sunzilog_register_serio(struct uart_sunzilog_port *up)
 }
 #endif
 
-static void __devinit sunzilog_init_hw(struct uart_sunzilog_port *up)
+static void sunzilog_init_hw(struct uart_sunzilog_port *up)
 {
 	struct zilog_channel __iomem *channel;
 	unsigned long flags;
@@ -1400,7 +1400,7 @@ static void __devinit sunzilog_init_hw(struct uart_sunzilog_port *up)
 
 static int zilog_irq;
 
-static int __devinit zs_probe(struct platform_device *op)
+static int zs_probe(struct platform_device *op)
 {
 	static int kbm_inst, uart_inst;
 	int inst;
diff --git a/drivers/tty/serial/timbuart.c b/drivers/tty/serial/timbuart.c
index 5fc11f2..c833f50 100644
--- a/drivers/tty/serial/timbuart.c
+++ b/drivers/tty/serial/timbuart.c
@@ -426,7 +426,7 @@ static struct uart_driver timbuart_driver = {
 	.nr = 1
 };
 
-static int __devinit timbuart_probe(struct platform_device *dev)
+static int timbuart_probe(struct platform_device *dev)
 {
 	int err, irq;
 	struct timbuart_port *uart;
diff --git a/drivers/tty/serial/uartlite.c b/drivers/tty/serial/uartlite.c
index 1d44383..df9eeb4 100644
--- a/drivers/tty/serial/uartlite.c
+++ b/drivers/tty/serial/uartlite.c
@@ -408,7 +408,7 @@ static void ulite_console_write(struct console *co, const char *s,
 		spin_unlock_irqrestore(&port->lock, flags);
 }
 
-static int __devinit ulite_console_setup(struct console *co, char *options)
+static int ulite_console_setup(struct console *co, char *options)
 {
 	struct uart_port *port;
 	int baud = 9600;
@@ -486,7 +486,7 @@ static struct uart_driver ulite_uart_driver = {
  *
  * Returns: 0 on success, <0 otherwise
  */
-static int __devinit ulite_assign(struct device *dev, int id, u32 base, int irq)
+static int ulite_assign(struct device *dev, int id, u32 base, int irq)
 {
 	struct uart_port *port;
 	int rc;
@@ -570,7 +570,7 @@ static struct of_device_id ulite_of_match[] __devinitdata = {
 MODULE_DEVICE_TABLE(of, ulite_of_match);
 #endif /* CONFIG_OF */
 
-static int __devinit ulite_probe(struct platform_device *pdev)
+static int ulite_probe(struct platform_device *pdev)
 {
 	struct resource *res, *res2;
 	int id = pdev->id;
diff --git a/drivers/tty/serial/vr41xx_siu.c b/drivers/tty/serial/vr41xx_siu.c
index 9d3bf75..c046c99 100644
--- a/drivers/tty/serial/vr41xx_siu.c
+++ b/drivers/tty/serial/vr41xx_siu.c
@@ -823,7 +823,7 @@ static struct console siu_console = {
 	.data	= &siu_uart_driver,
 };
 
-static int __devinit siu_console_init(void)
+static int siu_console_init(void)
 {
 	struct uart_port *port;
 	int i;
@@ -867,7 +867,7 @@ static struct uart_driver siu_uart_driver = {
 	.cons		= SERIAL_VR41XX_CONSOLE,
 };
 
-static int __devinit siu_probe(struct platform_device *dev)
+static int siu_probe(struct platform_device *dev)
 {
 	struct uart_port *port;
 	int num, i, retval;
diff --git a/drivers/tty/serial/vt8500_serial.c b/drivers/tty/serial/vt8500_serial.c
index dbcc909..80530c7 100644
--- a/drivers/tty/serial/vt8500_serial.c
+++ b/drivers/tty/serial/vt8500_serial.c
@@ -554,7 +554,7 @@ static struct uart_driver vt8500_uart_driver = {
 	.cons		= VT8500_CONSOLE,
 };
 
-static int __devinit vt8500_serial_probe(struct platform_device *pdev)
+static int vt8500_serial_probe(struct platform_device *pdev)
 {
 	struct vt8500_port *vt8500_port;
 	struct resource *mmres, *irqres;
diff --git a/drivers/tty/serial/xilinx_uartps.c b/drivers/tty/serial/xilinx_uartps.c
index b627363..6e9ce65 100644
--- a/drivers/tty/serial/xilinx_uartps.c
+++ b/drivers/tty/serial/xilinx_uartps.c
@@ -939,7 +939,7 @@ static struct uart_driver xuartps_uart_driver = {
  *
  * Returns 0 on success, negative error otherwise
  **/
-static int __devinit xuartps_probe(struct platform_device *pdev)
+static int xuartps_probe(struct platform_device *pdev)
 {
 	int rc;
 	struct uart_port *port;
diff --git a/drivers/tty/synclink.c b/drivers/tty/synclink.c
index 65b8669..87ba4ca 100644
--- a/drivers/tty/synclink.c
+++ b/drivers/tty/synclink.c
@@ -8064,7 +8064,7 @@ static void hdlcdev_exit(struct mgsl_struct *info)
 #endif /* CONFIG_HDLC */
 
 
-static int __devinit synclink_init_one (struct pci_dev *dev,
+static int synclink_init_one (struct pci_dev *dev,
 					const struct pci_device_id *ent)
 {
 	struct mgsl_struct *info;
diff --git a/drivers/tty/synclink_gt.c b/drivers/tty/synclink_gt.c
index 28a2ccf..cdd1ba7 100644
--- a/drivers/tty/synclink_gt.c
+++ b/drivers/tty/synclink_gt.c
@@ -3696,7 +3696,7 @@ static void device_init(int adapter_num, struct pci_dev *pdev)
 	}
 }
 
-static int __devinit init_one(struct pci_dev *dev,
+static int init_one(struct pci_dev *dev,
 			      const struct pci_device_id *ent)
 {
 	if (pci_enable_device(dev)) {
diff --git a/drivers/tty/synclinkmp.c b/drivers/tty/synclinkmp.c
index 3e56e1e..17454da 100644
--- a/drivers/tty/synclinkmp.c
+++ b/drivers/tty/synclinkmp.c
@@ -5592,7 +5592,7 @@ static void write_control_reg(SLMP_INFO * info)
 }
 
 
-static int __devinit synclinkmp_init_one (struct pci_dev *dev,
+static int synclinkmp_init_one (struct pci_dev *dev,
 					  const struct pci_device_id *ent)
 {
 	if (pci_enable_device(dev)) {
-- 
1.8.0

