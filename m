From: Matt_Domsch@Dell.com
Date: Thu, 15 Aug 2002 16:55:10 +0000
Subject: RE: [Linux-ia64] move asm-ia64/efi.h to linux/efi.h ?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C2447C.8456CDF0"
Message-Id: <marc-linux-ia64-105590701905941@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905936@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905936@msgid-missing>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C2447C.8456CDF0
Content-Type: text/plain; 
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit

> I'll post a similar patch against 2.4.x 
> current BK tree soon as I have a moment to make it.

David and Bjorn, three patches against Marcelo's current 2.4.x BK tree:

1)
http://domsch.com/linux/patches/gpt/linux-2.4-gpt-efiguidt.cset
has been in the IA64 port for a while.  This fixes the endianness issues
with the efi_guid_t type and adds the NULL_GUID definition needed to compile
the GPT code.

2)
http://domsch.com/linux/patches/ia64/linux-2.4-efihmove.cset
moves include/asm-ia64/efi.h to include/linux/efi.h similar to the 2.5
patches.  This is needed to allow the GPT code to compile on non-IA64
platforms too, necessary for the use of really big disks.

3)
http://domsch.com/linux/patches/gpt/linux-2.4-gpt-efiguidt-unparse.cset
has been the IA64 port for a while.  This fixes efi_guid_unparse for
endianness.


These need to be applied in the above order, as #1 touches efi.h,  #2
touches and moves efi.h, and #3 touches it then too.  You've got #1 and #3
already in your tree, but Marcelo and Alan don't have any of these three.
I've compiled this on x86 against BK-current building in GPT with no
troubles.


Because ia64 isn't sync'd with Marcelo ATM, on ia64 against
2.4.18-ia64-020722 then applying #2, one fixup to arch/ia64/kernel/acpi.c
needed, and by moving asm-ia64/efi.h to linux/efi.h, it works great.
Because acpi.c and efi.h changed in your patch since you've sync'd with
Marcelo, patch 2 above has these problems - easily fixed.  Patch attached
applies against 2.4.18-ia64-020722 accomplishes same as #2 patch above.

Please apply the attached patch to your local tree, and forward the three BK
patches above to Alan and Marcelo for inclusion in 2.4.x mainline.  Any
other syncs I leave up to you. :-)

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001 and Q1/2002! (IDC May 2002)


------_=_NextPart_000_01C2447C.8456CDF0
Content-Type: application/octet-stream; 
 name=linux-2.4.18-ia64-efihmove.patch
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; 
 filename=linux-2.4.18-ia64-efihmove.patch

diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/efi.c =
linux-2.4.18-efihmove/arch/ia64/kernel/efi.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/efi.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/efi.c	Wed Aug 14 17:10:15 =
2002=0A=
@@ -24,8 +24,8 @@=0A=
 #include <linux/types.h>=0A=
 #include <linux/time.h>=0A=
 #include <linux/proc_fs.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
-#include <asm/efi.h>=0A=
 #include <asm/io.h>=0A=
 #include <asm/kregs.h>=0A=
 #include <asm/pgtable.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/efivars.c =
linux-2.4.18-efihmove/arch/ia64/kernel/efivars.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/efivars.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/efivars.c	Wed Aug 14 =
17:10:15 2002=0A=
@@ -65,8 +65,8 @@=0A=
 #include <linux/mm.h>=0A=
 #include <linux/module.h>=0A=
 #include <linux/smp.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
-#include <asm/efi.h>=0A=
 #include <asm/uaccess.h>=0A=
 =0A=
 MODULE_AUTHOR("Matt Domsch <Matt_Domsch@Dell.com>");=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/fw-emu.c =
linux-2.4.18-efihmove/arch/ia64/kernel/fw-emu.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/fw-emu.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/fw-emu.c	Wed Aug 14 17:10:15 =
2002=0A=
@@ -13,7 +13,7 @@=0A=
 # include <linux/pci.h>=0A=
 #endif=0A=
 =0A=
-#include <asm/efi.h>=0A=
+#include <linux/efi.h>=0A=
 #include <asm/io.h>=0A=
 #include <asm/pal.h>=0A=
 #include <asm/sal.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/palinfo.c =
linux-2.4.18-efihmove/arch/ia64/kernel/palinfo.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/palinfo.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/palinfo.c	Wed Aug 14 =
17:10:15 2002=0A=
@@ -21,10 +21,10 @@=0A=
 #include <linux/proc_fs.h>=0A=
 #include <linux/mm.h>=0A=
 #include <linux/module.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #include <asm/pal.h>=0A=
 #include <asm/sal.h>=0A=
-#include <asm/efi.h>=0A=
 #include <asm/page.h>=0A=
 #include <asm/processor.h>=0A=
 #ifdef CONFIG_SMP=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/process.c =
linux-2.4.18-efihmove/arch/ia64/kernel/process.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/process.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/process.c	Wed Aug 14 =
17:10:15 2002=0A=
@@ -18,9 +18,9 @@=0A=
 #include <linux/smp_lock.h>=0A=
 #include <linux/stddef.h>=0A=
 #include <linux/unistd.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #include <asm/delay.h>=0A=
-#include <asm/efi.h>=0A=
 #include <asm/perfmon.h>=0A=
 #include <asm/pgtable.h>=0A=
 #include <asm/processor.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/setup.c =
linux-2.4.18-efihmove/arch/ia64/kernel/setup.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/setup.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/setup.c	Wed Aug 14 17:10:15 =
2002=0A=
@@ -29,6 +29,7 @@=0A=
 #include <linux/string.h>=0A=
 #include <linux/threads.h>=0A=
 #include <linux/console.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #include <asm/ia32.h>=0A=
 #include <asm/page.h>=0A=
@@ -36,7 +37,6 @@=0A=
 #include <asm/processor.h>=0A=
 #include <asm/sal.h>=0A=
 #include <asm/system.h>=0A=
