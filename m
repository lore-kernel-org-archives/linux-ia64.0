From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 07 Aug 2003 23:00:18 +0000
Subject: Re: [PATCH] sn2 pci fixes (among others)
Message-Id: <marc-linux-ia64-106029724220038@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106028902811432@msgid-missing>
In-Reply-To: <marc-linux-ia64-106028902811432@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 07, 2003 at 02:39:07PM -0700, David Mosberger wrote:
> >>>>> On Thu, 7 Aug 2003 13:42:56 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> sn2 still doesn't use ACPI to describe PCI busses on the system (I'm
>   Jesse> working on it), so we have to do it the old fashioned way.  This patch
>   Jesse> also includes a few other fixes.
> 
> Actually, the patch didn't apply.  I'm pushing out the latest
> linux-ia64-2.5 as I'm writing this.  Should be there in a few...

I'm not quite sure how I hosed that one, but here's another one.

 arch/ia64/sn/io/hwgfs/interface.c           |    5 
 arch/ia64/sn/io/machvec/pci.c               |   86 ++-------------
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c    |  151 ++++++++++------------------
 arch/ia64/sn/io/platform_init/sgi_io_init.c |   31 -----
 arch/ia64/sn/kernel/sn2/cache.c             |    6 +
 include/asm-ia64/sn/hcl.h                   |    1 

Thanks,
Jesse

diff -Nru a/arch/ia64/sn/io/hwgfs/interface.c b/arch/ia64/sn/io/hwgfs/interface.c
--- a/arch/ia64/sn/io/hwgfs/interface.c	Thu Aug  7 15:58:39 2003
+++ b/arch/ia64/sn/io/hwgfs/interface.c	Thu Aug  7 15:58:39 2003
@@ -40,14 +40,11 @@
 #include <linux/namei.h>
 #include <linux/string.h>
 #include <linux/slab.h>
+#include <linux/dcache.h>
 #include <asm/sn/hwgfs.h>
 
 
 extern struct vfsmount *hwgfs_vfsmount;
-
-/* TODO: Move this to some .h file or, more likely, use a slightly
-   different interface from lookup_create. */
-extern struct dentry *lookup_create(struct nameidata *nd, int is_dir);
 
 static int
 walk_parents_mkdir(
diff -Nru a/arch/ia64/sn/io/machvec/pci.c b/arch/ia64/sn/io/machvec/pci.c
--- a/arch/ia64/sn/io/machvec/pci.c	Thu Aug  7 15:58:39 2003
+++ b/arch/ia64/sn/io/machvec/pci.c	Thu Aug  7 15:58:39 2003
@@ -30,17 +30,13 @@
 #include <asm/sn/pci/pcibr_private.h>
 #include <asm/sn/pci/bridge.h>
 
-#ifdef DEBUG_CONFIG
-#define DBG(x...) printk(x)
-#else
-#define DBG(x...)
-#endif
-
-
-
+/*
+ * These routines are only used during sn_pci_init for probing each bus, and
+ * can probably be removed with a little more cleanup now that the SAL routines
+ * work on sn2.
+ */
 #ifdef CONFIG_PCI
 
-extern vertex_hdl_t pci_bus_to_vertex(unsigned char);
 extern vertex_hdl_t devfn_to_vertex(unsigned char bus, unsigned char devfn);
 
 int sn_read_config(struct pci_bus *bus, unsigned int devfn, int where, int size, u32 *val)
@@ -49,10 +45,12 @@
 	vertex_hdl_t device_vertex;
 
 	device_vertex = devfn_to_vertex(bus->number, devfn);
+
 	if (!device_vertex)
 		return PCIBIOS_DEVICE_NOT_FOUND;
-	res = pciio_config_get(device_vertex, (unsigned) where, size);
-	*val = (unsigned int) res;
+
+	res = pciio_config_get(device_vertex, (unsigned)where, size);
+	*val = (u32)res;
 	return PCIBIOS_SUCCESSFUL;
 }
 
