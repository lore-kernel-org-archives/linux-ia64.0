From: Martin Wilck <martin@tropos.de>
Date: Wed, 06 Jun 2001 12:01:16 +0000
Subject: [Linux-ia64] Patch: /dev/guid support
Message-Id: <marc-linux-ia64-105590693005689@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

here is a small patch I suggest for Linux/IA64. I am re-sending it because
I think the mail was lost when the list server was down last week.

The patch makes the kernel aware of the GUIDs of hard disks and partitions and
thereby allows to e.g. mount volumes by GUID rather than
driver/bus/target/lun, so that volumes can be uniquely identified
even if the sequence of controllers or disks on a controller changes.

The patch relies heavily on devfs and the EFI/GPT code in the IA64 kernel.
It is against 2.4.4 with David's IA64 patch (08/05/2001).

GUIDs are only recognized on disks with an EFI GPT partition table.

The GUIDs appear as soft links in /dev/guid, like this:

$ ls -l /dev/guid
total 0
25fb7980-1dd2-1000-8b55-00d0b7c7f993 -> ../scsi/host0/bus0/target0/lun0/disc
lr-xr-xr-x    1 root     root           37 Jan  1  1970
272ca680-1dd2-1000-b7ef-00d0b7c7f993 -> ../scsi/host0/bus0/target0/lun0/part1
lr-xr-xr-x    1 root     root           37 Jan  1  1970
87821d20-f3fa-2444-96b9-7ad4423d337b -> ../scsi/host0/bus0/target0/lun0/part2
lr-xr-xr-x    1 root     root           36 Jan  1  1970
a1050a55-2b64-244a-924d-8f6b9ea01931 -> ../scsi/host1/bus0/target3/lun0/disc
lr-xr-xr-x    1 root     root           37 Jan  1  1970
e3f2fd2f-604c-614e-b135-d74f3b5f9277 -> ../scsi/host0/bus0/target0/lun0/part3
lr-xr-xr-x    1 root     root           37 Jan  1  1970
e853dbd1-6dc3-1f4d-8e23-09311b60dd9e -> ../scsi/host1/bus0/target3/lun0/part1

As you can see, there are links for the entire disks as well as the
partitions.

On my system, links are correctly deleted / replaced if a disk is
repartitioned.

Notes:
 - The most heavy change in kernel internals is the inclusion of
   a efi_guid_t* field in the hd_struct structure.

 - I have copied Matt's uuid_unparse() function to fs/partition/check.c.
   I assume it would have been better to export Matt's function and have
   it only once in the code, but I couldn't figure out in which subtree it
   would then best belong.

- The mount man page states that mount already supports mounting by 
    UUID through information in /proc/partitions, but there is currently no
    UUID information in that file as far as I can see. I thought about adding
    it, but I think that the read function for that file must first be altered
    to support > 1 page output, since the file may become pretty big
    with UUIDs included.

Any improvements/suggestions/fixes greatly appreciated.

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113



diff -ru -x *.o -x.* -x*.rej -x*~ linux-2.4.4-orig/Documentation/Configure.help linux-2.4.4mw/Documentation/Configure.help
--- linux-2.4.4-orig/Documentation/Configure.help	Wed May 30 20:27:55 2001
+++ linux-2.4.4mw/Documentation/Configure.help	Wed May 30 18:24:09 2001
@@ -11996,6 +11996,12 @@
   were partitioned using EFI GPT.  Presently only useful on the
   IA-64 platform.

+/dev/guid support (EXPERIMENTAL)
+CONFIG_DEVFS_GUID
+  Say Y here if you would like to access disks and partitions by
+  their Globally Unique Identifiers (GUIDs) which will appear as
+  symbolic links in /dev/guid.
+
 Ultrix partition support
 CONFIG_ULTRIX_PARTITION
   Say Y here if you would like to be able to read the hard disk
