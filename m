From: peterc@gelato.unsw.edu.au
Date: Wed, 24 Apr 2002 05:25:21 +0000
Subject: [Linux-ia64] A start at large file and filesystem support
Message-Id: <marc-linux-ia64-105590701905504@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I've been looking at getting large file system support to work
properly (there's currently a 1TB or 2TB limit on the size of a block device
in 2.5.9, depending on how you use it).

This patch enables large filesystems, and discs bigger than 2TB.
Only the EFI GUID partitioning scheme can be used with enormous discs,
as all the others are constrained by 32-bit number of cylinders.

Next step is to audit the filesystems that claim to be able to support
large filesystems (ext2 may support up to 32TB; reiserfs version 4,
jfs and xfs much more) and make sure that they can.

The patch is a bit big for inclusion in this email.
You can get it from
 http://www.gelato.unsw.edu.au/patches/2.5.9-largefile-patch.txt.bz2
(which also includes the changes David Mosberger put up as the diffs
from 2.5.8)

If you're bitkeeper-enabled, you can pull the patch from
bk://gelato.unsw.edu.au:2022

The change set log is as follows:

ChangeSet@1.602, 2002-04-24 12:35:11+10:00,
peterc@redback.cse.unsw.edu.au
  Merged up to v2.5.9 from local parent.

ChangeSet@1.489.5.9, 2002-04-24 12:22:42+10:00,
peterc@redback.cse.unsw.edu.au
  Many files:
    Use sector_t to count sectors
  blkpg.c:
    Use sector_t to measure sectors; avoid useless checks on a 64-bit
    machine
  
  The aim is to begin a transition to 64-bit sector numbers, even on 
  32-bit architectures, and to allow 64-bit architectures to use huge
  partitions
  and filesystems (where the filesystems support it).

ChangeSet@1.489.5.8, 2002-04-24 12:20:15+10:00,
peterc@redback.cse.unsw.edu.au
  Minor changes to fix compilation warnings on IA64



Peter C

