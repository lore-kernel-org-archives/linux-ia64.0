From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 21 Jan 2005 23:22:18 +0000
Subject: optimize __gp location
Message-Id: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

__gp is positioned so far out that it is almost at the end of all data
sections.  On 2.6.11-rc1, 80% of kernel data symbols are out of 22-bit
immediate offset from __gp.  This means accessing these symbols are 
unnecessarily expansive such that they have to go through global offset
table (a memory load to get the symbol address).  Among these out of
reach symbols from __gp, some are very frequently used, like Jiffies,
etc.

Can we position the __gp somewhat more optimally, to cover more of these
symbols? Something like the following patch would make all of them fall
into the 22-bit immediate offset relative to gp.

--- linux-2.6.11-rc1/arch/ia64/kernel/vmlinux.lds.S.orig
2005-01-21 11:43:57.000000000 -0800
+++ linux-2.6.11-rc1/arch/ia64/kernel/vmlinux.lds.S	2005-01-21
14:45:29.000000000 -0800
@@ -193,7 +193,7 @@ SECTIONS
   . = ALIGN(16);	/* gp must be 16-byte aligned for exc. table */
   .got : AT(ADDR(.got) - LOAD_OFFSET)
 	{ *(.got.plt) *(.got) }
-  __gp = ADDR(.got) + 0x200000;
+  __gp = _end - 0x200000;
   /* We want the small data sections together, so single-instruction
offsets
      can access them all, and initialized data all before
uninitialized, so
      we can shorten the on-disk segment size.  */
@@ -205,7 +205,7 @@ SECTIONS
 	{ *(.sbss) *(.scommon) }
   .bss : AT(ADDR(.bss) - LOAD_OFFSET)
 	{ *(.bss) *(COMMON) }
-
+  . = ALIGN(16);
   _end = .;
 
   code : { } :code

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
