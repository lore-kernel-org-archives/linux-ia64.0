From: Christoph Hellwig <hch@lst.de>
Date: Sat, 27 Sep 2003 14:17:20 +0000
Subject: [PATCH] fix the sn_pci_fixup mess
Message-Id: <marc-linux-ia64-106467226726524@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sn_pci_fixup() was doing completly different things based on whether
you passed 0 or 1 as argument to it.  Moved the main body of the second
part into a per-pci device function (sn_pci_fixup_one) and merged
both the first part and the loop of the second one into the only
caller.  All externs in pci_bus_cvlink.c moved to the front of the
file, they should move to proper headers later on.


diff -Nru a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c
--- a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Sat Sep 27 16:13:35 2003
+++ b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Sat Sep 27 16:13:35 2003
@@ -38,19 +38,37 @@
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/arch.h>
 
+
+/*
+ * Eek!! externs in .c files..
+ */
+extern void register_sn_procfs(void);
+extern void irix_io_init(void);
+extern void sn_init_cpei_timer(void);
+extern void intr_init_vecblk(cnodeid_t);
+extern void register_pcibr_intr(int irq, pcibr_intr_t intr);
+extern void ioconfig_bus_init(void);
+extern void ioconfig_get_busnum(char *, int *);
+extern void ioconfig_bus_new_entries(void);
+extern int isIO9(int);
+extern int bit_pos_to_irq(int);
+extern int iomoduleid_get(nasid_t);
+
 extern int bridge_rev_b_data_check_disable;
+extern struct pci_ops sn_pci_ops;
+extern irqpda_t *irqpdaindr;
+extern int numnodes;
+
 
 vertex_hdl_t busnum_to_pcibr_vhdl[MAX_PCI_XWIDGET];
 nasid_t busnum_to_nid[MAX_PCI_XWIDGET];
 void * busnum_to_atedmamaps[MAX_PCI_XWIDGET];
 unsigned char num_bridges;
 static int done_probing;
-extern irqpda_t *irqpdaindr;
 
 static int pci_bus_map_create(vertex_hdl_t xtalk, char * io_moduleid);
 vertex_hdl_t devfn_to_vertex(unsigned char busnum, unsigned int devfn);
 
-extern void register_pcibr_intr(int irq, pcibr_intr_t intr);
 
 void sn_dma_flush_init(unsigned long start, unsigned long end, int idx, int pin, int slot);
 
@@ -74,9 +92,6 @@
 void
 pci_bus_cvlink_init(void)
 {
-
-	extern void ioconfig_bus_init(void);
-
 	memset(busnum_to_pcibr_vhdl, 0x0, sizeof(vertex_hdl_t) * MAX_PCI_XWIDGET);
 	memset(busnum_to_nid, 0x0, sizeof(nasid_t) * MAX_PCI_XWIDGET);
 
@@ -235,7 +250,6 @@
 	struct sn_flush_device_list *p;
 	bridge_t *b;
 	bridgereg_t dev_sel;
-	extern int isIO9(int);
 	int bwin;
 	int i;
 
@@ -411,173 +425,98 @@
 	}
 }
 
