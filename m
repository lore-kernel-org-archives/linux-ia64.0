From: Roland McGrath <roland@redhat.com>
Date: Tue, 16 Oct 2007 03:40:29 +0000
Subject: [PATCH] ia64 vDSO: linker script indentation
Message-Id: <20071016034029.1C3E44D0389@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>


This cleans up the formatting in the vDSO linker script, mostly just the
use of whitespace.  It's intended to approximate the kernel standard
conventions for indenting C, treating elements of the linker script about
like initialized variable definitions.

Signed-off-by: Roland McGrath <roland@redhat.com>
CC: Sam Ravnborg <sam@ravnborg.org>
---
 arch/ia64/kernel/gate.lds.S |  135 +++++++++++++++++++++++--------------------
 1 files changed, 72 insertions(+), 63 deletions(-)

diff --git a/arch/ia64/kernel/gate.lds.S b/arch/ia64/kernel/gate.lds.S
index 6d19833..44817d9 100644
--- a/arch/ia64/kernel/gate.lds.S
+++ b/arch/ia64/kernel/gate.lds.S
@@ -1,7 +1,8 @@
 /*
- * Linker script for gate DSO.  The gate pages are an ELF shared object prelinked to its
- * virtual address, with only one read-only segment and one execute-only segment (both fit
- * in one page).  This script controls its layout.
+ * Linker script for gate DSO.  The gate pages are an ELF shared object
+ * prelinked to its virtual address, with only one read-only segment and
+ * one execute-only segment (both fit in one page).  This script controls
+ * its layout.
  */
 
 
