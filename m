From: Richard Henderson <rth@twiddle.net>
Date: Tue, 17 Dec 2002 01:32:38 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805586@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 17, 2002 at 12:14:43PM +1100, Rusty Russell wrote:
> Well, yes, something is wrong with the relocations.  The asm there
> looks OK (assuming I'm reading it correctly, which is not guaranteed),
> and I thought I put everything in the right place, but obviously not
> 8(  After two days on and off of trying to get ia64 to work, I passed
> the buck. 8(

Found it.  First, some general fixes, attached.  

The remaining problem is that you're confusing the code address of a
symbol as seen via the module's local symbol table, and the descriptor
address as seen via EXPORT_SYMBOL from another module.

This makes

+			fixup_plt(location, value);

incorrect for local symbols.  Which can be seen when the call to
function() crashes.

You're going to have to distinguish between symbols retrieved from 
the local symbol table and symbols retrieved from EXPORT_SYMBOL, and
treat them differently in the IPLT case.



r~



diff -rup module-test-framework/Makefile module-test-framework.rth/Makefile
--- module-test-framework/Makefile	Mon Dec 16 20:23:55 2002
+++ module-test-framework.rth/Makefile	Mon Dec 16 19:32:49 2002
@@ -35,7 +35,7 @@ KCCFLAGS_sparc64:=-m64
 KLDFLAGS_sparc:=-N #-Bsymbolic
 KCCFLAGS_sparc: 
-KLDFLAGS_ia64:+KLDFLAGS_ia64:= -N
 KCCFLAGS_ia64:=#-fPIC
 
 KLDFLAGS_arm:=-N #-Bsymbolic
diff -rup module-test-framework/arch-ia64/module.c module-test-framework.rth/arch-ia64/module.c
--- module-test-framework/arch-ia64/module.c	Mon Dec 16 00:33:11 2002
+++ module-test-framework.rth/arch-ia64/module.c	Mon Dec 16 19:41:53 2002
@@ -46,14 +46,6 @@ struct ia64_callout_stub
  	unsigned char plt[16 * 3];
 };
 
-/* Confusingly, the pltoff section referred to by the (generated)
-   .plt, expects descriptors which look like this: */
-struct ia64_plt
-{
-	u64 gp;		/* global pointer */
-	u64 entry;	/* code entry point */
-};
-
 /* We need to create a function descriptor for any internal function
    which is referenced.  ld.so uses the size of the dynamic symbol
    table to allocated them: it does this by assuming the DT_STRTAB
@@ -132,11 +124,12 @@ static u64 calculate_got(struct module *
 	return got;
 }
 
-static void fixup_plt(struct ia64_plt *plt, u64 value)
+static inline void fixup_plt(void *xplt, u64 value)
 {
+	struct ia64_fdesc *plt = xplt;
 	struct ia64_fdesc *fdesc = (void *)value;
-	plt->gp = fdesc->gp;
-	plt->entry = fdesc->entry;
+	
+	*plt = *fdesc;
 }
 
 int apply_relocate(Elf_Rel *rel,
@@ -206,7 +199,7 @@ int apply_relocate_add(Elf_Rela *rela,
 		case R_IA64_IPLTLSB:
 			printk("PLT location %p -> %p\n", location,
 			       (void *)value);
-			fixup_plt((void *)location, value);
+			fixup_plt(location, value);
 			break;
 
 		default:
diff -rup module-test-framework/arch-ia64/module.lds module-test-framework.rth/arch-ia64/module.lds
--- module-test-framework/arch-ia64/module.lds	Mon Dec 16 00:33:11 2002
+++ module-test-framework.rth/arch-ia64/module.lds	Mon Dec 16 20:03:46 2002
@@ -7,15 +7,17 @@ PHDRS {
 
 SECTIONS
 {
+  .text : { *(.text) } :core
+  .plt : { *(.plt) } :core
   .rodata : { *(.rodata) *(.rodata.*) } :core
   .data : { *(.data) CONSTRUCTORS } :core
+  .opd : { *(.opd) } :core
+  .IA_64.unwind_info : { *(.IA_64.unwind_info* .gnu.linkonce.ia64unwi.*) } :core
+  .IA_64.unwind : { *(.IA_64.unwind* .gnu.linkonce.ia64unw.*) } :core
   .got : { *(.got.plt) *(.got) } :core
+  .IA_64.pltoff   : { *(.IA_64.pltoff) }
   .sdata : { *(.sdata) *(.sdata2) } :core
-  /* PLT placed incorrectly if moved after common. --RR */
-  .plt : { *(.plt) } :core
   .sbss : { *(.sbss) *(.dynsbss) *(.scommon) } :core
-  .text : { *(.text) } :core
-  .IA_64.unwind : { *(.IA_64.unwind*) } :core
 
   /* Generated module information */
   __ex_table : { 
@@ -59,6 +61,9 @@ SECTIONS
   .hash : { *(.hash) } :init
   .dynsym : { *(.dynsym) } :init
   .dynstr : { *(.dynstr) } :init
+  .gnu.version    : { *(.gnu.version) } :init
+  .gnu.version_d  : { *(.gnu.version_d) } :init
+  .gnu.version_r  : { *(.gnu.version_r) } :init
 
   /* .rela.IA_64.pltoff needs its own section, which means no wildcards. */
   .rela.dyn :
@@ -91,6 +96,7 @@ SECTIONS
   .rela.IA_64.pltoff : { *(.rela.IA_64.pltoff) } :init
 
   /* For some reason, this needs to be in init too? */
+  /* Of course.  It has to be loaded.  */
   .dynamic : { *(.dynamic) }  :init :dyn
 
   /* Buggy lds drop random sections in the last mentioned segment. */

