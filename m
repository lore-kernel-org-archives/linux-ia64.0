From: Bill Nottingham <notting@redhat.com>
Date: Thu, 24 Jan 2002 02:40:09 +0000
Subject: Re: [Linux-ia64] patch for vmlinux.lds.S
Message-Id: <marc-linux-ia64-105590698805922@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805920@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805920@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens (kaos@ocs.com.au) said: 
> On Wed, 23 Jan 2002 21:23:32 -0500, 
> Bill Nottingham <notting@redhat.com> wrote:
> >This fixes building the kernel for me; possibly a recent binutils
> >thing? (Otherwise, I'm getting dangling references to the
> >text.exit code in .IA_64.unwind.text.exit sections.)
> 
> Which binutils?

2.11.92.0.12 + patches.

> What does "objdump -h init/main.o vmlinux" report?

init/main.o:     file format elf64-ia64-little

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         00000740  0000000000000000  0000000000000000  00000040  2**5
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data         00000108  0000000000000000  0000000000000000  00000780  2**3
                  CONTENTS, ALLOC, LOAD, RELOC, DATA
  2 .bss          00000000  0000000000000000  0000000000000000  00000888  2**0
                  ALLOC
  3 .rodata.str1.8 00000708  0000000000000000  0000000000000000  00000888  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .sdata        00000020  0000000000000000  0000000000000000  00000f90  2**3
                  CONTENTS, ALLOC, LOAD, DATA, SMALL_DATA
  5 .text.init    000013c0  0000000000000000  0000000000000000  00000fc0  2**5
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  6 .IA_64.unwind_info.text.init 00000130  0000000000000000  0000000000000000  00002380  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .IA_64.unwind.text.init 000000f0  0000000000000000  0000000000000000  000024b0  2**3
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA
  8 .data.init    00000708  0000000000000000  0000000000000000  000025a0  2**3
                  CONTENTS, ALLOC, LOAD, RELOC, DATA
  9 .setup.init   00000060  0000000000000000  0000000000000000  00002ca8  2**3
                  CONTENTS, ALLOC, LOAD, RELOC, DATA
 10 .IA_64.unwind_info 00000078  0000000000000000  0000000000000000  00002d08  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 11 .IA_64.unwind 00000060  0000000000000000  0000000000000000  00002d80  2**3
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA
 12 .comment      00000039  0000000000000000  0000000000000000  00002de0  2**0
                  CONTENTS, READONLY

vmlinux:     file format elf64-ia64-little

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         00411d00  e000000004400000  0000000004400000  00010000  2**15
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .text.lock    00003480  e000000004811d00  0000000004811d00  00421d00  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  2 __ex_table    00001d98  e000000004815180  0000000004815180  00425180  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 __ksymtab     00005070  e000000004816f18  0000000004816f18  00426f18  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .IA_64.unwind_info 00023c18  e00000000481bf88  000000000481bf88  0042bf88  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .IA_64.unwind 0001b9f0  e00000000483fba0  000000000483fba0  0044fba0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .rodata       000311f5  e00000000485b590  000000000485b590  0046b590  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .kstrtab      0000a5a0  e00000000488c788  000000000488c788  0049c788  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  8 .opd          000097c0  e000000004896d30  0000000004896d30  004a6d30  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  9 .text.init    00029ce0  e0000000048a4000  00000000048a4000  004b4000  2**5
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 10 .data.init    000307c8  e0000000048cdce0  00000000048cdce0  004ddce0  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 11 .setup.init   00000270  e0000000048fe4b0  00000000048fe4b0  0050e4b0  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 12 .initcall.init 00000150  e0000000048fe720  00000000048fe720  0050e720  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 13 init_task     00008000  e000000004900000  0000000004900000  00510000  2**4
                  CONTENTS, ALLOC, LOAD, DATA
 14 .data.cacheline_aligned 00032dc0  e000000004908000  0000000004908000  00518000  2**6
                  CONTENTS, ALLOC, LOAD, DATA
 15 .data         000dd3b8  e00000000493adc0  000000000493adc0  0054adc0  2**6
                  CONTENTS, ALLOC, LOAD, DATA
 16 .got          0000d1c8  e000000004a18178  0000000004a18178  00628178  2**3
                  CONTENTS, ALLOC, LOAD, DATA, SMALL_DATA
 17 .sdata        00000b44  e000000004a25340  0000000004a25340  00635340  2**3
                  CONTENTS, ALLOC, LOAD, DATA, SMALL_DATA
 18 .sbss         00000748  e000000004a25e88  0000000004a25e88  00635e88  2**3
                  ALLOC, SMALL_DATA
 19 .bss          0006df30  e000000004a265d0  0000000004a25e88  00635e88  2**4
                  ALLOC

Bill