-#include <asm/efi.h>=0A=
 #include <asm/mca.h>=0A=
 #include <asm/smp.h>=0A=
 =0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/smp.c =
linux-2.4.18-efihmove/arch/ia64/kernel/smp.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/smp.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/smp.c	Wed Aug 14 17:10:15 =
2002=0A=
@@ -31,12 +31,12 @@=0A=
 #include <linux/mm.h>=0A=
 #include <linux/delay.h>=0A=
 #include <linux/cache.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #include <asm/atomic.h>=0A=
 #include <asm/bitops.h>=0A=
 #include <asm/current.h>=0A=
 #include <asm/delay.h>=0A=
-#include <asm/efi.h>=0A=
 #include <asm/machvec.h>=0A=
 =0A=
 #include <asm/io.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/smpboot.c =
linux-2.4.18-efihmove/arch/ia64/kernel/smpboot.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/smpboot.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/smpboot.c	Wed Aug 14 =
17:10:15 2002=0A=
@@ -23,13 +23,13 @@=0A=
 #include <linux/smp.h>=0A=
 #include <linux/smp_lock.h>=0A=
 #include <linux/spinlock.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #include <asm/atomic.h>=0A=
 #include <asm/bitops.h>=0A=
 #include <asm/cache.h>=0A=
 #include <asm/current.h>=0A=
 #include <asm/delay.h>=0A=
-#include <asm/efi.h>=0A=
 #include <asm/io.h>=0A=
 #include <asm/irq.h>=0A=
 #include <asm/machvec.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/kernel/time.c =
linux-2.4.18-efihmove/arch/ia64/kernel/time.c=0A=
--- linux-2.4.18-ia64/arch/ia64/kernel/time.c	Wed Aug 14 17:51:28 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/kernel/time.c	Wed Aug 14 17:10:15 =
2002=0A=
@@ -15,9 +15,9 @@=0A=
 #include <linux/sched.h>=0A=
 #include <linux/time.h>=0A=
 #include <linux/interrupt.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #include <asm/delay.h>=0A=
-#include <asm/efi.h>=0A=
 #include <asm/hw_irq.h>=0A=
 #include <asm/ptrace.h>=0A=
 #include <asm/sal.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/mm/init.c =
linux-2.4.18-efihmove/arch/ia64/mm/init.c=0A=
--- linux-2.4.18-ia64/arch/ia64/mm/init.c	Wed Aug 14 18:41:15 2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/mm/init.c	Wed Aug 14 17:10:15 =
2002=0A=
@@ -14,10 +14,10 @@=0A=
 #include <linux/reboot.h>=0A=
 #include <linux/slab.h>=0A=
 #include <linux/swap.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #include <asm/bitops.h>=0A=
 #include <asm/dma.h>=0A=
-#include <asm/efi.h>=0A=
 #include <asm/ia32.h>=0A=
 #include <asm/io.h>=0A=
 #include <asm/machvec.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/sn/fakeprom/fpmem.c =
linux-2.4.18-efihmove/arch/ia64/sn/fakeprom/fpmem.c=0A=
--- linux-2.4.18-ia64/arch/ia64/sn/fakeprom/fpmem.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/sn/fakeprom/fpmem.c	Wed Aug 14 =
17:10:15 2002=0A=
@@ -18,7 +18,7 @@=0A=
  */=0A=
 =0A=
 #include <linux/config.h>=0A=
-#include <asm/efi.h>=0A=
+#include <linux/efi.h>=0A=
 #include "fpmem.h"=0A=
 =0A=
 /*=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/sn/fakeprom/fw-emu.c =
linux-2.4.18-efihmove/arch/ia64/sn/fakeprom/fw-emu.c=0A=
--- linux-2.4.18-ia64/arch/ia64/sn/fakeprom/fw-emu.c	Wed Aug 14 =
18:41:15 2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/sn/fakeprom/fw-emu.c	Wed Aug 14 =
17:10:15 2002=0A=
@@ -36,7 +36,7 @@=0A=
  * http://oss.sgi.com/projects/GenInfo/NoticeExplan=0A=
  */=0A=
 #include <linux/config.h>=0A=
-#include <asm/efi.h>=0A=
+#include <linux/efi.h>=0A=
 #include <asm/pal.h>=0A=
 #include <asm/sal.h>=0A=
 #include <asm/sn/sn_sal.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/sn/io/efi-rtc.c =
linux-2.4.18-efihmove/arch/ia64/sn/io/efi-rtc.c=0A=
--- linux-2.4.18-ia64/arch/ia64/sn/io/efi-rtc.c	Wed Aug 14 18:41:15 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/sn/io/efi-rtc.c	Wed Aug 14 17:10:15 =
2002=0A=
@@ -12,7 +12,7 @@=0A=
 #include <linux/init.h>=0A=
 #include <linux/pci.h>=0A=
 #include <linux/errno.h>=0A=