diff -ru -x *.o -x.* -x*.rej -x*~ linux-2.4.4-orig/fs/devfs/base.c linux-2.4.4mw/fs/devfs/base.c
--- linux-2.4.4-orig/fs/devfs/base.c	Wed May 30 20:27:55 2001
+++ linux-2.4.4mw/fs/devfs/base.c	Wed May 30 20:27:38 2001
@@ -1903,6 +1903,27 @@
     return master->slave;
 }   /*  End Function devfs_get_unregister_slave  */

+#ifdef CONFIG_DEVFS_GUID
+/**
+ *	devfs_unregister_slave - remove the slave that is unregistered when @master is unregistered.
+ *      Destroys the connection established by devfs_auto_unregister.
+ *
+ *	@master: The master devfs entry.
+ */
+
+void devfs_unregister_slave (devfs_handle_t master)
+{
+	devfs_handle_t slave;
+
+	if (master == NULL) return;
+
+	slave = master->slave;
+	if (slave) {
+		master->slave = NULL;
+		unregister (slave);
+	};
+}
+#endif /* CONFIG_DEVFS_GUID */

 /**
  *	devfs_get_name - Get the name for a device entry in its parent directory.
@@ -2103,6 +2124,9 @@
 EXPORT_SYMBOL(devfs_get_next_sibling);
 EXPORT_SYMBOL(devfs_auto_unregister);
 EXPORT_SYMBOL(devfs_get_unregister_slave);
+#ifdef CONFIG_DEVFS_GUID
+EXPORT_SYMBOL(devfs_unregister_slave);
+#endif
 EXPORT_SYMBOL(devfs_register_chrdev);
 EXPORT_SYMBOL(devfs_register_blkdev);
 EXPORT_SYMBOL(devfs_unregister_chrdev);
diff -ru -x *.o -x.* -x*.rej -x*~ linux-2.4.4-orig/fs/partitions/Config.in linux-2.4.4mw/fs/partitions/Config.in
--- linux-2.4.4-orig/fs/partitions/Config.in	Wed May 30 20:27:55 2001
+++ linux-2.4.4mw/fs/partitions/Config.in	Wed May 30 18:24:03 2001
@@ -25,6 +25,7 @@
       bool '    Solaris (x86) partition table support' CONFIG_SOLARIS_X86_PARTITION
       bool '    Unixware slices support' CONFIG_UNIXWARE_DISKLABEL
       bool '    EFI GUID Partition support' CONFIG_EFI_PARTITION
+      dep_bool '    /dev/guid support (EXPERIMENTAL)' CONFIG_DEVFS_GUID $CONFIG_DEVFS_FS $CONFIG_EFI_PARTITION
    fi
    bool '  SGI partition support' CONFIG_SGI_PARTITION
    bool '  Ultrix partition table support' CONFIG_ULTRIX_PARTITION
diff -ru -x *.o -x.* -x*.rej -x*~ linux-2.4.4-orig/fs/partitions/check.c linux-2.4.4mw/fs/partitions/check.c
--- linux-2.4.4-orig/fs/partitions/check.c	Wed May 30 20:27:55 2001
+++ linux-2.4.4mw/fs/partitions/check.c	Wed May 30 19:29:55 2001
@@ -37,6 +37,18 @@
 # include "efi.h"
 #endif

+#ifdef CONFIG_DEVFS_GUID
+#define GUID_UNPARSED_LEN 36
+static void
+uuid_unparse_1(efi_guid_t *guid, char *out)
+{
+	sprintf(out, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
+		guid->data1, guid->data2, guid->data3,
+		guid->data4[0], guid->data4[1], guid->data4[2], guid->data4[3],
+		guid->data4[4], guid->data4[5], guid->data4[6], guid->data4[7]);
+}
+#endif
+
 extern void device_init(void);
 extern int *blk_size[];
 extern void rd_load(void);
@@ -82,6 +94,10 @@
 	NULL
 };

+#ifdef CONFIG_DEVFS_GUID
+static devfs_handle_t guid_top_handle;
+#endif
+
 /*
  * disk_name() is used by partition check code and the md driver.
  * It formats the devicename of the indicated disk into
@@ -317,6 +333,101 @@
 	devfs_register_partitions (hd, i, hd->sizes ? 0 : 1);
 }

+#ifdef CONFIG_DEVFS_GUID
+/*
+  devfs_register_guid: create a /dev/guid entry for a disk or partition
+                       if it has a GUID.
+
+  The /dev/guid entry will be a symlink to the "real" devfs device.
+  It is marked as "slave" of the real device,
+  to be automatically unregistered by devfs if that device is unregistered.
+
+  If the partition already had a /dev/guid entry, delete (unregister) it.
+  (If the disk was repartitioned, it's likely the old GUID entry will be wrong).
+
+  dev, minor:  Device for which an entry is to be created.
+
+  Prerequisites: dev->part[minor].guid must be either NULL or point
+                 to a valid kmalloc'ed GUID.
+*/
+
+static void devfs_register_guid (struct gendisk *dev, int minor)
+{
+	efi_guid_t *guid = dev->part[minor].guid;
+	devfs_handle_t guid_handle, slave,
+		real_master = dev->part[minor].de;
+	devfs_handle_t master = real_master;
+	char guid_link[GUID_UNPARSED_LEN + 1];
+	char dirname[128];
+	int pos, st;
+
+	if (!guid_top_handle)
+		guid_top_handle = devfs_mk_dir (NULL, "guid", NULL);
+
+	if (!guid || !master) return;
+
+	do {
+		slave = devfs_get_unregister_slave (master);
+		if (slave) {
+			if (slave == master || slave == real_master) {
+				printk (KERN_WARNING
+					"devfs_register_guid: infinite slave loop!\n");
+				return;
+			} else if (devfs_get_parent (slave) == guid_top_handle) {
+				printk (KERN_INFO
+					"devfs_register_guid: unregistering %s\n",
+					devfs_get_name (slave, NULL));
+				devfs_unregister_slave (master);
+				slave = NULL;
+			} else
+				master = slave;
+		};
+	} while (slave);
+
+	uuid_unparse_1 (guid, guid_link);
+	pos = devfs_generate_path (real_master, dirname + 3,
+				   sizeof (dirname) - 3);
+	if (pos < 0) {
+		printk (KERN_WARNING
+			"devfs_register_guid: error generating path: %d\n",
+			pos);
+		return;
+	};
+
+	strncpy (dirname + pos, "../", 3);
+
+	st = devfs_mk_symlink (guid_top_handle, guid_link,
+			       DEVFS_FL_DEFAULT,
+			       dirname + pos, &guid_handle, NULL);
+
+	if (st < 0) {
+		printk ("Error %d creating symlink\n", st);
+	} else {
+		devfs_auto_unregister (master, guid_handle);
+	};
+};
+
+/*
+  free_disk_guids: kfree all guid data structures alloced for
+  the disk device specified by (dev, minor) and all its partitions.
+
+  This function does not remove symlinks in /dev/guid.
+*/
+static void free_disk_guids (struct gendisk *dev, int minor)
+{
+	int i;
+	efi_guid_t *guid;
+
+	for (i = 0; i < dev->max_p; i++) {
+		guid = dev->part[minor + i].guid;
+		if (!guid) continue;
+		kfree (guid);
+		dev->part[minor + i].guid = NULL;
+	};
+}
+
+#endif /* CONFIG_DEVFS_GUID */
+
 #ifdef CONFIG_DEVFS_FS
 static void devfs_register_partition (struct gendisk *dev, int minor, int part)
 {
@@ -325,7 +436,11 @@
 	unsigned int devfs_flags = DEVFS_FL_DEFAULT;
 	char devname[16];

-	if (dev->part[minor + part].de) return;
+	/* Even if the devfs handle is still up-to-date,
+	   the GUID entry probably isn't */
+	if (dev->part[minor + part].de)
+		goto do_guid;
+
 	dir = devfs_get_parent (dev->part[minor].de);
 	if (!dir) return;
 	if ( dev->flags && (dev->flags[devnum] & GENHD_FL_REMOVABLE) )
@@ -336,6 +451,11 @@
 			    dev->major, minor + part,
 			    S_IFBLK | S_IRUSR | S_IWUSR,
 			    dev->fops, NULL);
