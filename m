From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 23 May 2003 20:03:00 +0000
Subject: [Linux-ia64] [PATCH] more sn2 cleanups
Message-Id: <marc-linux-ia64-105590723706016@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's another sn2 update.  It includes a bunch of misc. bits:
  o a bunch of cleanup from hch
  o addition of DMA routine wrappers
  o update of other PCI routines
  o topology.h prototype addition.

 arch/ia64/Kconfig                            |   18 
 arch/ia64/Makefile                           |    3 
 arch/ia64/sn/io/Makefile                     |    4 
 arch/ia64/sn/io/drivers/Makefile             |    2 
 arch/ia64/sn/io/drivers/pciba.c              |  941 ---------------------------
 arch/ia64/sn/io/machvec/pci.c                |  176 -----
 arch/ia64/sn/io/machvec/pci_dma.c            |  128 +++
 arch/ia64/sn/io/platform_init/irix_io_init.c |    1 
 arch/ia64/sn/io/sn2/pcibr/Makefile           |    2 
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c        |  194 -----
 arch/ia64/sn/io/sn2/pic.c                    |    2 
 arch/ia64/sn/io/sn2/xbow.c                   |  133 ---
 arch/ia64/sn/io/xswitch.c                    |    2 
 arch/ia64/sn/kernel/sn_ksyms.c               |   19 
 include/asm-ia64/sn/pci/pciba.h              |  121 ---
 include/asm-ia64/sn/sgi.h                    |   26 
 include/asm-ia64/topology.h                  |    2 
 17 files changed, 165 insertions(+), 1609 deletions(-)

Thanks,
Jesse


diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/Kconfig linux-2.5.69-ia64-sn/arch/ia64/Kconfig
--- linux-2.5.69-ia64/arch/ia64/Kconfig	Fri May 23 10:12:00 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/Kconfig	Fri May 23 10:37:31 2003
@@ -292,16 +292,6 @@
 	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_SGI_SN2
 	default y
 
-config IA64_SGI_SN
-	bool
-	depends on IA64_SGI_SN2
-	default y
-
-config HWGFS_FS
-	bool
-	depends on IA64_SGI_SN2
-	default y
-
 config IA64_SGI_SN_DEBUG
 	bool "Enable extra debugging code"
 	depends on IA64_SGI_SN2
@@ -340,14 +330,6 @@
 	depends on IA64_SGI_SN2
 	default y
 
-config PCIBA
-	tristate "PCIBA support"
-	depends on IA64_SGI_SN2
-	help
-	  IRIX PCIBA-inspired user mode PCI interface for the SGI SN (Scalable
-	  NUMA) platform for IA-64.  Unless you are compiling a kernel for an
-	  SGI SN IA-64 box, say N.
-
 # On IA-64, we always want an ELF /proc/kcore.
 config KCORE_ELF
 	bool
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/Makefile linux-2.5.69-ia64-sn/arch/ia64/Makefile
--- linux-2.5.69-ia64/arch/ia64/Makefile	Fri May 23 10:12:00 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/Makefile	Fri May 23 10:37:14 2003
@@ -47,7 +47,6 @@
 endif
 
 cflags-$(CONFIG_ITANIUM_BSTEP_SPECIFIC)	+= -mb-step
-cflags-$(CONFIG_IA64_SGI_SN)		+= -DBRINGUP
 
 CFLAGS += $(cflags-y)
 head-y := arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
@@ -58,7 +57,7 @@
 core-$(CONFIG_IA64_DIG) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_GENERIC) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
-core-$(CONFIG_IA64_SGI_SN)	+= arch/ia64/sn/
+core-$(CONFIG_IA64_SGI_SN2)	+= arch/ia64/sn/
 
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/Makefile linux-2.5.69-ia64-sn/arch/ia64/sn/io/Makefile
--- linux-2.5.69-ia64/arch/ia64/sn/io/Makefile	Fri May 23 10:12:04 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/Makefile	Fri May 23 10:37:14 2003
@@ -9,7 +9,7 @@
 # Makefile for the sn io routines.
 #
 
-EXTRA_CFLAGS    := -DLITTLE_ENDIAN -DSHUB_SWAP_WAR
+EXTRA_CFLAGS    := -DLITTLE_ENDIAN
 
 obj-y += sgi_if.o xswitch.o sgi_io_sim.o cdl.o ate_utils.o \
-	 io.o machvec/ drivers/ platform_init/ sn2/ hwgfs/
\ No newline at end of file
+	 io.o machvec/ drivers/ platform_init/ sn2/ hwgfs/
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/drivers/Makefile linux-2.5.69-ia64-sn/arch/ia64/sn/io/drivers/Makefile
--- linux-2.5.69-ia64/arch/ia64/sn/io/drivers/Makefile	Fri May 23 10:12:04 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/drivers/Makefile	Fri May 23 10:37:31 2003
@@ -10,5 +10,3 @@
 EXTRA_CFLAGS    := -DLITTLE_ENDIAN
 
 obj-y				+= ioconfig_bus.o ifconfig_net.o
