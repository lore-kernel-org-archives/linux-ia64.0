From: Tim Abbott <tabbott@ksplice.com>
Date: Fri, 31 Jul 2009 20:57:53 +0000
Subject: [PATCH 3/3] ia64: Clean up linker script using standard macros.
Message-Id: <1249073873-30028-3-git-send-email-tabbott@ksplice.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1249073873-30028-1-git-send-email-tabbott@ksplice.com>
In-Reply-To: <1249073873-30028-1-git-send-email-tabbott@ksplice.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Anders Kaseorg <andersk@ksplice.com>, Nelson Elhage <nelhage@ksplice.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

From: Nelson Elhage <nelhage@ksplice.com>

Aside from using fewer output sections and moving some data around,
the main side effect of this change is changing the alignment of some
sections. In particular:

* cachline-aligned and read_mostly data are now aligned to
  SMP_CACHE_BYTES. (Previously, they were laid out consecutively after
  a PAGE_SIZE alignment)
* .init.ramfs is now page-aligned, per the INIT_RAM_FS
  macro. (Previously it had no explicit alignment).

Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/vmlinux.lds.S |  109 ++++------------------------------------
 1 files changed, 11 insertions(+), 98 deletions(-)

diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index b484b86..f69f411 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -64,14 +64,7 @@ SECTIONS
   NOTES :code :note		/* put .notes in text and mark in PT_NOTE  */
   code_continues : {} :code	/* switch back to regular program...  */
 
-  /* Exception table */
-  . = ALIGN(16);
-  __ex_table : AT(ADDR(__ex_table) - LOAD_OFFSET)
-	{
-	  __start___ex_table = .;
-	  *(__ex_table)
-	  __stop___ex_table = .;
-	}
+  EXCEPTION_TABLE(16)
 
   /* MCA table */
   . = ALIGN(16);
@@ -113,38 +106,9 @@ SECTIONS
 
   . = ALIGN(PAGE_SIZE);
   __init_begin = .;
-  .init.text : AT(ADDR(.init.text) - LOAD_OFFSET)
-	{
-	  _sinittext = .;
-	  INIT_TEXT
-	  _einittext = .;
-	}
-
-  .init.data : AT(ADDR(.init.data) - LOAD_OFFSET)
-	{ INIT_DATA }
-
-#ifdef CONFIG_BLK_DEV_INITRD
-  .init.ramfs : AT(ADDR(.init.ramfs) - LOAD_OFFSET)
-	{
-	  __initramfs_start = .;
-	  *(.init.ramfs)
-	  __initramfs_end = .;
-	}
-#endif
 
-   . = ALIGN(16);
-  .init.setup : AT(ADDR(.init.setup) - LOAD_OFFSET)
-        {
-	  __setup_start = .;
-	  *(.init.setup)
-	  __setup_end = .;
-	}
-  .initcall.init : AT(ADDR(.initcall.init) - LOAD_OFFSET)
-	{
-	  __initcall_start = .;
-	INITCALLS
-	  __initcall_end = .;
-	}
+  INIT_TEXT_SECTION(PAGE_SIZE)
+  INIT_DATA_SECTION(16)
 
   .data.patch.vtop : AT(ADDR(.data.patch.vtop) - LOAD_OFFSET)
 	{
@@ -202,22 +166,9 @@ SECTIONS
 	}
 #endif
 
-  . = ALIGN(8);
-   __con_initcall_start = .;
-  .con_initcall.init : AT(ADDR(.con_initcall.init) - LOAD_OFFSET)
-	{ *(.con_initcall.init) }
-  __con_initcall_end = .;
-  __security_initcall_start = .;
-  .security_initcall.init : AT(ADDR(.security_initcall.init) - LOAD_OFFSET)
-	{ *(.security_initcall.init) }
-  __security_initcall_end = .;
   . = ALIGN(PAGE_SIZE);
   __init_end = .;
 
