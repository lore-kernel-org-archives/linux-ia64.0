From: Matt_Domsch@Dell.com
Date: Wed, 25 Oct 2000 17:34:21 +0000
Subject: [Linux-ia64] [PATCH] EFI GUID Partition Table support
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C03EA9.CEE66B3A"
Message-Id: <marc-linux-ia64-105590678205627@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C03EA9.CEE66B3A
Content-Type: text/plain;
	charset="iso-8859-1"

Attached is my patch (against 2.4.0-test9) to add EFI GUID Partition Table
support to the Linux kernel, specifically for IA-64.  This code is licensed
under the GPL.
To enable support, add CONFIG_EFI_PARTITION=y to your config files.

Special thanks to Andries Brouwer for his assistance in helping me to
understand the kernel block device layer.

Please direct any feedback you have with about code to me.

Thanks,
Matt Domsch
Dell Enterprise Systems Group
Linux Development Team

 <<linux-2.4.0-test9-efigpt-001025.patch>> 




------_=_NextPart_000_01C03EA9.CEE66B3A
Content-Type: application/octet-stream;
	name="linux-2.4.0-test9-efigpt-001025.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="linux-2.4.0-test9-efigpt-001025.patch"

diff -burN linux-2.4.0-test9.orig/Documentation/Configure.help =
linux-2.4.0-test9-efigpt/Documentation/Configure.help=0A=
--- linux-2.4.0-test9.orig/Documentation/Configure.help	Fri Sep 22 =
19:11:37 2000=0A=
+++ linux-2.4.0-test9-efigpt/Documentation/Configure.help	Wed Oct 25 =
10:49:21 2000=0A=
@@ -11279,6 +11279,12 @@=0A=
   Say Y here if you would like to be able to read the hard disk=0A=
   partition table format used by SGI machines.=0A=
 =0A=
+Intel EFI GUID partition support=0A=
+CONFIG_EFI_PARTITION=0A=
+  Say Y here if you would like to use hard disks under Linux which=0A=
+  were partitioned using EFI GPT.  Presently only useful on the=0A=
+  IA-64 platform.=0A=
+=0A=
 ADFS file system support (EXPERIMENTAL)=0A=
 CONFIG_ADFS_FS=0A=
   The Acorn Disc Filing System is the standard file system of the=0A=
diff -burN linux-2.4.0-test9.orig/fs/partitions/Config.in =
linux-2.4.0-test9-efigpt/fs/partitions/Config.in=0A=
--- linux-2.4.0-test9.orig/fs/partitions/Config.in	Mon Jul 10 00:21:41 =
2000=0A=
+++ linux-2.4.0-test9-efigpt/fs/partitions/Config.in	Wed Oct 25 =
10:49:21 2000=0A=
@@ -23,6 +23,7 @@=0A=
       bool '    BSD disklabel (FreeBSD partition tables) support' =
CONFIG_BSD_DISKLABEL=0A=
       bool '    Solaris (x86) partition table support' =
CONFIG_SOLARIS_X86_PARTITION=0A=
       bool '    Unixware slices support' CONFIG_UNIXWARE_DISKLABEL=0A=
+      bool '    EFI GUID Partition support' CONFIG_EFI_PARTITION=0A=
    fi=0A=
    bool '  SGI partition support' CONFIG_SGI_PARTITION=0A=
    bool '  Ultrix partition table support' CONFIG_ULTRIX_PARTITION=0A=
diff -burN linux-2.4.0-test9.orig/fs/partitions/Makefile =
linux-2.4.0-test9-efigpt/fs/partitions/Makefile=0A=
--- linux-2.4.0-test9.orig/fs/partitions/Makefile	Wed Jul 19 00:49:47 =
2000=0A=
+++ linux-2.4.0-test9-efigpt/fs/partitions/Makefile	Wed Oct 25 10:49:21 =
2000=0A=
@@ -20,6 +20,7 @@=0A=
 obj-$(CONFIG_SUN_PARTITION) +=3D sun.o=0A=
 obj-$(CONFIG_ULTRIX_PARTITION) +=3D ultrix.o=0A=
 obj-$(CONFIG_IBM_PARTITION) +=3D ibm.o=0A=
+obj-$(CONFIG_EFI_PARTITION) +=3D efi.o=0A=
 =0A=
 O_OBJS +=3D $(obj-y)=0A=
 M_OBJS +=3D $(obj-m)=0A=
diff -burN linux-2.4.0-test9.orig/fs/partitions/check.c =
linux-2.4.0-test9-efigpt/fs/partitions/check.c=0A=
--- linux-2.4.0-test9.orig/fs/partitions/check.c	Wed Sep 27 15:39:23 =
2000=0A=
+++ linux-2.4.0-test9-efigpt/fs/partitions/check.c	Wed Oct 25 10:49:21 =
2000=0A=
@@ -32,6 +32,7 @@=0A=
 #include "sun.h"=0A=
 #include "ibm.h"=0A=
 #include "ultrix.h"=0A=
+#include "efi.h"=0A=
 =0A=
 extern void device_init(void);=0A=
 extern int *blk_size[];=0A=
@@ -71,6 +72,9 @@=0A=
 #endif=0A=
 #ifdef CONFIG_IBM_PARTITION=0A=
 	ibm_partition,=0A=
+#endif=0A=
+#ifdef CONFIG_EFI_PARTITION=0A=
+	efi_partition,=0A=
 #endif=0A=
 	NULL=0A=
 };=0A=