-
-obj-$(CONFIG_PCIBA)		+= pciba.o
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/drivers/pciba.c linux-2.5.69-ia64-sn/arch/ia64/sn/io/drivers/pciba.c
--- linux-2.5.69-ia64/arch/ia64/sn/io/drivers/pciba.c	Fri May 23 10:12:04 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/drivers/pciba.c	Fri May 23 10:37:31 2003
@@ -1,941 +0,0 @@
-/*
- * arch/ia64/sn/io/pciba.c
- *
- * IRIX PCIBA-inspired user mode PCI interface
- *
- * requires: devfs
- *
- * device nodes show up in /dev/pci/BB/SS.F (where BB is the bus the
- * device is on, SS is the slot the device is in, and F is the
- * device's function on a multi-function card).
- *
- * when compiled into the kernel, it will only be initialized by the
- * sgi sn1 specific initialization code.  in this case, device nodes
- * are under /dev/hw/..../
- *
- * This file is subject to the terms and conditions of the GNU General
- * Public License.  See the file "COPYING" in the main directory of
- * this archive for more details.
- *
- * Copyright (C) 2001-2003 Silicon Graphics, Inc.  All rights reserved.
- *
- * 03262001 - Initial version by Chad Talbott
- */
-
-
-/* jesse's beefs:
-
-   register_pci_device should be documented
-   
-   grossness with do_swap should be documented
-   
-   big, gross union'ized node_data should be replaced with independent
-   structures
-
-   replace global list of nodes with global lists of resources.  could
-   use object oriented approach of allocating and cleaning up
-   resources.
-   
-*/
-
-
-#include <linux/config.h>
-#include <linux/module.h>
-#include <asm/sn/sgi.h>
-#include <asm/sn/iograph.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/labelcl.h>
-#include <linux/pci.h>
-#include <linux/list.h>
-
-#include <linux/mm.h>
-#include <linux/slab.h>
-#include <linux/vmalloc.h>
-#include <linux/mman.h>
-#include <linux/init.h>
-#include <linux/raw.h>
-#include <linux/capability.h>
-
-#include <asm/uaccess.h>
-#include <asm/sn/sgi.h>
-#include <asm/io.h>
-#include <asm/pgalloc.h>
-#include <asm/page.h>
-
-#include <asm/sn/pci/pciba.h>
-
-
-MODULE_DESCRIPTION("User mode PCI interface");
-MODULE_AUTHOR("Chad Talbott");
-
-
-#undef DEBUG_PCIBA
-/* #define DEBUG_PCIBA */
-
-#undef TRACE_PCIBA
-/* #define TRACE_PCIBA */
-
-#if defined(DEBUG_PCIBA)
-#  define DPRINTF(x...) printk(KERN_DEBUG x)
-#else
-#  define DPRINTF(x...)
-#endif
-
-#if defined(TRACE_PCIBA)
-#  if defined(__GNUC__)
-#    define TRACE()	printk(KERN_DEBUG "%s:%d:%s\n", \
-			       __FILE__, __LINE__, __FUNCTION__)
-#  else
-#    define TRACE()	printk(KERN_DEBUG "%s:%d\n", __LINE__, __FILE__)
-#  endif
-#else
-#  define TRACE()
-#endif
-
-
-typedef enum { failure, success } status;
-typedef enum { false, true } boolean;
-
-
-/* major data structures:
-
-   struct node_data -
-   
-   	one for each file registered with devfs.  contains everything
-   	that any file's fops would need to know about.
-
-   struct dma_allocation -
-
-   	a single DMA allocation.  only the 'dma' nodes care about
-   	these.  they are there primarily to allow the driver to look
-   	up the kernel virtual address of dma buffers allocated by
-   	pci_alloc_consistent, as the application is only given the
-   	physical address (to program the device's dma, presumably) and
-   	cannot supply the kernel virtual address when freeing the
-   	buffer.
-
-	it's also useful to maintain a list of buffers allocated
-	through a specific node to allow some sanity checking by this
-	driver.  this prevents (for example) a broken application from
-	freeing buffers that it didn't allocate, or buffers allocated
-	on another node.
-   
-   global_node_list -
-
-   	a list of all nodes allocated.  this allows the driver to free
-   	all the memory it has 'kmalloc'd in case of an error, or on
-   	module removal.
-
-   global_dma_list -
-
-        a list of all dma buffers allocated by this driver.  this
-	allows the driver to 'pci_free_consistent' all buffers on
-	module removal or error.
-
-*/
-
-
-struct node_data {
-	/* flat list of all the device nodes.  makes it easy to free
-	   them all when we're unregistered */
-	struct list_head global_node_list;
-	vertex_hdl_t devfs_handle;
-
-	void (* cleanup)(struct node_data *);
-
-	union {
-		struct {
-			struct pci_dev * dev;
-			struct list_head dma_allocs;
-			boolean mmapped;
-		} dma;
-		struct {
-			struct pci_dev * dev;
-			u32 saved_rom_base_reg;
-			boolean mmapped;
-		} rom;
-		struct {
-			struct resource * res;
-		} base;
-		struct {
-			struct pci_dev * dev;
-		} config;
-	} u;
-};
-
-struct dma_allocation {
-	struct list_head list;
-
-	dma_addr_t handle;
-	void * va;
-	size_t size;
-};
-
-
-static LIST_HEAD(global_node_list);
-static LIST_HEAD(global_dma_list);
-
-
-/* module entry points */
-int __init pciba_init(void);
-void __exit pciba_exit(void);
-
-static status __init register_with_devfs(void);
-static void __exit unregister_with_devfs(void);
-
-static status __init register_pci_device(vertex_hdl_t device_dir_handle,
-					 struct pci_dev * dev);
-
-/* file operations */
-static int generic_open(struct inode * inode, struct file * file);
-static int rom_mmap(struct file * file, struct vm_area_struct * vma);
-static int rom_release(struct inode * inode, struct file * file);
-static int base_mmap(struct file * file, struct vm_area_struct * vma);
-static int config_ioctl(struct inode * inode, struct file * file, 
-			unsigned int cmd, 
-			unsigned long arg);
-static int dma_ioctl(struct inode * inode, struct file * file, 
-		     unsigned int cmd, 
-		     unsigned long arg);
-static int dma_mmap(struct file * file, struct vm_area_struct * vma);
-
-/* support routines */
-static int mmap_pci_address(struct vm_area_struct * vma, unsigned long pci_va);
-static int mmap_kernel_address(struct vm_area_struct * vma, void * kernel_va);
-
-#ifdef DEBUG_PCIBA
-static void dump_nodes(struct list_head * nodes);
-static void dump_allocations(struct list_head * dalp);
-#endif
-
-/* file operations for each type of node */
-static struct file_operations rom_fops = {
-	owner:		THIS_MODULE,
-	mmap:		rom_mmap,
-	open:		generic_open,
-	release:	rom_release
-};
- 
-
-static struct file_operations base_fops = {
-	owner:		THIS_MODULE,
-	mmap:		base_mmap,
-	open:		generic_open
-};
-
-
-static struct file_operations config_fops = {
-	owner:		THIS_MODULE,
-	ioctl:		config_ioctl,
-	open:		generic_open
-};	
-
-static struct file_operations dma_fops = {
-	owner:		THIS_MODULE,
-	ioctl:		dma_ioctl,
-	mmap:		dma_mmap,
-	open:		generic_open
-};	
-
-
-module_init(pciba_init);
-module_exit(pciba_exit);
-
-
-int __init
-pciba_init(void)
-{
-	TRACE();
-
-	if (register_with_devfs() = failure)
-		return 1; /* failure */
-
-	printk("PCIBA (a user mode PCI interface) initialized.\n");
-
-	return 0; /* success */
-}
-
-
-void __exit
-pciba_exit(void)
-{
-	TRACE();
-
-	/* FIXME: should also free all that memory that we allocated
-           ;) */
-	unregister_with_devfs();
-}
-
-
-# if 0
-static void __exit
-free_nodes(void)
-{
-	struct node_data * nd;
-	
-	TRACE();
-
-	list_for_each(nd, &node_list) {
-		kfree(list_entry(nd, struct nd, node_list));
-	}
-}
-#endif
-
-
-static vertex_hdl_t pciba_devfs_handle;
-
-
-extern vertex_hdl_t
-devfn_to_vertex(unsigned char busnum, unsigned int devfn);
-
-static status __init
-register_with_devfs(void)
-{
-	struct pci_dev * dev;
-	vertex_hdl_t device_dir_handle;
-
-	TRACE();
-
-	/* FIXME: don't forget /dev/.../pci/mem & /dev/.../pci/io */
-
-	pci_for_each_dev(dev) {
-		device_dir_handle = devfn_to_vertex(dev->bus->number,
-						    dev->devfn);
-		if (device_dir_handle = NULL)
-			return failure;
-	
-		if (register_pci_device(device_dir_handle, dev) = failure) {
-			hwgraph_vertex_destroy(pciba_devfs_handle);
-			return failure;
-		}
-	}
-
-	return success;
-}
-
-static void __exit
-unregister_with_devfs(void)
-{
-	struct list_head * lhp;
-	struct node_data * nd;
-	
-	TRACE();
-
-	list_for_each(lhp, &global_node_list) {
-		nd = list_entry(lhp, struct node_data, global_node_list);
-		hwgraph_vertex_destroy(nd->devfs_handle);
-	}
-
-}
-
-
-struct node_data * new_node(void)
-{
-	struct node_data * node;
-	
-	TRACE();
-	
-	node = kmalloc(sizeof(struct node_data), GFP_KERNEL);
-	if (node = NULL)
-		return NULL;
-	list_add(&node->global_node_list, &global_node_list);
-	return node;
-}
-
-
-void dma_cleanup(struct node_data * dma_node)
-{
-	TRACE();
-
-	/* FIXME: should free these allocations */
-#ifdef DEBUG_PCIBA
-	dump_allocations(&dma_node->u.dma.dma_allocs);
-#endif
-	hwgraph_vertex_destroy(dma_node->devfs_handle);
-}
-
-
-void init_dma_node(struct node_data * node,
-		   struct pci_dev * dev, vertex_hdl_t dh)
-{
-	TRACE();
-
-	node->devfs_handle = dh;
-	node->u.dma.dev = dev;
-	node->cleanup = dma_cleanup;
-	INIT_LIST_HEAD(&node->u.dma.dma_allocs);
-}
-
-
-void rom_cleanup(struct node_data * rom_node)
-{
-	TRACE();
-
-	if (rom_node->u.rom.mmapped)
-		pci_write_config_dword(rom_node->u.rom.dev,
-				       PCI_ROM_ADDRESS,
-				       rom_node->u.rom.saved_rom_base_reg);
-	hwgraph_vertex_destroy(rom_node->devfs_handle);
-}
-
-
-void init_rom_node(struct node_data * node,
-		   struct pci_dev * dev, vertex_hdl_t dh)
-{
-	TRACE();
-
-	node->devfs_handle = dh;
-	node->u.rom.dev = dev;
-	node->cleanup = rom_cleanup;
-	node->u.rom.mmapped = false;
-}
-
-
-static status __init
-register_pci_device(vertex_hdl_t device_dir_handle, struct pci_dev * dev)
-{
-	struct node_data * nd;
-	char devfs_path[20];
-	vertex_hdl_t node_devfs_handle;
-	int ri;
-
-	TRACE();
-
-
-	/* register nodes for all the device's base address registers */
-	for (ri = 0; ri < PCI_ROM_RESOURCE; ri++) {
-		if (pci_resource_len(dev, ri) != 0) {
-			sprintf(devfs_path, "base/%d", ri);
-			if (hwgraph_register(device_dir_handle, devfs_path,
-					   0, DEVFS_FL_NONE,
-					   0, 0,
-					   S_IFCHR | S_IRUSR | S_IWUSR, 0, 0,
-					   &base_fops, 
-					   &dev->resource[ri]) = NULL)
-				return failure;
-		}
-	}
-	
-	/* register a node corresponding to the first MEM resource on
-           the device */
-	for (ri = 0; ri < PCI_ROM_RESOURCE; ri++) {
-		if (dev->resource[ri].flags & IORESOURCE_MEM &&
-		    pci_resource_len(dev, ri) != 0) {
-			if (hwgraph_register(device_dir_handle, "mem",
-					   0, DEVFS_FL_NONE, 0, 0,
-					   S_IFCHR | S_IRUSR | S_IWUSR, 0, 0,
-					   &base_fops, 
-					   &dev->resource[ri]) = NULL)
-				return failure;
-			break;
-		}
-	}
-
-	/* also register a node corresponding to the first IO resource
-           on the device */
-	for (ri = 0; ri < PCI_ROM_RESOURCE; ri++) {
-		if (dev->resource[ri].flags & IORESOURCE_IO &&
-		    pci_resource_len(dev, ri) != 0) {
-			if (hwgraph_register(device_dir_handle, "io",
-					   0, DEVFS_FL_NONE, 0, 0,
-					   S_IFCHR | S_IRUSR | S_IWUSR, 0, 0,
-					   &base_fops, 
-					   &dev->resource[ri]) = NULL)
-				return failure;
-			break;
-		}
-	}
-
-	/* register a node corresponding to the device's ROM resource,
-           if present */
-	if (pci_resource_len(dev, PCI_ROM_RESOURCE) != 0) {
-		nd = new_node();
-		if (nd = NULL)
-			return failure;
-		node_devfs_handle = hwgraph_register(device_dir_handle, "rom",
-						   0, DEVFS_FL_NONE, 0, 0,
-						   S_IFCHR | S_IRUSR, 0, 0,
-						   &rom_fops, nd);
-		if (node_devfs_handle = NULL)
-			return failure;
-		init_rom_node(nd, dev, node_devfs_handle);
-	}
-
-	/* register a node that allows ioctl's to read and write to
-           the device's config space */
-	if (hwgraph_register(device_dir_handle, "config", 0, DEVFS_FL_NONE,
-			   0, 0, S_IFCHR | S_IRUSR | S_IWUSR, 0, 0,
-			   &config_fops, dev) = NULL)
-		return failure;
-
-
-	/* finally, register a node that allows ioctl's to allocate
-           and free DMA buffers, as well as memory map those
-           buffers. */
-	nd = new_node();
-	if (nd = NULL)
-		return failure;
-	node_devfs_handle -		hwgraph_register(device_dir_handle, "dma", 0, DEVFS_FL_NONE,
-			       0, 0, S_IFCHR | S_IRUSR | S_IWUSR, 0, 0,
-			       &dma_fops, nd);
-	if (node_devfs_handle = NULL)
-		return failure;
-	init_dma_node(nd, dev, node_devfs_handle);
-
-#ifdef DEBUG_PCIBA
-	dump_nodes(&global_node_list);
-#endif
-	
-	return success;
-}
-
-
-static int
-generic_open(struct inode * inode, struct file * file)
-{
-	TRACE();
-
-	/* FIXME: should check that they're not trying to open the ROM
-           writable */
-
-	return 0; /* success */
-}
-
-
-static int
-rom_mmap(struct file * file, struct vm_area_struct * vma)
-{
-	unsigned long pci_pa;
-	struct node_data * nd;
-
-	TRACE();
-
-#ifdef CONFIG_HWGFS_FS
-	nd = (struct node_data * )file->f_dentry->d_fsdata;
-#else
-	nd = (struct node_data * )file->private_data;
-#endif
-
-	pci_pa = pci_resource_start(nd->u.rom.dev, PCI_ROM_RESOURCE);
-
-	if (!nd->u.rom.mmapped) {
-		nd->u.rom.mmapped = true;
-		DPRINTF("Enabling ROM address decoder.\n");
-		DPRINTF(
-"rom_mmap: FIXME: some cards do not allow both ROM and memory addresses to\n"
-"rom_mmap: FIXME: be enabled simultaneously, as they share a decoder.\n");
-		pci_read_config_dword(nd->u.rom.dev, PCI_ROM_ADDRESS,
-				      &nd->u.rom.saved_rom_base_reg);
-		DPRINTF("ROM base address contains %x\n",
-			nd->u.rom.saved_rom_base_reg);
-		pci_write_config_dword(nd->u.rom.dev, PCI_ROM_ADDRESS,
-				       nd->u.rom.saved_rom_base_reg |
-				       PCI_ROM_ADDRESS_ENABLE);
-	}
-	
-	return mmap_pci_address(vma, pci_pa);
-}
-
-
-static int
-rom_release(struct inode * inode, struct file * file)
-{
-	struct node_data * nd;
-
-	TRACE();
-
-#ifdef CONFIG_HWGFS_FS
-	nd = (struct node_data * )file->f_dentry->d_fsdata;
-#else
-	nd = (struct node_data * )file->private_data;
-#endif
-
-	if (nd->u.rom.mmapped) {
-		nd->u.rom.mmapped = false;
-		DPRINTF("Disabling ROM address decoder.\n");
-		pci_write_config_dword(nd->u.rom.dev, PCI_ROM_ADDRESS,
-				       nd->u.rom.saved_rom_base_reg);
-	}
-	return 0; /* indicate success */
-}
-
-
-static int
-base_mmap(struct file * file, struct vm_area_struct * vma)
-{
-	struct resource * resource;
-
-	TRACE();
-
-#ifdef CONFIG_HWGFS_FS
-	resource = (struct resource *)file->f_dentry->d_fsdata;
-#else
-	resource = (struct resource *)file->private_data;
-#endif
-
-	return mmap_pci_address(vma, resource->start);
-}
-
-
-static int
-config_ioctl(struct inode * inode, struct file * file, 
-	     unsigned int cmd, 
-	     unsigned long arg)
-{
-	struct pci_dev * dev;
-
-	union cfg_data {
-		uint8_t byte;
-		uint16_t word;
-		uint32_t dword;
-	} read_data, write_data;
-
-	int dir, size, offset;
-
-	TRACE();
-
-	DPRINTF("cmd = %x (DIR = %x, TYPE = %x, NR = %x, SIZE = %x)\n", 
-		cmd, 
-		_IOC_DIR(cmd), _IOC_TYPE(cmd), _IOC_NR(cmd), _IOC_SIZE(cmd));
-	DPRINTF("arg = %lx\n", arg);
-
-#ifdef CONFIG_HWGFS_FS
-	dev = (struct pci_dev *)file->f_dentry->d_fsdata;
-#else
-	dev = (struct pci_dev *)file->private_data;
-#endif
-
-	/* PCIIOCCFG{RD,WR}: read and/or write PCI configuration
-	   space. If both, the read happens first (this becomes a swap
-	   operation, atomic with respect to other updates through
-	   this path).  */
-
-	dir = _IOC_DIR(cmd);
-
-#define do_swap(suffix, type)	 					\
-	do {								\
-		if (dir & _IOC_READ) {					\
-			pci_read_config_##suffix(dev, _IOC_NR(cmd), 	\
-						 &read_data.suffix);	\
-		}							\
-		if (dir & _IOC_WRITE) {					\
-			get_user(write_data.suffix, (type)arg);		\
-			pci_write_config_##suffix(dev, _IOC_NR(cmd), 	\
-						  write_data.suffix);	\
-		}							\
-		if (dir & _IOC_READ) {					\
-			put_user(read_data.suffix, (type)arg);		\
-		}							\
-	} while (0)
-
-	size = _IOC_SIZE(cmd);
-	offset = _IOC_NR(cmd);
-
-	DPRINTF("sanity check\n");
-	if (((size > 0) || (size <= 4)) &&
-	    ((offset + size) <= 256) &&
-	    (dir & (_IOC_READ | _IOC_WRITE))) {
-
-		switch (size)
-		{
-		case 1:
-			do_swap(byte, uint8_t *);
-			break;
-		case 2:
-			do_swap(word, uint16_t *);
-			break;
-		case 4:
-			do_swap(dword, uint32_t *);
-			break;
-		default:
-			DPRINTF("invalid ioctl\n");
-			return -EINVAL;
-		}
-	} else
-		return -EINVAL;
-		
-	return 0;
-}
-
-
-#ifdef DEBUG_PCIBA
-static void
-dump_allocations(struct list_head * dalp)
-{
-	struct dma_allocation * dap;
-	struct list_head * p;
-	
-	printk("{\n");
-	list_for_each(p, dalp) {
-		dap = list_entry(p, struct dma_allocation, 
-				 list);
-		printk("  handle = %lx, va = %p\n",
-		       dap->handle, dap->va);
-	}
-	printk("}\n");
-}
-
-static void
-dump_nodes(struct list_head * nodes)
-{
-	struct node_data * ndp;
-	struct list_head * p;
-	
-	printk("{\n");
-	list_for_each(p, nodes) {
-		ndp = list_entry(p, struct node_data, 
-				 global_node_list);
-		printk("  %p\n", (void *)ndp);
-	}
-	printk("}\n");
-}
-
-
-#if 0
-#define NEW(ptr) (ptr = kmalloc(sizeof (*(ptr)), GFP_KERNEL))
-
-static void
-test_list(void)
-{
-	u64 i;
-	LIST_HEAD(the_list);
-
-	for (i = 0; i < 5; i++) {
-		struct dma_allocation * new_alloc;
-		NEW(new_alloc);
-		new_alloc->va = (void *)i;
-		new_alloc->handle = 5*i;
-		printk("%d - the_list->next = %lx\n", i, the_list.next);
-		list_add(&new_alloc->list, &the_list);
-	}
-	dump_allocations(&the_list);
-}
-#endif
-#endif
-
-
-static LIST_HEAD(dma_buffer_list);
-
-
-static int
-dma_ioctl(struct inode * inode, struct file * file, 
-	  unsigned int cmd, 
-	  unsigned long arg)
-{
-	struct node_data * nd;
-	uint64_t argv;
-	int result;
-	struct dma_allocation * dma_alloc;
-	struct list_head * iterp;
-
-	TRACE();
-
-	DPRINTF("cmd = %x\n", cmd);
-	DPRINTF("arg = %lx\n", arg);
-
-#ifdef CONFIG_HWGFS_FS
-	nd = (struct node_data *)file->f_dentry->d_fsdata;
-#else
-	nd = (struct node_data *)file->private_data;
-#endif
-
-#ifdef DEBUG_PCIBA
-	DPRINTF("at dma_ioctl entry\n");
-	dump_allocations(&nd->u.dma.dma_allocs);
-#endif
-
-	switch (cmd) {
-	case PCIIOCDMAALLOC:
-		/* PCIIOCDMAALLOC: allocate a chunk of physical memory
-		   and set it up for DMA. Return the PCI address that
-		   gets to it.  */
-		DPRINTF("case PCIIOCDMAALLOC (%lx)\n", PCIIOCDMAALLOC);
-		
-		if ( (result = get_user(argv, (uint64_t *)arg)) )
-			return result;
-		DPRINTF("argv (size of buffer) = %lx\n", argv);
-
-		dma_alloc = (struct dma_allocation *)
-			kmalloc(sizeof(struct dma_allocation), GFP_KERNEL);
-		if (dma_alloc = NULL)
-			return -ENOMEM;
-
-		dma_alloc->size = (size_t)argv;
-		dma_alloc->va = pci_alloc_consistent(nd->u.dma.dev,
-						     dma_alloc->size,
-						     &dma_alloc->handle);
-		DPRINTF("dma_alloc->va = %p, dma_alloc->handle = %lx\n",
-			dma_alloc->va, dma_alloc->handle);
-		if (dma_alloc->va = NULL) {
-			kfree(dma_alloc);
-			return -ENOMEM;
-		}
-
-		list_add(&dma_alloc->list, &nd->u.dma.dma_allocs);
-		if ( (result = put_user((uint64_t)dma_alloc->handle, 
-				      (uint64_t *)arg)) ) {
-			DPRINTF("put_user failed\n");
-			pci_free_consistent(nd->u.dma.dev, (size_t)argv,
-					    dma_alloc->va, dma_alloc->handle);
-			kfree(dma_alloc);
-			return result;
-		}
-
-#ifdef DEBUG_PCIBA
-		DPRINTF("after insertion\n");
-		dump_allocations(&nd->u.dma.dma_allocs);
-#endif
-		break;
-
-	case PCIIOCDMAFREE:
-		DPRINTF("case PCIIOCDMAFREE (%lx)\n", PCIIOCDMAFREE);
-
-		if ( (result = get_user(argv, (uint64_t *)arg)) ) {
-			DPRINTF("get_user failed\n");
-			return result;
-		}
-
-		DPRINTF("argv (physical address of DMA buffer) = %lx\n", argv);
-		list_for_each(iterp, &nd->u.dma.dma_allocs) {
-			struct dma_allocation * da -				list_entry(iterp, struct dma_allocation, list);
-			if (da->handle = argv) {
-				pci_free_consistent(nd->u.dma.dev, da->size,
-						    da->va, da->handle);
-				list_del(&da->list);
-				kfree(da);
-#ifdef DEBUG_PCIBA
-				DPRINTF("after deletion\n");
-				dump_allocations(&nd->u.dma.dma_allocs);
-#endif
-				return 0; /* success */
-			}
-		}
-		/* previously allocated dma buffer wasn't found */
-		DPRINTF("attempt to free invalid dma handle\n");
-		return -EINVAL;
-
-	default:
-		DPRINTF("undefined ioctl\n");
-		return -EINVAL;
-	}
-
-	DPRINTF("success\n");
-	return 0;
-}
-		
-
-static int
-dma_mmap(struct file * file, struct vm_area_struct * vma)
-{
-	struct node_data * nd;
-	struct list_head * iterp;
-	int result;
-	
-	TRACE();
-
-#ifdef CONFIG_HWGFS_FS
-	nd = (struct node_data *)file->f_dentry->d_fsdata;
-#else
-	nd = (struct node_data *)file->private_data;
-#endif
-	
-	DPRINTF("vma->vm_start is %lx\n", vma->vm_start);
-	DPRINTF("vma->vm_end is %lx\n", vma->vm_end);
-	DPRINTF("offset = %lx\n", vma->vm_pgoff);
-
-	/* get kernel virtual address for the dma buffer (necessary
-	 * for the mmap). */
-	list_for_each(iterp, &nd->u.dma.dma_allocs) {
-		struct dma_allocation * da -			list_entry(iterp, struct dma_allocation, list);
-		/* why does mmap shift its offset argument? */
-		if (da->handle = vma->vm_pgoff << PAGE_SHIFT) {
-			DPRINTF("found dma handle\n");
-			if ( (result = mmap_kernel_address(vma,
-							   da->va)) ) {
-				return result; /* failure */
-			} else {
-				/* it seems like at least one of these
-				   should show up in user land....
-				   I'm missing something */
-				*(char *)da->va = 0xaa;
-				strncpy(da->va, "        Toastie!", da->size);
-				if (put_user(0x18badbeeful,
-					     (u64 *)vma->vm_start))
-					DPRINTF("put_user failed?!\n");
-				return 0; /* success */
-			}
-
-		}
-	}
-	DPRINTF("attempt to mmap an invalid dma handle\n");
-	return -EINVAL;
-}
-
-
-static int
-mmap_pci_address(struct vm_area_struct * vma, unsigned long pci_va)
-{
-	unsigned long pci_pa;
-
-	TRACE();
-
-	DPRINTF("vma->vm_start is %lx\n", vma->vm_start);
-	DPRINTF("vma->vm_end is %lx\n", vma->vm_end);
-
-	/* the size of the vma doesn't necessarily correspond to the
-           size specified in the mmap call.  So we can't really do any
-           kind of sanity check here.  This is a dangerous driver, and
-           it's very easy for a user process to kill the machine.  */
-
-	DPRINTF("PCI base at virtual address %lx\n", pci_va);
-	/* the __pa macro is intended for region 7 on IA64, so it
-	   doesn't work for region 6 */
-  	/* pci_pa = __pa(pci_va); */
-	/* should be replaced by __tpa or equivalent (preferably a
-	   generic equivalent) */
-	pci_pa = pci_va & ~0xe000000000000000ul;
-	DPRINTF("PCI base at physical address %lx\n", pci_pa);
-
-	/* there are various arch-specific versions of this function
-           defined in linux/drivers/char/mem.c, but it would be nice
-           if all architectures put it in pgtable.h.  it's defined
-           there for ia64.... */
-	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-
-	vma->vm_flags |= VM_NONCACHED | VM_RESERVED | VM_IO;
-
-	return io_remap_page_range(vma->vm_start, pci_pa, 
-				   vma->vm_end-vma->vm_start,
-				   vma->vm_page_prot);
-}
-
-
-static int
-mmap_kernel_address(struct vm_area_struct * vma, void * kernel_va)
-{
-	unsigned long kernel_pa;
-
-	TRACE();
-
-	DPRINTF("vma->vm_start is %lx\n", vma->vm_start);
-	DPRINTF("vma->vm_end is %lx\n", vma->vm_end);
-
-	/* the size of the vma doesn't necessarily correspond to the
-           size specified in the mmap call.  So we can't really do any
-           kind of sanity check here.  This is a dangerous driver, and
-           it's very easy for a user process to kill the machine.  */
-
-	DPRINTF("mapping virtual address %p\n", kernel_va);
-	kernel_pa = __pa(kernel_va);
-	DPRINTF("mapping physical address %lx\n", kernel_pa);
-
-	vma->vm_flags |= VM_NONCACHED | VM_RESERVED | VM_IO;
-
-	return remap_page_range(vma->vm_start, kernel_pa, 
-				vma->vm_end-vma->vm_start,
-				vma->vm_page_prot);
-}	
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/machvec/pci.c linux-2.5.69-ia64-sn/arch/ia64/sn/io/machvec/pci.c
--- linux-2.5.69-ia64/arch/ia64/sn/io/machvec/pci.c	Fri May 23 10:12:05 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/machvec/pci.c	Fri May 23 10:54:40 2003
@@ -43,189 +43,33 @@
 extern vertex_hdl_t pci_bus_to_vertex(unsigned char);
 extern vertex_hdl_t devfn_to_vertex(unsigned char bus, unsigned char devfn);
 
