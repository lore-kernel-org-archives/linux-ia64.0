From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 20 Jun 2003 00:13:02 +0000
Subject: [PATCH] sn2 updates for 2.5.72
MIME-Version: 1
Content-Type: multipart/mixed; boundary="mYCpIKhGyMATD0i+"
Message-Id: <marc-linux-ia64-105606803327236@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Here's a patch against your bk tree that keeps things building for sn2
(and working with the discontig patch applied).

 arch/ia64/sn/io/drivers/ifconfig_net.c |  298 ---------------------------------
 arch/ia64/sn/io/drivers/Makefile     |    2

 Remove ifconfig_net.c.  It's not necessary for 2.5.

 arch/ia64/sn/io/hwgfs/hcl.c          |    4
 arch/ia64/sn/io/machvec/pci_dma.c    |    2

 Fix build errors and warnings.

Thanks,
Jesse

--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="misc-sn2-fixes-2.5.72-ia64-bk.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1341  -> 1.1342 
#	arch/ia64/sn/io/machvec/pci_dma.c	1.10    -> 1.11   
#	arch/ia64/sn/io/drivers/ifconfig_net.c	1.6     ->         (deleted)      
#	arch/ia64/sn/io/hwgfs/hcl.c	1.3     -> 1.4    
#	arch/ia64/sn/io/drivers/Makefile	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/19	jbarnes@tomahawk.engr.sgi.com	1.1342
# remove persistent net device naming and remove devfs flag
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/drivers/Makefile b/arch/ia64/sn/io/drivers/Makefile
--- a/arch/ia64/sn/io/drivers/Makefile	Thu Jun 19 17:04:11 2003
+++ b/arch/ia64/sn/io/drivers/Makefile	Thu Jun 19 17:04:11 2003
@@ -9,4 +9,4 @@
 
 EXTRA_CFLAGS    := -DLITTLE_ENDIAN
 