@@ -9,72 +10,80 @@
 
 SECTIONS
 {
-  . = GATE_ADDR + SIZEOF_HEADERS;
-
-  .hash				: { *(.hash) }				:readable
-  .gnu.hash			: { *(.gnu.hash) }
-  .dynsym			: { *(.dynsym) }
-  .dynstr			: { *(.dynstr) }
-  .gnu.version			: { *(.gnu.version) }
-  .gnu.version_d		: { *(.gnu.version_d) }
-  .gnu.version_r		: { *(.gnu.version_r) }
-  .dynamic			: { *(.dynamic) }			:readable :dynamic
-
-  /*
-   * This linker script is used both with -r and with -shared.  For the layouts to match,
-   * we need to skip more than enough space for the dynamic symbol table et al.  If this
-   * amount is insufficient, ld -shared will barf.  Just increase it here.
-   */
-  . = GATE_ADDR + 0x500;
-
-  .data.patch			: {
-				    __start_gate_mckinley_e9_patchlist = .;
-				    *(.data.patch.mckinley_e9)
-				    __end_gate_mckinley_e9_patchlist = .;
-
-				    __start_gate_vtop_patchlist = .;
-				    *(.data.patch.vtop)
-				    __end_gate_vtop_patchlist = .;
-
-				    __start_gate_fsyscall_patchlist = .;
-				    *(.data.patch.fsyscall_table)
-				    __end_gate_fsyscall_patchlist = .;
-
-				    __start_gate_brl_fsys_bubble_down_patchlist = .;
-				    *(.data.patch.brl_fsys_bubble_down)
-				    __end_gate_brl_fsys_bubble_down_patchlist = .;
-  }									:readable
-  .IA_64.unwind_info		: { *(.IA_64.unwind_info*) }
-  .IA_64.unwind			: { *(.IA_64.unwind*) }			:readable :unwind
+	. = GATE_ADDR + SIZEOF_HEADERS;
+
+	.hash			: { *(.hash) }		:readable
+	.gnu.hash		: { *(.gnu.hash) }
+	.dynsym			: { *(.dynsym) }
+	.dynstr			: { *(.dynstr) }
+	.gnu.version		: { *(.gnu.version) }
+	.gnu.version_d		: { *(.gnu.version_d) }
+	.gnu.version_r		: { *(.gnu.version_r) }
+
+	.dynamic		: { *(.dynamic) }	:readable	:dynamic
+
+	/*
+	 * This linker script is used both with -r and with -shared.  For
+	 * the layouts to match, we need to skip more than enough space for
+	 * the dynamic symbol table et al.  If this amount is insufficient,
+	 * ld -shared will barf.  Just increase it here.
+	 */
+	. = GATE_ADDR + 0x500;
+
+	.data.patch		: {
+		__start_gate_mckinley_e9_patchlist = .;
+		*(.data.patch.mckinley_e9)
+		__end_gate_mckinley_e9_patchlist = .;
+
+		__start_gate_vtop_patchlist = .;
+		*(.data.patch.vtop)
+		__end_gate_vtop_patchlist = .;
+
+		__start_gate_fsyscall_patchlist = .;
+		*(.data.patch.fsyscall_table)
+		__end_gate_fsyscall_patchlist = .;
+
+		__start_gate_brl_fsys_bubble_down_patchlist = .;
+		*(.data.patch.brl_fsys_bubble_down)
+		__end_gate_brl_fsys_bubble_down_patchlist = .;
+	}						:readable
+
+	.IA_64.unwind_info	: { *(.IA_64.unwind_info*) }
+	.IA_64.unwind		: { *(.IA_64.unwind*) }	:readable	:unwind
 #ifdef HAVE_BUGGY_SEGREL
-  .text (GATE_ADDR + PAGE_SIZE)	: { *(.text) *(.text.*) }		:readable
+	.text (GATE_ADDR + PAGE_SIZE) : { *(.text) *(.text.*) }	:readable
 #else
-  . = ALIGN (PERCPU_PAGE_SIZE) + (. & (PERCPU_PAGE_SIZE - 1));
-  .text				: { *(.text) *(.text.*) }		:epc
+	. = ALIGN(PERCPU_PAGE_SIZE) + (. & (PERCPU_PAGE_SIZE - 1));
+	.text			: { *(.text) *(.text.*) }	:epc
 #endif
 
-  /DISCARD/			: {
-  	*(.got.plt) *(.got)
-	*(.data .data.* .gnu.linkonce.d.*)
-	*(.dynbss)
-	*(.bss .bss.* .gnu.linkonce.b.*)
-	*(__ex_table)
-	*(__mca_table)
-  }
+	/DISCARD/		: {
+		*(.got.plt) *(.got)
+		*(.data .data.* .gnu.linkonce.d.*)
+		*(.dynbss)
+		*(.bss .bss.* .gnu.linkonce.b.*)
+		*(__ex_table)
+		*(__mca_table)
+	}
 }
 
 /*
+ * ld does not recognize this name token; use the constant.
+ */
+#define	PT_IA_64_UNWIND	0x70000001
+
+/*
  * We must supply the ELF program headers explicitly to get just one
  * PT_LOAD segment, and set the flags explicitly to make segments read-only.
  */
 PHDRS
 {
-  readable  PT_LOAD	FILEHDR	PHDRS	FLAGS(4);	/* PF_R */
+	readable	PT_LOAD	FILEHDR	PHDRS	FLAGS(4);	/* PF_R */
 #ifndef HAVE_BUGGY_SEGREL
-  epc	    PT_LOAD	FILEHDR PHDRS	FLAGS(1);	/* PF_X */
+	epc		PT_LOAD	FILEHDR PHDRS	FLAGS(1);	/* PF_X */
 #endif
-  dynamic   PT_DYNAMIC			FLAGS(4);	/* PF_R */
-  unwind    0x70000001; /* PT_IA_64_UNWIND, but ld doesn't match the name */
+	dynamic		PT_DYNAMIC		FLAGS(4);	/* PF_R */
+	unwind		PT_IA_64_UNWIND;
 }
 
 /*
@@ -82,14 +91,14 @@ PHDRS
  */
 VERSION
 {
-  LINUX_2.5 {
-    global:
-	__kernel_syscall_via_break;
-	__kernel_syscall_via_epc;
-	__kernel_sigtramp;
-
-    local: *;
-  };
+	LINUX_2.5 {
+	global:
+		__kernel_syscall_via_break;
+		__kernel_syscall_via_epc;
+		__kernel_sigtramp;
+
+	local: *;
+	};
 }
 
 /* The ELF entry point can be used to set the AT_SYSINFO value.  */