@@ -61,79 +59,21 @@
 	vertex_hdl_t device_vertex;
 
 	device_vertex = devfn_to_vertex(bus->number, devfn);
+
 	if (!device_vertex)
 		return PCIBIOS_DEVICE_NOT_FOUND;
-	pciio_config_set( device_vertex, (unsigned)where, size, (uint64_t) val);
+
+	pciio_config_set(device_vertex, (unsigned)where, size, (uint64_t)val);
 	return PCIBIOS_SUCCESSFUL;
 }
 
 struct pci_ops sn_pci_ops = {
 	.read = sn_read_config,
-	.write = sn_write_config
+	.write = sn_write_config,
 };
 
-/*
- * sn_pci_find_bios - SNIA64 pci_find_bios() platform specific code.
- */
-void __init
-sn_pci_find_bios(void)
-{
-	extern struct pci_ops *pci_root_ops;
-	/*
-	 * Go initialize our IO Infrastructure ..
-	 */
-	extern void sgi_master_io_infr_init(void);
-
-	sgi_master_io_infr_init();
-
-	/* sn_io_infrastructure_init(); */
-	pci_root_ops = &sn_pci_ops;
-}
-
-void
-pci_fixup_ioc3(struct pci_dev *d)
-{
-        int 		i;
-	unsigned int 	size;
-
-        /* IOC3 only decodes 0x20 bytes of the config space, reading
-	 * beyond that is relatively benign but writing beyond that
-	 * (especially the base address registers) will shut down the
-	 * pci bus...so avoid doing so.
-	 * NOTE: this means we can't program the intr_pin into the device,
-	 *       currently we hack this with special code in 
-	 *	 sgi_pci_intr_support()
-	 */
-        DBG("pci_fixup_ioc3: Fixing base addresses for ioc3 device %s\n", d->slot_name);
-
-	/* I happen to know from the spec that the ioc3 needs only 0xfffff 
-	 * The standard pci trick of writing ~0 to the baddr and seeing
-	 * what comes back doesn't work with the ioc3
-	 */
-	size = 0xfffff;
-	d->resource[0].end = (unsigned long) d->resource[0].start + (unsigned long) size;
-
-	/*
-	 * Zero out the resource structure .. because we did not go through 
-	 * the normal PCI Infrastructure Init, garbbage are left in these 
-	 * fileds.
-	 */
-        for (i = 1; i <= PCI_ROM_RESOURCE; i++) {
-                d->resource[i].start = 0UL;
-                d->resource[i].end = 0UL;
-                d->resource[i].flags = 0UL;
-        }
-
-        d->subsystem_vendor = 0;
-        d->subsystem_device = 0;
-
-}
-
 #else
-void sn_pci_find_bios(void) {}
-void pci_fixup_ioc3(struct pci_dev *d) {}
 struct list_head pci_root_buses;
 struct list_head pci_root_buses;
 struct list_head pci_devices;
-
 #endif /* CONFIG_PCI */
