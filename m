From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 01 Aug 2002 03:17:25 +0000
Subject: [Linux-ia64] [patch] Assign __gp to middle of short data sections
Message-Id: <marc-linux-ia64-105590701905870@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I was getting '__gp does not cover short data segment'.
arch/ia64/vmlinus.lds.S assigns __gp well away from the short data
sections, for no good reason that I can see.  A kernel with more than
2^21 bytes between __gp and the end of sbss cannot link.

This patch (against 2.4.18) puts __gp right in the middle of the short
data sections.  The comment 'gp must be 16-byte aligned for exc. table'
puzzles me, AFAICT the exception tables are not accessed via gp.

Index: 19-pre10.10/arch/ia64/vmlinux.lds.S
--- 19-pre10.10/arch/ia64/vmlinux.lds.S Thu, 09 May 2002 12:00:25 +1000 kaos (linux-2.4/p/c/50_vmlinux.ld 1.1.5.1.2.1.1.1.1.2 644)
+++ 19-pre10.10(w)/arch/ia64/vmlinux.lds.S Thu, 01 Aug 2002 13:09:02 +1000 kaos (linux-2.4/p/c/50_vmlinux.ld 1.1.5.1.2.1.1.1.1.2 644)
@@ -40,8 +40,6 @@ SECTIONS
 
   /* Read-only data */
 
-  __gp = ALIGN(16) + 0x200000;	/* gp must be 16-byte aligned for exc. table */
-
   /* Global data */
   _data = .;
 
@@ -130,6 +128,7 @@ SECTIONS
   .data : AT(ADDR(.data) - PAGE_OFFSET)
 	{ *(.data) *(.gnu.linkonce.d*) CONSTRUCTORS }
 
+  __got = ALIGN(16);
   .got : AT(ADDR(.got) - PAGE_OFFSET)
 	{ *(.got.plt) *(.got) }
   /* We want the small data sections together, so single-instruction offsets
@@ -141,6 +140,7 @@ SECTIONS
   _bss = .;
   .sbss : AT(ADDR(.sbss) - PAGE_OFFSET)
 	{ *(.sbss) *(.scommon) }
+  __gp = (. - (. - __got) / 2) & -16;	/* put __gp in the middle of the short data areas */
   .bss : AT(ADDR(.bss) - PAGE_OFFSET)
 	{ *(.bss) *(COMMON) }
   . = ALIGN(64 / 8);