-#include <asm/efi.h>=0A=
+#include <linux/efi.h>=0A=
 #include <asm/sn/klclock.h>=0A=
 =0A=
 /*=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/arch/ia64/sn/kernel/llsc4.c =
linux-2.4.18-efihmove/arch/ia64/sn/kernel/llsc4.c=0A=
--- linux-2.4.18-ia64/arch/ia64/sn/kernel/llsc4.c	Wed Aug 14 18:41:16 =
2002=0A=
+++ linux-2.4.18-efihmove/arch/ia64/sn/kernel/llsc4.c	Wed Aug 14 =
17:10:15 2002=0A=
@@ -17,7 +17,7 @@=0A=
 #include <linux/mm.h>=0A=
 #include <linux/delay.h>=0A=
 #include <linux/string.h>=0A=
-#include <asm/efi.h>=0A=
+#include <linux/efi.h>=0A=
 #include <asm/page.h>=0A=
 #include <linux/threads.h>=0A=
 #include <asm/sn/simulator.h>=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/drivers/acpi/osl.c =
linux-2.4.18-efihmove/drivers/acpi/osl.c=0A=
--- linux-2.4.18-ia64/drivers/acpi/osl.c	Wed Aug 14 18:41:17 2002=0A=
+++ linux-2.4.18-efihmove/drivers/acpi/osl.c	Wed Aug 14 17:11:22 =
2002=0A=
@@ -37,7 +37,7 @@=0A=
 #include "acpi.h"=0A=
 =0A=
 #ifdef CONFIG_ACPI_EFI=0A=
-#include <asm/efi.h>=0A=
+#include <linux/efi.h>=0A=
 u64 efi_mem_attributes (u64 phys_addr);=0A=
 #endif=0A=
 =0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/drivers/char/efirtc.c =
linux-2.4.18-efihmove/drivers/char/efirtc.c=0A=
--- linux-2.4.18-ia64/drivers/char/efirtc.c	Wed Aug 14 18:41:17 2002=0A=
+++ linux-2.4.18-efihmove/drivers/char/efirtc.c	Wed Aug 14 17:10:39 =
2002=0A=
@@ -35,8 +35,8 @@=0A=
 #include <linux/init.h>=0A=
 #include <linux/rtc.h>=0A=
 #include <linux/proc_fs.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
-#include <asm/efi.h>=0A=
 #include <asm/uaccess.h>=0A=
 #include <asm/system.h>=0A=
 =0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/drivers/char/hcdp_serial.c =
linux-2.4.18-efihmove/drivers/char/hcdp_serial.c=0A=
--- linux-2.4.18-ia64/drivers/char/hcdp_serial.c	Wed Aug 14 18:41:17 =
2002=0A=
+++ linux-2.4.18-efihmove/drivers/char/hcdp_serial.c	Wed Aug 14 =
17:10:39 2002=0A=
@@ -15,9 +15,9 @@=0A=
 #include <linux/init.h>=0A=
 #include <linux/serial.h>=0A=
 #include <linux/serialP.h>=0A=
+#include <linux/efi.h>=0A=
 #include <asm/serial.h>=0A=
 #include <asm/io.h>=0A=
-#include <asm/efi.h>=0A=
 #include <linux/hcdp_serial.h>=0A=
 =0A=
 #undef SERIAL_DEBUG_HCDP=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/fs/partitions/efi.h =
linux-2.4.18-efihmove/fs/partitions/efi.h=0A=
--- linux-2.4.18-ia64/fs/partitions/efi.h	Wed Aug 14 18:41:19 2002=0A=
+++ linux-2.4.18-efihmove/fs/partitions/efi.h	Thu Aug 15 11:38:46 =
2002=0A=
@@ -33,11 +33,7 @@=0A=
 #include <linux/major.h>=0A=
 #include <linux/string.h>=0A=
 #include <linux/blk.h>=0A=
-/*=0A=
- * Yes, specifying asm-ia64 is ugly, but this lets it build on=0A=
- * other platforms too, until efi.h moves to include/linux.=0A=
- */=0A=
-#include <asm-ia64/efi.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #define MSDOS_MBR_SIGNATURE 0xaa55=0A=
 #define EFI_PMBR_OSTYPE_EFI 0xEF=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/include/asm-ia64/efi.h =