diff -Nru a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c
--- a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Thu Aug  7 15:58:39 2003
+++ b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Thu Aug  7 15:58:39 2003
@@ -412,34 +412,6 @@
 }
 
 /*
- * Most drivers currently do not properly tell the arch specific pci dma
- * interfaces whether they can handle A64. Here is where we privately
- * keep track of this.
- */
-static void __init
-set_sn_pci64(struct pci_dev *dev)
-{
-	unsigned short vendor = dev->vendor;
-	unsigned short device = dev->device;
-
-	if (vendor = PCI_VENDOR_ID_QLOGIC) {
-		if ((device = PCI_DEVICE_ID_QLOGIC_ISP2100) ||
-				(device = PCI_DEVICE_ID_QLOGIC_ISP2200)) {
-			SET_PCIA64(dev);
-			return;
-		}
-	}
-
-	if (vendor = PCI_VENDOR_ID_SGI) {
-		if (device = PCI_DEVICE_ID_SGI_IOC3) {
-			SET_PCIA64(dev);
-			return;
-		}
-	}
-
-}
-
-/*
  * sn_pci_fixup() - This routine is called when platform_pci_fixup() is 
  *	invoked at the end of pcibios_init() to link the Linux pci 
  *	infrastructure to SGI IO Infrasturcture - ia64/kernel/pci.c
@@ -455,10 +427,9 @@
 	struct sn_widget_sysdata *widget_sysdata;
 	struct sn_device_sysdata *device_sysdata;
 	pciio_intr_t intr_handle;
-	int cpuid, bit;
+	int cpuid;
 	vertex_hdl_t device_vertex;
 	pciio_intr_line_t lines;
-	extern void sn_pci_find_bios(void);
 	extern int numnodes;
 	int cnode;
 
@@ -466,8 +437,11 @@
 #ifdef CONFIG_PROC_FS
 		extern void register_sn_procfs(void);
 #endif
-
-		sn_pci_find_bios();
+		extern void irix_io_init(void);
+		
+		init_hcl();
+		irix_io_init();
+		
 		for (cnode = 0; cnode < numnodes; cnode++) {
 			extern void intr_init_vecblk(nodepda_t *npda, cnodeid_t, int);
 			intr_init_vecblk(NODEPDA(cnode), cnode, 0);
@@ -512,32 +486,25 @@
 		unsigned int irq;
 		int idx;
 		u16 cmd;
-		vertex_hdl_t vhdl;
 		unsigned long size;
 		extern int bit_pos_to_irq(int);
 
-		if (device_dev->vendor = PCI_VENDOR_ID_SGI &&
-				device_dev->device = PCI_DEVICE_ID_SGI_IOC3) {
-			extern void pci_fixup_ioc3(struct pci_dev *d);
-			pci_fixup_ioc3(device_dev);
-		}
-
 		/* Set the device vertex */
 
 		device_sysdata = kmalloc(sizeof(struct sn_device_sysdata),
-					GFP_KERNEL);
+					 GFP_KERNEL);
 		device_sysdata->vhdl = devfn_to_vertex(device_dev->bus->number, device_dev->devfn);
 		device_sysdata->isa64 = 0;
-		/*
-		 * Set the xbridge Device(X) Write Buffer Flush and Xbow Flush 
-		 * register addresses.
-		 */
-		(void) set_flush_addresses(device_dev, device_sysdata);
+		device_vertex = device_sysdata->vhdl;
 
 		device_dev->sysdata = (void *) device_sysdata;
-		set_sn_pci64(device_dev);
 		set_isPIC(device_sysdata);
 
+		/*
+		 * Set the xbridge Device(X) Write Buffer Flush and Xbow Flush 
+		 * register addresses.
+		 */
+		set_flush_addresses(device_dev, device_sysdata);
 		pci_read_config_word(device_dev, PCI_COMMAND, &cmd);
 
 		/*
@@ -546,13 +513,12 @@
 		 * read from the card and it was set in the card by our
 		 * Infrastructure ..
 		 */
-		vhdl = device_sysdata->vhdl;
 		for (idx = 0; idx < PCI_ROM_RESOURCE; idx++) {
 			size = 0;
 			size = device_dev->resource[idx].end -
 				device_dev->resource[idx].start;
 			if (size) {
-				device_dev->resource[idx].start = (unsigned long)pciio_pio_addr(vhdl, 0, PCIIO_SPACE_WIN(idx), 0, size, 0, (IS_PIC_DEVICE(device_dev)) ? 0 : PCIIO_BYTE_STREAM);
+				device_dev->resource[idx].start = (unsigned long)pciio_pio_addr(device_vertex, 0, PCIIO_SPACE_WIN(idx), 0, size, 0, (IS_PIC_DEVICE(device_dev)) ? 0 : PCIIO_BYTE_STREAM);
 				device_dev->resource[idx].start |= __IA64_UNCACHED_OFFSET;
 			}
 			else
@@ -567,28 +533,6 @@
 			if (device_dev->resource[idx].flags & IORESOURCE_MEM)
 				cmd |= PCI_COMMAND_MEMORY;
 		}
