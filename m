From: Matt_Domsch@Dell.com
Date: Tue, 06 Mar 2001 18:01:00 +0000
Subject: [Linux-ia64] GPT patch for parted 1.4.7
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C0A667.6A928184"
Message-Id: <marc-linux-ia64-105590693005247@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C0A667.6A928184
Content-Type: text/plain;
	charset="iso-8859-1"

Attached is a patch against GNU Parted 1.4.7 which adds EFI GPT support.
This has not yet been submitted to the GNU Parted team officially, I'm
waiting on a kernel IOCTL patch to be included first.  A lot of people are
interested in this, so I'm making it available for testing.  I haven't
tested this against newer versions of parted, but expect it to drop in with
minimal effort.

Notes:
- This works for all disks with an even number of 512-byte sectors.
- This works for SCSI disks with an odd number of 512-byte sectors by using
SCSI Generic (sg) commands to read/write the last odd sector.  Odd-sized IDE
disks won't work.
- Pending the inclusion of a kernel patch to allow reading/writing the last
sector of any disk via a block layer IOCTL, I'll re-write this patch to
remove the sg hacks and use that instead.

Assistance:
If anyone wants to help, particularly in adding Unicode support to parted,
I'd appreciate it.  Please join the bug-parted mailing list.
To subscribe or unsubscribe via the World Wide Web, visit
	http://mail.gnu.org/mailman/listinfo/bug-parted
or, via email, send a message with subject or body 'help' to
	bug-parted-request@gnu.org


Your feedback is encouraged.  

Thanks,
Matt

--
Matt Domsch
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux



------_=_NextPart_000_01C0A667.6A928184
Content-Type: application/octet-stream;
	name="parted-1.4.7-gpt-010124.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="parted-1.4.7-gpt-010124.patch"

diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/include/parted/Makefile.am =
parted-1.4.7-gpt/include/parted/Makefile.am=0A=
--- parted-1.4.7/include/parted/Makefile.am	Mon Dec  4 13:12:47 2000=0A=
+++ parted-1.4.7-gpt/include/parted/Makefile.am	Thu Jan 18 11:24:42 =
2001=0A=
@@ -6,6 +6,7 @@=0A=
 			exception.h	\=0A=
 			filesys.h	\=0A=
 			natmath.h	\=0A=
+			crc32.h		\=0A=
 			parted.h=0A=
 =0A=
 noinst_HEADERS	      =3D disk_bsd.h	\=0A=
@@ -13,5 +14,6 @@=0A=
 			disk_loop.h	\=0A=
 			disk_mac.h	\=0A=
 			disk_pc98.h	\=0A=
+			disk_gpt.h	\=0A=
 			endian.h=0A=
 =0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/include/parted/crc32.h =
parted-1.4.7-gpt/include/parted/crc32.h=0A=
--- parted-1.4.7/include/parted/crc32.h	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/include/parted/crc32.h	Thu Jan 18 11:24:42 2001=0A=
@@ -0,0 +1,34 @@=0A=
+/*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+    crc32.h=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+#ifndef _CRC32_H=0A=
+#define _CRC32_H=0A=
+=0A=
+#include <linux/types.h>=0A=
+=0A=
+/*=0A=
+ * This computes a 32 bit CRC of the data in the buffer, and returns =
the CRC.=0A=
+ * The polynomial used is 0xedb88320.=0A=
+ */=0A=
+=0A=
+extern __u32 crc32 (const void *buf, unsigned long len, __u32 =
seed);=0A=
+=0A=
+#endif /* _CRC32_H */=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/include/parted/disk_gpt.h =
parted-1.4.7-gpt/include/parted/disk_gpt.h=0A=
--- parted-1.4.7/include/parted/disk_gpt.h	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/include/parted/disk_gpt.h	Wed Jan 24 11:23:31 =
2001=0A=
@@ -0,0 +1,195 @@=0A=
+/*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+=0A=
+    Copyright (C) 2000-2001 Dell Computer Corporation=0A=
+    disk_gpt.[ch] by Matt Domsch <Matt_Domsch@dell.com> =0A=
+=0A=
+    EFI GUID Partition Table handling=0A=
+    Per Intel EFI Specification v1.02=0A=
+    http://developer.intel.com/technology/efi/efi.htm=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+#ifndef EFI_GPT_H=0A=
+#define EFI_GPT_H=0A=
+=0A=
+=0A=
+#include <linux/types.h>=0A=
+=0A=
+#define EFI_PMBR_OSTYPE_EFI 0xEF=0A=
+#define EFI_PMBR_OSTYPE_EFI_GPT 0xEE=0A=
+#define MSDOS_MBR_SIGNATURE 0xaa55=0A=
+#define GUID_PT_BLOCK_SIZE 512=0A=
+=0A=
+=0A=
+#define GUID_PT_HEADER_SIGNATURE 0x5452415020494645=0A=
+#define GUID_PT_HEADER_REVISION_V1_02 0x00010200=0A=
+#define GUID_PT_HEADER_REVISION_V1_00 0x00010000=0A=
+#define GUID_PT_HEADER_REVISION_V0_99 0x00009900=0A=
+=0A=
+typedef __u16 efi_char16_t;	/* UNICODE character */=0A=
+=0A=
+typedef struct {=0A=
+	__u32 data1;=0A=
+	__u16 data2;=0A=
+	__u16 data3;=0A=
+	__u8 data4[8];=0A=
+} __attribute__ ((packed)) efi_guid_t;=0A=
+=0A=
+=0A=
+#define UNUSED_ENTRY_GUID    \=0A=
+    ((efi_guid_t) { 0x00000000, 0x0000, 0x0000, { 0x00, 0x00, 0x00, =
0x00, 0x00, 0x00, 0x00, 0x00 }})=0A=
+#define PARTITION_SYSTEM_GUID \=0A=
+    ((efi_guid_t) { 0xC12A7328, 0xF81F, 0x11d2, { 0xBA, 0x4B, 0x00, =
0xA0, 0xC9, 0x3E, 0xC9, 0x3B }})=0A=
+#define LEGACY_MBR_PARTITION_GUID \=0A=
+    ((efi_guid_t) { 0x024DEE41, 0x33E7, 0x11d3, { 0x9D, 0x69, 0x00, =
0x08, 0xC7, 0x81, 0xF3, 0x9F }})=0A=
+#define PARTITION_MSFT_RESERVED_GUID \=0A=
+    ((efi_guid_t) { 0xE3C9E316, 0x0B5C, 0x4DB8, { 0x81, 0x7D, 0xF9, =
0x2D, 0xF0, 0x02, 0x15, 0xAE }})=0A=
+#define PARTITION_BASIC_DATA_GUID \=0A=
+    ((efi_guid_t) { 0xEBD0A0A2, 0xB9E5, 0x4433, { 0x87, 0xC0, 0x68, =
0xB6, 0xB7, 0x26, 0x99, 0xC7 }})=0A=
+#define PARTITION_RAID_GUID \=0A=
+    ((efi_guid_t) { 0xa19d880f, 0x05fc, 0x4d3b, { 0xa0, 0x06, 0x74, =
0x3f, 0x0f, 0x84, 0x91, 0x1e }})=0A=
+#define PARTITION_SWAP_GUID \=0A=
+    ((efi_guid_t) { 0x0657fd6d, 0xa4ab, 0x43c4, { 0x84, 0xe5, 0x09, =
0x33, 0xc8, 0x4b, 0x4f, 0x4f }})=0A=
+#define PARTITION_LVM_GUID \=0A=
+    ((efi_guid_t) { 0xe6d6d379, 0xf507, 0x44c2, { 0xa2, 0x3c, 0x23, =
0x8f, 0x2a, 0x3d, 0xf9, 0x28 }})=0A=
+#define PARTITION_RESERVED_GUID \=0A=
+    ((efi_guid_t) { 0x8da63339, 0x0007, 0x60c0, { 0xc4, 0x36, 0x08, =
0x3a, 0xc8, 0x23, 0x09, 0x08 }})=0A=
+=0A=
+typedef struct _GuidPartitionTableHeader_t {=0A=
+	__u64 Signature;=0A=
+	__u32 Revision;=0A=
+	__u32 HeaderSize;=0A=
+	__u32 HeaderCRC32;=0A=
+	__u32 Reserved1;=0A=
+	__u64 MyLBA;=0A=
+	__u64 AlternateLBA;=0A=
+	__u64 FirstUsableLBA;=0A=
+	__u64 LastUsableLBA;=0A=
+	efi_guid_t DiskGUID;=0A=
+	__u64 PartitionEntryLBA;=0A=
+	__u32 NumberOfPartitionEntries;=0A=
+	__u32 SizeOfPartitionEntry;=0A=
+	__u32 PartitionEntryArrayCRC32;=0A=
+	__u8 Reserved2[GUID_PT_BLOCK_SIZE - 92];=0A=
+} __attribute__ ((packed)) GuidPartitionTableHeader_t;=0A=
+=0A=
+typedef struct _GuidPartitionEntryAttributes_t {=0A=
+	__u64 RequiredToFunction:1;=0A=
+	__u64 Reserved:47;=0A=
+        __u64 GuidSpecific:16;=0A=
+} __attribute__ ((packed)) GuidPartitionEntryAttributes_t;=0A=
+=0A=
+typedef struct _GuidPartitionEntry_t {=0A=
+	efi_guid_t PartitionTypeGuid;=0A=
+	efi_guid_t UniquePartitionGuid;=0A=
+	__u64 StartingLBA;=0A=
+	__u64 EndingLBA;=0A=
+	GuidPartitionEntryAttributes_t Attributes;=0A=
+	efi_char16_t PartitionName[72 / sizeof(efi_char16_t)];=0A=
+} __attribute__ ((packed)) GuidPartitionEntry_t;=0A=
+=0A=
+=0A=
+/* =0A=
+   These values are only defaults.  The actual on-disk structures=0A=
+   may define different sizes, so use those unless creating a new GPT =
disk!=0A=
+*/=0A=
+=0A=
+#define GPT_DEFAULT_RESERVED_PARTITION_ENTRY_ARRAY_SIZE 16384=0A=
+/* =0A=
+   Number of actual partition entries should be calculated=0A=
+   as: =0A=
+*/=0A=
+#define GPT_DEFAULT_RESERVED_PARTITION_ENTRIES \=0A=
+        (GPT_DEFAULT_RESERVED_PARTITION_ENTRY_ARRAY_SIZE / \=0A=
+         sizeof(GuidPartitionEntry_t))=0A=
+=0A=
+=0A=
+typedef struct _PartitionRecord_t {=0A=
+	__u8 BootIndicator;	/* Not used by EFI firmware. Set to 0x80 to =
indicate that this=0A=
+				   is the bootable legacy partition. */=0A=
+	__u8 StartHead;		/* Start of partition in CHS address, not used by =
EFI firmware. */=0A=
+	__u8 StartSector;	/* Start of partition in CHS address, not used by =
EFI firmware. */=0A=
+	__u8 StartTrack;	/* Start of partition in CHS address, not used by =
EFI firmware. */=0A=
+	__u8 OSType;		/* OS type. A value of 0xEF defines an EFI system =
partition.=0A=
+				   Other values are reserved for legacy operating systems, and=0A=
+				   allocated independently of the EFI specification. */=0A=
+	__u8 EndHead;		/* End of partition in CHS address, not used by EFI =
firmware. */=0A=
+	__u8 EndSector;		/* End of partition in CHS address, not used by EFI =
firmware. */=0A=
+	__u8 EndTrack;		/* End of partition in CHS address, not used by EFI =
firmware. */=0A=
+	__u32 StartingLBA;	/* Starting LBA address of the partition on the =
disk. Used by=0A=
+				   EFI firmware to define the start of the partition. */=0A=
+	__u32 SizeInLBA;	/* Size of partition in LBA. Used by EFI firmware to =
determine=0A=
+				   the size of the partition. */=0A=
+} __attribute__ ((packed)) PartitionRecord_t;=0A=
+=0A=
+=0A=
+/* Protected Master Boot Record  & Legacy MBR share same structure =
*/=0A=
+/* Needs to be packed because the u16s force misalignment. */=0A=
+=0A=
+typedef struct _LegacyMBR_t {=0A=
+	__u8 BootCode[440];=0A=
+	__u32 UniqueMBRSignature;=0A=
+	__u16 Unknown;=0A=
+	PartitionRecord_t PartitionRecord[4];=0A=
+	__u16 Signature;=0A=
+} __attribute__ ((packed)) LegacyMBR_t;=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+#define EFI_GPT_PRIMARY_PARTITION_TABLE_LBA 1=0A=
+=0A=
+=0A=
+/* Parted has a PedDisk field disk_specific that we'll keep=0A=
+   our own useful info in.=0A=
+*/=0A=
+typedef struct _GPTDiskData {=0A=
+        GuidPartitionTableHeader_t *pgpt;=0A=
+ 	GuidPartitionTableHeader_t *agpt;=0A=
+ 	GuidPartitionEntry_t       *ptes;=0A=
+} GPTDiskData;=0A=
+=0A=
+/* Parted has a PedPartition field disk_specific that we'll keep=0A=
+   our own useful info in.=0A=
+*/=0A=
+typedef struct _GPTPartitionData {=0A=
+        GuidPartitionEntry_t *  pte;=0A=
+} GPTPartitionData;=0A=
+=0A=
+=0A=
+#define GPT_NAME	"GPT"=0A=
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
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/Makefile.am =
parted-1.4.7-gpt/libparted/Makefile.am=0A=
--- parted-1.4.7/libparted/Makefile.am	Mon Jan  8 13:57:26 2001=0A=
+++ parted-1.4.7-gpt/libparted/Makefile.am	Thu Jan 18 11:24:42 2001=0A=
@@ -15,12 +15,23 @@=0A=
 			llseek.c		\=0A=
 			llseek.h		\=0A=
 			natmath.c		\=0A=
+			crc32.c			\=0A=
 			disk.c			\=0A=
 			disk_bsd.c		\=0A=
 			disk_dos.c		\=0A=
 			disk_loop.c		\=0A=
 			disk_mac.c		\=0A=
-			disk_pc98.c=0A=
+			disk_pc98.c		\=0A=
+			disk_gpt.c              \=0A=
+			device_scsi.c           \=0A=
+			device_scsi.h           \=0A=
+			sg_map.c                \=0A=
+			sg_map.h                \=0A=
+			sg_dd.c                 \=0A=
+			sg_dd.h                 \=0A=
+			sg_err.c                \=0A=
+			sg_err.h             =0A=
+=0A=
 =0A=
 libparted_la_LIBADD   =3D	fs_ext2/libext2.la		\=0A=
 			fs_fat/libfat.la		\=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/crc32.c =
parted-1.4.7-gpt/libparted/crc32.c=0A=
--- parted-1.4.7/libparted/crc32.c	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/crc32.c	Thu Jan 18 11:24:42 2001=0A=
@@ -0,0 +1,125 @@=0A=
+/* =0A=
+ * Dec 5, 2000 Matt Domsch <Matt_Domsch@dell.com>=0A=
+ * - Copied crc32.c from the linux/drivers/net/cipe directory.=0A=
+ * - Now pass seed as an arg=0A=
+ * - changed unsigned long to __u32, added #include<linux/types.h>=0A=
+ * - changed len to be an unsigned long=0A=
+ * - changed crc32val to be a register=0A=
+ * - License remains unchanged!  It's still GPL-compatable!=0A=
+ */=0A=
+=0A=
+  /* =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */=0A=
+  /*  COPYRIGHT (C) 1986 Gary S. Brown.  You may use this program, or  =
     */=0A=
+  /*  code or tables extracted from it, as desired without =
restriction.     */=0A=
+  /*                                                                   =
     */=0A=
+  /*  First, the polynomial itself and its table of feedback terms.  =
The    */=0A=
+  /*  polynomial is                                                    =
     */=0A=
+  /*  =
X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0   =
*/=0A=
+  /*                                                                   =
     */=0A=
+  /*  Note that we take it "backwards" and put the highest-order term =
in    */=0A=
+  /*  the lowest-order bit.  The X^32 term is "implied"; the LSB is =
the     */=0A=
+  /*  X^31 term, etc.  The X^0 term (usually shown as "+1") results in =
     */=0A=
+  /*  the MSB being 1.                                                 =
     */=0A=
+  /*                                                                   =
     */=0A=
+  /*  Note that the usual hardware shift register implementation, =
which     */=0A=
+  /*  is what we're using (we're merely optimizing it by doing =
eight-bit    */=0A=
+  /*  chunks at a time) shifts bits into the lowest-order term.  In =
our     */=0A=
+  /*  implementation, that means shifting towards the right.  Why do =
we     */=0A=
+  /*  do it this way?  Because the calculated CRC must be transmitted =
in    */=0A=
+  /*  order from highest-order term to lowest-order term.  UARTs =
transmit   */=0A=
+  /*  characters in order from LSB to MSB.  By storing the CRC this =
way,    */=0A=
+  /*  we hand it to the UART in the order low-byte to high-byte; the =
UART   */=0A=
+  /*  sends each low-bit to hight-bit; and the result is transmission =
bit   */=0A=
+  /*  by bit from highest- to lowest-order term without requiring any =
bit   */=0A=
+  /*  shuffling on our part.  Reception works similarly.               =
     */=0A=
+  /*                                                                   =
     */=0A=
+  /*  The feedback terms table consists of 256, 32-bit entries.  =
Notes:     */=0A=
+  /*                                                                   =
     */=0A=
+  /*      The table can be generated at runtime if desired; code to do =
so   */=0A=
+  /*      is shown later.  It might not be obvious, but the feedback   =
     */=0A=
+  /*      terms simply represent the results of eight shift/xor opera- =
     */=0A=
+  /*      tions for all combinations of data and CRC register values.  =
     */=0A=
+  /*                                                                   =
     */=0A=
+  /*      The values must be right-shifted by eight bits by the =
"updcrc"    */=0A=
+  /*      logic; the shift must be unsigned (bring in zeroes).  On =
some     */=0A=
+  /*      hardware you could probably optimize the shift in assembler =
by    */=0A=
+  /*      using byte-swap instructions.                                =
     */=0A=
+  /*      polynomial $edb88320                                         =
     */=0A=
+  /*                                                                   =
     */=0A=
+  /*  =
--------------------------------------------------------------------  =
*/=0A=
+=0A=
+#include<linux/types.h>=0A=
+=0A=
+static __u32 crc32_tab[] =3D {=0A=
+      0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, =
0x076dc419L,=0A=
+      0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, =
0x79dcb8a4L,=0A=
+      0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, =
0xe7b82d07L,=0A=
+      0x90bf1d91L, 0x1db71064L, 0x6ab020f2L, 0xf3b97148L, =
0x84be41deL,=0A=
+      0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L, 0x83d385c7L, =
0x136c9856L,=0A=
+      0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL, =
0x63066cd9L,=0A=
+      0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, =
0xd56041e4L,=0A=
+      0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, =
0xa50ab56bL,=0A=
+      0x35b5a8faL, 0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, =
0x32d86ce3L,=0A=
+      0x45df5c75L, 0xdcd60dcfL, 0xabd13d59L, 0x26d930acL, =
0x51de003aL,=0A=
+      0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L, 0x56b3c423L, =
0xcfba9599L,=0A=
+      0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L, =
0xb10be924L,=0A=
+      0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, =
0x76dc4190L,=0A=
+      0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, =
0x06b6b51fL,=0A=
+      0x9fbfe4a5L, 0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, =
0x9609a88eL,=0A=
+      0xe10e9818L, 0x7f6a0dbbL, 0x086d3d2dL, 0x91646c97L, =
0xe6635c01L,=0A=
+      0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L, 0xf262004eL, =
0x6c0695edL,=0A=
+      0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L, =
0x12b7e950L,=0A=
+      0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, =
0x8cd37cf3L,=0A=
+      0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, =
0xd4bb30e2L,=0A=
+      0x4adfa541L, 0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, =
0x4369e96aL,=0A=
+      0x346ed9fcL, 0xad678846L, 0xda60b8d0L, 0x44042d73L, =
0x33031de5L,=0A=
+      0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL, 0x270241aaL, =
0xbe0b1010L,=0A=
+      0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L, =
0xce61e49fL,=0A=
+      0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, =
0x59b33d17L,=0A=
+      0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, =
0x9abfb3b6L,=0A=
+      0x03b6e20cL, 0x74b1d29aL, 0xead54739L, 0x9dd277afL, =
0x04db2615L,=0A=
+      0x73dc1683L, 0xe3630b12L, 0x94643b84L, 0x0d6d6a3eL, =
0x7a6a5aa8L,=0A=
+      0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L, 0x7d079eb1L, =
0xf00f9344L,=0A=
+      0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL, =
0x806567cbL,=0A=
+      0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, =
0x10da7a5aL,=0A=
+      0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, =
0x60b08ed5L,=0A=
+      0xd6d6a3e8L, 0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, =
0xd1bb67f1L,=0A=
+      0xa6bc5767L, 0x3fb506ddL, 0x48b2364bL, 0xd80d2bdaL, =
0xaf0a1b4cL,=0A=
+      0x36034af6L, 0x41047a60L, 0xdf60efc3L, 0xa867df55L, =
0x316e8eefL,=0A=
+      0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L, =
0x5268e236L,=0A=
+      0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, =
0xc5ba3bbeL,=0A=
+      0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, =
0xb5d0cf31L,=0A=
+      0x2cd99e8bL, 0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, =
0x756aa39cL,=0A=
+      0x026d930aL, 0x9c0906a9L, 0xeb0e363fL, 0x72076785L, =
0x05005713L,=0A=
+      0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL, 0x0cb61b38L, =
0x92d28e9bL,=0A=
+      0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L, =
0xf1d4e242L,=0A=
+      0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, =
0x6fb077e1L,=0A=
+      0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, =
0x11010b5cL,=0A=
+      0x8f659effL, 0xf862ae69L, 0x616bffd3L, 0x166ccf45L, =
0xa00ae278L,=0A=
+      0xd70dd2eeL, 0x4e048354L, 0x3903b3c2L, 0xa7672661L, =
0xd06016f7L,=0A=
+      0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL, 0xd9d65adcL, =
0x40df0b66L,=0A=
+      0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL, =
0x30b5ffe9L,=0A=
+      0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, =
0xbad03605L,=0A=
+      0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, =
0xc4614ab8L,=0A=
+      0x5d681b02L, 0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, =
0x5a05df1bL,=0A=
+      0x2d02ef8dL=0A=
+   };=0A=
+=0A=
+/* Return a 32-bit CRC of the contents of the buffer. */=0A=
+=0A=
+__u32=0A=
+crc32(const void *buf, unsigned long len, __u32 seed)=0A=
+{=0A=
+  unsigned long i;=0A=
+  register __u32 crc32val;=0A=
+  const unsigned char *s =3D buf;=0A=
+=0A=
+  crc32val =3D seed;=0A=
+  for (i =3D 0;  i < len;  i ++)=0A=
+    {=0A=
+      crc32val =3D=0A=
+	crc32_tab[(crc32val ^ s[i]) & 0xff] ^=0A=
+	  (crc32val >> 8);=0A=
+    }=0A=
+  return crc32val;=0A=
+}=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/device.c =
parted-1.4.7-gpt/libparted/device.c=0A=
--- parted-1.4.7/libparted/device.c	Tue Jan  9 12:28:22 2001=0A=
+++ parted-1.4.7-gpt/libparted/device.c	Thu Jan 18 11:24:42 2001=0A=
@@ -41,6 +41,7 @@=0A=
 #include <sys/sysmacros.h>=0A=
 #include <sys/stat.h>=0A=
 #include <scsi/scsi.h>=0A=
+#include "device_scsi.h"=0A=
 =0A=
 #include <parted/parted.h>=0A=
 =0A=
@@ -828,6 +829,20 @@=0A=
 	PED_ASSERT (!dev->external_mode, return 0);=0A=
 	PED_ASSERT (buffer !=3D NULL, return 0);=0A=
 =0A=
