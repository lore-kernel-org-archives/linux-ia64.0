From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 19 May 2003 20:03:16 +0000
Subject: [Linux-ia64] [PATCH] SN cleanups
Message-Id: <marc-linux-ia64-105590723705952@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some patches from hch@infradead.org cleaning up sn2 code a bit,
including the removal of some unnecessary files.

 arch/ia64/sn/io/drivers/hubdev.c         |  100 ---
 arch/ia64/sn/io/hwgdfs/Makefile          |   12 
 arch/ia64/sn/io/hwgdfs/hcl.c             |  955 -------------------------------
 arch/ia64/sn/io/hwgdfs/hcl_util.c        |  200 ------
 arch/ia64/sn/io/hwgdfs/invent_stub.c     |  146 ----
 arch/ia64/sn/io/hwgdfs/labelcl.c         |  653 ---------------------
 arch/ia64/sn/io/hwgfs/hwgfs.h            |   23 
 arch/ia64/Kconfig                      |   28 
 arch/ia64/sn/io/Makefile               |   12 
 arch/ia64/sn/io/drivers/Makefile       |    2 
 arch/ia64/sn/io/drivers/ifconfig_net.c |    2 
 arch/ia64/sn/io/drivers/ioconfig_bus.c |    2 
 arch/ia64/sn/io/hwgfs/hcl.c            |    2 
 arch/ia64/sn/io/sn2/klgraph.c          |    2 
 arch/ia64/sn/io/sn2/l1.c               |    1 
 arch/ia64/sn/io/sn2/ml_SN_init.c       |    3 
 arch/ia64/sn/io/sn2/ml_iograph.c       |    3 
 arch/ia64/sn/io/sn2/pcibr/Makefile     |    6 
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c  |    2 
 arch/ia64/sn/io/sn2/shuberror.c        |    6 
 arch/ia64/sn/io/sn2/xbow.c             |    2 
 arch/ia64/sn/kernel/Makefile           |    3 
 include/asm-ia64/sn/hwgfs.h            |    2 
 include/asm-ia64/sn/sn2/shubio.h       |    9 
 24 files changed, 31 insertions(+), 2145 deletions(-)