-#if 0
-	/*
-	 * Software WAR for a Software BUG.
-	 * This is only temporary.
-	 * See PV 872791
-	 */
-
-		/*
-		 * Now handle the ROM resource ..
-		 */
-		size = device_dev->resource[PCI_ROM_RESOURCE].end -
-			device_dev->resource[PCI_ROM_RESOURCE].start;
-
-		if (size) {
-			device_dev->resource[PCI_ROM_RESOURCE].start -			(unsigned long) pciio_pio_addr(vhdl, 0, PCIIO_SPACE_ROM, 0, 
-				size, 0, (IS_PIC_DEVICE(device_dev)) ? 0 : PCIIO_BYTE_STREAM);
-			device_dev->resource[PCI_ROM_RESOURCE].start |= __IA64_UNCACHED_OFFSET;
-			device_dev->resource[PCI_ROM_RESOURCE].end -			device_dev->resource[PCI_ROM_RESOURCE].start + size;
-		}
-#endif
 
 		/*
 		 * Update the Command Word on the Card.
@@ -596,16 +540,10 @@
 		cmd |= PCI_COMMAND_MASTER; /* If the device doesn't support */
 					   /* bit gets dropped .. no harm */
 		pci_write_config_word(device_dev, PCI_COMMAND, cmd);
-
-		pci_read_config_byte(device_dev, PCI_INTERRUPT_PIN, (unsigned char *)&lines);
-		if (device_dev->vendor = PCI_VENDOR_ID_SGI &&
-			device_dev->device = PCI_DEVICE_ID_SGI_IOC3 ) {
-				lines = 1;
-		}
- 
-		device_sysdata = (struct sn_device_sysdata *)device_dev->sysdata;
-		device_vertex = device_sysdata->vhdl;
- 
+		
+		pci_read_config_byte(device_dev, PCI_INTERRUPT_PIN,
+				     (unsigned char *)&lines);
+	 
 		irqpdaindr->current = device_dev;
 		intr_handle = pciio_intr_alloc(device_vertex, NULL, lines, device_vertex);
 
@@ -622,7 +560,8 @@
 
 			size = device_dev->resource[idx].end -
 				device_dev->resource[idx].start;
-			if (size = 0) continue;
+			if (size = 0)
+				continue;
 
 			for (i=0; i<8; i++) {
 				if (ibits & (1 << i) ) {
@@ -636,22 +575,6 @@
 		}
 
 	}