+=0A=
+	/* Kludge.  This is necessary to read/write the last=0A=
+	   block of an odd-sized SCSI disk, until 2.5.x kernel fixes.=0A=
+	   This is only used by disk_gpt.c, and only to read/write=0A=
+	   one sector, so we don't have to be fancy.=0A=
+	*/=0A=
+=0A=
+	if (dev->type =3D=3D PED_DEVICE_SCSI &&=0A=
+	    (dev->length & 1) &&=0A=
+	    (count =3D=3D 1) &&=0A=
+	    start =3D=3D dev->length - 1) {=0A=
+		return ped_device_read_scsi(dev, buffer, start, count);=0A=
+	}=0A=
+=0A=
 	while (1) {=0A=
 		if (ped_device_seek (dev, start))=0A=
 			break;=0A=
@@ -946,6 +961,19 @@=0A=
 			return 0;=0A=
 		else=0A=
 			return 1;=0A=
+	}=0A=
+=0A=
+	/* Kludge.  This is necessary to read/write the last=0A=
+	   block of an odd-sized SCSI disk, until 2.5.x kernel fixes.=0A=
+	   This is only used by disk_gpt.c, and only to read/write=0A=
+	   one sector, so we don't have to be fancy.=0A=
+	*/=0A=
+=0A=
+	if (dev->type =3D=3D PED_DEVICE_SCSI &&=0A=
+	    (dev->length & 1) &&=0A=
+	    (count =3D=3D 1) &&=0A=
+	    start =3D=3D dev->length - 1) {=0A=
+		return ped_device_write_scsi(dev, buffer, start, count);=0A=
 	}=0A=
 =0A=
 	while (1) {=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/device_scsi.c =
parted-1.4.7-gpt/libparted/device_scsi.c=0A=
--- parted-1.4.7/libparted/device_scsi.c	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/device_scsi.c	Thu Jan 18 11:24:42 =
2001=0A=
@@ -0,0 +1,102 @@=0A=
+/*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+#include<stdio.h>=0A=
+#include<stdlib.h>=0A=
+#include<string.h>=0A=
+#include <fcntl.h>=0A=
+=0A=
+#include <parted/parted.h>=0A=
+#include"sg_map.h"=0A=
+#include"sg_dd.h"=0A=
+=0A=
+static const char *=0A=
+sg_from_sd(const char *sd)=0A=
+{=0A=
+	int i;=0A=
+	for (i=3D0; i<MAX_SG_DEVS; i++)=0A=
+		if (!strncmp(sd, sg_to_sd[i].sd, 16)) return sg_to_sd[i].sg;=0A=
+	return NULL;=0A=
+}=0A=
+=0A=
+int=0A=
+ped_device_read_scsi (PedDevice* dev, const void* buffer, PedSector =
start,=0A=
+		      PedSector count)=0A=
+{=0A=
+	const char *sg =3D NULL;=0A=
+	extern int sg_to_sd_map_made;=0A=
+	int rc;=0A=
+	int sg_fd, diop =3D 0;=0A=
+=0A=
+	// printf("in ped_device_read_scsi()\n");=0A=
+	PED_ASSERT(dev !=3D NULL, return 0);=0A=
+	PED_ASSERT(dev->type =3D=3D PED_DEVICE_SCSI, return 0);=0A=
+	PED_ASSERT(buffer !=3D NULL, return 0);=0A=
+	PED_ASSERT(count =3D=3D 1, return 0);	=0A=
+	=0A=
+	if (!sg_to_sd_map_made) make_sg_to_sd_map();=0A=
+=0A=
+	sg =3D sg_from_sd(dev->path);=0A=
+	if (!sg) return 0;=0A=
+=0A=
+	// printf("sg=3D%s\n", sg);=0A=
+	/* Must open RDRW because we write the command to the disk=0A=
+	   then read the results */=0A=
+	if ((sg_fd =3D open(sg, O_RDWR)) < 0)=0A=
+                return 0;=0A=
+	=0A=
+	rc =3D sg_read(sg_fd, (unsigned char *)buffer, count, start,=0A=
+		     dev->sector_size, &diop);=0A=
+	=0A=
+	close(sg_fd);=0A=
+	return !rc;=0A=
+}=0A=
+=0A=
+int=0A=
+ped_device_write_scsi (PedDevice* dev, const void* buffer, PedSector =
start,=0A=
+		       PedSector count)=0A=
+{=0A=
+	char *sg =3D NULL;=0A=
+	extern int sg_to_sd_map_made;=0A=
+	int rc;=0A=
+	int sg_fd, diop =3D 0;=0A=
+=0A=
+	// printf("in ped_device_write_scsi()\n");=0A=
+	PED_ASSERT(dev !=3D NULL, return 0);=0A=
+	PED_ASSERT(dev->type =3D=3D PED_DEVICE_SCSI, return 0);=0A=
+	PED_ASSERT(buffer !=3D NULL, return 0);=0A=
+	PED_ASSERT(count =3D=3D 1, return 0);	=0A=
+=0A=
+	if (!sg_to_sd_map_made) make_sg_to_sd_map();=0A=
+	sg =3D sg_from_sd(dev->path);=0A=
+	if (!sg) return 0;=0A=
+=0A=
+	// printf("sg=3D%s\n", sg);=0A=
+	/* Must open RDRW because we write the command to the disk=0A=
+	   then read the results */=0A=
+	if ((sg_fd =3D open(sg, O_RDWR)) < 0)=0A=
+                return 0;=0A=
+	=0A=
+	rc =3D sg_write(sg_fd, (unsigned char *)buffer, count, start,=0A=
+		     dev->sector_size, &diop);=0A=
+	=0A=
+	close(sg_fd);=0A=
+	return !rc;=0A=
+=0A=
+}=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/device_scsi.h =
parted-1.4.7-gpt/libparted/device_scsi.h=0A=
--- parted-1.4.7/libparted/device_scsi.h	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/device_scsi.h	Thu Jan 18 11:24:42 =
2001=0A=
@@ -0,0 +1,28 @@=0A=
+/*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+#include "parted/device.h"=0A=
+=0A=
+int=0A=
+ped_device_read_scsi (PedDevice* dev, const void* buffer, PedSector =
start,=0A=
+		      PedSector count);=0A=
+int=0A=
+ped_device_write_scsi (PedDevice* dev, const void* buffer, PedSector =
start,=0A=
+		       PedSector count);=0A=
+=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/disk.c parted-1.4.7-gpt/libpart=
ed/disk.c=0A=
--- parted-1.4.7/libparted/disk.c	Mon Jan  8 10:49:15 2001=0A=
+++ parted-1.4.7-gpt/libparted/disk.c	Thu Jan 18 11:32:50 2001=0A=
@@ -174,6 +174,7 @@=0A=
 	disk->dev =3D dev;=0A=
 	disk->type =3D disk_type;=0A=
 	disk->update_mode =3D 0;=0A=
+	disk->disk_specific =3D NULL;=0A=
 =0A=
 	disk->part_list =3D ped_partition_new (=0A=
 		disk, PED_PARTITION_FREESPACE, NULL,=0A=
@@ -581,6 +582,7 @@=0A=
 	part->type =3D type;=0A=
 	part->part_list =3D NULL;=0A=
 	part->fs_type =3D fs_type;=0A=
+	part->disk_specific =3D NULL;=0A=
 =0A=
 	return part;=0A=
 =0A=
@@ -599,6 +601,8 @@=0A=
 	PedPartition*	part;=0A=
 =0A=
 	PED_ASSERT (disk !=3D NULL, return NULL);=0A=
+	PED_ASSERT (disk->type !=3D NULL, return NULL);=0A=
+	PED_ASSERT (disk->type->ops !=3D NULL, return NULL);=0A=
 	PED_ASSERT (disk->type->ops->partition_new !=3D NULL, return =
NULL);=0A=
 =0A=
 	supports_extended =3D ped_disk_type_check_feature (disk->type,=0A=
@@ -1314,10 +1318,10 @@=0A=
 	PED_ASSERT (part !=3D NULL, return 0);=0A=
 =0A=
 #ifdef VERBOSE=0A=
-	printf ("ped_disk_add_partition (dev=3D\"%s\", start=3D%d, =
end=3D%d,"=0A=
+	printf ("ped_disk_add_partition (dev=3D\"%s\", start=3D%llx, =
end=3D%llx,"=0A=
 		" type=3D%x)\n",=0A=
-		disk->dev->path, (int) part->geom.start, (int) part->geom.end,=0A=
-		(int) part->system);=0A=
+		disk->dev->path, part->geom.start, part->geom.end,=0A=
+		part->type);=0A=
 #endif=0A=
 =0A=
 	if (!ped_disk_type_check_feature (disk->type, =
PED_DISK_TYPE_EXTENDED)=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/disk_dos.c =
parted-1.4.7-gpt/libparted/disk_dos.c=0A=
--- parted-1.4.7/libparted/disk_dos.c	Tue Jan  9 12:29:52 2001=0A=
+++ parted-1.4.7-gpt/libparted/disk_dos.c	Mon Jan 22 11:42:31 2001=0A=
@@ -232,6 +232,12 @@=0A=
 			return 0;=0A=
 	}=0A=
 =0A=
+	/* If this is a GPT disk, fail here */=0A=
+	for (i =3D 0; i < 4; i++) {=0A=
+		if (part_table.partitions[i].type =3D=3D 0xEE)=0A=
+ 			return 0;=0A=
+ 	}=0A=
+=0A=
 	/* HACK: it's impossible to tell PC98 and msdos disk labels apart.=0A=
 	 * Someone made the signatures the same (very clever).  Since=0A=
 	 * PC98 has some idiosyncracies with it's boot-loader, it's =
detection=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/disk_gpt.c =
parted-1.4.7-gpt/libparted/disk_gpt.c=0A=
--- parted-1.4.7/libparted/disk_gpt.c	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/disk_gpt.c	Wed Jan 24 11:47:09 2001=0A=
@@ -0,0 +1,1738 @@=0A=
+/*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+=0A=
+    Copyright (C) 2000-2001 Dell Computer Corporation=0A=
+    disk_gpt.[ch] by Matt Domsch <Matt_Domsch@dell.com> =0A=
+=0A=
+    EFI GUID Partition Table handling=0A=
+    Per Intel EFI Specification v1.02=0A=
+    http://developer.intel.com/technology/efi/efi.htm=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+/* =0A=
+   TODO:=0A=
+   - Make partition labels get/set properly=0A=
+*/=0A=
+=0A=
+#include "config.h"=0A=
+=0A=
+#include <parted/parted.h>=0A=
+#include <parted/endian.h>=0A=
+#include <parted/crc32.h>=0A=
+#include <parted/disk_gpt.h>=0A=
+#include <parted/natmath.h>=0A=
+#include <stdio.h>=0A=
+#include <string.h>=0A=
+#include <stdlib.h>=0A=
+#include <sys/types.h>=0A=
+#include <sys/ioctl.h>=0A=
+#include <fcntl.h>=0A=
+#include <unistd.h>=0A=
+#include <uuid/uuid.h>=0A=
+#include <unicode.h>=0A=
+=0A=
+#include <libintl.h>=0A=
+#if ENABLE_NLS=0A=
+#  define _(String) gettext (String)=0A=
+#else=0A=
+#  define _(String) (String)=0A=
+#endif				/* ENABLE_NLS */=0A=
+=0A=
+=0A=
+void ped_disk_gpt_init();=0A=
+void ped_disk_gpt_done();=0A=
+=0A=
+static int gpt_probe(const PedDevice * dev);=0A=
+static PedDisk *gpt_open(PedDevice * dev);=0A=
+static PedDisk *gpt_create(PedDevice * dev);=0A=
+static int gpt_clobber(PedDevice * dev);=0A=
+static int gpt_close(PedDisk * disk);=0A=
+static int gpt_read(PedDisk * disk);=0A=
+static int gpt_write(PedDisk * disk);=0A=
+=0A=
+=0A=
+static PedPartition *gpt_partition_new(const PedDisk *disk,=0A=
+                             PedPartitionType part_type,=0A=
+                             const PedFileSystemType* fs_type,=0A=
+                             PedSector start,=0A=
+                             PedSector end);=0A=
+static void gpt_partition_destroy(PedPartition *part);=0A=
+static int gpt_partition_set_flag(PedPartition *part,=0A=
+                                  PedPartitionFlag flag,=0A=
+                                  int state);=0A=
+static int gpt_partition_get_flag(const PedPartition *part,=0A=
+                                  PedPartitionFlag flag);=0A=
+static int gpt_partition_is_flag_available(const PedPartition * =
part,=0A=
+                                           PedPartitionFlag flag);=0A=
+static void gpt_partition_set_name(PedPartition *part,=0A=
+                                   const char *name);=0A=
+static const char * gpt_partition_get_name (const PedPartition * =
part);=0A=
+static int gpt_partition_align(PedPartition * part,=0A=
+                               const PedConstraint * constraint);=0A=
+static int gpt_partition_enumerate(PedPartition * part);=0A=
+=0A=
+static int gpt_alloc_metadata(PedDisk * disk);=0A=
+static int gpt_get_max_primary_partition_count(const PedDisk =
*disk);=0A=
+=0A=
+/* gpt private function */=0A=
+static PedDisk * gpt_new(PedDisk * disk);=0A=
+=0A=
+static PedDiskOps gpt_disk_ops =3D {=0A=
+	probe                           : gpt_probe,=0A=
+	open                            : gpt_open,=0A=
+	create                          : gpt_create,=0A=
+        clobber                         : gpt_clobber,=0A=
+	close                           : gpt_close,=0A=
+	read                            : gpt_read,=0A=
+	write                           : gpt_write,=0A=
+        partition_new                   : gpt_partition_new,=0A=
+        partition_destroy               : gpt_partition_destroy,=0A=
+        partition_set_flag              : gpt_partition_set_flag,=0A=
+        partition_get_flag              : gpt_partition_get_flag,=0A=
+        partition_is_flag_available     : =
gpt_partition_is_flag_available,=0A=
+        partition_set_name              : gpt_partition_set_name,=0A=
+        partition_get_name              : gpt_partition_get_name,=0A=
+	partition_align                 : gpt_partition_align,=0A=
+	partition_enumerate             : gpt_partition_enumerate,=0A=
+	partition_set_extended_system   : NULL,=0A=
+	alloc_metadata                  : gpt_alloc_metadata,=0A=
+        get_max_primary_partition_count : =
gpt_get_max_primary_partition_count=0A=
+=0A=
+};=0A=
+=0A=
+static PedDiskType gpt_disk_type =3D {=0A=
+	next:NULL,=0A=
+	name:GPT_NAME,=0A=
+	ops:&gpt_disk_ops,=0A=
+        features: PED_DISK_TYPE_PARTITION_NAME=0A=
+};=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * efi_crc32()=0A=
+ * Requires:=0A=
+ *  - a buffer of length len=0A=
+ * Modifies: nothing=0A=
+ * Returns:=0A=
+ *  EFI-style CRC32 value for buf=0A=
+ *  =0A=
+ * This function uses the crc32 function by Gary S. Brown,=0A=
+ * but seeds the function with ~0, and xor's with ~0 at the end.=0A=
+ ************************************************************/=0A=
+=0A=
+static inline __u32=0A=
+efi_crc32(const void *buf, unsigned long len)=0A=
+{=0A=
+  return (crc32(buf, len, ~0L) ^ ~0L);=0A=
+}=0A=
+=0A=
+=0A=
+static inline int=0A=
+IsLegacyMBRValid(LegacyMBR_t * mbr)=0A=
+{=0A=
+	return (mbr ? (mbr->Signature =3D=3D MSDOS_MBR_SIGNATURE) : 0);=0A=
+}=0A=
+=0A=
+static inline int=0A=
+efi_guidcmp(efi_guid_t left, efi_guid_t right)=0A=
+{=0A=
+	return memcmp(&left, &right, sizeof(efi_guid_t));=0A=
+}=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * LastLBA()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ * Modifies: nothing=0A=
+ * Returns:=0A=
+ *  Last LBA value on success =0A=
+ *  0 on error=0A=
+ ************************************************************/=0A=
+=0A=
+=0A=
+static __u64=0A=
+LastLBA(const PedDevice * dev)=0A=
+{=0A=
+        __u64 lastlba;=0A=
+	PED_ASSERT(dev !=3D NULL, return 0);=0A=
+        lastlba =3D dev->length - 1;=0A=
+        /* Kludge until either:=0A=
+           a) kernel can read/write last=0A=
+           block on an odd-sized disk, or =0A=
+           b) we use scsi-generic to do it.=0A=
+        */=0A=
+        // if (!(lastlba & 1)) lastlba--;=0A=
+        return lastlba;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * IsLBAValid()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ *  - lba is the logical block address desired=0A=
+ * Modifies: nothing=0A=
+ * Returns:=0A=
+ * - 1 if true=0A=
+ * - 0 if false=0A=
+ ************************************************************/=0A=
+=0A=
+=0A=
+=0A=
+static inline int=0A=
+IsLBAValid(PedDevice *dev, __u64 lba)=0A=
+{=0A=
+	return (lba <=3D LastLBA(dev));=0A=
+}=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * WriteLBA()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ *  - lba is the logical block address desired=0A=
+ *  - buffer is a buffer of size size into which data is read=0A=
+ *  - size_t count is size of the read (in bytes)=0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ * Returns:=0A=
+ *  - 1 on success=0A=
+ *  - 0 on error=0A=
+ ************************************************************/=0A=
+=0A=
+static int=0A=
+WriteLBA(PedDevice * dev, __u64 lba, void *buffer, size_t count)=0A=
+{=0A=
+	size_t blocks;=0A=
+        //printf("WriteLBA(lba=3D%llx, count=3D%llx)\n", lba, =
count);=0A=
+        PED_ASSERT(dev !=3D NULL, return 0);=0A=
+        PED_ASSERT(dev->sector_size !=3D 0, return 0);=0A=
+	blocks =3D count / dev->sector_size;=0A=
+	if (count % dev->sector_size)=0A=
+		blocks++;=0A=
+	return ped_device_write(dev, buffer, lba, blocks);=0A=
+}=0A=
+=0A=
+/************************************************************=0A=
+ * ReadLBA()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ *  - lba is the logical block address desired=0A=
+ *  - buffer is a buffer of size size into which data is read=0A=
+ *  - size_t count is size of the read (in bytes)=0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ * Returns:=0A=
+ *  - 1 on success=0A=
+ *  - 0 on error=0A=
+ ************************************************************/=0A=
+=0A=
+static int=0A=
+ReadLBA(const PedDevice * dev, __u64 lba, void *buffer, size_t =
count)=0A=
+{=0A=
+	size_t blocks;=0A=
+        PED_ASSERT(dev !=3D NULL, return 0);=0A=
+        PED_ASSERT(dev->sector_size !=3D 0, return 0);=0A=
+        //printf("ReadLBA(lba=3D%llx, count=3D%llx)\n", lba, =
count);=0A=
+	blocks =3D count / dev->sector_size;=0A=
+	if (count % dev->sector_size)=0A=
+		blocks++;=0A=
+	return ped_device_read(dev, buffer, lba, blocks);=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * ReadGuidPartitionEntries()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ *  - lba is the Logical Block Address of the partition table=0A=
+ *  - gpt is a buffer into which the GPT will be put  =0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ *  - gpt=0A=
+ * Returns:=0A=
+ *   pte on success=0A=
+ *   NULL on error=0A=
+ * Notes: remember to free pte when you're done!=0A=
+ ************************************************************/=0A=
+static GuidPartitionEntry_t *=0A=
+ReadGuidPartitionEntries(const PedDevice * dev,=0A=
+                         GuidPartitionTableHeader_t *=0A=
+                         gpt)=0A=
+{=0A=
+	GuidPartitionEntry_t *pte;=0A=
+=0A=
+	PED_ASSERT(dev !=3D NULL, return NULL);=0A=
+	PED_ASSERT(gpt !=3D NULL, return NULL);=0A=
+=0A=
+	pte =3D (GuidPartitionEntry_t *)=0A=
+                ped_malloc(gpt->NumberOfPartitionEntries *=0A=
+                           gpt->SizeOfPartitionEntry);=0A=
+=0A=
+        PED_ASSERT(pte !=3D NULL, return NULL);=0A=
+=0A=
+        memset(pte, 0, gpt->NumberOfPartitionEntries *=0A=
+               gpt->SizeOfPartitionEntry);=0A=
+=0A=
+=0A=
+	if (!ReadLBA(dev, gpt->PartitionEntryLBA, pte,=0A=
+		     gpt->NumberOfPartitionEntries *=0A=
+		     gpt->SizeOfPartitionEntry)) {=0A=
+		free(pte);=0A=
+		return NULL;=0A=
+	}=0A=
+	return pte;=0A=
+}=0A=
+=0A=
+/************************************************************=0A=
+ * WriteGuidPartitionEntries()=0A=
+ * Requires:=0A=
+ *  - PedDevice *dev=0A=
+ *  - gpt =0A=
+ *  - pte is a buffer that will be written=0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ *  - gpt=0A=
+ * Returns:=0A=
+ *   pte on success=0A=
+ *   NULL on error=0A=
+ * Notes: remember to free pte when you're done!=0A=
+ ************************************************************/=0A=
+static GuidPartitionEntry_t *=0A=
+WriteGuidPartitionEntries(PedDevice * dev,=0A=
+                          GuidPartitionTableHeader_t * gpt,=0A=
+                          GuidPartitionEntry_t *ptes)=0A=
+{=0A=
+        PED_ASSERT(gpt !=3D NULL, return NULL);=0A=
+        PED_ASSERT(ptes !=3D NULL, return NULL);=0A=
+=0A=
+	if (!WriteLBA=0A=
+	    (dev, gpt->PartitionEntryLBA, ptes,=0A=
+	     gpt->NumberOfPartitionEntries *=0A=
+	     gpt->SizeOfPartitionEntry)) return NULL;=0A=
+	return ptes;=0A=
+}=0A=
+=0A=
+=0A=
+static void=0A=
+PrintGuidPartitionEntry(GuidPartitionEntry_t * pte, int i)=0A=
+{=0A=
+	efi_guid_t unused_guid =3D UNUSED_ENTRY_GUID;=0A=
+	char uuid_buffer[40];=0A=
+	uuid_t uuid;=0A=
+        PED_ASSERT(pte !=3D NULL, return);=0A=
+	if (!efi_guidcmp(pte->PartitionTypeGuid, unused_guid)) {=0A=
+		// printf("UNUSED_ENTRY_GUID\n");=0A=
+		return;=0A=
+	}=0A=
+	printf("GUID Partition Entry %d:\n", i);=0A=
+	memcpy(uuid, &pte->PartitionTypeGuid, sizeof(uuid_t));=0A=
+	uuid_unparse(uuid, uuid_buffer);=0A=
+	printf("\tPartitionTypeGuid : %s\n", uuid_buffer);=0A=
+	memcpy(uuid, &pte->UniquePartitionGuid, sizeof(uuid_t));=0A=
+	uuid_unparse(uuid, uuid_buffer);=0A=
+	printf("\tUniquePartitionGuid : %s\n", uuid_buffer);=0A=
+	printf("\tStartingLBA : %llx\n", pte->StartingLBA);=0A=
+	printf("\tEndingLBA   : %llx\n", pte->EndingLBA);=0A=
+	printf("\tAttributes  : ");=0A=
+	printf("\tRequiredToFunction: %x",=0A=
+	       pte->Attributes.RequiredToFunction);=0A=
+	printf("\tGuidSpecific: %x\n",=0A=
+	       pte->Attributes.GuidSpecific);=0A=
+        =0A=
+	//  printf("\tPartitionName : Unicode string.\n");=0A=
+	return;=0A=
+}=0A=
+=0A=
+=0A=
+static void=0A=
+PrintGuidPartitionTableHeader(GuidPartitionTableHeader_t * gpt)=0A=
+{=0A=
+	char uuid_buffer[40];=0A=
+	uuid_t uuid;=0A=
+	printf("GUID Partition Table Header\n");=0A=
+        PED_ASSERT(gpt !=3D NULL, return);=0A=
+	printf("Signature      : %llx\n", gpt->Signature);=0A=
+	printf("Revision       : %x\n", gpt->Revision);=0A=
+	printf("HeaderSize     : %x\n", gpt->HeaderSize);=0A=
+	printf("HeaderCRC32    : %x\n", gpt->HeaderCRC32);=0A=
+	printf("MyLBA          : %llx\n", gpt->MyLBA);=0A=
+	printf("AlternateLBA   : %llx\n", gpt->AlternateLBA);=0A=
+	printf("FirstUsableLBA : %llx\n", gpt->FirstUsableLBA);=0A=
+	printf("LastUsableLBA  : %llx\n", gpt->LastUsableLBA);=0A=
+	memcpy(uuid, &gpt->DiskGUID, sizeof(uuid_t));=0A=
+	uuid_unparse(uuid, uuid_buffer);=0A=
+	printf("DiskGUID : %s\n", uuid_buffer);=0A=
+	printf("PartitionEntryLBA : %llx\n", gpt->PartitionEntryLBA);=0A=
+	printf("NumberOfPartitionEntries : %x\n",=0A=
+	       gpt->NumberOfPartitionEntries);=0A=
+	printf("SizeOfPartitionEntry : %x\n", gpt->SizeOfPartitionEntry);=0A=
+	printf("PartitionEntryArrayCRC32 : %x\n",=0A=
+	       gpt->PartitionEntryArrayCRC32); return;=0A=
+}=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * ReadGuidPartitionTableHeader()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ *  - lba is the Logical Block Address of the partition table=0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ * Returns:=0A=
+ *   GPTH on success=0A=
+ *   NULL on error=0A=
+ ************************************************************/=0A=
+static GuidPartitionTableHeader_t *=0A=
+ReadGuidPartitionTableHeader(const PedDevice * dev,=0A=
+                             __u64 lba)=0A=
+{=0A=
+	GuidPartitionTableHeader_t *gpt;=0A=
+	PED_ASSERT(dev !=3D NULL, return 0);=0A=
+	gpt =3D (GuidPartitionTableHeader_t *)=0A=
+	    ped_malloc(sizeof(GuidPartitionTableHeader_t));=0A=
+        if (!gpt) return NULL;=0A=
+        memset(gpt, 0, sizeof (*gpt));=0A=
+	if (!ReadLBA(dev, lba, gpt, sizeof(GuidPartitionTableHeader_t))) {=0A=
+		free(gpt);=0A=
+		return NULL;=0A=
+	}=0A=
+=0A=
+	return gpt;=0A=
+}=0A=
+=0A=
+/************************************************************=0A=
+ * WriteGuidPartitionTableHeader()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ *  - lba is the Logical Block Address of the partition table=0A=
+ *  - gpt is a buffer into which the GPT will be put  =0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ * Returns:=0A=
+ *   1 on success=0A=
+ *   0 on error=0A=
+ ************************************************************/=0A=
+static int=0A=
+WriteGuidPartitionTableHeader(PedDevice *dev,=0A=
+			      GuidPartitionTableHeader_t * gpt)=0A=
+{=0A=
+        PED_ASSERT(gpt !=3D NULL, return 0);=0A=
+	if (!WriteLBA=0A=
+	    (dev, gpt->MyLBA, gpt,=0A=
+	     sizeof(GuidPartitionTableHeader_t))) return 0;=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * IsGuidPartitionTableValid()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ *  - lba is the Logical Block Address of the partition table=0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ *  - gpt  - reads data into gpt=0A=
+ *  - ptes - reads data into ptes=0A=
+ * Returns:=0A=
+ *   1 if valid=0A=
+ *   0 on error=0A=
+ ************************************************************/=0A=
+=0A=
+=0A=
+static int=0A=
+IsGuidPartitionTableValid(const PedDevice * dev, __u64 lba,=0A=
+			  GuidPartitionTableHeader_t ** gpt,=0A=
+			  GuidPartitionEntry_t ** ptes)=0A=
+{=0A=
+	int rc =3D 0;		/* default to not valid */=0A=
+	__u32 crc, origcrc;=0A=
+	PED_ASSERT(gpt !=3D NULL, return 0);=0A=
+	PED_ASSERT(ptes !=3D NULL, return 0);=0A=
+        // printf("IsGuidPartitionTableValid(%llx)\n", lba);=0A=
+	if (!(*gpt =3D ReadGuidPartitionTableHeader(dev, lba)))=0A=
+		return rc;=0A=
+	/* Check the GUID Partition Table Signature */=0A=
+	if ((*gpt)->Signature !=3D GUID_PT_HEADER_SIGNATURE) {=0A=
+                /* =0A=
+                printf("GUID Partition Table Header Signature is =
wrong: %llx !=3D %llx\n",=0A=
+			(*gpt)->Signature, GUID_PT_HEADER_SIGNATURE);=0A=
+                */=0A=
+		free(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		return rc;=0A=
+	}=0A=
+=0A=
+	/* Check the GUID Partition Table Header CRC */=0A=
+	origcrc =3D (*gpt)->HeaderCRC32;=0A=
+	(*gpt)->HeaderCRC32 =3D 0;=0A=
+	crc =3D efi_crc32(*gpt, (*gpt)->HeaderSize);=0A=
+	if (crc !=3D origcrc) {=0A=
+		// printf( "GPTH CRC check failed, %x !=3D %x.\n", origcrc, crc);=0A=
+		(*gpt)->HeaderCRC32 =3D origcrc;=0A=
+		PrintGuidPartitionTableHeader(*gpt);=0A=
+		free(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		return rc;=0A=
+	}=0A=
+	(*gpt)->HeaderCRC32 =3D origcrc;=0A=
+	/* Check that the MyLBA entry points to the LBA=0A=
+	   that contains the GPT we read */=0A=
+	if ((*gpt)->MyLBA !=3D lba) {=0A=
+		// printf( "MyLBA %llx !=3D lba %llx.\n", (*gpt)->MyLBA, lba);=0A=
+		free(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		return rc;=0A=
+	}=0A=
+=0A=
+	if (!(*ptes =3D ReadGuidPartitionEntries(dev, *gpt))) {=0A=
+		free(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		return rc;=0A=
+	}=0A=
+=0A=
+=0A=
+	/* Check the GUID Partition Entry Array CRC */=0A=
+	crc =3D efi_crc32(*ptes, (*gpt)->NumberOfPartitionEntries *=0A=
+			   (*gpt)->SizeOfPartitionEntry);=0A=
+	if (crc !=3D (*gpt)->PartitionEntryArrayCRC32) {=0A=
+		// printf("GUID Partitition Entry Array CRC check failed.\n");=0A=
+		free(*gpt);=0A=
+		*gpt =3D NULL;=0A=
+		free(*ptes);=0A=
+		*ptes =3D NULL;=0A=
+		return rc;=0A=
+	}=0A=
+=0A=
+	/* We're done, all's well */=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+/************************************************************=0A=
+ * CreateNewPMBR()=0A=
+ * Requires:=0A=
+ *  - dev=0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ * Returns:=0A=
+ *   1 on success=0A=
+ *   0 on error=0A=
+ ************************************************************/=0A=
+=0A=
+=0A=
+static int=0A=
+CreateNewPMBR(PedDevice * dev)=0A=
+{=0A=
+	LegacyMBR_t pmbr;=0A=
+	memset(&pmbr, 0, sizeof(pmbr));=0A=
+	pmbr.Signature =3D MSDOS_MBR_SIGNATURE;=0A=
+	pmbr.PartitionRecord[0].OSType =3D EFI_PMBR_OSTYPE_EFI_GPT;=0A=
+	pmbr.PartitionRecord[0].EndHead =3D 0xFF;=0A=
+	pmbr.PartitionRecord[0].EndSector =3D 0xFE;=0A=
+	pmbr.PartitionRecord[0].EndTrack =3D 0xFF;=0A=
+	pmbr.PartitionRecord[0].StartingLBA =3D 1;=0A=
+	pmbr.PartitionRecord[0].SizeInLBA =3D LastLBA(dev) + 1;=0A=
+	if (!WriteLBA(dev, 0, &pmbr, sizeof(pmbr))) {=0A=
+=0A=
+		// printf("CreateNewPMBR(): Unable to create new PMBR.\n");=0A=
+		return 0;=0A=
+	}=0A=
+=0A=
+	return 1;=0A=
+=0A=
+}=0A=
+=0A=
+=0A=
+#if 0=0A=
+static int=0A=
+UpdateGuidPartition(PedPartition *part)=0A=
+{=0A=
+        GPTPartitionData *gpt_part_data;=0A=
+        PED_ASSERT(part !=3D NULL, return -1);=0A=
+        PED_ASSERT(part->disk_specific !=3D NULL, return 0);=0A=
+=0A=
+        gpt_part_data =3D part->disk_specific;=0A=
+        PED_ASSERT(gpt_part_data->pte !=3D NULL, return -1);=0A=
+=0A=
+        gpt_part_data->pte->StartingLBA =3D part->geom.start;=0A=
+        gpt_part_data->pte->EndingLBA   =3D part->geom.end;=0A=
+        gpt_part_data->pte->PartitionTypeGuid =3D  =
PARTITION_BASIC_DATA_GUID;=0A=
+=0A=
+        /* FIXME: need to change type to PARTITION_SYSTEM_GUID=0A=
+           or tag raid and lvm flags into attributes */=0A=
+=0A=
+        return 1;=0A=
+}=0A=
+#endif=0A=
+=0A=
+#if 0=0A=
+/***********************************=0A=
+ * CreateDefaultMSRGuidPartition()=0A=
+ *=0A=
+ * Returns: 1 on success, 0 on failure=0A=
+ *=0A=
+ */=0A=
+=0A=
+=0A=
+static int=0A=
+CreateDefaultMSRGuidPartition(GuidPartitionTableHeader_t * gpt,=0A=
+			      GuidPartitionEntry_t * pte)=0A=
+{=0A=
+	__u64 size;=0A=
+	int i;=0A=
+        PED_ASSERT(gpt !=3D NULL, return 0);=0A=
+        PED_ASSERT(pte !=3D NULL, return 0);=0A=
+=0A=
+	/* The rule is :=0A=
+	   On drives < 16GB, MSR is 32MB.=0A=
+	   On drives >=3D 16GB, MSR is 128MB.=0A=
+	 */=0A=
+=0A=
+	/* This accounts for block size =3D=3D 512 */=0A=
+	if (gpt->LastUsableLBA < 16 * 1024 * 1024 * 2)=0A=
+		size =3D (16 * 1024 * 1024) / 512;=0A=
+	else=0A=
+		size =3D (128 * 1024 * 1024) / 512;=0A=
+=0A=
+	i =3D CreateNextGuidPartition(gpt, pte, size);=0A=
+	if (i =3D=3D -1)=0A=
+		return 0;=0A=
+=0A=
+	pte[i].PartitionTypeGuid =3D PARTITION_MSFT_RESERVED_GUID;=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+=0A=
+static int=0A=
+CreateDefaultEFIGuidPartition(GuidPartitionTableHeader_t * gpt,=0A=
+			      GuidPartitionEntry_t * pte)=0A=
+{=0A=
+	int i;=0A=
+	__u64 size;=0A=
+        PED_ASSERT(gpt !=3D NULL, return 0);=0A=
+        PED_ASSERT(pte !=3D NULL, return 0);=0A=
+=0A=
+=0A=
+	/* The rule is :=0A=
+	   size =3D MAX(100MB, MIN(1% of physical disk, 1GB)) =0A=
+	 */=0A=
+	size =3D PED_MAX((100 * 1024 * 1024) / 512;=0A=
+		   PED_MIN(gpt->LastUsableLBA / 100,=0A=
+		       (1024 * 1024 * 1024) / 512));=0A=
+=0A=
+	i =3D CreateNextGuidPartition(gpt, pte, size);=0A=
+	if (i =3D=3D -1)=0A=
+		return 0;=0A=
+	pte[i].PartitionTypeGuid =3D PARTITION_SYSTEM_GUID;=0A=
+	return 1;=0A=
+}=0A=
+#endif=0A=
+=0A=
+/************************************************************n=0A=
+ * UpdateGuidPartitionTableHeaders()=0A=
+ * Updates the CRC fields for both primary and alternate GPTs=0A=
+ *=0A=
+ */=0A=
+static int=0A=
+UpdateGuidPartitionTableHeaders(GuidPartitionTableHeader_t *pgpt,=0A=
+                                GuidPartitionTableHeader_t *agpt,=0A=
+                                GuidPartitionEntry_t *ptes)=0A=
+{=0A=
+=0A=
+        // printf("in UpdateGuidPartitionTableHeaders()\n");=0A=
+        PED_ASSERT(pgpt !=3D NULL, return 0);=0A=
+        PED_ASSERT(agpt !=3D NULL, return 0);=0A=
+        PED_ASSERT(ptes !=3D NULL, return 0);=0A=
+=0A=
+	pgpt->PartitionEntryArrayCRC32 =3D=0A=
+                agpt->PartitionEntryArrayCRC32 =3D=0A=
+                efi_crc32(ptes, pgpt->NumberOfPartitionEntries *=0A=
+                          pgpt->SizeOfPartitionEntry);=0A=
+        =0A=
+	pgpt->HeaderCRC32 =3D 0;=0A=
+	pgpt->HeaderCRC32 =3D efi_crc32(pgpt, pgpt->HeaderSize);=0A=
+	agpt->HeaderCRC32 =3D 0;=0A=
+	agpt->HeaderCRC32 =3D efi_crc32(agpt, agpt->HeaderSize);=0A=
+        return 1;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+static int=0A=
+CreateNewGuidPartitionTableHeader(PedDevice *dev)=0A=
+{=0A=
+	__u64 size;=0A=
+	uuid_t uuid;=0A=
+	GuidPartitionTableHeader_t gpt, agpt;=0A=
+	GuidPartitionEntry_t ptes[GPT_DEFAULT_RESERVED_PARTITION_ENTRIES];=0A=
+	int count;=0A=
+=0A=
+        // printf("in CreateNewGuidPartitionTableHeader()\n");=0A=
+	memset(&gpt, 0, sizeof(gpt));=0A=
+	gpt.Signature =3D GUID_PT_HEADER_SIGNATURE;=0A=
+	gpt.Revision =3D GUID_PT_HEADER_REVISION_V1_02;=0A=
+	gpt.HeaderSize =3D 92; /* per 1.02 spec */=0A=
+	gpt.MyLBA =3D 1;=0A=
+	gpt.AlternateLBA =3D LastLBA(dev);=0A=
+	gpt.FirstUsableLBA =3D =
(GPT_DEFAULT_RESERVED_PARTITION_ENTRY_ARRAY_SIZE /=0A=
+                              dev->sector_size) + 2;=0A=
+	gpt.LastUsableLBA =3D=0A=
+                gpt.AlternateLBA -=0A=
+                (GPT_DEFAULT_RESERVED_PARTITION_ENTRY_ARRAY_SIZE /=0A=
+                 dev->sector_size) - 1;=0A=
+	uuid_generate(uuid);=0A=
+	memcpy(&(gpt.DiskGUID), uuid, sizeof(uuid));=0A=
+	gpt.PartitionEntryLBA =3D 2;=0A=
+	gpt.NumberOfPartitionEntries =3D =
GPT_DEFAULT_RESERVED_PARTITION_ENTRIES;=0A=
+	gpt.SizeOfPartitionEntry =3D sizeof(GuidPartitionEntry_t);=0A=
+=0A=
+	memset(ptes, 0,=0A=
+	       gpt.NumberOfPartitionEntries * gpt.SizeOfPartitionEntry);=0A=
+=0A=
+	/* Fix up Alternate GPT */=0A=
+	memcpy(&agpt, &gpt, sizeof(gpt));=0A=
+	agpt.MyLBA =3D gpt.AlternateLBA;=0A=
+	agpt.AlternateLBA =3D gpt.MyLBA;=0A=
+	agpt.PartitionEntryLBA =3D agpt.MyLBA -=0A=
+                (GPT_DEFAULT_RESERVED_PARTITION_ENTRY_ARRAY_SIZE /=0A=
+                 dev->sector_size);=0A=
+=0A=
+        if (!UpdateGuidPartitionTableHeaders(&gpt, &agpt, ptes))=0A=
+                return 0;=0A=
+=0A=
+        // printf("update successful\n");=0A=
+=0A=
+	/* Before the writes */=0A=
+	/* Write PTH and PTEs */=0A=
+	if (!WriteGuidPartitionTableHeader(dev, &gpt))=0A=
+		return 0;=0A=
+	if (!WriteGuidPartitionEntries(dev, &gpt, ptes))=0A=
+		return 0;=0A=
+=0A=
+=0A=
+	/* Write Alternate PTH & PTEs */=0A=
+	if (!WriteGuidPartitionEntries(dev, &agpt, ptes))=0A=
+		return 0;=0A=
+	if (!WriteGuidPartitionTableHeader(dev, &agpt))=0A=
+		return 0;=0A=
+=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+static int=0A=
+CreateNewGPTDisk(PedDevice * dev)=0A=
+{=0A=
+	if (!CreateNewPMBR(dev))=0A=
+		return 0;=0A=
+	if (!CreateNewGuidPartitionTableHeader(dev))=0A=
+		return 0;=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * FixPrimaryGuidPartitionTable()=0A=
+ * Uses values from alternate GPT and puts them in primary GPT.=0A=
+ * Requires:=0A=
+ * pgpt, agpt, ptes.=0A=
+ *  =0A=
+ * Modifies:=0A=
+ * pgpt=0A=
+ * =0A=
+ * Returns:=0A=
+ *   1 if valid=0A=
+ *   0 on error=0A=
+ ************************************************************/=0A=
+=0A=
+static int=0A=
+FixBrokenGuidPartitionTable(PedDevice *dev,=0A=
+                            GuidPartitionTableHeader_t **badgpt,=0A=
+                            GuidPartitionTableHeader_t *goodgpt,=0A=
+                            GuidPartitionEntry_t     *ptes)=0A=
+{=0A=
+=0A=
+        PED_ASSERT(badgpt !=3D NULL, return 0);=0A=
+        PED_ASSERT(goodgpt !=3D NULL, return 0);=0A=
+        PED_ASSERT(ptes !=3D NULL, return 0);=0A=
+=0A=
+	*badgpt =3D (GuidPartitionTableHeader_t *)=0A=
+                ped_malloc(sizeof(GuidPartitionTableHeader_t));=0A=
+	if (!*badgpt) return 0;=0A=
+        memset(*badgpt, 0, sizeof(**badgpt));=0A=
+=0A=
+	memcpy(*badgpt, goodgpt, sizeof(*goodgpt));=0A=
+=0A=
+	/* Change badgpt values */=0A=
+	(*badgpt)->MyLBA =3D goodgpt->AlternateLBA;=0A=
+	(*badgpt)->AlternateLBA =3D goodgpt->MyLBA;=0A=
+=0A=
+        =0A=
+        if ((*badgpt)->MyLBA =3D=3D 1) =0A=
+                (*badgpt)->PartitionEntryLBA =3D (*badgpt)->MyLBA + =
1;=0A=
+        else=0A=
+                (*badgpt)->PartitionEntryLBA =3D (*badgpt)->MyLBA - =
=0A=
+                        =
(GPT_DEFAULT_RESERVED_PARTITION_ENTRY_ARRAY_SIZE /=0A=
+                         dev->sector_size);=0A=
+        =0A=
+        return UpdateGuidPartitionTableHeaders(*badgpt, goodgpt, =
ptes);=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+static void=0A=
+PrintPartitionRecord(PartitionRecord_t * pr, int i)=0A=
+{=0A=
+	if (!pr)=0A=
+		return;=0A=
+	if (!(pr->OSType))=0A=
+		return;=0A=
+	printf("Legacy Partition Record %d\n", i);=0A=
+	printf("\tBootInd %02x", pr->BootIndicator);=0A=
+	printf("\tSHead %02x", pr->StartHead);=0A=
+	printf("\tSSector %02x", pr->StartSector);=0A=
+	printf("\tSTrack %02x\n", pr->StartTrack);=0A=
+	printf("\tOSType %02x", pr->OSType);=0A=
+	printf("\tEHead %02x", pr->EndHead);=0A=
+	printf("\tESector %02x", pr->EndSector);=0A=
+	printf("\tETrack %02x\n", pr->EndTrack);=0A=
+	printf("\tStartingLBA : %x", pr->StartingLBA);=0A=
+	printf("\tSizeInLBA : %x\n", pr->SizeInLBA);=0A=
+	return;=0A=
+}=0A=
+=0A=
+static void=0A=
+PrintLegacyMBR(LegacyMBR_t * mbr)=0A=
+{=0A=
+	int i;=0A=
+	if (!mbr)=0A=
+		return;=0A=
+	if (!IsLegacyMBRValid(mbr)) {=0A=
+		printf("MBR is invalid.\n");=0A=
+		return;=0A=
+	}=0A=
+=0A=
+	printf("UniqueMBRSignature: %x\n", mbr->UniqueMBRSignature);=0A=
+	for (i =3D 0; i < 4; i++)=0A=
+		PrintPartitionRecord(&(mbr->PartitionRecord[i]), i);=0A=
+	printf("Signature: %x\n", mbr->Signature);=0A=
+	return;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * FindValidGPT()=0A=
+ * Requires:=0A=
+ *  - dev =0A=
+ *  - pgpt is a GPTH if it's valid=0A=
+ *  - agpt is a GPTH if it's valid=0A=
+ *  - ptes is a PTE=0A=
+ * Modifies:=0A=
+ *  - gpt & ptes=0A=
+ * Returns:=0A=
+ *   1 if valid=0A=
+ *   0 on error=0A=
+ ************************************************************/=0A=
+static int=0A=
+FindValidGPT(const PedDevice * dev,=0A=
+	     GuidPartitionTableHeader_t ** pgpt,=0A=
+             GuidPartitionTableHeader_t ** agpt,=0A=
+	     GuidPartitionEntry_t       ** ptes)=0A=
+{=0A=
+	int rc =3D 0;=0A=
+	GuidPartitionEntry_t *pptes =3D NULL, *aptes =3D NULL;=0A=
+	__u64 lastlba;=0A=
+=0A=
+        PED_ASSERT(dev  !=3D NULL, return 0);=0A=
+        PED_ASSERT(pgpt !=3D NULL, return 0);=0A=
+        PED_ASSERT(agpt !=3D NULL, return 0);=0A=
+        PED_ASSERT(ptes !=3D NULL, return 0);=0A=
+=0A=
+        // printf("FindValidGPT()\n");=0A=
+	lastlba =3D LastLBA(dev);=0A=
+	/* Check the Primary GPT */=0A=
+	rc =3D IsGuidPartitionTableValid(dev, 1, pgpt, &pptes);=0A=
+	if (rc) {=0A=
+		/* Primary GPT is OK, check the alternate and warn if bad */=0A=
+		rc =3D IsGuidPartitionTableValid(dev, (*pgpt)->AlternateLBA,=0A=
+					       agpt, &aptes);=0A=
+=0A=
+		if (!rc) {=0A=
+                        *agpt =3D NULL;=0A=
+                        printf("Alternate GPT is invalid, using =
primary GPT.\n");=0A=
+=0A=
+		}=0A=
+		if (aptes) free(aptes);=0A=
+		*ptes =3D pptes;=0A=
+		return 1;=0A=
+	} /* if primary is valid */=0A=
+	else {=0A=
+		/* Primary GPT is bad, check the Alternate GPT */=0A=
+                *pgpt =3D NULL;=0A=
+		rc =3D IsGuidPartitionTableValid(dev, lastlba,=0A=
+					       agpt, &aptes);=0A=
+		if (rc) {=0A=
+			/* Primary is bad, alternate is good.=0A=
+			   Return values from the alternate and warn.=0A=
+			 */=0A=
+			printf=0A=
+			    ("Primary GPT is invalid, using alternate GPT.\n");=0A=
+			*ptes =3D aptes;=0A=
+			return 1;=0A=
+		}=0A=
+	}=0A=
+	/* Both primary and alternate GPTs are bad.=0A=
+	 * This isn't our disk, return 0.=0A=
+	 */=0A=
+        *pgpt =3D NULL;=0A=
+        *agpt =3D NULL;=0A=
+        *ptes =3D NULL;=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+=0A=
+static void=0A=
+PrintDiskInfo(PedDevice *dev)=0A=
+{=0A=
+	unsigned int i;=0A=
+	LegacyMBR_t mbr;=0A=
+	GuidPartitionTableHeader_t *pgpt =3D NULL, *agpt =3D NULL, *gpt =3D =
NULL;=0A=
+	GuidPartitionEntry_t *pte =3D NULL, zeropte;=0A=
+=0A=
+        // printf("PrintDiskInfo()\n");=0A=
+	memset(&zeropte, 0, sizeof(zeropte));=0A=
+	if (!ReadLBA(dev, 0, &mbr, sizeof(mbr))) {=0A=
+		printf("PrintDiskInfo error: ReadLBA(mbr) error.\n");=0A=
+		return;=0A=
+	}=0A=
+	PrintLegacyMBR(&mbr);=0A=
+	if (mbr.PartitionRecord[0].OSType =3D=3D EFI_PMBR_OSTYPE_EFI_GPT) =
{=0A=
+		/* This is an EFI GPT disk */=0A=
+		if (!ReadLBA(dev, 1, &pgpt, sizeof(*pgpt))) {=0A=
+			printf("PrintDiskInfo error: ReadLBA(gpt) error.\n");=0A=
+			return;=0A=
+		}=0A=
+		printf("This is an EFI GPT disk.\n");=0A=
+                if (FindValidGPT(dev, &pgpt, &agpt, &pte)) {=0A=
+                        if (pgpt) gpt =3D pgpt;=0A=
+                        else if (agpt) gpt =3D agpt;=0A=
+                }=0A=
+                else {=0A=
+			printf("GUID Partition Table is invalid.\n");=0A=
+			return;=0A=
+		}=0A=
+		for (i =3D 0; pte && i < gpt->NumberOfPartitionEntries; i++) {=0A=
+			/* Partition entry is unused if all bytes are 0 */=0A=
+			if (memcmp(&zeropte, &pte[i], sizeof(zeropte)))=0A=
+				PrintGuidPartitionEntry(&pte[i], i);=0A=
+		}=0A=
+		if (pgpt) free(pgpt);=0A=
+		if (agpt) free(agpt);=0A=
+		if (pte)  free(pte);=0A=
+	} else {=0A=
+		printf("This is not an EFI GPT disk.  Try using fdisk.\n");=0A=
+	}=0A=
+	return;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+void=0A=
+ped_disk_gpt_init()=0A=
+{=0A=
+	PED_ASSERT(sizeof(GuidPartitionTableHeader_t) =3D=3D 512, return);=0A=
+	PED_ASSERT(sizeof(GuidPartitionEntryAttributes_t) =3D=3D 8, =
return);=0A=
+	PED_ASSERT(sizeof(GuidPartitionEntry_t) =3D=3D 128, return);=0A=
+=0A=
+	ped_register_disk_type(&gpt_disk_type);=0A=
+}=0A=
+=0A=
+void=0A=
+ped_disk_gpt_done()=0A=
+{=0A=
+	ped_unregister_disk_type(&gpt_disk_type);=0A=
+}=0A=
+=0A=
+static int=0A=
+gpt_probe(const PedDevice * dev)=0A=
+{=0A=
+	GuidPartitionTableHeader_t *pgpt =3D NULL, *agpt =3D NULL;=0A=
+	GuidPartitionEntry_t *ptes =3D NULL;=0A=
+=0A=
+	PED_ASSERT(dev !=3D NULL, return 0);=0A=
+=0A=
+        // printf("gpt_probe()\n");=0A=
+=0A=
+	if (!ped_device_open((PedDevice *) dev))=0A=
+		return 0;=0A=
+=0A=
+	if (!(FindValidGPT(dev, &pgpt, &agpt, &ptes))) {=0A=
+		ped_device_close((PedDevice *) dev);=0A=
+		return 0;=0A=
+	}=0A=
+=0A=
+	ped_device_close((PedDevice *) dev);=0A=
+=0A=
+	if (pgpt) free(pgpt);=0A=
+	if (agpt) free(agpt);=0A=
+	if (ptes) free(ptes);=0A=
+        // printf("gpt_probe returning 1\n");=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+static PedDisk *=0A=
+gpt_open(PedDevice * dev)=0A=
+{=0A=
+	PedDisk *disk;=0A=
+=0A=
+        // printf("gpt_open()\n");=0A=
+=0A=
+	PED_ASSERT(dev !=3D NULL, return 0);=0A=
+=0A=
+	if (!gpt_probe(dev))=0A=
+		goto error;=0A=
+        =0A=
+=0A=
+	ped_device_open((PedDevice *) dev);=0A=
+=0A=
+        // printf("gpt_open() called ped_device_open()\n");=0A=
+	disk =3D ped_disk_alloc(dev, &gpt_disk_type);=0A=
+        // printf("gpt_open called ped_disk_alloc()\n");=0A=
+=0A=
+	if (!disk)=0A=
+		goto error;=0A=
+=0A=
+        // printf("gpt_open: ped_disk_alloc() succeeded\n");=0A=
+=0A=
+        // printf("gpt_open() calling gpt_read()\n");=0A=
+	if (!gpt_read(disk))=0A=
+          goto error_free_disk_specific;=0A=
+=0A=
+        // printf("gpt_open returning disk\n");=0A=
+	return disk;=0A=
+=0A=
+      error_free_disk_specific:=0A=
+        ped_free(disk->disk_specific);=0A=
+      error_free_disk:=0A=
+	ped_free(disk);=0A=
+      error:=0A=
+        // printf("gpt_open() returning NULL\n");=0A=
+	return NULL;=0A=
+}=0A=
+=0A=
+static PedDisk *=0A=
+gpt_create(PedDevice * dev)=0A=
+{=0A=
+        PedDisk *newdisk;=0A=
+	PED_ASSERT(dev !=3D NULL, return 0);=0A=
+=0A=
+        // printf("gpt_create()\n");=0A=
+	if (!ped_device_open(dev))=0A=
+		goto error;=0A=
+=0A=
+=0A=
+	CreateNewGPTDisk(dev);=0A=
+=0A=
+	if (!ped_device_sync(dev))=0A=
+		goto error_close_dev;=0A=
+=0A=
+	ped_device_close(dev);=0A=
+        newdisk =3D gpt_open(dev);=0A=
+        return newdisk;=0A=
+=0A=
+      error_close_dev:=0A=
+	ped_device_close(dev);=0A=
+      error:=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+static int=0A=
+gpt_close(PedDisk * disk)=0A=
+{=0A=
+        // printf("in gpt_close()\n");=0A=
+	PED_ASSERT(disk !=3D NULL, return 0);=0A=
+=0A=
+	ped_device_close(disk->dev);=0A=
+	ped_disk_delete_all(disk);=0A=
+        if (disk->disk_specific) ped_free(disk->disk_specific);=0A=
+	ped_free(disk);=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+static int=0A=
+gpt_read(PedDisk * disk)=0A=
+{=0A=
+	PedPartition *part;=0A=
+	unsigned int i;=0A=
+        GPTDiskData *gpt_disk_data;=0A=
+        GPTPartitionData *gpt_part_data;=0A=
+	PedConstraint*		constraint_exact;=0A=
+        efi_guid_t unused =3D UNUSED_ENTRY_GUID;=0A=
+=0A=
+        // printf("in gpt_read()\n");        =0A=
+	PED_ASSERT(disk !=3D NULL, return 0);=0A=
+	PED_ASSERT(disk->dev !=3D NULL, return 0);=0A=
+=0A=
+=0A=
+	ped_disk_delete_all(disk);=0A=
+=0A=
+        // printf("gpt_read(): ped_disk_delete_all() returned.\n");=0A=
+=0A=
+        if (!disk->disk_specific) gpt_new(disk);=0A=
+        PED_ASSERT(disk->disk_specific !=3D NULL, return 0);=0A=
+        gpt_disk_data =3D disk->disk_specific;=0A=
+=0A=
+=0A=
+	if (!FindValidGPT(disk->dev, &(gpt_disk_data->pgpt), =
&(gpt_disk_data->agpt), &(gpt_disk_data->ptes)))=0A=
+		return 0;=0A=
+=0A=
+        /* If one of the gpts are broken, fix it. */=0A=
+        if (!gpt_disk_data->pgpt) {=0A=
+                FixBrokenGuidPartitionTable(disk->dev,=0A=
+                                            &gpt_disk_data->pgpt,=0A=
+                                            gpt_disk_data->agpt,=0A=
+                                            gpt_disk_data->ptes);=0A=
+        }=0A=
+        else if (!gpt_disk_data->agpt) {=0A=
+                FixBrokenGuidPartitionTable(disk->dev,=0A=
+                                            &gpt_disk_data->agpt,=0A=
+                                            gpt_disk_data->pgpt,=0A=
+                                            gpt_disk_data->ptes);=0A=
+        }=0A=
+        =0A=
+	for (i =3D 0; i < gpt_disk_data->pgpt->NumberOfPartitionEntries; i++) =
{=0A=
+                =0A=
+                if =
(!efi_guidcmp(gpt_disk_data->ptes[i].PartitionTypeGuid,=0A=
+                                 unused)) continue;=0A=
+=0A=
+                // printf("calling ped_partition_alloc() in =
gpt_read(), i=3D%u\n", i);=0A=
+                // PrintGuidPartitionEntry(&gpt_disk_data->ptes[i], =
i);=0A=
+		part =3D ped_partition_alloc(disk, PED_PARTITION_PRIMARY, NULL,=0A=
+					 gpt_disk_data->ptes[i].StartingLBA,=0A=
+					 gpt_disk_data->ptes[i].EndingLBA);=0A=
+		if (!part)=0A=
+			return 0;=0A=
+=0A=
+                part->num =3D i+1;=0A=
+=0A=
+                gpt_part_data =3D part->disk_specific =3D=0A=
+                        ped_malloc(sizeof(GPTPartitionData));=0A=
+                if (!gpt_part_data) {=0A=
+                        ped_free(part);=0A=
+                        return 0;=0A=
+                }=0A=
+                memset(gpt_part_data, 0, sizeof(*gpt_part_data));=0A=
+                =0A=
+                gpt_part_data->pte  =3D &(gpt_disk_data->ptes[i]);=0A=
+=0A=
+                // printf("handling constraints\n");=0A=
+		constraint_exact =3D ped_constraint_exact (&part->geom);=0A=
+		if (!ped_disk_add_partition(disk, part, constraint_exact)) {=0A=
+			ped_free(gpt_part_data);=0A=
+                        ped_free(part);=0A=
+                        // printf("gpt_read() returning 0 after =
ped_disk_add_partition()\n");=0A=
+                        return 0;=0A=
+                }=0A=
+		ped_constraint_destroy (constraint_exact);=0A=
+=0A=
+	}=0A=
+        // printf("gpt_read() returning 1\n");=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+=0A=
+static int=0A=
+gpt_write(PedDisk * disk)=0A=
+{=0A=
+=0A=
+        GPTDiskData *gpt_disk_data;=0A=
+        PedPartition *part =3D NULL;=0A=
+=0A=
+        // printf("!!!!!in gpt_write()\n");=0A=
+	PED_ASSERT(disk !=3D NULL, return 0);=0A=
+	PED_ASSERT(disk->dev !=3D NULL, return 0);=0A=
+        PED_ASSERT(disk->disk_specific !=3D NULL, return 0);=0A=
+        gpt_disk_data =3D disk->disk_specific;=0A=
+=0A=
+        if (!CreateNewPMBR(disk->dev)) return 0;=0A=
+=0A=
+        UpdateGuidPartitionTableHeaders(gpt_disk_data->pgpt,=0A=
+                                        gpt_disk_data->agpt,=0A=
+                                        gpt_disk_data->ptes);=0A=
+=0A=
+	/* Write PTH and PTEs */=0A=
+	if (!WriteGuidPartitionTableHeader(disk->dev, =
gpt_disk_data->pgpt))=0A=
+		return 0;=0A=
+	if (!WriteGuidPartitionEntries(disk->dev, gpt_disk_data->pgpt, =
gpt_disk_data->ptes))=0A=
+		return 0;=0A=
+=0A=
+=0A=
+	/* Write Alternate PTH & PTEs */=0A=
+	if (!WriteGuidPartitionEntries(disk->dev, gpt_disk_data->agpt, =
gpt_disk_data->ptes))=0A=
+		return 0;=0A=
+	if (!WriteGuidPartitionTableHeader(disk->dev, =
gpt_disk_data->agpt))=0A=
+		return 0;=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+	if (!ped_device_sync(disk->dev))=0A=
+		return 0;=0A=
+=0A=
+	return 1;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+static int=0A=
+add_metadata_part(PedDisk * disk, PedPartitionType type, PedSector =
start,=0A=
+		  PedSector length)=0A=
+{=0A=
+	PedPartition *new_part;=0A=
+        PedConstraint * constraint_exact;=0A=
+	PED_ASSERT(disk !=3D NULL, return 0);=0A=
+=0A=
+=0A=
+        // printf("calling ped_partition_new() in =
add_metadata_part()\n");=0A=
+	new_part =3D=0A=
+	    ped_partition_new(disk, type | PED_PARTITION_METADATA, NULL,=0A=
+			      start, start + length - 1);=0A=
+	if (!new_part)=0A=
+		goto error;=0A=
+=0A=
+        constraint_exact =3D ped_constraint_exact =
(&new_part->geom);=0A=
+=0A=
+	if (!ped_disk_add_partition(disk, new_part, constraint_exact))=0A=
+		goto error_destroy_new_part;=0A=
+=0A=
+	return 1;=0A=
+=0A=
+      error_destroy_new_part:=0A=
+	ped_partition_destroy(new_part);=0A=
+      error:=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+static PedPartition *=0A=
+gpt_partition_new(const PedDisk *disk,=0A=
+                  PedPartitionType part_type,=0A=
+                  const PedFileSystemType* fs_type,=0A=
+                  PedSector start,=0A=
+                  PedSector end)=0A=
+{=0A=
+        unsigned int i;=0A=
+	uuid_t uuid;=0A=
+	efi_guid_t unused_entry_guid =3D UNUSED_ENTRY_GUID;=0A=
+        GPTDiskData *gpt_disk_data;=0A=
+        GPTPartitionData *gpt_part_data;=0A=
+        PedPartition *part;=0A=
+        =0A=
+        PED_ASSERT(disk !=3D NULL, return NULL);=0A=
+=0A=
+=0A=
+	part =3D ped_partition_alloc (disk, part_type, fs_type, start, =
end);=0A=
+	if (!part) return NULL;=0A=
+=0A=
+        if (part_type !=3D PED_PARTITION_PRIMARY)=0A=
+                return part;=0A=
+=0A=
+        if (!ped_disk_check_overlap(disk, part)) {=0A=
+		ped_exception_throw (=0A=
+			PED_EXCEPTION_ERROR,=0A=
+			PED_EXCEPTION_CANCEL,=0A=
+			_("The new partition overlaps with another "=0A=
+			  "partition."));=0A=
+                ped_free(part);=0A=
+                return NULL;=0A=
+        }=0A=
+=0A=
+        PED_ASSERT(disk->disk_specific !=3D NULL, return NULL);=0A=
+=0A=
+        gpt_disk_data =3D disk->disk_specific;=0A=
+        // printf("in gpt_partition_new(s=3D%llx, e=3D%llx t=3D%d)\n", =
start, end, part_type);=0A=
+=0A=
+=0A=
+        PED_ASSERT(gpt_disk_data->pgpt !=3D NULL, return NULL);=0A=
+        PED_ASSERT(gpt_disk_data->agpt !=3D NULL, return NULL);=0A=
+        PED_ASSERT(gpt_disk_data->ptes !=3D NULL, return NULL);=0A=
+=0A=
+=0A=
+        for (i =3D 0; i < =
gpt_disk_data->pgpt->NumberOfPartitionEntries; i++) {=0A=
+		if (!efi_guidcmp=0A=
+		    (gpt_disk_data->ptes[i].PartitionTypeGuid, unused_entry_guid)) =
{=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
+	/* No unused entries */=0A=
+	if (i =3D=3D gpt_disk_data->pgpt->NumberOfPartitionEntries){=0A=
+                ped_free(part);=0A=
+		return NULL;=0A=
+        }=0A=
+=0A=
+        // printf("Found unused entry at i=3D%u\n", i);=0A=
+        part->num =3D i + 1;=0A=
+	gpt_disk_data->ptes[i].StartingLBA =3D part->geom.start;=0A=
+	gpt_disk_data->ptes[i].EndingLBA =3D part->geom.end;=0A=
+	uuid_generate(uuid);=0A=
+	memcpy(&(gpt_disk_data->ptes[i].UniquePartitionGuid), uuid, =
sizeof(uuid));=0A=
+=0A=
+        gpt_disk_data->ptes[i].PartitionTypeGuid =3D =
PARTITION_BASIC_DATA_GUID;=0A=
+=0A=
+        if (fs_type && fs_type->name && !strcmp(fs_type->name, =
"linux-swap"))=0A=
+                gpt_disk_data->ptes[i].PartitionTypeGuid =3D =0A=
+                        PARTITION_SWAP_GUID;=0A=
+=0A=
+        =0A=
+        gpt_part_data =3D part->disk_specific =3D=0A=
+                ped_malloc(sizeof(GPTPartitionData));=0A=
+        if (!gpt_part_data) return part;=0A=
+        memset(gpt_part_data, 0, sizeof(*gpt_part_data));=0A=
+=0A=
+        gpt_part_data->pte =3D &(gpt_disk_data->ptes[i]);=0A=
+=0A=
+        return part;=0A=
+}=0A=
+=0A=
+static void=0A=
+gpt_partition_destroy(PedPartition *part)=0A=
+{=0A=
+        GPTPartitionData *gpt_part_data;=0A=
+=0A=
+        PED_ASSERT(part !=3D NULL, return);=0A=
+        // printf("in gpt_partition_destroy(type=3D%x)\n", =
part->type);=0A=
+=0A=
+        if (part->type !=3D PED_PARTITION_PRIMARY)=0A=
+                return;=0A=
+=0A=
+        PED_ASSERT(part->disk_specific !=3D NULL, return);=0A=
+        gpt_part_data =3D part->disk_specific;=0A=
+        if (gpt_part_data->pte)=0A=
+                memset(gpt_part_data->pte, 0, =
sizeof(*(gpt_part_data->pte)));=0A=
+=0A=
+        ped_free(part->disk_specific);=0A=
+        part->disk_specific =3D NULL;=0A=
+        ped_free(part);=0A=
+        // printf("returning from gpt_partition_destroy()\n");        =
=0A=
+}=0A=
+=0A=
+/**********************************************************=0A=
+ * Allocate metadata partitions for the GPTH and PTES.=0A=
+ *=0A=
+ */=0A=
+static int=0A=
+_alloc_metadata_unknown(PedDisk * disk)=0A=
+{=0A=
+        __u64 pte_reserved_blocks;=0A=
+	PED_ASSERT(disk !=3D NULL, return 0);=0A=
+        PED_ASSERT(disk->dev !=3D NULL, return 0);=0A=
+=0A=
+        pte_reserved_blocks =3D =0A=
+                (GPT_DEFAULT_RESERVED_PARTITION_ENTRY_ARRAY_SIZE /=0A=
+                 disk->dev->sector_size);=0A=
+=0A=
+        =0A=
+        //  printf("in _alloc_metadata_unknown()\n");=0A=
+	/* metadata at the start of the disk includes the MBR */=0A=
+        // printf("adding metadata at start of the disk.\n");=0A=
+	if (!add_metadata_part(disk, PED_PARTITION_PRIMARY,=0A=
+			       0,=0A=
+                               1 + 1 + pte_reserved_blocks))=0A=
+		return 0;=0A=
+=0A=
+	/* metadata at the end of the disk */=0A=
+        // printf("adding metadata at end of the disk.\n");=0A=
+	if (!add_metadata_part(disk, PED_PARTITION_PRIMARY,=0A=
+			       LastLBA(disk->dev) -=0A=
+                               pte_reserved_blocks,=0A=
+                               1 + pte_reserved_blocks))=0A=
+                return 0;=0A=
+=0A=
+        return 1;=0A=
+}=0A=
+=0A=
+=0A=
+/**********************************************************=0A=
+ * Allocate metadata partitions for the GPTH and PTES=0A=
+ * when we know the actual metadata size=0A=
+ */=0A=
+static int=0A=
+_alloc_metadata_known(PedDisk * disk)=0A=
+{=0A=
+	int i;=0A=
+	PedSector gptlength, pteslength =3D 0;=0A=
+        GPTDiskData *gpt_disk_data;=0A=
+        =0A=
+        // printf("in _alloc_metadata_known()\n");=0A=
+	PED_ASSERT(disk !=3D NULL, return 0);=0A=
+	PED_ASSERT(disk->dev !=3D NULL, return 0);=0A=
+        PED_ASSERT(disk->disk_specific !=3D NULL, return 0);=0A=
+        gpt_disk_data =3D disk->disk_specific;=0A=
+=0A=
+	/* allocate space for the header */=0A=
+	gptlength =3D gpt_disk_data->pgpt->HeaderSize / =
disk->dev->sector_size;=0A=
+	if (gpt_disk_data->pgpt->HeaderSize % disk->dev->sector_size)=0A=
+		gptlength++;=0A=
+	/* allocate space for the ptes */=0A=
+	pteslength =3D=0A=
+	    (gpt_disk_data->pgpt->NumberOfPartitionEntries *=0A=
+	     gpt_disk_data->pgpt->SizeOfPartitionEntry) /=0A=
+                disk->dev->sector_size;=0A=
+	if ((gpt_disk_data->pgpt->NumberOfPartitionEntries *=0A=
+	     gpt_disk_data->pgpt->SizeOfPartitionEntry) %=0A=
+            disk->dev->sector_size)=0A=
+		pteslength++;=0A=
+=0A=
+	/* metadata at the start of the disk includes the MBR */=0A=
+        // printf("adding metadata at start of the disk.\n");=0A=
+	if (!add_metadata_part(disk, PED_PARTITION_PRIMARY,=0A=
+			       0, 1 + gptlength + pteslength))=0A=
+		return 0;=0A=
+=0A=
+	/* metadata at the end of the disk */=0A=
+        // printf("adding metadata at end of the disk.\n");=0A=
+	if (!add_metadata_part(disk, PED_PARTITION_PRIMARY,=0A=
+			       LastLBA(disk->dev) - gptlength - pteslength + 1,=0A=
+                               gptlength + pteslength))=0A=
+                return 0;=0A=
+=0A=
+        return 1;=0A=
+}=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+/**********************************************************=0A=
+ * Allocate metadata partitions for the GPTH and PTES.=0A=
+ *=0A=
+ */=0A=
+static int=0A=
+gpt_alloc_metadata(PedDisk * disk)=0A=
+{=0A=
+        GPTDiskData *gpt_disk_data;=0A=
+	PED_ASSERT(disk !=3D NULL, return 0);=0A=
+	PED_ASSERT(disk->dev !=3D NULL, return 0);=0A=
+=0A=
+        gpt_disk_data =3D disk->disk_specific;=0A=
+=0A=
+	if (!gpt_disk_data ||=0A=
+            !gpt_disk_data->pgpt ||=0A=
+            !gpt_disk_data->agpt ||=0A=
+            !gpt_disk_data->ptes)=0A=
+                return _alloc_metadata_unknown(disk);=0A=
+        =0A=
+        return _alloc_metadata_known(disk);=0A=
+}=0A=
+=0A=
+/************************************************************=0A=
+ * gpt_partition_enumerate()=0A=
+ * Requires:=0A=
+ *  - part =0A=
+ * Modifies:=0A=
+ *  - part->num=0A=
+ * Returns:=0A=
+ *   1 if valid=0A=
+ *   0 on error=0A=
+ * Actions:=0A=
+ *   Does nothing, as the read/new/destroy functions maintain=0A=
+ *   part->num.=0A=
+ *   =0A=
+ *   =0A=
+ ************************************************************/=0A=
+static int=0A=
+gpt_partition_enumerate(PedPartition * part)=0A=
+{=0A=
+        return 1;=0A=
+}=0A=
+=0A=
+=0A=
+/************************************************************=0A=
+ * gpt_clobber()=0A=
+ * Requires:=0A=
+ *  - dev =0A=
+ * Modifies:=0A=
+ *  - dev=0A=
+ * Returns:=0A=
+ *   1 if valid=0A=
+ *   0 on error=0A=
+ * Actions:=0A=
+ *   This writes zeros to the PMBR and the primary and=0A=
+ *   alternate GPTHs and PTEs.=0A=
+ ************************************************************/=0A=
+static int=0A=
+gpt_clobber(PedDevice * dev)=0A=
+{=0A=
+	LegacyMBR_t pmbr;=0A=
+        GuidPartitionTableHeader_t gpt;=0A=
+        GuidPartitionEntry_t =
ptes[GPT_DEFAULT_RESERVED_PARTITION_ENTRIES];=0A=
+        __u64 lastLBA, pte_reserved_blocks;=0A=
+        =0A=
+=0A=
+        // printf("in gpt_clobber()\n");=0A=
+        PED_ASSERT (dev !=3D NULL, return 0);=0A=
+        PED_ASSERT (gpt_probe(dev), return 0);=0A=
+=0A=
+        if (!ped_device_open(dev)) return 0;=0A=
+=0A=
+        PED_ASSERT(dev->sector_size !=3D 0, return 0);=0A=
+        pte_reserved_blocks =3D =
GPT_DEFAULT_RESERVED_PARTITION_ENTRY_ARRAY_SIZE /=0A=
+                dev->sector_size;=0A=
+=0A=
+=0A=
+	memset(&pmbr, 0, sizeof(pmbr));=0A=
+        memset(&gpt, 0, sizeof(gpt));=0A=
+        memset(ptes, 0,=0A=
+               GPT_DEFAULT_RESERVED_PARTITION_ENTRIES *=0A=
+               sizeof(GuidPartitionEntry_t));=0A=
+        lastLBA =3D LastLBA(dev);=0A=
+               =0A=
+	if (!WriteLBA(dev, 0, &pmbr, sizeof(pmbr))) {=0A=
+		printf("gpt_clobber(): Unable to write empty PMBR.\n");=0A=
+		return 0;=0A=
+	}=0A=
+	if (!WriteLBA(dev, 1, &gpt, sizeof(gpt))) {=0A=
+		printf("gpt_clobber(): Unable to write empty PGPTH.\n");=0A=
+		return 0;=0A=
+	}=0A=
+	if (!WriteLBA(dev, 2, ptes, sizeof(ptes))) {=0A=
+		printf("gpt_clobber(): Unable to write empty PPTES.\n");=0A=
+		return 0;=0A=
+	}=0A=
+	if (!WriteLBA(dev, lastLBA-pte_reserved_blocks, ptes,=0A=
+                      sizeof(ptes))) {=0A=
+		printf("gpt_clobber(): Unable to write empty APTES.\n");=0A=
+		return 0;=0A=
+	}=0A=
+	if (!WriteLBA(dev, lastLBA, &gpt, sizeof(gpt))) {=0A=
+		printf("gpt_clobber(): Unable to write empty AGPTH.\n");=0A=
+		return 0;=0A=
+	}=0A=
+        return 1;=0A=
+}=0A=
+=0A=
+=0A=
+static int=0A=
+gpt_partition_set_flag(PedPartition *part,=0A=
+                       PedPartitionFlag flag,=0A=
+                       int state)=0A=
+{=0A=
+        GPTPartitionData *gpt_part_data;=0A=
+        PED_ASSERT(part !=3D NULL, return 0);=0A=
+        PED_ASSERT(part->disk_specific !=3D NULL, return 0);=0A=
+        gpt_part_data =3D part->disk_specific;=0A=
+        PED_ASSERT(gpt_part_data->pte !=3D NULL, return 0);=0A=
+=0A=
+=0A=
+	switch (flag) {=0A=
+	case PED_PARTITION_RAID:=0A=
+                if (state)=0A=
+                        gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+                                PARTITION_RAID_GUID;=0A=
+                else=0A=
+                        gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+                                PARTITION_BASIC_DATA_GUID;=0A=
+                break;=0A=
+	case PED_PARTITION_LVM:=0A=
+                if (state)=0A=
+                        gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+                                PARTITION_LVM_GUID;=0A=
+                else=0A=
+                        gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+                                PARTITION_BASIC_DATA_GUID;=0A=
+=0A=
+                break;=0A=
+	case PED_PARTITION_BOOT:=0A=
+                if (state)=0A=
+                        gpt_part_data->pte->PartitionTypeGuid =3D =0A=
+                                PARTITION_SYSTEM_GUID;=0A=
+                else=0A=
+                        gpt_part_data->pte->PartitionTypeGuid =3D =0A=
+                                PARTITION_BASIC_DATA_GUID;=0A=
+=0A=
+                break;=0A=
+	case PED_PARTITION_LBA:=0A=
+                if (!state) return 0;=0A=
+		break;=0A=
+	case PED_PARTITION_HIDDEN:=0A=
+	default:=0A=
+		return 0;=0A=
+        }=0A=
+=0A=
+        if (part->fs_type && part->fs_type->name &&=0A=
+            !strcmp(part->fs_type->name, "linux-swap"))=0A=
+                        gpt_part_data->pte->PartitionTypeGuid =3D =0A=
+                                PARTITION_SWAP_GUID;=0A=
+                =0A=
+=0A=
+        return 1;=0A=
+}=0A=
+=0A=
+static int=0A=
+gpt_partition_get_flag(const PedPartition *part,=0A=
+                       PedPartitionFlag flag)=0A=
+{=0A=
+        GPTPartitionData *gpt_part_data =3D NULL;=0A=
+        PED_ASSERT(part->disk_specific !=3D NULL, return 0);=0A=
+        gpt_part_data =3D part->disk_specific;=0A=
+=0A=
+	switch (flag) {=0A=
+	case PED_PARTITION_RAID:=0A=
+                return =
(!efi_guidcmp(gpt_part_data->pte->PartitionTypeGuid, =0A=
+                                     PARTITION_RAID_GUID));=0A=
+	case PED_PARTITION_LVM:=0A=
+                return =
(!efi_guidcmp(gpt_part_data->pte->PartitionTypeGuid, =0A=
+                                     PARTITION_LVM_GUID));=0A=
+	case PED_PARTITION_BOOT:=0A=
+                return =
(!efi_guidcmp(gpt_part_data->pte->PartitionTypeGuid,=0A=
+                                     PARTITION_SYSTEM_GUID));=0A=
+	case PED_PARTITION_LBA:=0A=
+		return 1;=0A=
+	case PED_PARTITION_HIDDEN:=0A=
+	default:=0A=
+		return 0;=0A=
+        }=0A=
+        return 0;=0A=
+}=0A=
+=0A=
+static int=0A=
+gpt_partition_is_flag_available(const PedPartition * part,=0A=
+                                PedPartitionFlag flag)=0A=
+{=0A=
+	switch (flag) {=0A=
+	case PED_PARTITION_RAID:=0A=
+	case PED_PARTITION_LVM:=0A=
+	case PED_PARTITION_LBA:=0A=
+	case PED_PARTITION_BOOT:=0A=
+		return 1;=0A=
+	case PED_PARTITION_HIDDEN:=0A=
+	default:=0A=
+		return 0;=0A=
+        }=0A=
+        return 0;=0A=
+}=0A=
+=0A=
+static void=0A=
+gpt_partition_set_name(PedPartition *part,=0A=
+                       const char *name)=0A=
+{=0A=
+        unsigned int i;=0A=
+        GPTPartitionData *gpt_part_data =3D NULL;=0A=
+        PED_ASSERT(part->disk_specific !=3D NULL, return);=0A=
+        gpt_part_data =3D part->disk_specific;=0A=
+=0A=
+        if (!gpt_part_data->pte) return;=0A=
+=0A=
+        memset(gpt_part_data->pte->PartitionName, 0, =
sizeof(gpt_part_data->pte->PartitionName));=0A=
+=0A=
+        for (i=3D0; i < (72 / sizeof(efi_char16_t)) && i < =
strlen(name); i++) {=0A=
+                gpt_part_data->pte->PartitionName[i] =3D name[i];=0A=
+        }=0A=
+        return;=0A=
+}=0A=
+static const char *=0A=
+gpt_partition_get_name (const PedPartition * part)=0A=
+{=0A=
+        /* The name is stored in Unicode in the GPT entry */=0A=
+        char *name;=0A=
+        unsigned int i, namelen =3D (72 / sizeof(efi_char16_t));=0A=
+        GPTPartitionData *gpt_part_data =3D NULL;=0A=
+        PED_ASSERT(part->disk_specific !=3D NULL, return 0);=0A=
+        gpt_part_data =3D part->disk_specific;=0A=
+=0A=
+        if (!gpt_part_data->pte) return NULL;=0A=
+=0A=
+        name =3D ped_malloc(namelen);=0A=
+        if (!name) return NULL;=0A=
+=0A=
+        memset(name, 0, namelen);=0A=
+=0A=
+        for (i=3D0; i < namelen ; i++) {=0A=
+                name[i] =3D gpt_part_data->pte->PartitionName[i];=0A=
+        }=0A=
+=0A=
+        return name;=0A=
+}=0A=
+=0A=
+=0A=
+static int=0A=
+gpt_get_max_primary_partition_count(const PedDisk *disk)=0A=
+{=0A=
+        int rc =3D GPT_DEFAULT_RESERVED_PARTITION_ENTRIES; /* 128 =
*/=0A=
+        GPTDiskData *gpt_disk_data;=0A=
+        PED_ASSERT(disk !=3D NULL, return 0);=0A=
+        gpt_disk_data =3D disk->disk_specific;=0A=
+        =0A=
+        if (gpt_disk_data  && gpt_disk_data->pgpt)=0A=
+                rc =3D =
gpt_disk_data->pgpt->NumberOfPartitionEntries;=0A=
+        return rc;=0A=
+}=0A=
+=0A=
+/* There are no alignment issues with GPT */=0A=
+static int=0A=
+gpt_partition_align(PedPartition * part,=0A=
+                    const PedConstraint * constraint)=0A=
+{=0A=
+        // printf("in gpt_partition_align()\n");=0A=
+        return 1;=0A=
+}=0A=
+=0A=
+static PedDisk *=0A=
+gpt_new(PedDisk * disk)=0A=
+{=0A=
+        // printf("gpt_new(%p)\n", disk);=0A=
+        PED_ASSERT(disk !=3D NULL, return NULL);=0A=
+        if (disk->disk_specific) return disk;=0A=
+=0A=
+        disk->disk_specific =3D ped_malloc(sizeof(GPTDiskData));=0A=
+        PED_ASSERT(disk->disk_specific !=3D NULL, return NULL);=0A=
+        memset(disk->disk_specific, 0, sizeof(GPTDiskData));=0A=
+        return disk;=0A=
+}  =0A=
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
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/fs_ext2/interface.c =
parted-1.4.7-gpt/libparted/fs_ext2/interface.c=0A=
--- parted-1.4.7/libparted/fs_ext2/interface.c	Mon Dec  4 13:12:47 =
2000=0A=
+++ parted-1.4.7-gpt/libparted/fs_ext2/interface.c	Thu Jan 18 11:45:14 =
2001=0A=
@@ -31,6 +31,7 @@=0A=
 #include <parted/disk_pc98.h>=0A=
 #include <parted/disk_mac.h>=0A=
 #include <parted/disk_bsd.h>=0A=
+#include <parted/disk_gpt.h>=0A=
 #include "ext2.h"=0A=
 #include "parted_io.h"=0A=
 =0A=
@@ -342,6 +343,15 @@=0A=
 	if (strcmp (disk_type->name, BSD_NAME) =3D=3D 0) {=0A=
 		BSDPartitionData* bsd_data =3D part->disk_specific;=0A=
 		bsd_data->type =3D 0x8;=0A=
+		return 1;=0A=
+	}=0A=
+=0A=
+	if (strcmp (disk_type->name, GPT_NAME) =3D=3D 0) {=0A=
+		GPTPartitionData *gpt_part_data =3D part->disk_specific;=0A=
+		PED_ASSERT(gpt_part_data      !=3D NULL, return 0);	=0A=
+		PED_ASSERT(gpt_part_data->pte !=3D NULL, return 0);=0A=
+		gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+			PARTITION_BASIC_DATA_GUID;=0A=
 		return 1;=0A=
 	}=0A=
 =0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/fs_fat/fat.c =
parted-1.4.7-gpt/libparted/fs_fat/fat.c=0A=
--- parted-1.4.7/libparted/fs_fat/fat.c	Mon Dec  4 13:12:47 2000=0A=
+++ parted-1.4.7-gpt/libparted/fs_fat/fat.c	Thu Jan 18 11:42:08 2001=0A=
@@ -22,6 +22,7 @@=0A=
 #include <parted/disk_loop.h>=0A=
 #include <parted/disk_pc98.h>=0A=
 #include <parted/disk_mac.h>=0A=
+#include <parted/disk_gpt.h>=0A=
 =0A=
 #include "fat.h"=0A=
 #include "calc.h"=0A=
@@ -751,6 +752,15 @@=0A=
 		else=0A=
 			strcpy (mac_data->system_name, "FAT");=0A=
 		mac_data->status =3D 0x33;=0A=
+		return 1;=0A=
+	}=0A=
+=0A=
+	if (strcmp (disk_type->name, GPT_NAME) =3D=3D 0) {=0A=
+		GPTPartitionData *gpt_part_data =3D part->disk_specific;=0A=
+		PED_ASSERT(gpt_part_data      !=3D NULL, return 0);	=0A=
+		PED_ASSERT(gpt_part_data->pte !=3D NULL, return 0);=0A=
+		gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+			PARTITION_BASIC_DATA_GUID;=0A=
 		return 1;=0A=
 	}=0A=
 =0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/fs_hfs/hfs.c =
parted-1.4.7-gpt/libparted/fs_hfs/hfs.c=0A=
--- parted-1.4.7/libparted/fs_hfs/hfs.c	Fri Jan  5 07:30:56 2001=0A=
+++ parted-1.4.7-gpt/libparted/fs_hfs/hfs.c	Thu Jan 18 11:44:07 2001=0A=
@@ -25,6 +25,7 @@=0A=
 #include <parted/disk_loop.h>=0A=
 #include <parted/disk_pc98.h>=0A=
 #include <parted/disk_mac.h>=0A=
+#include <parted/disk_gpt.h>=0A=
 =0A=
 #include <libintl.h>=0A=
 #if ENABLE_NLS=0A=
@@ -151,6 +152,15 @@=0A=
 			strcpy (mac_data->system_name, "Apple_HFS");=0A=
 			mac_data->status |=3D 0x7f;=0A=
 		}=0A=
+		return 1;=0A=
+	}=0A=
+=0A=
+	if (strcmp (disk_type->name, GPT_NAME) =3D=3D 0) {=0A=
+		GPTPartitionData *gpt_part_data =3D part->disk_specific;=0A=
+		PED_ASSERT(gpt_part_data      !=3D NULL, return 0);	=0A=
+		PED_ASSERT(gpt_part_data->pte !=3D NULL, return 0);=0A=
+		gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+			PARTITION_BASIC_DATA_GUID;=0A=
 		return 1;=0A=
 	}=0A=
 =0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/fs_linux_swap/linux_swap.c =
parted-1.4.7-gpt/libparted/fs_linux_swap/linux_swap.c=0A=
--- parted-1.4.7/libparted/fs_linux_swap/linux_swap.c	Fri Jan  5 =
07:31:23 2001=0A=
+++ parted-1.4.7-gpt/libparted/fs_linux_swap/linux_swap.c	Thu Jan 18 =
11:24:42 2001=0A=
@@ -28,6 +28,7 @@=0A=
 #include <parted/disk_pc98.h>=0A=
 #include <parted/disk_mac.h>=0A=
 #include <parted/disk_bsd.h>=0A=
+#include <parted/disk_gpt.h>=0A=
 =0A=
 #include <libintl.h>=0A=
 #if ENABLE_NLS=0A=
@@ -565,6 +566,15 @@=0A=
 	if (strcmp (disk_type->name, BSD_NAME) =3D=3D 0) {=0A=
 		BSDPartitionData* bsd_data =3D part->disk_specific;=0A=
 		bsd_data->type =3D 0x1;=0A=
+		return 1;=0A=
+	}=0A=
+=0A=
+	if (strcmp (disk_type->name, GPT_NAME) =3D=3D 0) {=0A=
+		GPTPartitionData* gpt_part_data =3D part->disk_specific;=0A=
+		PED_ASSERT(gpt_part_data      !=3D NULL, return 0);=0A=
+		PED_ASSERT(gpt_part_data->pte !=3D NULL, return 0);=0A=
+		gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+			PARTITION_SWAP_GUID;=0A=
 		return 1;=0A=
 	}=0A=
 =0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/fs_ntfs/ntfs.c =
parted-1.4.7-gpt/libparted/fs_ntfs/ntfs.c=0A=
--- parted-1.4.7/libparted/fs_ntfs/ntfs.c	Fri Jan  5 07:29:47 2001=0A=
+++ parted-1.4.7-gpt/libparted/fs_ntfs/ntfs.c	Thu Jan 18 11:45:18 =
2001=0A=
@@ -25,6 +25,7 @@=0A=
 #include <parted/disk_loop.h>=0A=
 #include <parted/disk_pc98.h>=0A=
 #include <parted/disk_mac.h>=0A=
+#include <parted/disk_gpt.h>=0A=
 =0A=
 #include <libintl.h>=0A=
 #if ENABLE_NLS=0A=
@@ -147,6 +148,15 @@=0A=
 		else=0A=
 			strcpy (mac_data->system_name, "Apple_UNIX_SVR2");=0A=
 		mac_data->status =3D 0x33;=0A=
+		return 1;=0A=
+	}=0A=
+=0A=
+	if (strcmp (disk_type->name, GPT_NAME) =3D=3D 0) {=0A=
+		GPTPartitionData *gpt_part_data =3D part->disk_specific;=0A=
+		PED_ASSERT(gpt_part_data      !=3D NULL, return 0);	=0A=
+		PED_ASSERT(gpt_part_data->pte !=3D NULL, return 0);=0A=
+		gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+			PARTITION_BASIC_DATA_GUID;=0A=
 		return 1;=0A=
 	}=0A=
 =0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/fs_reiserfs/reiserfs.c =
parted-1.4.7-gpt/libparted/fs_reiserfs/reiserfs.c=0A=
--- parted-1.4.7/libparted/fs_reiserfs/reiserfs.c	Fri Jan  5 07:30:13 =
2001=0A=
+++ parted-1.4.7-gpt/libparted/fs_reiserfs/reiserfs.c	Thu Jan 18 =
11:42:34 2001=0A=
@@ -25,6 +25,7 @@=0A=
 #include <parted/disk_loop.h>=0A=
 #include <parted/disk_pc98.h>=0A=
 #include <parted/disk_mac.h>=0A=
+#include <parted/disk_gpt.h>=0A=
 =0A=
 #include <libintl.h>=0A=
 #if ENABLE_NLS=0A=
@@ -181,6 +182,15 @@=0A=
 		else=0A=
 			strcpy (mac_data->system_name, "Apple_UNIX_SVR2");=0A=
 		mac_data->status =3D 0x33;=0A=
+		return 1;=0A=
+	}=0A=
+=0A=
+	if (strcmp (disk_type->name, GPT_NAME) =3D=3D 0) {=0A=
+		GPTPartitionData *gpt_part_data =3D part->disk_specific;=0A=
+		PED_ASSERT(gpt_part_data      !=3D NULL, return 0);	=0A=
+		PED_ASSERT(gpt_part_data->pte !=3D NULL, return 0);=0A=
+		gpt_part_data->pte->PartitionTypeGuid =3D=0A=
+			PARTITION_BASIC_DATA_GUID;=0A=
 		return 1;=0A=
 	}=0A=
 =0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/libparted.c =
parted-1.4.7-gpt/libparted/libparted.c=0A=
--- parted-1.4.7/libparted/libparted.c	Thu Jan 11 13:03:16 2001=0A=
+++ parted-1.4.7-gpt/libparted/libparted.c	Thu Jan 18 11:24:42 2001=0A=
@@ -65,6 +65,7 @@=0A=
 	ped_disk_pc98_init ();=0A=
 	ped_disk_mac_init ();=0A=
 	ped_disk_bsd_init ();=0A=
+	ped_disk_gpt_init ();=0A=
 }=0A=
 =0A=
 static void=0A=
@@ -102,6 +103,7 @@=0A=
 	ped_disk_loop_done ();=0A=
 	ped_disk_mac_done ();=0A=
 	ped_disk_bsd_done ();=0A=
+	ped_disk_gpt_done ();=0A=
 }=0A=
 =0A=
 static void=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/sg_dd.c =
parted-1.4.7-gpt/libparted/sg_dd.c=0A=
--- parted-1.4.7/libparted/sg_dd.c	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/sg_dd.c	Thu Jan 18 11:24:42 2001=0A=
@@ -0,0 +1,781 @@=0A=
+ /*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+#define _XOPEN_SOURCE 500=0A=
+=0A=
+#include <unistd.h>=0A=
+#include <fcntl.h>=0A=
+#include <stdio.h>=0A=
+#include <stdlib.h>=0A=
+#include <string.h>=0A=
+#include <signal.h>=0A=
+#include <ctype.h>=0A=
+#include <errno.h>=0A=
+#include <sys/ioctl.h>=0A=
+#include <sys/types.h>=0A=
+#include <sys/stat.h>=0A=
+#include <sys/sysmacros.h>=0A=
+#include <linux/../scsi/sg.h>  /* cope with silly includes */=0A=
+#include <linux/major.h> =0A=
+typedef unsigned char u_char;	/* horrible, for scsi.h */=0A=
+#include "sg_err.h"=0A=
+=0A=
+#if 0=0A=
+#include "sg_llseek.h"=0A=
+#endif=0A=
+=0A=
+/* A utility program for the Linux OS SCSI generic ("sg") device =
driver.=0A=
+*  Copyright (C) 1999, 2000 D. Gilbert and P. Allworth=0A=
+*  This program is free software; you can redistribute it and/or =
modify=0A=
+*  it under the terms of the GNU General Public License as published =
by=0A=
+*  the Free Software Foundation; either version 2, or (at your =
option)=0A=
+*  any later version.=0A=
+=0A=
+   This program is a specialization of the Unix "dd" command in =
which=0A=
+   either the input or the output file is a scsi generic device or =
a=0A=
+   raw device. The block size ('bs') is assumed to be 512 if not =
given. =0A=
+   This program complains if 'ibs' or 'obs' are given with a value=0A=
+   that differs from 'bs' (or the default 512).=0A=
+   If 'if' is not given or 'if=3D-' then stdin is assumed. If 'of' =
is=0A=
+   not given or 'of=3D-' then stdout assumed. Multipliers:=0A=
+     'c','C'  *1       'b','B' *512      'k' *1024      'K' *1000=0A=
+     'm' *(1024^2)     'M' *(1000^2)     'g' *(1024^3)  'G' =
*(1000^3)=0A=
+=0A=
+   A non-standard argument "bpt" (blocks per transfer) is added to =
control=0A=
+   the maximum number of blocks in each transfer. The default value is =
128.=0A=
+   For example if "bs=3D512" and "bpt=3D32" then a maximum of 32 =
blocks (16KB=0A=
+   in this case) is transferred to or from the sg device in a single =
SCSI=0A=
+   command.=0A=
+=0A=
+   This version should compile with Linux sg drivers with version =
numbers=0A=
+   >=3D 30000 .=0A=
+=0A=
+   Version 5.11 20001220=0A=
+*/=0A=
+=0A=
+#define DEF_BLOCK_SIZE 512=0A=
+#define DEF_BLOCKS_PER_TRANSFER 128=0A=
+=0A=
+// #define SG_DEBUG=0A=
+=0A=
+#define SENSE_BUFF_LEN 32       /* Arbitrary, could be larger */=0A=
+#define READ_CAP_REPLY_LEN 8=0A=
+#define DEF_TIMEOUT 40000       /* 40,000 millisecs =3D=3D 40 seconds =
*/=0A=
+=0A=
+#ifndef RAW_MAJOR=0A=
+#define RAW_MAJOR 255	/*unlikey value */=0A=
+#endif =0A=
+=0A=
+#define FT_OTHER 0		/* filetype other than sg or raw device */=0A=
+#define FT_SG 1			/* filetype is sg char device */=0A=
+#define FT_RAW 2		/* filetype is raw char device */=0A=
+=0A=
+static int sum_of_resids =3D 0;=0A=
+=0A=
+static int dd_count =3D -1;=0A=
+static int in_full =3D 0;=0A=
+static int in_partial =3D 0;=0A=
+static int out_full =3D 0;=0A=
+static int out_partial =3D 0;=0A=
+=0A=
+static void install_handler (int sig_num, void (*sig_handler) (int =
sig))=0A=
+{=0A=
+    struct sigaction sigact;=0A=
+    sigaction (sig_num, NULL, &sigact);=0A=
+    if (sigact.sa_handler !=3D SIG_IGN)=0A=
+    {=0A=
+        sigact.sa_handler =3D sig_handler;=0A=
+        sigemptyset (&sigact.sa_mask);=0A=
+        sigact.sa_flags =3D 0;=0A=
+        sigaction (sig_num, &sigact, NULL);=0A=
+    }=0A=
+}=0A=
+=0A=
+static void print_stats()=0A=
+{=0A=
+    if (0 !=3D dd_count)=0A=
+        fprintf(stderr, "  remaining block count=3D%d\n", =
dd_count);=0A=
+    fprintf(stderr, "%d+%d records in\n", in_full, in_partial);=0A=
+    fprintf(stderr, "%d+%d records out\n", out_full, out_partial);=0A=
+}=0A=
+=0A=
+static void interrupt_handler(int sig)=0A=
+{=0A=
+    struct sigaction sigact;=0A=
+=0A=
+    sigact.sa_handler =3D SIG_DFL;=0A=
+    sigemptyset (&sigact.sa_mask);=0A=
+    sigact.sa_flags =3D 0;=0A=
+    sigaction (sig, &sigact, NULL);=0A=
+    fprintf(stderr, "Interrupted by signal,");=0A=
+    print_stats ();=0A=
+    kill (getpid (), sig);=0A=
+}=0A=
+=0A=
+static void siginfo_handler(int sig)=0A=
+{=0A=
+    fprintf(stderr, "Progress report, continuing ...\n");=0A=
+    print_stats ();=0A=
+}=0A=
+=0A=
+static int dd_filetype(const char * filename)=0A=
+{=0A=
+    struct stat st;=0A=
+=0A=
+    if (stat(filename, &st) < 0)=0A=
+	return FT_OTHER;=0A=
+    if (S_ISCHR(st.st_mode)) {=0A=
+	if (RAW_MAJOR =3D=3D major(st.st_rdev))=0A=
+	    return FT_RAW;=0A=
+	else if (SCSI_GENERIC_MAJOR =3D=3D major(st.st_rdev))=0A=
+	    return FT_SG;=0A=
+    }=0A=
+    return FT_OTHER;=0A=
+}=0A=
+=0A=
+static void usage()=0A=
+{=0A=
+    fprintf(stderr, "Usage: "=0A=
+           "sg_dd  [if=3D<infile>] [skip=3D<n>] [of=3D<ofile>] =
[seek=3D<n>]\n"=0A=
+           "              [bs=3D<num>] [bpt=3D<num>] [count=3D<n>]"=0A=
+           " [dio=3D<n>]\n"=0A=
+           "            either 'if' or 'of' must be a sg or raw =
device\n"=0A=
+           " 'bpt' is blocks_per_transfer (default is 128)\n"=0A=
+           " 'dio' is direct IO, 1->attempt, 0->indirect IO =
(def)\n");=0A=
+}=0A=
+=0A=
+/* Return of 0 -> success, -1 -> failure, 2 -> try again */=0A=
+static int read_capacity(int sg_fd, int * num_sect, int * sect_sz)=0A=
+{=0A=
+    int res;=0A=
+    unsigned char rcCmdBlk [10] =3D {0x25, 0, 0, 0, 0, 0, 0, 0, 0, =
0};=0A=
+    unsigned char rcBuff[READ_CAP_REPLY_LEN];=0A=
+    unsigned char sense_b[64];=0A=
+    sg_io_hdr_t io_hdr;=0A=
+=0A=
+    memset(&io_hdr, 0, sizeof(sg_io_hdr_t));=0A=
+    io_hdr.interface_id =3D 'S';=0A=
+    io_hdr.cmd_len =3D sizeof(rcCmdBlk);=0A=
+    io_hdr.mx_sb_len =3D sizeof(sense_b);=0A=
+    io_hdr.dxfer_direction =3D SG_DXFER_FROM_DEV;=0A=
+    io_hdr.dxfer_len =3D sizeof(rcBuff);=0A=
+    io_hdr.dxferp =3D rcBuff;=0A=
+    io_hdr.cmdp =3D rcCmdBlk;=0A=
+    io_hdr.sbp =3D sense_b;=0A=
+    io_hdr.timeout =3D DEF_TIMEOUT;=0A=
+=0A=
+    if (ioctl(sg_fd, SG_IO, &io_hdr) < 0) {=0A=
+        perror("read_capacity (SG_IO) error");=0A=
+        return -1;=0A=
+    }=0A=
+    res =3D sg_err_category3(&io_hdr);=0A=
+    if (SG_ERR_CAT_MEDIA_CHANGED =3D=3D res)=0A=
+        return 2; /* probably have another go ... */=0A=
+    else if (SG_ERR_CAT_CLEAN !=3D res) {=0A=
+        sg_chk_n_print3("read capacity", &io_hdr);=0A=
+        return -1;=0A=
+    }=0A=
+    *num_sect =3D 1 + ((rcBuff[0] << 24) | (rcBuff[1] << 16) |=0A=
+                (rcBuff[2] << 8) | rcBuff[3]);=0A=
+    *sect_sz =3D (rcBuff[4] << 24) | (rcBuff[5] << 16) |=0A=
+               (rcBuff[6] << 8) | rcBuff[7];=0A=
+    return 0;=0A=
+}=0A=
+=0A=
+/* -1 -> unrecoverable error, 0 -> successful, 1 -> recoverable =
(ENOMEM),=0A=
+   2 -> try again */=0A=
+int sg_read(int sg_fd, unsigned char * buff, unsigned int blocks, =
unsigned int from_block,=0A=
+            int bs, int * diop)=0A=
+{=0A=
+    unsigned char rdCmd[10] =3D {0x28, 0, 0, 0, 0, 0, 0, 0, 0, 0};=0A=
+    unsigned char senseBuff[SENSE_BUFF_LEN];=0A=
+    sg_io_hdr_t io_hdr;=0A=
+    int res;=0A=
+=0A=
+    rdCmd[2] =3D (unsigned char)((from_block >> 24) & 0xFF);=0A=
+    rdCmd[3] =3D (unsigned char)((from_block >> 16) & 0xFF);=0A=
+    rdCmd[4] =3D (unsigned char)((from_block >> 8) & 0xFF);=0A=
+    rdCmd[5] =3D (unsigned char)(from_block & 0xFF);=0A=
+    rdCmd[7] =3D (unsigned char)((blocks >> 8) & 0xff);=0A=
+    rdCmd[8] =3D (unsigned char)(blocks & 0xff);=0A=
+=0A=
+    memset(&io_hdr, 0, sizeof(sg_io_hdr_t));=0A=
+    io_hdr.interface_id =3D 'S';=0A=
+    io_hdr.cmd_len =3D sizeof(rdCmd);=0A=
+    io_hdr.cmdp =3D rdCmd;=0A=
+    io_hdr.dxfer_direction =3D SG_DXFER_FROM_DEV;=0A=
+    io_hdr.dxfer_len =3D bs * blocks;=0A=
+    io_hdr.dxferp =3D buff;=0A=
+    io_hdr.mx_sb_len =3D SENSE_BUFF_LEN;=0A=
+    io_hdr.sbp =3D senseBuff;=0A=
+    io_hdr.timeout =3D DEF_TIMEOUT;=0A=
+    io_hdr.pack_id =3D from_block;=0A=
+    if (diop && *diop)=0A=
+        io_hdr.flags |=3D SG_FLAG_DIRECT_IO;=0A=
+=0A=
+    while (((res =3D write(sg_fd, &io_hdr, sizeof(io_hdr))) < 0) &&=0A=
+           (EINTR =3D=3D errno))=0A=
+        ;=0A=
+    if (res < 0) {=0A=
+        if (ENOMEM =3D=3D errno)=0A=
+            return 1;=0A=
+        perror("reading (wr) on sg device, error");=0A=
+        return -1;=0A=
+    }=0A=
+=0A=
+    while (((res =3D read(sg_fd, &io_hdr, sizeof(io_hdr))) < 0) &&=0A=
+           (EINTR =3D=3D errno))=0A=
+        ;=0A=
+    if (res < 0) {=0A=
+        perror("reading (rd) on sg device, error");=0A=
+        return -1;=0A=
+    }=0A=
+    switch (sg_err_category3(&io_hdr)) {=0A=
+    case SG_ERR_CAT_CLEAN:=0A=
+        break;=0A=
+    case SG_ERR_CAT_RECOVERED:=0A=
+        fprintf(stderr, "Recovered error while reading block=3D%d, =
num=3D%d\n",=0A=
+               from_block, blocks);=0A=
+        break;=0A=
+    case SG_ERR_CAT_MEDIA_CHANGED:=0A=
+        return 2;=0A=
+    default:=0A=
+        sg_chk_n_print3("reading", &io_hdr);=0A=
+        return -1;=0A=
+    }=0A=
+    if (diop && *diop && =0A=
+        ((io_hdr.info & SG_INFO_DIRECT_IO_MASK) !=3D =
SG_INFO_DIRECT_IO))=0A=
+        *diop =3D 0;      /* flag that dio not done (completely) */=0A=
+    sum_of_resids +=3D io_hdr.resid;=0A=
+#if SG_DEBUG=0A=
+    fprintf(stderr, "duration=3D%u ms\n", io_hdr.duration);=0A=
+#endif=0A=
+    return 0;=0A=
+}=0A=
+=0A=
+/* -1 -> unrecoverable error, 0 -> successful, 1 -> recoverable =
(ENOMEM),=0A=
+   2 -> try again */=0A=
+int sg_write(int sg_fd, unsigned char * buff, unsigned int blocks, =
unsigned int to_block,=0A=
+             int bs, int * diop)=0A=
+{=0A=
+    unsigned char wrCmd[10] =3D {0x2a, 0, 0, 0, 0, 0, 0, 0, 0, 0};=0A=
+    unsigned char senseBuff[SENSE_BUFF_LEN];=0A=
+    sg_io_hdr_t io_hdr;=0A=
+    int res;=0A=
+=0A=
+    wrCmd[2] =3D (unsigned char)((to_block >> 24) & 0xFF);=0A=
+    wrCmd[3] =3D (unsigned char)((to_block >> 16) & 0xFF);=0A=
+    wrCmd[4] =3D (unsigned char)((to_block >> 8) & 0xFF);=0A=
+    wrCmd[5] =3D (unsigned char)(to_block & 0xFF);=0A=
+    wrCmd[7] =3D (unsigned char)((blocks >> 8) & 0xff);=0A=
+    wrCmd[8] =3D (unsigned char)(blocks & 0xff);=0A=
+=0A=
+    memset(&io_hdr, 0, sizeof(sg_io_hdr_t));=0A=
+    io_hdr.interface_id =3D 'S';=0A=
+    io_hdr.cmd_len =3D sizeof(wrCmd);=0A=
+    io_hdr.cmdp =3D wrCmd;=0A=
+    io_hdr.dxfer_direction =3D SG_DXFER_TO_DEV;=0A=
+    io_hdr.dxfer_len =3D bs * blocks;=0A=
+    io_hdr.dxferp =3D buff;=0A=
+    io_hdr.mx_sb_len =3D SENSE_BUFF_LEN;=0A=
+    io_hdr.sbp =3D senseBuff;=0A=
+    io_hdr.timeout =3D DEF_TIMEOUT;=0A=
+    io_hdr.pack_id =3D to_block;=0A=
+    if (diop && *diop)=0A=
+        io_hdr.flags |=3D SG_FLAG_DIRECT_IO;=0A=
+=0A=
+    while (((res =3D write(sg_fd, &io_hdr, sizeof(io_hdr))) < 0) &&=0A=
+           (EINTR =3D=3D errno))=0A=
+        ;=0A=
+    if (res < 0) {=0A=
+        if (ENOMEM =3D=3D errno)=0A=
+            return 1;=0A=
+        perror("writing (wr) on sg device, error");=0A=
+        return -1;=0A=
+    }=0A=
+=0A=
+    while (((res =3D read(sg_fd, &io_hdr, sizeof(io_hdr))) < 0) &&=0A=
+           (EINTR =3D=3D errno))=0A=
+        ;=0A=
+    if (res < 0) {=0A=
+        perror("writing (rd) on sg device, error");=0A=
+        return -1;=0A=
+    }=0A=
+    switch (sg_err_category3(&io_hdr)) {=0A=
+    case SG_ERR_CAT_CLEAN:=0A=
+        break;=0A=
+    case SG_ERR_CAT_RECOVERED:=0A=
+        fprintf(stderr, "Recovered error while writing block=3D%d, =
num=3D%d\n",=0A=
+               to_block, blocks);=0A=
+        break;=0A=
+    case SG_ERR_CAT_MEDIA_CHANGED:=0A=
+        return 2;=0A=
+    default:=0A=
+        sg_chk_n_print3("writing", &io_hdr);=0A=
+        return -1;=0A=
+    }=0A=
+    if (diop && *diop && =0A=
+        ((io_hdr.info & SG_INFO_DIRECT_IO_MASK) !=3D =
SG_INFO_DIRECT_IO))=0A=
+        *diop =3D 0;      /* flag that dio not done (completely) */=0A=
+    return 0;=0A=
+}=0A=
+=0A=
+static int get_num(char * buf)=0A=
+{=0A=
+    int res, num;=0A=
+    char c;=0A=
+=0A=
+    res =3D sscanf(buf, "%d%c", &num, &c);=0A=
+    if (0 =3D=3D res)=0A=
+        return -1;=0A=
+    else if (1 =3D=3D res)=0A=
+        return num;=0A=
+    else {=0A=
+    	switch (c) {=0A=
+	case 'c':=0A=
+	case 'C':=0A=
+            return num;=0A=
+	case 'b':=0A=
+	case 'B':=0A=
+            return num * 512;=0A=
+	case 'k':=0A=
+            return num * 1024;=0A=
+	case 'K':=0A=
+            return num * 1000;=0A=
+	case 'm':=0A=
+            return num * 1024 * 1024;=0A=
+	case 'M':=0A=
+            return num * 1000000;=0A=
+	case 'g':=0A=
+            return num * 1024 * 1024 * 1024;=0A=
+	case 'G':=0A=
+            return num * 1000000000;=0A=
+        default:=0A=
+            fprintf(stderr, "unrecognized multiplier\n");=0A=
+            return -1;=0A=
+	}=0A=
+    }=0A=
+}=0A=
+=0A=
+#if 0=0A=
+static int sg_dd_main(int argc, char * argv[])=0A=
+{=0A=
+    int skip =3D 0;=0A=
+    int seek =3D 0;=0A=
+    int bs =3D 0;=0A=
+    int ibs =3D 0;=0A=
+    int obs =3D 0;=0A=
+    int bpt =3D DEF_BLOCKS_PER_TRANSFER;=0A=
+    char str[512];=0A=
+    char * key;=0A=
+    char * buf;=0A=
+    char inf[512];=0A=
+    int in_type =3D FT_OTHER;=0A=
+    char outf[512];=0A=
+    int out_type =3D FT_OTHER;=0A=
+    int dio =3D 0;=0A=
+    int dio_incomplete =3D 0;=0A=
+    int res, k, t, buf_sz, dio_tmp;=0A=
+    int infd, outfd, blocks;=0A=
+    unsigned char * wrkBuff;=0A=
+    unsigned char * wrkPos;=0A=
+    int in_num_sect =3D 0;=0A=
+    int out_num_sect =3D 0;=0A=
+    int in_sect_sz, out_sect_sz;=0A=
+    char ebuff[256];=0A=
+    int blocks_per;=0A=
+=0A=
+    inf[0] =3D '\0';=0A=
+    outf[0] =3D '\0';=0A=
+    if (argc < 2) {=0A=
+        usage();=0A=
+        return 1;=0A=
+    }=0A=
+=0A=
+    for(k =3D 1; k < argc; k++) {=0A=
+        if (argv[k])=0A=
+            strcpy(str, argv[k]);=0A=
+        else=0A=
+            continue;=0A=
+        for(key =3D str, buf =3D key; *buf && *buf !=3D '=3D';)=0A=
+            buf++;=0A=
+        if (*buf)=0A=
+            *buf++ =3D '\0';=0A=
+        if (strcmp(key,"if") =3D=3D 0)=0A=
+            strcpy(inf, buf);=0A=
+        else if (strcmp(key,"of") =3D=3D 0)=0A=
+            strcpy(outf, buf);=0A=
+        else if (0 =3D=3D strcmp(key,"ibs"))=0A=
+            ibs =3D get_num(buf);=0A=
+        else if (0 =3D=3D strcmp(key,"obs"))=0A=
+            obs =3D get_num(buf);=0A=
+        else if (0 =3D=3D strcmp(key,"bs"))=0A=
+            bs =3D get_num(buf);=0A=
+        else if (0 =3D=3D strcmp(key,"bpt"))=0A=
+            bpt =3D get_num(buf);=0A=
+        else if (0 =3D=3D strcmp(key,"skip"))=0A=
+            skip =3D get_num(buf);=0A=
+        else if (0 =3D=3D strcmp(key,"seek"))=0A=
+            seek =3D get_num(buf);=0A=
+        else if (0 =3D=3D strcmp(key,"count"))=0A=
+            dd_count =3D get_num(buf);=0A=
+        else if (0 =3D=3D strcmp(key,"dio"))=0A=
+            dio =3D get_num(buf);=0A=
+        else {=0A=
+            fprintf(stderr, "Unrecognized argument '%s'\n", key);=0A=
+            usage();=0A=
+            return 1;=0A=
+        }=0A=
+    }=0A=
+    if (bs <=3D 0) {=0A=
+        bs =3D DEF_BLOCK_SIZE;=0A=
+        fprintf(stderr, "Assume default 'bs' (block size) of %d =
bytes\n", bs);=0A=
+    }=0A=
+    if ((ibs && (ibs !=3D bs)) || (obs && (obs !=3D bs))) {=0A=
+        fprintf(stderr, "If 'ibs' or 'obs' given must be same as =
'bs'\n");=0A=
+        usage();=0A=
+        return 1;=0A=
+    }=0A=
+    if ((skip < 0) || (seek < 0)) {=0A=
+        fprintf(stderr, "skip and seek cannot be negative\n");=0A=
+        return 1;=0A=
+    }=0A=
+#ifdef SG_DEBUG=0A=
+    fprintf(stderr, "sg_dd: if=3D%s skip=3D%d of=3D%s seek=3D%d =
count=3D%d\n",=0A=
+           inf, skip, outf, seek, dd_count);=0A=
+#endif=0A=
+    install_handler (SIGINT, interrupt_handler);=0A=
+    install_handler (SIGQUIT, interrupt_handler);=0A=
+    install_handler (SIGPIPE, interrupt_handler);=0A=
+    install_handler (SIGUSR1, siginfo_handler);=0A=
+=0A=
+    infd =3D STDIN_FILENO;=0A=
+    outfd =3D STDOUT_FILENO;=0A=
+    if (inf[0] && ('-' !=3D inf[0])) {=0A=
+	in_type =3D dd_filetype(inf);=0A=
+=0A=
+	if (FT_SG =3D=3D in_type) {=0A=
+	    if ((infd =3D open(inf, O_RDWR)) < 0) {=0A=
+                sprintf(ebuff, "sg_dd: could not open %s for sg =
reading", inf);=0A=
+                perror(ebuff);=0A=
+                return 1;=0A=
+            }=0A=
+	    t =3D bs * bpt;=0A=
+            res =3D ioctl(infd, SG_SET_RESERVED_SIZE, &t);=0A=
+            if (res < 0)=0A=
+                perror("sg_dd: SG_SET_RESERVED_SIZE error");=0A=
+            res =3D ioctl(infd, SG_GET_VERSION_NUM, &t);=0A=
+            if ((res < 0) || (t < 30000)) {=0A=
+                fprintf(stderr, "sg_dd: sg driver prior to =
3.x.y\n");=0A=
+                return 1;=0A=
+            }=0A=
+        }=0A=
+        if (FT_SG !=3D in_type) {=0A=
+            if ((infd =3D open(inf, O_RDONLY)) < 0) {=0A=
+                sprintf(ebuff, "sg_dd: could not open %s for reading", =
inf);=0A=
+                perror(ebuff);=0A=
+                return 1;=0A=
+            }=0A=
+            else if (skip > 0) {=0A=
+                llse_loff_t offset =3D skip;=0A=
+=0A=
+                offset *=3D bs;       /* could exceed 32 bits here! =
*/=0A=
+                if (llse_llseek(infd, offset, SEEK_SET) < 0) {=0A=
+                    sprintf(ebuff,=0A=
+                "sg_dd: couldn't skip to required position on %s", =
inf);=0A=
+                    perror(ebuff);=0A=
+                    return 1;=0A=
+                }=0A=
+            }=0A=
+        }=0A=
+    }=0A=
+=0A=
+    if (outf[0] && ('-' !=3D outf[0])) {=0A=
+	out_type =3D dd_filetype(outf);=0A=
+=0A=
+	if (FT_SG =3D=3D out_type) {=0A=
+	    if ((outfd =3D open(outf, O_RDWR)) < 0) {=0A=
+                sprintf(ebuff, "sg_dd: could not open %s for sg =
writing", outf);=0A=
+                perror(ebuff);=0A=
+                return 1;=0A=
+            }=0A=
+            t =3D bs * bpt;=0A=
+            res =3D ioctl(outfd, SG_SET_RESERVED_SIZE, &t);=0A=
+            if (res < 0)=0A=
+                perror("sg_dd: SG_SET_RESERVED_SIZE error");=0A=
+            res =3D ioctl(outfd, SG_GET_VERSION_NUM, &t);=0A=
+            if ((res < 0) || (t < 30000)) {=0A=
+                fprintf(stderr, "sg_dd: sg driver prior to =
3.x.y\n");=0A=
+                return 1;=0A=
+            }=0A=
+        }=0A=
+	else {=0A=
+	    if (FT_OTHER =3D=3D out_type) {=0A=
+		if ((outfd =3D open(outf, O_WRONLY | O_CREAT, 0666)) < 0) {=0A=
+		    sprintf(ebuff,=0A=
+			    "sg_dd: could not open %s for writing", outf);=0A=
+		    perror(ebuff);=0A=
+		    return 1;=0A=
+		}=0A=
+	    }=0A=
+	    else {=0A=
+		if ((outfd =3D open(outf, O_WRONLY)) < 0) {=0A=
+		    sprintf(ebuff,=0A=
+			    "sg_dd: could not open %s for raw writing", outf);=0A=
+		    perror(ebuff);=0A=
+		    return 1;=0A=
+		}=0A=
+	    }=0A=
+            if (seek > 0) {=0A=
+                llse_loff_t offset =3D seek;=0A=
+=0A=
+                offset *=3D bs;       /* could exceed 32 bits here! =
*/=0A=
+                if (llse_llseek(outfd, offset, SEEK_SET) < 0) {=0A=
+                    sprintf(ebuff,=0A=
+                "sg_dd: couldn't seek to required position on %s", =
outf);=0A=
+                    perror(ebuff);=0A=
+                    return 1;=0A=
+                }=0A=
+            }=0A=
+        }=0A=
+    }=0A=
+    if ((STDIN_FILENO =3D=3D infd) && (STDOUT_FILENO =3D=3D outfd)) =
{=0A=
+        fprintf(stderr, =0A=
+		"Can't have both 'if' as stdin _and_ 'of' as stdout\n");=0A=
+        return 1;=0A=
+    }=0A=
+#if 1=0A=
+    if ((FT_OTHER =3D=3D in_type) && (FT_OTHER =3D=3D out_type)) {=0A=
+        fprintf(stderr, "Both 'if' and 'of' can't be ordinary =
files\n");=0A=
+        return 1;=0A=
+    }=0A=
+#endif=0A=
+    if (0 =3D=3D dd_count)=0A=
+        return 0;=0A=
+    else if (dd_count < 0) {=0A=
+        if (FT_SG =3D=3D in_type) {=0A=
+            res =3D read_capacity(infd, &in_num_sect, &in_sect_sz);=0A=
+            if (2 =3D=3D res) {=0A=
+                fprintf(stderr, =0A=
+			"Unit attention, media changed(in), try again\n");=0A=
+                res =3D read_capacity(infd, &in_num_sect, =
&in_sect_sz);=0A=
+            }=0A=
+            if (0 !=3D res) {=0A=
+                fprintf(stderr, "Unable to read capacity on %s\n", =
inf);=0A=
+                in_num_sect =3D -1;=0A=
+            }=0A=
+            else {=0A=
+#if 0=0A=
+                if (0 =3D=3D in_sect_sz)=0A=
+                    in_sect_sz =3D bs;=0A=
+                else if (in_sect_sz > bs)=0A=
+                    in_num_sect *=3D  (in_sect_sz / bs);=0A=
+                else if (in_sect_sz < bs)=0A=
+                    in_num_sect /=3D  (bs / in_sect_sz);=0A=
+#endif=0A=
+                if (in_num_sect > skip)=0A=
+                    in_num_sect -=3D skip;=0A=
+            }=0A=
+        }=0A=
+        if (FT_SG =3D=3D out_type) {=0A=
+            res =3D read_capacity(outfd, &out_num_sect, =
&out_sect_sz);=0A=
+            if (2 =3D=3D res) {=0A=
+                fprintf(stderr, =0A=
+			"Unit attention, media changed(out), try again\n");=0A=
+                res =3D read_capacity(outfd, &out_num_sect, =
&out_sect_sz);=0A=
+            }=0A=
+            if (0 !=3D res) {=0A=
+                fprintf(stderr, "Unable to read capacity on %s\n", =
outf);=0A=
+                out_num_sect =3D -1;=0A=
+            }=0A=
+            else {=0A=
+                if (out_num_sect > seek)=0A=
+                    out_num_sect -=3D seek;=0A=
+            }=0A=
+        }=0A=
+#ifdef SG_DEBUG=0A=
+    fprintf(stderr, =0A=
+	    "Start of loop, count=3D%d, in_num_sect=3D%d, =
out_num_sect=3D%d\n", =0A=
+            dd_count, in_num_sect, out_num_sect);=0A=
+#endif=0A=
+        if (in_num_sect > 0) {=0A=
+            if (out_num_sect > 0)=0A=
+                dd_count =3D (in_num_sect > out_num_sect) ? =
out_num_sect :=0A=
+                                                       in_num_sect;=0A=
+            else=0A=
+                dd_count =3D in_num_sect;=0A=
+        }=0A=
+        else=0A=
+            dd_count =3D out_num_sect;=0A=
+    }=0A=
+    if (dd_count <=3D 0) {=0A=
+        fprintf(stderr, "Couldn't calculate count, please give =
one\n");=0A=
+        return 1;=0A=
+    }=0A=
+=0A=
+    if (dio || (FT_RAW =3D=3D in_type) || (FT_RAW =3D=3D out_type)) =
{=0A=
+	size_t psz =3D getpagesize();=0A=
+	wrkBuff =3D malloc(bs * bpt + psz);=0A=
+	if (0 =3D=3D wrkBuff) {=0A=
+            fprintf(stderr, "Not enough user memory for raw\n");=0A=
+            return 1;=0A=
+        }=0A=
+	wrkPos =3D (unsigned char *)(((unsigned long)wrkBuff + psz - 1) &=0A=
+		                   (~(psz - 1)));=0A=
+    }=0A=
+    else {=0A=
+	wrkBuff =3D malloc(bs * bpt);=0A=
+	if (0 =3D=3D wrkBuff) {=0A=
+            fprintf(stderr, "Not enough user memory\n");=0A=
+            return 1;=0A=
+        }=0A=
+        wrkPos =3D wrkBuff;=0A=
+    }=0A=
+=0A=
+    blocks_per =3D bpt;=0A=
+#ifdef SG_DEBUG=0A=
+    fprintf(stderr, "Start of loop, count=3D%d, blocks_per=3D%d\n", =
=0A=
+	    dd_count, blocks_per);=0A=
+#endif=0A=
+    while (dd_count > 0) {=0A=
+        blocks =3D (dd_count > blocks_per) ? blocks_per : dd_count;=0A=
+        if (FT_SG =3D=3D in_type) {=0A=
+            dio_tmp =3D dio;=0A=
+            res =3D sg_read(infd, wrkPos, blocks, skip, bs, =
&dio_tmp);=0A=
+            if (1 =3D=3D res) {     /* ENOMEM, find what's =
available+try that */=0A=
+                if (ioctl(infd, SG_GET_RESERVED_SIZE, &buf_sz) < 0) =
{=0A=
+                    perror("RESERVED_SIZE ioctls failed");=0A=
+                    break;=0A=
+                }=0A=
+                blocks_per =3D (buf_sz + bs - 1) / bs;=0A=
+                blocks =3D blocks_per;=0A=
+                fprintf(stderr, =0A=
+			"Reducing read to %d blocks per loop\n", blocks_per);=0A=
+                res =3D sg_read(infd, wrkPos, blocks, skip, bs, =
&dio_tmp);=0A=
+            }=0A=
+            else if (2 =3D=3D res) {=0A=
+                fprintf(stderr, =0A=
+			"Unit attention, media changed, try again (r)\n");=0A=
+                res =3D sg_read(infd, wrkPos, blocks, skip, bs, =
&dio_tmp);=0A=
+            }=0A=
+            if (0 !=3D res) {=0A=
+                fprintf(stderr, "sg_read failed, skip=3D%d\n", =
skip);=0A=
+                break;=0A=
+            }=0A=
+            else {=0A=
+                in_full +=3D blocks;=0A=
+                if (dio && (0 =3D=3D dio_tmp))=0A=
+                    dio_incomplete++;=0A=
+            }=0A=
+        }=0A=
+        else {=0A=
+	    while (((res =3D read(infd, wrkPos, blocks * bs)) < 0) &&=0A=
+		   (EINTR =3D=3D errno))=0A=
+		;=0A=
+            if (res < 0) {=0A=
+                sprintf(ebuff, "sg_dd: reading, skip=3D%d ", skip);=0A=
+                perror(ebuff);=0A=
+                break;=0A=
+            }=0A=
+            else if (res < blocks * bs) {=0A=
+                dd_count =3D 0;=0A=
+                blocks =3D res / bs;=0A=
+                if ((res % bs) > 0) {=0A=
+                    blocks++;=0A=
+                    in_partial++;=0A=
+                }=0A=
+            }=0A=
+            in_full +=3D blocks;=0A=
+        }=0A=
+=0A=
+        if (FT_SG =3D=3D out_type) {=0A=
+            dio_tmp =3D dio;=0A=
+            res =3D sg_write(outfd, wrkPos, blocks, seek, bs, =
&dio_tmp);=0A=
+            if (1 =3D=3D res) {     /* ENOMEM, find what's =
available+try that */=0A=
+                if (ioctl(outfd, SG_GET_RESERVED_SIZE, &buf_sz) < 0) =
{=0A=
+                    perror("RESERVED_SIZE ioctls failed");=0A=
+                    break;=0A=
+                }=0A=
+                blocks_per =3D (buf_sz + bs - 1) / bs;=0A=
+                blocks =3D blocks_per;=0A=
+                fprintf(stderr, =0A=
+			"Reducing write to %d blocks per loop\n", blocks);=0A=
+                res =3D sg_write(outfd, wrkPos, blocks, seek, bs, =
&dio_tmp);=0A=
+            }=0A=
+            else if (2 =3D=3D res) {=0A=
+                fprintf(stderr, =0A=
+			"Unit attention, media changed, try again (w)\n");=0A=
+                res =3D sg_write(outfd, wrkPos, blocks, seek, bs, =
&dio_tmp);=0A=
+            }=0A=
+            else if (0 !=3D res) {=0A=
+                fprintf(stderr, "sg_write failed, seek=3D%d\n", =
seek);=0A=
+                break;=0A=
+            }=0A=
+            else {=0A=
+                out_full +=3D blocks;=0A=
+                if (dio && (0 =3D=3D dio_tmp))=0A=
+                    dio_incomplete++;=0A=
+            }=0A=
+        }=0A=
+        else {=0A=
+	    while (((res =3D write(outfd, wrkPos, blocks * bs)) < 0)=0A=
+		   && (EINTR =3D=3D errno))=0A=
+		;=0A=
+            if (res < 0) {=0A=
+                sprintf(ebuff, "sg_dd: writing, seek=3D%d ", seek);=0A=
+                perror(ebuff);=0A=
+                break;=0A=
+            }=0A=
+            else if (res < blocks * bs) {=0A=
+                fprintf(stderr, "output file probably full, seek=3D%d =
", seek);=0A=
+                blocks =3D res / bs;=0A=
+                out_full +=3D blocks;=0A=
+                if ((res % bs) > 0)=0A=
+                    out_partial++;=0A=
+                break;=0A=
+            }=0A=
+            else=0A=
+                out_full +=3D blocks;=0A=
+        }=0A=
+        if (dd_count > 0)=0A=
+            dd_count -=3D blocks;=0A=
+        skip +=3D blocks;=0A=
+        seek +=3D blocks;=0A=
+    }=0A=
+=0A=
+    free(wrkBuff);=0A=
+    if (STDIN_FILENO !=3D infd)=0A=
+        close(infd);=0A=
+    if (STDOUT_FILENO !=3D outfd)=0A=
+        close(outfd);=0A=
+    res =3D 0;=0A=
+    if (0 !=3D dd_count) {=0A=
+        fprintf(stderr, "Some error occurred,");=0A=
+	res =3D 2;=0A=
+    }=0A=
+    print_stats();=0A=
+    if (dio_incomplete)=0A=
+        fprintf(stderr, ">> Direct IO requested but incomplete %d =
times\n", =0A=
+                dio_incomplete);=0A=
+    if (sum_of_resids)=0A=
+        fprintf(stderr, ">> Non-zero sum of residual counts=3D%d\n", =
=0A=
+		sum_of_resids);=0A=
+    return res;=0A=
+}=0A=
+#endif=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/sg_dd.h =
parted-1.4.7-gpt/libparted/sg_dd.h=0A=
--- parted-1.4.7/libparted/sg_dd.h	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/sg_dd.h	Thu Jan 18 11:24:42 2001=0A=
@@ -0,0 +1,23 @@=0A=
+ /*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+int sg_write(int sg_fd, unsigned char * buff, unsigned int blocks, =
unsigned int to_block,=0A=
+             int bs, int * diop);=0A=
+int sg_read(int sg_fd, unsigned char * buff, unsigned int blocks, =
unsigned int from_block,=0A=
+            int bs, int * diop);=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/sg_err.c =
parted-1.4.7-gpt/libparted/sg_err.c=0A=
--- parted-1.4.7/libparted/sg_err.c	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/sg_err.c	Thu Jan 18 11:24:42 2001=0A=
@@ -0,0 +1,648 @@=0A=
+ /*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+*/=0A=
+#include <stdio.h>=0A=
+#include <stdlib.h>=0A=
+#include "sg_err.h"=0A=
+=0A=
+/* This file is a huge cut, paste and hack from =
linux/drivers/scsi/constant.c=0A=
+*  which I guess was written by:=0A=
+*         Copyright (C) 1993, 1994, 1995 Eric Youngdale=0A=
+=0A=
+* The rest of this is:=0A=
+*  Copyright (C) 1999 D. Gilbert=0A=
+*=0A=
+*  This program is free software; you can redistribute it and/or =
modify=0A=
+*  it under the terms of the GNU General Public License as published =
by=0A=
+*  the Free Software Foundation; either version 2, or (at your =
option)=0A=
+*  any later version.=0A=
+*=0A=
+*  ASCII values for a number of symbolic constants, printing =
functions, etc.=0A=
+*=0A=
+*  Some of the tables have been updated for SCSI 2.=0A=
+*=0A=
+*  Version 0.83 (991208)=0A=
+*/=0A=
+=0A=
+=0A=
+static const unsigned char scsi_command_size[8] =3D { 6, 10, 10, =
12,=0A=
+                                                   12, 12, 10, 10 =
};=0A=
+=0A=
+#define COMMAND_SIZE(opcode) scsi_command_size[((opcode) >> 5) & 7]=0A=
+=0A=
+static const char unknown[] =3D "UNKNOWN";=0A=
+=0A=
+static const char * group_0_commands[] =3D {=0A=
+/* 00-03 */ "Test Unit Ready", "Rezero Unit", unknown, "Request =
Sense",=0A=
+/* 04-07 */ "Format Unit", "Read Block Limits", unknown, "Reasssign =
Blocks",=0A=
+/* 08-0d */ "Read (6)", unknown, "Write (6)", "Seek (6)", unknown, =
unknown,=0A=
+/* 0e-12 */ unknown, "Read Reverse", "Write Filemarks", "Space", =
"Inquiry",=0A=
+/* 13-16 */ "Verify", "Recover Buffered Data", "Mode Select", =
"Reserve",=0A=
+/* 17-1b */ "Release", "Copy", "Erase", "Mode Sense", "Start/Stop =
Unit",=0A=
+/* 1c-1d */ "Receive Diagnostic", "Send Diagnostic",=0A=
+/* 1e-1f */ "Prevent/Allow Medium Removal", unknown,=0A=
+};=0A=
+=0A=
+=0A=
+static const char *group_1_commands[] =3D {=0A=
+/* 20-22 */  unknown, unknown, unknown,=0A=
+/* 23-28 */ unknown, "Define window parameters", "Read Capacity",=0A=
+            unknown, unknown, "Read (10)",=0A=
+/* 29-2d */ "Read Generation", "Write (10)", "Seek (10)", "Erase",=0A=
+            "Read updated block",=0A=
+/* 2e-31 */ "Write Verify","Verify", "Search High", "Search Equal",=0A=
+/* 32-34 */ "Search Low", "Set Limits", "Prefetch or Read =
Position",=0A=
+/* 35-37 */ "Synchronize Cache","Lock/Unlock Cache", "Read Defect =
Data",=0A=
+/* 38-3c */ "Medium Scan", "Compare", "Copy Verify", "Write =
Buffer",=0A=
+            "Read Buffer",=0A=
+/* 3d-3f */ "Update Block", "Read Long",  "Write Long",=0A=
+};=0A=
+=0A=
+static const char *group_2_commands[] =3D {=0A=
+/* 40-41 */ "Change Definition", "Write Same",=0A=
+/* 42-48 */ "Read sub-channel", "Read TOC", "Read header",=0A=
+            "Play audio (10)", unknown, "Play audio msf",=0A=
+            "Play audio track/index",=0A=
+/* 49-4f */ "Play track relative (10)", unknown, "Pause/resume",=0A=
+            "Log Select", "Log Sense", unknown, unknown,=0A=
+/* 50-55 */ unknown, unknown, unknown, unknown, unknown, "Mode Select =
(10)",=0A=
+/* 56-5b */ unknown, unknown, unknown, unknown, "Mode Sense (10)", =
unknown,=0A=
+/* 5c-5f */ unknown, unknown, unknown,=0A=
+};=0A=
+=0A=
+=0A=
+/* The following are 12 byte commands in group 5 */=0A=
+static const char *group_5_commands[] =3D {=0A=
+/* a0-a5 */ unknown, unknown, unknown, unknown, unknown,=0A=
+            "Move medium/play audio(12)",=0A=
+/* a6-a9 */ "Exchange medium", unknown, "Read(12)", "Play track =
relative(12)",=0A=
+/* aa-ae */ "Write(12)", unknown, "Erase(12)", unknown,=0A=
+            "Write and verify(12)",=0A=
+/* af-b1 */ "Verify(12)", "Search data high(12)", "Search data =
equal(12)",=0A=
+/* b2-b4 */ "Search data low(12)", "Set limits(12)", unknown,=0A=
+/* b5-b6 */ "Request volume element address", "Send volume tag",=0A=
+/* b7-b9 */ "Read defect data(12)", "Read element status", unknown,=0A=
+/* ba-bf */ unknown, unknown, unknown, unknown, unknown, unknown,=0A=
+};=0A=
+=0A=
+=0A=
+=0A=
+=0A=
+#define group(opcode) (((opcode) >> 5) & 7)=0A=
+=0A=
+#define RESERVED_GROUP  0=0A=
+#define VENDOR_GROUP    1=0A=
+=0A=
+static const char **commands[] =3D {=0A=
+    group_0_commands, group_1_commands, group_2_commands,=0A=
+    (const char **) RESERVED_GROUP, (const char **) RESERVED_GROUP,=0A=
+    group_5_commands, (const char **) VENDOR_GROUP,=0A=
+    (const char **) VENDOR_GROUP=0A=
+};=0A=
+=0A=
+static const char reserved[] =3D "RESERVED";=0A=
+static const char vendor[] =3D "VENDOR SPECIFIC";=0A=
+=0A=
+static void print_opcode(int opcode) {=0A=
+    const char **table =3D commands[ group(opcode) ];=0A=
+    switch ((unsigned long) table) {=0A=
+    case RESERVED_GROUP:=0A=
+        printf("%s(0x%02x) ", reserved, opcode);=0A=
+        break;=0A=
+    case VENDOR_GROUP:=0A=
+        printf("%s(0x%02x) ", vendor, opcode);=0A=
+        break;=0A=
+    default:=0A=
+        if (table[opcode & 0x1f] !=3D unknown)=0A=
+            printf("%s ",table[opcode & 0x1f]);=0A=
+        else=0A=
+            printf("%s(0x%02x) ", unknown, opcode);=0A=
+        break;=0A=
+    }=0A=
+}=0A=
+=0A=
+void sg_print_command (const unsigned char * command) {=0A=
+    int i,s;=0A=
+    print_opcode(command[0]);=0A=
+    for ( i =3D 1, s =3D COMMAND_SIZE(command[0]); i < s; ++i)=0A=
+        printf("%02x ", command[i]);=0A=
+    printf("\n");=0A=
+}=0A=
+=0A=
+static const char * statuses[] =3D {=0A=
+/* 0-4 */ "Good", "Check Condition", "Condition Met", unknown, =
"Busy",=0A=
+/* 5-9 */ unknown, unknown, unknown, "Intermediate", unknown,=0A=
+/* a-c */ "Intermediate-Condition Met", unknown, "Reservation =
Conflict",=0A=
+/* d-10 */ unknown, unknown, unknown, unknown,=0A=
+/* 11-14 */ "Command Terminated", unknown, unknown, "Queue Full",=0A=
+/* 15-1a */ unknown, unknown, unknown,  unknown, unknown, unknown,=0A=
+/* 1b-1f */ unknown, unknown, unknown,  unknown, unknown,=0A=
+};=0A=
+=0A=
+void sg_print_status (int masked_status) {=0A=
+    /* status =3D (status >> 1) & 0xf; */ /* already done */=0A=
+    printf("%s ",statuses[masked_status]);=0A=
+}=0A=
+=0A=
+#define D 0x001  /* DIRECT ACCESS DEVICE (disk) */=0A=
+#define T 0x002  /* SEQUENTIAL ACCESS DEVICE (tape) */=0A=
+#define L 0x004  /* PRINTER DEVICE */=0A=
+#define P 0x008  /* PROCESSOR DEVICE */=0A=
+#define W 0x010  /* WRITE ONCE READ MULTIPLE DEVICE */=0A=
+#define R 0x020  /* READ ONLY (CD-ROM) DEVICE */=0A=
+#define S 0x040  /* SCANNER DEVICE */=0A=
+#define O 0x080  /* OPTICAL MEMORY DEVICE */=0A=
+#define M 0x100  /* MEDIA CHANGER DEVICE */=0A=
+#define C 0x200  /* COMMUNICATION DEVICE */=0A=
+=0A=
+struct error_info{=0A=
+    unsigned char code1, code2;=0A=
+    unsigned short int devices;=0A=
+    const char * text;=0A=
+};=0A=
+=0A=
+struct error_info2{=0A=
+    unsigned char code1, code2_min, code2_max;=0A=
+    unsigned short int devices;=0A=
+    const char * text;=0A=
+};=0A=
+=0A=
+static struct error_info2 additional2[] =3D=0A=
+{=0A=
+  {0x40,0x00,0x7f,D,"Ram failure (%x)"},=0A=
+  {0x40,0x80,0xff,D|T|L|P|W|R|S|O|M|C,"Diagnostic failure on component =
(%x)"},=0A=
+  {0x41,0x00,0xff,D,"Data path failure (%x)"},=0A=
+  {0x42,0x00,0xff,D,"Power-on or self-test failure (%x)"},=0A=
+  {0, 0, 0, 0, NULL}=0A=
+};=0A=
+=0A=
+static struct error_info additional[] =3D=0A=
+{=0A=
+  {0x00,0x01,T,"Filemark detected"},=0A=
+  {0x00,0x02,T|S,"End-of-partition/medium detected"},=0A=
+  {0x00,0x03,T,"Setmark detected"},=0A=
+  {0x00,0x04,T|S,"Beginning-of-partition/medium detected"},=0A=
+  {0x00,0x05,T|S,"End-of-data detected"},=0A=
+  {0x00,0x06,D|T|L|P|W|R|S|O|M|C,"I/O process terminated"},=0A=
+  {0x00,0x11,R,"Audio play operation in progress"},=0A=
+  {0x00,0x12,R,"Audio play operation paused"},=0A=
+  {0x00,0x13,R,"Audio play operation successfully completed"},=0A=
+  {0x00,0x14,R,"Audio play operation stopped due to error"},=0A=
+  {0x00,0x15,R,"No current audio status to return"},=0A=
+  {0x01,0x00,D|W|O,"No index/sector signal"},=0A=
+  {0x02,0x00,D|W|R|O|M,"No seek complete"},=0A=
+  {0x03,0x00,D|T|L|W|S|O,"Peripheral device write fault"},=0A=
+  {0x03,0x01,T,"No write current"},=0A=
+  {0x03,0x02,T,"Excessive write errors"},=0A=
+  {0x04,0x00,D|T|L|P|W|R|S|O|M|C,=0A=
+     "Logical unit not ready, cause not reportable"},=0A=
+  {0x04,0x01,D|T|L|P|W|R|S|O|M|C,=0A=
+     "Logical unit is in process of becoming ready"},=0A=
+  {0x04,0x02,D|T|L|P|W|R|S|O|M|C,=0A=
+     "Logical unit not ready, initializing command required"},=0A=
+  {0x04,0x03,D|T|L|P|W|R|S|O|M|C,=0A=
+     "Logical unit not ready, manual intervention required"},=0A=
+  {0x04,0x04,D|T|L|O,"Logical unit not ready, format in progress"},=0A=
+  {0x05,0x00,D|T|L|W|R|S|O|M|C,"Logical unit does not respond to =
selection"},=0A=
+  {0x06,0x00,D|W|R|O|M,"No reference position found"},=0A=
+  {0x07,0x00,D|T|L|W|R|S|O|M,"Multiple peripheral devices =
selected"},=0A=
+  {0x08,0x00,D|T|L|W|R|S|O|M|C,"Logical unit communication =
failure"},=0A=
+  {0x08,0x01,D|T|L|W|R|S|O|M|C,"Logical unit communication =
time-out"},=0A=
+  {0x08,0x02,D|T|L|W|R|S|O|M|C,"Logical unit communication parity =
error"},=0A=
+  {0x09,0x00,D|T|W|R|O,"Track following error"},=0A=
+  {0x09,0x01,W|R|O,"Tracking servo failure"},=0A=
+  {0x09,0x02,W|R|O,"Focus servo failure"},=0A=
+  {0x09,0x03,W|R|O,"Spindle servo failure"},=0A=
+  {0x0A,0x00,D|T|L|P|W|R|S|O|M|C,"Error log overflow"},=0A=
+  {0x0C,0x00,T|S,"Write error"},=0A=
+  {0x0C,0x01,D|W|O,"Write error recovered with auto reallocation"},=0A=
+  {0x0C,0x02,D|W|O,"Write error - auto reallocation failed"},=0A=
+  {0x10,0x00,D|W|O,"Id crc or ecc error"},=0A=
+  {0x11,0x00,D|T|W|R|S|O,"Unrecovered read error"},=0A=
+  {0x11,0x01,D|T|W|S|O,"Read retries exhausted"},=0A=
+  {0x11,0x02,D|T|W|S|O,"Error too long to correct"},=0A=
+  {0x11,0x03,D|T|W|S|O,"Multiple read errors"},=0A=
+  {0x11,0x04,D|W|O,"Unrecovered read error - auto reallocate =
failed"},=0A=
+  {0x11,0x05,W|R|O,"L-ec uncorrectable error"},=0A=
+  {0x11,0x06,W|R|O,"Circ unrecovered error"},=0A=
+  {0x11,0x07,W|O,"Data resynchronization error"},=0A=
+  {0x11,0x08,T,"Incomplete block read"},=0A=
+  {0x11,0x09,T,"No gap found"},=0A=
+  {0x11,0x0A,D|T|O,"Miscorrected error"},=0A=
+  {0x11,0x0B,D|W|O,"Unrecovered read error - recommend =
reassignment"},=0A=
+  {0x11,0x0C,D|W|O,"Unrecovered read error - recommend rewrite the =
data"},=0A=
+  {0x12,0x00,D|W|O,"Address mark not found for id field"},=0A=
+  {0x13,0x00,D|W|O,"Address mark not found for data field"},=0A=
+  {0x14,0x00,D|T|L|W|R|S|O,"Recorded entity not found"},=0A=
+  {0x14,0x01,D|T|W|R|O,"Record not found"},=0A=
+  {0x14,0x02,T,"Filemark or setmark not found"},=0A=
+  {0x14,0x03,T,"End-of-data not found"},=0A=
+  {0x14,0x04,T,"Block sequence error"},=0A=
+  {0x15,0x00,D|T|L|W|R|S|O|M,"Random positioning error"},=0A=
+  {0x15,0x01,D|T|L|W|R|S|O|M,"Mechanical positioning error"},=0A=
+  {0x15,0x02,D|T|W|R|O,"Positioning error detected by read of =
medium"},=0A=
+  {0x16,0x00,D|W|O,"Data synchronization mark error"},=0A=
+  {0x17,0x00,D|T|W|R|S|O,"Recovered data with no error correction =
applied"},=0A=
+  {0x17,0x01,D|T|W|R|S|O,"Recovered data with retries"},=0A=
+  {0x17,0x02,D|T|W|R|O,"Recovered data with positive head offset"},=0A=
+  {0x17,0x03,D|T|W|R|O,"Recovered data with negative head offset"},=0A=
+  {0x17,0x04,W|R|O,"Recovered data with retries and/or circ =
applied"},=0A=
+  {0x17,0x05,D|W|R|O,"Recovered data using previous sector id"},=0A=
+  {0x17,0x06,D|W|O,"Recovered data without ecc - data =
auto-reallocated"},=0A=
+  {0x17,0x07,D|W|O,"Recovered data without ecc - recommend =
reassignment"},=0A=
+  {0x18,0x00,D|T|W|R|O,"Recovered data with error correction =
applied"},=0A=
+  {0x18,0x01,D|W|R|O,"Recovered data with error correction and retries =
applied"},=0A=
+  {0x18,0x02,D|W|R|O,"Recovered data - data auto-reallocated"},=0A=
+  {0x18,0x03,R,"Recovered data with circ"},=0A=
+  {0x18,0x04,R,"Recovered data with lec"},=0A=
+  {0x18,0x05,D|W|R|O,"Recovered data - recommend reassignment"},=0A=
+  {0x19,0x00,D|O,"Defect list error"},=0A=
+  {0x19,0x01,D|O,"Defect list not available"},=0A=
+  {0x19,0x02,D|O,"Defect list error in primary list"},=0A=
+  {0x19,0x03,D|O,"Defect list error in grown list"},=0A=
+  {0x1A,0x00,D|T|L|P|W|R|S|O|M|C,"Parameter list length error"},=0A=
+  {0x1B,0x00,D|T|L|P|W|R|S|O|M|C,"Synchronous data transfer =
error"},=0A=
+  {0x1C,0x00,D|O,"Defect list not found"},=0A=
+  {0x1C,0x01,D|O,"Primary defect list not found"},=0A=
+  {0x1C,0x02,D|O,"Grown defect list not found"},=0A=
+  {0x1D,0x00,D|W|O,"Miscompare during verify operation"},=0A=
+  {0x1E,0x00,D|W|O,"Recovered id with ecc correction"},=0A=
+  {0x20,0x00,D|T|L|P|W|R|S|O|M|C,"Invalid command operation code"},=0A=
+  {0x21,0x00,D|T|W|R|O|M,"Logical block address out of range"},=0A=
+  {0x21,0x01,M,"Invalid element address"},=0A=
+  {0x22,0x00,D,"Illegal function (should use 20 00, 24 00, or 26 =
00)"},=0A=
+  {0x24,0x00,D|T|L|P|W|R|S|O|M|C,"Invalid field in cdb"},=0A=
+  {0x25,0x00,D|T|L|P|W|R|S|O|M|C,"Logical unit not supported"},=0A=
+  {0x26,0x00,D|T|L|P|W|R|S|O|M|C,"Invalid field in parameter =
list"},=0A=
+  {0x26,0x01,D|T|L|P|W|R|S|O|M|C,"Parameter not supported"},=0A=
+  {0x26,0x02,D|T|L|P|W|R|S|O|M|C,"Parameter value invalid"},=0A=
+  {0x26,0x03,D|T|L|P|W|R|S|O|M|C,"Threshold parameters not =
supported"},=0A=
+  {0x27,0x00,D|T|W|O,"Write protected"},=0A=
+  {0x28,0x00,D|T|L|P|W|R|S|O|M|C,"Not ready to ready transition =
(medium may have changed)"},=0A=
+  {0x28,0x01,M,"Import or export element accessed"},=0A=
+  {0x29,0x00,D|T|L|P|W|R|S|O|M|C,"Power on, reset, or bus device reset =
occurred"},=0A=
+  {0x2A,0x00,D|T|L|W|R|S|O|M|C,"Parameters changed"},=0A=
+  {0x2A,0x01,D|T|L|W|R|S|O|M|C,"Mode parameters changed"},=0A=
+  {0x2A,0x02,D|T|L|W|R|S|O|M|C,"Log parameters changed"},=0A=
+  {0x2B,0x00,D|T|L|P|W|R|S|O|C,"Copy cannot execute since host cannot =
disconnect"},=0A=
+  {0x2C,0x00,D|T|L|P|W|R|S|O|M|C,"Command sequence error"},=0A=
+  {0x2C,0x01,S,"Too many windows specified"},=0A=
+  {0x2C,0x02,S,"Invalid combination of windows specified"},=0A=
+  {0x2D,0x00,T,"Overwrite error on update in place"},=0A=
+  {0x2F,0x00,D|T|L|P|W|R|S|O|M|C,"Commands cleared by another =
initiator"},=0A=
+  {0x30,0x00,D|T|W|R|O|M,"Incompatible medium installed"},=0A=
+  {0x30,0x01,D|T|W|R|O,"Cannot read medium - unknown format"},=0A=
+  {0x30,0x02,D|T|W|R|O,"Cannot read medium - incompatible format"},=0A=
+  {0x30,0x03,D|T,"Cleaning cartridge installed"},=0A=
+  {0x31,0x00,D|T|W|O,"Medium format corrupted"},=0A=
+  {0x31,0x01,D|L|O,"Format command failed"},=0A=
+  {0x32,0x00,D|W|O,"No defect spare location available"},=0A=
+  {0x32,0x01,D|W|O,"Defect list update failure"},=0A=
+  {0x33,0x00,T,"Tape length error"},=0A=
+  {0x36,0x00,L,"Ribbon, ink, or toner failure"},=0A=
+  {0x37,0x00,D|T|L|W|R|S|O|M|C,"Rounded parameter"},=0A=
+  {0x39,0x00,D|T|L|W|R|S|O|M|C,"Saving parameters not supported"},=0A=
+  {0x3A,0x00,D|T|L|W|R|S|O|M,"Medium not present"},=0A=
+  {0x3B,0x00,T|L,"Sequential positioning error"},=0A=
+  {0x3B,0x01,T,"Tape position error at beginning-of-medium"},=0A=
+  {0x3B,0x02,T,"Tape position error at end-of-medium"},=0A=
+  {0x3B,0x03,L,"Tape or electronic vertical forms unit not ready"},=0A=
+  {0x3B,0x04,L,"Slew failure"},=0A=
+  {0x3B,0x05,L,"Paper jam"},=0A=
+  {0x3B,0x06,L,"Failed to sense top-of-form"},=0A=
+  {0x3B,0x07,L,"Failed to sense bottom-of-form"},=0A=
+  {0x3B,0x08,T,"Reposition error"},=0A=
+  {0x3B,0x09,S,"Read past end of medium"},=0A=
+  {0x3B,0x0A,S,"Read past beginning of medium"},=0A=
+  {0x3B,0x0B,S,"Position past end of medium"},=0A=
+  {0x3B,0x0C,S,"Position past beginning of medium"},=0A=
+  {0x3B,0x0D,M,"Medium destination element full"},=0A=
+  {0x3B,0x0E,M,"Medium source element empty"},=0A=
+  {0x3D,0x00,D|T|L|P|W|R|S|O|M|C,"Invalid bits in identify =
message"},=0A=
+  {0x3E,0x00,D|T|L|P|W|R|S|O|M|C,"Logical unit has not self-configured =
yet"},=0A=
+  {0x3F,0x00,D|T|L|P|W|R|S|O|M|C,"Target operating conditions have =
changed"},=0A=
+  {0x3F,0x01,D|T|L|P|W|R|S|O|M|C,"Microcode has been changed"},=0A=
+  {0x3F,0x02,D|T|L|P|W|R|S|O|M|C,"Changed operating definition"},=0A=
+  {0x3F,0x03,D|T|L|P|W|R|S|O|M|C,"Inquiry data has changed"},=0A=
+  {0x43,0x00,D|T|L|P|W|R|S|O|M|C,"Message error"},=0A=
+  {0x44,0x00,D|T|L|P|W|R|S|O|M|C,"Internal target failure"},=0A=
+  {0x45,0x00,D|T|L|P|W|R|S|O|M|C,"Select or reselect failure"},=0A=
+  {0x46,0x00,D|T|L|P|W|R|S|O|M|C,"Unsuccessful soft reset"},=0A=
+  {0x47,0x00,D|T|L|P|W|R|S|O|M|C,"Scsi parity error"},=0A=
+  {0x48,0x00,D|T|L|P|W|R|S|O|M|C,"Initiator detected error message =
received"},=0A=
+  {0x49,0x00,D|T|L|P|W|R|S|O|M|C,"Invalid message error"},=0A=
+  {0x4A,0x00,D|T|L|P|W|R|S|O|M|C,"Command phase error"},=0A=
+  {0x4B,0x00,D|T|L|P|W|R|S|O|M|C,"Data phase error"},=0A=
+  {0x4C,0x00,D|T|L|P|W|R|S|O|M|C,"Logical unit failed =
self-configuration"},=0A=
+  {0x4E,0x00,D|T|L|P|W|R|S|O|M|C,"Overlapped commands attempted"},=0A=
+  {0x50,0x00,T,"Write append error"},=0A=
+  {0x50,0x01,T,"Write append position error"},=0A=
+  {0x50,0x02,T,"Position error related to timing"},=0A=
+  {0x51,0x00,T|O,"Erase failure"},=0A=
+  {0x52,0x00,T,"Cartridge fault"},=0A=
+  {0x53,0x00,D|T|L|W|R|S|O|M,"Media load or eject failed"},=0A=
+  {0x53,0x01,T,"Unload tape failure"},=0A=
+  {0x53,0x02,D|T|W|R|O|M,"Medium removal prevented"},=0A=
+  {0x54,0x00,P,"Scsi to host system interface failure"},=0A=
+  {0x55,0x00,P,"System resource failure"},=0A=
+  {0x57,0x00,R,"Unable to recover table-of-contents"},=0A=
+  {0x58,0x00,O,"Generation does not exist"},=0A=
+  {0x59,0x00,O,"Updated block read"},=0A=
+  {0x5A,0x00,D|T|L|P|W|R|S|O|M,"Operator request or state change input =
(unspecified)"},=0A=
+  {0x5A,0x01,D|T|W|R|O|M,"Operator medium removal request"},=0A=
+  {0x5A,0x02,D|T|W|O,"Operator selected write protect"},=0A=
+  {0x5A,0x03,D|T|W|O,"Operator selected write permit"},=0A=
+  {0x5B,0x00,D|T|L|P|W|R|S|O|M,"Log exception"},=0A=
+  {0x5B,0x01,D|T|L|P|W|R|S|O|M,"Threshold condition met"},=0A=
+  {0x5B,0x02,D|T|L|P|W|R|S|O|M,"Log counter at maximum"},=0A=
+  {0x5B,0x03,D|T|L|P|W|R|S|O|M,"Log list codes exhausted"},=0A=
+  {0x5C,0x00,D|O,"Rpl status change"},=0A=
+  {0x5C,0x01,D|O,"Spindles synchronized"},=0A=
+  {0x5C,0x02,D|O,"Spindles not synchronized"},=0A=
+  {0x60,0x00,S,"Lamp failure"},=0A=
+  {0x61,0x00,S,"Video acquisition error"},=0A=
+  {0x61,0x01,S,"Unable to acquire video"},=0A=
+  {0x61,0x02,S,"Out of focus"},=0A=
+  {0x62,0x00,S,"Scan head positioning error"},=0A=
+  {0x63,0x00,R,"End of user area encountered on this track"},=0A=
+  {0x64,0x00,R,"Illegal mode for this track"},=0A=
+  {0, 0, 0, NULL}=0A=
+};=0A=
+=0A=
+static const char *snstext[] =3D {=0A=
+    "None",                     /* There is no sense information */=0A=
+    "Recovered Error",          /* The last command completed =
successfully=0A=
+                                   but used error correction */=0A=
+    "Not Ready",                /* The addressed target is not ready =
*/=0A=
+    "Medium Error",             /* Data error detected on the medium =
*/=0A=
+    "Hardware Error",           /* Controller or device failure */=0A=
+    "Illegal Request",=0A=
+    "Unit Attention",           /* Removable medium was changed, or=0A=
+                                   the target has been reset */=0A=
+    "Data Protect",             /* Access to the data is blocked */=0A=
+    "Blank Check",              /* Reached unexpected written or =
unwritten=0A=
+                                   region of the medium */=0A=
+    "Key=3D9",                    /* Vendor specific */=0A=
+    "Copy Aborted",             /* COPY or COMPARE was aborted */=0A=
+    "Aborted Command",          /* The target aborted the command =
*/=0A=
+    "Equal",                    /* A SEARCH DATA command found data =
equal */=0A=
+    "Volume Overflow",          /* Medium full with still data to be =
written */=0A=
+    "Miscompare",               /* Source data and data on the =
medium=0A=
+                                   do not agree */=0A=
+    "Key=3D15"                    /* Reserved */=0A=
+};=0A=
+=0A=
+/* Print sense information */=0A=
+void sg_print_sense(const char * leadin, const unsigned char * =
sense_buffer,=0A=
+                    int sb_len)=0A=
+{=0A=
+    int i, s;=0A=
+    int sense_class, valid, code;=0A=
+    const char * error =3D NULL;=0A=
+=0A=
+    sense_class =3D (sense_buffer[0] >> 4) & 0x07;=0A=
+    code =3D sense_buffer[0] & 0xf;=0A=
+    valid =3D sense_buffer[0] & 0x80;=0A=
+=0A=
+    if (sense_class =3D=3D 7) {     /* extended sense data */=0A=
+        s =3D sense_buffer[7] + 8;=0A=
+        if(s > sb_len)=0A=
+           s =3D sb_len;=0A=
+=0A=
+        if (!valid)=0A=
+            printf("[valid=3D0] ");=0A=
+        printf("Info fld=3D0x%x, ", (int)((sense_buffer[3] << 24) |=0A=
+               (sense_buffer[4] << 16) | (sense_buffer[5] << 8) |=0A=
+               sense_buffer[6]));=0A=
+=0A=
+        if (sense_buffer[2] & 0x80)=0A=
+           printf( "FMK ");     /* current command has read a filemark =
*/=0A=
+        if (sense_buffer[2] & 0x40)=0A=
+           printf( "EOM ");     /* end-of-medium condition exists =
*/=0A=
+        if (sense_buffer[2] & 0x20)=0A=
+           printf( "ILI ");     /* incorrect block length requested =
*/=0A=
+=0A=
+        switch (code) {=0A=
+        case 0x0:=0A=
+            error =3D "Current";  /* error concerns current command =
*/=0A=
+            break;=0A=
+        case 0x1:=0A=
+            error =3D "Deferred"; /* error concerns some earlier =
command */=0A=
+                /* e.g., an earlier write to disk cache succeeded, =
but=0A=
+                   now the disk discovers that it cannot write the =
data */=0A=
+            break;=0A=
+        default:=0A=
+            error =3D "Invalid";=0A=
+        }=0A=
+=0A=
+        printf("%s ", error);=0A=
+=0A=
+        if (leadin)=0A=
+            printf("%s: ", leadin);=0A=
+        printf("sense key: %s\n", snstext[sense_buffer[2] & 0x0f]);=0A=
+=0A=
+        /* Check to see if additional sense information is available =
*/=0A=
+        if(sense_buffer[7] + 7 < 13 ||=0A=
+           (sense_buffer[12] =3D=3D 0  && sense_buffer[13] =3D=3D  0)) =
goto done;=0A=
+=0A=
+        for(i=3D0; additional[i].text; i++)=0A=
+            if(additional[i].code1 =3D=3D sense_buffer[12] &&=0A=
+               additional[i].code2 =3D=3D sense_buffer[13])=0A=
+                printf("Additional sense indicates: %s\n",=0A=
+                       additional[i].text);=0A=
+=0A=
+        for(i=3D0; additional2[i].text; i++)=0A=
+            if(additional2[i].code1 =3D=3D sense_buffer[12] &&=0A=
+               additional2[i].code2_min >=3D sense_buffer[13]  &&=0A=
+               additional2[i].code2_max <=3D sense_buffer[13]) {=0A=
+                printf("Additional sense indicates: ");=0A=
+                printf(additional2[i].text, sense_buffer[13]);=0A=
+                printf("\n");=0A=
+            };=0A=
+    } else {    /* non-extended sense data */=0A=
+=0A=
+         /*=0A=
+          * Standard says:=0A=
+          *    sense_buffer[0] & 0200 : address valid=0A=
+          *    sense_buffer[0] & 0177 : vendor-specific error code=0A=
+          *    sense_buffer[1] & 0340 : vendor-specific=0A=
+          *    sense_buffer[1..3] : 21-bit logical block address=0A=
+          */=0A=
+=0A=
+        if (leadin)=0A=
+            printf("%s: ", leadin);=0A=
+        if (sense_buffer[0] < 15)=0A=
+            printf("old sense: key %s\n", snstext[sense_buffer[0] & =
0x0f]);=0A=
+        else=0A=
+            printf("sns =3D %2x %2x\n", sense_buffer[0], =
sense_buffer[2]);=0A=
+=0A=
+        printf("Non-extended sense class %d code 0x%0x ", sense_class, =
code);=0A=
+        s =3D 4;=0A=
+    }=0A=
+=0A=
+ done:=0A=
+    printf("Raw sense data (in hex):\n  ");=0A=
+    for (i =3D 0; i < s; ++i) {=0A=
+        if ((i > 0) && (0 =3D=3D (i % 24)))=0A=
+            printf("\n  ");=0A=
+        printf("%02x ", sense_buffer[i]);=0A=
+    }=0A=
+    printf("\n");=0A=
+    return;=0A=
+}=0A=
+=0A=
+static const char * hostbyte_table[]=3D{=0A=
+"DID_OK", "DID_NO_CONNECT", "DID_BUS_BUSY", "DID_TIME_OUT", =
"DID_BAD_TARGET",=0A=
+"DID_ABORT", "DID_PARITY", "DID_ERROR", "DID_RESET", =
"DID_BAD_INTR",=0A=
+"DID_PASSTHROUGH", "DID_SOFT_ERROR", NULL};=0A=
+=0A=
+void sg_print_host_status(int host_status)=0A=
+{   static int maxcode=3D0;=0A=
+    int i;=0A=
+=0A=
+    if(! maxcode) {=0A=
+        for(i =3D 0; hostbyte_table[i]; i++) ;=0A=
+        maxcode =3D i-1;=0A=
+    }=0A=
+    printf("Host_status=3D0x%02x", host_status);=0A=
+    if(host_status > maxcode) {=0A=
+        printf("is invalid ");=0A=
+        return;=0A=
+    }=0A=
+    printf("(%s) ",hostbyte_table[host_status]);=0A=
+}=0A=
+=0A=
+static const char * driverbyte_table[]=3D{=0A=
+"DRIVER_OK", "DRIVER_BUSY", "DRIVER_SOFT",  "DRIVER_MEDIA", =
"DRIVER_ERROR",=0A=
+"DRIVER_INVALID", "DRIVER_TIMEOUT", "DRIVER_HARD", "DRIVER_SENSE", =
NULL};=0A=
+=0A=
+static const char * driversuggest_table[]=3D{"SUGGEST_OK",=0A=
+"SUGGEST_RETRY", "SUGGEST_ABORT", "SUGGEST_REMAP", "SUGGEST_DIE",=0A=
+unknown,unknown,unknown, "SUGGEST_SENSE",NULL};=0A=
+=0A=
+=0A=
+void sg_print_driver_status(int driver_status)=0A=
+{=0A=
+    static int driver_max =3D0 , suggest_max=3D0;=0A=
+    int i;=0A=
+    int dr =3D driver_status & SG_ERR_DRIVER_MASK;=0A=
+    int su =3D (driver_status & SG_ERR_SUGGEST_MASK) >> 4;=0A=
+=0A=
+    if(! driver_max) {=0A=
+        for(i =3D 0; driverbyte_table[i]; i++) ;=0A=
+        driver_max =3D i;=0A=
+        for(i =3D 0; driversuggest_table[i]; i++) ;=0A=
+        suggest_max =3D i;=0A=
+    }=0A=
+    printf("Driver_status=3D0x%02x",driver_status);=0A=
+    printf(" (%s,%s) ",=0A=
+        dr < driver_max  ? driverbyte_table[dr]:"invalid",=0A=
+        su < suggest_max ? driversuggest_table[su]:"invalid");=0A=
+}=0A=
+=0A=
+#ifdef SG_IO=0A=
+int sg_chk_n_print3(const char * leadin, sg_io_hdr_t * hp)=0A=
+{=0A=
+    return sg_chk_n_print(leadin, hp->masked_status, =
hp->host_status,=0A=
+                          hp->driver_status, hp->sbp, =
hp->sb_len_wr);=0A=
+}=0A=
+#endif=0A=
+=0A=
+int sg_chk_n_print(const char * leadin, int masked_status,=0A=
+                   int host_status, int driver_status,=0A=
+                   const unsigned char * sense_buffer, int sb_len)=0A=
+{=0A=
+    int done_leadin =3D 0;=0A=
+    int done_sense =3D 0;=0A=
+=0A=
+    if ((0 =3D=3D masked_status) && (0 =3D=3D host_status) &&=0A=
+        (0 =3D=3D driver_status))=0A=
+        return 1;       /* No problems */=0A=
+    if (0 !=3D masked_status) {=0A=
+        if (leadin)=0A=
+            printf("%s: ", leadin);=0A=
+        done_leadin =3D 1;=0A=
+        sg_print_status(masked_status);=0A=
+        printf("\n");=0A=
+        if (sense_buffer && ((masked_status =3D=3D CHECK_CONDITION) =
||=0A=
+                             (masked_status =3D=3D =
COMMAND_TERMINATED))) {=0A=
+            sg_print_sense(0, sense_buffer, sb_len);=0A=
+            done_sense =3D 1;=0A=
+        }=0A=
+    }=0A=
+    if (0 !=3D host_status) {=0A=
+        if (leadin && (! done_leadin))=0A=
+            printf("%s: ", leadin);=0A=
+        if (done_leadin)=0A=
+            printf("plus...: ");=0A=
+        else=0A=
+            done_leadin =3D 1;=0A=
+        sg_print_host_status(host_status);=0A=
+        printf("\n");=0A=
+    }=0A=
+    if (0 !=3D driver_status) {=0A=
+        if (leadin && (! done_leadin))=0A=
+            printf("%s: ", leadin);=0A=
+        if (done_leadin)=0A=
+            printf("plus...: ");=0A=
+        else=0A=
+            done_leadin =3D 1;=0A=
+        sg_print_driver_status(driver_status);=0A=
+        printf("\n");=0A=
+        if (sense_buffer && (! done_sense) &&=0A=
+            (SG_ERR_DRIVER_SENSE & driver_status))=0A=
+            sg_print_sense(0, sense_buffer, sb_len);=0A=
+    }=0A=
+    return 0;=0A=
+}=0A=
+=0A=
+#ifdef SG_IO=0A=
+int sg_err_category3(sg_io_hdr_t * hp)=0A=
+{=0A=
+    return sg_err_category(hp->masked_status, hp->host_status,=0A=
+                           hp->driver_status, hp->sbp, =
hp->sb_len_wr);=0A=
+}=0A=
+#endif=0A=
+=0A=
+int sg_err_category(int masked_status, int host_status,=0A=
+                    int driver_status, const unsigned char * =
sense_buffer,=0A=
+                    int sb_len)=0A=
+{=0A=
+    if ((0 =3D=3D masked_status) && (0 =3D=3D host_status) &&=0A=
+        (0 =3D=3D driver_status))=0A=
+        return SG_ERR_CAT_CLEAN;=0A=
+    if ((CHECK_CONDITION =3D=3D masked_status) ||=0A=
+        (COMMAND_TERMINATED =3D=3D masked_status) ||=0A=
+        (SG_ERR_DRIVER_SENSE & driver_status)) {=0A=
+        if (sense_buffer && (sb_len > 2)) {=0A=
+            if(RECOVERED_ERROR =3D=3D sense_buffer[2])=0A=
+                return SG_ERR_CAT_RECOVERED;=0A=
+            else if ((UNIT_ATTENTION =3D=3D (0x0f & sense_buffer[2])) =
&&=0A=
+                     (sb_len > 12)) {=0A=
+                if (0x28 =3D=3D sense_buffer[12])=0A=
+                    return SG_ERR_CAT_MEDIA_CHANGED;=0A=
+                if (0x29 =3D=3D sense_buffer[12])=0A=
+                    return SG_ERR_CAT_RESET;=0A=
+            }=0A=
+        }=0A=
+        return SG_ERR_CAT_SENSE;=0A=
+    }=0A=
+    if (0 !=3D host_status) {=0A=
+        if ((SG_ERR_DID_NO_CONNECT =3D=3D host_status) ||=0A=
+            (SG_ERR_DID_BUS_BUSY =3D=3D host_status) ||=0A=
+            (SG_ERR_DID_TIME_OUT =3D=3D host_status))=0A=
+            return SG_ERR_CAT_TIMEOUT;=0A=
+    }=0A=
+    if (0 !=3D driver_status) {=0A=
+        if (SG_ERR_DRIVER_TIMEOUT =3D=3D driver_status)=0A=
+            return SG_ERR_CAT_TIMEOUT;=0A=
+    }=0A=
+    return SG_ERR_CAT_OTHER;=0A=
+}=0A=
+=0A=
+int sg_get_command_size(unsigned char opcode)=0A=
+{=0A=
+    return COMMAND_SIZE(opcode);=0A=
+}=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/sg_err.h =
parted-1.4.7-gpt/libparted/sg_err.h=0A=
--- parted-1.4.7/libparted/sg_err.h	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/sg_err.h	Thu Jan 18 11:24:42 2001=0A=
@@ -0,0 +1,156 @@=0A=
+ /*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+#ifndef SG_ERR_H=0A=
+#define SG_ERR_H=0A=
+#include <linux/../scsi/scsi.h>  /* cope with silly includes */=0A=
+#include <linux/../scsi/sg.h>=0A=
+=0A=
+/* Feel free to copy and modify this GPL-ed code into your =
applications. */=0A=
+=0A=
+/* Version 0.83 (991208) */=0A=
+=0A=
+=0A=
+/* Some of the following error/status codes are exchanged between =
the=0A=
+   various layers of the SCSI sub-system in Linux and should never=0A=
+   reach the user. They are placed here for completeness. What =
appears=0A=
+   here is copied from drivers/scsi/scsi.h which is not visible in=0A=
+   the user space. */=0A=
+=0A=
+/* The following are 'host_status' codes */=0A=
+#ifndef DID_OK=0A=
+#define DID_OK 0x00=0A=
+#endif=0A=
+#ifndef DID_NO_CONNECT=0A=
+#define DID_NO_CONNECT 0x01     /* Unable to connect before timeout =
*/=0A=
+#define DID_BUS_BUSY 0x02       /* Bus remain busy until timeout */=0A=
+#define DID_TIME_OUT 0x03       /* Timed out for some other reason =
*/=0A=
+#define DID_BAD_TARGET 0x04     /* Bad target (id?) */=0A=
+#define DID_ABORT 0x05          /* Told to abort for some other reason =
*/=0A=
+#define DID_PARITY 0x06         /* Parity error (on SCSI bus) */=0A=
+#define DID_ERROR 0x07          /* Internal error */=0A=
+#define DID_RESET 0x08          /* Reset by somebody */=0A=
+#define DID_BAD_INTR 0x09       /* Received an unexpected interrupt =
*/=0A=
+#define DID_PASSTHROUGH 0x0a    /* Force command past mid-level */=0A=
+#define DID_SOFT_ERROR 0x0b     /* The low-level driver wants a retry =
*/=0A=
+#endif=0A=
+=0A=
+/* These defines are to isolate applictaions from kernel define =
changes */=0A=
+#define SG_ERR_DID_OK           DID_OK=0A=
+#define SG_ERR_DID_NO_CONNECT   DID_NO_CONNECT=0A=
+#define SG_ERR_DID_BUS_BUSY     DID_BUS_BUSY=0A=
+#define SG_ERR_DID_TIME_OUT     DID_TIME_OUT=0A=
+#define SG_ERR_DID_BAD_TARGET   DID_BAD_TARGET=0A=
+#define SG_ERR_DID_ABORT        DID_ABORT=0A=
+#define SG_ERR_DID_PARITY       DID_PARITY=0A=
+#define SG_ERR_DID_ERROR        DID_ERROR=0A=
+#define SG_ERR_DID_RESET        DID_RESET=0A=
+#define SG_ERR_DID_BAD_INTR     DID_BAD_INTR=0A=
+#define SG_ERR_DID_PASSTHROUGH  DID_PASSTHROUGH=0A=
+#define SG_ERR_DID_SOFT_ERROR   DID_SOFT_ERROR=0A=
+=0A=
+/* The following are 'driver_status' codes */=0A=
+#ifndef DRIVER_OK=0A=
+#define DRIVER_OK 0x00=0A=
+#endif=0A=
+#ifndef DRIVER_BUSY=0A=
+#define DRIVER_BUSY 0x01=0A=
+#define DRIVER_SOFT 0x02=0A=
+#define DRIVER_MEDIA 0x03=0A=
+#define DRIVER_ERROR 0x04=0A=
+#define DRIVER_INVALID 0x05=0A=
+#define DRIVER_TIMEOUT 0x06=0A=
+#define DRIVER_HARD 0x07=0A=
+#define DRIVER_SENSE 0x08       /* Sense_buffer has been set */=0A=
+=0A=
+/* Following "suggests" are "or-ed" with one of previous 8 entries =
*/=0A=
+#define SUGGEST_RETRY 0x10=0A=
+#define SUGGEST_ABORT 0x20=0A=
+#define SUGGEST_REMAP 0x30=0A=
+#define SUGGEST_DIE 0x40=0A=
+#define SUGGEST_SENSE 0x80=0A=
+#define SUGGEST_IS_OK 0xff=0A=
+#endif=0A=
+#ifndef DRIVER_MASK=0A=
+#define DRIVER_MASK 0x0f=0A=
+#endif=0A=
+#ifndef SUGGEST_MASK=0A=
+#define SUGGEST_MASK 0xf0=0A=
+#endif=0A=
+=0A=
+/* These defines are to isolate applictaions from kernel define =
changes */=0A=
+#define SG_ERR_DRIVER_OK        DRIVER_OK=0A=
+#define SG_ERR_DRIVER_BUSY      DRIVER_BUSY=0A=
+#define SG_ERR_DRIVER_SOFT      DRIVER_SOFT=0A=
+#define SG_ERR_DRIVER_MEDIA     DRIVER_MEDIA=0A=
+#define SG_ERR_DRIVER_ERROR     DRIVER_ERROR=0A=
+#define SG_ERR_DRIVER_INVALID   DRIVER_INVALID=0A=
+#define SG_ERR_DRIVER_TIMEOUT   DRIVER_TIMEOUT=0A=
+#define SG_ERR_DRIVER_HARD      DRIVER_HARD=0A=
+#define SG_ERR_DRIVER_SENSE     DRIVER_SENSE=0A=
+#define SG_ERR_SUGGEST_RETRY    SUGGEST_RETRY=0A=
+#define SG_ERR_SUGGEST_ABORT    SUGGEST_ABORT=0A=
+#define SG_ERR_SUGGEST_REMAP    SUGGEST_REMAP=0A=
+#define SG_ERR_SUGGEST_DIE      SUGGEST_DIE=0A=
+#define SG_ERR_SUGGEST_SENSE    SUGGEST_SENSE=0A=
+#define SG_ERR_SUGGEST_IS_OK    SUGGEST_IS_OK=0A=
+#define SG_ERR_DRIVER_MASK      DRIVER_MASK=0A=
+#define SG_ERR_SUGGEST_MASK     SUGGEST_MASK=0A=
+=0A=
+=0A=
+=0A=
+/* The following "print" functions send ACSII to stdout */=0A=
+extern void sg_print_command(const unsigned char * command);=0A=
+extern void sg_print_sense(const char * leadin,=0A=
+                           const unsigned char * sense_buffer, int =
sb_len);=0A=
+extern void sg_print_status(int masked_status);=0A=
+extern void sg_print_host_status(int host_status);=0A=
+extern void sg_print_driver_status(int driver_status);=0A=
+=0A=
+/* sg_chk_n_print() returns 1 quietly if there are no =
errors/warnings=0A=
+   else it prints to standard output and returns 0. */=0A=
+extern int sg_chk_n_print(const char * leadin, int masked_status,=0A=
+                          int host_status, int driver_status,=0A=
+                          const unsigned char * sense_buffer, int =
sb_len);=0A=
+#ifdef SG_IO=0A=
+extern int sg_chk_n_print3(const char * leadin, sg_io_hdr_t * hp);=0A=
+#endif=0A=
+=0A=
+=0A=
+/* The following "category" function returns one of the following =
*/=0A=
+#define SG_ERR_CAT_CLEAN 0      /* No errors or other information =
*/=0A=
+#define SG_ERR_CAT_MEDIA_CHANGED 1 /* interpreted from sense buffer =
*/=0A=
+#define SG_ERR_CAT_RESET 2      /* interpreted from sense buffer */=0A=
+#define SG_ERR_CAT_TIMEOUT 3=0A=
+#define SG_ERR_CAT_RECOVERED 4  /* Successful command after recovered =
err */=0A=
+#define SG_ERR_CAT_SENSE 98     /* Something else is in the sense =
buffer */=0A=
+#define SG_ERR_CAT_OTHER 99     /* Some other error/warning has =
occurred */=0A=
+=0A=
+extern int sg_err_category(int masked_status, int host_status,=0A=
+               int driver_status, const unsigned char * =
sense_buffer,=0A=
+               int sb_len);=0A=
+#ifdef SG_IO=0A=
+extern int sg_err_category3(sg_io_hdr_t * hp);=0A=
+#endif=0A=
+=0A=
+=0A=
+/* Returns length of SCSI command given the opcode (first byte) */=0A=
+int sg_get_command_size(unsigned char opcode);=0A=
+=0A=
+#endif=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/sg_map.c =
parted-1.4.7-gpt/libparted/sg_map.c=0A=
--- parted-1.4.7/libparted/sg_map.c	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/sg_map.c	Thu Jan 18 11:24:42 2001=0A=
@@ -0,0 +1,422 @@=0A=
+/*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+#include <unistd.h>=0A=
+#include <fcntl.h>=0A=
+#include <stdio.h>=0A=
+#include <stdlib.h>=0A=
+#include <string.h>=0A=
+#include <errno.h>=0A=
+#include <sys/ioctl.h>=0A=
+#include <sys/types.h>=0A=
+#include <sys/stat.h>=0A=
+#include <linux/../scsi/sg.h>  /* cope with silly includes */=0A=
+#include <linux/../scsi/scsi.h>=0A=
+=0A=
+/* Test code for D. Gilbert's extensions to the Linux OS SCSI generic =
("sg")=0A=
+   device driver.=0A=
+*  Copyright (C) 2000 D. Gilbert=0A=
+*  This program is free software; you can redistribute it and/or =
modify=0A=
+*  it under the terms of the GNU General Public License as published =
by=0A=
+*  the Free Software Foundation; either version 2, or (at your =
option)=0A=
+*  any later version.=0A=
+=0A=
+   This shows the mapping from "sg" devices to other scsi devices=0A=
+   (i.e. sd, scd or st) if any.=0A=
+   Options: -n   numeric scan: scan /dev/sg0,1,2, .... [default]=0A=
+            -a   alphabetical scan: scan /dev/sga,b,c, ....=0A=
+            -x   also show bus,chan,id,lun and type=0A=
+            -sd  only scan for sd devices (disks)=0A=
+            -st  only scan for st devices (tapes)=0A=
+            -scd (or -sr)  only scan for scd devices (cdroms)=0A=
+=0A=
+   Note: This program requires sg version 2 or better.=0A=
+=0A=
+   Version 0.12 20000415=0A=
+*/=0A=
+=0A=
+#include "sg_map.h"=0A=
+=0A=
+struct _sg_to_sd sg_to_sd[MAX_SG_DEVS];=0A=
+=0A=
+#ifndef SG_GET_RESERVED_SIZE=0A=
+#error "Need version 2 sg driver (linux kernel >=3D 2.2.6)"=0A=
+#endif=0A=
+=0A=
+static const char * devfs_id =3D "/dev/.devfsd";=0A=
+=0A=
+#define NUMERIC_SCAN_DEF 1   /* change to 0 to make alpha scan default =
*/=0A=
+=0A=
+=0A=
+typedef struct my_map_info=0A=
+{=0A=
+    int active;=0A=
+    int lin_dev_type;=0A=
+    int oth_dev_num;=0A=
+    struct sg_scsi_id sg_dat;=0A=
+} my_map_info_t;=0A=
+=0A=
+=0A=
+#define MAX_SG_DEVS 128=0A=
+#define MAX_SD_DEVS 128=0A=
+#define MAX_SR_DEVS 128=0A=
+#define MAX_ST_DEVS 128=0A=
+#define MAX_ERRORS 4=0A=
+=0A=
+static my_map_info_t map_arr[MAX_SG_DEVS];=0A=
+=0A=
+#define LIN_DEV_TYPE_UNKNOWN 0=0A=
+#define LIN_DEV_TYPE_SD 1=0A=
+#define LIN_DEV_TYPE_SR 2=0A=
+#define LIN_DEV_TYPE_ST 3=0A=
+#define LIN_DEV_TYPE_SCD 4=0A=
+=0A=
+=0A=
+typedef struct my_scsi_idlun {=0A=
+/* why can't userland see this structure ??? */=0A=
+    int dev_id;=0A=
+    int host_unique_id;=0A=
+} My_scsi_idlun;=0A=
+=0A=
+=0A=
+#define EBUFF_LEN 256=0A=
+static char ebuff[EBUFF_LEN];=0A=
+=0A=
+static void scan_dev_type(const char * leadin, int max_dev, int =
do_numeric,=0A=
+                          int lin_dev_type, int last_sg_ind);=0A=
+=0A=
+static void usage()=0A=
+{=0A=
+    printf("Usage: 'sg_map [-a] [-n] [-x] [-sd] [-scd or -sr] =
[-st]'\n");=0A=
+    printf("    where: -a   do alphabetic scan (ie sga, sgb, =
sgc)\n");=0A=
+    printf("           -n   do numeric scan (ie sg0, sg1, sg2)\n");=0A=
+    printf("           -x   also show bus,chan,id,lun and type\n");=0A=
+    printf("           -sd  show mapping to disks\n");=0A=
+    printf("           -scd show mapping to cdroms (look for =
/dev/scd<n>\n");=0A=
+    printf("           -sr  show mapping to cdroms (look for =
/dev/sr<n>\n");=0A=
+    printf("           -st  show mapping to tapes\n");=0A=
+    printf("    If no '-s*' arguments given then show all =
mappings\n");=0A=
+}=0A=
+=0A=
+=0A=
+static void make_dev_name(char * fname, const char * leadin, int k, =
=0A=
+                          int do_numeric)=0A=
+{=0A=
+    char buff[64];=0A=
+    int  big,little;=0A=
+=0A=
+    strcpy(fname, leadin ? leadin : "/dev/sg");=0A=
+    if (do_numeric) {=0A=
+        sprintf(buff, "%d", k);=0A=
+        strcat(fname, buff);=0A=
+    }=0A=
+    else {=0A=
+        if (k < 26) {=0A=
+            buff[0] =3D 'a' + (char)k;=0A=
+            buff[1] =3D '\0';=0A=
+            strcat(fname, buff);=0A=
+        }=0A=
+        else if (k <=3D 255) { /* assumes sequence goes x,y,z,aa,ab,ac =
etc */=0A=
+            big    =3D k/26;=0A=
+            little =3D k - (26 * big);=0A=
+            big    =3D big - 1;=0A=
+=0A=
+            buff[0] =3D 'a' + (char)big;=0A=
+            buff[1] =3D 'a' + (char)little;=0A=
+            buff[2] =3D '\0';=0A=
+            strcat(fname, buff);=0A=
+        }=0A=
+        else=0A=
+            strcat(fname, "xxxx");=0A=
+    }=0A=
+}=0A=
+=0A=
+int sg_to_sd_map_made =3D 0;=0A=
+=0A=
+int=0A=
+make_sg_to_sd_map()=0A=
+{=0A=
+    int sg_fd, res, k;=0A=
+    int do_numeric =3D NUMERIC_SCAN_DEF;=0A=
+    int do_all_s =3D 0;=0A=
+    int do_sd =3D 1;=0A=
+    int do_st =3D 0;=0A=
+    int do_sr =3D 0;=0A=
+    int do_scd =3D 0;=0A=
+    int do_extra =3D 0;=0A=
+    char fname[64];=0A=
+    int num_errors =3D 0;=0A=
+    int num_silent =3D 0;=0A=
+    int eacces_err =3D 0;=0A=
+    int last_sg_ind =3D -1;=0A=
+    struct stat stat_buf;=0A=
+=0A=
+    memset(&sg_to_sd, 0, MAX_SG_DEVS * sizeof(struct _sg_to_sd));=0A=
+=0A=
+#if 0=0A=
+    for (k =3D 1; k < argc; ++k) {=0A=
+        if (0 =3D=3D strcmp("-n", argv[k]))=0A=
+            do_numeric =3D 1;=0A=
+        else if (0 =3D=3D strcmp("-a", argv[k]))=0A=
+            do_numeric =3D 0;=0A=
+        else if (0 =3D=3D strcmp("-x", argv[k]))=0A=
+            do_extra =3D 1;=0A=
+        else if (0 =3D=3D strcmp("-sd", argv[k])) {=0A=
+            do_sd =3D 1;=0A=
+            do_all_s =3D 0;=0A=
+        }=0A=
+        else if (0 =3D=3D strcmp("-st", argv[k])) {=0A=
+            do_st =3D 1;=0A=
+            do_all_s =3D 0;=0A=
+        }=0A=
+        else if (0 =3D=3D strcmp("-sr", argv[k])) {=0A=
+            do_sr =3D 1;=0A=
+            do_all_s =3D 0;=0A=
+        }=0A=
+        else if (0 =3D=3D strcmp("-scd", argv[k])) {=0A=
+            do_scd =3D 1;=0A=
+            do_all_s =3D 0;=0A=
+        }=0A=
+        else if ((0 =3D=3D strcmp("-?", argv[k])) ||=0A=
+                 (0 =3D=3D strncmp("-h", argv[k], 2))) {=0A=
+            printf(=0A=
+            "Show mapping from sg devices to other scsi device =
names\n\n");=0A=
+            usage();=0A=
+            return 1;=0A=
+        }=0A=
+        else if (*argv[k] =3D=3D '-') {=0A=
+            printf("Unknown switch: %s\n", argv[k]);=0A=
+            usage();=0A=
+            return 1;=0A=
+        }=0A=
+        else if (*argv[k] !=3D '-') {=0A=
+            printf("Unknown argument\n");=0A=
+            usage();=0A=
+            return 1;=0A=
+        }=0A=
+    }=0A=
+#endif=0A=
+=0A=
+    if (stat(devfs_id, &stat_buf) =3D=3D 0)=0A=
+        printf("# Note: the devfs pseudo file system is =
present\n");=0A=
+=0A=
+    for (k =3D 0, res =3D 0; (k < MAX_SG_DEVS)  && (num_errors < =
MAX_ERRORS);=0A=
+         ++k, res =3D (sg_fd >=3D 0) ? close(sg_fd) : 0) {=0A=
+        if (res < 0) {=0A=
+            sprintf(ebuff, "Error closing %s ", fname);=0A=
+            perror("sg_map: close error");=0A=
+            return 1;=0A=
+        }=0A=
+        make_dev_name(fname, "/dev/sg", k, do_numeric);=0A=
+=0A=
+        sg_fd =3D open(fname, O_RDONLY | O_NONBLOCK);=0A=
+        if (sg_fd < 0) {=0A=
+            if (EBUSY =3D=3D errno) {=0A=
+                map_arr[k].active =3D -2;=0A=
+                continue;=0A=
+            }=0A=
+            else if ((ENODEV =3D=3D errno) || (ENOENT =3D=3D errno) =
||=0A=
+                     (ENXIO =3D=3D errno)) {=0A=
+                ++num_errors;=0A=
+                ++num_silent;=0A=
+                map_arr[k].active =3D -1;=0A=
+                continue;=0A=
+            }=0A=
+            else {=0A=
+                if (EACCES =3D=3D errno)=0A=
+                    eacces_err =3D 1;=0A=
+                sprintf(ebuff, "Error opening %s ", fname);=0A=
+                perror(ebuff);=0A=
+                ++num_errors;=0A=
+                continue;=0A=
+            }=0A=
+        }=0A=
+        res =3D ioctl(sg_fd, SG_GET_SCSI_ID, &map_arr[k].sg_dat);=0A=
+        if (res < 0) {=0A=
+            sprintf(ebuff, "device %s failed on sg ioctl, skip", =
fname);=0A=
+            perror(ebuff);=0A=
+            ++num_errors;=0A=
+            continue;=0A=
+        }=0A=
+        map_arr[k].active =3D 1;=0A=
+        map_arr[k].oth_dev_num =3D -1;=0A=
+        last_sg_ind =3D k;=0A=
+    }=0A=
+    if ((num_errors >=3D MAX_ERRORS) && (num_silent < num_errors)) =
{=0A=
+        printf("Stopping because there are too many error\n");=0A=
+        if (eacces_err)=0A=
+            printf("    root access may be required\n");=0A=
+        return 1;=0A=
+    }=0A=
+    if (last_sg_ind < 0) {=0A=
+        printf("Stopping because no sg devices found\n");=0A=
+    }=0A=
+=0A=
+    if (do_all_s || do_sd)=0A=
+        scan_dev_type("/dev/sd", MAX_SD_DEVS, 0, LIN_DEV_TYPE_SD, =
last_sg_ind);=0A=
+#if 0=0A=
+    if (do_all_s || do_sr)=0A=
+        scan_dev_type("/dev/sr", MAX_SR_DEVS, 1, LIN_DEV_TYPE_SR, =
last_sg_ind);=0A=
+    if (do_all_s || do_scd)=0A=
+        scan_dev_type("/dev/scd", MAX_SR_DEVS, 1, LIN_DEV_TYPE_SCD, =
=0A=
+                      last_sg_ind);=0A=
+    if (do_all_s || do_st)=0A=
+        scan_dev_type("/dev/st", MAX_ST_DEVS, 1, LIN_DEV_TYPE_ST, =
last_sg_ind);=0A=
+#endif=0A=
+=0A=
+    for (k =3D 0; k <=3D last_sg_ind; ++k) {=0A=
+        make_dev_name(fname, "/dev/sg", k, do_numeric);=0A=
+        // printf("%s", fname);=0A=
+	snprintf(sg_to_sd[k].sg, 15, "%s", fname);=0A=
+        switch (map_arr[k].active)=0A=
+        {=0A=
+        case -2:=0A=
+            printf(do_extra ? "  -2 -2 -2 -2  -2" : "  busy");=0A=
+            break;=0A=
+        case -1:=0A=
+            printf(do_extra ? "  -1 -1 -1 -1  -1" : "  not =
present");=0A=
+            break;=0A=
+        case 0:=0A=
+            printf(do_extra ? "  -3 -3 -3 -3  -3" : "  some =
error\n");=0A=
+            break;=0A=
+        case 1:=0A=
+            if (do_extra) =0A=
+                printf("  %d %d %d %d  %d", =
map_arr[k].sg_dat.host_no,=0A=
+                       map_arr[k].sg_dat.channel, =
map_arr[k].sg_dat.scsi_id,=0A=
+                       map_arr[k].sg_dat.lun, =
map_arr[k].sg_dat.scsi_type);=0A=
+            switch (map_arr[k].lin_dev_type)=0A=
+            {=0A=
+            case LIN_DEV_TYPE_SD:=0A=
+                make_dev_name(fname, "/dev/sd" , =
map_arr[k].oth_dev_num, 0);=0A=
+                // printf("  %s", fname);=0A=
+		snprintf(sg_to_sd[k].sd, 15, "%s", fname);=0A=
+                break;=0A=
+#if 0=0A=
+            case LIN_DEV_TYPE_ST:=0A=
+                make_dev_name(fname, "/dev/st" , =
map_arr[k].oth_dev_num, 1);=0A=
+                printf("  %s", fname);=0A=
+                break;=0A=
+            case LIN_DEV_TYPE_SR:=0A=
+                make_dev_name(fname, "/dev/sr" , =
map_arr[k].oth_dev_num, 1);=0A=
+                printf("  %s", fname);=0A=
+                break;=0A=
+            case LIN_DEV_TYPE_SCD:=0A=
+                make_dev_name(fname, "/dev/scd" , =
map_arr[k].oth_dev_num, 1);=0A=
+                printf("  %s", fname);=0A=
+                break;=0A=
+#endif=0A=
+            default:=0A=
+                break;=0A=
+            }=0A=
+            break;=0A=
+        default:=0A=
+            printf("  bad logic\n");=0A=
+            break;=0A=
+        }=0A=
+        // printf("\n");=0A=
+    }=0A=
+=0A=
+    sg_to_sd_map_made =3D 1;=0A=
+    return 0;=0A=
+}=0A=
+        =0A=
+static int find_dev_in_sg_arr(My_scsi_idlun * my_idlun, int host_no, =
=0A=
+                              int last_sg_ind)=0A=
+{=0A=
+    int k;=0A=
+    struct sg_scsi_id * sidp;=0A=
+=0A=
+    for (k =3D 0; k <=3D last_sg_ind; ++k) {=0A=
+        sidp =3D &(map_arr[k].sg_dat);=0A=
+        if ((host_no =3D=3D sidp->host_no) &&=0A=
+            ((my_idlun->dev_id & 0xff) =3D=3D sidp->scsi_id) &&=0A=
+            (((my_idlun->dev_id >> 8) & 0xff) =3D=3D sidp->lun) &&=0A=
+            (((my_idlun->dev_id >> 16) & 0xff) =3D=3D =
sidp->channel))=0A=
+            return k;=0A=
+    }=0A=
+    return -1;=0A=
+}=0A=
+=0A=
+static void scan_dev_type(const char * leadin, int max_dev, int =
do_numeric,=0A=
+                          int lin_dev_type, int last_sg_ind)=0A=
+{=0A=
+    int k, res, ind, sg_fd;=0A=
+    int num_errors =3D 0;=0A=
+    int num_silent =3D 0;=0A=
+    int host_no =3D -1;=0A=
+    My_scsi_idlun my_idlun;=0A=
+    char fname[64];=0A=
+=0A=
+    for (k =3D 0, res =3D 0; (k < max_dev)  && (num_errors < =
MAX_ERRORS);=0A=
+         ++k, res =3D (sg_fd >=3D 0) ? close(sg_fd) : 0) {=0A=
+        if (res < 0) {=0A=
+            sprintf(ebuff, "Error closing %s ", fname);=0A=
+            perror("sg_map: close error");=0A=
+            return;=0A=
+        }=0A=
+        make_dev_name(fname, leadin, k, do_numeric);=0A=
+=0A=
+        sg_fd =3D open(fname, O_RDONLY | O_NONBLOCK);=0A=
+        if (sg_fd < 0) {=0A=
+            if (EBUSY =3D=3D errno) {=0A=
+                printf("Device %s is busy\n", fname);=0A=
+                ++num_errors;=0A=
+                continue;=0A=
+            }=0A=
+            else if ((ENODEV =3D=3D errno) || (ENOENT =3D=3D errno) =
||=0A=
+                     (ENXIO =3D=3D errno)) {=0A=
+                ++num_errors;=0A=
+                ++num_silent;=0A=
+                continue;=0A=
+            }=0A=
+            else {=0A=
+                sprintf(ebuff, "Error opening %s ", fname);=0A=
+                perror(ebuff);=0A=
+                ++num_errors;=0A=
+                continue;=0A=
+            }=0A=
+        }=0A=
+=0A=
+        res =3D ioctl(sg_fd, SCSI_IOCTL_GET_IDLUN, &my_idlun);=0A=
+        if (res < 0) {=0A=
+            sprintf(ebuff, "device %s failed on scsi ioctl(idlun), =
skip", =0A=
+                    fname);=0A=
+            perror(ebuff);=0A=
+            ++num_errors;=0A=
+            continue;=0A=
+        }=0A=
+        res =3D ioctl(sg_fd, SCSI_IOCTL_GET_BUS_NUMBER, &host_no);=0A=
+        if (res < 0) {=0A=
+            sprintf(ebuff, "device %s failed on scsi =
ioctl(bus_number), skip",=0A=
+                    fname);=0A=
+            perror(ebuff);=0A=
+            ++num_errors;=0A=
+            continue;=0A=
+        }=0A=
+        ind =3D find_dev_in_sg_arr(&my_idlun, host_no, =
last_sg_ind);=0A=
+        if (ind >=3D 0) {=0A=
+            map_arr[ind].oth_dev_num =3D k;=0A=
+            map_arr[ind].lin_dev_type =3D lin_dev_type;=0A=
+        }=0A=
+        else=0A=
+            printf("Strange, could not find device %s mapped to sg =
device??\n", =0A=
+                   fname);=0A=
+    }=0A=
+}=0A=
+=0A=
diff -BburN --exclude *.orig --exclude *.spec --exclude=3D*Makefile.in =
--exclude=3D*.po* parted-1.4.7/libparted/sg_map.h =
parted-1.4.7-gpt/libparted/sg_map.h=0A=
--- parted-1.4.7/libparted/sg_map.h	Wed Dec 31 18:00:00 1969=0A=
+++ parted-1.4.7-gpt/libparted/sg_map.h	Thu Jan 18 11:24:42 2001=0A=
@@ -0,0 +1,33 @@=0A=
+ /*=0A=
+    libparted - a library for manipulating disk partitions=0A=
+    Copyright (C) 1998-2000 Free Software Foundation, Inc.=0A=
+=0A=
+    This program is free software; you can redistribute it and/or =
modify=0A=
+    it under the terms of the GNU General Public License as published =
by=0A=
+    the Free Software Foundation; either version 2 of the License, =
or=0A=
+    (at your option) any later version.=0A=
+=0A=
+    This program is distributed in the hope that it will be useful,=0A=
+    but WITHOUT ANY WARRANTY; without even the implied warranty of=0A=
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the=0A=
+    GNU General Public License for more details.=0A=
+=0A=
+    You should have received a copy of the GNU General Public =
License=0A=
+    along with this program; if not, write to the Free Software=0A=
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  =
02111-1307  USA=0A=
+*/=0A=
+=0A=
+#define MAX_SG_DEVS 128=0A=
+=0A=
+=0A=
+struct _sg_to_sd {=0A=
+	char sg[16];=0A=
+	char sd[16];=0A=
+};=0A=
+=0A=
+=0A=
+extern struct _sg_to_sd sg_to_sd[MAX_SG_DEVS];=0A=
+extern int sg_to_sd_map_made;=0A=
+=0A=
+int make_sg_to_sd_map();=0A=
+=0A=

------_=_NextPart_000_01C0A667.6A928184--

