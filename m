From: Matt_Domsch@Dell.com
Date: Thu, 28 Mar 2002 23:17:34 +0000
Subject: [Linux-ia64] GUID cleanups and GPT patches
Message-Id: <marc-linux-ia64-105590701905342@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, I've finally gotten around to doing the GUID cleanups as we
discussed.  Additionally it brings the GPT code for 2.4.18 and 2.5.17 into
alignment again.  I'm still trying to get the GPT stuff in the standard
kernel, but the fs/partitions maintainer has been busy with other non-Linux
work.  Since the GPT code again has dependencies on IA-64 port-specific
files, I'll submit only the GPT stuff to Linus and Marcelo after the IA-64
code is merged there.

Common changes:
* EFI_GUID macro defined per your suggestion - efi_guid_t is now a struct of
char[16].  Fixed all GUID definitions.
* Made one unified efi_guid_unparse() static inline in asm-ia64/efi.h.
Removed three other definitions of similar in efivars.c and mca.c.
* fixed endianness of fs/partitions/efi.c - thanks to Richard Hirst and his
GPT work in Parted.
* cleaned up find_valid_gpt() to make it easier to see what's going on and
avoid future NULL ptr deref cases if this code gets modified yet again.
* Only use partition table slots 0..max_p.  The previous behaviour would let
you delete a partition in the middle of the table, and on next boot all the
partition numbers above that would switch down.  This change makes it
consistent with the MSDOS concept of primary partitions.  /dev/sdaX exists
iff the partition type is not NULL.

Changes only to 2.4.18:
* Brought fs/partitions/efi.[ch] in line with 2.5.x.
* Removed CONFIG_DEVFS_GUID stuff from 2.4.18
* Moved crc32 functions into efi.c - in 2.4.19pre there's now a different
include/linux/crc32.h and no lib/crc32.c, which would otherwise conflict.
include/linux/crc32.h and lib/crc32.c may be removed from your patch
entirely.

Changes only in 2.5.7-pre1:
* Moved CONFIG_PARTITION_EFI help text to fs/partitions/Config.help


On top of linux-2.4.18 plus linux-2.4.18-ia64-020226.patch:
http://domsch.com/linux/ia64/linux-2.4.18-ia64-020226-gpt-guidcleanup-200203
27.patch


On top of linux-2.5.7-pre1 plus linux-2.5.7-pre1-ia64-020314:
http://domsch.com/linux/ia64/linux-2.5.7-pre1-gpt-guidcleanup-20020327.patch


While I can't get 2.5.7-pre1 to boot on my IA-64 workstation (hangs after
saying "I'm alive and well..."), 2.4.18 appears to work just fine.

I've also built this with 2.5.7-dj2 on x86 and it works fine.  Dave Jones
has had the GPT stuff in his tree for a while now.
http://domsch.com/linux/ia64/linux-2.5.7-dj2-gpt-guidcleanup-20020327.patch.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001!

