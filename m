From: Keith Owens <kaos@sgi.com>
Date: Thu, 27 May 2004 05:39:41 +0000
Subject: [patch 2.6.6] Workaround linker bug
Message-Id: <9422.1085636381@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Building 2.6.6-ia64-040521, using GNU ld version 2.14.90.0.4 20030523.
__gp is sometimes set incorrectly.  Instead of being .got + 0x2000000,
it is set to .data + 0x2000000, which breaks some LTOFF22 and GPREL22
entries.

This is non-deterministic, changing the path name to the kernel tree
which changes the size of some messages in .data is enough to make the
linker get it right.  Force __gp to be based on .got.

Index: linux/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux.orig/arch/ia64/kernel/vmlinux.lds.S	Thu May 27 15:08:02 2004
+++ linux/arch/ia64/kernel/vmlinux.lds.S	Thu May 27 15:16:11 2004
@@ -202,11 +202,10 @@ SECTIONS
   .data : AT(ADDR(.data) - LOAD_OFFSET)
 	{ *(.data) *(.data1) *(.gnu.linkonce.d*) CONSTRUCTORS }
 
-  . = ALIGN(16);
-  __gp = . + 0x200000;	/* gp must be 16-byte aligned for exc. table */
-
+  . = ALIGN(16);	/* gp must be 16-byte aligned for exc. table */
   .got : AT(ADDR(.got) - LOAD_OFFSET)
 	{ *(.got.plt) *(.got) }
+  __gp = ADDR(.got) + 0x200000;
   /* We want the small data sections together, so single-instruction offsets
      can access them all, and initialized data all before uninitialized, so
      we can shorten the on-disk segment size.  */