+ do_guid:
+#ifdef CONFIG_DEVFS_GUID
+	devfs_register_guid (dev, minor + part);
+#endif
+	return;
 }

 static void devfs_register_disc (struct gendisk *dev, int minor)
@@ -348,7 +468,9 @@
 	static unsigned int disc_counter;
 	static devfs_handle_t devfs_handle;

-	if (dev->part[minor].de) return;
+	if (dev->part[minor].de)
+		goto do_guid;
+
 	if ( dev->flags && (dev->flags[devnum] & GENHD_FL_REMOVABLE) )
 		devfs_flags |= DEVFS_FL_REMOVABLE;
 	if (dev->de_arr) {
@@ -375,6 +497,12 @@
 	devfs_auto_unregister (dev->part[minor].de, slave);
 	if (!dev->de_arr)
 		devfs_auto_unregister (slave, dir);
+
+ do_guid:
+#ifdef CONFIG_DEVFS_GUID
+	devfs_register_guid (dev, minor);
+#endif
+	return;
 }
 #endif  /*  CONFIG_DEVFS_FS  */

@@ -396,6 +524,7 @@
 	if (unregister) {
 		devfs_unregister (dev->part[minor].de);
 		dev->part[minor].de = NULL;
+		free_disk_guids (dev, minor);
 	}
 #endif  /*  CONFIG_DEVFS_FS  */
 }