-/*
- * snia64_read_config_byte - Read a byte from the config area of the device.
- */
-static int snia64_read_config_byte (struct pci_dev *dev,
-                                   int where, unsigned char *val)
-{
-	unsigned long res = 0;
-	unsigned size = 1;
-	vertex_hdl_t device_vertex;
-
-	if ( (dev = (struct pci_dev *)0) || (val = (unsigned char *)0) ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	res = pciio_config_get(device_vertex, (unsigned) where, size);
-	*val = (unsigned char) res;
-	return PCIBIOS_SUCCESSFUL;
-}
-
-/*
- * snia64_read_config_word - Read 2 bytes from the config area of the device.
- */
-static int snia64_read_config_word (struct pci_dev *dev,
-                                   int where, unsigned short *val)
+int sn_read_config(struct pci_bus *bus, unsigned int devfn, int where, int size, u32 *val)
 {
 	unsigned long res = 0;
-	unsigned size = 2; /* 2 bytes */
 	vertex_hdl_t device_vertex;
 
-	if ( (dev = (struct pci_dev *)0) || (val = (unsigned short *)0) ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	res = pciio_config_get(device_vertex, (unsigned) where, size);
-	*val = (unsigned short) res;
-	return PCIBIOS_SUCCESSFUL;
-}
-
-/*
- * snia64_read_config_dword - Read 4 bytes from the config area of the device.
- */
-static int snia64_read_config_dword (struct pci_dev *dev,
-                                    int where, unsigned int *val)
-{
-	unsigned long res = 0;
-	unsigned size = 4; /* 4 bytes */
-	vertex_hdl_t device_vertex;
-
-	if (where & 3) {
-		return PCIBIOS_BAD_REGISTER_NUMBER;
-	}
-	if ( (dev = (struct pci_dev *)0) || (val = (unsigned int *)0) ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
+	device_vertex = devfn_to_vertex(bus->number, devfn);
 	res = pciio_config_get(device_vertex, (unsigned) where, size);
 	*val = (unsigned int) res;
 	return PCIBIOS_SUCCESSFUL;
 }
 
-/*
- * snia64_write_config_byte - Writes 1 byte to the config area of the device.
- */
-static int snia64_write_config_byte (struct pci_dev *dev,
-                                    int where, unsigned char val)
-{
-	vertex_hdl_t device_vertex;
-
-	if ( dev = (struct pci_dev *)0 ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-	/* 
-	 * if it's an IOC3 then we bail out, we special
-	 * case them with pci_fixup_ioc3
-	 */
-	if (dev->vendor = PCI_VENDOR_ID_SGI && 
-	    dev->device = PCI_DEVICE_ID_SGI_IOC3 )
-		return PCIBIOS_SUCCESSFUL;
-
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	pciio_config_set( device_vertex, (unsigned)where, 1, (uint64_t) val);
-
-	return PCIBIOS_SUCCESSFUL;
-}
-
-/*
- * snia64_write_config_word - Writes 2 bytes to the config area of the device.
- */
-static int snia64_write_config_word (struct pci_dev *dev,
-                                    int where, unsigned short val)
-{
-	vertex_hdl_t device_vertex = NULL;
-
-	if (where & 1) {
-		return PCIBIOS_BAD_REGISTER_NUMBER;
-	}
-	if ( dev = (struct pci_dev *)0 ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-	/* 
-	 * if it's an IOC3 then we bail out, we special
-	 * case them with pci_fixup_ioc3
-	 */
-	if (dev->vendor = PCI_VENDOR_ID_SGI && 
-	    dev->device = PCI_DEVICE_ID_SGI_IOC3)
-		return PCIBIOS_SUCCESSFUL;
-
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	pciio_config_set( device_vertex, (unsigned)where, 2, (uint64_t) val);
-
-	return PCIBIOS_SUCCESSFUL;
-}
-
-/*
- * snia64_write_config_dword - Writes 4 bytes to the config area of the device.
- */
-static int snia64_write_config_dword (struct pci_dev *dev,
-                                     int where, unsigned int val)
+int sn_write_config(struct pci_bus *bus, unsigned int devfn, int where, int size, u32 val)
 {
 	vertex_hdl_t device_vertex;
 
-	if (where & 3) {
-		return PCIBIOS_BAD_REGISTER_NUMBER;
-	}
-	if ( dev = (struct pci_dev *)0 ) {
-		return PCIBIOS_DEVICE_NOT_FOUND;
-	}
-	/* 
-	 * if it's an IOC3 then we bail out, we special
-	 * case them with pci_fixup_ioc3
-	 */
-	if (dev->vendor = PCI_VENDOR_ID_SGI && 
-	    dev->device = PCI_DEVICE_ID_SGI_IOC3)
-		return PCIBIOS_SUCCESSFUL;
-
-	device_vertex = devfn_to_vertex(dev->bus->number, dev->devfn);
-	if (!device_vertex) {
-		DBG("%s : nonexistent device: bus= 0x%x  slot= 0x%x  func= 0x%x\n", 
-		__FUNCTION__, dev->bus->number, PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-		return(-1);
-	}
-	pciio_config_set( device_vertex, (unsigned)where, 4, (uint64_t) val);
-
+	device_vertex = devfn_to_vertex(bus->number, devfn);
+	pciio_config_set( device_vertex, (unsigned)where, size, (uint64_t) val);
 	return PCIBIOS_SUCCESSFUL;
 }
 
-static struct pci_ops snia64_pci_ops = {
-	snia64_read_config_byte,
-	snia64_read_config_word,
-	snia64_read_config_dword,
-	snia64_write_config_byte,
-	snia64_write_config_word,
-	snia64_write_config_dword
+struct pci_ops sn_pci_ops = {
+	.read = sn_read_config,
+	.write = sn_write_config
 };
 
 /*
- * snia64_pci_find_bios - SNIA64 pci_find_bios() platform specific code.
+ * sn_pci_find_bios - SNIA64 pci_find_bios() platform specific code.
  */
 void __init
 sn_pci_find_bios(void)
@@ -239,7 +83,7 @@
 	sgi_master_io_infr_init();
 
 	/* sn_io_infrastructure_init(); */
-	pci_root_ops = &snia64_pci_ops;
+	pci_root_ops = &sn_pci_ops;
 }
 
 void
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/machvec/pci_dma.c linux-2.5.69-ia64-sn/arch/ia64/sn/io/machvec/pci_dma.c
--- linux-2.5.69-ia64/arch/ia64/sn/io/machvec/pci_dma.c	Fri May 23 10:12:05 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/machvec/pci_dma.c	Fri May 23 10:52:29 2003
@@ -566,6 +566,134 @@
 	return 1;
 }
 
+#ifdef CONFIG_PCI
+
+/*
+ * New generic DMA routines just wrap sn2 PCI routines until we
+ * support other bus types (if ever).
+ */
+
+int
+sn_dma_supported(struct device *dev, u64 mask)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	return pci_dma_supported(to_pci_dev(dev), mask);
+}
+EXPORT_SYMBOL(sn_dma_supported);
+
+int
+sn_dma_set_mask(struct device *dev, u64 dma_mask)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	return pci_set_dma_mask(to_pci_dev(dev), dma_mask);
+}
+EXPORT_SYMBOL(sn_dma_set_mask);
+
+void *
+sn_dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		   int flag)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	return pci_alloc_consistent(to_pci_dev(dev), size, dma_handle);
+}
+EXPORT_SYMBOL(sn_dma_alloc_coherent);
+
+void
+sn_dma_free_coherent(struct device *dev, size_t size, void *cpu_addr,
+		    dma_addr_t dma_handle)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	pci_free_consistent(to_pci_dev(dev), size, cpu_addr, dma_handle);
+}
+EXPORT_SYMBOL(sn_dma_free_coherent);
+
+dma_addr_t
+sn_dma_map_single(struct device *dev, void *cpu_addr, size_t size,
+	       int direction)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	return pci_map_single(to_pci_dev(dev), cpu_addr, size, (int)direction);
+}
+EXPORT_SYMBOL(sn_dma_map_single);
+
+void
+sn_dma_unmap_single(struct device *dev, dma_addr_t dma_addr, size_t size,
+		 int direction)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	pci_unmap_single(to_pci_dev(dev), dma_addr, size, (int)direction);
+}
+EXPORT_SYMBOL(sn_dma_unmap_single);
+
+dma_addr_t
+sn_dma_map_page(struct device *dev, struct page *page,
+	     unsigned long offset, size_t size,
+	     int direction)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	return pci_map_page(to_pci_dev(dev), page, offset, size, (int)direction);
+}
+EXPORT_SYMBOL(sn_dma_map_page);
+
+void
+sn_dma_unmap_page(struct device *dev, dma_addr_t dma_address, size_t size,
+	       int direction)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	pci_unmap_page(to_pci_dev(dev), dma_address, size, (int)direction);
+}
+EXPORT_SYMBOL(sn_dma_unmap_page);
+
+int
+sn_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
+	   int direction)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	return pci_map_sg(to_pci_dev(dev), sg, nents, (int)direction);
+}
+EXPORT_SYMBOL(sn_dma_map_sg);
+
+void
+sn_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nhwentries,
+	     int direction)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	pci_unmap_sg(to_pci_dev(dev), sg, nhwentries, (int)direction);
+}
+EXPORT_SYMBOL(sn_dma_unmap_sg);
+
+void
+sn_dma_sync_single(struct device *dev, dma_addr_t dma_handle, size_t size,
+		int direction)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	pci_dma_sync_single(to_pci_dev(dev), dma_handle, size, (int)direction);
+}
+EXPORT_SYMBOL(sn_dma_sync_single);
+
+void
+sn_dma_sync_sg(struct device *dev, struct scatterlist *sg, int nelems,
+	    int direction)
+{
+	BUG_ON(dev->bus != &pci_bus_type);
+
+	pci_dma_sync_sg(to_pci_dev(dev), sg, nelems, (int)direction);
+}
+EXPORT_SYMBOL(sn_dma_sync_sg);
+
+#endif /* CONFIG_PCI */
+
 EXPORT_SYMBOL(sn_pci_unmap_single);
 EXPORT_SYMBOL(sn_pci_map_single);
 EXPORT_SYMBOL(sn_pci_dma_sync_single);
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/platform_init/irix_io_init.c linux-2.5.69-ia64-sn/arch/ia64/sn/io/platform_init/irix_io_init.c
--- linux-2.5.69-ia64/arch/ia64/sn/io/platform_init/irix_io_init.c	Fri May 23 10:12:05 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/platform_init/irix_io_init.c	Fri May 23 10:37:31 2003
@@ -15,7 +15,6 @@
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/klconfig.h>
 #include <asm/sn/sn_private.h>