diff -burN linux-2.4.0-test9.orig/fs/partitions/efi.c =
linux-2.4.0-test9-efigpt/fs/partitions/efi.c=0A=
--- linux-2.4.0-test9.orig/fs/partitions/efi.c	Wed Dec 31 18:00:00 =
1969=0A=
+++ linux-2.4.0-test9-efigpt/fs/partitions/efi.c	Wed Oct 25 11:26:28 =
2000=0A=
@@ -0,0 +1,646 @@=0A=
+/************************************************************=0A=
+ * EFI GUID Partition Table handling=0A=
+ * Per Intel EFI Specification v0.99=0A=
+ * http://developer.intel.com/technology/efi/efi.htm=0A=
+ * efi.[ch] by Matt Domsch <Matt_Domsch@dell.com> =0A=
+ *   Copyright 2000 Dell Computer Corporation=0A=
+ * CRC routines taken from the EFI Sample Implementation,=0A=
+ *   1999.12.31, lib/crc.c=0A=
+ *=0A=
+ *  This program is free software; you can redistribute it and/or =
modify=0A=
+ *  it under the terms of the GNU General Public License as published =
by=0A=
+ *  the Free Software Foundation; either version 2 of the License, =
or=0A=
+ *  (at your option) any later version.=0A=
+ * =0A=
+ *  This program is distributed in the hope that it will be useful,=0A=
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+ *  GNU General Public License for more details.=0A=
+ *=0A=
+ *  You should have received a copy of the GNU General Public =
License=0A=
+ *  along with this program; if not, write to the Free Software=0A=
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+ *=0A=
+ * =0A=
+ * TODO:=0A=
+ *=0A=
+ * Changelog:=0A=
+ * Wed Oct 25 2000 Matt Domsch <Matt_Domsch@dell.com>=0A=
+ * - Fixed the LastLBA() call to return the proper last block=0A=
+ * =0A=
+ * Thu Oct 12 2000 Matt Domsch <Matt_Domsch@dell.com>=0A=
+ * - Thanks to Andries Brouwer for his debugging assistance.=0A=
+ * - Code works, detects all the partitions.=0A=
+ *=0A=
+ ************************************************************/=0A=
+#include <linux/config.h>=0A=
+#include <linux/fs.h>=0A=
+#include <linux/genhd.h>=0A=
+#include <linux/kernel.h>=0A=
+#include <linux/major.h>=0A=
+#include <linux/string.h>=0A=
+#include <linux/blk.h>=0A=
+#include <linux/malloc.h>=0A=
+#include <linux/smp_lock.h>=0A=
+#include <asm/system.h>=0A=
+#include <asm/efi.h>=0A=
+=0A=
+#include "check.h"=0A=
+#include "efi.h"=0A=
+=0A=
+#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID=0A=
+extern void md_autodetect_dev(kdev_t dev);=0A=
+#endif=0A=
+=0A=
+=0A=
+#undef EFI_DEBUG=0A=
+#ifdef EFI_DEBUG=0A=
+static char *efi_printk_level =3D KERN_DEBUG;=0A=
+#define debug_printk printk=0A=
+#else=0A=
+#define debug_printk(...)=0A=
+#endif=0A=
+=0A=
+/* CRC routines taken from the EFI Sample Implementation,=0A=
+ *   1999.12.31, lib/crc.c=0A=
+ *=0A=
+ * Note, the EFI Specification, v0.99, has a reference to=0A=
+ * Dr. Dobbs Journal, May 1994 (actually it's in May 1992)=0A=
+ * but that isn't the CRC function being used by EFI.=0A=
+ */=0A=
+=0A=
+static u32 CRCTable[256] =3D {=0A=
+	0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, =
0x706AF48F,=0A=
+	0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, =
0x97D2D988,=0A=
+	0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, =
0x6AB020F2,=0A=
+	0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, =
0x83D385C7,=0A=
+	0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, =
0x63066CD9,=0A=
+	0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, =
0xA2677172,=0A=
+	0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, =
0x42B2986C,=0A=
+	0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, =
0xABD13D59,=0A=
+	0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, =
0x56B3C423,=0A=
+	0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, =
0xB10BE924,=0A=
+	0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, =
0x01DB7106,=0A=
+	0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, =
0xE8B8D433,=0A=
+	0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, =
0x086D3D2D,=0A=
+	0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, =
0xF262004E,=0A=
+	0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, =
0x12B7E950,=0A=
+	0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, =
0xFBD44C65,=0A=
+	0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, =
0x3DD895D7,=0A=
+	0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, =
0xDA60B8D0,=0A=
+	0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, =
0x270241AA,=0A=
+	0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, =
0xCE61E49F,=0A=
+	0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, =
0x2EB40D81,=0A=
+	0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, =
0x74B1D29A,=0A=
+	0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, =
0x94643B84,=0A=
+	0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, =
0x7D079EB1,=0A=
+	0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, =
0x806567CB,=0A=
+	0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, =
0x67DD4ACC,=0A=
+	0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, =
0xA1D1937E,=0A=
+	0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, =
0x48B2364B,=0A=
+	0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, =
0xA867DF55,=0A=
+	0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, =
0x5268E236,=0A=
+	0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, =
0xB2BD0B28,=0A=
+	0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, =
0x5BDEAE1D,=0A=
+	0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, =
0xEB0E363F,=0A=
+	0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, =
0x0CB61B38,=0A=
+	0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, =
0xF1D4E242,=0A=
+	0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, =
0x18B74777,=0A=
+	0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, =
0xF862AE69,=0A=
+	0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, =
0x3903B3C2,=0A=
+	0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, =
0xD9D65ADC,=0A=
+	0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, =
0x30B5FFE9,=0A=
+	0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, =
0xCDD70693,=0A=
+	0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, =
0x2A6F2B94,=0A=
+	0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D =0A=
+};=0A=
+=0A=
+static u32=0A=
+CalculateCrc (void *_pt, u32 Size)=0A=
+{=0A=
+	u8 *pt =3D (u8 *)_pt;=0A=
+	register u32 Crc;=0A=
+=0A=
+	/*  compute crc */=0A=
+	Crc =3D 0xffffffff;=0A=
+	while (Size) {=0A=
+		Crc =3D (Crc >> 8) ^ CRCTable[(__u8) Crc ^ *pt];=0A=
+		pt +=3D 1;=0A=
+		Size -=3D 1;=0A=
+	}=0A=
+	Crc =3D Crc ^ 0xffffffff;=0A=
+	return Crc;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * IsLegacyMBRValid()=0A=
+ * Requires:=0A=
+ *  - mbr is a pointer to a legacy mbr structure=0A=
+ * Modifies: nothing=0A=
+ * Returns:=0A=
+ *  1 on true=0A=
+ *  0 on false=0A=
+ ************************************************************/=0A=
+static inline int=0A=
+IsLegacyMBRValid(LegacyMBR_t *mbr)=0A=
+{=0A=
+	return (mbr ? (mbr->Signature =3D=3D MSDOS_MBR_SIGNATURE) : 0);=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * LastLBA()=0A=
+ * Requires:=0A=
+ *  - struct gendisk hd=0A=
+ *  - kdev_t dev=0A=
+ * Modifies: nothing=0A=
+ * Returns:=0A=
+ *  Last LBA value on success.  This is stored (by sd and=0A=
+ *  ide-geometry) in =0A=
+ *  the part[0] entry for this disk, and is the number of=0A=
+ *  physical sectors available on the disk.=0A=
+ *  0 on error=0A=
+ ************************************************************/=0A=
+u64=0A=
+LastLBA(struct gendisk *hd, kdev_t dev)=0A=
+{=0A=
+  if (!hd || !hd->part) return 0;=0A=
+  return hd->part[MINOR(dev)].nr_sects - 1;=0A=
+}=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * ReadLBA()=0A=
+ * Requires:=0A=
+ *  - hd is our disk device.=0A=
+ *  - dev is our device major number=0A=
+ *  - lba is the logical block address desired (disk hardsector =
number)=0A=
+ *  - buffer is a buffer of size size into which data copied=0A=
+ *  - size_t count is size of the read (in bytes)=0A=
+ * Modifies:=0A=
+ *  - buffer=0A=
+ * Returns:=0A=
+ *  - count of bytes read=0A=
+ *  - 0 on error=0A=
+ * Bugs:=0A=
+ *  - bread() takes second argument as a signed int, not a u64.=0A=
+ *    This is because getblk() takes the block number as a signed =
int.=0A=
+ *    This overflow is known on l-k.   We overflow at about 1TB.=0A=
+ *=0A=
+ ************************************************************/=0A=
+=0A=
+static size_t=0A=
+ReadLBA(struct gendisk *hd, kdev_t dev, u64 _lba, u8 *buffer, size_t =
count)=0A=
+{=0A=
+	struct buffer_head *bh;=0A=
+	size_t totalreadcount =3D 0, bytesread;=0A=
+	int lba =3D (_lba & 0x7FFFFFFF), i, blockstoread, blocksize;=0A=
+	debug_printk(efi_printk_level "ReadLBA(%p,%s,%x,%p,%x)\n",=0A=
+		     hd, kdevname(dev), lba, buffer, count);=0A=
+  =0A=
+	if (!hd || !buffer || !count) return 0;=0A=
+  =0A=
+  =0A=
+	blocksize =3D get_hardblocksize(dev);=0A=
+	if (!blocksize) blocksize =3D 512;=0A=
+	blockstoread =3D count / blocksize;=0A=
+	if (count % blocksize) blockstoread +=3D 1;=0A=
+	debug_printk(efi_printk_level "about to read %d blocks\n",=0A=
+		     blockstoread);=0A=
+  =0A=
+  =0A=
+	for (i=3D0; i<blockstoread; i++) {=0A=
+		bh =3D bread(dev, lba+i, blocksize);=0A=
+		if (!bh) {=0A=
+			/* We hit the end of the disk */=0A=
+			debug_printk(efi_printk_level=0A=
+				     "bread returned NULL.\n");=0A=
+			return totalreadcount;=0A=
+		}=0A=
+    =0A=
+		bytesread =3D (count > bh->b_size ? bh->b_size : count);=0A=
+		memcpy(buffer, bh->b_data, bytesread);=0A=
+    =0A=
+		buffer +=3D bytesread;         /* Advance the buffer pointer */=0A=
+		totalreadcount +=3D bytesread; /* Advance the total read count */=0A=
+		count -=3D bytesread;         /* Subtract bytesread from count */=0A=
+    =0A=
+		brelse(bh); =0A=
+	}=0A=
+  =0A=
+	return totalreadcount;=0A=
+}=0A=
+=0A=
+void=0A=
+PrintGuidPartitionTableHeader(GuidPartitionTableHeader_t *gpt)=0A=
+{=0A=
+	debug_printk(efi_printk_level "GUID Partition Table Header\n");=0A=
+	if (!gpt) return;=0A=
+	debug_printk(efi_printk_level "Signature      : %lx\n",=0A=
+		     gpt->Signature);=0A=
+	debug_printk(efi_printk_level "Revision       : %x\n",=0A=
+		     gpt->Revision);=0A=
+	debug_printk(efi_printk_level "HeaderSize     : %x\n",=0A=
+		     gpt->HeaderSize);=0A=
+	debug_printk(efi_printk_level "HeaderCRC32    : %x\n",=0A=
+		     gpt->HeaderCRC32);=0A=
+	debug_printk(efi_printk_level "MyLBA          : %lx\n",=0A=
+		     gpt->MyLBA);=0A=
+	debug_printk(efi_printk_level "AlternateLBA   : %lx\n",=0A=
+		     gpt->AlternateLBA);=0A=
+	debug_printk(efi_printk_level "FirstUsableLBA : %lx\n",=0A=
+		     gpt->FirstUsableLBA);=0A=
+	debug_printk(efi_printk_level "LastUsableLBA  : %lx\n",=0A=
+		     gpt->LastUsableLBA);=0A=
+  =0A=
+	debug_printk(efi_printk_level "PartitionEntryLBA : %lx\n",=0A=
+		     gpt->PartitionEntryLBA);=0A=
+	debug_printk(efi_printk_level "NumberOfPartitionEntries : %x\n",=0A=
+		     gpt->NumberOfPartitionEntries);=0A=
+	debug_printk(efi_printk_level "SizeOfPartitionEntry : %x\n",=0A=
+		     gpt->SizeOfPartitionEntry);=0A=
+	debug_printk(efi_printk_level "PartitionEntryArrayCRC32 : %x\n",=0A=
+		     gpt->PartitionEntryArrayCRC32);=0A=
+  =0A=
+	return;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * ReadGuidPartitionEntries()=0A=
+ * Requires:=0A=
+ *  - filedes is an open file descriptor, suitable for reading=0A=
+ *  - lba is the Logical Block Address of the partition table=0A=
+ *  - gpt is a buffer into which the GPT will be put  =0A=
+ * Modifies:=0A=
+ *  - filedes file and pointer=0A=
+ *  - gpt=0A=
+ * Returns:=0A=
+ *   pte on success=0A=
+ *   NULL on error=0A=
+ * Notes: remember to free pte when you're done!=0A=
+ ************************************************************/=0A=
+GuidPartitionEntry_t *=0A=
+ReadGuidPartitionEntries(struct gendisk *hd, kdev_t dev,=0A=
+			 GuidPartitionTableHeader_t *gpt)=0A=
+{=0A=
+	size_t count;=0A=
+	GuidPartitionEntry_t *pte;=0A=
+	if (!hd || !gpt) return NULL;=0A=
+  =0A=
+	count =3D gpt->NumberOfPartitionEntries * =
gpt->SizeOfPartitionEntry;=0A=
+	debug_printk(efi_printk_level "ReadGPTEs() kmallocing %x bytes\n",=0A=
+		     count);=0A=
+	if (!count) return NULL;=0A=
+	pte =3D kmalloc(count, GFP_KERNEL);=0A=
+	if (!pte)  return NULL;=0A=
+	memset(pte, 0, count);=0A=
+  =0A=
+	if (ReadLBA(hd, dev, gpt->PartitionEntryLBA, (u8 *)pte,=0A=
+		    count) < count) {=0A=
+		kfree(pte);=0A=
+		return NULL;=0A=
+	}=0A=
+	return pte;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * ReadGuidPartitionTableHeader()=0A=
+ * Requires:=0A=
+ *  - hd is our struct gendisk=0A=
+ *  - dev is our device major number=0A=
+ *  - lba is the Logical Block Address of the partition table=0A=
+ *  - gpt is a buffer into which the GPT will be put  =0A=
+ *  - pte is a buffer into which the PTEs will be put  =0A=
+ * Modifies:=0A=
+ *  - gpt and pte=0A=
+ * Returns:=0A=
+ *   1 on success=0A=
+ *   0 on error=0A=
+ ************************************************************/=0A=
+=0A=
+GuidPartitionTableHeader_t *=0A=
+ReadGuidPartitionTableHeader(struct gendisk *hd, kdev_t dev, u64 =
lba)=0A=
+     =0A=
+{=0A=
+	GuidPartitionTableHeader_t *gpt;=0A=
+	if (!hd) return NULL;=0A=
+  =0A=
+	gpt =3D kmalloc(sizeof(GuidPartitionTableHeader_t), GFP_KERNEL);=0A=
+	if (!gpt) return NULL;=0A=
+	memset(gpt, 0, sizeof(GuidPartitionTableHeader_t));=0A=
+  =0A=
+	debug_printk(efi_printk_level "GPTH() calling ReadLBA().\n");=0A=
+	if (ReadLBA(hd, dev, lba, (u8 *)gpt,=0A=
+		    sizeof(GuidPartitionTableHeader_t)) <=0A=
+	    sizeof(GuidPartitionTableHeader_t)) {=0A=
+		debug_printk(efi_printk_level "ReadGPTH(%lx) read failed.\n",=0A=
+			     lba);=0A=
+		kfree(gpt);=0A=
+		return NULL;=0A=
+	}=0A=
+	PrintGuidPartitionTableHeader(gpt);=0A=
+  =0A=
+	return gpt;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * IsGuidPartitionTableValid()=0A=
+ * Requires:=0A=
+ *  - gd points to our struct gendisk=0A=
+ *  - dev is our device major number=0A=
+ *  - lba is the logical block address of the GPTH to test=0A=
+ *  - gpt is a GPTH if it's valid=0A=
+ *  - ptes is a PTEs if it's valid=0A=
+ * Modifies:=0A=
+ *  - gpt and ptes=0A=
+ * Returns:=0A=
+ *   1 if valid=0A=
+ *   0 on error=0A=
+ ************************************************************/=0A=
+static int=0A=
+IsGuidPartitionTableValid(struct gendisk *hd, kdev_t dev, u64 lba, =0A=
+                          GuidPartitionTableHeader_t **gpt,=0A=
+                          GuidPartitionEntry_t **ptes)=0A=
+{=0A=
+	u32 crc, origcrc;=0A=
+  =0A=
+	if (!hd || !gpt || !ptes) return 0;=0A=
+	if (!(*gpt =3D ReadGuidPartitionTableHeader(hd, dev, lba))) return =
0;=0A=
+  =0A=
+	/* Check the GUID Partition Table Signature */=0A=
+	if ((*gpt)->Signature !=3D GUID_PT_HEADER_SIGNATURE) {=0A=
+		debug_printk(efi_printk_level "GUID Partition Table Header Signature =
is wrong: %x !=3D %x\n", (*gpt)->Signature, =
GUID_PT_HEADER_SIGNATURE);=0A=
+		kfree(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		return 0;=0A=
+	}=0A=
+  =0A=
+	/* Check the GUID Partition Table CRC */=0A=
+	origcrc =3D (*gpt)->HeaderCRC32;=0A=
+	(*gpt)->HeaderCRC32 =3D 0;=0A=
+	crc =3D CalculateCrc(*gpt, (*gpt)->HeaderSize);=0A=
+  =0A=
+  =0A=
+	if (crc !=3D origcrc) {=0A=
+		debug_printk(efi_printk_level "GUID Partition Table Header CRC is =
wrong: %x !=3D %x\n", (*gpt)->HeaderCRC32, origcrc);=0A=
+		kfree(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		return 0;=0A=
+	}=0A=
+	(*gpt)->HeaderCRC32 =3D origcrc;=0A=
+  =0A=
+	/* Check that the MyLBA entry points to the LBA that contains=0A=
+	 * the GUID Partition Table */=0A=
+	if ((*gpt)->MyLBA !=3D lba) {=0A=
+		debug_printk(efi_printk_level "GPT MyLBA incorrect: %lx !=3D %lx\n", =
(*gpt)->MyLBA, lba);=0A=
+		kfree(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		return 0;=0A=
+	}=0A=
+  =0A=
+	if (!(*ptes =3D ReadGuidPartitionEntries(hd, dev, *gpt))) {=0A=
+		debug_printk(efi_printk_level "read PTEs failed.\n");=0A=
+		kfree(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		return 0;=0A=
+	}=0A=
+  =0A=
+	/* Check the GUID Partition Entry Array CRC */=0A=
+	crc =3D CalculateCrc(*ptes, (*gpt)->NumberOfPartitionEntries *=0A=
+			   (*gpt)->SizeOfPartitionEntry);=0A=
+  =0A=
+	if (crc !=3D (*gpt)->PartitionEntryArrayCRC32)  {=0A=
+		debug_printk(efi_printk_level "GUID Partitition Entry Array CRC =
check failed.\n");=0A=
+		kfree(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		kfree(*ptes);=0A=
+		*ptes =3D NULL;=0A=
+		return 0;=0A=
+	}=0A=
+  =0A=
+  =0A=
+	/* We're done, all's well */=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * FindValidGPT()=0A=
+ * Requires:=0A=
+ *  - gd points to our struct gendisk=0A=
+ *  - dev is our device major number=0A=
+ *  - gpt is a GPTH if it's valid=0A=
+ *  - ptes is a PTE=0A=
+ * Modifies:=0A=
+ *  - gpt & ptes=0A=
+ * Returns:=0A=
+ *   1 if valid=0A=
+ *   0 on error=0A=
+ ************************************************************/=0A=
+static int=0A=
+FindValidGPT(struct gendisk *hd, kdev_t dev,=0A=
+             GuidPartitionTableHeader_t **gpt,=0A=
+             GuidPartitionEntry_t **ptes)=0A=
+{=0A=
+	int rc =3D 0;=0A=
+	GuidPartitionTableHeader_t *pgpt =3D NULL, *agpt =3D NULL;=0A=
+	GuidPartitionEntry_t *pptes =3D NULL, *aptes =3D NULL;=0A=
+	u64 lastlba;=0A=
+	if (!hd || !gpt || !ptes) return 0;=0A=
+=0A=
+	lastlba =3D LastLBA(hd, dev);=0A=
+	/* Check the Primary GPT */=0A=
+	rc =3D IsGuidPartitionTableValid(hd, dev, 1, &pgpt, &pptes);=0A=
+	if (rc) {=0A=
+		/* Primary GPT is OK, check the alternate and warn if bad */=0A=
+		rc =3D IsGuidPartitionTableValid(hd, dev, pgpt->AlternateLBA,=0A=
+					       &agpt, &aptes);    =0A=
+		if (!rc){=0A=
+			printk(KERN_WARNING "Alternate GPT is invalid, using primary =
GPT.\n");=0A=
+		}=0A=
+    =0A=
+		*gpt =3D pgpt;=0A=
+		*ptes =3D pptes;=0A=
+		if (agpt)  kfree(agpt);=0A=
+		if (aptes) kfree(aptes);=0A=
+		return 1;=0A=
+	} /* if primary is valid */=0A=
+	else {=0A=
+		/* Primary GPT is bad, check the Alternate GPT */=0A=
+		rc =3D IsGuidPartitionTableValid(hd, dev, lastlba,=0A=
+					       &agpt, &aptes);    =0A=
+		if (rc) {=0A=
+			/* Primary is bad, alternate is good.=0A=
+			   Return values from the alternate and warn.=0A=
+			*/=0A=
+			printk(KERN_WARNING "Primary GPT is invalid, using alternate =
GPT.\n");=0A=
+			*gpt =3D agpt;=0A=
+			*ptes =3D aptes;=0A=
+			return 1;=0A=
+		}=0A=
+		else {=0A=
+			/* Primary is bad, alternate is bad, try "other"=0A=
+			 * alternate.  This is necessary because if we=0A=
+			 * have an odd-sized disk, user-space might=0A=
+			 * have put the alternate in block lastlba-1.=0A=
+			 */=0A=
+			if (!(lastlba & 1)) {=0A=
+				lastlba--;=0A=
+				rc =3D IsGuidPartitionTableValid(hd, dev,=0A=
+							       lastlba,=0A=
+							       &agpt, &aptes);=0A=
+				if (rc) {=0A=
+					/* Primary is bad, alternate is good.=0A=
+					 * Return values from the alternate=0A=
+					 * and warn.=0A=
+					 */=0A=
+					printk("Primary GPT is invalid, using alternate GPT.\n");=0A=
+					*gpt =3D agpt;=0A=
+					*ptes =3D aptes;=0A=
+					return 1;=0A=
+				}=0A=
+			}=0A=
+		}=0A=
+	}=0A=
+	/* Both primary and alternate GPTs are bad.=0A=
+	 * This isn't our disk, return 0.=0A=
+	 */=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/*=0A=
+ * Create devices for each entry in the GUID Partition Table =
Entries.=0A=
+ * The first block of each partition is a Legacy MBR.=0A=
+ *=0A=
+ * We do not create a Linux partition for GPT, but=0A=
+ * only for the actual data partitions.=0A=
+ * Returns:=0A=
+ * -1 if unable to read the partition table=0A=
+ *  0 if this isn't our partition table=0A=
+ *  1 if successful=0A=
+ *=0A=
+ */=0A=
+=0A=
+static int=0A=
+add_gpt_partitions(struct gendisk *hd, kdev_t dev, int nextminor)=0A=
+{=0A=
+	GuidPartitionTableHeader_t *gpt =3D NULL;=0A=
+	GuidPartitionEntry_t *ptes =3D NULL;=0A=
+	u32 i, nummade=3D0;=0A=
+=0A=
+	efi_guid_t unusedGuid =3D UNUSED_ENTRY_GUID;=0A=
+#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID=0A=
+	efi_guid_t raidGuid =3D PARTITION_LINUX_RAID_GUID;=0A=
+#endif=0A=
+=0A=
+	if (!hd) return -1;=0A=
+  =0A=
+	if (!FindValidGPT(hd, dev, &gpt, &ptes) || =0A=
+	    !gpt || !ptes) {=0A=
+		if (gpt) kfree(gpt);=0A=
+		if (ptes) kfree(ptes);=0A=
+		return 0;=0A=
+	}=0A=
+  =0A=
+	debug_printk(efi_printk_level "GUID Partition Table is valid!  =
Yea!\n");=0A=
+	for (i =3D 0; i < gpt->NumberOfPartitionEntries &&=0A=
+		     nummade < (hd->max_p - 1); i++) {=0A=
+		if (!efi_guidcmp(unusedGuid, ptes[i].PartitionTypeGuid))=0A=
+			continue;=0A=
+=0A=
+		add_gd_partition(hd, nextminor, ptes[i].StartingLBA,=0A=
+				 (ptes[i].EndingLBA-ptes[i].StartingLBA + 1));=0A=
+=0A=
+		/* If there's this is a RAID volume, tell md */=0A=
+#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID=0A=
+		if (!efi_guidcmp(raidGuid, ptes[i].PartitionTypeGuid)) {=0A=
+			md_autodetect_dev(MKDEV(MAJOR(dev),nextminor));=0A=
+		}=0A=
+#endif=0A=
+		nummade++;=0A=
+		nextminor++;=0A=
+=0A=
+	}=0A=
+	kfree(ptes);=0A=
+	kfree(gpt);=0A=
+	printk("\n");=0A=
+	return 1;=0A=
+  =0A=
+}=0A=
+=0A=
+=0A=
+/* =0A=
+ * efi_partition()=0A=
+ *=0A=
+ * If the first block on the disk is a legacy MBR,=0A=
+ * it got handled already by msdos_partition().=0A=
+ * If it's a Protective MBR, we'll handle it here.=0A=
+ *=0A=
+ * Returns:=0A=
+ * -1 if unable to read the partition table=0A=
+ *  0 if this isn't our partitoin table=0A=
+ *  1 if successful=0A=
+ *=0A=
+ */=0A=
+=0A=
+int=0A=
+efi_partition(struct gendisk *hd, kdev_t dev,=0A=
+              unsigned long first_sector, int first_part_minor) {=0A=
+	int hardblocksize =3D get_hardblocksize(dev);=0A=
+	int orig_blksize_size =3D BLOCK_SIZE;=0A=
+	int rc =3D 0;=0A=
+  =0A=
+  /* not good, but choose something! */=0A=
+	if (!hardblocksize) hardblocksize =3D 512;=0A=
+  =0A=
+	/* Need to change the block size that the block layer uses */=0A=
+	if (blksize_size[MAJOR(dev)]){=0A=
+		orig_blksize_size =3D blksize_size[MAJOR(dev)][MINOR(dev)];=0A=
+	}=0A=
+  =0A=
+	if (orig_blksize_size !=3D hardblocksize)=0A=
+		set_blocksize(dev, hardblocksize);=0A=
+  =0A=
+	rc =3D add_gpt_partitions(hd, dev, first_part_minor);=0A=
+  =0A=
+	/* change back */=0A=
+	if (orig_blksize_size !=3D hardblocksize)=0A=
+		set_blocksize(dev, orig_blksize_size);=0A=
+  =0A=
+	return rc;=0A=
+}=0A=
+=0A=
+=0A=
+/*=0A=
+ * Overrides for Emacs so that we follow Linus's tabbing style.=0A=
+ * Emacs will notice this stuff at the end of the file and =
automatically=0A=
+ * adjust the settings for this buffer only.  This must remain at the =
end=0A=
+ * of the file.=0A=
+ * =
------------------------------------------------------------------------=
---=0A=
+ * Local variables:=0A=
+ * c-indent-level: 4 =0A=
+ * c-brace-imaginary-offset: 0=0A=
+ * c-brace-offset: -4=0A=
+ * c-argdecl-indent: 4=0A=
+ * c-label-offset: -4=0A=
+ * c-continued-statement-offset: 4=0A=
+ * c-continued-brace-offset: 0=0A=
+ * indent-tabs-mode: nil=0A=
+ * tab-width: 8=0A=
+ * End:=0A=
+ */=0A=
+=0A=
+=0A=
+=0A=
diff -burN linux-2.4.0-test9.orig/fs/partitions/efi.h =
linux-2.4.0-test9-efigpt/fs/partitions/efi.h=0A=
--- linux-2.4.0-test9.orig/fs/partitions/efi.h	Wed Dec 31 18:00:00 =
1969=0A=
+++ linux-2.4.0-test9-efigpt/fs/partitions/efi.h	Wed Oct 25 10:59:37 =
2000=0A=
@@ -0,0 +1,154 @@=0A=
+/************************************************************=0A=
+ * EFI GUID Partition Table=0A=
+ * Per Intel EFI Specification v0.99=0A=
+ * http://developer.intel.com/technology/efi/efi.htm=0A=
+ *=0A=
+ * By Matt Domsch <Matt_Domsch@dell.com>  Fri Sep 22 22:15:56 CDT 2000 =
 =0A=
+ *   Copyright 2000 Dell Computer Corporation=0A=
+ *=0A=
+ *  This program is free software; you can redistribute it and/or =
modify=0A=
+ *  it under the terms of the GNU General Public License as published =
by=0A=
+ *  the Free Software Foundation; either version 2 of the License, =
or=0A=
+ *  (at your option) any later version.=0A=
+ * =0A=
+ *  This program is distributed in the hope that it will be useful,=0A=
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+ *  GNU General Public License for more details.=0A=
+ *=0A=
+ *  You should have received a copy of the GNU General Public =
License=0A=
+ *  along with this program; if not, write to the Free Software=0A=
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-130=
7  USA=0A=
+ * =0A=
+ ************************************************************/=0A=
+=0A=
+#ifndef FS_PART_EFI_H_INCLUDED=0A=
+#define FS_PART_EFI_H_INCLUDED=0A=
+=0A=
+#include <linux/types.h>=0A=
+#include <asm/efi.h>=0A=
+=0A=
+#include <linux/config.h>=0A=
+#include <linux/fs.h>=0A=
+#include <linux/genhd.h>=0A=
+#include <linux/kernel.h>=0A=
+#include <linux/major.h>=0A=
+#include <linux/string.h>=0A=
+#include <linux/blk.h>=0A=
+=0A=
+#define MSDOS_MBR_SIGNATURE 0xaa55=0A=
+#define EFI_PMBR_OSTYPE_EFI 0xEF=0A=
+#define EFI_PMBR_OSTYPE_EFI_GPT 0xEE=0A=
+=0A=
+#define GUID_PT_BLOCK_SIZE 512=0A=
+=0A=
+#define GUID_PT_HEADER_SIGNATURE 0x5452415020494645L=0A=
+#define GUID_PT_HEADER_REVISION_V1 0x00010000=0A=
+#define GUID_PT_HEADER_REVISION_V0_99 0x00000099=0A=
+#define UNUSED_ENTRY_GUID    \=0A=
+    ((efi_guid_t) { 0x00000000, 0x0000, 0x0000, { 0x00, 0x00, 0x00, =
0x00, 0x00, 0x00, 0x00, 0x00 }})=0A=
+#define PARTITION_SYSTEM_GUID \=0A=
+((efi_guid_t) { 0xC12A7328, 0xF81F, 0x11d2, { 0xBA, 0x4B, 0x00, 0xA0, =
0xC9, 0x3E, 0xC9, 0x3B }})=0A=
+#define LEGACY_MBR_PARTITION_GUID \=0A=
+    ((efi_guid_t) { 0x024DEE41, 0x33E7, 0x11d3, { 0x9D, 0x69, 0x00, =
0x08, 0xC7, 0x81, 0xF3, 0x9F }})=0A=
+#define PARTITION_MSFT_RESERVED_GUID \=0A=
+    ((efi_guid_t) { 0xE3C9E316, 0x0B5C, 0x4DB8, { 0x81, 0x7D, 0xF9, =
0x2D, 0xF0, 0x02, 0x15, 0xAE }})=0A=
+#define PARTITION_BASIC_DATA_GUID \=0A=
+    ((efi_guid_t) { 0xEBD0A0A2, 0xB9E5, 0x4433, { 0x87, 0xC0, 0x68, =
0xB6, 0xB7, 0x26, 0x99, 0xC7 }})=0A=
+#define PARTITION_LINUX_RAID_GUID \=0A=
+    ((efi_guid_t) { 0xa19d880f, 0x05fc, 0x4d3b, { 0xa0, 0x06, 0x74, =
0x3f, 0x0f, 0x84, 0x91, 0x1e  }})=0A=
+#define PARTITION_LINUX_SWAP_GUID \=0A=
+    ((efi_guid_t) { 0x0657fd6d, 0xa4ab, 0x43c4, { 0x84, 0xe5, 0x09, =
0x33, 0xc8, 0x4b, 0x4f, 0x4f  }})=0A=
+=0A=
+typedef struct _GuidPartitionTableHeader_t {=0A=
+  u64 Signature;=0A=
+  u32 Revision;=0A=
+  u32 HeaderSize;=0A=
+  u32 HeaderCRC32;=0A=
+  u32 Reserved1;=0A=
+  u64 MyLBA;=0A=
+  u64 AlternateLBA;=0A=
+  u64 FirstUsableLBA;=0A=
+  u64 LastUsableLBA;=0A=
+  efi_guid_t DiskGUID;=0A=
+  u64 PartitionEntryLBA;=0A=
+  u32 NumberOfPartitionEntries;=0A=
+  u32 SizeOfPartitionEntry;=0A=
+  u32 PartitionEntryArrayCRC32;=0A=
+  u8 Reserved2[GUID_PT_BLOCK_SIZE - 92];=0A=
+} GuidPartitionTableHeader_t;=0A=
+=0A=
+typedef struct _GuidPartitionEntryAttributes_t {=0A=
+  __u64 RequiredToFunction:1;=0A=
+  __u64 Reserved:63;=0A=
+} GuidPartitionEntryAttributes_t;=0A=
+=0A=
+typedef struct _GuidPartitionEntry_t {=0A=
+  efi_guid_t PartitionTypeGuid;=0A=
+  efi_guid_t UniquePartitionGuid;=0A=
+  u64 StartingLBA;=0A=
+  u64 EndingLBA;=0A=
+  GuidPartitionEntryAttributes_t Attributes;=0A=
+  efi_char16_t PartitionName[72/sizeof(efi_char16_t)];=0A=
+} GuidPartitionEntry_t;=0A=
+=0A=
+=0A=
+=0A=
+typedef struct _PartitionRecord_t {=0A=
+  u8 BootIndicator;  /* Not used by EFI firmware. Set to 0x80 to =
indicate that this=0A=
+                        is the bootable legacy partition. */=0A=
+  u8 StartHead;      /* Start of partition in CHS address, not used by =
EFI firmware. */=0A=
+  u8 StartSector;    /* Start of partition in CHS address, not used by =
EFI firmware. */=0A=
+  u8 StartTrack;     /* Start of partition in CHS address, not used by =
EFI firmware. */=0A=
+  u8 OSType;         /* OS type. A value of 0xEF defines an EFI system =
partition.=0A=
+                        Other values are reserved for legacy operating =
systems, and=0A=
+                        allocated independently of the EFI =
specification. */=0A=
+  u8 EndHead;        /* End of partition in CHS address, not used by =
EFI firmware. */=0A=
+  u8 EndSector;      /* End of partition in CHS address, not used by =
EFI firmware. */=0A=
+  u8 EndTrack;       /* End of partition in CHS address, not used by =
EFI firmware. */=0A=
+  u32 StartingLBA;   /* Starting LBA address of the partition on the =
disk. Used by=0A=
+                        EFI firmware to define the start of the =
partition. */=0A=
+  u32 SizeInLBA;     /* Size of partition in LBA. Used by EFI firmware =
to determine=0A=
+                        the size of the partition. */=0A=
+} PartitionRecord_t;=0A=
+=0A=
+typedef struct _LegacyMBR_t {=0A=
+  u8 BootCode[440];=0A=
+  u32 UniqueMBRSignature;=0A=
+  u16 Unknown;=0A=
+  PartitionRecord_t PartitionRecord[4];=0A=
+  u16 Signature;=0A=
+} __attribute__ ((packed)) LegacyMBR_t;=0A=
+=0A=
+=0A=
+=0A=
+#define EFI_GPT_PRIMARY_PARTITION_TABLE_LBA 1=0A=
+=0A=
+/* Functions */=0A=
+extern int=0A=
+efi_partition(struct gendisk *hd, kdev_t dev,=0A=
+              unsigned long first_sector, int first_part_minor);=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+#endif=0A=
+=0A=
+/*=0A=
+ * Overrides for Emacs so that we follow Linus's tabbing style.=0A=
+ * Emacs will notice this stuff at the end of the file and =
automatically=0A=
+ * adjust the settings for this buffer only.  This must remain at the =
end=0A=
+ * of the file.=0A=
+ * =
------------------------------------------------------------------------=
--=0A=
+ * Local variables:=0A=
+ * c-indent-level: 4 =0A=
+ * c-brace-imaginary-offset: 0=0A=
+ * c-brace-offset: -4=0A=
+ * c-argdecl-indent: 4=0A=
+ * c-label-offset: -4=0A=
+ * c-continued-statement-offset: 4=0A=
+ * c-continued-brace-offset: 0=0A=
+ * indent-tabs-mode: nil=0A=
+ * tab-width: 8=0A=
+ * End:=0A=
+ */=0A=
diff -burN linux-2.4.0-test9.orig/fs/partitions/msdos.c =
linux-2.4.0-test9-efigpt/fs/partitions/msdos.c=0A=
--- linux-2.4.0-test9.orig/fs/partitions/msdos.c	Wed Jul 19 01:29:16 =
2000=0A=
+++ linux-2.4.0-test9-efigpt/fs/partitions/msdos.c	Wed Oct 25 10:49:21 =
2000=0A=
@@ -36,6 +36,10 @@=0A=
 #include "check.h"=0A=
 #include "msdos.h"=0A=
 =0A=
+#ifdef CONFIG_EFI_PARTITION=0A=
+#include "efi.h"=0A=
+#endif=0A=
+=0A=
 #if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID=0A=
 extern void md_autodetect_dev(kdev_t dev);=0A=
 #endif=0A=
@@ -378,6 +382,16 @@=0A=
 		bforget(bh);=0A=
 		return 0;=0A=
 	}=0A=
+#ifdef CONFIG_EFI_PARTITION=0A=
+	p =3D (struct partition *) (0x1be + data);=0A=
+	for (i=3D1 ; i<=3D4 ; i++,p++) {=0A=
+	  /* If this is an EFI GPT disk, msdos should ignore it. */=0A=
+	  if (SYS_IND(p) =3D=3D EFI_PMBR_OSTYPE_EFI_GPT) {=0A=
+	    bforget(bh);=0A=
+	    return 0;=0A=
+	  }=0A=
+	}=0A=
+#endif=0A=
 	p =3D (struct partition *) (0x1be + data);=0A=
 =0A=
 #ifdef CONFIG_BLK_DEV_IDE=0A=

------_=_NextPart_000_01C03EA9.CEE66B3A--