-/*
- * sn_pci_fixup() - This routine is called when platform_pci_fixup() is 
- *	invoked at the end of pcibios_init() to link the Linux pci 
- *	infrastructure to SGI IO Infrasturcture - ia64/kernel/pci.c
- *
- *	Other platform specific fixup can also be done here.
- */
-void
-sn_pci_fixup(int arg)
+static void __init sn_pci_fixup_one(struct pci_dev *pdev)
 {
-	struct list_head *ln;
-	struct pci_bus *pci_bus = NULL;
-	struct pci_dev *device_dev = NULL;
-	struct sn_widget_sysdata *widget_sysdata;
 	struct sn_device_sysdata *device_sysdata;
 	pcibr_intr_t intr_handle;
-	int cpuid;
 	vertex_hdl_t device_vertex;
 	pciio_intr_line_t lines;
-	extern int numnodes;
-	int cnode;
-
-	if (arg = 0) {
-#ifdef CONFIG_PROC_FS
-		extern void register_sn_procfs(void);
-#endif
-		extern void irix_io_init(void);
-		extern void sn_init_cpei_timer(void);
-		
-		init_hcl();
-		irix_io_init();
-		
-		for (cnode = 0; cnode < numnodes; cnode++) {
-			extern void intr_init_vecblk(cnodeid_t);
-			intr_init_vecblk(cnode);
-		} 
-
-		sn_init_cpei_timer();
-
-#ifdef CONFIG_PROC_FS
-		register_sn_procfs();
-#endif
+	unsigned int irq;
+	unsigned long size;
+	int idx;
+	u16 cmd;
+
+	/* Set the device vertex */
+	device_sysdata = kmalloc(sizeof(*device_sysdata), GFP_KERNEL);
+	if (!device_sysdata)
 		return;
-	}
-
-
-	done_probing = 1;
+	device_sysdata->vhdl = devfn_to_vertex(pdev->bus->number, pdev->devfn);
+	device_sysdata->isa64 = 0;
+	device_vertex = device_sysdata->vhdl;
 
-	/*
-	 * Initialize the pci bus vertex in the pci_bus struct.
-	 */
-	for( ln = pci_root_buses.next; ln != &pci_root_buses; ln = ln->next) {
-		pci_bus = pci_bus_b(ln);
-		widget_sysdata = kmalloc(sizeof(struct sn_widget_sysdata), 
-					GFP_KERNEL);
-		widget_sysdata->vhdl = pci_bus_to_vertex(pci_bus->number);
-		pci_bus->sysdata = (void *)widget_sysdata;
-	}
+	pdev->sysdata = device_sysdata;
+	set_isPIC(device_sysdata);
 
 	/*
- 	 * set the root start and end so that drivers calling check_region()
-	 * won't see a conflict
+	 * Set the xbridge Device(X) Write Buffer Flush and Xbow Flush 
+	 * register addresses.
 	 */
-	ioport_resource.start  = 0xc000000000000000;
-	ioport_resource.end =    0xcfffffffffffffff;
+	set_flush_addresses(pdev, device_sysdata);
+	pci_read_config_word(pdev, PCI_COMMAND, &cmd);
 
 	/*
-	 * Set the root start and end for Mem Resource.
+	 * Set the resources address correctly.  The assumption here 
+	 * is that the addresses in the resource structure has been
+	 * read from the card and it was set in the card by our
+	 * Infrastructure ..
 	 */
-	iomem_resource.start = 0;
-	iomem_resource.end = 0xffffffffffffffff;
+	for (idx = 0; idx < PCI_ROM_RESOURCE; idx++) {
+		size = pdev->resource[idx].end -
+			pdev->resource[idx].start;
+		if (!size)
+			continue;
+		pdev->resource[idx].start +			(unsigned long)pciio_pio_addr(device_vertex, 0,
+				PCIIO_SPACE_WIN(idx), 0, size, 0,
+				(IS_PIC_DEVICE(pdev)) ? 0 :
+					PCIIO_BYTE_STREAM);
+		pdev->resource[idx].start |= __IA64_UNCACHED_OFFSET;
+		pdev->resource[idx].end = pdev->resource[idx].start + size;
+
+		if (pdev->resource[idx].flags & IORESOURCE_IO)
+			cmd |= PCI_COMMAND_IO;
+		if (pdev->resource[idx].flags & IORESOURCE_MEM)
+			cmd |= PCI_COMMAND_MEMORY;
+	}
 
 	/*
-	 * Initialize the device vertex in the pci_dev struct.
-	 */
-	while ((device_dev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, device_dev)) != NULL) {
-		unsigned int irq;
-		int idx;
-		u16 cmd;
-		unsigned long size;
-		extern int bit_pos_to_irq(int);
-
-		/* Set the device vertex */
-
-		device_sysdata = kmalloc(sizeof(struct sn_device_sysdata),
-					 GFP_KERNEL);
-		device_sysdata->vhdl = devfn_to_vertex(device_dev->bus->number, device_dev->devfn);
-		device_sysdata->isa64 = 0;
-		device_vertex = device_sysdata->vhdl;
-
-		device_dev->sysdata = (void *) device_sysdata;
-		set_isPIC(device_sysdata);
-
-		/*
-		 * Set the xbridge Device(X) Write Buffer Flush and Xbow Flush 
-		 * register addresses.
-		 */
-		set_flush_addresses(device_dev, device_sysdata);
-		pci_read_config_word(device_dev, PCI_COMMAND, &cmd);
-
-		/*
-		 * Set the resources address correctly.  The assumption here 
-		 * is that the addresses in the resource structure has been
-		 * read from the card and it was set in the card by our
-		 * Infrastructure ..
-		 */
-		for (idx = 0; idx < PCI_ROM_RESOURCE; idx++) {
-			size = 0;
-			size = device_dev->resource[idx].end -
-				device_dev->resource[idx].start;
-			if (size) {
-				device_dev->resource[idx].start = (unsigned long)pciio_pio_addr(device_vertex, 0, PCIIO_SPACE_WIN(idx), 0, size, 0, (IS_PIC_DEVICE(device_dev)) ? 0 : PCIIO_BYTE_STREAM);
-				device_dev->resource[idx].start |= __IA64_UNCACHED_OFFSET;
-			}
-			else
-				continue;
-
-			device_dev->resource[idx].end = 
-				device_dev->resource[idx].start + size;
-
-			if (device_dev->resource[idx].flags & IORESOURCE_IO)
-				cmd |= PCI_COMMAND_IO;
-
-			if (device_dev->resource[idx].flags & IORESOURCE_MEM)
-				cmd |= PCI_COMMAND_MEMORY;
-		}
-
-		/*
-		 * Update the Command Word on the Card.
-		 */
-		cmd |= PCI_COMMAND_MASTER; /* If the device doesn't support */
-					   /* bit gets dropped .. no harm */
-		pci_write_config_word(device_dev, PCI_COMMAND, cmd);
-		
-		pci_read_config_byte(device_dev, PCI_INTERRUPT_PIN,
-				     (unsigned char *)&lines);
-	 
-		irqpdaindr->curr = device_dev;
-		intr_handle = pcibr_intr_alloc(device_vertex, NULL, lines, device_vertex);
-
-		irq = intr_handle->bi_irq;
-		irqpdaindr->device_dev[irq] = device_dev;
-		cpuid = intr_handle->bi_cpu;
-		pcibr_intr_connect(intr_handle, (intr_func_t)0, (intr_arg_t)0);
-		device_dev->irq = irq;
-		register_pcibr_intr(irq, intr_handle);
-
-		for (idx = 0; idx < PCI_ROM_RESOURCE; idx++) {
-			int ibits = intr_handle->bi_ibits;
-			int i;
-
-			size = device_dev->resource[idx].end -
-				device_dev->resource[idx].start;
-			if (size = 0)
-				continue;
+	 * Update the Command Word on the Card.
+	 *
+	 * If the device doesn't support bit gets dropped .. no harm
+	 */
+	cmd |= PCI_COMMAND_MASTER;
+	pci_write_config_word(pdev, PCI_COMMAND, cmd);
+
+	pci_read_config_byte(pdev, PCI_INTERRUPT_PIN,
+			(unsigned char *)&lines);
+
+	irqpdaindr->curr = pdev;  /* XXX: horrible hack */
+	intr_handle = pcibr_intr_alloc(device_vertex, NULL,
+			lines, device_vertex);
+
+	irq = intr_handle->bi_irq;
+	irqpdaindr->device_dev[irq] = pdev;
+	pcibr_intr_connect(intr_handle, (intr_func_t)0, (intr_arg_t)0);
+	pdev->irq = irq;
+	register_pcibr_intr(irq, intr_handle);
+
+	for (idx = 0; idx < PCI_ROM_RESOURCE; idx++) {
+		int ibits = intr_handle->bi_ibits;
+		int i;
+
+		size = pdev->resource[idx].end -
+			pdev->resource[idx].start;
+		if (size = 0)
+			continue;
 
-			for (i=0; i<8; i++) {
-				if (ibits & (1 << i) ) {
-					sn_dma_flush_init(device_dev->resource[idx].start, 
-							device_dev->resource[idx].end,
-							idx,
-							i,
-							PCI_SLOT(device_dev->devfn));
-				}
+		for (i = 0; i < 8; i++) {
+			if (ibits & (1 << i) ) {
+				sn_dma_flush_init(pdev->resource[idx].start, 
+						  pdev->resource[idx].end,
+						  idx, i,
+						  PCI_SLOT(pdev->devfn));
 			}
 		}
-
 	}
 }
 
@@ -642,7 +581,6 @@
 	graph_error_t rv;
 	int bus;
 	int basebus_num;
-	extern void ioconfig_get_busnum(char *, int *);
 
 	int bus_number;
 
@@ -799,13 +737,11 @@
 	char tmp_name[256];
 	int i, ii, j;
 	char *brick_name;
-	extern void ioconfig_bus_new_entries(void);
 
 	/*
 	 * Figure out which IO Brick is connected to the Compute Bricks.
 	 */
 	for (i = 0; i < nummodules; i++) {
-		extern int iomoduleid_get(nasid_t);
 		moduleid_t iobrick_id;
 		nasid_t nasid = -1;
 		int nodecnt;
@@ -859,18 +795,23 @@
 /*
  * Ugly hack to get PCI setup until we have a proper ACPI namespace.
  */
-extern struct pci_ops sn_pci_ops;
-int __init
-sn_pci_init (void)
+#define PCI_BUSES_TO_SCAN 256
+static int __init sn_pci_init (void)
 {
-#	define PCI_BUSES_TO_SCAN 256
-	int i = 0;
 	struct pci_controller *controller;
+	struct pci_dev *pdev = NULL;
+	struct list_head *ln;
+	int i = 0;
 
-	/*
-	 * set pci_raw_ops, etc.
-	 */
-	sn_pci_fixup(0);
+	init_hcl();
+	irix_io_init();
+		
+	for (i = 0; i < numnodes; i++)
+		intr_init_vecblk(i);
+	sn_init_cpei_timer();
+#ifdef CONFIG_PROC_FS
+	register_sn_procfs();
+#endif
 
 	controller = kmalloc(sizeof(struct pci_controller), GFP_KERNEL);
 	if (controller) {
@@ -880,11 +821,40 @@
 			pci_scan_bus(i, &sn_pci_ops, controller);
 	}
 
+	done_probing = 1;
+
+	/*
+	 * Initialize the pci bus vertex in the pci_bus struct.
+	 */
+	for (ln = pci_root_buses.next; ln != &pci_root_buses; ln = ln->next) {
+		struct pci_bus *pci_bus = pci_bus_b(ln);
+		struct sn_widget_sysdata *widget_sysdata;
+
+		widget_sysdata = kmalloc(sizeof(*widget_sysdata), GFP_KERNEL);
+		if (!widget_sysdata)
+			return 0;
+		widget_sysdata->vhdl = pci_bus_to_vertex(pci_bus->number);
+		pci_bus->sysdata = widget_sysdata;
+	}
+
 	/*
-	 * actually find devices and fill in hwgraph structs
+ 	 * set the root start and end so that drivers calling request_region()
+	 * won't see a conflict
+	 */
+	ioport_resource.start  = 0xc000000000000000;
+	ioport_resource.end =    0xcfffffffffffffff;
+
+	/*
+	 * Set the root start and end for Mem Resource.
 	 */
-	sn_pci_fixup(1);
+	iomem_resource.start = 0;
+	iomem_resource.end = 0xffffffffffffffff;
 
+	/*
+	 * Initialize the device vertex in the pci_dev struct.
+	 */
+	while ((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev)))
+		sn_pci_fixup_one(pdev);
 	return 0;
 }
 