-#include <asm/sn/pci/pciba.h>
 #include <linux/smp.h>
 #include <asm/sn/simulator.h>
 
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/sn2/pcibr/Makefile linux-2.5.69-ia64-sn/arch/ia64/sn/io/sn2/pcibr/Makefile
--- linux-2.5.69-ia64/arch/ia64/sn/io/sn2/pcibr/Makefile	Fri May 23 10:12:06 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/sn2/pcibr/Makefile	Fri May 23 10:37:14 2003
@@ -9,7 +9,7 @@
 # Makefile for the sn2 specific pci bridge routines.
 #
 
-EXTRA_CFLAGS    := -DLITTLE_ENDIAN -DSHUB_SWAP_WAR
+EXTRA_CFLAGS    := -DLITTLE_ENDIAN
 
 obj-y += pcibr_ate.o pcibr_config.o pcibr_dvr.o pcibr_hints.o pcibr_intr.o pcibr_rrb.o \
 	 pcibr_slot.o pcibr_error.o
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c linux-2.5.69-ia64-sn/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c
--- linux-2.5.69-ia64/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Fri May 23 10:12:07 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Fri May 23 10:37:38 2003
@@ -77,8 +77,6 @@
 #define USS302_BRIDGE_TIMEOUT_HLD	4
 #endif
 