@@ -413,8 +542,21 @@
 void register_disk(struct gendisk *gdev, kdev_t dev, unsigned minors,
 	struct block_device_operations *ops, long size)
 {
+	int i;
+
 	if (!gdev)
 		return;
+
+#ifdef CONFIG_DEVFS_GUID
+	/* Initialize all guid fields to NULL (=^ not kmalloc'ed).
+	   It is assumed that drivers call register_disk after
+	   allocating the gen_hd structure, and call grok_partitions
+	   directly for a revalidate event, as those drives I've inspected
+	   (among which hd and sd) do. */
+	for (i = 0; i < gdev->max_p; i++)
+		gdev->part[MINOR(dev) + i].guid = NULL;
+#endif
+
 	grok_partitions(gdev, MINOR(dev)>>gdev->minor_shift, minors, size);
 }

@@ -432,6 +574,13 @@
 	if (!size || minors == 1)
 		return;

+#ifdef CONFIG_DEVFS_GUID
+	/* In case this is a revalidation, free GUID memory.
+	   On the first call for this device,
+	   register_disk has set all entries to NULL,
+	   and nothing will happen. */
+	free_disk_guids (dev, first_minor);
+#endif
 	blk_size[dev->major] = NULL;
 	check_partition(dev, MKDEV(dev->major, first_minor), 1 + first_minor);

diff -ru -x *.o -x.* -x*.rej -x*~ linux-2.4.4-orig/fs/partitions/efi.c linux-2.4.4mw/fs/partitions/efi.c
--- linux-2.4.4-orig/fs/partitions/efi.c	Wed May 30 20:27:55 2001
+++ linux-2.4.4mw/fs/partitions/efi.c	Wed May 30 20:11:12 2001
@@ -479,7 +479,31 @@
 	return 0;
 }

