From: Keith Owens <kaos@sgi.com>
Date: Wed, 17 Mar 2004 22:46:32 +0000
Subject: Re: 2.6.3 Heisenbug in unwind.c
Message-Id: <6631.1079563592@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <2654.1077624337@ocs3.ocs.com.au>
In-Reply-To: <2654.1077624337@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 16 Mar 2004 21:41:29 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>Yes, that basically looks good.  I do think you have to change the
>order to this:
>
>PHDRS {
>  code   PT_LOAD;
>  percpu PT_LOAD;
>  data   PT_LOAD;
>}
>
>to avoid extra padding, though.

Done.

Index: linux-2.6.4/arch/ia64/kernel/vmlinux.lds.S
=================================--- linux-2.6.4.orig/arch/ia64/kernel/vmlinux.lds.S	Mon Mar 15 10:14:58 2004
+++ linux-2.6.4/arch/ia64/kernel/vmlinux.lds.S	Wed Mar 17 14:44:14 2004
@@ -12,6 +12,11 @@
 OUTPUT_ARCH(ia64)
 ENTRY(phys_start)
 jiffies = jiffies_64;
+PHDRS {
+  code   PT_LOAD;
+  percpu PT_LOAD;
+  data   PT_LOAD;
+}
 SECTIONS
 {
   /* Sections to be discarded */
@@ -27,6 +32,7 @@
   v = PAGE_OFFSET;	/* this symbol is here to make debugging easier... */
   phys_start = _start - LOAD_OFFSET;
 
+  code : { } :code
   . = KERNEL_START;
 
   _text = .;
@@ -180,6 +186,7 @@
         { *(.data.cacheline_aligned) }
 
   /* Per-cpu data: */
+  percpu : { } :percpu
   . = ALIGN(PERCPU_PAGE_SIZE);
   __phys_per_cpu_start = .;
   .data.percpu PERCPU_ADDR : AT(__phys_per_cpu_start - LOAD_OFFSET)
@@ -190,6 +197,7 @@
 	}
   . = __phys_per_cpu_start + PERCPU_PAGE_SIZE;	/* ensure percpu data fits into percpu page size */
 
+  data : { } :data
   .data : AT(ADDR(.data) - LOAD_OFFSET)
 	{ *(.data) *(.data1) *(.gnu.linkonce.d*) CONSTRUCTORS }
 
@@ -212,6 +220,7 @@
 
   _end = .;
 
+  code : { } :code
   /* Stabs debugging sections.  */
   .stab 0 : { *(.stab) }
   .stabstr 0 : { *(.stabstr) }


Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000010000 0xa000000100000000 0x0000000004000000
                 0x0000000000730d00 0x0000000000730d00  RWE    10000
  LOAD           0x0000000000750000 0xffffffffffff0000 0x0000000004740000
                 0x0000000000009278 0x0000000000009278  RW     10000
  LOAD           0x0000000000760000 0xa000000100750000 0x0000000004750000
                 0x000000000017e238 0x000000000036bf00  RW     10000
  IA_64_UNWIND   0x0000000000618c48 0xa000000100608c48 0x0000000004608c48
                 0x0000000000034758 0x0000000000034758  R      8

 Section to Segment mapping:
  Segment Sections...
   00     .text __ex_table .data.patch.vtop .data.patch.mckinley_e9 .IA_64.unwind_info .IA_64.unwind .rodata __ksymtab __ksymtab_gpl __kcrctab __kcrctab_gpl __ksymtab_strings .opd .init.text .init.data .init.ramfs .init.setup .kdb_initcall.init __param .initcall.init .con_initcall.init .data.init_task .data.page_aligned .data.cacheline_aligned 
   01     .data.percpu 
   02     .data .got .sdata .sbss .bss 
   03     .IA_64.unwind 

>Also, what happens for the case that was giving you grief in the first
>place?  Does the linker report an error or does it actually do the
>right thing?

It does the right thing.  The load map and section to segment mapping
above is from my test case, without PHDR it puts .init.text in a
separate segment.

>I guess I'm wondering why the linker decided to put it
>into a different segment in the first place.

The only difference is the size of the input objects, literally a
single extra nop bundle in one object is enough to trip the error case.
Also add -q to ld makes the problem disappear.  I am assuming that the
size difference on input is enough to affect one of the linker's
hashing algorithms.  That in turn lets the linker see a difference
between

  { .text __ex_table .data.patch.vtop .data.patch.mckinley_e9
  .IA_64.unwind_info .IA_64.unwind .rodata __ksymtab __ksymtab_gpl
  __kcrctab __kcrctab_gpl __ksymtab_strings .opd }

which it puts in a 'R E' segment and these sections

  { .init.text .init.data .init.ramfs .init.setup .kdb_initcall.init
  __param .initcall.init .con_initcall.init .data.init_task
  .data.page_aligned .data.cacheline_aligned }

which are marked 'RWE'.  In the normal case all those sections are in a
single RWE segment.