-int                     pcibr_devflag = D_MP;
-
 /* kbrick widgetnum-to-bus layout */
 int p_busnum[MAX_PORT_NUM] = {                  /* widget#      */
         0, 0, 0, 0, 0, 0, 0, 0,                 /* 0x0 - 0x7    */
@@ -148,10 +146,6 @@
 int			 pcibr_attach2(vertex_hdl_t, bridge_t *, vertex_hdl_t,
 				       int, pcibr_soft_t *);
 int			 pcibr_detach(vertex_hdl_t);
-int                      pcibr_close(vertex_hdl_t, int, int, cred_t *);
-int                      pcibr_map(vertex_hdl_t, vhandl_t *, off_t, size_t, uint);
-int                      pcibr_unmap(vertex_hdl_t, vhandl_t *);
-int                      pcibr_ioctl(vertex_hdl_t, int, void *, int, struct cred *, int *);
 int			 pcibr_pcix_rbars_calc(pcibr_soft_t);
 extern int               pcibr_init_ext_ate_ram(bridge_t *);
 extern int               pcibr_ate_alloc(pcibr_soft_t, int);
@@ -270,34 +264,6 @@
 extern int		pcibr_slot_initial_rrb_alloc(vertex_hdl_t, pciio_slot_t);
 extern int		pcibr_initial_rrb(vertex_hdl_t, pciio_slot_t, pciio_slot_t);
 
-/*
- * This is the file operation table for the pcibr driver.
- * As each of the functions are implemented, put the
- * appropriate function name below.
- */
-static int pcibr_mmap(struct file * file, struct vm_area_struct * vma);
-static int pcibr_open(struct inode *, struct file *);
-struct file_operations pcibr_fops = {
-        owner:  THIS_MODULE,
-        llseek: NULL,
-        read: NULL,
-        write: NULL,
-        readdir: NULL,
-        poll: NULL,
-        ioctl: NULL,
-        mmap: pcibr_mmap,
-        open: pcibr_open,
-        flush: NULL,
-        release: NULL,
-        fsync: NULL,
-        fasync: NULL,
-        lock: NULL,
-        readv: NULL,
-        writev: NULL,
-	sendpage: NULL,
-	get_unmapped_area: NULL
-};
-
 /* ==================================  *    Device(x) register management
  */
@@ -622,44 +588,15 @@
  */
 
 
-/*
- * open/close mmap/munmap interface would be used by processes
- * that plan to map the PCI bridge, and muck around with the
- * registers. This is dangerous to do, and will be allowed
- * to a select brand of programs. Typically these are
- * diagnostics programs, or some user level commands we may
- * write to do some weird things.
- * To start with expect them to have root priveleges.
- * We will ask for more later.
- */
-/* ARGSUSED */
-int
-pcibr_open(struct inode *x, struct file *y)
-{
-    return 0;
-}
-
-/*ARGSUSED */
-int
-pcibr_close(vertex_hdl_t dev, int oflag, int otyp, cred_t *crp)
-{
-    return 0;
-}
-
 static int
 pcibr_mmap(struct file * file, struct vm_area_struct * vma)
 {
-	vertex_hdl_t		pcibr_vhdl;
+	vertex_hdl_t		pcibr_vhdl = file->f_dentry->d_fsdata;
 	pcibr_soft_t            pcibr_soft;
 	bridge_t               *bridge;
 	unsigned long		phys_addr;
 	int			error = 0;
 
-#ifdef CONFIG_HWGFS_FS
-	pcibr_vhdl = (vertex_hdl_t) file->f_dentry->d_fsdata;
-#else
-	pcibr_vhdl = (vertex_hdl_t) file->private_data;
-#endif
 	pcibr_soft = pcibr_soft_get(pcibr_vhdl);
 	bridge = pcibr_soft->bs_base;
 	phys_addr = (unsigned long)bridge & ~0xc000000000000000; /* Mask out the Uncache bits */
@@ -671,114 +608,17 @@
 	return(error);
 }
 
-/*ARGSUSED */
-int
-pcibr_map(vertex_hdl_t dev, vhandl_t *vt, off_t off, size_t len, uint prot)
-{
-    int                     error;
-    vertex_hdl_t            vhdl = dev_to_vhdl(dev);
-    vertex_hdl_t            pcibr_vhdl = hwgraph_connectpt_get(vhdl);
-    pcibr_soft_t            pcibr_soft = pcibr_soft_get(pcibr_vhdl);
-    bridge_t               *bridge = pcibr_soft->bs_base;
-
-    hwgraph_vertex_unref(pcibr_vhdl);
-
-    ASSERT(pcibr_soft);
-    len = ctob(btoc(len));		/* Make len page aligned */
-    error = v_mapphys(vt, (void *) ((__psunsigned_t) bridge + off), len);
-
-    /*
-     * If the offset being mapped corresponds to the flash prom
-     * base, and if the mapping succeeds, and if the user
-     * has requested the protections to be WRITE, enable the
-     * flash prom to be written.
-     *
-     * XXX- deprecate this in favor of using the
-     * real flash driver ...
-     */
-    if (IS_BRIDGE_SOFT(pcibr_soft) && !error &&
-	((off = BRIDGE_EXTERNAL_FLASH) ||
-	 (len > BRIDGE_EXTERNAL_FLASH))) {
-	int                     s;
-
-	/*
-	 * ensure that we write and read without any interruption.
-	 * The read following the write is required for the Bridge war
-	 */
-	s = splhi();
-
-	if (io_get_sh_swapper(NASID_GET(bridge))) {
-		BRIDGE_REG_SET32((&bridge->b_wid_control)) |= __swab32(BRIDGE_CTRL_FLASH_WR_EN);
-		BRIDGE_REG_GET32((&bridge->b_wid_control));          /* inval addr bug war */
-	} else {
-		bridge->b_wid_control |= BRIDGE_CTRL_FLASH_WR_EN;
-		bridge->b_wid_control;          /* inval addr bug war */
-	}
-	splx(s);
-    }
-    return error;
-}
-
-/*ARGSUSED */
-int
-pcibr_unmap(vertex_hdl_t dev, vhandl_t *vt)
-{
-    vertex_hdl_t            pcibr_vhdl = hwgraph_connectpt_get((vertex_hdl_t) dev);
-    pcibr_soft_t            pcibr_soft = pcibr_soft_get(pcibr_vhdl);
-    bridge_t               *bridge = pcibr_soft->bs_base;
-
-    hwgraph_vertex_unref(pcibr_vhdl);
-
-    if ( IS_PIC_SOFT(pcibr_soft) ) {
-	/*
-	 * If flashprom write was enabled, disable it, as
-	 * this is the last unmap.
-	 */
-	if (IS_BRIDGE_SOFT(pcibr_soft) && 
-			(bridge->b_wid_control & BRIDGE_CTRL_FLASH_WR_EN)) {
-		int                     s;
-
-		/*
-		 * ensure that we write and read without any interruption.
-		 * The read following the write is required for the Bridge war
-		 */
-		s = splhi();
-		bridge->b_wid_control &= ~BRIDGE_CTRL_FLASH_WR_EN;
-		bridge->b_wid_control;		/* inval addr bug war */
-		splx(s);
-	}
-    }
-    else {
-	if (io_get_sh_swapper(NASID_GET(bridge))) {
-		if (BRIDGE_REG_GET32((&bridge->b_wid_control)) & BRIDGE_CTRL_FLASH_WR_EN) {
-			int                     s;
+/*
+ * This is the file operation table for the pcibr driver.
+ * As each of the functions are implemented, put the
+ * appropriate function name below.
+ */
+static int pcibr_mmap(struct file * file, struct vm_area_struct * vma);
+struct file_operations pcibr_fops = {
+	.owner		= THIS_MODULE,
+	.mmap		= pcibr_mmap,
+};
 
-			/*
-			 * ensure that we write and read without any interruption.
-			 * The read following the write is required for the Bridge war
-			 */
-			s = splhi();
-			BRIDGE_REG_SET32((&bridge->b_wid_control)) &= __swab32((unsigned int)~BRIDGE_CTRL_FLASH_WR_EN);
-			BRIDGE_REG_GET32((&bridge->b_wid_control));          /* inval addr bug war */
-			splx(s);
-		} else {
-			if (bridge->b_wid_control & BRIDGE_CTRL_FLASH_WR_EN) {
-				int                     s;
-
-				/*
-				 * ensure that we write and read without any interruption.
-				 * The read following the write is required for the Bridge war
-				 */
-				s = splhi();
-				bridge->b_wid_control &= ~BRIDGE_CTRL_FLASH_WR_EN;
-				bridge->b_wid_control;          /* inval addr bug war */
-				splx(s);
-    			}
-		}
-	}
-    }
-    return 0;
-}
 
 /* This is special case code used by grio. There are plans to make
  * this a bit more general in the future, but till then this should
@@ -812,18 +652,6 @@
     return slot;
 }
 
-/*ARGSUSED */
-int
-pcibr_ioctl(vertex_hdl_t dev,
-	    int cmd,
-	    void *arg,
-	    int flag,
-	    struct cred *cr,
-	    int *rvalp)
-{
-    return 0;
-}
-
 pcibr_info_t
 pcibr_info_get(vertex_hdl_t vhdl)
 {
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/sn2/pic.c linux-2.5.69-ia64-sn/arch/ia64/sn/io/sn2/pic.c
--- linux-2.5.69-ia64/arch/ia64/sn/io/sn2/pic.c	Fri May 23 10:12:07 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/sn2/pic.c	Fri May 23 10:37:38 2003
@@ -35,8 +35,6 @@
 
 #define PCI_BUS_NO_1 1
 
-int pic_devflag = D_MP;
-
 extern int pcibr_attach2(vertex_hdl_t, bridge_t *, vertex_hdl_t, int, pcibr_soft_t *);
 extern void pcibr_driver_reg_callback(vertex_hdl_t, int, int, int);
 extern void pcibr_driver_unreg_callback(vertex_hdl_t, int, int, int);
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/sn2/xbow.c linux-2.5.69-ia64-sn/arch/ia64/sn/io/sn2/xbow.c
--- linux-2.5.69-ia64/arch/ia64/sn/io/sn2/xbow.c	Fri May 23 10:12:08 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/sn2/xbow.c	Fri May 23 10:37:38 2003
@@ -45,8 +45,6 @@
 #define NEW(ptr)	(ptr = kmalloc(sizeof (*(ptr)), GFP_KERNEL))
 #define DEL(ptr)	(kfree(ptr))
 
-int                     xbow_devflag = D_MP;
-
 /*
  * This file supports the Xbow chip.  Main functions: initializtion,
  * error handling, and GBR.
@@ -92,14 +90,6 @@
 void                    xbow_mlreset(xbow_t *);
 int                     xbow_attach(vertex_hdl_t);
 
-static int              xbow_open(struct inode *, struct file *);
-
-int                     xbow_close(vertex_hdl_t, int, int, cred_t *);
-
-int                     xbow_map(vertex_hdl_t, vhandl_t *, off_t, size_t, uint);
-int                     xbow_unmap(vertex_hdl_t, vhandl_t *);
-int                     xbow_ioctl(vertex_hdl_t, int, void *, int, struct cred *, int *);
-
 int                     xbow_widget_present(xbow_t *, int);
 static int              xbow_link_alive(xbow_t *, int);
 vertex_hdl_t            xbow_widget_lookup(vertex_hdl_t, int);
@@ -127,32 +117,6 @@
     xbow_reset_link,
 };
 
-/*
- * This is the file operation table for the pcibr driver.
- * As each of the functions are implemented, put the
- * appropriate function name below.
- */
-static int xbow_mmap(struct file * file, struct vm_area_struct * vma);
-struct file_operations xbow_fops = {
-        owner:  THIS_MODULE,
-        llseek: NULL,
-        read: NULL,
-        write: NULL,
-        readdir: NULL,
-        poll: NULL,
-        ioctl: NULL,
-        mmap: xbow_mmap,
-        open: xbow_open,
-        flush: NULL,
-        release: NULL,
-        fsync: NULL,
-        fasync: NULL,
-        lock: NULL,
-        readv: NULL,
-        writev: NULL,
-        sendpage: NULL,
-        get_unmapped_area: NULL
-};
 
 static int
 xbow_mmap(struct file * file, struct vm_area_struct * vma)
@@ -169,6 +133,15 @@
         return(error);
 }
 
+/*
+ * This is the file operation table for the pcibr driver.
+ * As each of the functions are implemented, put the
+ * appropriate function name below.
+ */
+struct file_operations xbow_fops = {
+        .owner		= THIS_MODULE,
+        .mmap		= xbow_mmap,
+};
 
 /*
  *    xbow_mlreset: called at mlreset time if the
@@ -446,42 +419,6 @@
     return 0;				/* attach successful */
 }
 