linux-2.4.18-efihmove/include/asm-ia64/efi.h=0A=
--- linux-2.4.18-ia64/include/asm-ia64/efi.h	Wed Aug 14 18:41:19 =
2002=0A=
+++ linux-2.4.18-efihmove/include/asm-ia64/efi.h	Wed Dec 31 18:00:00 =
1969=0A=
@@ -1,284 +0,0 @@=0A=
-#ifndef _ASM_IA64_EFI_H=0A=
-#define _ASM_IA64_EFI_H=0A=
-=0A=
-/*=0A=
- * Extensible Firmware Interface=0A=
- * Based on 'Extensible Firmware Interface Specification' version 0.9, =
April 30, 1999=0A=
- *=0A=
- * Copyright (C) 1999 VA Linux Systems=0A=
- * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>=0A=
- * Copyright (C) 1999, 2002 Hewlett-Packard Co.=0A=
- *	David Mosberger-Tang <davidm@hpl.hp.com>=0A=
- *	Stephane Eranian <eranian@hpl.hp.com>=0A=
- */=0A=
-#include <linux/init.h>=0A=
-#include <linux/string.h>=0A=
-#include <linux/time.h>=0A=
-#include <linux/types.h>=0A=
-#include <linux/proc_fs.h>=0A=
-=0A=
-#include <asm/page.h>=0A=
-#include <asm/system.h>=0A=
-=0A=
-#define EFI_SUCCESS		0=0A=
-#define EFI_LOAD_ERROR          (1L | (1L << 63))=0A=
-#define EFI_INVALID_PARAMETER	(2L | (1L << 63))=0A=
-#define EFI_UNSUPPORTED		(3L | (1L << 63))=0A=
-#define EFI_BAD_BUFFER_SIZE     (4L | (1L << 63))=0A=
-#define EFI_BUFFER_TOO_SMALL	(5L | (1L << 63))=0A=
-#define EFI_NOT_FOUND          (14L | (1L << 63))=0A=
-=0A=
-typedef unsigned long efi_status_t;=0A=
-typedef u8 efi_bool_t;=0A=
-typedef u16 efi_char16_t;		/* UNICODE character */=0A=
-=0A=
-=0A=
-typedef struct {=0A=
-	u8 b[16];=0A=
-} efi_guid_t;=0A=
-=0A=
-#define EFI_GUID(a,b,c,d0,d1,d2,d3,d4,d5,d6,d7) \=0A=
-((efi_guid_t) \=0A=
-{{ (a) & 0xff, ((a) >> 8) & 0xff, ((a) >> 16) & 0xff, ((a) >> 24) & =
0xff, \=0A=
-  (b) & 0xff, ((b) >> 8) & 0xff, \=0A=
-  (c) & 0xff, ((c) >> 8) & 0xff, \=0A=
-  (d0), (d1), (d2), (d3), (d4), (d5), (d6), (d7) }})=0A=
-=0A=
-/*=0A=
- * Generic EFI table header=0A=
- */=0A=
-typedef	struct {=0A=
-	u64 signature;=0A=
-	u32 revision;=0A=
-	u32 headersize;=0A=
-	u32 crc32;=0A=
-	u32 reserved;=0A=
-} efi_table_hdr_t;=0A=
-=0A=
-/*=0A=
- * Memory map descriptor:=0A=
- */=0A=
-=0A=
-/* Memory types: */=0A=
-#define EFI_RESERVED_TYPE		 0=0A=
-#define EFI_LOADER_CODE			 1=0A=
-#define EFI_LOADER_DATA			 2=0A=
-#define EFI_BOOT_SERVICES_CODE		 3=0A=
-#define EFI_BOOT_SERVICES_DATA		 4=0A=
-#define EFI_RUNTIME_SERVICES_CODE	 5=0A=
-#define EFI_RUNTIME_SERVICES_DATA	 6=0A=
-#define EFI_CONVENTIONAL_MEMORY		 7=0A=
-#define EFI_UNUSABLE_MEMORY		 8=0A=
-#define EFI_ACPI_RECLAIM_MEMORY		 9=0A=
-#define EFI_ACPI_MEMORY_NVS		10=0A=
-#define EFI_MEMORY_MAPPED_IO		11=0A=
-#define EFI_MEMORY_MAPPED_IO_PORT_SPACE	12=0A=
-#define EFI_PAL_CODE			13=0A=
-#define EFI_MAX_MEMORY_TYPE		14=0A=
-=0A=
-/* Attribute values: */=0A=
-#define EFI_MEMORY_UC		0x0000000000000001	/* uncached */=0A=
-#define EFI_MEMORY_WC		0x0000000000000002	/* write-coalescing */=0A=
-#define EFI_MEMORY_WT		0x0000000000000004	/* write-through */=0A=
-#define EFI_MEMORY_WB		0x0000000000000008	/* write-back */=0A=
-#define EFI_MEMORY_WP		0x0000000000001000	/* write-protect */=0A=
-#define EFI_MEMORY_RP		0x0000000000002000	/* read-protect */=0A=
-#define EFI_MEMORY_XP		0x0000000000004000	/* execute-protect */=0A=
-#define EFI_MEMORY_RUNTIME	0x8000000000000000	/* range requires =
runtime mapping */=0A=
-#define EFI_MEMORY_DESCRIPTOR_VERSION	1=0A=
-=0A=
-#define EFI_PAGE_SHIFT		12=0A=
-=0A=
-typedef struct {=0A=
-	u32 type;=0A=
-	u32 pad;=0A=
-	u64 phys_addr;=0A=
-	u64 virt_addr;=0A=
-	u64 num_pages;=0A=
-	u64 attribute;=0A=
-} efi_memory_desc_t;=0A=
-=0A=
-typedef int efi_freemem_callback_t (u64 start, u64 end, void *arg);=0A=
-=0A=
-/*=0A=
- * Types and defines for Time Services=0A=
- */=0A=
-#define EFI_TIME_ADJUST_DAYLIGHT 0x1=0A=
-#define EFI_TIME_IN_DAYLIGHT     0x2=0A=
-#define EFI_UNSPECIFIED_TIMEZONE 0x07ff=0A=
-=0A=
-typedef struct {=0A=
-	u16 year;=0A=
-	u8 month;=0A=
-	u8 day;=0A=
-	u8 hour;=0A=
-	u8 minute;=0A=
-	u8 second;=0A=
-	u8 pad1;=0A=
-	u32 nanosecond;=0A=
-	s16 timezone;=0A=
-	u8 daylight;=0A=
-	u8 pad2;=0A=
-} efi_time_t;=0A=
-=0A=
-typedef struct {=0A=
-	u32 resolution;=0A=
-	u32 accuracy;=0A=
-	u8 sets_to_zero;=0A=
-} efi_time_cap_t;=0A=
-=0A=
-/*=0A=
- * Types and defines for EFI ResetSystem=0A=
- */=0A=
-#define EFI_RESET_COLD 0=0A=
-#define EFI_RESET_WARM 1=0A=
-=0A=
-/*=0A=
- * EFI Runtime Services table=0A=
- */=0A=
-#define EFI_RUNTIME_SERVICES_SIGNATURE 0x5652453544e5552=0A=
-#define EFI_RUNTIME_SERVICES_REVISION  0x00010000=0A=
-=0A=
-typedef struct {=0A=
-	efi_table_hdr_t hdr;=0A=
-	u64 get_time;=0A=
-	u64 set_time;=0A=
-	u64 get_wakeup_time;=0A=
-	u64 set_wakeup_time;=0A=
-	u64 set_virtual_address_map;=0A=
-	u64 convert_pointer;=0A=
-	u64 get_variable;=0A=
-	u64 get_next_variable;=0A=
-	u64 set_variable;=0A=
-	u64 get_next_high_mono_count;=0A=
-	u64 reset_system;=0A=
-} efi_runtime_services_t;=0A=
-=0A=
-typedef efi_status_t efi_get_time_t (efi_time_t *tm, efi_time_cap_t =
*tc);=0A=
-typedef efi_status_t efi_set_time_t (efi_time_t *tm);=0A=
-typedef efi_status_t efi_get_wakeup_time_t (efi_bool_t *enabled, =
efi_bool_t *pending,=0A=
-					    efi_time_t *tm);=0A=
-typedef efi_status_t efi_set_wakeup_time_t (efi_bool_t enabled, =
efi_time_t *tm);=0A=
-typedef efi_status_t efi_get_variable_t (efi_char16_t *name, =
efi_guid_t *vendor, u32 *attr,=0A=
-					 unsigned long *data_size, void *data);=0A=
-typedef efi_status_t efi_get_next_variable_t (unsigned long =
*name_size, efi_char16_t *name,=0A=
-					      efi_guid_t *vendor);=0A=
-typedef efi_status_t efi_set_variable_t (efi_char16_t *name, =
efi_guid_t *vendor, u32 attr,=0A=
-					 unsigned long data_size, void *data);=0A=
-typedef efi_status_t efi_get_next_high_mono_count_t (u64 *count);=0A=
-typedef void efi_reset_system_t (int reset_type, efi_status_t =
status,=0A=
-				 unsigned long data_size, efi_char16_t *data);=0A=
-=0A=
-/*=0A=
- *  EFI Configuration Table and GUID definitions=0A=
- */=0A=
-#define NULL_GUID \=0A=
-    EFI_GUID(  0x00000000, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, =
0x00, 0x00, 0x00, 0x00 )=0A=
-=0A=
-#define MPS_TABLE_GUID    \=0A=
-    EFI_GUID(  0xeb9d2d2f, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, =
0x27, 0x3f, 0xc1, 0x4d )=0A=
-=0A=
-#define ACPI_TABLE_GUID    \=0A=
-    EFI_GUID(  0xeb9d2d30, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, =
0x27, 0x3f, 0xc1, 0x4d )=0A=
-=0A=
-#define ACPI_20_TABLE_GUID    \=0A=
-    EFI_GUID(  0x8868e871, 0xe4f1, 0x11d3, 0xbc, 0x22, 0x0, 0x80, =
0xc7, 0x3c, 0x88, 0x81 )=0A=
-=0A=
-#define SMBIOS_TABLE_GUID    \=0A=
-    EFI_GUID(  0xeb9d2d31, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, =
0x27, 0x3f, 0xc1, 0x4d )=0A=
-=0A=
-#define SAL_SYSTEM_TABLE_GUID    \=0A=
-    EFI_GUID(  0xeb9d2d32, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, =
0x27, 0x3f, 0xc1, 0x4d )=0A=
-=0A=
-#define HCDP_TABLE_GUID	\=0A=
-    EFI_GUID(  0xf951938d, 0x620b, 0x42ef, 0x82, 0x79, 0xa8, 0x4b, =
0x79, 0x61, 0x78, 0x98 )=0A=
-=0A=
-typedef struct {=0A=
-	efi_guid_t guid;=0A=
-	u64 table;=0A=
-} efi_config_table_t;=0A=
-=0A=
-#define EFI_SYSTEM_TABLE_SIGNATURE 0x5453595320494249=0A=
-#define EFI_SYSTEM_TABLE_REVISION  ((1 << 16) | 00)=0A=
-=0A=
-typedef struct {=0A=
-	efi_table_hdr_t hdr;=0A=
-	u64 fw_vendor;		/* physical addr of CHAR16 vendor string */=0A=
-	u32 fw_revision;=0A=
-	u64 con_in_handle;=0A=
-	u64 con_in;=0A=
-	u64 con_out_handle;=0A=
-	u64 con_out;=0A=
-	u64 stderr_handle;=0A=
-	u64 stderr;=0A=
-	u64 runtime;=0A=
-	u64 boottime;=0A=
-	u64 nr_tables;=0A=
-	u64 tables;=0A=
-} efi_system_table_t;=0A=
-=0A=
-/*=0A=
- * All runtime access to EFI goes through this structure:=0A=
- */=0A=
-extern struct efi {=0A=
-	efi_system_table_t *systab;	/* EFI system table */=0A=
-	void *mps;			/* MPS table */=0A=
-	void *acpi;			/* ACPI table  (IA64 ext 0.71) */=0A=
-	void *acpi20;			/* ACPI table  (ACPI 2.0) */=0A=
-	void *smbios;			/* SM BIOS table */=0A=
-	void *sal_systab;		/* SAL system table */=0A=
-	void *hcdp;			/* HCDP table */=0A=
-	void *boot_info;		/* boot info table */=0A=
-	efi_get_time_t *get_time;=0A=
-	efi_set_time_t *set_time;=0A=
-	efi_get_wakeup_time_t *get_wakeup_time;=0A=
-	efi_set_wakeup_time_t *set_wakeup_time;=0A=
-	efi_get_variable_t *get_variable;=0A=
-	efi_get_next_variable_t *get_next_variable;=0A=
-	efi_set_variable_t *set_variable;=0A=
-	efi_get_next_high_mono_count_t *get_next_high_mono_count;=0A=
-	efi_reset_system_t *reset_system;=0A=
-} efi;=0A=
-=0A=
-static inline int=0A=
-efi_guidcmp (efi_guid_t left, efi_guid_t right)=0A=
-{=0A=
-	return memcmp(&left, &right, sizeof (efi_guid_t));=0A=
-}=0A=
-=0A=
-static inline char *=0A=
-efi_guid_unparse(efi_guid_t *guid, char *out)=0A=
-{=0A=
-	sprintf(out, =
"%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",=0A=
-		guid->b[3], guid->b[2], guid->b[1], guid->b[0],=0A=
-		guid->b[5], guid->b[4], guid->b[7], guid->b[6],=0A=
-		guid->b[8], guid->b[9], guid->b[10], guid->b[11],=0A=
-		guid->b[12], guid->b[13], guid->b[14], guid->b[15]);=0A=
-        return out;=0A=
-}=0A=
-=0A=
-extern void efi_init (void);=0A=
-extern void efi_map_pal_code (void);=0A=
-extern void efi_memmap_walk (efi_freemem_callback_t callback, void =
*arg);=0A=
-extern void efi_gettimeofday (struct timeval *tv);=0A=
-extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual =
mode, if possible */=0A=
-extern u64 efi_get_iobase (void);=0A=
-extern u32 efi_mem_type (unsigned long phys_addr);=0A=
-extern u64 efi_mem_attributes (unsigned long phys_addr);=0A=
-=0A=
-/*=0A=
- * Variable Attributes=0A=
- */=0A=
-#define EFI_VARIABLE_NON_VOLATILE       0x0000000000000001=0A=
-#define EFI_VARIABLE_BOOTSERVICE_ACCESS 0x0000000000000002=0A=
-#define EFI_VARIABLE_RUNTIME_ACCESS     0x0000000000000004=0A=
-=0A=
-=0A=
-/*=0A=
- * efi_dir is allocated in arch/ia64/kernel/efi.c.=0A=
- */=0A=
-#ifdef CONFIG_PROC_FS=0A=
-extern struct proc_dir_entry *efi_dir;=0A=
-#endif=0A=
-=0A=
-#endif /* _ASM_IA64_EFI_H */=0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/include/asm-ia64/sal.h =
linux-2.4.18-efihmove/include/asm-ia64/sal.h=0A=
--- linux-2.4.18-ia64/include/asm-ia64/sal.h	Wed Aug 14 18:41:19 =
2002=0A=
+++ linux-2.4.18-efihmove/include/asm-ia64/sal.h	Thu Aug 15 11:22:48 =
2002=0A=
@@ -24,9 +24,9 @@=0A=
  */=0A=
 =0A=
 #include <linux/spinlock.h>=0A=