-obj-y				+= ioconfig_bus.o ifconfig_net.o
+obj-y				+= ioconfig_bus.o
diff -Nru a/arch/ia64/sn/io/drivers/ifconfig_net.c b/arch/ia64/sn/io/drivers/ifconfig_net.c
--- a/arch/ia64/sn/io/drivers/ifconfig_net.c	Thu Jun 19 17:04:11 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,298 +0,0 @@
-/* $Id: ifconfig_net.c,v 1.1 2002/02/28 17:31:25 marcelo Exp $
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- *  ifconfig_net - SGI's Persistent Network Device names.
- *
- * Copyright (C) 1992-1997, 2000-2003 Silicon Graphics, Inc.  All rights reserved.
- */
-
-#include <linux/types.h>
-#include <linux/config.h>
-#include <linux/slab.h>
-#include <linux/ctype.h>
-#include <linux/module.h>
-#include <linux/init.h>
-
-#include <linux/pci.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-
-#include <asm/sn/sgi.h>
-#include <linux/devfs_fs.h>
-#include <linux/devfs_fs_kernel.h>
-#include <asm/io.h>
-#include <asm/sn/iograph.h>
-#include <asm/sn/invent.h>
-#include <asm/sn/hcl.h>
-#include <asm/sn/labelcl.h>
-#include <asm/sn/ifconfig_net.h>
-
-#define SGI_IFCONFIG_NET "SGI-PERSISTENT NETWORK DEVICE NAME DRIVER"
-#define SGI_IFCONFIG_NET_VERSION "1.0"
-
-/*
- * Some Global definitions.
- */
-static devfs_handle_t ifconfig_net_handle;
-static unsigned long ifconfig_net_debug;
-
-/*
- * ifconfig_net_open - Opens the special device node "/devhw/.ifconfig_net".
- */
-static int ifconfig_net_open(struct inode * inode, struct file * filp)
-{
-	if (ifconfig_net_debug) {
-        	printk("ifconfig_net_open called.\n");
-	}
-
-        return(0);
-
-}
-
-/*
- * ifconfig_net_close - Closes the special device node "/devhw/.ifconfig_net".
- */
-static int ifconfig_net_close(struct inode * inode, struct file * filp)
-{
-
-	if (ifconfig_net_debug) {
-        	printk("ifconfig_net_close called.\n");
-	}
-
-        return(0);
-}
-
-/*
- * assign_ifname - Assign the next available interface name from the persistent list.
- */
-void
-assign_ifname(struct net_device *dev,
-		  struct ifname_num *ifname_num)
-
-{
-
-	/*
-	 * Handle eth devices.
-	 */
-        if ( (memcmp(dev->name, "eth", 3) == 0) ) {
-		if (ifname_num->next_eth != -1) {
-			/*
-			 * Assign it the next available eth interface number. 
-			 */
-			memset(dev->name, 0, strlen(dev->name));
-			sprintf(dev->name, "eth%d", (int)ifname_num->next_eth);
-			ifname_num->next_eth++;
-		} 
-
-                return;
-        }
-
-	/*
-	 * Handle fddi devices.
-	 */
-	if ( (memcmp(dev->name, "fddi", 4) == 0) ) {
-		if (ifname_num->next_fddi != -1) {
-			/*
-			 * Assign it the next available fddi interface number.
-			 */
-			memset(dev->name, 0, strlen(dev->name));
-			sprintf(dev->name, "fddi%d", (int)ifname_num->next_fddi);
-			ifname_num->next_fddi++;
-		}
-
-		return;
-	}
-
-	/*
-	 * Handle hip devices.
-	 */
-	if ( (memcmp(dev->name, "hip", 3) == 0) ) {
-		if (ifname_num->next_hip != -1) {
-			/*
-			 * Assign it the next available hip interface number.
-			 */
-			memset(dev->name, 0, strlen(dev->name));
-			sprintf(dev->name, "hip%d", (int)ifname_num->next_hip);
-			ifname_num->next_hip++;
-		}
-
-		return;
-	}
-
-	/*
-	 * Handle tr devices.
-	 */
-	if ( (memcmp(dev->name, "tr", 2) == 0) ) {
-		if (ifname_num->next_tr != -1) {
-			/*
-			 * Assign it the next available tr interface number.
-			 */
-			memset(dev->name, 0, strlen(dev->name));
-			sprintf(dev->name, "tr%d", (int)ifname_num->next_tr);
-			ifname_num->next_tr++;
-		}
-
-		return;
-	}
-
-	/*
-	 * Handle fc devices.
-	 */
-	if ( (memcmp(dev->name, "fc", 2) == 0) ) {
-		if (ifname_num->next_fc != -1) {
-			/*
-			 * Assign it the next available fc interface number.
-			 */
-			memset(dev->name, 0, strlen(dev->name));
-			sprintf(dev->name, "fc%d", (int)ifname_num->next_fc);
-			ifname_num->next_fc++;
-		}
-
-		return;
-	}
-}
-
-/*
- * find_persistent_ifname: Returns the entry that was seen in previous boot.
- */
-struct ifname_MAC *
-find_persistent_ifname(struct net_device *dev,
-	struct ifname_MAC *ifname_MAC)
-
-{
-
-	while (ifname_MAC->addr_len) {
-		if (memcmp(dev->dev_addr, ifname_MAC->dev_addr, dev->addr_len) == 0)
-			return(ifname_MAC);
-
-		ifname_MAC++;
-	}
-
-	return(NULL);
-}
-
-/*
- * ifconfig_net_ioctl: ifconfig_net driver ioctl interface.
- */
-static int ifconfig_net_ioctl(struct inode * inode, struct file * file,
-        unsigned int cmd, unsigned long arg)
-{
-
-	extern struct net_device *__dev_get_by_name(const char *);
-#ifdef CONFIG_NET
-	struct net_device *dev;
-	struct ifname_MAC *found;
-	char temp[64];
-#endif
-	struct ifname_MAC *ifname_MAC;
-	struct ifname_MAC *new_devices, *temp_new_devices;
-	struct ifname_num *ifname_num;
-	unsigned long size;
-
-
-	if (ifconfig_net_debug) {
-		printk("HCL: hcl_ioctl called.\n");
-	}
-
-	/*
-	 * Read in the header and see how big of a buffer we really need to 
-	 * allocate.
-	 */
-	ifname_num = (struct ifname_num *) kmalloc(sizeof(struct ifname_num), 
-			GFP_KERNEL);
-	copy_from_user( ifname_num, (char *) arg, sizeof(struct ifname_num));
-	size = ifname_num->size;
-	kfree(ifname_num);
-	ifname_num = (struct ifname_num *) kmalloc(size, GFP_KERNEL);
-	ifname_MAC = (struct ifname_MAC *) ((char *)ifname_num + (sizeof(struct ifname_num)) );
-
-	copy_from_user( ifname_num, (char *) arg, size);
-	new_devices =  kmalloc(size - sizeof(struct ifname_num), GFP_KERNEL);
-	temp_new_devices = new_devices;
-
-	memset(new_devices, 0, size - sizeof(struct ifname_num));
-
-#ifdef CONFIG_NET
-	/*
-	 * Go through the net device entries and make them persistent!
-	 */
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
-		/*
-		 * Skip NULL entries or "lo"
-		 */
-		if ( (dev->addr_len == 0) || ( !strncmp(dev->name, "lo", strlen(dev->name))) ){
-			continue;
-		}
-
-		/*
-		 * See if we have a persistent interface name for this device.
-		 */
-		found = NULL;
-		found = find_persistent_ifname(dev, ifname_MAC);
-		if (found) {
-			strcpy(dev->name, found->name);
-		} else {
-			/* Never seen this before .. */
-			assign_ifname(dev, ifname_num);
-
-			/* 
-			 * Save the information for the next boot.
-			 */
- 			sprintf(temp,"%s %02x:%02x:%02x:%02x:%02x:%02x\n", dev->name,
-				dev->dev_addr[0],  dev->dev_addr[1],  dev->dev_addr[2],
-				dev->dev_addr[3],  dev->dev_addr[4],  dev->dev_addr[5]);
-			strcpy(temp_new_devices->name, dev->name);
-			temp_new_devices->addr_len = dev->addr_len;
-			memcpy(temp_new_devices->dev_addr, dev->dev_addr, dev->addr_len);
-			temp_new_devices++;
-		}
-		
-	}
-#endif
-
-	/*
-	 * Copy back to the User Buffer area any new devices encountered.
-	 */
-	copy_to_user((char *)arg + (sizeof(struct ifname_num)), new_devices, 
-			size - sizeof(struct ifname_num));
-
-	return(0);
-
-}
-
-struct file_operations ifconfig_net_fops = {
-	ioctl:ifconfig_net_ioctl,	/* ioctl */
-	open:ifconfig_net_open,		/* open */
-	release:ifconfig_net_close	/* release */
-};
-
-
-/*
- * init_ifconfig_net() - Boot time initialization.  Ensure that it is called 
- *	after devfs has been initialized.
- *
- */
-#ifdef MODULE
-int init_module (void)
-#else
-int __init init_ifconfig_net(void)
-#endif
-{
-	ifconfig_net_handle = NULL;
-	ifconfig_net_handle = hwgraph_register(hwgraph_root, ".ifconfig_net",
- 		        0, 0,
-			0, 0,
-			S_IFCHR | S_IRUSR | S_IWUSR | S_IRGRP, 0, 0,
-			&ifconfig_net_fops, NULL);
-
-	if (ifconfig_net_handle == NULL) {
-		panic("Unable to create SGI PERSISTENT NETWORK DEVICE Name Driver.\n");
-	}
-
-	return(0);
-
-}
diff -Nru a/arch/ia64/sn/io/hwgfs/hcl.c b/arch/ia64/sn/io/hwgfs/hcl.c
--- a/arch/ia64/sn/io/hwgfs/hcl.c	Thu Jun 19 17:04:11 2003
+++ b/arch/ia64/sn/io/hwgfs/hcl.c	Thu Jun 19 17:04:11 2003
@@ -128,7 +128,6 @@
 {
 	extern void string_table_init(struct string_table *);
 	extern struct string_table label_string_table;
-	extern int init_ifconfig_net(void);
 	extern int init_ioconfig_bus(void);
 	extern int init_hwgfs_fs(void);
 	int rv = 0;
@@ -183,7 +182,6 @@
 	 * Initialize the ifconfgi_net driver that does network devices 
 	 * Persistent Naming.
 	 */
-	init_ifconfig_net();
 	init_ioconfig_bus();
 
 	return(0);
@@ -557,7 +555,7 @@
 	 * In this case the vertex was previous created with a REAL pathname.
 	 */
 	rv = hwgfs_mk_symlink (from, (const char *)name,
-			       DEVFS_FL_DEFAULT, link,
+			       0, link,
 			       &handle, NULL);
 	kfree(path);
 	kfree(link);
diff -Nru a/arch/ia64/sn/io/machvec/pci_dma.c b/arch/ia64/sn/io/machvec/pci_dma.c
--- a/arch/ia64/sn/io/machvec/pci_dma.c	Thu Jun 19 17:04:11 2003
+++ b/arch/ia64/sn/io/machvec/pci_dma.c	Thu Jun 19 17:04:11 2003
@@ -587,7 +587,7 @@
 {
 	BUG_ON(dev->bus != &pci_bus_type);
 
-	if (!sn_dma_supported(to_pci_dev(dev), dma_mask))
+	if (!sn_dma_supported(dev, dma_mask))
 		return 0;
 
 	dev->dma_mask = dma_mask;

--mYCpIKhGyMATD0i+--
