From: Keith Owens <kaos@sgi.com>
Date: Tue, 16 Mar 2004 06:22:39 +0000
Subject: Re: 2.6.3 Heisenbug in unwind.c
Message-Id: <6187.1079418159@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2654.1077624337@ocs3.ocs.com.au>
In-Reply-To: <2654.1077624337@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 15 Mar 2004 17:52:09 +1100, 
Keith Owens <kaos@sgi.com> wrote:
>One step further on.  The illegal unwind descriptors are being caused
>by the linker (GNU ld version 2.14.90.0.4 20030523) sometimes putting
>everything from .init.text onwards in an extra output program header.

Which of course it is quite entitled to do.  vmlinux.lds.S does not
define the mapping of sections to segments so the linker can choose the
layout itself.  Most of the time .text and .init.text are in the same
segment, but sometimes they are in separate segments.  When they are in
separate segments _and_ binutils has buggy SEGREL code then the unwind
data is useless.

Refuse to build 2.6 ia64 with a buggy binutils.

Index: linux-2.6.4/arch/ia64/scripts/toolchain-flags
=================================--- linux-2.6.4.orig/arch/ia64/scripts/toolchain-flags	2004-03-10 18:55:49.000000000 -0800
+++ linux-2.6.4/arch/ia64/scripts/toolchain-flags	2004-03-15 22:11:02.000000000 -0800
@@ -18,11 +18,6 @@
 rm -f $out
 if [ $res != 00000a00 ]; then
     CPPFLAGS="$CPPFLAGS -DHAVE_BUGGY_SEGREL"
-    cat >&2 <<EOF
-warning: your linker cannot handle cross-segment segment-relative relocations.
-         please upgrade to a newer version (it is safe to use this linker, but
-         the kernel will be bigger than strictly necessary).
-EOF
 fi
 
 # Check whether .align inside a function works as expected.
Index: linux-2.6.4/arch/ia64/Makefile
=================================--- linux-2.6.4.orig/arch/ia64/Makefile	2004-03-11 22:29:00.000000000 -0800
+++ linux-2.6.4/arch/ia64/Makefile	2004-03-15 22:18:06.000000000 -0800
@@ -37,6 +37,12 @@
 		ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
 endif
 
+ifneq ($(findstring -DHAVE_BUGGY_SEGREL,$(CPPFLAGS)),)
+$(error Sorry, you need a newer version of binutils, one that is built from	\
+	a source-tree that post-dates 17-Jul-2003.  binutils-2.14.90.0.8 is	\
+	known to work)
+endif
+
 ifeq ($(GCC_VERSION),2)
 $(error Sorry, your compiler is too old.  GCC v2.96 is known to generate bad code.)
 endif
Index: linux-2.6.4/arch/ia64/kernel/gate.lds.S
=================================--- linux-2.6.4.orig/arch/ia64/kernel/gate.lds.S	2004-03-10 18:55:24.000000000 -0800
+++ linux-2.6.4/arch/ia64/kernel/gate.lds.S	2004-03-15 21:21:02.000000000 -0800
@@ -46,12 +46,8 @@
   }									:readable
   .IA_64.unwind_info		: { *(.IA_64.unwind_info*) }
   .IA_64.unwind			: { *(.IA_64.unwind*) }			:readable :unwind
-#ifdef HAVE_BUGGY_SEGREL
-  .text (GATE_ADDR + PAGE_SIZE)	: { *(.text) *(.text.*) }		:readable
-#else
   . = ALIGN (PERCPU_PAGE_SIZE) + (. & (PERCPU_PAGE_SIZE - 1));
   .text				: { *(.text) *(.text.*) }		:epc
-#endif
 
   /DISCARD/			: {
   	*(.got.plt) *(.got)
@@ -69,9 +65,7 @@
 PHDRS
 {
   readable  PT_LOAD	FILEHDR	PHDRS	FLAGS(4);	/* PF_R */
-#ifndef HAVE_BUGGY_SEGREL
   epc	    PT_LOAD	FILEHDR PHDRS	FLAGS(1);	/* PF_X */
-#endif
   dynamic   PT_DYNAMIC			FLAGS(4);	/* PF_R */
   unwind    0x70000001; /* PT_IA_64_UNWIND, but ld doesn't match the name */
 }
Index: linux-2.6.4/arch/ia64/mm/init.c
=================================--- linux-2.6.4.orig/arch/ia64/mm/init.c	2004-03-10 18:55:26.000000000 -0800
+++ linux-2.6.4/arch/ia64/mm/init.c	2004-03-15 21:21:18.000000000 -0800
@@ -265,12 +265,7 @@
 	 */
 	page = virt_to_page(ia64_imva(__start_gate_section));
 	put_kernel_page(page, GATE_ADDR, PAGE_READONLY);
-#ifdef HAVE_BUGGY_SEGREL
-	page = virt_to_page(ia64_imva(__start_gate_section + PAGE_SIZE));
-	put_kernel_page(page, GATE_ADDR + PAGE_SIZE, PAGE_GATE);
-#else
 	put_kernel_page(page, GATE_ADDR + PERCPU_PAGE_SIZE, PAGE_GATE);
-#endif
 	ia64_patch_gate();
 }
 