-#ifdef ajmtestintr
-		{
-			int slot = PCI_SLOT(device_dev->devfn);
-			static int timer_set = 0;
-			pcibr_intr_t	pcibr_intr = (pcibr_intr_t)intr_handle;
-			pcibr_soft_t	pcibr_soft = pcibr_intr->bi_soft;
-			extern void intr_test_handle_intr(int, void*, struct pt_regs *);
-
-			if (!timer_set) {
-				intr_test_set_timer();
-				timer_set = 1;
-			}
-			intr_test_register_irq(irq, pcibr_soft, slot);
-			request_irq(irq, intr_test_handle_intr,0,NULL, NULL);
-		}
-#endif
 }
 
 /*
@@ -928,3 +851,37 @@
 
 	return(0);
 }
+
+/*
+ * Ugly hack to get PCI setup until we have a proper ACPI namespace.
+ */
+extern struct pci_ops sn_pci_ops;
+int __init
+sn_pci_init (void)
+{
+#	define PCI_BUSES_TO_SCAN 256
+	int i = 0;
+	struct pci_controller *controller;
+
+	/*
+	 * set pci_raw_ops, etc.
+	 */
+	sn_pci_fixup(0);
+
+	controller = kmalloc(sizeof(struct pci_controller), GFP_KERNEL);
+	if (controller) {
+		memset(controller, 0, sizeof(struct pci_controller));
+		/* just allocate some devices and fill in the pci_dev structs */
+		for (i = 0; i < PCI_BUSES_TO_SCAN; i++)
+			pci_scan_bus(i, &sn_pci_ops, controller);
+	}
+
+	/*
+	 * actually find devices and fill in hwgraph structs
+	 */
+	sn_pci_fixup(1);
+
+	return 0;
+}
+
+subsys_initcall(sn_pci_init);
diff -Nru a/arch/ia64/sn/io/platform_init/sgi_io_init.c b/arch/ia64/sn/io/platform_init/sgi_io_init.c
--- a/arch/ia64/sn/io/platform_init/sgi_io_init.c	Thu Aug  7 15:58:39 2003
+++ b/arch/ia64/sn/io/platform_init/sgi_io_init.c	Thu Aug  7 15:58:39 2003
@@ -9,15 +9,13 @@
 #include <linux/types.h>
 #include <linux/config.h>
 #include <linux/slab.h>
+#include <linux/smp.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/io.h>
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/klconfig.h>
 #include <asm/sn/sn_private.h>
 #include <asm/sn/pda.h>
-#include <linux/smp.h>
-
-extern int init_hcl(void);
 
 /*
  * per_hub_init
@@ -79,31 +77,4 @@
 
 	/* Initialize error interrupts for this hub. */
 	hub_error_init(cnode);
-}
-
-/*
- * This routine is responsible for the setup of all the IRIX hwgraph style
- * stuff that's been pulled into linux.  It's called by sn_pci_find_bios which
- * is called just before the generic Linux PCI layer does its probing (by 
- * platform_pci_fixup aka sn_pci_fixup).
- *
- * It is very IMPORTANT that this call is only made by the Master CPU!
- *
- */
-
-void
-sgi_master_io_infr_init(void)
-{
-	extern void irix_io_init(void);
-
-	init_hcl(); /* Sets up the hwgraph compatibility layer with devfs */
-	irix_io_init(); /* Do IRIX Compatibility IO Init */
-
-#ifdef	CONFIG_KDB
-	{
-		extern void kdba_io_init(void);
-		kdba_io_init();
-	}
-#endif
-
 }
diff -Nru a/arch/ia64/sn/kernel/sn2/cache.c b/arch/ia64/sn/kernel/sn2/cache.c
--- a/arch/ia64/sn/kernel/sn2/cache.c	Thu Aug  7 15:58:39 2003
+++ b/arch/ia64/sn/kernel/sn2/cache.c	Thu Aug  7 15:58:39 2003
@@ -26,6 +26,12 @@
 sn_flush_all_caches(long flush_addr, long bytes)
 {
 	flush_icache_range(flush_addr, flush_addr+bytes);
+	/*
+	 * The last call may have returned before the caches
+	 * were actually flushed, so we call it again to make
+	 * sure.
+	 */
+	flush_icache_range(flush_addr, flush_addr+bytes);
 	mb();
 }
 EXPORT_SYMBOL(sn_flush_all_caches);
diff -Nru a/include/asm-ia64/sn/hcl.h b/include/asm-ia64/sn/hcl.h
--- a/include/asm-ia64/sn/hcl.h	Thu Aug  7 15:58:39 2003
+++ b/include/asm-ia64/sn/hcl.h	Thu Aug  7 15:58:39 2003
@@ -105,5 +105,6 @@
 extern char * vertex_to_name(vertex_hdl_t, char *, uint);
 extern graph_error_t hwgraph_vertex_unref(vertex_hdl_t);
 
+extern int init_hcl(void);
 
 #endif /* _ASM_IA64_SN_HCL_H */