+#ifdef CONFIG_DEVFS_GUID
+/* set_partition_guid */
+/* Fill in the GUID field of the partition.
+   It is set to NULL by register_disk before. */
+static void set_partition_guid (struct gendisk *hd,
+				const int minor,
+				const efi_guid_t *guid)
+{
+        char guid_buf[GUID_UNPARSED_LEN + 1];
+	efi_guid_t *part_guid = hd->part[minor].guid;

+	if (!guid || !hd) return;
+
+	part_guid = kmalloc (sizeof (efi_guid_t), GFP_KERNEL);
+
+        if (part_guid) {
+		memcpy (part_guid, guid, sizeof (efi_guid_t));
+	} else {
+		printk (KERN_WARNING
+                        "add_gpt_partitions: cannot allocate GUID memory!\n");
+	};
+
+	hd->part[minor].guid = part_guid;
+}
+#endif /* CONFIG_DEVFS_GUID */

 /*
  * Create devices for each entry in the GUID Partition Table Entries.
@@ -516,6 +540,11 @@
 	}

 	debug_printk(efi_printk_level "GUID Partition Table is valid!  Yea!\n");
+
+#ifdef CONFIG_DEVFS_GUID
+	set_partition_guid (hd, nextminor - 1, &(gpt->DiskGUID));
+#endif
+
 	for (i = 0; i < gpt->NumberOfPartitionEntries &&
 		     nummade < (hd->max_p - 1); i++) {
 		if (!efi_guidcmp(unusedGuid, ptes[i].PartitionTypeGuid))
@@ -523,6 +552,10 @@

 		add_gd_partition(hd, nextminor, ptes[i].StartingLBA,
 				 (ptes[i].EndingLBA-ptes[i].StartingLBA + 1));
+
+#ifdef CONFIG_DEVFS_GUID
+		set_partition_guid (hd, nextminor, &(ptes[i].UniquePartitionGuid));
+#endif

 		/* If there's this is a RAID volume, tell md */
 #if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
diff -ru -x *.o -x.* -x*.rej -x*~ linux-2.4.4-orig/include/linux/devfs_fs_kernel.h linux-2.4.4mw/include/linux/devfs_fs_kernel.h
--- linux-2.4.4-orig/include/linux/devfs_fs_kernel.h	Wed May 30 20:27:55 2001
+++ linux-2.4.4mw/include/linux/devfs_fs_kernel.h	Wed May 30 20:24:15 2001
@@ -81,6 +81,9 @@
 extern devfs_handle_t devfs_get_next_sibling (devfs_handle_t de);
 extern void devfs_auto_unregister (devfs_handle_t master,devfs_handle_t slave);
 extern devfs_handle_t devfs_get_unregister_slave (devfs_handle_t master);
+#ifdef CONFIG_DEVFS_GUID
+extern void devfs_unregister_slave (devfs_handle_t master);
+#endif
 extern const char *devfs_get_name (devfs_handle_t de, unsigned int *namelen);
 extern int devfs_register_chrdev (unsigned int major, const char *name,
 				  struct file_operations *fops);
diff -ru -x *.o -x.* -x*.rej -x*~ linux-2.4.4-orig/include/linux/genhd.h linux-2.4.4mw/include/linux/genhd.h
--- linux-2.4.4-orig/include/linux/genhd.h	Wed May 30 20:27:55 2001
+++ linux-2.4.4mw/include/linux/genhd.h	Wed May 30 18:26:02 2001
@@ -13,6 +13,10 @@
 #include <linux/types.h>
 #include <linux/major.h>

+#ifdef CONFIG_DEVFS_GUID
+#include <asm/efi.h>
+#endif
+
 /* These three have identical behaviour; use the second one if DOS fdisk gets
    confused about extended/logical partitions starting past cylinder 1023. */
 #define DOS_EXTENDED_PARTITION 5
@@ -51,6 +55,9 @@
 	long start_sect;
 	long nr_sects;
 	devfs_handle_t de;              /* primary (master) devfs entry  */
+#ifdef CONFIG_DEVFS_GUID
+	efi_guid_t *guid;
+#endif
 };

 #define GENHD_FL_REMOVABLE  1