Thanks,
Jesse

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1091  -> 1.1092 
#	   arch/ia64/Kconfig	1.22    -> 1.23   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/19	jbarnes@dec.engr.sgi.com	1.1092
# remove SN1 options from KConfig
# --------------------------------------------
#
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Mon May 19 12:41:52 2003
+++ b/arch/ia64/Kconfig	Mon May 19 12:41:52 2003
@@ -63,7 +63,7 @@
 	  HP-simulator   For the HP simulator
 	  (<http://software.hp.com/ia64linux/>).
 	  HP-zx1         For HP zx1-based systems.
-	  SN1-simulator  For the SGI SN1 simulator.
+	  SGI-SN2	 For SGI Altix systems
 	  DIG-compliant  For DIG ("Developer's Interface Guide") compliant
 	  systems.
 
@@ -187,8 +187,8 @@
 # align cache-sensitive data to 128 bytes
 config IA64_L1_CACHE_SHIFT
 	int
-	default "7" if MCKINLEY || ITANIUM && IA64_SGI_SN1
-	default "6" if ITANIUM && !IA64_SGI_SN1
+	default "7" if MCKINLEY
+	default "6" if ITANIUM
 
 # align cache-sensitive data to 64 bytes
 config MCKINLEY_ASTEP_SPECIFIC
@@ -207,7 +207,7 @@
 
 config NUMA
 	bool "Enable NUMA support" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y if IA64_SGI_SN1 || IA64_SGI_SN2
+	default y if IA64_SGI_SN2
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor
@@ -231,7 +231,7 @@
 
 config DISCONTIGMEM
 	bool
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2 || (IA64_GENERIC || IA64_DIG || IA64_HP_ZX1) && NUMA
+	depends on IA64_SGI_SN2 || (IA64_GENERIC || IA64_DIG || IA64_HP_ZX1) && NUMA
 	default y
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
@@ -256,7 +256,7 @@
 
 config IA64_MCA
 	bool "Enable IA-64 Machine Check Abort" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y if IA64_SGI_SN1 || IA64_SGI_SN2
+	default y if IA64_SGI_SN2
 	help
 	  Say Y here to enable machine check support for IA-64.  If you're
 	  unsure, answer Y.
@@ -290,17 +290,17 @@
 
 config IA64_SGI_SN
 	bool
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2
+	depends on IA64_SGI_SN2
 	default y
 
 config HWGFS_FS
 	bool
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2
+	depends on IA64_SGI_SN2
 	default y
 
 config IA64_SGI_SN_DEBUG
 	bool "Enable extra debugging code"
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2
+	depends on IA64_SGI_SN2
 	help
 	  Turns on extra debugging code in the SGI SN (Scalable NUMA) platform
 	  for IA-64.  Unless you are debugging problems on an SGI SN IA-64 box,
@@ -308,14 +308,14 @@
 
 config IA64_SGI_SN_SIM
 	bool "Enable SGI Medusa Simulator Support"
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2
+	depends on IA64_SGI_SN2
 	help
 	  If you are compiling a kernel that will run under SGI's IA-64
 	  simulator (Medusa) then say Y, otherwise say N.
 
 config IA64_SGI_AUTOTEST
 	bool "Enable autotest (llsc). Option to run cache test instead of booting"
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2
+	depends on IA64_SGI_SN2
 	help
 	  Build a kernel used for hardware validation. If you include the
 	  keyword "autotest" on the boot command line, the kernel does NOT boot.
@@ -325,7 +325,7 @@
 
 config SERIAL_SGI_L1_PROTOCOL
 	bool "Enable protocol mode for the L1 console"
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2
+	depends on IA64_SGI_SN2
 	help
 	  Uses protocol mode instead of raw mode for the level 1 console on the
 	  SGI SN (Scalable NUMA) platform for IA-64.  If you are compiling for
@@ -333,12 +333,12 @@
 
 config PERCPU_IRQ
 	bool
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2
+	depends on IA64_SGI_SN2
 	default y
 
 config PCIBA
 	tristate "PCIBA support"
-	depends on IA64_SGI_SN1 || IA64_SGI_SN2
+	depends on IA64_SGI_SN2
 	help
 	  IRIX PCIBA-inspired user mode PCI interface for the SGI SN (Scalable
 	  NUMA) platform for IA-64.  Unless you are compiling a kernel for an
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1092  -> 1.1093 
#	arch/ia64/sn/kernel/Makefile	1.12    -> 1.13   
#	include/asm-ia64/sn/hwgfs.h	1.1     -> 1.2    
#	arch/ia64/sn/io/Makefile	1.12    -> 1.13   
#	arch/ia64/sn/io/hwgdfs/labelcl.c	1.5     ->         (deleted)      
#	arch/ia64/sn/io/hwgdfs/Makefile	1.1     ->         (deleted)      
#	arch/ia64/sn/io/hwgdfs/invent_stub.c	1.1     ->         (deleted)      
#	arch/ia64/sn/io/hwgdfs/hcl_util.c	1.5     ->         (deleted)      
#	arch/ia64/sn/io/hwgdfs/hcl.c	1.9     ->         (deleted)      
#	arch/ia64/sn/io/hwgfs/hwgfs.h	1.1     ->         (deleted)      
#	arch/ia64/sn/io/sn2/pcibr/Makefile	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/19	jbarnes@dec.engr.sgi.com	1.1093
# hwgfs & config option cleanups
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/Makefile b/arch/ia64/sn/io/Makefile
--- a/arch/ia64/sn/io/Makefile	Mon May 19 12:42:08 2003
+++ b/arch/ia64/sn/io/Makefile	Mon May 19 12:42:08 2003
@@ -11,13 +11,5 @@
 
 EXTRA_CFLAGS    := -DLITTLE_ENDIAN -DSHUB_SWAP_WAR
 
-obj-$(CONFIG_IA64_SGI_SN) += sgi_if.o xswitch.o sgi_io_sim.o cdl.o ate_utils.o \
-			     io.o machvec/ drivers/ platform_init/
-
-obj-$(CONFIG_IA64_SGI_SN2) += sn2/
-
-ifdef CONFIG_HWGFS_FS
-obj-$(CONFIG_HWGFS_FS) += hwgfs/
-else
-obj-$(CONFIG_DEVFS_FS) += hwgdfs/
-endif
+obj-y += sgi_if.o xswitch.o sgi_io_sim.o cdl.o ate_utils.o \
+	 io.o machvec/ drivers/ platform_init/ sn2/ hwgfs/
\ No newline at end of file
diff -Nru a/arch/ia64/sn/io/hwgdfs/Makefile b/arch/ia64/sn/io/hwgdfs/Makefile
--- a/arch/ia64/sn/io/hwgdfs/Makefile	Mon May 19 12:42:08 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,12 +0,0 @@
-#
-# This file is subject to the terms and conditions of the GNU General Public
-# License.  See the file "COPYING" in the main directory of this archive
-# for more details.
-#
-# Copyright (C) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
-#
-# Makefile for the sn2 io routines.
-
-EXTRA_CFLAGS    := -DLITTLE_ENDIAN
-
-obj-y				+= hcl.o labelcl.o hcl_util.o invent_stub.o
diff -Nru a/arch/ia64/sn/io/hwgdfs/hcl.c b/arch/ia64/sn/io/hwgdfs/hcl.c
--- a/arch/ia64/sn/io/hwgdfs/hcl.c	Mon May 19 12:42:08 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,955 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- *  hcl - SGI's Hardware Graph compatibility layer.
- *
- * Copyright (C) 1992-1997,2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-
-#include <linux/types.h>
-#include <linux/config.h>
-#include <linux/slab.h>
-#include <linux/ctype.h>
-#include <linux/module.h>
-#include <linux/init.h>
-#include <asm/sn/sgi.h>
-#include <linux/devfs_fs.h>
-#include <linux/devfs_fs_kernel.h>
-#include <asm/io.h>
-#include <asm/sn/iograph.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/labelcl.h>
-#include <asm/sn/simulator.h>
-
-#define HCL_NAME "SGI-HWGRAPH COMPATIBILITY DRIVER"
-#define HCL_TEMP_NAME "HCL_TEMP_NAME_USED_FOR_HWGRAPH_VERTEX_CREATE"
-#define HCL_TEMP_NAME_LEN 44 
-#define HCL_VERSION "1.0"
-vertex_hdl_t hwgraph_root;
-vertex_hdl_t linux_busnum;
-
-extern void pci_bus_cvlink_init(void);
-
-/*
- * Debug flag definition.
- */
-#define OPTION_NONE             0x00
-#define HCL_DEBUG_NONE 0x00000
-#define HCL_DEBUG_ALL  0x0ffff
-#if defined(CONFIG_HCL_DEBUG)
-static unsigned int hcl_debug_init __initdata = HCL_DEBUG_NONE;
-#endif
-static unsigned int hcl_debug = HCL_DEBUG_NONE;
-#if defined(CONFIG_HCL_DEBUG) && !defined(MODULE)
-static unsigned int boot_options = OPTION_NONE;
-#endif
-
-/*
- * Some Global definitions.
- */
-static vertex_hdl_t hcl_handle;
-
-invplace_t invplace_none = {
-	GRAPH_VERTEX_NONE,
-	GRAPH_VERTEX_PLACE_NONE,
-	NULL
-};
-
-/*
- * HCL device driver.
- * The purpose of this device driver is to provide a facility 
- * for User Level Apps e.g. hinv, ioconfig etc. an ioctl path 
- * to manipulate label entries without having to implement
- * system call interfaces.  This methodology will enable us to 
- * make this feature module loadable.
- */
-static int hcl_open(struct inode * inode, struct file * filp)
-{
-	if (hcl_debug) {
-        	printk("HCL: hcl_open called.\n");
-	}
-
-        return(0);
-
-}
-
-static int hcl_close(struct inode * inode, struct file * filp)
-{
-
-	if (hcl_debug) {
-        	printk("HCL: hcl_close called.\n");
-	}
-
-        return(0);
-
-}
-
-static int hcl_ioctl(struct inode * inode, struct file * file,
-        unsigned int cmd, unsigned long arg)
-{
-
-	if (hcl_debug) {
-		printk("HCL: hcl_ioctl called.\n");
-	}
-
-	switch (cmd) {
-		default:
-			if (hcl_debug) {
-				printk("HCL: hcl_ioctl cmd = 0x%x\n", cmd);
-			}
-	}
-
-	return(0);
-
-}
-
-struct file_operations hcl_fops = {
-	(struct module *)0,
-	NULL,		/* lseek - default */
-	NULL,		/* read - general block-dev read */
-	NULL,		/* write - general block-dev write */
-	NULL,		/* readdir - bad */
-	NULL,		/* poll */
-	hcl_ioctl,      /* ioctl */
-	NULL,		/* mmap */
-	hcl_open,	/* open */
-	NULL,		/* flush */
-	hcl_close,	/* release */
-	NULL,		/* fsync */
-	NULL,		/* fasync */
-	NULL,		/* lock */
-	NULL,		/* readv */
-	NULL,		/* writev */
-};
-
-
-/*
- * init_hcl() - Boot time initialization.  Ensure that it is called 
- *	after devfs has been initialized.
- *
- * For now this routine is being called out of devfs/base.c.  Actually 
- * Not a bad place to be ..
- *
- */
-int __init init_hcl(void)
-{
-	extern void string_table_init(struct string_table *);
-	extern struct string_table label_string_table;
-	extern int init_ifconfig_net(void);
-	extern int init_ioconfig_bus(void);
-	int status = 0;
-	int rv = 0;
-
-	if (IS_RUNNING_ON_SIMULATOR()) {
-		extern u64 klgraph_addr[];
-		klgraph_addr[0] = 0xe000003000030000;
-	}
-
-	/*
-	 * Create the hwgraph_root on devfs.
-	 */
-	rv = hwgraph_path_add(NULL, EDGE_LBL_HW, &hwgraph_root);
-	if (rv)
-		printk ("WARNING: init_hcl: Failed to create hwgraph_root. Error = %d.\n", rv);
-
-	status = devfs_set_flags (hwgraph_root, DEVFS_FL_HIDE);
-
-	/*
-	 * Create the hcl driver to support inventory entry manipulations.
-	 * By default, it is expected that devfs is mounted on /dev.
-	 *
-	 */
-	hcl_handle = hwgraph_register(hwgraph_root, ".hcl",
-			0, DEVFS_FL_AUTO_DEVNUM,
-			0, 0,
-			S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0,
-			&hcl_fops, NULL);
-
-	if (hcl_handle = NULL) {
-		panic("HCL: Unable to create HCL Driver in init_hcl().\n");
-		return(0);
-	}
-
-	/*
-	 * Initialize the HCL string table.
-	 */
-	string_table_init(&label_string_table);
-
-	/*
-	 * Create the directory that links Linux bus numbers to our Xwidget.
-	 */
-	rv = hwgraph_path_add(hwgraph_root, EDGE_LBL_LINUX_BUS, &linux_busnum);
-	if (linux_busnum = NULL) {
-		panic("HCL: Unable to create %s\n", EDGE_LBL_LINUX_BUS);
-		return(0);
-	}
-
-	pci_bus_cvlink_init();
-
-	/*
-	 * Initialize the ifconfgi_net driver that does network devices 
-	 * Persistent Naming.
-	 */
-	init_ifconfig_net();
-	init_ioconfig_bus();
-
-	return(0);
-
-}
-
-
-/*
- * hcl_setup() - Process boot time parameters if given.
- *	"hcl="
- *	This routine gets called only if "hcl=" is given in the 
- *	boot line and before init_hcl().
- *
- *	We currently do not have any boot options .. when we do, 
- *	functionalities can be added here.
- *
- */
-static int __init hcl_setup(char *str)
-{
-    while ( (*str != '\0') && !isspace (*str) )
-    {
-#ifdef CONFIG_HCL_DEBUG
-        if (strncmp (str, "all", 3) = 0) {
-            hcl_debug_init |= HCL_DEBUG_ALL;
-            str += 3;
-        } else 
-        	return 0;
-#endif
-        if (*str != ',') return 0;
-        ++str;
-    }
-
-    return 1;
-
-}
-
-__setup("hcl=", hcl_setup);
-
-
-/*
- * Set device specific "fast information".
- *
- */
-void
-hwgraph_fastinfo_set(vertex_hdl_t de, arbitrary_info_t fastinfo)
-{
-	labelcl_info_replace_IDX(de, HWGRAPH_FASTINFO, fastinfo, NULL);
-}
-
-
-/*
- * Get device specific "fast information".
- *
- */
-arbitrary_info_t
-hwgraph_fastinfo_get(vertex_hdl_t de)
-{
-	arbitrary_info_t fastinfo;
-	int rv;
-
-	if (!de) {
-		printk(KERN_WARNING "HCL: hwgraph_fastinfo_get handle given is NULL.\n");
-		return(-1);
-	}
-
-	rv = labelcl_info_get_IDX(de, HWGRAPH_FASTINFO, &fastinfo);
-	if (rv = 0)
-		return(fastinfo);
-
-	return(0);
-}
-
-
-/*
- * hwgraph_connectpt_set - Sets the connect point handle in de to the 
- *	given connect_de handle.  By default, the connect point of the 
- *	devfs node is the parent.  This effectively changes this assumption.
- */
-int
-hwgraph_connectpt_set(vertex_hdl_t de, vertex_hdl_t connect_de)
-{
-	int rv;
-
-	if (!de)
-		return(-1);
-
-	rv = labelcl_info_connectpt_set(de, connect_de);
-
-	return(rv);
-}
-
-
-/*
- * hwgraph_connectpt_get: Returns the entry's connect point  in the devfs 
- *	tree.
- */
-vertex_hdl_t
-hwgraph_connectpt_get(vertex_hdl_t de)
-{
-	int rv;
-	arbitrary_info_t info;
-	vertex_hdl_t connect;
-
-	rv = labelcl_info_get_IDX(de, HWGRAPH_CONNECTPT, &info);
-	if (rv != 0) {
-		return(NULL);
-	}
-
-	connect = (vertex_hdl_t)info;
-	return(connect);
-
-}
-
-
-/*
- * hwgraph_mk_dir - Creates a directory entry with devfs.
- *	Note that a directory entry in devfs can have children 
- *	but it cannot be a char|block special file.
- */
-vertex_hdl_t
-hwgraph_mk_dir(vertex_hdl_t de, const char *name,
-                unsigned int namelen, void *info)
-{
-
-	int rv;
-	labelcl_info_t *labelcl_info = NULL;
-	vertex_hdl_t new_devfs_handle = NULL;
-	vertex_hdl_t parent = NULL;
-
-	/*
-	 * Create the device info structure for hwgraph compatiblity support.
-	 */
-	labelcl_info = labelcl_info_create();
-	if (!labelcl_info)
-		return(NULL);
-
-	/*
-	 * Create a devfs entry.
-	 */
-	new_devfs_handle = devfs_mk_dir(de, name, (void *)labelcl_info);
-	if (!new_devfs_handle) {
-		labelcl_info_destroy(labelcl_info);
-		return(NULL);
-	}
-
-	/*
-	 * Get the parent handle.
-	 */
-	parent = devfs_get_parent (new_devfs_handle);
-
-	/*
-	 * To provide the same semantics as the hwgraph, set the connect point.
-	 */
-	rv = hwgraph_connectpt_set(new_devfs_handle, parent);
-	if (!rv) {
-		/*
-		 * We need to clean up!
-		 */
-	}
-
-	/*
-	 * If the caller provides a private data pointer, save it in the 
-	 * labelcl info structure(fastinfo).  This can be retrieved via
-	 * hwgraph_fastinfo_get()
-	 */
-	if (info)
-		hwgraph_fastinfo_set(new_devfs_handle, (arbitrary_info_t)info);
-		
-	return(new_devfs_handle);
-
-}
-
-/*
- * hwgraph_path_add - Create a directory node with the given path starting 
- * from the given vertex_hdl_t.
- */
-int
-hwgraph_path_add(vertex_hdl_t  fromv,
-		 char *path,
-		 vertex_hdl_t *new_de)
-{
-
-	unsigned int	namelen = strlen(path);
-	int		rv;
-
-	/*
-	 * We need to handle the case when fromv is NULL ..
-	 * in this case we need to create the path from the 
-	 * hwgraph root!
-	 */
-	if (fromv = NULL)
-		fromv = hwgraph_root;
-
-	/*
-	 * check the entry doesn't already exist, if it does
-	 * then we simply want new_de to point to it (otherwise
-	 * we'll overwrite the existing labelcl_info struct)
-	 */
-	rv = hwgraph_edge_get(fromv, path, new_de);
-	if (rv)	{	/* couldn't find entry so we create it */
-		*new_de = hwgraph_mk_dir(fromv, path, namelen, NULL);
-		if (new_de = NULL)
-			return(-1);
-		else
-			return(0);
-	}
-	else 
- 		return(0);
-
-}
-
-/*
- * hwgraph_register  - Creates a file entry with devfs.
- *	Note that a file entry cannot have children .. it is like a 
- *	char|block special vertex in hwgraph.
- */
-vertex_hdl_t
-hwgraph_register(vertex_hdl_t de, const char *name,
-                unsigned int namelen, unsigned int flags, 
-		unsigned int major, unsigned int minor,
-                umode_t mode, uid_t uid, gid_t gid, 
-		struct file_operations *fops,
-                void *info)
-{
-
-	int rv;
-        void *labelcl_info = NULL;
-        vertex_hdl_t new_devfs_handle = NULL;
-	vertex_hdl_t parent = NULL;
-
-        /*
-         * Create the labelcl info structure for hwgraph compatiblity support.
-         */
-        labelcl_info = labelcl_info_create();
-        if (!labelcl_info)
-                return(NULL);
-
-        /*
-         * Create a devfs entry.
-         */
-        new_devfs_handle = devfs_register(de, name, flags, major,
-				minor, mode, fops, labelcl_info);
-        if (!new_devfs_handle) {
-                labelcl_info_destroy((labelcl_info_t *)labelcl_info);
-                return(NULL);
-        }
-
-	/*
-	 * Get the parent handle.
-	 */
-	if (de = NULL)
-		parent = devfs_get_parent (new_devfs_handle);
-	else
-		parent = de;
-		
-	/*
-	 * To provide the same semantics as the hwgraph, set the connect point.
-	 */
-	rv = hwgraph_connectpt_set(new_devfs_handle, parent);
-	if (rv) {
-		/*
-		 * We need to clean up!
-		 */
-		printk(KERN_WARNING "HCL: Unable to set the connect point to it's parent 0x%p\n",
-			(void *)new_devfs_handle);
-	}
-
-        /*
-         * If the caller provides a private data pointer, save it in the 
-         * labelcl info structure(fastinfo).  This can be retrieved via
-         * hwgraph_fastinfo_get()
-         */
-        if (info)
-                hwgraph_fastinfo_set(new_devfs_handle, (arbitrary_info_t)info);
-
-        return(new_devfs_handle);
-
-}
-
-
-/*
- * hwgraph_mk_symlink - Create a symbolic link.
- */
-int
-hwgraph_mk_symlink(vertex_hdl_t de, const char *name, unsigned int namelen,
-                unsigned int flags, const char *link, unsigned int linklen, 
-		vertex_hdl_t *handle, void *info)
-{
-
-	void *labelcl_info = NULL;
-	int status = 0;
-	vertex_hdl_t new_devfs_handle = NULL;
-
-	/*
-	 * Create the labelcl info structure for hwgraph compatiblity support.
-	 */
-	labelcl_info = labelcl_info_create();
-	if (!labelcl_info)
-		return(-1);
-
-	/*
-	 * Create a symbolic link devfs entry.
-	 */
-	status = devfs_mk_symlink(de, name, flags, link,
-				&new_devfs_handle, labelcl_info);
-	if ( (!new_devfs_handle) || (!status) ){
-		labelcl_info_destroy((labelcl_info_t *)labelcl_info);
-		return(-1);
-	}
-
-	/*
-	 * If the caller provides a private data pointer, save it in the 
-	 * labelcl info structure(fastinfo).  This can be retrieved via
-	 * hwgraph_fastinfo_get()
-	 */
-	if (info)
-		hwgraph_fastinfo_set(new_devfs_handle, (arbitrary_info_t)info);
-
-	*handle = new_devfs_handle;
-	return(0);
-
-}
-
-/*
- * hwgraph_vertex_destroy - Destroy the devfs entry
- */
-int
-hwgraph_vertex_destroy(vertex_hdl_t de)
-{
-
-	void *labelcl_info = NULL;
-
-	labelcl_info = devfs_get_info(de);
-	devfs_unregister(de);
-
-	if (labelcl_info)
-		labelcl_info_destroy((labelcl_info_t *)labelcl_info);
-
-	return(0);
-}
-
-/*
- * hwgraph_edge_add - This routines has changed from the original conext.
- * All it does now is to create a symbolic link from "from" to "to".
- */
-/* ARGSUSED */
-int
-hwgraph_edge_add(vertex_hdl_t from, vertex_hdl_t to, char *name)
-{
-
-	char *path;
-	char *s1;
-	char *index;
-	int name_start;
-	vertex_hdl_t handle = NULL;
-	int rv;
-	int i, count;
-
-	path = kmalloc(1024, GFP_KERNEL);
-	memset(path, 0x0, 1024);
-	name_start = devfs_generate_path (from, path, 1024);
-	s1 = &path[name_start];
-	count = 0;
-	while (1) {
-		index = strstr (s1, "/");
-		if (index) {
-			count++;
-			s1 = ++index;
-		} else {
-			count++;
-			break;
-		}
-	}
-
-	memset(path, 0x0, 1024);
-	name_start = devfs_generate_path (to, path, 1024);
-
-	for (i = 0; i < count; i++) {
-		strcat(path,"../");
-	}
-
-	strcat(path, &path[name_start]);
-
-	/*
-	 * Otherwise, just create a symlink to the vertex.
-	 * In this case the vertex was previous created with a REAL pathname.
-	 */
-	rv = devfs_mk_symlink (from, (const char *)name, 
-			       DEVFS_FL_DEFAULT, path,
-			       &handle, NULL);
-
-	name_start = devfs_generate_path (handle, path, 1024);
-	return(rv);
-
-	
-}
-/* ARGSUSED */
-int
-hwgraph_edge_get(vertex_hdl_t from, char *name, vertex_hdl_t *toptr)
-{
-
-	int namelen = 0;
-	vertex_hdl_t target_handle = NULL;
-
-	if (name = NULL)
-		return(-1);
-
-	if (toptr = NULL)
-		return(-1);
-
-	/*
-	 * If the name is "." just return the current devfs entry handle.
-	 */
-	if (!strcmp(name, HWGRAPH_EDGELBL_DOT)) {
-		if (toptr) {
-			*toptr = from;
-		}
-	} else if (!strcmp(name, HWGRAPH_EDGELBL_DOTDOT)) {
-		/*
-		 * Hmmm .. should we return the connect point or parent ..
-		 * see in hwgraph, the concept of parent is the connectpt!
-		 *
-		 * Maybe we should see whether the connectpt is set .. if 
-		 * not just return the parent!
-		 */
-		target_handle = hwgraph_connectpt_get(from);
-		if (target_handle) {
-			/*
-			 * Just return the connect point.
-			 */
-			*toptr = target_handle;
-			return(0);
-		}
-		target_handle = devfs_get_parent(from);
-		*toptr = target_handle;
-
-	} else {
-		/*
-		 * Call devfs to get the devfs entry.
-		 */
-		namelen = (int) strlen(name);
-		target_handle = devfs_find_handle (from, name, 0, 0,
-					0, 1); /* Yes traverse symbolic links */
-		if (target_handle = NULL)
-			return(-1);
-		else
-		*toptr = target_handle;
-	}
-
-	return(0);
-}
-
-/*
- * hwgraph_info_add_LBL - Adds a new label for the device.  Mark the info_desc
- *	of the label as INFO_DESC_PRIVATE and store the info in the label.
- */
-/* ARGSUSED */
-int
-hwgraph_info_add_LBL(	vertex_hdl_t de,
-			char *name,
-			arbitrary_info_t info)
-{
-	return(labelcl_info_add_LBL(de, name, INFO_DESC_PRIVATE, info));
-}
-
-/*
- * hwgraph_info_remove_LBL - Remove the label entry for the device.
- */
-/* ARGSUSED */
-int
-hwgraph_info_remove_LBL(	vertex_hdl_t de,
-				char *name,
-				arbitrary_info_t *old_info)
-{
-	return(labelcl_info_remove_LBL(de, name, NULL, old_info));
-}
-
-/*
- * hwgraph_info_replace_LBL - replaces an existing label with 
- *	a new label info value.
- */
-/* ARGSUSED */
-int
-hwgraph_info_replace_LBL(	vertex_hdl_t de,
-				char *name,
-				arbitrary_info_t info,
-				arbitrary_info_t *old_info)
-{
-	return(labelcl_info_replace_LBL(de, name,
-			INFO_DESC_PRIVATE, info,
-			NULL, old_info));
-}
-/*
- * hwgraph_info_get_LBL - Get and return the info value in the label of the 
- * 	device.
- */
-/* ARGSUSED */
-int
-hwgraph_info_get_LBL(	vertex_hdl_t de,
-			char *name,
-			arbitrary_info_t *infop)
-{
-	return(labelcl_info_get_LBL(de, name, NULL, infop));
-}
-
-/*
- * hwgraph_info_get_exported_LBL - Retrieve the info_desc and info pointer 
- *	of the given label for the device.  The weird thing is that the label 
- *	that matches the name is return irrespective of the info_desc value!
- *	Do not understand why the word "exported" is used!
- */
-/* ARGSUSED */
-int
-hwgraph_info_get_exported_LBL(	vertex_hdl_t de,
-				char *name,
-				int *export_info,
-				arbitrary_info_t *infop)
-{
-	int rc;
-	arb_info_desc_t info_desc;
-
-	rc = labelcl_info_get_LBL(de, name, &info_desc, infop);
-	if (rc = 0)
-		*export_info = (int)info_desc;
-
-	return(rc);
-}
-
-/*
- * hwgraph_info_get_next_LBL - Returns the next label info given the 
- *	current label entry in place.
- *
- *	Once again this has no locking or reference count for protection.
- *
- */
-/* ARGSUSED */
-int
-hwgraph_info_get_next_LBL(	vertex_hdl_t de,
-				char *buf,
-				arbitrary_info_t *infop,
-				labelcl_info_place_t *place)
-{
-	return(labelcl_info_get_next_LBL(de, buf, NULL, infop, place));
-}
-
-/*
- * hwgraph_info_export_LBL - Retrieve the specified label entry and modify 
- *	the info_desc field with the given value in nbytes.
- */
-/* ARGSUSED */
-int
-hwgraph_info_export_LBL(vertex_hdl_t de, char *name, int nbytes)
-{
-	arbitrary_info_t info;
-	int rc;
-
-	if (nbytes = 0)
-		nbytes = INFO_DESC_EXPORT;
-
-	if (nbytes < 0)
-		return(-1);
-
-	rc = labelcl_info_get_LBL(de, name, NULL, &info);
-	if (rc != 0)
-		return(rc);
-
-	rc = labelcl_info_replace_LBL(de, name,
-				nbytes, info, NULL, NULL);
-
-	return(rc);
-}
-
-/*
- * hwgraph_info_unexport_LBL - Retrieve the given label entry and change the 
- * label info_descr filed to INFO_DESC_PRIVATE.
- */
-/* ARGSUSED */
-int
-hwgraph_info_unexport_LBL(vertex_hdl_t de, char *name)
-{
-	arbitrary_info_t info;
-	int rc;
-
-	rc = labelcl_info_get_LBL(de, name, NULL, &info);
-	if (rc != 0)
-		return(rc);
-
-	rc = labelcl_info_replace_LBL(de, name,
-				INFO_DESC_PRIVATE, info, NULL, NULL);
-
-	return(rc);
-}
-
-/*
- * hwgraph_path_lookup - return the handle for the given path.
- *
- */
-int
-hwgraph_path_lookup(	vertex_hdl_t start_vertex_handle,
-			char *lookup_path,
-			vertex_hdl_t *vertex_handle_ptr,
-			char **remainder)
-{
-	*vertex_handle_ptr = devfs_find_handle(start_vertex_handle,	/* start dir */
-					lookup_path,		/* path */
-					0,			/* major */
-					0,			/* minor */
-					0,			/* char | block */
-					1);			/* traverse symlinks */
-	if (*vertex_handle_ptr = NULL)
-		return(-1);
-	else
-		return(0);
-}
-
-/*
- * hwgraph_traverse - Find and return the devfs handle starting from de.
- *
- */
-graph_error_t
-hwgraph_traverse(vertex_hdl_t de, char *path, vertex_hdl_t *found)
-{
-	/* 
-	 * get the directory entry (path should end in a directory)
-	 */
-
-	*found = devfs_find_handle(de,	/* start dir */
-			    path,	/* path */
-			    0,		/* major */
-			    0,		/* minor */
-			    0,		/* char | block */
-			    1);		/* traverse symlinks */
-	if (*found = NULL)
-		return(GRAPH_NOT_FOUND);
-	else
-		return(GRAPH_SUCCESS);
-}
-
-/*
- * hwgraph_path_to_vertex - Return the devfs entry handle for the given 
- *	pathname .. assume traverse symlinks too!.
- */
-vertex_hdl_t
-hwgraph_path_to_vertex(char *path)
-{
-	return(devfs_find_handle(NULL,	/* start dir */
-			path,		/* path */
-		    	0,		/* major */
-		    	0,		/* minor */
-		    	0,		/* char | block */
-		    	1));		/* traverse symlinks */
-}
-
-/*
- * hwgraph_inventory_remove - Removes an inventory entry.
- *
- *	Remove an inventory item associated with a vertex.   It is the caller's
- *	responsibility to make sure that there are no races between removing
- *	inventory from a vertex and simultaneously removing that vertex.
-*/
-int
-hwgraph_inventory_remove(	vertex_hdl_t de,
-				int class,
-				int type,
-				major_t controller,
-				minor_t unit,
-				int state)
-{
-	return(0); /* Just a Stub for IRIX code. */
-}
-
-/*
- * Find the canonical name for a given vertex by walking back through
- * connectpt's until we hit the hwgraph root vertex (or until we run
- * out of buffer space or until something goes wrong).
- *
- *	COMPATIBILITY FUNCTIONALITY
- * Walks back through 'parents', not necessarily the same as connectpts.
- *
- * Need to resolve the fact that devfs does not return the path from 
- * "/" but rather it just stops right before /dev ..
- */
-int
-hwgraph_vertex_name_get(vertex_hdl_t vhdl, char *buf, uint buflen)
-{
-	char *locbuf;
-	int   pos;
-
-	if (buflen < 1)
-		return(-1);	/* XXX should be GRAPH_BAD_PARAM ? */
-
-	locbuf = kmalloc(buflen, GFP_KERNEL);
-
-	pos = devfs_generate_path(vhdl, locbuf, buflen);
-	if (pos < 0) {
-		kfree(locbuf);
-		return pos;
-	}
-
-	strcpy(buf, &locbuf[pos]);
-	kfree(locbuf);
-	return 0;
-}
-
-/*
-** vertex_to_name converts a vertex into a canonical name by walking
-** back through connect points until we hit the hwgraph root (or until
-** we run out of buffer space).
-**
-** Usually returns a pointer to the original buffer, filled in as
-** appropriate.  If the buffer is too small to hold the entire name,
-** or if anything goes wrong while determining the name, vertex_to_name
-** returns "UnknownDevice".
-*/
-
-#define DEVNAME_UNKNOWN "UnknownDevice"
-
-char *
-vertex_to_name(vertex_hdl_t vhdl, char *buf, uint buflen)
-{
-	if (hwgraph_vertex_name_get(vhdl, buf, buflen) = GRAPH_SUCCESS)
-		return(buf);
-	else
-		return(DEVNAME_UNKNOWN);
-}
-
-graph_error_t
-hwgraph_edge_remove(vertex_hdl_t from, char *name, vertex_hdl_t *toptr)
-{
-	printk("WARNING: hwgraph_edge_remove NOT supported.\n");
-	return(GRAPH_ILLEGAL_REQUEST);
-}
-
-graph_error_t
-hwgraph_vertex_unref(vertex_hdl_t vhdl)
-{
-	return(GRAPH_ILLEGAL_REQUEST);
-}
-
-
-EXPORT_SYMBOL(hwgraph_mk_dir);
-EXPORT_SYMBOL(hwgraph_path_add);
-EXPORT_SYMBOL(hwgraph_register);
-EXPORT_SYMBOL(hwgraph_vertex_destroy);
-EXPORT_SYMBOL(hwgraph_fastinfo_get);
-EXPORT_SYMBOL(hwgraph_fastinfo_set);
-EXPORT_SYMBOL(hwgraph_connectpt_set);
-EXPORT_SYMBOL(hwgraph_connectpt_get);
-EXPORT_SYMBOL(hwgraph_info_add_LBL);
-EXPORT_SYMBOL(hwgraph_info_remove_LBL);
-EXPORT_SYMBOL(hwgraph_info_replace_LBL);
-EXPORT_SYMBOL(hwgraph_info_get_LBL);
-EXPORT_SYMBOL(hwgraph_info_get_exported_LBL);
-EXPORT_SYMBOL(hwgraph_info_get_next_LBL);
-EXPORT_SYMBOL(hwgraph_info_export_LBL);
-EXPORT_SYMBOL(hwgraph_info_unexport_LBL);
-EXPORT_SYMBOL(hwgraph_path_lookup);
-EXPORT_SYMBOL(hwgraph_traverse);
-EXPORT_SYMBOL(hwgraph_vertex_name_get);
diff -Nru a/arch/ia64/sn/io/hwgdfs/hcl_util.c b/arch/ia64/sn/io/hwgdfs/hcl_util.c
--- a/arch/ia64/sn/io/hwgdfs/hcl_util.c	Mon May 19 12:42:08 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,200 +0,0 @@
-/* $Id: hcl_util.c,v 1.3 2003/04/24 13:59:39 pfg Exp $
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992-1997,2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-
-#include <linux/types.h>
-#include <linux/kernel.h>
-#include <linux/devfs_fs.h>
-#include <linux/devfs_fs_kernel.h>
-#include <asm/sn/sgi.h>
-#include <asm/io.h>
-#include <asm/sn/io.h>
-#include <asm/sn/iograph.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/labelcl.h>
-#include <asm/sn/hcl_util.h>
-#include <asm/sn/nodepda.h>
-
-static vertex_hdl_t hwgraph_all_cnodes = GRAPH_VERTEX_NONE;
-extern vertex_hdl_t hwgraph_root;
-
-
-/*
-** Return the "master" for a given vertex.  A master vertex is a
-** controller or adapter or other piece of hardware that the given
-** vertex passes through on the way to the rest of the system.
-*/
-vertex_hdl_t
-device_master_get(vertex_hdl_t vhdl)
-{
-	graph_error_t rc;
-	vertex_hdl_t master;
-
-	rc = hwgraph_edge_get(vhdl, EDGE_LBL_MASTER, &master);
-	if (rc = GRAPH_SUCCESS)
-		return(master);
-	else
-		return(GRAPH_VERTEX_NONE);
-}
-
-/*
-** Set the master for a given vertex.
-** Returns 0 on success, non-0 indicates failure
-*/
-int
-device_master_set(vertex_hdl_t vhdl, vertex_hdl_t master)
-{
-	graph_error_t rc;
-
-	rc = hwgraph_edge_add(vhdl, master, EDGE_LBL_MASTER);
-	return(rc != GRAPH_SUCCESS);
-}
-
-
-/*
-** Return the compact node id of the node that ultimately "owns" the specified
-** vertex.  In order to do this, we walk back through masters and connect points
-** until we reach a vertex that represents a node.
-*/
-cnodeid_t
-master_node_get(vertex_hdl_t vhdl)
-{
-	cnodeid_t cnodeid;
-	vertex_hdl_t master;
-
-	for (;;) {
-		cnodeid = nodevertex_to_cnodeid(vhdl);
-		if (cnodeid != CNODEID_NONE)
-			return(cnodeid);
-
-		master = device_master_get(vhdl);
-
-		/* Check for exceptional cases */
-		if (master = vhdl) {
-			/* Since we got a reference to the "master" thru
-			 * device_master_get() we should decrement
-			 * its reference count by 1
-			 */
-			return(CNODEID_NONE);
-		}
-
-		if (master = GRAPH_VERTEX_NONE) {
-			master = hwgraph_connectpt_get(vhdl);
-			if ((master = GRAPH_VERTEX_NONE) ||
-			    (master = vhdl)) {
-				return(CNODEID_NONE);
-			}
-		}
-
-		vhdl = master;
-	}
-}
-
-static vertex_hdl_t hwgraph_all_cpuids = GRAPH_VERTEX_NONE;
-extern int maxcpus;
-
-void
-mark_cpuvertex_as_cpu(vertex_hdl_t vhdl, cpuid_t cpuid)
-{
-	if (cpuid = CPU_NONE)
-		return;
-
-	(void)labelcl_info_add_LBL(vhdl, INFO_LBL_CPUID, INFO_DESC_EXPORT,
-			(arbitrary_info_t)cpuid);
-	{
-		char cpuid_buffer[10];
-
-		if (hwgraph_all_cpuids = GRAPH_VERTEX_NONE) {
-			(void)hwgraph_path_add( hwgraph_root,
-						EDGE_LBL_CPUNUM,
-						&hwgraph_all_cpuids);
-		}
-
-		sprintf(cpuid_buffer, "%ld", cpuid);
-		(void)hwgraph_edge_add( hwgraph_all_cpuids,
-							vhdl,
-							cpuid_buffer);
-	}
-}
-
-/*
-** If the specified device represents a node, return its
-** compact node ID; otherwise, return CNODEID_NONE.
-*/
-cnodeid_t
-nodevertex_to_cnodeid(vertex_hdl_t vhdl)
-{
-	int rv = 0;
-	arbitrary_info_t cnodeid = CNODEID_NONE;
-
-	rv = labelcl_info_get_LBL(vhdl, INFO_LBL_CNODEID, NULL, &cnodeid);
-
-	return((cnodeid_t)cnodeid);
-}
-
-void
-mark_nodevertex_as_node(vertex_hdl_t vhdl, cnodeid_t cnodeid)
-{
-	if (cnodeid = CNODEID_NONE)
-		return;
-
-	cnodeid_to_vertex(cnodeid) = vhdl;
-	labelcl_info_add_LBL(vhdl, INFO_LBL_CNODEID, INFO_DESC_EXPORT, 
-		(arbitrary_info_t)cnodeid);
-
-	{
-		char cnodeid_buffer[10];
-
-		if (hwgraph_all_cnodes = GRAPH_VERTEX_NONE) {
-			(void)hwgraph_path_add( hwgraph_root,
-						EDGE_LBL_NODENUM,
-						&hwgraph_all_cnodes);
-		}
-
-		sprintf(cnodeid_buffer, "%d", cnodeid);
-		(void)hwgraph_edge_add( hwgraph_all_cnodes,
-					vhdl,
-					cnodeid_buffer);
-	}
-}
-
-/*
-** If the specified device represents a CPU, return its cpuid;
-** otherwise, return CPU_NONE.
-*/
-cpuid_t
-cpuvertex_to_cpuid(vertex_hdl_t vhdl)
-{
-	arbitrary_info_t cpuid = CPU_NONE;
-
-	(void)labelcl_info_get_LBL(vhdl, INFO_LBL_CPUID, NULL, &cpuid);
-
-	return((cpuid_t)cpuid);
-}
-
-
-/*
-** dev_to_name converts a vertex_hdl_t into a canonical name.  If the vertex_hdl_t
-** represents a vertex in the hardware graph, it is converted in the
-** normal way for vertices.  If the vertex_hdl_t is an old vertex_hdl_t (one which
-** does not represent a hwgraph vertex), we synthesize a name based
-** on major/minor number.
-**
-** Usually returns a pointer to the original buffer, filled in as
-** appropriate.  If the buffer is too small to hold the entire name,
-** or if anything goes wrong while determining the name, dev_to_name
-** returns "UnknownDevice".
-*/
-char *
-dev_to_name(vertex_hdl_t dev, char *buf, uint buflen)
-{
-        return(vertex_to_name(dev, buf, buflen));
-}
-
-
diff -Nru a/arch/ia64/sn/io/hwgdfs/invent_stub.c b/arch/ia64/sn/io/hwgdfs/invent_stub.c
--- a/arch/ia64/sn/io/hwgdfs/invent_stub.c	Mon May 19 12:42:08 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,146 +0,0 @@
-/* $Id$
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992-1997,2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-
-/*
- * Hardware Inventory
- *
- * See sys/sn/invent.h for an explanation of the hardware inventory contents.
- *
- */
-#include <linux/types.h>
-#include <asm/sn/sgi.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/labelcl.h>
-
-void
-inventinit(void)
-{
-}
-
-/*
- * For initializing/updating an inventory entry.
- */
-void
-replace_in_inventory(
-	inventory_t *pinv, int class, int type,
-	int controller, int unit, int state)
-{
-}
-
-/*
- * Inventory addition 
- *
- * XXX NOTE: Currently must be called after dynamic memory allocator is
- * initialized.
- *
- */
-void
-add_to_inventory(int class, int type, int controller, int unit, int state)
-{
-}
-
-
-/*
- * Inventory retrieval 
- *
- * These two routines are intended to prevent the caller from having to know
- * the internal structure of the inventory table.
- *
- * The caller of get_next_inventory is supposed to call start_scan_invent
- * before the irst call to get_next_inventory, and the caller is required
- * to call end_scan_invent after the last call to get_next_inventory.
- */
-inventory_t *
-get_next_inventory(invplace_t *place)
-{
-	return((inventory_t *) NULL);
-}
-
-/* ARGSUSED */
-int
-get_sizeof_inventory(int abi)
-{
-	return sizeof(inventory_t);
-}
-
-/* Must be called prior to first call to get_next_inventory */
-void
-start_scan_inventory(invplace_t *iplace)
-{
-}
-
-/* Must be called after last call to get_next_inventory */
-void
-end_scan_inventory(invplace_t *iplace)
-{
-}
-
-/*
- * Hardware inventory scanner.
- *
- * Calls fun() for every entry in inventory list unless fun() returns something
- * other than 0.
- */
-int
-scaninvent(int (*fun)(inventory_t *, void *), void *arg)
-{
-	return 0;
-}
-
-/*
- * Find a particular inventory object
- *
- * pinv can be a pointer to an inventory entry and the search will begin from
- * there, or it can be 0 in which case the search starts at the beginning.
- * A -1 for any of the other arguments is a wildcard (i.e. it always matches).
- */
-inventory_t *
-find_inventory(inventory_t *pinv, int class, int type, int controller,
-	       int unit, int state)
-{
-	return((inventory_t *) NULL);
-}
-
-
-/*
-** Retrieve inventory data associated with a device.
-*/
-inventory_t *
-device_inventory_get_next(	vertex_hdl_t device,
-				invplace_t *invplace)
-{
-		return((inventory_t *) NULL);
-}
-
-
-/*
-** Associate canonical inventory information with a device (and
-** add it to the general inventory).
-*/
-void
-device_inventory_add(	vertex_hdl_t device,
-			int class, 
-			int type, 
-			major_t controller, 
-			minor_t unit, 
-			int state)
-{
-}
-
-int
-device_controller_num_get(vertex_hdl_t device)
-{
-	return (0);
-}
-
-void
-device_controller_num_set(vertex_hdl_t device, int contr_num)
-{
-}
diff -Nru a/arch/ia64/sn/io/hwgdfs/labelcl.c b/arch/ia64/sn/io/hwgdfs/labelcl.c
--- a/arch/ia64/sn/io/hwgdfs/labelcl.c	Mon May 19 12:42:08 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,653 +0,0 @@
-/*  labelcl - SGI's Hwgraph Compatibility Layer.
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2001-2003 Silicon Graphics, Inc.  All rights reserved.
-*/
-
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <asm/sn/sgi.h>
-#include <linux/devfs_fs.h>
-#include <linux/devfs_fs_kernel.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/labelcl.h>
-
-/*
-** Very simple and dumb string table that supports only find/insert.
-** In practice, if this table gets too large, we may need a more
-** efficient data structure.   Also note that currently there is no 
-** way to delete an item once it's added.  Therefore, name collision 
-** will return an error.
-*/
-
-struct string_table label_string_table;
-
-
-
-/*
- * string_table_init - Initialize the given string table.
- */
-void
-string_table_init(struct string_table *string_table)
-{
-	string_table->string_table_head = NULL;
-	string_table->string_table_generation = 0;
-
-	/*
-	 * We nedd to initialize locks here!
-	 */
-
-	return;
-}
-
-
-/*
- * string_table_destroy - Destroy the given string table.
- */
-void
-string_table_destroy(struct string_table *string_table)
-{
-	struct string_table_item *item, *next_item;
-
-	item = string_table->string_table_head;
-	while (item) {
-		next_item = item->next;
-
-		STRTBL_FREE(item);
-		item = next_item;
-	}
-
-	/*
-	 * We need to destroy whatever lock we have here
-	 */
-
-	return;
-}
-
-
-
-/*
- * string_table_insert - Insert an entry in the string table .. duplicate 
- *	names are not allowed.
- */
-char *
-string_table_insert(struct string_table *string_table, char *name)
-{
-	struct string_table_item *item, *new_item = NULL, *last_item = NULL;
-
-again:
-	/*
-	 * Need to lock the table ..
-	 */
-	item = string_table->string_table_head;
-	last_item = NULL;
-
-	while (item) {
-		if (!strcmp(item->string, name)) {
-			/*
-			 * If we allocated space for the string and the found that
-			 * someone else already entered it into the string table,
-			 * free the space we just allocated.
-			 */
-			if (new_item)
-				STRTBL_FREE(new_item);
-
-
-			/*
-			 * Search optimization: move the found item to the head
-			 * of the list.
-			 */
-			if (last_item != NULL) {
-				last_item->next = item->next;
-				item->next = string_table->string_table_head;
-				string_table->string_table_head = item;
-			}
-			goto out;
-		}
-		last_item = item;
-		item=item->next;
-	}
-
-	/*
-	 * name was not found, so add it to the string table.
-	 */
-	if (new_item = NULL) {
-		long old_generation = string_table->string_table_generation;
-
-		new_item = STRTBL_ALLOC(strlen(name));
-
-		strcpy(new_item->string, name);
-
-		/*
-		 * While we allocated memory for the new string, someone else 
-		 * changed the string table.
-		 */
-		if (old_generation != string_table->string_table_generation) {
-			goto again;
-		}
-	} else {
-		/* At this we only have the string table lock in access mode.
-		 * Promote the access lock to an update lock for the string
-		 * table insertion below.
-		 */
-			long old_generation = 
-				string_table->string_table_generation;
-
-			/*
-			 * After we did the unlock and wer waiting for update
-			 * lock someone could have potentially updated
-			 * the string table. Check the generation number
-			 * for this case. If it is the case we have to
-			 * try all over again.
-			 */
-			if (old_generation != 
-			    string_table->string_table_generation) {
-				goto again;
-			}
-		}
-
-	/*
-	 * At this point, we're committed to adding new_item to the string table.
-	 */
-	new_item->next = string_table->string_table_head;
-	item = string_table->string_table_head = new_item;
-	string_table->string_table_generation++;
-
-out:
-	/*
-	 * Need to unlock here.
-	 */
-	return(item->string);
-}
-
-/*
- * labelcl_info_create - Creates the data structure that will hold the
- *	device private information asscoiated with a devfs entry.
- *	The pointer to this structure is what gets stored in the devfs 
- *	(void * info).
- */
-labelcl_info_t *
-labelcl_info_create()
-{
-
-	labelcl_info_t *new = NULL;
-
-	/* Initial allocation does not include any area for labels */
-	if ( ( new = (labelcl_info_t *)kmalloc (sizeof(labelcl_info_t), GFP_KERNEL) ) = NULL )
-		return NULL;
-
-	memset (new, 0, sizeof(labelcl_info_t));
-	new->hwcl_magic = LABELCL_MAGIC;
-	return( new);
-
-}
-
-/*
- * labelcl_info_destroy - Frees the data structure that holds the
- *      device private information asscoiated with a devfs entry.  This 
- *	data structure was created by device_info_create().
- *
- *	The caller is responsible for nulling the (void *info) in the 
- *	corresponding devfs entry.
- */
-int
-labelcl_info_destroy(labelcl_info_t *labelcl_info)
-{
-
-	if (labelcl_info = NULL)
-		return(0);
-
-	/* Free the label list */
-	if (labelcl_info->label_list)
-		kfree(labelcl_info->label_list);
-
-	/* Now free the label info area */
-	labelcl_info->hwcl_magic = 0;
-	kfree(labelcl_info);
-
-	return(0);
-}
-
-/*
- * labelcl_info_add_LBL - Adds a new label entry in the labelcl info 
- *	structure.
- *
- *	Error is returned if we find another label with the same name.
- */
-int
-labelcl_info_add_LBL(vertex_hdl_t de,
-			char *info_name,
-			arb_info_desc_t info_desc,
-			arbitrary_info_t info)
-{
-	labelcl_info_t	*labelcl_info = NULL;
-	int num_labels;
-	int new_label_list_size;
-	label_info_t *old_label_list, *new_label_list = NULL;
-	char *name;
-	int i;
-
-	if (de = NULL)
-		return(-1);
-
-        labelcl_info = devfs_get_info(de);
-	if (labelcl_info = NULL)
-		return(-1);
-
-	if (labelcl_info->hwcl_magic != LABELCL_MAGIC)
-		return(-1);
-
-	if (info_name = NULL)
-		return(-1);
-
-	if (strlen(info_name) >= LABEL_LENGTH_MAX)
-		return(-1);
-
-	name = string_table_insert(&label_string_table, info_name);
-
-	num_labels = labelcl_info->num_labels;
-	new_label_list_size = sizeof(label_info_t) * (num_labels+1);
-
-	/*
-	 * Create a new label info area.
-	 */
-	if (new_label_list_size != 0) {
-		new_label_list = (label_info_t *) kmalloc(new_label_list_size, GFP_KERNEL);
-
-		if (new_label_list = NULL)
-			return(-1);
-	}
-
-	/*
-	 * At this point, we are committed to adding the labelled info, 
-	 * if there isn't already information there with the same name.
-	 */
-	old_label_list = labelcl_info->label_list;
-
-	/* 
-	 * Look for matching info name.
-	 */
-	for (i=0; i<num_labels; i++) {
-		if (!strcmp(info_name, old_label_list[i].name)) {
-			/* Not allowed to add duplicate labelled info names. */
-			kfree(new_label_list);
-			return(-1);
-		}
-		new_label_list[i] = old_label_list[i]; /* structure copy */
-	}
-
-	new_label_list[num_labels].name = name;
-	new_label_list[num_labels].desc = info_desc;
-	new_label_list[num_labels].info = info;
-
-	labelcl_info->num_labels = num_labels+1;
-	labelcl_info->label_list = new_label_list;
-
-	if (old_label_list != NULL)
-		kfree(old_label_list);
-
-	return(0);
-}
-
-/*
- * labelcl_info_remove_LBL - Remove a label entry.
- */
-int
-labelcl_info_remove_LBL(vertex_hdl_t de,
-			 char *info_name,
-			 arb_info_desc_t *info_desc,
-			 arbitrary_info_t *info)
-{
-	labelcl_info_t	*labelcl_info = NULL;
-	int num_labels;
-	int new_label_list_size;
-	label_info_t *old_label_list, *new_label_list = NULL;
-	arb_info_desc_t label_desc_found;
-	arbitrary_info_t label_info_found;
-	int i;
-
-	if (de = NULL)
-		return(-1);
-
-	labelcl_info = devfs_get_info(de);
-	if (labelcl_info = NULL)
-		return(-1);
-
-	if (labelcl_info->hwcl_magic != LABELCL_MAGIC)
-		return(-1);
-
-	num_labels = labelcl_info->num_labels;
-	if (num_labels = 0) {
-		return(-1);
-	}
-
-	/*
-	 * Create a new info area.
-	 */
-	new_label_list_size = sizeof(label_info_t) * (num_labels-1);
-	if (new_label_list_size) {
-		new_label_list = (label_info_t *) kmalloc(new_label_list_size, GFP_KERNEL);
-		if (new_label_list = NULL)
-			return(-1);
-	}
-
-	/*
-	 * At this point, we are committed to removing the labelled info, 
-	 * if it still exists.
-	 */
-	old_label_list = labelcl_info->label_list;
-
-	/* 
-	 * Find matching info name.
-	 */
-	for (i=0; i<num_labels; i++) {
-		if (!strcmp(info_name, old_label_list[i].name)) {
-			label_desc_found = old_label_list[i].desc;
-			label_info_found = old_label_list[i].info;
-			goto found;
-		}
-		if (i < num_labels-1) /* avoid walking off the end of the new vertex */
-			new_label_list[i] = old_label_list[i]; /* structure copy */
-	}
-
-	/* The named info doesn't exist. */
-	if (new_label_list)
-		kfree(new_label_list);
-
-	return(-1);
-
-found:
-	/* Finish up rest of labelled info */
-	for (i=i+1; i<num_labels; i++)
-		new_label_list[i-1] = old_label_list[i]; /* structure copy */
-
-	labelcl_info->num_labels = num_labels+1;
-	labelcl_info->label_list = new_label_list;
-
-	kfree(old_label_list);
-
-	if (info != NULL)
-		*info = label_info_found;
-
-	if (info_desc != NULL)
-		*info_desc = label_desc_found;
-
-	return(0);
-}
-
-
-/*
- * labelcl_info_replace_LBL - Replace an existing label entry with the 
- *	given new information.
- *
- *	Label entry must exist.
- */
-int
-labelcl_info_replace_LBL(vertex_hdl_t de,
-			char *info_name,
-			arb_info_desc_t info_desc,
-			arbitrary_info_t info,
-			arb_info_desc_t *old_info_desc,
-			arbitrary_info_t *old_info)
-{
-	labelcl_info_t	*labelcl_info = NULL;
-	int num_labels;
-	label_info_t *label_list;
-	int i;
-
-	if (de = NULL)
-		return(-1);
-
-	labelcl_info = devfs_get_info(de);
-	if (labelcl_info = NULL)
-		return(-1);
-
-	if (labelcl_info->hwcl_magic != LABELCL_MAGIC)
-		return(-1);
-
-	num_labels = labelcl_info->num_labels;
-	if (num_labels = 0) {
-		return(-1);
-	}
-
-	if (info_name = NULL)
-		return(-1);
-
-	label_list = labelcl_info->label_list;
-
-	/* 
-	 * Verify that information under info_name already exists.
-	 */
-	for (i=0; i<num_labels; i++)
-		if (!strcmp(info_name, label_list[i].name)) {
-			if (old_info != NULL)
-				*old_info = label_list[i].info;
-
-			if (old_info_desc != NULL)
-				*old_info_desc = label_list[i].desc;
-
-			label_list[i].info = info;
-			label_list[i].desc = info_desc;
-
-			return(0);
-		}
-
-
-	return(-1);
-}
-
-/*
- * labelcl_info_get_LBL - Retrieve and return the information for the 
- *	given label entry.
- */
-int
-labelcl_info_get_LBL(vertex_hdl_t de,
-		      char *info_name,
-		      arb_info_desc_t *info_desc,
-		      arbitrary_info_t *info)
-{
-	labelcl_info_t	*labelcl_info = NULL;
-	int num_labels;
-	label_info_t *label_list;
-	int i;
-
-	if (de = NULL)
-		return(-1);
-
-	labelcl_info = devfs_get_info(de);
-	if (labelcl_info = NULL)
-		return(-1);
-
-	if (labelcl_info->hwcl_magic != LABELCL_MAGIC)
-		return(-1);
-
-	num_labels = labelcl_info->num_labels;
-	if (num_labels = 0) {
-		return(-1);
-	}
-
-	label_list = labelcl_info->label_list;
-
-	/* 
-	 * Find information under info_name.
-	 */
-	for (i=0; i<num_labels; i++)
-		if (!strcmp(info_name, label_list[i].name)) {
-			if (info != NULL)
-				*info = label_list[i].info;
-			if (info_desc != NULL)
-				*info_desc = label_list[i].desc;
-
-			return(0);
-		}
-
-	return(-1);
-}
-
-/*
- * labelcl_info_get_next_LBL - returns the next label entry on the list.
- */
-int
-labelcl_info_get_next_LBL(vertex_hdl_t de,
-			   char *buffer,
-			   arb_info_desc_t *info_descp,
-			   arbitrary_info_t *infop,
-			   labelcl_info_place_t *placeptr)
-{
-	labelcl_info_t	*labelcl_info = NULL;
-	uint which_info;
-	label_info_t *label_list;
-
-	if ((buffer = NULL) && (infop = NULL))
-		return(-1);
-
-	if (placeptr = NULL)
-		return(-1);
-
-	if (de = NULL)
-		return(-1);
-
-	labelcl_info = devfs_get_info(de);
-	if (labelcl_info = NULL)
-		return(-1);
-
-	if (labelcl_info->hwcl_magic != LABELCL_MAGIC)
-		return(-1);
-
-	which_info = *placeptr;
-
-	if (which_info >= labelcl_info->num_labels) {
-		return(-1);
-	}
-
-	label_list = (label_info_t *) labelcl_info->label_list;
-
-	if (buffer != NULL)
-		strcpy(buffer, label_list[which_info].name);
-
-	if (infop)
-		*infop = label_list[which_info].info;
-
-	if (info_descp)
-		*info_descp = label_list[which_info].desc;
-
-	*placeptr = which_info + 1;
-
-	return(0);
-}
-
-
-int
-labelcl_info_replace_IDX(vertex_hdl_t de,
-			int index,
-			arbitrary_info_t info,
-			arbitrary_info_t *old_info)
-{
-	arbitrary_info_t *info_list_IDX;
-	labelcl_info_t	*labelcl_info = NULL;
-
-	if (de = NULL) {
-		printk(KERN_ALERT "labelcl: NULL devfs handle given.\n");
-		return(-1);
-	}
-
-	labelcl_info = devfs_get_info(de);
-	if (labelcl_info = NULL) {
-		printk(KERN_ALERT "labelcl: Entry does not have info pointer.\n");
-		return(-1);
-	}
-
-	if (labelcl_info->hwcl_magic != LABELCL_MAGIC)
-		return(-1);
-
-	if ( (index < 0) || (index >= HWGRAPH_NUM_INDEX_INFO) )
-		return(-1);
-
-	/*
-	 * Replace information at the appropriate index in this vertex with 
-	 * the new info.
-	 */
-	info_list_IDX = labelcl_info->IDX_list;
-	if (old_info != NULL)
-		*old_info = info_list_IDX[index];
-	info_list_IDX[index] = info;
-
-	return(0);
-
-}
-
-/*
- * labelcl_info_connectpt_set - Sets the connectpt.
- */
-int
-labelcl_info_connectpt_set(struct devfs_entry *de,
-			  struct devfs_entry *connect_de)
-{
-	arbitrary_info_t old_info;
-	int	rv;
-
-	rv = labelcl_info_replace_IDX(de, HWGRAPH_CONNECTPT, 
-		(arbitrary_info_t) connect_de, &old_info);
-
-	if (rv) {
-		return(rv);
-	}
-
-	return(0);
-}
-
-
-/*
- * labelcl_info_get_IDX - Returns the information pointed at by index.
- *
- */
-int
-labelcl_info_get_IDX(vertex_hdl_t de,
-			int index,
-			arbitrary_info_t *info)
-{
-	arbitrary_info_t *info_list_IDX;
-	labelcl_info_t	*labelcl_info = NULL;
-
-	if (de = NULL)
-		return(-1);
-
-	labelcl_info = devfs_get_info(de);
-	if (labelcl_info = NULL)
-		return(-1);
-
-	if (labelcl_info->hwcl_magic != LABELCL_MAGIC)
-		return(-1);
-
-	if ( (index < 0) || (index >= HWGRAPH_NUM_INDEX_INFO) )
-		return(-1);
-
-	/*
-	 * Return information at the appropriate index in this vertex.
-	 */
-	info_list_IDX = labelcl_info->IDX_list;
-	if (info != NULL)
-		*info = info_list_IDX[index];
-
-	return(0);
-}
-
-/*
- * labelcl_info_connectpt_get - Retrieve the connect point for a device entry.
- */
-struct devfs_entry *
-labelcl_info_connectpt_get(struct devfs_entry *de)
-{
-	int rv;
-	arbitrary_info_t info;
-
-	rv = labelcl_info_get_IDX(de, HWGRAPH_CONNECTPT, &info);
-	if (rv)
-		return(NULL);
-
-	return((struct devfs_entry *)info);
-}
diff -Nru a/arch/ia64/sn/io/hwgfs/hwgfs.h b/arch/ia64/sn/io/hwgfs/hwgfs.h
--- a/arch/ia64/sn/io/hwgfs/hwgfs.h	Mon May 19 12:42:08 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,23 +0,0 @@
-
-typedef struct dentry *hwgfs_handle_t;
-
-extern hwgfs_handle_t hwgfs_register(hwgfs_handle_t dir, const char *name,
-				     unsigned int flags,
-				     unsigned int major, unsigned int minor,
-				     umode_t mode, void *ops, void *info);
-extern int hwgfs_mk_symlink(hwgfs_handle_t dir, const char *name,
-			     unsigned int flags, const char *link,
-			     hwgfs_handle_t *handle, void *info);
-extern hwgfs_handle_t hwgfs_mk_dir(hwgfs_handle_t dir, const char *name,
-				    void *info);
-extern void hwgfs_unregister(hwgfs_handle_t de);
-
-extern hwgfs_handle_t hwgfs_find_handle(hwgfs_handle_t dir, const char *name,
-					unsigned int major,unsigned int minor,
-					char type, int traverse_symlinks);
-extern hwgfs_handle_t hwgfs_get_parent(hwgfs_handle_t de);
-extern int hwgfs_generate_path(hwgfs_handle_t de, char *path, int buflen);
-
-extern void *hwgfs_get_info(hwgfs_handle_t de);
-extern int hwgfs_set_info(hwgfs_handle_t de, void *info);
-
diff -Nru a/arch/ia64/sn/io/sn2/pcibr/Makefile b/arch/ia64/sn/io/sn2/pcibr/Makefile
--- a/arch/ia64/sn/io/sn2/pcibr/Makefile	Mon May 19 12:42:08 2003
+++ b/arch/ia64/sn/io/sn2/pcibr/Makefile	Mon May 19 12:42:08 2003
@@ -11,7 +11,5 @@
 
 EXTRA_CFLAGS    := -DLITTLE_ENDIAN -DSHUB_SWAP_WAR
 
-obj-$(CONFIG_IA64_SGI_SN2)	+= pcibr_ate.o pcibr_config.o \
-                                   pcibr_dvr.o pcibr_hints.o \
-				   pcibr_intr.o pcibr_rrb.o pcibr_slot.o \
-				   pcibr_error.o
+obj-y += pcibr_ate.o pcibr_config.o pcibr_dvr.o pcibr_hints.o pcibr_intr.o pcibr_rrb.o \
+	 pcibr_slot.o pcibr_error.o
diff -Nru a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
--- a/arch/ia64/sn/kernel/Makefile	Mon May 19 12:42:08 2003
+++ b/arch/ia64/sn/kernel/Makefile	Mon May 19 12:42:08 2003
@@ -9,8 +9,7 @@
 
 EXTRA_CFLAGS := -DLITTLE_ENDIAN
 
-obj-y				:= probe.o setup.o sv.o bte.o irq.o mca.o
+obj-y				:= probe.o setup.o sv.o bte.o irq.o mca.o sn2/
 
-obj-$(CONFIG_IA64_SGI_SN2)      += sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
 obj-$(CONFIG_MODULES)           += sn_ksyms.o
diff -Nru a/include/asm-ia64/sn/hwgfs.h b/include/asm-ia64/sn/hwgfs.h
--- a/include/asm-ia64/sn/hwgfs.h	Mon May 19 12:42:08 2003
+++ b/include/asm-ia64/sn/hwgfs.h	Mon May 19 12:42:08 2003
@@ -10,8 +10,6 @@
  * Copyright (C) 1992 - 1997, 2000-2003 Silicon Graphics, Inc. All rights reserved.
  */
 
-#define DEVFS_FL_AUTO_DEVNUM 0
-
 typedef struct dentry *hwgfs_handle_t;
 
 extern hwgfs_handle_t hwgfs_register(hwgfs_handle_t dir, const char *name,
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1094  -> 1.1095 
#	arch/ia64/sn/io/sn2/ml_iograph.c	1.2     -> 1.3    
#	arch/ia64/sn/io/sn2/ml_SN_init.c	1.2     -> 1.3    
#	include/asm-ia64/sn/sn2/shubio.h	1.3     -> 1.4    
#	arch/ia64/sn/io/drivers/hubdev.c	1.5     ->         (deleted)      
#	arch/ia64/sn/io/drivers/Makefile	1.1     -> 1.2    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/19	jbarnes@dec.engr.sgi.com	1.1095
# remove unneeded hubdev stuff
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/drivers/Makefile b/arch/ia64/sn/io/drivers/Makefile
--- a/arch/ia64/sn/io/drivers/Makefile	Mon May 19 12:42:20 2003
+++ b/arch/ia64/sn/io/drivers/Makefile	Mon May 19 12:42:20 2003
@@ -9,6 +9,6 @@
 
 EXTRA_CFLAGS    := -DLITTLE_ENDIAN
 
-obj-y				+= hubdev.o ioconfig_bus.o ifconfig_net.o
+obj-y				+= ioconfig_bus.o ifconfig_net.o
 
 obj-$(CONFIG_PCIBA)		+= pciba.o
diff -Nru a/arch/ia64/sn/io/drivers/hubdev.c b/arch/ia64/sn/io/drivers/hubdev.c
--- a/arch/ia64/sn/io/drivers/hubdev.c	Mon May 19 12:42:20 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,100 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992-1997,2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-
-#include <linux/config.h>
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <asm/sn/sgi.h>
-#include <asm/sn/io.h>
-#include <asm/sn/iograph.h>
-#include <asm/sn/sn_private.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/labelcl.h>
-
-struct hubdev_callout {
-        int (*attach_method)(vertex_hdl_t);
-        struct hubdev_callout *fp;
-};
-
-typedef struct hubdev_callout hubdev_callout_t;
-
-mutex_t hubdev_callout_mutex;
-static hubdev_callout_t *hubdev_callout_list;
-
-void
-hubdev_init(void)
-{
-	mutex_init(&hubdev_callout_mutex);
-        hubdev_callout_list = NULL;
-}
-        
-void
-hubdev_register(int (*attach_method)(vertex_hdl_t))
-{
-        hubdev_callout_t *callout;
-        
-        ASSERT(attach_method);
-
-        callout =  (hubdev_callout_t *)snia_kmem_zalloc(sizeof(hubdev_callout_t), KM_SLEEP);
-        ASSERT(callout);
-        
-	mutex_lock(&hubdev_callout_mutex);
-        /*
-         * Insert at the end of the list
-         */
-        callout->fp = hubdev_callout_list;
-        hubdev_callout_list = callout;
-        callout->attach_method = attach_method;
-	mutex_unlock(&hubdev_callout_mutex);
-}
-
-int
-hubdev_unregister(int (*attach_method)(vertex_hdl_t))
-{
-        hubdev_callout_t **p;
-        
-        ASSERT(attach_method);
-   
-	mutex_lock(&hubdev_callout_mutex);
-        /*
-         * Remove registry element containing attach_method
-         */
-        for (p = &hubdev_callout_list; *p != NULL; p = &(*p)->fp) {
-                if ((*p)->attach_method = attach_method) {
-                        hubdev_callout_t* victim = *p;
-                        *p = (*p)->fp;
-                        kfree(victim);
-                        mutex_unlock(&hubdev_callout_mutex);
-                        return (0);
-                }
-        }
-        mutex_unlock(&hubdev_callout_mutex);
-        return (ENOENT);
-}
-
-
-int
-hubdev_docallouts(vertex_hdl_t hub)
-{
-        hubdev_callout_t *p;
-        int errcode;
-
-	mutex_lock(&hubdev_callout_mutex);
-        
-        for (p = hubdev_callout_list; p != NULL; p = p->fp) {
-                ASSERT(p->attach_method);
-                errcode = (*p->attach_method)(hub);
-                if (errcode != 0) {
-			mutex_unlock(&hubdev_callout_mutex);
-                        return (errcode);
-                }
-        }
-        mutex_unlock(&hubdev_callout_mutex);
-        return (0);
-}
diff -Nru a/arch/ia64/sn/io/sn2/ml_SN_init.c b/arch/ia64/sn/io/sn2/ml_SN_init.c
--- a/arch/ia64/sn/io/sn2/ml_SN_init.c	Mon May 19 12:42:20 2003
+++ b/arch/ia64/sn/io/sn2/ml_SN_init.c	Mon May 19 12:42:20 2003
@@ -62,9 +62,6 @@
 
 	/* early initialization of iograph */
 	iograph_early_init();
-
-	/* Initialize Hub Pseudodriver Management */
-	hubdev_init();
 }
 
 
diff -Nru a/arch/ia64/sn/io/sn2/ml_iograph.c b/arch/ia64/sn/io/sn2/ml_iograph.c
--- a/arch/ia64/sn/io/sn2/ml_iograph.c	Mon May 19 12:42:20 2003
+++ b/arch/ia64/sn/io/sn2/ml_iograph.c	Mon May 19 12:42:20 2003
@@ -655,7 +655,6 @@
 	struct semaphore *peer_sema = 0;
 	uint32_t	widget_partnum;
 	cpu_cookie_t	c = 0;
-	extern int hubdev_docallouts(vertex_hdl_t);
 
 	npdap = NODEPDA(cnodeid);
 
@@ -670,8 +669,6 @@
 	DBG("io_init_node: Initialize IO for cnode %d hubv(node) 0x%p npdap 0x%p\n", cnodeid, hubv, npdap);
 
 	ASSERT(hubv != GRAPH_VERTEX_NONE);
-
-	hubdev_docallouts(hubv);
 
 	/*
 	 * Read mfg info on this hub
diff -Nru a/include/asm-ia64/sn/sn2/shubio.h b/include/asm-ia64/sn/sn2/shubio.h
--- a/include/asm-ia64/sn/sn2/shubio.h	Mon May 19 12:42:20 2003
+++ b/include/asm-ia64/sn/sn2/shubio.h	Mon May 19 12:42:20 2003
@@ -3629,15 +3629,6 @@
 extern int hub_error_devenable(vertex_hdl_t, int, int);
 extern int  hub_dma_enabled(vertex_hdl_t);
 
-/* hubdev */
-extern void hubdev_init(void);
-extern void hubdev_register(int (*attach_method)(vertex_hdl_t));
-extern int hubdev_unregister(int (*attach_method)(vertex_hdl_t));
-extern int hubdev_docallouts(vertex_hdl_t hub);
-
-extern caddr_t hubdev_prombase_get(vertex_hdl_t hub);
-extern cnodeid_t hubdev_cnodeid_get(vertex_hdl_t hub);
-
 #endif /* __ASSEMBLY__ */
 #endif /* _KERNEL */
 #endif /* _ASM_IA64_SN_SN2_SHUBIO_H */
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1095  -> 1.1096 
#	arch/ia64/sn/io/drivers/ifconfig_net.c	1.5     -> 1.6    
#	arch/ia64/sn/io/sn2/xbow.c	1.2     -> 1.3    
#	arch/ia64/sn/io/hwgfs/hcl.c	1.1     -> 1.2    
#	arch/ia64/sn/io/sn2/klgraph.c	1.2     -> 1.3    
#	arch/ia64/sn/io/drivers/ioconfig_bus.c	1.2     -> 1.3    
#	arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	1.8     -> 1.9    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/19	jbarnes@dec.engr.sgi.com	1.1096
# DEVFS_FL_AUTO_DEVNUM removal
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/drivers/ifconfig_net.c b/arch/ia64/sn/io/drivers/ifconfig_net.c
--- a/arch/ia64/sn/io/drivers/ifconfig_net.c	Mon May 19 12:42:35 2003
+++ b/arch/ia64/sn/io/drivers/ifconfig_net.c	Mon May 19 12:42:35 2003
@@ -284,7 +284,7 @@
 {
 	ifconfig_net_handle = NULL;
 	ifconfig_net_handle = hwgraph_register(hwgraph_root, ".ifconfig_net",
-			0, DEVFS_FL_AUTO_DEVNUM,
+ 		        0, 0,
 			0, 0,
 			S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0,
 			&ifconfig_net_fops, NULL);
diff -Nru a/arch/ia64/sn/io/drivers/ioconfig_bus.c b/arch/ia64/sn/io/drivers/ioconfig_bus.c
--- a/arch/ia64/sn/io/drivers/ioconfig_bus.c	Mon May 19 12:42:35 2003
+++ b/arch/ia64/sn/io/drivers/ioconfig_bus.c	Mon May 19 12:42:35 2003
@@ -361,7 +361,7 @@
 {
 	ioconfig_bus_handle = NULL;
 	ioconfig_bus_handle = hwgraph_register(hwgraph_root, ".ioconfig_bus",
-			0, DEVFS_FL_AUTO_DEVNUM,
+		        0, 0,
 			0, 0,
 			S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0,
 			&ioconfig_bus_fops, NULL);
diff -Nru a/arch/ia64/sn/io/hwgfs/hcl.c b/arch/ia64/sn/io/hwgfs/hcl.c
--- a/arch/ia64/sn/io/hwgfs/hcl.c	Mon May 19 12:42:35 2003
+++ b/arch/ia64/sn/io/hwgfs/hcl.c	Mon May 19 12:42:35 2003
@@ -164,7 +164,7 @@
 	 *
 	 */
 	hcl_handle = hwgraph_register(hwgraph_root, ".hcl",
-			0, DEVFS_FL_AUTO_DEVNUM,
+		        0, 0,
 			0, 0,
 			S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0,
 			&hcl_fops, NULL);
diff -Nru a/arch/ia64/sn/io/sn2/klgraph.c b/arch/ia64/sn/io/sn2/klgraph.c
--- a/arch/ia64/sn/io/sn2/klgraph.c	Mon May 19 12:42:35 2003
+++ b/arch/ia64/sn/io/sn2/klgraph.c	Mon May 19 12:42:35 2003
@@ -216,7 +216,7 @@
 	(void) hwgraph_path_add(node_vertex, EDGE_LBL_HUB, &myhubv);
 	rc = device_master_set(myhubv, node_vertex);
 	hub_mon = hwgraph_register(myhubv, EDGE_LBL_PERFMON,
-		0, DEVFS_FL_AUTO_DEVNUM,
+		0, 0,
 		0, 0,
 		S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0,
 		&shub_mon_fops, (void *)(long)cnode);
diff -Nru a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c
--- a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Mon May 19 12:42:35 2003
+++ b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Mon May 19 12:42:35 2003
@@ -1215,7 +1215,7 @@
 
     ctlr_vhdl = NULL;
     ctlr_vhdl = hwgraph_register(pcibr_vhdl, EDGE_LBL_CONTROLLER, 0, 
-                DEVFS_FL_AUTO_DEVNUM, 0, 0,
+                0, 0, 0,
 		S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0, 
 		(struct file_operations *)&pcibr_fops, (void *)pcibr_vhdl);
     ASSERT(ctlr_vhdl != NULL);
diff -Nru a/arch/ia64/sn/io/sn2/xbow.c b/arch/ia64/sn/io/sn2/xbow.c
--- a/arch/ia64/sn/io/sn2/xbow.c	Mon May 19 12:42:35 2003
+++ b/arch/ia64/sn/io/sn2/xbow.c	Mon May 19 12:42:35 2003
@@ -289,7 +289,7 @@
      */
     vhdl = NULL;
     vhdl = hwgraph_register(conn, EDGE_LBL_XBOW, 0,
-	   DEVFS_FL_AUTO_DEVNUM, 0, 0,
+	   0, 0, 0,
 	   S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0,
 	   (struct file_operations *)&xbow_fops, (void *)xbow);
     if (!vhdl) {
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1096  -> 1.1097 
#	arch/ia64/sn/io/sn2/l1.c	1.2     -> 1.3    
#	arch/ia64/sn/io/sn2/shuberror.c	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/19	jbarnes@dec.engr.sgi.com	1.1097
# fixup warnings (irqreturn_t and interrupt.h)
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/sn2/l1.c b/arch/ia64/sn/io/sn2/l1.c
--- a/arch/ia64/sn/io/sn2/l1.c	Mon May 19 12:42:56 2003
+++ b/arch/ia64/sn/io/sn2/l1.c	Mon May 19 12:42:56 2003
@@ -29,6 +29,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/delay.h>
+#include <linux/interrupt.h>
 #include <asm/io.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/io.h>
diff -Nru a/arch/ia64/sn/io/sn2/shuberror.c b/arch/ia64/sn/io/sn2/shuberror.c
--- a/arch/ia64/sn/io/sn2/shuberror.c	Mon May 19 12:42:56 2003
+++ b/arch/ia64/sn/io/sn2/shuberror.c	Mon May 19 12:42:56 2003
@@ -35,7 +35,7 @@
 
 extern void hubni_eint_init(cnodeid_t cnode);
 extern void hubii_eint_init(cnodeid_t cnode);
-extern void hubii_eint_handler (int irq, void *arg, struct pt_regs *ep);
+extern irqreturn_t hubii_eint_handler (int irq, void *arg, struct pt_regs *ep);
 int hubiio_crb_error_handler(vertex_hdl_t hub_v, hubinfo_t hinfo);
 int hubiio_prb_error_handler(vertex_hdl_t hub_v, hubinfo_t hinfo);
 extern void bte_crb_error_handler(vertex_hdl_t hub_v, int btenum, int crbnum, ioerror_t *ioe, int bteop);
@@ -168,7 +168,7 @@
 
 
 /*ARGSUSED*/
-void
+irqreturn_t
 hubii_eint_handler (int irq, void *arg, struct pt_regs *ep)
 {
     vertex_hdl_t	hub_v;
@@ -263,6 +263,8 @@
      */
     (void)hubiio_crb_error_handler(hub_v, hinfo);
     (void)hubiio_prb_error_handler(hub_v, hinfo);
+
+    return IRQ_HANDLED;
 }
 
 /*