-  /* The initial task and kernel stack */
-  .data.init_task : AT(ADDR(.data.init_task) - LOAD_OFFSET)
-	{ *(.data.init_task) }
-
   .data.page_aligned : AT(ADDR(.data.page_aligned) - LOAD_OFFSET)
         {
 	PAGE_ALIGNED_DATA(PAGE_SIZE)
@@ -236,12 +187,6 @@ SECTIONS
   				 * kernel data
 				 */
 
-  .data.read_mostly : AT(ADDR(.data.read_mostly) - LOAD_OFFSET)
-        { *(.data.read_mostly) }
-
-  .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - LOAD_OFFSET)
-        { *(.data.cacheline_aligned) }
-
   /* Per-cpu data: */
   . = ALIGN(PERCPU_PAGE_SIZE);
   PERCPU_VADDR(PERCPU_ADDR, :percpu)
@@ -258,6 +203,9 @@ SECTIONS
 		__cpu0_per_cpu = .;
   . = . + PERCPU_PAGE_SIZE;	/* cpu0 per-cpu space */
 #endif
+		INIT_TASK_DATA(PAGE_SIZE)
+		CACHELINE_ALIGNED_DATA(SMP_CACHE_BYTES)
+		READ_MOSTLY_DATA(SMP_CACHE_BYTES)
 		DATA_DATA
 		*(.data1)
 		*(.gnu.linkonce.d*)
@@ -274,49 +222,14 @@ SECTIONS
   .sdata : AT(ADDR(.sdata) - LOAD_OFFSET)
 	{ *(.sdata) *(.sdata1) *(.srdata) }
   _edata  =  .;
-  __bss_start = .;
-  .sbss : AT(ADDR(.sbss) - LOAD_OFFSET)
-	{ *(.sbss) *(.scommon) }
-  .bss : AT(ADDR(.bss) - LOAD_OFFSET)
-	{ *(.bss) *(COMMON) }
-  __bss_stop = .;
+
+  BSS_SECTION(0, 0, 0)
 
   _end = .;
 
   code : { } :code
-  /* Stabs debugging sections.  */
-  .stab 0 : { *(.stab) }
-  .stabstr 0 : { *(.stabstr) }
-  .stab.excl 0 : { *(.stab.excl) }
-  .stab.exclstr 0 : { *(.stab.exclstr) }
-  .stab.index 0 : { *(.stab.index) }
-  .stab.indexstr 0 : { *(.stab.indexstr) }
-  /* DWARF debug sections.
-     Symbols in the DWARF debugging sections are relative to the beginning
-     of the section so we begin them at 0.  */
-  /* DWARF 1 */
-  .debug          0 : { *(.debug) }
-  .line           0 : { *(.line) }
-  /* GNU DWARF 1 extensions */
-  .debug_srcinfo  0 : { *(.debug_srcinfo) }
-  .debug_sfnames  0 : { *(.debug_sfnames) }
-  /* DWARF 1.1 and DWARF 2 */
-  .debug_aranges  0 : { *(.debug_aranges) }
-  .debug_pubnames 0 : { *(.debug_pubnames) }
-  /* DWARF 2 */
-  .debug_info     0 : { *(.debug_info) }
-  .debug_abbrev   0 : { *(.debug_abbrev) }
-  .debug_line     0 : { *(.debug_line) }
-  .debug_frame    0 : { *(.debug_frame) }
-  .debug_str      0 : { *(.debug_str) }
-  .debug_loc      0 : { *(.debug_loc) }
-  .debug_macinfo  0 : { *(.debug_macinfo) }
-  /* SGI/MIPS DWARF 2 extensions */
-  .debug_weaknames 0 : { *(.debug_weaknames) }
-  .debug_funcnames 0 : { *(.debug_funcnames) }
-  .debug_typenames 0 : { *(.debug_typenames) }
-  .debug_varnames  0 : { *(.debug_varnames) }
-  /* These must appear regardless of  .  */
-  /DISCARD/ : { *(.comment) }
+
+  STABS_DEBUG
+  DWARF_DEBUG
   /DISCARD/ : { *(.note) }
 }
-- 
1.6.3.3