-/*ARGSUSED */
-static int
-xbow_open(struct inode *xx, struct file *yy)
-{
-    return 0;
-}
-
-/*ARGSUSED */
-int
-xbow_close(vertex_hdl_t dev, int oflag, int otyp, cred_t *crp)
-{
-    return 0;
-}
-
-/*ARGSUSED */
-int
-xbow_map(vertex_hdl_t dev, vhandl_t *vt, off_t off, size_t len, uint prot)
-{
-    vertex_hdl_t            vhdl = dev_to_vhdl(dev);
-    xbow_soft_t             soft = xbow_soft_get(vhdl);
-    int                     error;
-
-    ASSERT(soft);
-    len = ctob(btoc(len));
-    /* XXX- this ignores the offset!!! */
-    error = v_mapphys(vt, (void *) soft->base, len);
-    return error;
-}
-
-/*ARGSUSED */
-int
-xbow_unmap(vertex_hdl_t dev, vhandl_t *vt)
-{
-    return 0;
-}
-
 /* This contains special-case code for grio. There are plans to make
  * this general sometime in the future, but till then this should
  * be good enough.
@@ -519,58 +456,6 @@
 	return XWIDGET_NONE;
 }
 
-int
-xbow_ioctl(vertex_hdl_t dev,
-	   int cmd,
-	   void *arg,
-	   int flag,
-	   struct cred *cr,
-	   int *rvalp)
-{
-    vertex_hdl_t            vhdl;
-    int                     error = 0;
-
-#if defined (DEBUG)
-    int                     rc;
-    vertex_hdl_t            conn;
-    struct xwidget_info_s  *xwidget_info;
-    xbow_soft_t             xbow_soft;
-#endif
-    *rvalp = 0;
-
-    vhdl = dev_to_vhdl(dev);
-#if defined (DEBUG)
-    xbow_soft = xbow_soft_get(vhdl);
-    conn = xbow_soft->conn;
-
-    xwidget_info = xwidget_info_get(conn);
-    ASSERT_ALWAYS(xwidget_info != NULL);
-
-    rc = xwidget_hwid_is_xswitch(&xwidget_info->w_hwid);
-    ASSERT_ALWAYS(rc != 0);
-#endif
-    switch (cmd) {
-
-    case XBOWIOC_LLP_ERROR_ENABLE:
-	if ((error = xbow_enable_llp_monitor(vhdl)) != 0)
-	    error = EINVAL;
-
-	break;
-
-    case XBOWIOC_LLP_ERROR_DISABLE:
-
-	if ((error = xbow_disable_llp_monitor(vhdl)) != 0)
-	    error = EINVAL;
-
-	break;
-
-    default:
-	break;
-
-    }
-    return error;
-}
-
 /*
  * xbow_widget_present: See if a device is present
  * on the specified port of this crossbow.
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/io/xswitch.c linux-2.5.69-ia64-sn/arch/ia64/sn/io/xswitch.c
--- linux-2.5.69-ia64/arch/ia64/sn/io/xswitch.c	Fri May 23 10:12:08 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/io/xswitch.c	Fri May 23 10:37:38 2003
@@ -23,8 +23,6 @@
 #define	NEW(ptr)	(ptr = kmalloc(sizeof (*(ptr)), GFP_KERNEL))
 #define	DEL(ptr)	(kfree(ptr))
 
-int                     xswitch_devflag = D_MP;
-
 /*
  * This file provides generic support for Crosstalk
  * Switches, in a way that insulates crosstalk providers
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/arch/ia64/sn/kernel/sn_ksyms.c linux-2.5.69-ia64-sn/arch/ia64/sn/kernel/sn_ksyms.c
--- linux-2.5.69-ia64/arch/ia64/sn/kernel/sn_ksyms.c	Fri May 23 10:12:10 2003
+++ linux-2.5.69-ia64-sn/arch/ia64/sn/kernel/sn_ksyms.c	Fri May 23 10:37:31 2003
@@ -26,25 +26,6 @@
 EXPORT_SYMBOL(base_io_scsi_ctlr_vhdl);
 EXPORT_SYMBOL(master_node_get);
 
-
-/*
- * symbols referenced by the PCIBA module
- */
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/pci/pciio.h>
-#include <asm/sn/sn_cpuid.h>
-
-devfs_handle_t
-devfn_to_vertex(unsigned char busnum, unsigned int devfn);
-EXPORT_SYMBOL(devfn_to_vertex);
-EXPORT_SYMBOL(hwgraph_vertex_unref);
-EXPORT_SYMBOL(pciio_config_get);
-EXPORT_SYMBOL(pciio_info_slot_get);
-EXPORT_SYMBOL(hwgraph_edge_add);
-EXPORT_SYMBOL(pciio_info_master_get);
-EXPORT_SYMBOL(pciio_info_get);
-
 #ifdef CONFIG_IA64_SGI_SN_DEBUG
 EXPORT_SYMBOL(__pa_debug);
 EXPORT_SYMBOL(__va_debug);
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/include/asm-ia64/sn/pci/pciba.h linux-2.5.69-ia64-sn/include/asm-ia64/sn/pci/pciba.h
--- linux-2.5.69-ia64/include/asm-ia64/sn/pci/pciba.h	Fri May 23 10:12:18 2003
+++ linux-2.5.69-ia64-sn/include/asm-ia64/sn/pci/pciba.h	Fri May 23 10:37:31 2003
@@ -1,121 +0,0 @@
-/* 
- * This file is subject to the terms and conditions of the GNU General
- * Public License.  See the file "COPYING" in the main directory of
- * this archive for more details.
- *
- * Copyright (C) 1997, 2001-2003 Silicon Graphics, Inc. All rights reserved.
- *
- */
-
-#ifndef _ASM_SN_PCI_PCIBA_H
-#define _ASM_SN_PCI_PCIBA_H
-
-#include <linux/ioctl.h>
-#include <linux/types.h>
-#include <linux/pci.h>
-
-/* for application compatibility with IRIX (why do I bother?) */
-
-#ifndef __KERNEL__
-typedef u_int8_t uint8_t;
-typedef u_int16_t uint16_t;
-typedef u_int32_t uint32_t;
-#endif
-
-#define PCI_CFG_VENDOR_ID	PCI_VENDOR_ID
-#define PCI_CFG_COMMAND		PCI_COMMAND
-#define PCI_CFG_REV_ID		PCI_REVISION_ID
-#define PCI_CFG_HEADER_TYPE	PCI_HEADER_TYPE
-#define PCI_CFG_BASE_ADDR(n)	PCI_BASE_ADDRESS_##n
-
-
-/* /hw/.../pci/[slot]/config accepts ioctls to read
- * and write specific registers as follows:
- *
- * "t" is the native type (char, short, uint32, uint64)
- * to read from CFG space; results will be arranged in
- * byte significance (ie. first byte from PCI is lowest
- * or last byte in result).
- *
- * "r" is the byte offset in PCI CFG space of the first
- * byte of the register (it's least significant byte,
- * in the little-endian PCI numbering). This can actually
- * be as much as 16 bits wide, and is intended to match
- * the layout of a "Type 1 Configuration Space" address:
- * the register number in the low eight bits, then three
- * bits for the function number and five bits for the
- * slot number.
- */
-#define	PCIIOCCFGRD(t,r)	_IOR(0,(r),t)
-#define	PCIIOCCFGWR(t,r)	_IOW(0,(r),t)
-
-/* Some common config register access commands.
- * Use these as examples of how to construct
- * values for other registers you want to access.
- */
-
-/* PCIIOCGETID: arg is ptr to 32-bit int,
- * returns the 32-bit ID value with VENDOR
- * in the bottom 16 bits and DEVICE in the top.
- */
-#define	PCIIOCGETID		PCIIOCCFGRD(uint32_t,PCI_CFG_VENDOR_ID)
-
-/* PCIIOCSETCMD: arg is ptr to a 16-bit short,
- * which will be written to the CMD register.
- */
-#define	PCIIOCSETCMD		PCIIOCCFGWR(uint16_t,PCI_CFG_COMMAND)
-
-/* PCIIOCGETREV: arg is ptr to an 8-bit char,
- * which will get the 8-bit revision number.
- */
-#define	PCIIOCGETREV		PCIIOCCFGRD(uint8_t,PCI_CFG_REV_ID)
-
-/* PCIIOCGETHTYPE: arg is ptr to an 8-bit char,
- * which will get the 8-bit header type.
- */
-#define	PCIIOCGETHTYPE		PCIIOCCFGRD(uint8_t,PCI_CFG_HEADER_TYPE)
-
-/* PCIIOCGETBASE(n): arg is ptr to a 32-bit int,
- * which will get the value of the BASE<n> register.
- */
-
-/* FIXME chadt: this doesn't tell me whether or not this will work
-   with non-constant 'n.'  */
-#define	PCIIOCGETBASE(n)	PCIIOCCFGRD(uint32_t,PCI_CFG_BASE_ADDR(n))
-
-
-/* /hw/.../pci/[slot]/dma accepts ioctls to allocate
- * and free physical memory for use in user-triggered
- * DMA operations.
- */
-#define	PCIIOCDMAALLOC		_IOWR(0,1,uint64_t)
-#define	PCIIOCDMAFREE		_IOW(0,1,uint64_t)
-
-/* pio cache-mode ioctl defines.  current only uncached accelerated */
-#define PCIBA_CACHE_MODE_SET	1
-#define PCIBA_CACHE_MODE_CLEAR	2
-#ifdef PIOMAP_UNC_ACC
-#define PCIBA_UNCACHED_ACCEL	PIOMAP_UNC_ACC
-#endif
-
-/* The parameter for PCIIOCDMAALLOC needs to contain
- * both the size of the request and the flag values
- * to be used in setting up the DMA.
- *
-
-FIXME chadt: gonna have to revisit this: what flags would an IRIXer like to
- have available?
-
- * Any flags normally useful in pciio_dmamap
- * or pciio_dmatrans function calls can6 be used here.  */
-#define	PCIIOCDMAALLOC_REQUEST_PACK(flags,size)		\
-	((((uint64_t)(flags))<<32)|			\
-	 (((uint64_t)(size))&0xFFFFFFFF))
-
-
-#ifdef __KERNEL__
-extern int pciba_init(void);
-#endif
-
-
-#endif	/* _ASM_SN_PCI_PCIBA_H */
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/include/asm-ia64/sn/sgi.h linux-2.5.69-ia64-sn/include/asm-ia64/sn/sgi.h
--- linux-2.5.69-ia64/include/asm-ia64/sn/sgi.h	Fri May 23 10:12:19 2003
+++ linux-2.5.69-ia64-sn/include/asm-ia64/sn/sgi.h	Fri May 23 10:37:38 2003
@@ -17,21 +17,15 @@
 #include <asm/uaccess.h>		/* for copy_??_user */
 #include <linux/mm.h>
 #include <linux/devfs_fs_kernel.h>