+#include <linux/efi.h>=0A=
 =0A=
 #include <asm/pal.h>=0A=
-#include <asm/efi.h>=0A=
 #include <asm/system.h>=0A=
 #include <asm/fpu.h>=0A=
 =0A=
diff -urNp --exclude-from=3D/home/mdomsch/excludes --minimal =
linux-2.4.18-ia64/include/linux/efi.h =
linux-2.4.18-efihmove/include/linux/efi.h=0A=
--- linux-2.4.18-ia64/include/linux/efi.h	Wed Dec 31 18:00:00 1969=0A=
+++ linux-2.4.18-efihmove/include/linux/efi.h	Thu Aug 15 11:22:35 =
2002=0A=
@@ -0,0 +1,284 @@=0A=
+#ifndef _LINUX_EFI_H=0A=
+#define _LINUX_EFI_H=0A=
+=0A=
+/*=0A=
+ * Extensible Firmware Interface=0A=
+ * Based on 'Extensible Firmware Interface Specification' version 0.9, =
April 30, 1999=0A=
+ *=0A=
+ * Copyright (C) 1999 VA Linux Systems=0A=
+ * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>=0A=
+ * Copyright (C) 1999, 2002 Hewlett-Packard Co.=0A=
+ *	David Mosberger-Tang <davidm@hpl.hp.com>=0A=
+ *	Stephane Eranian <eranian@hpl.hp.com>=0A=
+ */=0A=
+#include <linux/init.h>=0A=
+#include <linux/string.h>=0A=
+#include <linux/time.h>=0A=
+#include <linux/types.h>=0A=
+#include <linux/proc_fs.h>=0A=
+=0A=
+#include <asm/page.h>=0A=
+#include <asm/system.h>=0A=
+=0A=
+#define EFI_SUCCESS		0=0A=
+#define EFI_LOAD_ERROR          (1L | (1L << 63))=0A=
+#define EFI_INVALID_PARAMETER	(2L | (1L << 63))=0A=
+#define EFI_UNSUPPORTED		(3L | (1L << 63))=0A=
+#define EFI_BAD_BUFFER_SIZE     (4L | (1L << 63))=0A=
+#define EFI_BUFFER_TOO_SMALL	(5L | (1L << 63))=0A=
+#define EFI_NOT_FOUND          (14L | (1L << 63))=0A=
+=0A=
+typedef unsigned long efi_status_t;=0A=
+typedef u8 efi_bool_t;=0A=
+typedef u16 efi_char16_t;		/* UNICODE character */=0A=
+=0A=
+=0A=
+typedef struct {=0A=
+	u8 b[16];=0A=
+} efi_guid_t;=0A=
+=0A=
+#define EFI_GUID(a,b,c,d0,d1,d2,d3,d4,d5,d6,d7) \=0A=
+((efi_guid_t) \=0A=
+{{ (a) & 0xff, ((a) >> 8) & 0xff, ((a) >> 16) & 0xff, ((a) >> 24) & =
0xff, \=0A=
+  (b) & 0xff, ((b) >> 8) & 0xff, \=0A=
+  (c) & 0xff, ((c) >> 8) & 0xff, \=0A=
+  (d0), (d1), (d2), (d3), (d4), (d5), (d6), (d7) }})=0A=
+=0A=
+/*=0A=
+ * Generic EFI table header=0A=
+ */=0A=
+typedef	struct {=0A=
+	u64 signature;=0A=
+	u32 revision;=0A=
+	u32 headersize;=0A=
+	u32 crc32;=0A=
+	u32 reserved;=0A=
+} efi_table_hdr_t;=0A=
+=0A=
+/*=0A=
+ * Memory map descriptor:=0A=
+ */=0A=
+=0A=
+/* Memory types: */=0A=
+#define EFI_RESERVED_TYPE		 0=0A=
+#define EFI_LOADER_CODE			 1=0A=
+#define EFI_LOADER_DATA			 2=0A=
+#define EFI_BOOT_SERVICES_CODE		 3=0A=
+#define EFI_BOOT_SERVICES_DATA		 4=0A=
+#define EFI_RUNTIME_SERVICES_CODE	 5=0A=
+#define EFI_RUNTIME_SERVICES_DATA	 6=0A=
+#define EFI_CONVENTIONAL_MEMORY		 7=0A=
+#define EFI_UNUSABLE_MEMORY		 8=0A=
+#define EFI_ACPI_RECLAIM_MEMORY		 9=0A=
+#define EFI_ACPI_MEMORY_NVS		10=0A=
+#define EFI_MEMORY_MAPPED_IO		11=0A=
+#define EFI_MEMORY_MAPPED_IO_PORT_SPACE	12=0A=
+#define EFI_PAL_CODE			13=0A=
+#define EFI_MAX_MEMORY_TYPE		14=0A=
+=0A=
+/* Attribute values: */=0A=
+#define EFI_MEMORY_UC		0x0000000000000001	/* uncached */=0A=
+#define EFI_MEMORY_WC		0x0000000000000002	/* write-coalescing */=0A=
+#define EFI_MEMORY_WT		0x0000000000000004	/* write-through */=0A=
+#define EFI_MEMORY_WB		0x0000000000000008	/* write-back */=0A=
+#define EFI_MEMORY_WP		0x0000000000001000	/* write-protect */=0A=
+#define EFI_MEMORY_RP		0x0000000000002000	/* read-protect */=0A=
+#define EFI_MEMORY_XP		0x0000000000004000	/* execute-protect */=0A=
+#define EFI_MEMORY_RUNTIME	0x8000000000000000	/* range requires =
runtime mapping */=0A=
+#define EFI_MEMORY_DESCRIPTOR_VERSION	1=0A=
+=0A=
+#define EFI_PAGE_SHIFT		12=0A=
+=0A=
+typedef struct {=0A=
+	u32 type;=0A=
+	u32 pad;=0A=
+	u64 phys_addr;=0A=
+	u64 virt_addr;=0A=
+	u64 num_pages;=0A=
+	u64 attribute;=0A=
+} efi_memory_desc_t;=0A=
+=0A=
+typedef int efi_freemem_callback_t (u64 start, u64 end, void *arg);=0A=
+=0A=
+/*=0A=
+ * Types and defines for Time Services=0A=
+ */=0A=
+#define EFI_TIME_ADJUST_DAYLIGHT 0x1=0A=
+#define EFI_TIME_IN_DAYLIGHT     0x2=0A=
+#define EFI_UNSPECIFIED_TIMEZONE 0x07ff=0A=
+=0A=
+typedef struct {=0A=
+	u16 year;=0A=
+	u8 month;=0A=
+	u8 day;=0A=
+	u8 hour;=0A=
+	u8 minute;=0A=
+	u8 second;=0A=
+	u8 pad1;=0A=
+	u32 nanosecond;=0A=
+	s16 timezone;=0A=
+	u8 daylight;=0A=
+	u8 pad2;=0A=
+} efi_time_t;=0A=
+=0A=
+typedef struct {=0A=
+	u32 resolution;=0A=
+	u32 accuracy;=0A=
+	u8 sets_to_zero;=0A=
+} efi_time_cap_t;=0A=
+=0A=
+/*=0A=
+ * Types and defines for EFI ResetSystem=0A=
+ */=0A=
+#define EFI_RESET_COLD 0=0A=
+#define EFI_RESET_WARM 1=0A=
+=0A=
+/*=0A=
+ * EFI Runtime Services table=0A=
+ */=0A=
+#define EFI_RUNTIME_SERVICES_SIGNATURE 0x5652453544e5552=0A=
+#define EFI_RUNTIME_SERVICES_REVISION  0x00010000=0A=
+=0A=
+typedef struct {=0A=
+	efi_table_hdr_t hdr;=0A=
+	u64 get_time;=0A=
+	u64 set_time;=0A=
+	u64 get_wakeup_time;=0A=
+	u64 set_wakeup_time;=0A=
+	u64 set_virtual_address_map;=0A=
+	u64 convert_pointer;=0A=
+	u64 get_variable;=0A=
+	u64 get_next_variable;=0A=
+	u64 set_variable;=0A=
+	u64 get_next_high_mono_count;=0A=
+	u64 reset_system;=0A=
+} efi_runtime_services_t;=0A=
+=0A=
+typedef efi_status_t efi_get_time_t (efi_time_t *tm, efi_time_cap_t =
*tc);=0A=
+typedef efi_status_t efi_set_time_t (efi_time_t *tm);=0A=
+typedef efi_status_t efi_get_wakeup_time_t (efi_bool_t *enabled, =
efi_bool_t *pending,=0A=
+					    efi_time_t *tm);=0A=
+typedef efi_status_t efi_set_wakeup_time_t (efi_bool_t enabled, =
efi_time_t *tm);=0A=
+typedef efi_status_t efi_get_variable_t (efi_char16_t *name, =
efi_guid_t *vendor, u32 *attr,=0A=
+					 unsigned long *data_size, void *data);=0A=
+typedef efi_status_t efi_get_next_variable_t (unsigned long =
*name_size, efi_char16_t *name,=0A=
+					      efi_guid_t *vendor);=0A=
+typedef efi_status_t efi_set_variable_t (efi_char16_t *name, =
efi_guid_t *vendor, u32 attr,=0A=
+					 unsigned long data_size, void *data);=0A=
+typedef efi_status_t efi_get_next_high_mono_count_t (u64 *count);=0A=
+typedef void efi_reset_system_t (int reset_type, efi_status_t =
status,=0A=
+				 unsigned long data_size, efi_char16_t *data);=0A=
+=0A=
+/*=0A=
+ *  EFI Configuration Table and GUID definitions=0A=
+ */=0A=
+#define NULL_GUID \=0A=
+    EFI_GUID(  0x00000000, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, =
0x00, 0x00, 0x00, 0x00 )=0A=
+=0A=
+#define MPS_TABLE_GUID    \=0A=
+    EFI_GUID(  0xeb9d2d2f, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, =
0x27, 0x3f, 0xc1, 0x4d )=0A=
+=0A=
+#define ACPI_TABLE_GUID    \=0A=
+    EFI_GUID(  0xeb9d2d30, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, =
0x27, 0x3f, 0xc1, 0x4d )=0A=
+=0A=
+#define ACPI_20_TABLE_GUID    \=0A=
+    EFI_GUID(  0x8868e871, 0xe4f1, 0x11d3, 0xbc, 0x22, 0x0, 0x80, =
0xc7, 0x3c, 0x88, 0x81 )=0A=
+=0A=
+#define SMBIOS_TABLE_GUID    \=0A=
+    EFI_GUID(  0xeb9d2d31, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, =
0x27, 0x3f, 0xc1, 0x4d )=0A=
+=0A=
+#define SAL_SYSTEM_TABLE_GUID    \=0A=
+    EFI_GUID(  0xeb9d2d32, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, =
0x27, 0x3f, 0xc1, 0x4d )=0A=
+=0A=
+#define HCDP_TABLE_GUID	\=0A=
+    EFI_GUID(  0xf951938d, 0x620b, 0x42ef, 0x82, 0x79, 0xa8, 0x4b, =
0x79, 0x61, 0x78, 0x98 )=0A=
+=0A=
+typedef struct {=0A=
+	efi_guid_t guid;=0A=
+	u64 table;=0A=
+} efi_config_table_t;=0A=
+=0A=
+#define EFI_SYSTEM_TABLE_SIGNATURE 0x5453595320494249=0A=
+#define EFI_SYSTEM_TABLE_REVISION  ((1 << 16) | 00)=0A=
+=0A=
+typedef struct {=0A=
+	efi_table_hdr_t hdr;=0A=
+	u64 fw_vendor;		/* physical addr of CHAR16 vendor string */=0A=
+	u32 fw_revision;=0A=
+	u64 con_in_handle;=0A=
+	u64 con_in;=0A=
+	u64 con_out_handle;=0A=
+	u64 con_out;=0A=
+	u64 stderr_handle;=0A=
+	u64 stderr;=0A=
+	u64 runtime;=0A=
+	u64 boottime;=0A=
+	u64 nr_tables;=0A=
+	u64 tables;=0A=
+} efi_system_table_t;=0A=
+=0A=
+/*=0A=
+ * All runtime access to EFI goes through this structure:=0A=
+ */=0A=
+extern struct efi {=0A=
+	efi_system_table_t *systab;	/* EFI system table */=0A=
+	void *mps;			/* MPS table */=0A=
+	void *acpi;			/* ACPI table  (IA64 ext 0.71) */=0A=
+	void *acpi20;			/* ACPI table  (ACPI 2.0) */=0A=
+	void *smbios;			/* SM BIOS table */=0A=
+	void *sal_systab;		/* SAL system table */=0A=
+	void *hcdp;			/* HCDP table */=0A=
+	void *boot_info;		/* boot info table */=0A=
+	efi_get_time_t *get_time;=0A=
+	efi_set_time_t *set_time;=0A=
+	efi_get_wakeup_time_t *get_wakeup_time;=0A=
+	efi_set_wakeup_time_t *set_wakeup_time;=0A=
+	efi_get_variable_t *get_variable;=0A=
+	efi_get_next_variable_t *get_next_variable;=0A=
+	efi_set_variable_t *set_variable;=0A=
+	efi_get_next_high_mono_count_t *get_next_high_mono_count;=0A=
+	efi_reset_system_t *reset_system;=0A=
+} efi;=0A=
+=0A=
+static inline int=0A=
+efi_guidcmp (efi_guid_t left, efi_guid_t right)=0A=
+{=0A=
+	return memcmp(&left, &right, sizeof (efi_guid_t));=0A=
+}=0A=
+=0A=
+static inline char *=0A=
+efi_guid_unparse(efi_guid_t *guid, char *out)=0A=
+{=0A=
+	sprintf(out, =
"%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",=0A=
+		guid->b[3], guid->b[2], guid->b[1], guid->b[0],=0A=
+		guid->b[5], guid->b[4], guid->b[7], guid->b[6],=0A=
+		guid->b[8], guid->b[9], guid->b[10], guid->b[11],=0A=
+		guid->b[12], guid->b[13], guid->b[14], guid->b[15]);=0A=
+        return out;=0A=
+}=0A=
+=0A=
+extern void efi_init (void);=0A=
+extern void efi_map_pal_code (void);=0A=
+extern void efi_memmap_walk (efi_freemem_callback_t callback, void =
*arg);=0A=
+extern void efi_gettimeofday (struct timeval *tv);=0A=
+extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual =
mode, if possible */=0A=
+extern u64 efi_get_iobase (void);=0A=
+extern u32 efi_mem_type (unsigned long phys_addr);=0A=
+extern u64 efi_mem_attributes (unsigned long phys_addr);=0A=
+=0A=
+/*=0A=
+ * Variable Attributes=0A=
+ */=0A=
+#define EFI_VARIABLE_NON_VOLATILE       0x0000000000000001=0A=
+#define EFI_VARIABLE_BOOTSERVICE_ACCESS 0x0000000000000002=0A=
+#define EFI_VARIABLE_RUNTIME_ACCESS     0x0000000000000004=0A=
+=0A=
+=0A=
+/*=0A=
+ * efi_dir is allocated in arch/ia64/kernel/efi.c.=0A=
+ */=0A=
+#ifdef CONFIG_PROC_FS=0A=
+extern struct proc_dir_entry *efi_dir;=0A=
+#endif=0A=
+=0A=
+#endif /* _LINUX_EFI_H */=0A=

------_=_NextPart_000_01C2447C.8456CDF0--


