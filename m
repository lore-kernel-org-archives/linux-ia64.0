From: John Levon <levon@movementarian.org>
Date: Sat, 11 Oct 2003 14:54:02 +0000
Subject: [PATCH] select EFI partition support by default
Message-Id: <marc-linux-ia64-106588409310269@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This makes the EFI choice look like the others, and makes sure it's
selected by default if the user didn't choose Advanced Partition
Selection.

I fell foul of this, being an IA-64 newbie.

OK ?

regards
john


Index: linux-cvs/fs/partitions/Kconfig
=================================RCS file: /home/cvs/linux-2.5/fs/partitions/Kconfig,v
retrieving revision 1.5
diff -u -a -p -r1.5 Kconfig
--- linux-cvs/fs/partitions/Kconfig	27 Sep 2003 07:07:08 -0000	1.5
+++ linux-cvs/fs/partitions/Kconfig	11 Oct 2003 14:51:42 -0000
@@ -225,8 +225,8 @@ config SUN_PARTITION
 	  you don't know what all this is about, say N.
 
 config EFI_PARTITION
-	bool "EFI GUID Partition support"
-	depends on PARTITION_ADVANCED
+	bool "EFI GUID Partition support" if PARTITION_ADVANCED
+	default y if !PARTITION_ADVANCED && IA64
 	select CRC32
 	help
 	  Say Y here if you would like to use hard disks under Linux which
