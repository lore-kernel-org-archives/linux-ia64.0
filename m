From: Alex Williamson <alex_williamson@hp.com>
Date: Fri, 16 Aug 2002 16:33:08 +0000
Subject: [Linux-ia64] [PATCH] fix raid on GPT partitions
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------74221873371FA43169767FE9"
Message-Id: <marc-linux-ia64-105590701905943@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------74221873371FA43169767FE9
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Seems a minor number increment was missed in the efi partition
code.  This was causing RAID to only autodetect if you were lucky
enough to be using raid on the first partition of the disk.  Here's
the fix (against 2.4.18+0722).

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------74221873371FA43169767FE9
Content-Type: text/plain; charset=us-ascii;
 name="root-raid.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="root-raid.diff"

Index: fs/partitions/efi.c
===================================================================
RCS file: /var/cvs/linux/fs/partitions/efi.c,v
retrieving revision 1.4
diff -u -p -r1.4 efi.c
--- fs/partitions/efi.c	15 May 2002 16:15:16 -0000	1.4
+++ fs/partitions/efi.c	16 Aug 2002 16:14:55 -0000
@@ -740,7 +740,7 @@ add_gpt_partitions(struct gendisk *hd, s
                                  PARTITION_LINUX_RAID_GUID)) {
                         md_autodetect_dev(MKDEV
                                           (MAJOR(to_kdev_t(bdev->bd_dev)),
-                                           nextminor));
+                                           nextminor+i));
 		}
 #endif
 	}

--------------74221873371FA43169767FE9--


