From: Matt_Domsch@Dell.com
Date: Fri, 17 Nov 2000 23:40:12 +0000
Subject: [Linux-ia64] FAT32 file system not mounting on IA-64
Message-Id: <marc-linux-ia64-105590678205745@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone tried using a FAT32 file system on an IA-64 Linux box?  While
this works on my IA-32 system (kernel 2.4.0-test9), this fails on my IA-64
system (same kernel).

(use fdisk to make one big sdb1 partition, 18GB or so)
mkdosfs -F 32 /dev/sdb1
mount /dev/sdb1 /mnt/fat32-1

On IA-64, I get the following error:
Directory 1: bad FAT	(from linux/fs/fat/inode.c)
File system panic (dev 08:11)
  FAT error		(from linux/fs/fat/misc.c)
  File system has been set read-only.

If the file system previously existed, after the (read-only) mount, I can
only see garbage.  I suspect that the on-disk data structures as defined in
the kernel are not 64-bit clean, but that's just a guess.  Any pointers are
appreciated.

Thanks,
Matt Domsch
Dell Enterprise Systems Group
Linux Development Team