-#ifdef CONFIG_HWGFS_FS
 #include <linux/fs.h>
 #include <asm/sn/hwgfs.h>
+
 typedef hwgfs_handle_t vertex_hdl_t;
-#else
-typedef devfs_handle_t vertex_hdl_t;
-#endif
 
 typedef int64_t  __psint_t;	/* needed by klgraph.c */
 
 typedef enum { B_FALSE, B_TRUE } boolean_t;
 
-#define ctob(x)			((uint64_t)(x)*NBPC)
-#define btoc(x)			(((uint64_t)(x)+(NBPC-1))/NBPC)
-
 
 /*
 ** Possible return values from graph routines.
@@ -60,20 +54,10 @@
 #define NBPP PAGE_SIZE
 #define _PAGESZ PAGE_SIZE
 
-#ifndef D_MP
-#define D_MP 1
-#endif
-
 #ifndef MAXDEVNAME
 #define MAXDEVNAME 256
 #endif
 
-#ifndef NBPC
-#define NBPC 0
-#endif
-
-typedef uint64_t mrlock_t;	/* needed by devsupport.c */
-
 #define HUB_PIO_CONVEYOR 0x1
 #define CNODEID_NONE ((cnodeid_t)-1)
 #define XTALK_PCI_PART_NUM "030-1275-"
@@ -83,10 +67,6 @@
 #define COPYIN(a, b, c)		copy_from_user(b,a,c)
 #define COPYOUT(a, b, c)	copy_to_user(b,a,c)
 
-#define kvtophys(x)		(alenaddr_t) (x)
-#define POFFMASK		(NBPP - 1)
-#define poff(X)			((__psunsigned_t)(X) & POFFMASK)
-
 #define BZERO(a,b)		memset(a, 0, b)
 
 #define kern_malloc(x)		kmalloc(x, GFP_KERNEL)
@@ -172,10 +152,6 @@
  * Definitions that do not exist in linux *
  ******************************************/
 
-typedef int cred_t;	/* This is for compilation reasons */
-struct cred { int x; };
-
-
 #define DELAY(a)
 
 /************************************************
diff -Naur -X /usr/people/jbarnes/dontdiff -u linux-2.5.69-ia64/include/asm-ia64/topology.h linux-2.5.69-ia64-sn/include/asm-ia64/topology.h
--- linux-2.5.69-ia64/include/asm-ia64/topology.h	Sun May  4 16:52:48 2003
+++ linux-2.5.69-ia64-sn/include/asm-ia64/topology.h	Fri May 23 10:35:21 2003
@@ -63,4 +63,6 @@
 /* Cross-node load balancing interval. */
 #define NODE_BALANCE_RATE 10
 
+void build_cpu_to_node_map(void);
+
 #endif /* _ASM_IA64_TOPOLOGY_H */

