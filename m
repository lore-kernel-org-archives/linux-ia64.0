From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 03 Jan 2002 00:27:14 +0000
Subject: [Linux-ia64] [piet@sgi.com: Re: kgdb internet/ethernet support and {gcc or gdb} bug on test addresse
Message-Id: <marc-linux-ia64-105590698805728@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

				IA64 GCC/GDB BUG
				=3D=3D=3D=3D=3D=3D=3D=3D


I'm having trouble with GDB on ia64/sn with addresses in the text segment.
Pointers to functions are being reported wrong. I tried changing to the lat=
est
gcc and gdb but it hasn't helped. The actual address for a function will be
0x2000000000037fa8 but it will be reported as 0x4000000000059ee0 for a large
program or just slightly for a small program as illustrated below. I wonder=
 if
our kernel could be the cause possibly using:

			gdb+ddd
			-------
			  gdb
			------
			 test

and watch the kernel systems calls. I've asked the GNU news group on gdb bu=
gs and
some of the guys hacking on gdb a lot but didn't hear back from anyone yet.=
 I thought
it might be resoanble to see what the srn@engr.sgi.com abd linux-ia64@linux=
ia64.org=20
folks think.

---------------------------------------------------------------------------=
--------
	   gcc version 3.0.2	gdb Red Hat Linux 7.x	(Also in gdb 5.1)
---------------------------------------------------------------------------=
--------


---------------------------------------------------------------------------=
--------
				Simple Test Program Showing Bug
---------------------------------------------------------------------------=
--------
#include <stdio.h>


typedef struct disassemble_info {
        void (*fprintf_func)();
} disassemble_info_t;

disassemble_info_t disinfo;

void my_printf(void)
{
        (void) printf("Hello World\n");
}

main(void)
{
        disinfo.fprintf_func =3D my_printf;
        printf("my_printf is at 0x%llx.\n", my_printf);
        printf("disinfo is at 0x%llx.\n", &disinfo);
        disinfo.fprintf_func();
}
---------------------------------------------------------------------------=
-----

---------------------------------------------------------------------------=
-----
				Test Program Output
---------------------------------------------------------------------------=
-----
320 monica 18:01 ~/src> ./test
    my_printf is at 0x40000000000007e0.
    disinfo is at   0x6000000000000af8.
    Hello World
321 monica 18:01 ~/src>
---------------------------------------------------------------------------=
-----------

---------------------------------------------------------------------------=
--------------
	In GDB the Code Appears Offset 40000000000007E0-4000000000000560 =3D 0x280=
 =3D 640.0
---------------------------------------------------------------------------=
--------------
(gdb) disassemble my_printf
Dump of assembler code for function my_printf:
0x4000000000000560 <my_printf>: 	[MII]       alloc r34=3Dar.pfs,5,4,0
0x4000000000000561 <my_printf+1>:                   mov r35=3Dr12
0x4000000000000562 <my_printf+2>:                   mov r33=B0
0x4000000000000570 <my_printf+16>:      [MMI]       addl r14=80,r1;;
0x4000000000000571 <my_printf+17>:                  ld8 r36=3D[r14]
0x4000000000000572 <my_printf+18>:                  mov r32=3Dr1
0x4000000000000580 <my_printf+32>:      [MFB]       nop.m 0x0
0x4000000000000581 <my_printf+33>:                  nop.f 0x0
0x4000000000000582 <my_printf+34>:                  br.call.sptk.many b0=3D=
0x4000000000000400 <_init+272>;;
0x4000000000000590 <my_printf+48>:      [MII]       mov r1=3Dr32
0x4000000000000591 <my_printf+49>:                  mov.i ar.pfs=3Dr34
0x4000000000000592 <my_printf+50>:                  mov b0=3Dr33
0x40000000000005a0 <my_printf+64>:      [MFB]       mov r12=3Dr35
0x40000000000005a1 <my_printf+65>:                  nop.f 0x0
0x40000000000005a2 <my_printf+66>:                  br.ret.sptk.many b0;;
End of assembler dump.
---------------------------------------------------------------------------=
-----
(gdb) print disinfo.fprintf_func
$1 =3D (void (*)()) 0x40000000000007e0 <_fini+192>
---------------------------------------------------------------------------=
-----
Dump of assembler code for function _fini:
0x4000000000000720 <_fini>:     [MII]       alloc r34=3Dar.pfs,3,3,0
0x4000000000000721 <_fini+1>:               mov r32=3Dr12
0x4000000000000722 <_fini+2>:               mov r33=B0
0x4000000000000730 <_fini+16>:  [MFB]       adds r12=3D-16,r12
0x4000000000000731 <_fini+17>:              nop.f 0x0
0x4000000000000732 <_fini+18>:              nop.b 0x0;;
0x4000000000000740 <_fini+32>:  [MLX]       nop.m 0x0
0x4000000000000741 <_fini+33>:              movl r2=3D0xfffffffffffffd90
0x4000000000000750 <_fini+48>:  [MII]       nop.m 0x0
0x4000000000000751 <_fini+49>:              mov r3=3Dip;;
0x4000000000000752 <_fini+50>:              add r2=3Dr2,r3;;
0x4000000000000760 <_fini+64>:  [MIB]       nop.m 0x0
0x4000000000000761 <_fini+65>:              mov b6=3Dr2
0x4000000000000762 <_fini+66>:              br.call.sptk.many b0=B6;;
0x4000000000000770 <_fini+80>:  [MII]       mov r12=3Dr32
0x4000000000000771 <_fini+81>:              mov.i ar.pfs=3Dr34
0x4000000000000772 <_fini+82>:              mov b0=3Dr33
0x4000000000000780 <_fini+96>:  [MFB]       nop.m 0x0
0x4000000000000781 <_fini+97>:              nop.f 0x0
0x4000000000000782 <_fini+98>:              br.ret.sptk.many b0;;
0x4000000000000790 <_fini+112>: [MMI]       data8 0x1037b63632a
0x4000000000000791 <_fini+113>:       (p28) cmp.le.and p53,p54=3Dr0,r28
0x4000000000000792 <_fini+114>:       (p20) break.i 0x0
0x40000000000007a0 <_fini+128>: [MFI]       data8 0x14b9382fbcb
0x40000000000007a1 <_fini+129>:       (p57) fnma.d.s1 f70=F25,f16,f78
0x40000000000007a2 <_fini+130>:             data8 0x40e8c240e6
0x40000000000007b0 <_fini+144>: [MIB] (p01) cmp.eq.or.andcm p47,p44=3Dr9,r54
0x40000000000007b1 <_fini+145>:       (p57) break.i 0xa2
0x40000000000007b2 <_fini+146>:             break.b 0x0
0x40000000000007c0 <_fini+160>: [MLX] (p11) mov r109=3D-1231012
0x40000000000007c1 <_fini+161>:             data8 0xf06040e8c2
0x40000000000007d0 <_fini+176>: [MLX]       data8 0x5173c36361
0x40000000000007d1 <_fini+177>:             break.x 0x0;;
0x40000000000007e0 <_fini+192>: [MII] (p43) break.m 0x0				<<<-------- Poin=
ts Here
0x40000000000007e1 <_fini+193>:             data8 0x023e10000
0x40000000000007e2 <_fini+194>:             data8 0xc000000000
0x40000000000007f0 <_fini+208>: [MIB] (p23) break.m 0x0
0x40000000000007f1 <_fini+209>:             data8 0x023e10000
0x40000000000007f2 <_fini+210>:             data8 0xc000000000
0x4000000000000800 <_fini+224>: [MIB] (p45) break.m 0x0
0x4000000000000801 <_fini+225>:             data8 0x023e10000
0x4000000000000802 <_fini+226>:             data8 0xc000000000
0x4000000000000810 <_fini+240>: [MII] (p57) break.m 0x0
0x4000000000000811 <_fini+241>:             data8 0x023e10000
0x4000000000000812 <_fini+242>:             data8 0xc000000000
0x4000000000000820 <_fini+256>: [MII]       break.m 0x0
0x4000000000000821 <_fini+257>:             break.i 0x0
0x4000000000000822 <_fini+258>:             break.i 0x0
End of assembler dump.
---------------------------------------------------------------------------=
-----

---------------------------------------------------------------------------=
-----
Dump of assembler code for function main:
0x40000000000005b0 <main>:      [MII]       alloc r34=3Dar.pfs,6,4,0
0x40000000000005b1 <main+1>:                mov r35=3Dr12
0x40000000000005b2 <main+2>:                adds r12=3D-16,r12
0x40000000000005c0 <main+16>:   [MII]       nop.m 0x0
0x40000000000005c1 <main+17>:               mov r33=B0
0x40000000000005c2 <main+18>:               addl r142,r1;;
0x40000000000005d0 <main+32>:   [MFI]       ld8 r15=3D[r14]
0x40000000000005d1 <main+33>:               nop.f 0x0
0x40000000000005d2 <main+34>:               addl r14$,r1;;
0x40000000000005e0 <main+48>:   [MMI]       ld8 r14=3D[r14];;
0x40000000000005e1 <main+49>:               st8 [r15]=3Dr14		Stores Result

0x40000000000005e2 <main+50>:               addl r14=88,r1;;
0x40000000000005f0 <main+64>:   [MFI]       ld8 r36=3D[r14]
0x40000000000005f1 <main+65>:               nop.f 0x0
0x40000000000005f2 <main+66>:               addl r14$,r1;;
0x4000000000000600 <main+80>:   [MIB]       ld8 r37=3D[r14]
0x4000000000000601 <main+81>:               mov r32=3Dr1
0x4000000000000602 <main+82>:               br.call.sptk.many b0=3D0x400000=
0000000400 <_init+272>;;
0x4000000000000610 <main+96>:   [MMI]       mov r1=3Dr32;;
0x4000000000000611 <main+97>:               addl r14=96,r1
0x4000000000000612 <main+98>:               nop.i 0x0;;
0x4000000000000620 <main+112>:  [MFI]       ld8 r36=3D[r14]
0x4000000000000621 <main+113>:              nop.f 0x0
0x4000000000000622 <main+114>:              addl r142,r1;;
0x4000000000000630 <main+128>:  [MFB]       ld8 r37=3D[r14]
0x4000000000000631 <main+129>:              nop.f 0x0
0x4000000000000632 <main+130>:              br.call.sptk.many b0=3D0x400000=
0000000400 <_init+272>
0x4000000000000640 <main+144>:  [MMI]       mov r1=3Dr32;;
0x4000000000000641 <main+145>:              addl r152,r1
0x4000000000000642 <main+146>:              nop.i 0x0;;
0x4000000000000650 <main+160>:  [MMI]       ld8 r14=3D[r15];;
0x4000000000000651 <main+161>:              ld8 r14=3D[r14]
0x4000000000000652 <main+162>:              nop.i 0x0;;
0x4000000000000660 <main+176>:  [MFI]       ld8 r15=3D[r14]
0x4000000000000661 <main+177>:              nop.f 0x0
0x4000000000000662 <main+178>:              adds r14=3D8,r14;;
0x4000000000000670 <main+192>:  [MIB]       ld8 r1=3D[r14]
0x4000000000000671 <main+193>:              mov b6=3Dr15
0x4000000000000672 <main+194>:              br.call.sptk.many b0=B6;;
0x4000000000000680 <main+208>:  [MII]       mov r1=3Dr32
0x4000000000000681 <main+209>:              mov.i ar.pfs=3Dr34
0x4000000000000682 <main+210>:              mov b0=3Dr33
0x4000000000000690 <main+224>:  [MFB]       mov r12=3Dr35
0x4000000000000691 <main+225>:              nop.f 0x0
0x4000000000000692 <main+226>:              br.ret.sptk.many b0;;
---------------------------------------------------------------------------=
-----
objdump --debugging --disassemble-all --reloc --stabs --full-contents --all=
-headers test.o

test.o:     file format elf64-ia64-little
test.o
architecture: ia64-elf64, flags 0x00000011:
HAS_RELOC, HAS_SYMS
start address 0x0000000000000000
private flags =3D LE, ABI64

Sections:
Idx Name          Size      VMA               LMA               File off  A=
lgn
  0 .text         00000140  0000000000000000  0000000000000000  00000040  2=
**4
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data         00000000  0000000000000000  0000000000000000  00000180  2=
**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000000  0000000000000000  0000000000000000  00000180  2=
**0
                  ALLOC
  3 .debug_abbrev 0000015a  0000000000000000  0000000000000000  00000180  2=
**0
                  CONTENTS, READONLY, DEBUGGING
  4 .debug_info   00001255  0000000000000000  0000000000000000  000002da  2=
**0
                  CONTENTS, RELOC, READONLY, DEBUGGING
  5 .debug_line   0000018e  0000000000000000  0000000000000000  0000152f  2=
**0
                  CONTENTS, RELOC, READONLY, DEBUGGING
  6 .rodata       00000048  0000000000000000  0000000000000000  000016c0  2=
**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .IA_64.unwind_info 00000040  0000000000000000  0000000000000000  000017=
08  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  8 .IA_64.unwind 00000030  0000000000000000  0000000000000000  00001748  2=
**3
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA
  9 .debug_pubnames 00000035  0000000000000000  0000000000000000  00001778 =
 2**0
                  CONTENTS, RELOC, READONLY, DEBUGGING
 10 .debug_aranges 00000030  0000000000000000  0000000000000000  000017ad  =
2**0
                  CONTENTS, RELOC, READONLY, DEBUGGING
 11 .comment      00000012  0000000000000000  0000000000000000  000017dd  2=
**0
                  CONTENTS, READONLY
SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 test.c
0000000000000000 l    d  .text  0000000000000000
0000000000000000 l    d  .debug_abbrev  0000000000000000
0000000000000000 l    d  .debug_info    0000000000000000
0000000000000000 l    d  .debug_line    0000000000000000
0000000000000000 l    d  .rodata        0000000000000000
0000000000000000 l    d  .IA_64.unwind_info     0000000000000000
0000000000000000 l    d  .data  0000000000000000
0000000000000000 l    d  .bss   0000000000000000
0000000000000000 l    d  .IA_64.unwind  0000000000000000
0000000000000000 l    d  .debug_pubnames        0000000000000000
0000000000000000 l    d  .debug_aranges 0000000000000000
0000000000000000 l    d  .comment       0000000000000000
0000000000000000 g     F .text  0000000000000000 my_printf
0000000000000000         *UND*  0000000000000000 printf
0000000000000050 g     F .text  0000000000000000 main
0000000000000008       O *COM*  0000000000000008 disinfo
---------------------------------------------------------------------------=
-----
 293 monica 22:16 ~/src> objdump --disassemble-all test.o

test.o:     file format elf64-ia64-little

Disassembly of section .text:

0000000000000000 <my_printf>:
   0:   00 10 15 08 80 05       [MII]       alloc r34=3Dar.pfs,5,4,0
   6:   30 02 30 00 42 20                   mov r35=3Dr12
   c:   04 00 c4 00                         mov r33=B0
  10:   0a 70 00 02 00 24       [MMI]       addl r14=3D0,r1;;
  16:   40 02 38 30 20 00                   ld8 r36=3D[r14]
  1c:   04 08 00 84                         mov r32=3Dr1
  20:   1d 00 00 00 01 00       [MFB]       nop.m 0x0
  26:   00 00 00 02 00 00                   nop.f 0x0
  2c:   08 00 00 50                         br.call.sptk.many b0  <my_print=
f+0x20>;;
  30:   00 08 00 40 00 21       [MII]       mov r1=3Dr32
  36:   00 10 01 55 00 00                   mov.i ar.pfs=3Dr34
  3c:   10 0a 00 07                         mov b0=3Dr33
  40:   1d 60 00 46 00 21       [MFB]       mov r12=3Dr35
  46:   00 00 00 02 00 80                   nop.f 0x0
  4c:   08 00 84 00                         br.ret.sptk.many b0;;

0000000000000050 <main>:
  50:   00 10 19 08 80 05       [MII]       alloc r34=3Dar.pfs,6,4,0
  56:   30 02 30 00 42 80                   mov r35=3Dr12
  5c:   01 67 fc 8c                         adds r12=3D-16,r12
  60:   01 00 00 00 01 00       [MII]       nop.m 0x0
  66:   10 02 00 62 00 c0                   mov r33=B0
  6c:   01 08 00 90                         addl r14=3D0,r1;;
  70:   0d 78 00 1c 18 10       [MFI]       ld8 r15=3D[r14]
  76:   00 00 00 02 00 c0                   nop.f 0x0
  7c:   01 08 00 90                         addl r14=3D0,r1;;
  80:   0b 70 00 1c 18 10       [MMI]       ld8 r14=3D[r14];;
  86:   00 70 3c 30 23 c0                   st8 [r15]=3Dr14
  8c:   01 08 00 90                         addl r14=3D0,r1;;
  90:   0d 20 01 1c 18 10       [MFI]       ld8 r36=3D[r14]
  96:   00 00 00 02 00 c0                   nop.f 0x0
  9c:   01 08 00 90                         addl r14=3D0,r1;;
  a0:   11 28 01 1c 18 10       [MIB]       ld8 r37=3D[r14]
  a6:   00 02 04 00 42 00                   mov r32=3Dr1
  ac:   08 00 00 50                         br.call.sptk.many b0=A0 <main+0=
x50>;;
  b0:   0b 08 00 40 00 21       [MMI]       mov r1=3Dr32;;
  b6:   e0 00 04 00 48 00                   addl r14=3D0,r1
  bc:   00 00 04 00                         nop.i 0x0;;
  c0:   0d 20 01 1c 18 10       [MFI]       ld8 r36=3D[r14]
  c6:   00 00 00 02 00 c0                   nop.f 0x0
  cc:   01 08 00 90                         addl r14=3D0,r1;;
  d0:   1c 28 01 1c 18 10       [MFB]       ld8 r37=3D[r14]
  d6:   00 00 00 02 00 00                   nop.f 0x0
  dc:   08 00 00 50                         br.call.sptk.many b0=D0 <main+0=
x80>
  e0:   0b 08 00 40 00 21       [MMI]       mov r1=3Dr32;;
  e6:   f0 00 04 00 48 00                   addl r15=3D0,r1
  ec:   00 00 04 00                         nop.i 0x0;;
  f0:   0b 70 00 1e 18 10       [MMI]       ld8 r14=3D[r15];;
  f6:   e0 00 38 30 20 00                   ld8 r14=3D[r14]
  fc:   00 00 04 00                         nop.i 0x0;;
 100:   0d 78 00 1c 18 10       [MFI]       ld8 r15=3D[r14]
 106:   00 00 00 02 00 c0                   nop.f 0x0
 10c:   81 70 00 84                         adds r14=3D8,r14;;
 110:   11 08 00 1c 18 10       [MIB]       ld8 r1=3D[r14]
 116:   60 78 04 80 03 00                   mov b6=3Dr15
 11c:   68 00 00 10                         br.call.sptk.many b0=B6;;
 120:   00 08 00 40 00 21       [MII]       mov r1=3Dr32
 126:   00 10 01 55 00 00                   mov.i ar.pfs=3Dr34
 12c:   10 0a 00 07                         mov b0=3Dr33
 130:   1d 60 00 46 00 21       [MFB]       mov r12=3Dr35
 136:   00 00 00 02 00 80                   nop.f 0x0
 13c:   08 00 84 00                         br.ret.sptk.many b0;;
Disassembly of section .data:
Disassembly of section .rodata:

0000000000000000 <.rodata>:
   0:   48 65 6c 6c 6f 20       [MMI]       data8 0x1037b63632a
   6:   57 6f 72 6c 64 0a             (p28) cmp.le.and p53,p54=3Dr0,r28
   c:   00 00 00 00                   (p20) break.i 0x0
  10:   6d 79 5f 70 72 69       [MFI]       data8 0x14b9382fbcb
  16:   6e 74 66 20 69 73             (p57) fnma.d.s1 f70=F25,f16,f78
  1c:   20 61 74 20                         data8 0x40e8c240e6
  20:   30 78 25 6c 6c 78       [MIB] (p01) cmp.eq.or.andcm p47,p44=3Dr9,r54
  26:   2e 0a 00 00 00 00             (p57) break.i 0xa2
  2c:   00 00 00 00                         break.b 0x0
  30:   64 69 73 69 6e 66       [MLX] (p11) mov r109=3D-1231012
  36:   6f 20 69 73 20 61                   data8 0xf06040e8c2
  3c:   74 20 30 78
  40:   Address 0x40 is out of bounds.

Disassembly of section .IA_64.unwind_info:

0000000000000000 <.IA_64.unwind_info>:
   0:   02 00 00 00 00 00       [MII]       break.m 0x0
   6:   01 00 47 21 03 e6                   data8 0xc851c0004
   c:   00 e1 01 e4                   (p12) cmp.eq p7,p0=16,r60
  10:   02 2c c0 02 00 00       [MII] (p32) break.m 0x5805
        ...
  1e:   00 00 02 00                         break.i 0x0
  22:   00 00 00 00 01 00       [MII]       break.m 0x0
  28:   47 21 05 e6 00 e1             (p04) mov pr.rot=3D0xfffffa1470000000=
;;
  2e:   01 e4 04 61                   (p12) cmp.eq p7,p0=16,r60
  32:   28 c0 02 00 00 00       [MLX]       data8 0x016014308
        ...
Disassembly of section .IA_64.unwind:

0000000000000000 <.IA_64.unwind>:
        ...
 294 monica 22:16 ~/src>
---------------------------------------------------------------------------=
-----
 295 monica 22:16 ~/src>  objdump --disassemble-all test

test:     file format elf64-ia64-little

Disassembly of section .interp:

40000000000001c8 <.interp>:
40000000000001c8:       Address 0x1c0 is out of bounds.

Disassembly of section .note.ABI-tag:

40000000000001e0 <.note.ABI-tag>:
40000000000001e0:       04 00 00 00 10 00       [MLX]       invala
40000000000001e6:       00 00 01 00 00 00                   data8 0x0aa9c8e=
00
40000000000001ec:       47 4e 55 00
40000000000001f0:       00 00 00 00 02 00       [MII]       data8 0x0100000=
00
40000000000001f6:       00 00 04 00 00 00                   break.i 0x4000
40000000000001fc:       00 00 00 00                         break.i 0x0
Disassembly of section .hash:

4000000000000200 <.hash>:
4000000000000200:       03 00 00 00 03 00       [MII]       data8 0x0180000=
00
4000000000000206:       00 00 00 00 00 00                   break.i 0x0;;
400000000000020c:       02 00 00 00                         break.i 0x10;;
4000000000000210:       01 00 00 00 00 00       [MII]       break.m 0x0
        ...
Disassembly of section .dynsym:

4000000000000220 <.dynsym>:
        ...
4000000000000238:       0d 00 00 00 12 00                   break.i 0xd000
        ...
400000000000024e:       00 00 14 00                         break.i 0x0
4000000000000252:       00 00 12 00 00 00       [-a-]       data8 0x0900000=
00
        ...
Disassembly of section .dynstr:

4000000000000268 <.dynstr>:
4000000000000268:       Address 0x260 is out of bounds.

Disassembly of section .gnu.version:

4000000000000298 <.gnu.version>:
4000000000000298:       Address 0x290 is out of bounds.

Disassembly of section .gnu.version_r:

40000000000002a0 <.gnu.version_r>:
40000000000002a0:       01 00 01 00 01 00       [MII]       nop.m 0x20
40000000000002a6:       00 00 10 00 00 00                   break.i 0x10000
40000000000002ac:       00 00 00 00                         break.i 0x0;;
40000000000002b0:       12 69 69 0d 00 00       [MBB] (p08) break.m 0x1ad2d
40000000000002b6:       02 00 26 00 00 00             (p08) break.b 0x26000
40000000000002bc:       00 00 00 00                         break.b 0x0
Disassembly of section .rela.IA_64.pltoff:

40000000000002c0 <.rela.IA_64.pltoff>:
40000000000002c0:       d0 0a 00 00 00 00       [MIB] (p22) break.m 0x1
40000000000002c6:       00 60 81 00 00 00                   break.i 0x81600
40000000000002cc:       01 00 00 00                         break.b 0x8
        ...
40000000000002d8:       e0 0a 00 00 00 00                   data8 0x02b8000=
00
40000000000002de:       00 60 81 00                         data8 0xc000000=
000
40000000000002e2:       00 00 02 00 00 00       [MII]       data8 0x0100000=
04
        ...
Disassembly of section .init:

40000000000002f0 <_init>:
40000000000002f0:       00 10 0d 06 80 05       [MII]       alloc r34=3Dar.=
pfs,3,3,0
40000000000002f6:       00 02 30 00 42 20                   mov r32=3Dr12
40000000000002fc:       04 00 c4 00                         mov r33=B0
4000000000000300:       0d 60 c0 19 3f 23       [MFI]       adds r12=3D-16,=
r12
4000000000000306:       00 00 00 02 00 c0                   nop.f 0x0
400000000000030c:       81 0c 00 90                         addl r14r,r1;;
4000000000000310:       0a 78 00 1c 18 10       [MMI]       ld8 r15=3D[r14]=
;;
4000000000000316:       60 00 3c 0e 72 00                   cmp.eq p6,p7=3D=
0,r15
400000000000031c:       00 00 04 00                         nop.i 0x0
4000000000000320:       1c 00 00 00 01 00       [MFB]       nop.m 0x0
4000000000000326:       00 00 00 02 00 03                   nop.f 0x0
400000000000032c:       30 00 00 42                   (p06) br.cond.dptk.fe=
w 4000000000000350 <_init+0x60>
4000000000000330:       1d 80 07 18 99 17       [MFB]       st8 [r12]=3Dr1,=
-16
4000000000000336:       00 00 00 02 00 00                   nop.f 0x0
400000000000033c:       08 00 00 50                         br.call.sptk.ma=
ny b0@00000000000330 <_init+0x40>;;
4000000000000340:       0b 60 40 18 00 21       [MMI]       adds r12=16,r12=
;;
4000000000000346:       10 00 30 30 20 00                   ld8 r1=3D[r12]
400000000000034c:       00 00 04 00                         nop.i 0x0;;
4000000000000350:       04 00 00 00 01 00       [MLX]       nop.m 0x0
4000000000000356:       00 00 00 00 00 40                   movl r2=3D0x340
400000000000035c:       00 04 18 60
4000000000000360:       03 00 00 00 01 00       [MII]       nop.m 0x0
4000000000000366:       30 00 00 60 00 40                   mov r3=3Dip;;
400000000000036c:       20 18 00 80                         add r2=3Dr2,r3;;
4000000000000370:       11 00 00 00 01 00       [MIB]       nop.m 0x0
4000000000000376:       60 10 04 80 03 00                   mov b6=3Dr2
400000000000037c:       68 00 00 10                         br.call.sptk.ma=
ny b0=B6;;
4000000000000380:       00 60 00 40 00 21       [MII]       mov r12=3Dr32
4000000000000386:       00 10 01 55 00 00                   mov.i ar.pfs=3D=
r34
400000000000038c:       10 0a 00 07                         mov b0=3Dr33
4000000000000390:       1d 00 00 00 01 00       [MFB]       nop.m 0x0
4000000000000396:       00 00 00 02 00 80                   nop.f 0x0
400000000000039c:       08 00 84 00                         br.ret.sptk.man=
y b0;;
Disassembly of section .plt:

40000000000003a0 <.plt>:
40000000000003a0:       0b 10 00 1c 00 21       [MMI]       mov r2=3Dr14;;
40000000000003a6:       e0 00 08 00 48 00                   addl r14=3D0,r2
40000000000003ac:       00 00 04 00                         nop.i 0x0;;
40000000000003b0:       0b 80 20 1c 18 14       [MMI]       ld8 r16=3D[r14]=
,8;;
40000000000003b6:       10 41 38 30 28 00                   ld8 r17=3D[r14]=
,8
40000000000003bc:       00 00 04 00                         nop.i 0x0;;
40000000000003c0:       11 08 00 1c 18 10       [MIB]       ld8 r1=3D[r14]
40000000000003c6:       60 88 04 80 03 00                   mov b6=3Dr17
40000000000003cc:       60 00 80 00                         br.few b6;;
40000000000003d0:       11 78 00 00 00 24       [MIB]       mov r15=3D0
40000000000003d6:       00 00 00 02 00 00                   nop.i 0x0
40000000000003dc:       d0 ff ff 48                         br.few 40000000=
000003a0 <_init+0xb0>;;
40000000000003e0:       11 78 04 00 00 24       [MIB]       mov r15=3D1
40000000000003e6:       00 00 00 02 00 00                   nop.i 0x0
40000000000003ec:       c0 ff ff 48                         br.few 40000000=
000003a0 <_init+0xb0>;;
        ...
4000000000000400:       0b 78 60 03 03 24       [MMI]       addl r15G2,r1;;
4000000000000406:       00 41 3c 30 28 c0                   ld8 r16=3D[r15]=
,8
400000000000040c:       01 08 00 84                         mov r14=3Dr1;;
4000000000000410:       11 08 00 1e 18 10       [MIB]       ld8 r1=3D[r15]
4000000000000416:       60 80 04 80 03 00                   mov b6=3Dr16
400000000000041c:       60 00 80 00                         br.few b6;;
4000000000000420:       0b 78 a0 03 03 24       [MMI]       addl r15H8,r1;;
4000000000000426:       00 41 3c 30 28 c0                   ld8 r16=3D[r15]=
,8
400000000000042c:       01 08 00 84                         mov r14=3Dr1;;
4000000000000430:       11 08 00 1e 18 10       [MIB]       ld8 r1=3D[r15]
4000000000000436:       60 80 04 80 03 00                   mov b6=3Dr16
400000000000043c:       60 00 80 00                         br.few b6;;
Disassembly of section .text:

4000000000000440 <_start>:
4000000000000440:       04 10 1c 00 80 45       [MLX]       alloc r2=3Dar.p=
fs,7,0,0
4000000000000446:       02 4c 80 09 00 60                   movl r3=3D0x980=
4c0270033f
400000000000044c:       f0 13 1a 60
4000000000000450:       05 10 41 18 00 e1       [MLX]       adds r34=16,r12
4000000000000456:       ff ff ff ff 5f 20                   movl r1=3D0xdff=
ffffffffffb68;;
400000000000045c:       80 f6 db 6f
4000000000000460:       09 08 21 44 18 14       [MMI]       ld8 r33=3D[r34]=
,8
4000000000000466:       a0 00 44 44 08 20                   mov.m r10=3Dar.=
bsp
400000000000046c:       01 00 c0 00                         mov r9=3Dip;;
4000000000000470:       01 00 0c 50 2a 04       [MII]       mov.m ar.fpsr=
=3Dr3
4000000000000476:       10 48 04 0a 40 c0                   sub r1=3Dr9,r1
400000000000047c:       04 61 00 84                         adds r38=16,r12=
;;
4000000000000480:       01 58 00 03 00 24       [MII]       addl r11d,r1
4000000000000486:       00 82 05 00 48 60                   addl r32H,r1
400000000000048c:       84 0a 00 90                         addl r35@,r1;;
4000000000000490:       09 18 00 16 18 10       [MMI]       ld8 r3=3D[r11]
4000000000000496:       00 02 80 30 20 80                   ld8 r32=3D[r32]
400000000000049c:       84 0b 00 90                         addl r36V,r1;;
40000000000004a0:       08 18 01 46 18 10       [MMI]       ld8 r35=3D[r35]
40000000000004a6:       40 02 90 30 20 80                   ld8 r36=3D[r36]
40000000000004ac:       00 00 00 84                         mov r4=3Dr0
40000000000004b0:       10 00 28 06 98 11       [MIB]       st8 [r3]=3Dr10
40000000000004b6:       50 02 20 00 42 00                   mov r37=3Dr8
40000000000004bc:       70 ff ff 58                         br.call.sptk.fe=
w b0@00000000000420 <_init+0x130>
40000000000004c0:       11 00 00 00 00 00       [MIB]       break.m 0x0
40000000000004c6:       00 00 00 02 00 00                   nop.i 0x0
40000000000004cc:       00 00 00 20                         nop.b 0x0;;
40000000000004d0:       0c 00 00 00 01 00       [MFI]       nop.m 0x0
40000000000004d6:       00 00 00 02 00 00                   nop.f 0x0
40000000000004dc:       00 00 04 00                         nop.i 0x0

40000000000004e0 <__do_global_dtors_aux>:
40000000000004e0:       00 18 15 08 80 05       [MII]       alloc r35=3Dar.=
pfs,5,4,0
40000000000004e6:       00 42 06 06 48 20                   addl r32E6,r1
40000000000004ec:       04 00 c4 00                         mov r33=B0
40000000000004f0:       11 10 01 02 00 21       [MIB]       mov r34=3Dr1
40000000000004f6:       00 00 00 02 00 00                   nop.i 0x0
40000000000004fc:       30 00 00 40                         br.few 40000000=
00000520 <__do_global_dtors_aux+0x40>;;
4000000000000500:       09 00 3c 40 98 11       [MMI]       st8 [r32]=3Dr15
4000000000000506:       10 41 40 30 28 00                   ld8 r17=3D[r16]=
,8
400000000000050c:       00 00 04 00                         nop.i 0x0;;
4000000000000510:       10 08 00 20 18 10       [MIB]       ld8 r1=3D[r16]
4000000000000516:       60 88 04 80 03 00                   mov b6=3Dr17
400000000000051c:       68 00 00 10                         br.call.sptk.ma=
ny b0=B6
4000000000000520:       0b 78 00 40 18 10       [MMI]       ld8 r15=3D[r32]=
;;
4000000000000526:       00 41 3c 30 28 00                   ld8 r16=3D[r15]=
,8
400000000000052c:       00 00 04 00                         nop.i 0x0;;
4000000000000530:       1c 00 00 20 06 38       [MFB]       cmp.eq p0,p6=3D=
r0,r16
4000000000000536:       00 00 00 02 00 03                   nop.f 0x0
400000000000053c:       d0 ff ff 48                   (p06) br.cond.sptk.fe=
w 4000000000000500 <__do_global_dtors_aux+0x20>
4000000000000540:       00 08 00 44 00 21       [MII]       mov r1=3Dr34
4000000000000546:       00 08 05 80 03 00                   mov b0=3Dr33
400000000000054c:       30 02 aa 00                         mov.i ar.pfs=3D=
r35
4000000000000550:       17 20 02 00 21 00       [BBB]       br.ret.sptk.man=
y b0
4000000000000556:       00 00 00 00 10 00                   nop.b 0x0
400000000000055c:       00 00 00 20                         nop.b 0x0;;

4000000000000560 <my_printf>:
4000000000000560:       00 10 15 08 80 05       [MII]       alloc r34=3Dar.=
pfs,5,4,0
4000000000000566:       30 02 30 00 42 20                   mov r35=3Dr12
400000000000056c:       04 00 c4 00                         mov r33=B0
4000000000000570:       0a 70 40 03 00 24       [MMI]       addl r14=80,r1;;
4000000000000576:       40 02 38 30 20 00                   ld8 r36=3D[r14]
400000000000057c:       04 08 00 84                         mov r32=3Dr1
4000000000000580:       1d 00 00 00 01 00       [MFB]       nop.m 0x0
4000000000000586:       00 00 00 02 00 00                   nop.f 0x0
400000000000058c:       88 fe ff 58                         br.call.sptk.ma=
ny b0@00000000000400 <_init+0x110>;;
4000000000000590:       00 08 00 40 00 21       [MII]       mov r1=3Dr32
4000000000000596:       00 10 01 55 00 00                   mov.i ar.pfs=3D=
r34
400000000000059c:       10 0a 00 07                         mov b0=3Dr33
40000000000005a0:       1d 60 00 46 00 21       [MFB]       mov r12=3Dr35
40000000000005a6:       00 00 00 02 00 80                   nop.f 0x0
40000000000005ac:       08 00 84 00                         br.ret.sptk.man=
y b0;;

40000000000005b0 <main>:
40000000000005b0:       00 10 19 08 80 05       [MII]       alloc r34=3Dar.=
pfs,6,4,0
40000000000005b6:       30 02 30 00 42 80                   mov r35=3Dr12
40000000000005bc:       01 67 fc 8c                         adds r12=3D-16,=
r12
40000000000005c0:       01 00 00 00 01 00       [MII]       nop.m 0x0
40000000000005c6:       10 02 00 62 00 c0                   mov r33=B0
40000000000005cc:       01 0a 00 90                         addl r142,r1;;
40000000000005d0:       0d 78 00 1c 18 10       [MFI]       ld8 r15=3D[r14]
40000000000005d6:       00 00 00 02 00 c0                   nop.f 0x0
40000000000005dc:       81 09 00 90                         addl r14$,r1;;
40000000000005e0:       0b 70 00 1c 18 10       [MMI]       ld8 r14=3D[r14]=
;;
40000000000005e6:       00 70 3c 30 23 c0                   st8 [r15]=3Dr14
40000000000005ec:       81 0d 00 90                         addl r14=88,r1;;
40000000000005f0:       0d 20 01 1c 18 10       [MFI]       ld8 r36=3D[r14]
40000000000005f6:       00 00 00 02 00 c0                   nop.f 0x0
40000000000005fc:       81 09 00 90                         addl r14$,r1;;
4000000000000600:       11 28 01 1c 18 10       [MIB]       ld8 r37=3D[r14]
4000000000000606:       00 02 04 00 42 00                   mov r32=3Dr1
400000000000060c:       08 fe ff 58                         br.call.sptk.ma=
ny b0@00000000000400 <_init+0x110>;;
4000000000000610:       0b 08 00 40 00 21       [MMI]       mov r1=3Dr32;;
4000000000000616:       e0 00 07 00 48 00                   addl r14=96,r1
400000000000061c:       00 00 04 00                         nop.i 0x0;;
4000000000000620:       0d 20 01 1c 18 10       [MFI]       ld8 r36=3D[r14]
4000000000000626:       00 00 00 02 00 c0                   nop.f 0x0
400000000000062c:       01 0a 00 90                         addl r142,r1;;
4000000000000630:       1c 28 01 1c 18 10       [MFB]       ld8 r37=3D[r14]
4000000000000636:       00 00 00 02 00 00                   nop.f 0x0
400000000000063c:       d8 fd ff 58                         br.call.sptk.ma=
ny b0@00000000000400 <_init+0x110>
4000000000000640:       0b 08 00 40 00 21       [MMI]       mov r1=3Dr32;;
4000000000000646:       f0 00 05 00 48 00                   addl r152,r1
400000000000064c:       00 00 04 00                         nop.i 0x0;;
4000000000000650:       0b 70 00 1e 18 10       [MMI]       ld8 r14=3D[r15]=
;;
4000000000000656:       e0 00 38 30 20 00                   ld8 r14=3D[r14]
400000000000065c:       00 00 04 00                         nop.i 0x0;;
4000000000000660:       0d 78 00 1c 18 10       [MFI]       ld8 r15=3D[r14]
4000000000000666:       00 00 00 02 00 c0                   nop.f 0x0
400000000000066c:       81 70 00 84                         adds r14=3D8,r1=
4;;
4000000000000670:       11 08 00 1c 18 10       [MIB]       ld8 r1=3D[r14]
4000000000000676:       60 78 04 80 03 00                   mov b6=3Dr15
400000000000067c:       68 00 00 10                         br.call.sptk.ma=
ny b0=B6;;
4000000000000680:       00 08 00 40 00 21       [MII]       mov r1=3Dr32
4000000000000686:       00 10 01 55 00 00                   mov.i ar.pfs=3D=
r34
400000000000068c:       10 0a 00 07                         mov b0=3Dr33
4000000000000690:       1d 60 00 46 00 21       [MFB]       mov r12=3Dr35
4000000000000696:       00 00 00 02 00 80                   nop.f 0x0
400000000000069c:       08 00 84 00                         br.ret.sptk.man=
y b0;;

40000000000006a0 <__do_global_ctors_aux>:
40000000000006a0:       01 20 15 0a 80 05       [MII]       alloc r36=3Dar.=
pfs,5,5,0
40000000000006a6:       00 42 07 00 48 20                   addl r32=104,r1
40000000000006ac:       04 00 c4 00                         mov r33=B0;;
40000000000006b0:       0b 00 01 40 18 10       [MMI]       ld8 r32=3D[r32]=
;;
40000000000006b6:       30 c2 83 32 2c 40                   ld8 r35=3D[r32]=
,-8
40000000000006bc:       04 08 00 84                         mov r34=3Dr1;;
40000000000006c0:       1c 30 fc 47 00 3b       [MFB]       cmp.eq p6,p0=3D=
-1,r35
40000000000006c6:       00 00 00 02 00 03                   nop.f 0x0
40000000000006cc:       40 00 00 41                   (p06) br.cond.spnt.fe=
w 4000000000000700 <__do_global_ctors_aux+0x60>
40000000000006d0:       0a 78 20 46 18 14       [MMI]       ld8 r15=3D[r35]=
,8;;
40000000000006d6:       10 00 8c 30 20 c0                   ld8 r1=3D[r35]
40000000000006dc:       f0 08 00 07                         mov b6=3Dr15
40000000000006e0:       1d 18 e1 41 19 16       [MFB]       ld8 r35=3D[r32]=
,-8
40000000000006e6:       00 00 00 02 00 00                   nop.f 0x0
40000000000006ec:       68 00 00 10                         br.call.sptk.ma=
ny b0=B6;;
40000000000006f0:       1c 00 fc 47 06 3b       [MFB]       cmp.eq p0,p6=3D=
-1,r35
40000000000006f6:       00 00 00 02 00 03                   nop.f 0x0
40000000000006fc:       e0 ff ff 48                   (p06) br.cond.sptk.fe=
w 40000000000006d0 <__do_global_ctors_aux+0x30>
4000000000000700:       00 08 00 44 00 21       [MII]       mov r1=3Dr34
4000000000000706:       00 08 05 80 03 00                   mov b0=3Dr33
400000000000070c:       40 02 aa 00                         mov.i ar.pfs=3D=
r36
4000000000000710:       17 20 02 00 21 00       [BBB]       br.ret.sptk.man=
y b0
4000000000000716:       00 00 00 00 10 00                   nop.b 0x0
400000000000071c:       00 00 00 20                         nop.b 0x0;;
Disassembly of section .fini:

4000000000000720 <_fini>:
4000000000000720:       00 10 0d 06 80 05       [MII]       alloc r34=3Dar.=
pfs,3,3,0
4000000000000726:       00 02 30 00 42 20                   mov r32=3Dr12
400000000000072c:       04 00 c4 00                         mov r33=B0
4000000000000730:       1d 60 c0 19 3f 23       [MFB]       adds r12=3D-16,=
r12
4000000000000736:       00 00 00 02 00 00                   nop.f 0x0
400000000000073c:       00 00 00 20                         nop.b 0x0;;
4000000000000740:       04 00 00 00 01 c0       [MLX]       nop.m 0x0
4000000000000746:       ff ff ff ff 7f 40                   movl r2=3D0xfff=
ffffffffffd90
400000000000074c:       00 f1 ef 6f
4000000000000750:       03 00 00 00 01 00       [MII]       nop.m 0x0
4000000000000756:       30 00 00 60 00 40                   mov r3=3Dip;;
400000000000075c:       20 18 00 80                         add r2=3Dr2,r3;;
4000000000000760:       11 00 00 00 01 00       [MIB]       nop.m 0x0
4000000000000766:       60 10 04 80 03 00                   mov b6=3Dr2
400000000000076c:       68 00 00 10                         br.call.sptk.ma=
ny b0=B6;;
4000000000000770:       00 60 00 40 00 21       [MII]       mov r12=3Dr32
4000000000000776:       00 10 01 55 00 00                   mov.i ar.pfs=3D=
r34
400000000000077c:       10 0a 00 07                         mov b0=3Dr33
4000000000000780:       1d 00 00 00 01 00       [MFB]       nop.m 0x0
4000000000000786:       00 00 00 02 00 80                   nop.f 0x0
400000000000078c:       08 00 84 00                         br.ret.sptk.man=
y b0;;
Disassembly of section .rodata:

4000000000000790 <.rodata>:
4000000000000790:       48 65 6c 6c 6f 20       [MMI]       data8 0x1037b63=
632a
4000000000000796:       57 6f 72 6c 64 0a             (p28) cmp.le.and p53,=
p54=3Dr0,r28
400000000000079c:       00 00 00 00                   (p20) break.i 0x0
40000000000007a0:       6d 79 5f 70 72 69       [MFI]       data8 0x14b9382=
fbcb
40000000000007a6:       6e 74 66 20 69 73             (p57) fnma.d.s1 f70=
=F25,f16,f78
40000000000007ac:       20 61 74 20                         data8 0x40e8c24=
0e6
40000000000007b0:       30 78 25 6c 6c 78       [MIB] (p01) cmp.eq.or.andcm=
 p47,p44=3Dr9,r54
40000000000007b6:       2e 0a 00 00 00 00             (p57) break.i 0xa2
40000000000007bc:       00 00 00 00                         break.b 0x0
40000000000007c0:       64 69 73 69 6e 66       [MLX] (p11) mov r109=3D-123=
1012
40000000000007c6:       6f 20 69 73 20 61                   data8 0xf06040e=
8c2
40000000000007cc:       74 20 30 78
40000000000007d0:       Address 0x7d0 is out of bounds.

Disassembly of section .opd:

40000000000007e0 <.opd>:
40000000000007e0:       60 05 00 00 00 00       [MII] (p43) break.m 0x0
40000000000007e6:       00 40 f8 08 00 00                   data8 0x023e100=
00
40000000000007ec:       00 00 00 60                         data8 0xc000000=
000
40000000000007f0:       f0 02 00 00 00 00       [MIB] (p23) break.m 0x0
40000000000007f6:       00 40 f8 08 00 00                   data8 0x023e100=
00
40000000000007fc:       00 00 00 60                         data8 0xc000000=
000
4000000000000800:       b0 05 00 00 00 00       [MIB] (p45) break.m 0x0
4000000000000806:       00 40 f8 08 00 00                   data8 0x023e100=
00
400000000000080c:       00 00 00 60                         data8 0xc000000=
000
4000000000000810:       20 07 00 00 00 00       [MII] (p57) break.m 0x0
4000000000000816:       00 40 f8 08 00 00                   data8 0x023e100=
00
400000000000081c:       00 00 00 60                         data8 0xc000000=
000
        ...
Disassembly of section .IA_64.unwind_info:

4000000000000830 <.IA_64.unwind_info>:
4000000000000830:       01 00 00 00 00 00       [MII]       break.m 0x0
4000000000000836:       01 00 15 e4 14 b0                   data8 0x5390540=
004
400000000000083c:       84 26 00 00                   (p32) break.i 0x13425=
;;
        ...
4000000000000848:       02 00 00 00 00 00                   break.i 0x2000
400000000000084e:       01 00 47 21                         break.i 0x80000
4000000000000852:       03 e6 00 e1 01 e4       [-3-]       data8 0x1080730=
190a
4000000000000858:       02 2c c0 02 00 00                   data8 0x100b00b=
9007
        ...
4000000000000866:       00 00 02 00 00 00                   break.i 0x2000
400000000000086c:       00 00 01 00                         break.i 0x80000
4000000000000870:       47 21 05 e6 00 e1       [-3-]       data8 0x1080730=
290a
4000000000000876:       01 e4 04 61 28 c0                   data8 0xa184139=
007
400000000000087c:       02 00 00 00                         data8 0x0000005=
80
        ...
Disassembly of section .IA_64.unwind:

4000000000000888 <.IA_64.unwind>:
4000000000000888:       Address 0x880 is out of bounds.

Disassembly of section .data:

60000000000008d0 <__data_start>:
60000000000008d0:       Address 0x8d0 is out of bounds.

Disassembly of section .ctors:

60000000000008d8 <__CTOR_LIST__>:
60000000000008d8:       Address 0x8d0 is out of bounds.


60000000000008e0 <__CTOR_END__>:
        ...
Disassembly of section .dtors:

60000000000008e8 <__DTOR_LIST__>:
60000000000008e8:       Address 0x8e0 is out of bounds.


60000000000008f0 <__DTOR_END__>:
        ...
Disassembly of section .got:

60000000000008f8 <_GLOBAL_OFFSET_TABLE_>:
        ...
6000000000000910:       e0 07 00 00 00 00       [MII] (p63) break.m 0x0
6000000000000916:       00 40 f8 0a 00 00                   data8 0x02be100=
00
600000000000091c:       00 00 00 60                         data8 0xc000000=
000
6000000000000920:       f0 07 00 00 00 00       [MIB] (p63) break.m 0x0
6000000000000926:       00 40 00 08 00 00                   data8 0x0200100=
00
600000000000092c:       00 00 00 40                         br.few 60000000=
00000920 <_GLOBAL_OFFSET_TABLE_+0x28>
6000000000000930:       10 08 00 00 00 00       [MIB]       break.m 0x1
6000000000000936:       00 40 f0 0a 00 00                   data8 0x02bc100=
00
600000000000093c:       00 00 00 60                         data8 0xc000000=
000
        ...
6000000000000948:       90 07 00 00 00 00                   data8 0x01e4000=
00
600000000000094e:       00 40 a0 07                         dep r0=3Dr0,r0,=
63,1
6000000000000952:       00 00 00 00 00 40       [MII] (p61) break.m 0x0
6000000000000958:       c0 07 00 00 00 00                   data8 0x01f0100=
00
600000000000095e:       00 40 d8 08                         dep r0=3Dr0,r0,=
63,1
6000000000000962:       Address 0x960 is out of bounds.

Disassembly of section .dynamic:

6000000000000968 <_DYNAMIC>:
6000000000000968:       Address 0x960 is out of bounds.

Disassembly of section .sdata:

6000000000000ab8 <_IO_stdin_used>:
6000000000000ab8:       Address 0xab0 is out of bounds.


6000000000000ac0 <dtor_ptr>:
6000000000000ac0:       Address 0xac0 is out of bounds.

Disassembly of section .IA_64.pltoff:

6000000000000ad0 <.IA_64.pltoff>:
6000000000000ad0:       d0 03 00 00 00 00       [MIB] (p30) break.m 0x0
6000000000000ad6:       00 40 f8 08 00 00                   data8 0x023e100=
00
6000000000000adc:       00 00 00 60                         data8 0xc000000=
000
6000000000000ae0:       e0 03 00 00 00 00       [MII] (p31) break.m 0x0
6000000000000ae6:       00 40 f8 08 00 00                   data8 0x023e100=
00
6000000000000aec:       00 00 00 60                         data8 0xc000000=
000
 296 monica 22:16 ~/src>
---------------------------------------------------------------------------=
-----

---------------------------------------------------------------------------=
-------------
objdump --debugging --disassemble-all --reloc --stabs --full-contents --all=
-headers test
---------------------------------------------------------------------------=
--------------
test:     file format elf64-ia64-little
test
architecture: ia64-elf64, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x4000000000000440
private flags =3D LE, ABI64

Program Header:
    PHDR off    0x0000000000000040 vaddr 0x4000000000000040 paddr 0x4000000=
000000040 align 2**3
         filesz 0x0000000000000188 memsz 0x0000000000000188 flags r-x
  INTERP off    0x00000000000001c8 vaddr 0x40000000000001c8 paddr 0x4000000=
0000001c8 align 2**0
         filesz 0x0000000000000018 memsz 0x0000000000000018 flags r--
    LOAD off    0x0000000000000000 vaddr 0x4000000000000000 paddr 0x4000000=
000000000 align 2**16
         filesz 0x00000000000008d0 memsz 0x00000000000008d0 flags r-x
    LOAD off    0x00000000000008d0 vaddr 0x60000000000008d0 paddr 0x6000000=
0000008d0 align 2**16
         filesz 0x0000000000000220 memsz 0x0000000000000238 flags rw-
 DYNAMIC off    0x0000000000000968 vaddr 0x6000000000000968 paddr 0x6000000=
000000968 align 2**3
         filesz 0x0000000000000150 memsz 0x0000000000000150 flags rw-
    NOTE off    0x00000000000001e0 vaddr 0x40000000000001e0 paddr 0x4000000=
0000001e0 align 2**2
         filesz 0x0000000000000020 memsz 0x0000000000000020 flags r--
0x70000001 off    0x0000000000000888 vaddr 0x4000000000000888 paddr 0x40000=
00000000888 align 2**3
         filesz 0x0000000000000048 memsz 0x0000000000000048 flags r--

Dynamic Section:
  NEEDED      libc.so.6.1
  INIT        0x40000000000002f0
  FINI        0x4000000000000720
  HASH        0x4000000000000200
  STRTAB      0x4000000000000268
  SYMTAB      0x4000000000000220
  STRSZ       0x26
  SYMENT      0x18
  DEBUG       0x0
  0x70000000  0x60000000000008f8
  PLTGOT      0x60000000000008f8
  PLTRELSZ    0x30
  PLTREL      0x7
  JMPREL      0x40000000000002c0
  RELA        0x40000000000002c0
  RELASZ      0x0
  RELAENT     0x18
  VERNEED     0x40000000000002a0
  VERNEEDNUM  0x1
  VERSYM      0x4000000000000298

Version References:
  required from libc.so.6.1:
    0x0d696912 0x00 02 GLIBC_2.2

Sections:
Idx Name          Size      VMA               LMA               File off  A=
lgn
  0 .interp       00000018  40000000000001c8  40000000000001c8  000001c8  2=
**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .note.ABI-tag 00000020  40000000000001e0  40000000000001e0  000001e0  2=
**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .hash         00000020  4000000000000200  4000000000000200  00000200  2=
**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .dynsym       00000048  4000000000000220  4000000000000220  00000220  2=
**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .dynstr       00000030  4000000000000268  4000000000000268  00000268  2=
**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .gnu.version  00000006  4000000000000298  4000000000000298  00000298  2=
**1
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .gnu.version_r 00000020  40000000000002a0  40000000000002a0  000002a0  =
2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .rela.IA_64.pltoff 00000030  40000000000002c0  40000000000002c0  000002=
c0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  8 .init         000000b0  40000000000002f0  40000000000002f0  000002f0  2=
**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  9 .plt          000000a0  40000000000003a0  40000000000003a0  000003a0  2=
**5
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 10 .text         000002e0  4000000000000440  4000000000000440  00000440  2=
**5
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 11 .fini         00000070  4000000000000720  4000000000000720  00000720  2=
**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 12 .rodata       00000048  4000000000000790  4000000000000790  00000790  2=
**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 13 .opd          00000050  40000000000007e0  40000000000007e0  000007e0  2=
**4
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 14 .IA_64.unwind_info 00000058  4000000000000830  4000000000000830  000008=
30  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 15 .IA_64.unwind 00000048  4000000000000888  4000000000000888  00000888  2=
**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 16 .data         00000004  60000000000008d0  60000000000008d0  000008d0  2=
**2
                  CONTENTS, ALLOC, LOAD, DATA
 17 .ctors        00000010  60000000000008d8  60000000000008d8  000008d8  2=
**3
                  CONTENTS, ALLOC, LOAD, DATA
 18 .dtors        00000010  60000000000008e8  60000000000008e8  000008e8  2=
**3
                  CONTENTS, ALLOC, LOAD, DATA
 19 .got          00000070  60000000000008f8  60000000000008f8  000008f8  2=
**3
                  CONTENTS, ALLOC, LOAD, DATA, SMALL_DATA
 20 .dynamic      00000150  6000000000000968  6000000000000968  00000968  2=
**3
                  CONTENTS, ALLOC, LOAD, DATA
 21 .sdata        00000010  6000000000000ab8  6000000000000ab8  00000ab8  2=
**3
                  CONTENTS, ALLOC, LOAD, DATA, SMALL_DATA
 22 .IA_64.pltoff 00000020  6000000000000ad0  6000000000000ad0  00000ad0  2=
**4
                  CONTENTS, ALLOC, LOAD, DATA, SMALL_DATA
 23 .sbss         00000010  6000000000000af0  6000000000000af0  00000af0  2=
**3
                  ALLOC
 24 .bss          00000008  6000000000000b00  6000000000000b00  00000af0  2=
**3
                  ALLOC
 25 .comment      000000b4  0000000000000000  0000000000000000  00000af0  2=
**0
                  CONTENTS, READONLY
 26 .debug_aranges 00000030  0000000000000000  0000000000000000  00000ba4  =
2**0
                  CONTENTS, READONLY, DEBUGGING
 27 .debug_pubnames 0000005a  0000000000000000  0000000000000000  00000bd4 =
 2**0
                  CONTENTS, READONLY, DEBUGGING
 28 .debug_info   00001fb8  0000000000000000  0000000000000000  00000c2e  2=
**0
                  CONTENTS, READONLY, DEBUGGING
 29 .debug_abbrev 0000024f  0000000000000000  0000000000000000  00002be6  2=
**0
                  CONTENTS, READONLY, DEBUGGING
 30 .debug_line   0000018e  0000000000000000  0000000000000000  00002e35  2=
**0
                  CONTENTS, READONLY, DEBUGGING
SYMBOL TABLE:
40000000000001c8 l    d  .interp	0000000000000000             =20
40000000000001e0 l    d  .note.ABI-tag	0000000000000000             =20
4000000000000200 l    d  .hash	0000000000000000             =20
4000000000000220 l    d  .dynsym	0000000000000000             =20
4000000000000268 l    d  .dynstr	0000000000000000             =20
4000000000000298 l    d  .gnu.version	0000000000000000             =20
40000000000002a0 l    d  .gnu.version_r	0000000000000000             =20
40000000000002c0 l    d  .rela.IA_64.pltoff	0000000000000000             =20
40000000000002f0 l    d  .init	0000000000000000             =20
40000000000003a0 l    d  .plt	0000000000000000             =20
4000000000000440 l    d  .text	0000000000000000             =20
4000000000000720 l    d  .fini	0000000000000000             =20
4000000000000790 l    d  .rodata	0000000000000000             =20
40000000000007e0 l    d  .opd	0000000000000000             =20
4000000000000830 l    d  .IA_64.unwind_info	0000000000000000             =20
4000000000000888 l    d  .IA_64.unwind	0000000000000000             =20
60000000000008d0 l    d  .data	0000000000000000             =20
60000000000008d8 l    d  .ctors	0000000000000000             =20
60000000000008e8 l    d  .dtors	0000000000000000             =20
60000000000008f8 l    d  .got	0000000000000000             =20
6000000000000968 l    d  .dynamic	0000000000000000             =20
6000000000000ab8 l    d  .sdata	0000000000000000             =20
6000000000000ad0 l    d  .IA_64.pltoff	0000000000000000             =20
6000000000000af0 l    d  .sbss	0000000000000000             =20
6000000000000b00 l    d  .bss	0000000000000000             =20
0000000000000000 l    d  .comment	0000000000000000             =20
0000000000000000 l    d  .debug_aranges	0000000000000000             =20
0000000000000000 l    d  .debug_pubnames	0000000000000000             =20
0000000000000000 l    d  .debug_info	0000000000000000             =20
0000000000000000 l    d  .debug_abbrev	0000000000000000             =20
0000000000000000 l    d  .debug_line	0000000000000000             =20
0000000000000000 l    d  *ABS*	0000000000000000             =20
0000000000000000 l    d  *ABS*	0000000000000000             =20
0000000000000000 l    d  *ABS*	0000000000000000             =20
0000000000000000 l    df *ABS*	0000000000000000              /usr/include/a=
sm/fpu.h
0000000000000000 l    df *ABS*	0000000000000000              /usr/include/a=
sm/types.h
0000000000000000 l    df *ABS*	0000000000000000              /usr/include/a=
sm/fpu.h
0000000000000000 l    df *ABS*	0000000000000000              /usr/include/a=
sm/unistd.h
0000000000000000 l    df *ABS*	0000000000000000              /usr/include/a=
sm/unistd.h
0000000000000000 l    df *ABS*	0000000000000000              /usr/include/a=
sm/break.h
0000000000000000 l    df *ABS*	0000000000000000              /usr/include/a=
sm/unistd.h
0000000000000000 l    df *ABS*	0000000000000000              abi-note.S
0000000000000000 l    df *ABS*	0000000000000000              abi-tag.h
0000000000000000 l    df *ABS*	0000000000000000              abi-note.S
0000000000000000 l    df *ABS*	0000000000000000              abi-note.S
0000000000000000 l    df *ABS*	0000000000000000              abi-note.S
0000000000000000 l    df *ABS*	0000000000000000              init.c
0000000000000000 l    df *ABS*	0000000000000000              crti.S
0000000000000000 l    df *ABS*	0000000000000000              defs.h
0000000000000000 l    df *ABS*	0000000000000000              defs.h
0000000000000000 l    df *ABS*	0000000000000000              crti.S
0000000000000000 l    df *ABS*	0000000000000000              initfini.c
0000000000000000 l    df *ABS*	0000000000000000              crti.S
0000000000000000 l    df *ABS*	0000000000000000              crti.S
0000000000000000 l    df *ABS*	0000000000000000              config/ia64/cr=
tend.asm
60000000000008e0 l       .ctors	0000000000000000              __CTOR_END__
60000000000008f0 l       .dtors	0000000000000000              __DTOR_END__
40000000000006a0 l     F .text	0000000000000000              __do_global_ct=
ors_aux
0000000000000000 l    df *ABS*	0000000000000000              crtn.S
0000000000000000 l    df *ABS*	0000000000000000              defs.h
0000000000000000 l    df *ABS*	0000000000000000              defs.h
0000000000000000 l    df *ABS*	0000000000000000              crtn.S
0000000000000000 l    df *ABS*	0000000000000000              initfini.c
0000000000000000 l    df *ABS*	0000000000000000              crtn.S
0000000000000000 l    df *ABS*	0000000000000000              crtn.S
0000000000000000 l    df *ABS*	0000000000000000              config/ia64/cr=
tbegin.asm
60000000000008d8 l       .ctors	0000000000000000              __CTOR_LIST__
60000000000008e8 l       .dtors	0000000000000000              __DTOR_LIST__
6000000000000ac0 l     O .sdata	0000000000000008              dtor_ptr
40000000000004e0 l     F .text	0000000000000000              __do_global_dt=
ors_aux
0000000000000000 l    df *ABS*	0000000000000000              test.c
4000000000000560 g     F .text	0000000000000000              my_printf
6000000000000968 g     O .dynamic	0000000000000000              _DYNAMIC
6000000000000af8 g     O .sbss	0000000000000008              disinfo
0000000000000000       F *UND*	0000000000000000              printf@@GLIBC_=
2.2
40000000000002f0 g     F .init	0000000000000000              _init
4000000000000440 g     F .text	0000000000000000              _start
6000000000000af0 g     O *ABS*	0000000000000000              __bss_start
40000000000005b0 g     F .text	0000000000000000              main
60000000000008d0  w      .data	0000000000000000              data_start
4000000000000720 g     F .fini	0000000000000000              _fini
6000000000000af0 g     O *ABS*	0000000000000000              _edata
60000000000008f8 g     O .got	0000000000000000              _GLOBAL_OFFSET_=
TABLE_
6000000000000b08 g     O *ABS*	0000000000000000              _end
6000000000000ab8 g     O .sdata	0000000000000004              _IO_stdin_used
6000000000000af0 g     O .sbss	0000000000000008              __libc_ia64_re=
gister_backing_store_base
60000000000008d0 g       .data	0000000000000000              __data_start
0000000000000000       F *UND*	0000000000000000              __libc_start_m=
ain@@GLIBC_2.2
0000000000000000  w      *UND*	0000000000000000              __gmon_start__


Contents of section .interp:
 40000000000001c8 2f6c6962 2f6c642d 6c696e75 782d6961  /lib/ld-linux-ia
 40000000000001d8 36342e73 6f2e3200                    64.so.2.       =20
Contents of section .note.ABI-tag:
 40000000000001e0 04000000 10000000 01000000 474e5500  ............GNU.
 40000000000001f0 00000000 02000000 04000000 00000000  ................
Contents of section .hash:
 4000000000000200 03000000 03000000 00000000 02000000  ................
 4000000000000210 01000000 00000000 00000000 00000000  ................
Contents of section .dynsym:
 4000000000000220 00000000 00000000 00000000 00000000  ................
 4000000000000230 00000000 00000000 0d000000 12000000  ................
 4000000000000240 00000000 00000000 00000000 00000000  ................
 4000000000000250 14000000 12000000 00000000 00000000  ................
 4000000000000260 00000000 00000000                    ........       =20
Contents of section .dynstr:
 4000000000000268 006c6962 632e736f 2e362e31 00707269  .libc.so.6.1.pri
 4000000000000278 6e746600 5f5f6c69 62635f73 74617274  ntf.__libc_start
 4000000000000288 5f6d6169 6e00474c 4942435f 322e3200  _main.GLIBC_2.2.
Contents of section .gnu.version:
 4000000000000298 00000200 0200                        ......         =20
Contents of section .gnu.version_r:
 40000000000002a0 01000100 01000000 10000000 00000000  ................
 40000000000002b0 1269690d 00000200 26000000 00000000  .ii.....&.......
Contents of section .rela.IA_64.pltoff:
 40000000000002c0 d00a0000 00000060 81000000 01000000  .......`........
 40000000000002d0 00000000 00000000 e00a0000 00000060  ...............`
 40000000000002e0 81000000 02000000 00000000 00000000  ................
Contents of section .init:
 40000000000002f0 00100d06 80050002 30004220 0400c400  ........0.B ....
 4000000000000300 0d60c019 3f230000 000200c0 810c0090  .`..?#..........
 4000000000000310 0a78001c 18106000 3c0e7200 00000400  .x....`.<.r.....
 4000000000000320 1c000000 01000000 00020003 30000042  ............0..B
 4000000000000330 1d800718 99170000 00020000 08000050  ...............P
 4000000000000340 0b604018 00211000 30302000 00000400  .`@..!..00 .....
 4000000000000350 04000000 01000000 00000040 00041860  ...........@...`
 4000000000000360 03000000 01003000 00600040 20180080  ......0..`.@ ...
 4000000000000370 11000000 01006010 04800300 68000010  ......`.....h...
 4000000000000380 00600040 00210010 01550000 100a0007  .`.@.!...U......
 4000000000000390 1d000000 01000000 00020080 08008400  ................
Contents of section .plt:
 40000000000003a0 0b10001c 0021e000 08004800 00000400  .....!....H.....
 40000000000003b0 0b80201c 18141041 38302800 00000400  .. ....A80(.....
 40000000000003c0 1108001c 18106088 04800300 60008000  ......`.....`...
 40000000000003d0 11780000 00240000 00020000 d0ffff48  .x...$.........H
 40000000000003e0 11780400 00240000 00020000 c0ffff48  .x...$.........H
 40000000000003f0 00000000 00000000 00000000 00000000  ................
 4000000000000400 0b786003 03240041 3c3028c0 01080084  .x`..$.A<0(.....
 4000000000000410 1108001e 18106080 04800300 60008000  ......`.....`...
 4000000000000420 0b78a003 03240041 3c3028c0 01080084  .x...$.A<0(.....
 4000000000000430 1108001e 18106080 04800300 60008000  ......`.....`...
Contents of section .text:
 4000000000000440 04101c00 8045024c 80090060 f0131a60  .....E.L...`...`
 4000000000000450 05104118 00e1ffff ffff5f20 80f6db6f  ..A......._ ...o
 4000000000000460 09082144 1814a000 44440820 0100c000  ..!D....DD. ....
 4000000000000470 01000c50 2a041048 040a40c0 04610084  ...P*..H..@..a..
 4000000000000480 01580003 00240082 05004860 840a0090  .X...$....H`....
 4000000000000490 09180016 18100002 80302080 840b0090  .........0 .....
 40000000000004a0 08180146 18104002 90302080 00000084  ...F..@..0 .....
 40000000000004b0 10002806 98115002 20004200 70ffff58  ..(...P. .B.p..X
 40000000000004c0 11000000 00000000 00020000 00000020  ...............=20
 40000000000004d0 0c000000 01000000 00020000 00000400  ................
 40000000000004e0 00181508 80050042 06064820 0400c400  .......B..H ....
 40000000000004f0 11100102 00210000 00020000 30000040  .....!......0..@
 4000000000000500 09003c40 98111041 40302800 00000400  ..<@...A@0(.....
 4000000000000510 10080020 18106088 04800300 68000010  ... ..`.....h...
 4000000000000520 0b780040 18100041 3c302800 00000400  .x.@...A<0(.....
 4000000000000530 1c000020 06380000 00020003 d0ffff48  ... .8.........H
 4000000000000540 00080044 00210008 05800300 3002aa00  ...D.!......0...
 4000000000000550 17200200 21000000 00001000 00000020  . ..!..........=20
 4000000000000560 00101508 80053002 30004220 0400c400  ......0.0.B ....
 4000000000000570 0a704003 00244002 38302000 04080084  .p@..$@.80 .....
 4000000000000580 1d000000 01000000 00020000 88feff58  ...............X
 4000000000000590 00080040 00210010 01550000 100a0007  ...@.!...U......
 40000000000005a0 1d600046 00210000 00020080 08008400  .`.F.!..........
 40000000000005b0 00101908 80053002 30004280 0167fc8c  ......0.0.B..g..
 40000000000005c0 01000000 01001002 006200c0 010a0090  .........b......
 40000000000005d0 0d78001c 18100000 000200c0 81090090  .x..............
 40000000000005e0 0b70001c 18100070 3c3023c0 810d0090  .p.....p<0#.....
 40000000000005f0 0d20011c 18100000 000200c0 81090090  . ..............
 4000000000000600 1128011c 18100002 04004200 08feff58  .(........B....X
 4000000000000610 0b080040 0021e000 07004800 00000400  ...@.!....H.....
 4000000000000620 0d20011c 18100000 000200c0 010a0090  . ..............
 4000000000000630 1c28011c 18100000 00020000 d8fdff58  .(.............X
 4000000000000640 0b080040 0021f000 05004800 00000400  ...@.!....H.....
 4000000000000650 0b70001e 1810e000 38302000 00000400  .p......80 .....
 4000000000000660 0d78001c 18100000 000200c0 81700084  .x...........p..
 4000000000000670 1108001c 18106078 04800300 68000010  ......`x....h...
 4000000000000680 00080040 00210010 01550000 100a0007  ...@.!...U......
 4000000000000690 1d600046 00210000 00020080 08008400  .`.F.!..........
 40000000000006a0 0120150a 80050042 07004820 0400c400  . .....B..H ....
 40000000000006b0 0b000140 181030c2 83322c40 04080084  ...@..0..2,@....
 40000000000006c0 1c30fc47 003b0000 00020003 40000041  .0.G.;......@..A
 40000000000006d0 0a782046 18141000 8c3020c0 f0080007  .x F.....0 .....
 40000000000006e0 1d18e141 19160000 00020000 68000010  ...A........h...
 40000000000006f0 1c00fc47 063b0000 00020003 e0ffff48  ...G.;.........H
 4000000000000700 00080044 00210008 05800300 4002aa00  ...D.!......@...
 4000000000000710 17200200 21000000 00001000 00000020  . ..!..........=20
Contents of section .fini:
 4000000000000720 00100d06 80050002 30004220 0400c400  ........0.B ....
 4000000000000730 1d60c019 3f230000 00020000 00000020  .`..?#.........=20
 4000000000000740 04000000 01c0ffff ffff7f40 00f1ef6f  ...........@...o
 4000000000000750 03000000 01003000 00600040 20180080  ......0..`.@ ...
 4000000000000760 11000000 01006010 04800300 68000010  ......`.....h...
 4000000000000770 00600040 00210010 01550000 100a0007  .`.@.!...U......
 4000000000000780 1d000000 01000000 00020080 08008400  ................
Contents of section .rodata:
 4000000000000790 48656c6c 6f20576f 726c640a 00000000  Hello World.....
 40000000000007a0 6d795f70 72696e74 66206973 20617420  my_printf is at=20
 40000000000007b0 3078256c 6c782e0a 00000000 00000000  0x%llx..........
 40000000000007c0 64697369 6e666f20 69732061 74203078  disinfo is at 0x
 40000000000007d0 256c6c78 2e0a0000                    %llx....       =20
Contents of section .opd:
 40000000000007e0 60050000 00000040 f8080000 00000060  `......@.......`
 40000000000007f0 f0020000 00000040 f8080000 00000060  .......@.......`
 4000000000000800 b0050000 00000040 f8080000 00000060  .......@.......`
 4000000000000810 20070000 00000040 f8080000 00000060   ......@.......`
 4000000000000820 00000000 00000000 00000000 00000000  ................
Contents of section .IA_64.unwind_info:
 4000000000000830 01000000 00000100 15e414b0 84260000  .............&..
 4000000000000840 00000000 00000000 02000000 00000100  ................
 4000000000000850 472103e6 00e101e4 022cc002 00000000  G!.......,......
 4000000000000860 00000000 00000000 02000000 00000100  ................
 4000000000000870 472105e6 00e101e4 046128c0 02000000  G!.......a(.....
 4000000000000880 00000000 00000000                    ........       =20
Contents of section .IA_64.unwind:
 4000000000000888 40040000 00000000 d0040000 00000000  @...............
 4000000000000898 30080000 00000000 60050000 00000000  0.......`.......
 40000000000008a8 b0050000 00000000 48080000 00000000  ........H.......
 40000000000008b8 b0050000 00000000 a0060000 00000000  ................
 40000000000008c8 68080000 00000000                    h.......       =20
Contents of section .data:
 60000000000008d0 00000000                             ....           =20
Contents of section .ctors:
 60000000000008d8 ffffffff ffffffff 00000000 00000000  ................
Contents of section .dtors:
 60000000000008e8 ffffffff ffffffff 00000000 00000000  ................
Contents of section .got:
 60000000000008f8 00000000 00000000 00000000 00000000  ................
 6000000000000908 00000000 00000000 e0070000 00000040  ...............@
 6000000000000918 f80a0000 00000060 f0070000 00000040  .......`.......@
 6000000000000928 00080000 00000040 10080000 00000040  .......@.......@
 6000000000000938 f00a0000 00000060 00000000 00000000  .......`........
 6000000000000948 90070000 00000040 a0070000 00000040  .......@.......@
 6000000000000958 c0070000 00000040 d8080000 00000060  .......@.......`
Contents of section .dynamic:
 6000000000000968 01000000 00000000 01000000 00000000  ................
 6000000000000978 0c000000 00000000 f0020000 00000040  ...............@
 6000000000000988 0d000000 00000000 20070000 00000040  ........ ......@
 6000000000000998 04000000 00000000 00020000 00000040  ...............@
 60000000000009a8 05000000 00000000 68020000 00000040  ........h......@
 60000000000009b8 06000000 00000000 20020000 00000040  ........ ......@
 60000000000009c8 0a000000 00000000 26000000 00000000  ........&.......
 60000000000009d8 0b000000 00000000 18000000 00000000  ................
 60000000000009e8 15000000 00000000 00000000 00000000  ................
 60000000000009f8 00000070 00000000 f8080000 00000060  ...p...........`
 6000000000000a08 03000000 00000000 f8080000 00000060  ...............`
 6000000000000a18 02000000 00000000 30000000 00000000  ........0.......
 6000000000000a28 14000000 00000000 07000000 00000000  ................
 6000000000000a38 17000000 00000000 c0020000 00000040  ...............@
 6000000000000a48 07000000 00000000 c0020000 00000040  ...............@
 6000000000000a58 08000000 00000000 00000000 00000000  ................
 6000000000000a68 09000000 00000000 18000000 00000000  ................
 6000000000000a78 feffff6f 00000000 a0020000 00000040  ...o...........@
 6000000000000a88 ffffff6f 00000000 01000000 00000000  ...o............
 6000000000000a98 f0ffff6f 00000000 98020000 00000040  ...o...........@
 6000000000000aa8 00000000 00000000 00000000 00000000  ................
Contents of section .sdata:
 6000000000000ab8 01000200 00000000 f0080000 00000060  ...............`
Contents of section .IA_64.pltoff:
 6000000000000ad0 d0030000 00000040 f8080000 00000060  .......@.......`
 6000000000000ae0 e0030000 00000040 f8080000 00000060  .......@.......`
Contents of section .comment:
 0000 00474343 3a202847 4e552920 322e3936  .GCC: (GNU) 2.96
 0010 20323030 30303733 31202852 65642048   20000731 (Red H
 0020 6174204c 696e7578 20372e31 20322e39  at Linux 7.1 2.9
 0030 362d3835 29000047 43433a20 28474e55  6-85)..GCC: (GNU
 0040 2920322e 39362032 30303030 37333120  ) 2.96 20000731=20
 0050 28526564 20486174 204c696e 75782037  (Red Hat Linux 7
 0060 2e312032 2e39362d 38352900 00474343  .1 2.96-85)..GCC
 0070 3a202847 4e552920 332e302e 32000047  : (GNU) 3.0.2..G
 0080 43433a20 28474e55 2920322e 39362032  CC: (GNU) 2.96 2
 0090 30303030 37333120 28526564 20486174  0000731 (Red Hat
 00a0 204c696e 75782037 2e312032 2e39362d   Linux 7.1 2.96-
 00b0 38352900                             85).           =20
Contents of section .debug_aranges:
 0000 2c000000 0200630d 00000800 00000000  ,.....c.........
 0010 60050000 00000040 40010000 00000000  `......@@.......
 0020 00000000 00000000 00000000 00000000  ................
Contents of section .debug_pubnames:
 0000 21000000 02000000 0000630d 00003c0d  !.........c...<.
 0010 00005f49 4f5f7374 64696e5f 75736564  .._IO_stdin_used
 0020 00000000 00310000 00020063 0d000055  .....1.....c...U
 0030 120000ac 0a00006d 795f7072 696e7466  .......my_printf
 0040 00ce0a00 006d6169 6e003a12 00006469  .....main.:...di
 0050 73696e66 6f000000 0000               sinfo.....     =20
Contents of section .debug_info:
 0000 5f0d0000 02000000 00000801 696e6974  _...........init
 0010 2e63002f 7573722f 6c6f6361 6c2f7372  .c./usr/local/sr
 0020 632f6763 632f676c 6962632d 322e322e  c/gcc/glibc-2.2.
 0030 342f6373 7500474e 55204320 322e3936  4/csu.GNU C 2.96
 0040 20323030 30303733 31202852 65642048   20000731 (Red H
 0050 6174204c 696e7578 20372e31 20322e39  at Linux 7.1 2.9
 0060 362d3835 29000102 73697a65 5f740001  6-85)...size_t..
 0070 c7750000 00036c6f 6e672075 6e736967  .u....long unsig
 0080 6e656420 696e7400 0807025f 5f755f63  ned int....__u_c
 0090 68617200 02209a00 00000375 6e736967  har.. .....unsig
 00a0 6e656420 63686172 00010802 5f5f755f  ned char....__u_
 00b0 73686f72 74000221 bc000000 0373686f  short..!.....sho
 00c0 72742075 6e736967 6e656420 696e7400  rt unsigned int.
 00d0 0207025f 5f755f69 6e740002 22e10000  ...__u_int.."...
 00e0 0003756e 7369676e 65642069 6e740004  ..unsigned int..
 00f0 07025f5f 755f6c6f 6e670002 23750000  ..__u_long..#u..
 0100 00025f5f 755f7175 61645f74 00022475  ..__u_quad_t..$u
 0110 00000002 5f5f7175 61645f74 00022523  ....__quad_t..%#
 0120 01000003 6c6f6e67 20696e74 00080502  ....long int....
 0130 5f5f696e 74385f74 0002263f 01000003  __int8_t..&?....
 0140 7369676e 65642063 68617200 0106025f  signed char...._
 0150 5f75696e 74385f74 0002279a 00000002  _uint8_t..'.....
 0160 5f5f696e 7431365f 74000228 70010000  __int16_t..(p...
 0170 0373686f 72742069 6e740002 05025f5f  .short int....__
 0180 75696e74 31365f74 000229bc 00000002  uint16_t..).....
 0190 5f5f696e 7433325f 7400022a a0010000  __int32_t..*....
 01a0 03696e74 00040502 5f5f7569 6e743332  .int....__uint32
 01b0 5f740002 2be10000 00025f5f 696e7436  _t..+.....__int6
 01c0 345f7400 022c2301 0000025f 5f75696e  4_t..,#....__uin
 01d0 7436345f 7400022d 75000000 025f5f71  t64_t..-u....__q
 01e0 61646472 5f740002 2eed0100 00040813  addr_t..........
 01f0 01000002 5f5f6465 765f7400 0230ca01  ....__dev_t..0..
 0200 0000025f 5f756964 5f740002 31a70100  ...__uid_t..1...
 0210 00025f5f 6769645f 74000232 a7010000  ..__gid_t..2....
 0220 025f5f69 6e6f5f74 000233ca 01000002  .__ino_t..3.....
 0230 5f5f696e 6f36345f 74000234 ca010000  __ino64_t..4....
 0240 025f5f6d 6f64655f 74000235 a7010000  .__mode_t..5....
 0250 025f5f6e 6c696e6b 5f740002 36ca0100  .__nlink_t..6...
 0260 00025f5f 6f66665f 74000237 b9010000  ..__off_t..7....
 0270 025f5f6f 66663634 5f740002 38b90100  .__off64_t..8...
 0280 00025f5f 6c6f6666 5f740002 39b90100  ..__loff_t..9...
 0290 00025f5f 7069645f 7400023a 8f010000  ..__pid_t..:....
 02a0 025f5f73 73697a65 5f740002 3bb90100  .__ssize_t..;...
 02b0 00025f5f 726c696d 5f740002 3cca0100  ..__rlim_t..<...
 02c0 00025f5f 726c696d 36345f74 00023dca  ..__rlim64_t..=3D.
 02d0 01000002 5f5f626c 6b636e74 5f740002  ....__blkcnt_t..
 02e0 3eb90100 00025f5f 626c6b63 6e743634  >.....__blkcnt64
 02f0 5f740002 3fb90100 00025f5f 6673626c  _t..?.....__fsbl
 0300 6b636e74 5f740002 40ca0100 00025f5f  kcnt_t..@.....__
 0310 6673626c 6b636e74 36345f74 000241ca  fsblkcnt64_t..A.
 0320 01000002 5f5f6673 66696c63 6e745f74  ....__fsfilcnt_t
 0330 000242ca 01000002 5f5f6673 66696c63  ..B.....__fsfilc
 0340 6e743634 5f740002 43ca0100 00025f5f  nt64_t..C.....__
 0350 69645f74 000244a7 01000005 74030000  id_t..D.....t...
 0360 08024906 5f5f7661 6c000248 74030000  ..I.__val..Ht...
 0370 02230000 07840300 00a00100 00088403  .#..............
 0380 00000100 036c6f6e 6720756e 7369676e  .....long unsign
 0390 65642069 6e740008 07025f5f 66736964  ed int....__fsid
 03a0 5f740002 495b0300 00025f5f 64616464  _t..I[....__dadd
 03b0 725f7400 024ca001 0000025f 5f636164  r_t..L.....__cad
 03c0 64725f74 00024dcb 03000004 08d10300  dr_t..M.........
 03d0 00036368 61720001 06025f5f 74696d65  ..char....__time
 03e0 5f740002 4e230100 00025f5f 75736563  _t..N#....__usec
 03f0 6f6e6473 5f740002 4fe10000 00025f5f  onds_t..O.....__
 0400 73757365 636f6e64 735f7400 02502301  suseconds_t..P#.
 0410 0000025f 5f737762 6c6b5f74 00025123  ...__swblk_t..Q#
 0420 01000002 5f5f636c 6f636b5f 74000252  ....__clock_t..R
 0430 23010000 025f5f6b 65795f74 000253a0  #....__key_t..S.
 0440 01000002 5f5f636c 6f636b69 645f7400  ....__clockid_t.
 0450 0256a001 0000025f 5f74696d 65725f74  .V.....__timer_t
 0460 000259a0 01000002 5f5f6970 635f7069  ..Y.....__ipc_pi
 0470 645f7400 025ca001 0000025f 5f626c6b  d_t..\.....__blk
 0480 73697a65 5f740002 5f230100 00025f5f  size_t.._#....__
 0490 745f7363 616c6172 5f740002 66a00100  t_scalar_t..f...
 04a0 00025f5f 745f7573 63616c61 725f7400  ..__t_uscalar_t.
 04b0 0267e100 0000025f 5f696e74 7074725f  .g.....__intptr_
 04c0 7400026a 23010000 025f5f73 6f636b6c  t..j#....__sockl
 04d0 656e5f74 00026de1 00000009 77636861  en_t..m.....wcha
 04e0 725f7400 011f01a0 01000009 77696e74  r_t.........wint
 04f0 5f740001 3801e100 00000a1e 05000004  _t..8...........
 0500 034a0b5f 5f776368 000348eb 0400000b  .J.__wch..H.....
 0510 5f5f7763 68620003 491e0500 0000072e  __wchb..I.......
 0520 050000d1 03000008 84030000 0300055b  ...............[
 0530 05000008 034b065f 5f636f75 6e740003  .....K.__count..
 0540 45a00100 00022300 065f5f76 616c7565  E.....#..__value
 0550 00034afa 04000002 23040002 5f5f6d62  ..J.....#...__mb
 0560 73746174 655f7400 034b2e05 00000599  state_t..K......
 0570 05000010 041e065f 5f706f73 00041c61  .......__pos...a
 0580 02000002 2300065f 5f737461 74650004  ....#..__state..
 0590 1d5b0500 00022308 00025f47 5f66706f  .[....#..._G_fpo
 05a0 735f7400 041e6e05 000005d5 05000010  s_t...n.........
 05b0 0423065f 5f706f73 00042170 02000002  .#.__pos..!p....
 05c0 2300065f 5f737461 74650004 225b0500  #..__state.."[..
 05d0 00022308 00025f47 5f66706f 7336345f  ..#..._G_fpos64_
 05e0 74000423 aa050000 0cc30600 00040525  t..#...........%
 05f0 0d5f5f47 434f4e56 5f4f4b00 000d5f5f  .__GCONV_OK...__
 0600 47434f4e 565f4e4f 434f4e56 00010d5f  GCONV_NOCONV..._
 0610 5f47434f 4e565f4e 4f444200 020d5f5f  _GCONV_NODB...__
 0620 47434f4e 565f4e4f 4d454d00 030d5f5f  GCONV_NOMEM...__
 0630 47434f4e 565f454d 5054595f 494e5055  GCONV_EMPTY_INPU
 0640 5400040d 5f5f4743 4f4e565f 46554c4c  T...__GCONV_FULL
 0650 5f4f5554 50555400 050d5f5f 47434f4e  _OUTPUT...__GCON
 0660 565f494c 4c454741 4c5f494e 50555400  V_ILLEGAL_INPUT.
 0670 060d5f5f 47434f4e 565f494e 434f4d50  ..__GCONV_INCOMP
 0680 4c455445 5f494e50 55540007 0d5f5f47  LETE_INPUT...__G
 0690 434f4e56 5f494c4c 4547414c 5f444553  CONV_ILLEGAL_DES
 06a0 43524950 544f5200 080d5f5f 47434f4e  CRIPTOR...__GCON
 06b0 565f494e 5445524e 414c5f45 52524f52  V_INTERNAL_ERROR
 06c0 0009000c f6060000 0405370d 5f5f4743  ..........7.__GC
 06d0 4f4e565f 49535f4c 41535400 010d5f5f  ONV_IS_LAST...__
 06e0 47434f4e 565f4947 4e4f5245 5f455252  GCONV_IGNORE_ERR
 06f0 4f525300 02000e42 0800005f 5f67636f  ORS....B...__gco
 0700 6e765f73 74657000 60053e06 5f5f7368  nv_step.`.>.__sh
 0710 6c69625f 68616e64 6c650005 715a0800  lib_handle..qZ..
 0720 00022300 065f5f6d 6f646e61 6d650005  ..#..__modname..
 0730 72600800 00022308 065f5f63 6f756e74  r`....#..__count
 0740 65720005 74a00100 00022310 065f5f66  er..t.....#..__f
 0750 726f6d5f 6e616d65 000576cb 03000002  rom_name..v.....
 0760 2318065f 5f746f5f 6e616d65 000577cb  #..__to_name..w.
 0770 03000002 2320065f 5f666374 000579a1  ....# .__fct..y.
 0780 0a000002 2328065f 5f696e69 745f6663  ....#(.__init_fc
 0790 7400057a b70a0000 02233006 5f5f656e  t..z.....#0.__en
 07a0 645f6663 7400057b c90a0000 02233806  d_fct..{.....#8.
 07b0 5f5f6d69 6e5f6e65 65646564 5f66726f  __min_needed_fro
 07c0 6d00057f a0010000 02234006 5f5f6d61  m........#@.__ma
 07d0 785f6e65 65646564 5f66726f 6d000580  x_needed_from...
 07e0 a0010000 02234406 5f5f6d69 6e5f6e65  .....#D.__min_ne
 07f0 65646564 5f746f00 0581a001 00000223  eded_to........#
 0800 48065f5f 6d61785f 6e656564 65645f74  H.__max_needed_t
 0810 6f000582 a0010000 02234c06 5f5f7374  o........#L.__st
 0820 61746566 756c0005 85a00100 00022350  ateful........#P
 0830 065f5f64 61746100 05873a0a 00000223  .__data...:....#
 0840 58000f5f 5f67636f 6e765f6c 6f616465  X..__gconv_loade
 0850 645f6f62 6a656374 00010408 42080000  d_object....B...
 0860 04086608 000010d1 03000011 9e080000  ..f.............
 0870 01a00100 00129e08 000012a4 08000012  ................
 0880 470a0000 123c0a00 00124d0a 00001253  G....<....M....S
 0890 0a000012 a0010000 12a00100 00000408  ................
 08a0 f6060000 0408aa08 00000e6f 0900005f  ...........o..._
 08b0 5f67636f 6e765f73 7465705f 64617461  _gconv_step_data
 08c0 0038053f 065f5f6f 75746275 6600058e  .8.?.__outbuf...
 08d0 6f090000 02230006 5f5f6f75 74627566  o....#..__outbuf
 08e0 656e6400 058f6f09 00000223 08065f5f  end...o....#..__
 08f0 666c6167 73000593 a0010000 02231006  flags........#..
 0900 5f5f696e 766f6361 74696f6e 5f636f75  __invocation_cou
 0910 6e746572 000597a0 01000002 2314065f  nter........#.._
 0920 5f696e74 65726e61 6c5f7573 6500059b  _internal_use...
 0930 a0010000 02231806 5f5f7374 61746570  .....#..__statep
 0940 00059d75 09000002 2320065f 5f737461  ...u....# .__sta
 0950 74650005 9e5b0500 00022328 065f5f74  te...[....#(.__t
 0960 72616e73 0005a29b 0a000002 23300004  rans........#0..
 0970 089a0000 0004085b 0500000e 070a0000  .......[........
 0980 5f5f6763 6f6e765f 7472616e 735f6461  __gconv_trans_da
 0990 74610028 0541065f 5f747261 6e735f66  ta.(.A.__trans_f
 09a0 63740005 66590a00 00022300 065f5f74  ct..fY....#..__t
 09b0 72616e73 5f636f6e 74657874 5f666374  rans_context_fct
 09c0 00056783 0a000002 2308065f 5f747261  ..g.....#..__tra
 09d0 6e735f65 6e645f66 63740005 68950a00  ns_end_fct..h...
 09e0 00022310 065f5f64 61746100 05693a0a  ..#..__data..i:.
 09f0 00000223 18065f5f 6e657874 00056a9b  ...#..__next..j.
 0a00 0a000002 23200011 3a0a0000 01a00100  ....# ..:.......
 0a10 00129e08 000012a4 08000012 3a0a0000  ............:...
 0a20 123c0a00 0012470a 0000123c 0a000012  .<....G....<....
 0a30 4d0a0000 12530a00 00001308 0408420a  M....S........B.
 0a40 0000109a 00000004 083c0a00 0004086f  .........<.....o
 0a50 09000004 08670000 00040807 0a000011  .....g..........
 0a60 830a0000 01a00100 00123a0a 0000123c  ..........:....<
 0a70 0a000012 3c0a0000 126f0900 00126f09  ....<....o....o.
 0a80 00000004 085f0a00 0014950a 00000112  ....._..........
 0a90 3a0a0000 00040889 0a000004 087b0900  :............{..
 0aa0 0004086b 08000011 b70a0000 01a00100  ...k............
 0ab0 00129e08 00000004 08a70a00 0014c90a  ................
 0ac0 00000112 9e080000 000408bd 0a000002  ................
 0ad0 5f5f6763 6f6e765f 66637400 0547e20a  __gconv_fct..G..
 0ae0 00000408 6b080000 025f5f67 636f6e76  ....k....__gconv
 0af0 5f696e69 745f6663 7400054a 000b0000  _init_fct..J....
 0b00 0408a70a 0000025f 5f67636f 6e765f65  .......__gconv_e
 0b10 6e645f66 63740005 4b1d0b00 000408bd  nd_fct..K.......
 0b20 0a000002 5f5f6763 6f6e765f 7472616e  ....__gconv_tran
 0b30 735f6663 74000554 3c0b0000 0408070a  s_fct..T<.......
 0b40 0000025f 5f67636f 6e765f74 72616e73  ...__gconv_trans
 0b50 5f636f6e 74657874 5f666374 00055963  _context_fct..Yc
 0b60 0b000004 085f0a00 00025f5f 67636f6e  ....._....__gcon
 0b70 765f7472 616e735f 71756572 795f6663  v_trans_query_fc
 0b80 7400055d 880b0000 04088e0b 000011a8  t..]............
 0b90 0b000001 a0010000 12600800 0012a80b  .........`......
 0ba0 00001253 0a000000 0408ae0b 00000408  ...S............
 0bb0 60080000 025f5f67 636f6e76 5f747261  `....__gconv_tra
 0bc0 6e735f69 6e69745f 66637400 0560d20b  ns_init_fct..`..
 0bd0 00000408 d80b0000 11ed0b00 0001a001  ................
 0be0 000012ed 0b000012 60080000 0004083a  ........`......:
 0bf0 0a000002 5f5f6763 6f6e765f 7472616e  ....__gconv_tran
 0c00 735f656e 645f6663 74000561 100c0000  s_end_fct..a....
 0c10 0408890a 00000e62 0c00005f 5f67636f  .......b...__gco
 0c20 6e765f69 6e666f00 1005a806 5f5f6e73  nv_info.....__ns
 0c30 74657073 0005a967 00000002 2300065f  teps...g....#.._
 0c40 5f737465 70730005 aa9e0800 00022308  _steps........#.
 0c50 065f5f64 61746100 05ab620c 00000223  .__data...b....#
 0c60 10000779 0c0000aa 08000015 84030000  ...y............
 0c70 ffffffff ffffffff 00025f5f 67636f6e  ..........__gcon
 0c80 765f7400 05ac8a0c 00000408 160c0000  v_t.............
 0c90 05b90c00 00480434 065f5f63 64000432  .....H.4.__cd..2
 0ca0 160c0000 02230006 5f5f6461 74610004  .....#..__data..
 0cb0 33aa0800 00022310 000ae00c 00004804  3.....#.......H.
 0cc0 350b5f5f 63640004 2f160c00 000b5f5f  5.__cd../.....__
 0cd0 636f6d62 696e6564 00043490 0c000000  combined..4.....
 0ce0 025f475f 69636f6e 765f7400 0435b90c  ._G_iconv_t..5..
 0cf0 0000025f 475f696e 7431365f 74000437  ..._G_int16_t..7
 0d00 70010000 025f475f 696e7433 325f7400  p...._G_int32_t.
 0d10 0438a001 0000025f 475f7569 6e743136  .8....._G_uint16
 0d20 5f740004 39bc0000 00025f47 5f75696e  _t..9....._G_uin
 0d30 7433325f 7400043a e1000000 165f494f  t32_t..:....._IO
 0d40 5f737464 696e5f75 73656400 06195d0d  _stdin_used...].
 0d50 00000109 03b80a00 00000000 6010a001  ............`...
 0d60 00000051 12000002 00f50000 00080100  ...Q............
 0d70 000000a0 06000000 00004060 05000000  ..........@`....
 0d80 00004074 6573742e 63002f75 73722f70  ..@test.c./usr/p
 0d90 656f706c 652f7069 65742f73 72630047  eople/piet/src.G
 0da0 4e552043 20332e30 2e320001 02620000  NU C 3.0.2...b..
 0db0 00080249 035f5f76 616c0002 48620000  ...I.__val..Hb..
 0dc0 00022300 00047200 00008700 00000572  ..#...r........r
 0dd0 00000001 00066c6f 6e672075 6e736967  ......long unsig
 0de0 6e656420 696e7400 08070669 6e740004  ned int....int..
 0df0 0507b200 00000403 4a085f5f 77636800  ........J.__wch.
 0e00 0348b200 0000085f 5f776368 62000349  .H.....__wchb..I
 0e10 bc000000 00067769 6e745f74 00040704  ......wint_t....
 0e20 cc000000 cc000000 05720000 00030006  .........r......
 0e30 63686172 00010602 01010000 08034b03  char..........K.
 0e40 5f5f636f 756e7400 03458700 00000223  __count..E.....#
 0e50 00035f5f 76616c75 6500034a 8e000000  ..__value..J....
 0e60 02230400 022c0100 0010041e 035f5f70  .#...,.......__p
 0e70 6f730004 1c2c0100 00022300 035f5f73  os...,....#..__s
 0e80 74617465 00041dd4 00000002 23080006  tate........#...
 0e90 5f5f6f66 665f7400 08050262 01000010  __off_t....b....
 0ea0 0423035f 5f706f73 00042162 01000002  .#.__pos..!b....
 0eb0 2300035f 5f737461 74650004 22d40000  #..__state.."...
 0ec0 00022308 00065f5f 6f666636 345f7400  ..#...__off64_t.
 0ed0 0805094a 02000004 05250a5f 5f47434f  ...J.....%.__GCO
 0ee0 4e565f4f 4b00000a 5f5f4743 4f4e565f  NV_OK...__GCONV_
 0ef0 4e4f434f 4e560001 0a5f5f47 434f4e56  NOCONV...__GCONV
 0f00 5f4e4f44 4200020a 5f5f4743 4f4e565f  _NODB...__GCONV_
 0f10 4e4f4d45 4d00030a 5f5f4743 4f4e565f  NOMEM...__GCONV_
 0f20 454d5054 595f494e 50555400 040a5f5f  EMPTY_INPUT...__
 0f30 47434f4e 565f4655 4c4c5f4f 55545055  GCONV_FULL_OUTPU
 0f40 5400050a 5f5f4743 4f4e565f 494c4c45  T...__GCONV_ILLE
 0f50 47414c5f 494e5055 5400060a 5f5f4743  GAL_INPUT...__GC
 0f60 4f4e565f 494e434f 4d504c45 54455f49  ONV_INCOMPLETE_I
 0f70 4e505554 00070a5f 5f47434f 4e565f49  NPUT...__GCONV_I
 0f80 4c4c4547 414c5f44 45534352 4950544f  LLEGAL_DESCRIPTO
 0f90 5200080a 5f5f4743 4f4e565f 494e5445  R...__GCONV_INTE
 0fa0 524e414c 5f455252 4f520009 00097d02  RNAL_ERROR....}.
 0fb0 00000405 370a5f5f 47434f4e 565f4953  ....7.__GCONV_IS
 0fc0 5f4c4153 5400010a 5f5f4743 4f4e565f  _LAST...__GCONV_
 0fd0 49474e4f 52455f45 52524f52 53000200  IGNORE_ERRORS...
 0fe0 0b090300 005f5f67 636f6e76 5f747261  .....__gconv_tra
 0ff0 6e735f64 61746100 28054103 5f5f7472  ns_data.(.A.__tr
 1000 616e735f 66637400 05669905 00000223  ans_fct..f.....#
 1010 00035f5f 7472616e 735f636f 6e746578  ..__trans_contex
 1020 745f6663 74000567 c3050000 02230803  t_fct..g.....#..
 1030 5f5f7472 616e735f 656e645f 66637400  __trans_end_fct.
 1040 0568d505 00000223 10035f5f 64617461  .h.....#..__data
 1050 00056959 05000002 2318035f 5f6e6578  ..iY....#..__nex
 1060 7400056a db050000 02232000 0c3c0300  t..j.....# ..<..
 1070 00018700 00000d3c 0300000d 8e040000  .......<........
 1080 0d590500 000d5b05 00000d77 0500000d  .Y....[....w....
 1090 5b050000 0d7d0500 000d8905 0000000e  [....}..........
 10a0 08420300 000b8e04 00005f5f 67636f6e  .B........__gcon
 10b0 765f7374 65700060 053e035f 5f73686c  v_step.`.>.__shl
 10c0 69625f68 616e646c 65000571 f9050000  ib_handle..q....
 10d0 02230003 5f5f6d6f 646e616d 65000572  .#..__modname..r
 10e0 ff050000 02230803 5f5f636f 756e7465  .....#..__counte
 10f0 72000574 87000000 02231003 5f5f6672  r..t.....#..__fr
 1100 6f6d5f6e 616d6500 05760a06 00000223  om_name..v.....#
 1110 18035f5f 746f5f6e 616d6500 05770a06  ..__to_name..w..
 1120 00000223 20035f5f 66637400 05794306  ...# .__fct..yC.
 1130 00000223 28035f5f 696e6974 5f666374  ...#(.__init_fct
 1140 00057a59 06000002 2330035f 5f656e64  ..zY....#0.__end
 1150 5f666374 00057b6b 06000002 2338035f  _fct..{k....#8._
 1160 5f6d696e 5f6e6565 6465645f 66726f6d  _min_needed_from
 1170 00057f87 00000002 2340035f 5f6d6178  ........#@.__max
 1180 5f6e6565 6465645f 66726f6d 00058087  _needed_from....
 1190 00000002 2344035f 5f6d696e 5f6e6565  ....#D.__min_nee
 11a0 6465645f 746f0005 81870000 00022348  ded_to........#H
 11b0 035f5f6d 61785f6e 65656465 645f746f  .__max_needed_to
 11c0 00058287 00000002 234c035f 5f737461  ........#L.__sta
 11d0 74656675 6c000585 87000000 02235003  teful........#P.
 11e0 5f5f6461 74610005 87590500 00022358  __data...Y....#X
 11f0 000e0894 0400000b 59050000 5f5f6763  ........Y...__gc
 1200 6f6e765f 73746570 5f646174 61003805  onv_step_data.8.
 1210 3f035f5f 6f757462 75660005 8e830500  ?.__outbuf......
 1220 00022300 035f5f6f 75746275 66656e64  ..#..__outbufend
 1230 00058f83 05000002 2308035f 5f666c61  ........#..__fla
 1240 67730005 93870000 00022310 035f5f69  gs........#..__i
 1250 6e766f63 6174696f 6e5f636f 756e7465  nvocation_counte
 1260 72000597 87000000 02231403 5f5f696e  r........#..__in
 1270 7465726e 616c5f75 73650005 9b870000  ternal_use......
 1280 00022318 035f5f73 74617465 7000059d  ..#..__statep...
 1290 71060000 02232003 5f5f7374 61746500  q....# .__state.
 12a0 059ed400 00000223 28035f5f 7472616e  .......#(.__tran
 12b0 730005a2 db050000 02233000 0f080e08  s........#0.....
 12c0 61050000 10660500 0006756e 7369676e  a....f....unsign
 12d0 65642063 68617200 01080e08 5b050000  ed char.....[...
 12e0 0e088305 00000e08 66050000 0e088f05  ........f.......
 12f0 00000673 697a655f 74000807 0e080903  ...size_t.......
 1300 00000cc3 05000001 87000000 0d590500  .............Y..
 1310 000d5b05 00000d5b 0500000d 83050000  ..[....[........
 1320 0d830500 00000e08 9f050000 11d50500  ................
 1330 00010d59 05000000 0e08c905 00000e08  ...Y............
 1340 7d020000 125f5f67 636f6e76 5f6c6f61  }....__gconv_loa
 1350 6465645f 6f626a65 63740001 0e08e105  ded_object......
 1360 00000e08 05060000 10cc0000 000e08cc  ................
 1370 0000000c 43060000 01870000 000d3c03  ....C.........<.
 1380 00000d8e 0400000d 77050000 0d5b0500  ........w....[..
 1390 000d7d05 00000d89 0500000d 87000000  ..}.............
 13a0 0d870000 00000e08 10060000 0c590600  .............Y..
 13b0 00018700 00000d3c 03000000 0e084906  .......<......I.
 13c0 0000116b 06000001 0d3c0300 00000e08  ...k.....<......
 13d0 5f060000 0e08d400 00000bc3 0600005f  _.............._
 13e0 5f67636f 6e765f69 6e666f00 1005a803  _gconv_info.....
 13f0 5f5f6e73 74657073 0005a98f 05000002  __nsteps........
 1400 2300035f 5f737465 70730005 aa3c0300  #..__steps...<..
 1410 00022308 035f5f64 61746100 05abc306  ..#..__data.....
 1420 00000223 100004d2 06000094 04000013  ...#............
 1430 72000000 0002fb06 00004804 34035f5f  r.........H.4.__
 1440 63640004 32770600 00022300 035f5f64  cd..2w....#..__d
 1450 61746100 04339404 00000223 10000722  ata..3.....#..."
 1460 07000048 0435085f 5f636400 042f7706  ...H.5.__cd../w.
 1470 0000085f 5f636f6d 62696e65 64000434  ...__combined..4
 1480 d2060000 000b6507 00005f49 4f5f6d61  ......e..._IO_ma
 1490 726b6572 001806b0 035f6e65 78740006  rker....._next..
 14a0 b1650700 00022300 035f7362 75660006  .e....#.._sbuf..
 14b0 b2bf0900 00022308 035f706f 730006b6  ......#.._pos...
 14c0 87000000 02231000 0e082207 00000bbf  .....#....".....
 14d0 0900005f 494f5f46 494c4500 d8072d14  ..._IO_FILE...-.
 14e0 5f666c61 67730006 06018700 00000223  _flags.........#
 14f0 00145f49 4f5f7265 61645f70 74720006  .._IO_read_ptr..
 1500 0b010a06 00000223 08145f49 4f5f7265  .......#.._IO_re
 1510 61645f65 6e640006 0c010a06 00000223  ad_end.........#
 1520 10145f49 4f5f7265 61645f62 61736500  .._IO_read_base.
 1530 060d010a 06000002 2318145f 494f5f77  ........#.._IO_w
 1540 72697465 5f626173 6500060e 010a0600  rite_base.......
 1550 00022320 145f494f 5f777269 74655f70  ..# ._IO_write_p
 1560 74720006 0f010a06 00000223 28145f49  tr.........#(._I
 1570 4f5f7772 6974655f 656e6400 0610010a  O_write_end.....
 1580 06000002 2330145f 494f5f62 75665f62  ....#0._IO_buf_b
 1590 61736500 0611010a 06000002 2338145f  ase.........#8._
 15a0 494f5f62 75665f65 6e640006 12010a06  IO_buf_end......
 15b0 00000223 40145f49 4f5f7361 76655f62  ...#@._IO_save_b
 15c0 61736500 0614010a 06000002 2348145f  ase.........#H._
 15d0 494f5f62 61636b75 705f6261 73650006  IO_backup_base..
 15e0 15010a06 00000223 50145f49 4f5f7361  .......#P._IO_sa
 15f0 76655f65 6e640006 16010a06 00000223  ve_end.........#
 1600 58145f6d 61726b65 72730006 18016507  X._markers....e.
 1610 00000223 60145f63 6861696e 00061a01  ...#`._chain....
 1620 bf090000 02236814 5f66696c 656e6f00  .....#h._fileno.
 1630 061c0187 00000002 2370145f 626c6b73  ........#p._blks
 1640 697a6500 061d0187 00000002 2374145f  ize.........#t._
 1650 6f6c645f 6f666673 65740006 1e012c01  old_offset....,.
 1660 00000223 78145f63 75725f63 6f6c756d  ...#x._cur_colum
 1670 6e000622 01270a00 00032380 01145f76  n..".'....#..._v
 1680 7461626c 655f6f66 66736574 00062301  table_offset..#.
 1690 3d0a0000 03238201 145f7368 6f727462  =3D....#..._shortb
 16a0 75660006 24014c0a 00000323 8301145f  uf..$.L....#..._
 16b0 6c6f636b 00062801 5c0a0000 03238801  lock..(.\....#..
 16c0 145f6f66 66736574 00063101 62010000  ._offset..1.b...
 16d0 03239001 145f5f70 61643100 06370159  .#...__pad1..7.Y
 16e0 05000003 23980114 5f5f7061 64320006  ....#...__pad2..
 16f0 38015905 00000323 a001145f 6d6f6465  8.Y....#..._mode
 1700 00063a01 87000000 0323a801 145f756e  ..:......#..._un
 1710 75736564 3200063c 015e0a00 000323ac  used2..<.^....#.
 1720 01000e08 6b070000 15270a00 005f5f63  ....k....'...__c
 1730 6f646563 76745f72 6573756c 74000406  odecvt_result...
 1740 c50a5f5f 636f6465 6376745f 6f6b0000  ..__codecvt_ok..
 1750 0a5f5f63 6f646563 76745f70 61727469  .__codecvt_parti
 1760 616c0001 0a5f5f63 6f646563 76745f65  al...__codecvt_e
 1770 72726f72 00020a5f 5f636f64 65637674  rror...__codecvt
 1780 5f6e6f63 6f6e7600 03000673 686f7274  _noconv....short
 1790 20756e73 69676e65 6420696e 74000207   unsigned int...
 17a0 06736967 6e656420 63686172 00010604  .signed char....
 17b0 5c0a0000 cc000000 05720000 0000000f  \........r......
 17c0 08046e0a 0000cc00 00000572 0000002b  ..n........r...+
 17d0 000b9f0a 00006469 73617373 656d626c  ......disassembl
 17e0 655f696e 666f0008 01040366 7072696e  e_info.....fprin
 17f0 74665f66 756e6300 0105a60a 00000223  tf_func........#
 1800 000016a6 0a000017 000e089f 0a000018  ................
 1810 016d795f 7072696e 74660001 0b016005  .my_printf....`.
 1820 00000000 0040b005 00000000 00400290  .....@.......@..
 1830 2319016d 61696e00 01100187 000000b0  #..main.........
 1840 05000000 000040a0 06000000 00004002  ......@.......@.
 1850 90231a73 697a655f 740008c7 fd0a0000  .#.size_t.......
 1860 066c6f6e 6720756e 7369676e 65642069  .long unsigned i
 1870 6e740008 071a5f5f 755f6368 61720002  nt....__u_char..
 1880 20660500 001a5f5f 755f7368 6f727400   f....__u_short.
 1890 0221270a 00001a5f 5f755f69 6e740002  .!'....__u_int..
 18a0 22420b00 0006756e 7369676e 65642069  "B....unsigned i
 18b0 6e740004 071a5f5f 755f6c6f 6e670002  nt....__u_long..
 18c0 23fd0a00 001a5f5f 755f7175 61645f74  #.....__u_quad_t
 18d0 000224fd 0a00001a 5f5f7175 61645f74  ..$.....__quad_t
 18e0 00022584 0b000006 6c6f6e67 20696e74  ..%.....long int
 18f0 0008051a 5f5f696e 74385f74 0002263d  ....__int8_t..& 1900 0a00001a 5f=
5f7569 6e74385f 74000227  ....__uint8_t..'
 1910 66050000 1a5f5f69 6e743136 5f740002  f....__int16_t..
 1920 28c20b00 00067368 6f727420 696e7400  (.....short int.
 1930 02051a5f 5f75696e 7431365f 74000229  ...__uint16_t..)
 1940 270a0000 1a5f5f69 6e743332 5f740002  '....__int32_t..
 1950 2a870000 001a5f5f 75696e74 33325f74  *.....__uint32_t
 1960 00022b42 0b00001a 5f5f696e 7436345f  ..+B....__int64_
 1970 7400022c 840b0000 1a5f5f75 696e7436  t..,.....__uint6
 1980 345f7400 022dfd0a 00001a5f 5f716164  4_t..-.....__qad
 1990 64725f74 00022e38 0c00000e 08740b00  dr_t...8.....t..
 19a0 001a5f5f 6465765f 74000230 150c0000  ..__dev_t..0....
 19b0 1a5f5f75 69645f74 000231f2 0b00001a  .__uid_t..1.....
 19c0 5f5f6769 645f7400 0232f20b 00001a5f  __gid_t..2....._
 19d0 5f696e6f 5f740002 33150c00 001a5f5f  _ino_t..3.....__
 19e0 696e6f36 345f7400 0234150c 00001a5f  ino64_t..4....._
 19f0 5f6d6f64 655f7400 0235f20b 00001a5f  _mode_t..5....._
 1a00 5f6e6c69 6e6b5f74 00023615 0c00001a  _nlink_t..6.....
 1a10 5f5f6f66 665f7400 0237040c 00001a5f  __off_t..7....._
 1a20 5f6f6666 36345f74 00023804 0c00001a  _off64_t..8.....
 1a30 5f5f6c6f 66665f74 00023904 0c00001a  __loff_t..9.....
 1a40 5f5f7069 645f7400 023ae10b 00001a5f  __pid_t..:....._
 1a50 5f737369 7a655f74 00023b04 0c00001a  _ssize_t..;.....
 1a60 5f5f726c 696d5f74 00023c15 0c00001a  __rlim_t..<.....
 1a70 5f5f726c 696d3634 5f740002 3d150c00  __rlim64_t..=3D...
 1a80 001a5f5f 626c6b63 6e745f74 00023e04  ..__blkcnt_t..>.
 1a90 0c00001a 5f5f626c 6b636e74 36345f74  ....__blkcnt64_t
 1aa0 00023f04 0c00001a 5f5f6673 626c6b63  ..?.....__fsblkc
 1ab0 6e745f74 00024015 0c00001a 5f5f6673  nt_t..@.....__fs
 1ac0 626c6b63 6e743634 5f740002 41150c00  blkcnt64_t..A...
 1ad0 001a5f5f 66736669 6c636e74 5f740002  ..__fsfilcnt_t..
 1ae0 42150c00 001a5f5f 66736669 6c636e74  B.....__fsfilcnt
 1af0 36345f74 00024315 0c00001a 5f5f6964  64_t..C.....__id
 1b00 5f740002 44f20b00 001a5f5f 66736964  _t..D.....__fsid
 1b10 5f740002 49490000 001a5f5f 64616464  _t..II....__dadd
 1b20 725f7400 024c8700 00001a5f 5f636164  r_t..L.....__cad
 1b30 64725f74 00024d0a 0600001a 5f5f7469  dr_t..M.....__ti
 1b40 6d655f74 00024e84 0b00001a 5f5f7573  me_t..N.....__us
 1b50 65636f6e 64735f74 00024f42 0b00001a  econds_t..OB....
 1b60 5f5f7375 7365636f 6e64735f 74000250  __suseconds_t..P
 1b70 840b0000 1a5f5f73 77626c6b 5f740002  .....__swblk_t..
 1b80 51840b00 001a5f5f 636c6f63 6b5f7400  Q.....__clock_t.
 1b90 0252840b 00001a5f 5f6b6579 5f740002  .R.....__key_t..
 1ba0 53870000 001a5f5f 636c6f63 6b69645f  S.....__clockid_
 1bb0 74000256 87000000 1a5f5f74 696d6572  t..V.....__timer
 1bc0 5f740002 59870000 001a5f5f 6970635f  _t..Y.....__ipc_
 1bd0 7069645f 7400025c 87000000 1a5f5f62  pid_t..\.....__b
 1be0 6c6b7369 7a655f74 00025f84 0b00001a  lksize_t.._.....
 1bf0 5f5f745f 7363616c 61725f74 00026687  __t_scalar_t..f.
 1c00 0000001a 5f5f745f 75736361 6c61725f  ....__t_uscalar_
 1c10 74000267 420b0000 1a5f5f69 6e747074  t..gB....__intpt
 1c20 725f7400 026a840b 00001a5f 5f736f63  r_t..j.....__soc
 1c30 6b6c656e 5f740002 6d420b00 001a4649  klen_t..mB....FI
 1c40 4c450007 2d6b0700 001a5f5f 46494c45  LE..-k....__FILE
 1c50 0007376b 0700001b 77636861 725f7400  ..7k....wchar_t.
 1c60 081f0187 0000001b 77696e74 5f740008  ........wint_t..
 1c70 3801420b 00001a5f 5f6d6273 74617465  8.B....__mbstate
 1c80 5f740003 4bd40000 001a5f47 5f66706f  _t..K....._G_fpo
 1c90 735f7400 041e0101 00001a5f 475f6670  s_t........_G_fp
 1ca0 6f733634 5f740004 23370100 001a5f5f  os64_t..#7....__
 1cb0 67636f6e 765f6663 74000547 5d0f0000  gconv_fct..G]...
 1cc0 0e081006 00001a5f 5f67636f 6e765f69  .......__gconv_i
 1cd0 6e69745f 66637400 054a7b0f 00000e08  nit_fct..J{.....
 1ce0 49060000 1a5f5f67 636f6e76 5f656e64  I....__gconv_end
 1cf0 5f666374 00054b98 0f00000e 085f0600  _fct..K......_..
 1d00 001a5f5f 67636f6e 765f7472 616e735f  ..__gconv_trans_
 1d10 66637400 0554b70f 00000e08 09030000  fct..T..........
 1d20 1a5f5f67 636f6e76 5f747261 6e735f63  .__gconv_trans_c
 1d30 6f6e7465 78745f66 63740005 59de0f00  ontext_fct..Y...
 1d40 000e089f 0500001a 5f5f6763 6f6e765f  ........__gconv_
 1d50 7472616e 735f7175 6572795f 66637400  trans_query_fct.
 1d60 055d0310 00000e08 09100000 0c231000  .]...........#..
 1d70 00018700 00000dff 0500000d 23100000  ............#...
 1d80 0d890500 00000e08 29100000 0e08ff05  ........).......
 1d90 00001a5f 5f67636f 6e765f74 72616e73  ...__gconv_trans
 1da0 5f696e69 745f6663 74000560 4d100000  _init_fct..`M...
 1db0 0e085310 00000c68 10000001 87000000  ..S....h........
 1dc0 0d681000 000dff05 0000000e 08590500  .h...........Y..
 1dd0 001a5f5f 67636f6e 765f7472 616e735f  ..__gconv_trans_
 1de0 656e645f 66637400 05618b10 00000e08  end_fct..a......
 1df0 c9050000 1a5f5f67 636f6e76 5f740005  .....__gconv_t..
 1e00 aca21000 000e0877 0600001a 5f475f69  .......w...._G_i
 1e10 636f6e76 5f740004 35fb0600 001a5f47  conv_t..5....._G
 1e20 5f696e74 31365f74 000437c2 0b00001a  _int16_t..7.....
 1e30 5f475f69 6e743332 5f740004 38870000  _G_int32_t..8...
 1e40 001a5f47 5f75696e 7431365f 74000439  .._G_uint16_t..9
 1e50 270a0000 1a5f475f 75696e74 33325f74  '...._G_uint32_t
 1e60 00043a42 0b00001a 5f5f676e 75635f76  ..:B....__gnuc_v
 1e70 615f6c69 73740009 2b1a1100 000f0812  a_list..+.......
 1e80 5f494f5f 6a756d70 5f740001 1c5f494f  _IO_jump_t..._IO
 1e90 5f6c6f63 6b5f7400 06aa1b5f 494f5f46  _lock_t...._IO_F
 1ea0 494c4500 0641016b 07000012 5f494f5f  ILE..A.k...._IO_
 1eb0 46494c45 5f706c75 7300011b 5f5f696f  FILE_plus...__io
 1ec0 5f726561 645f666e 00065801 6d110000  _read_fn..X.m...
 1ed0 0c871100 0001eb0c 00000d59 0500000d  ...........Y....
 1ee0 0a060000 0def0a00 00001b5f 5f696f5f  ...........__io_
 1ef0 77726974 655f666e 00066101 9d110000  write_fn..a.....
 1f00 0cb71100 0001eb0c 00000d59 0500000d  ...........Y....
 1f10 ff050000 0def0a00 00001b5f 5f696f5f  ...........__io_
 1f20 7365656b 5f666e00 066901cc 1100000c  seek_fn..i......
 1f30 e6110000 01870000 000d5905 00000de6  ..........Y.....
 1f40 1100000d 87000000 000e08bb 0c00001b  ................
 1f50 5f5f696f 5f636c6f 73655f66 6e00066c  __io_close_fn..l
 1f60 01021200 000c1212 00000187 0000000d  ................
 1f70 59050000 001a6670 6f735f74 00075026  Y.....fpos_t..P&
 1f80 0f00001a 64697361 7373656d 626c655f  ....disassemble_
 1f90 696e666f 5f740001 066e0a00 001d6469  info_t...n....di
 1fa0 73696e66 6f000108 20120000 010903f8  sinfo... .......
 1fb0 0a000000 00006000                    ......`.       =20
Contents of section .debug_abbrev:
 0000 01110103 081b0825 08130b00 00021600  .......%........
 0010 03083a0b 3b0b4913 00000324 0003080b  ..:.;.I....$....
 0020 0b3e0b00 00040f00 0b0b4913 00000513  .>........I.....
 0030 0101130b 0b3a0b3b 0b000006 0d000308  .....:.;........
 0040 3a0b3b0b 4913380a 00000701 01011349  :.;.I.8........I
 0050 13000008 21004913 2f0b0000 09160003  ....!.I./.......
 0060 083a0b3b 05491300 000a1701 01130b0b  .:.;.I..........
 0070 3a0b3b0b 00000b0d 0003083a 0b3b0b49  :.;........:.;.I
 0080 1300000c 04010113 0b0b3a0b 3b0b0000  ..........:.;...
 0090 0d280003 081c0b00 000e1301 01130308  .(..............
 00a0 0b0b3a0b 3b0b0000 0f130003 083c0c00  ..:.;........<..
 00b0 00102600 49130000 11150101 13270c49  ..&.I........'.I
 00c0 13000012 05004913 0000130f 000b0b00  ......I.........
 00d0 00141501 0113270c 00001521 0049132f  ......'....!.I./
 00e0 07000016 34000308 3a0b3b0b 49133f0c  ....4...:.;.I.?.
 00f0 020a0000 00011101 10061201 11010308  ................
 0100 1b082508 130b0000 02130101 130b0b3a  ..%............:
 0110 0b3b0b00 00030d00 03083a0b 3b0b4913  .;........:.;.I.
 0120 380a0000 04010101 13491300 00052100  8........I....!.
 0130 49132f0b 00000624 0003080b 0b3e0b00  I./....$.....>..
 0140 00071701 01130b0b 3a0b3b0b 0000080d  ........:.;.....
 0150 0003083a 0b3b0b49 13000009 04010113  ...:.;.I........
 0160 0b0b3a0b 3b0b0000 0a280003 081c0b00  ..:.;....(......
 0170 000b1301 01130308 0b0b3a0b 3b0b0000  ..........:.;...
 0180 0c150101 13270c49 1300000d 05004913  .....'.I......I.
 0190 00000e0f 000b0b49 1300000f 0f000b0b  .......I........
 01a0 00001026 00491300 00111501 0113270c  ...&.I........'.
 01b0 00001213 0003083c 0c000013 21004913  .......<....!.I.
 01c0 0000140d 0003083a 0b3b0549 13380a00  .......:.;.I.8..
 01d0 00150401 01130308 0b0b3a0b 3b0b0000  ..........:.;...
 01e0 16150101 13000017 18000000 182e003f  ...............?
 01f0 0c03083a 0b3b0b27 0c110112 01400a00  ...:.;.'.....@..
 0200 00192e00 3f0c0308 3a0b3b0b 270c4913  ....?...:.;.'.I.
 0210 11011201 400a0000 1a160003 083a0b3b  ....@........:.;
 0220 0b491300 001b1600 03083a0b 3b054913  .I........:.;.I.
 0230 00001c16 0003083a 0b3b0b00 001d3400  .......:.;....4.
 0240 03083a0b 3b0b4913 3f0c020a 000000    ..:.;.I.?......=20
Contents of section .debug_line:
 0000 8a010000 02005f01 00000101 fb0e0a00  ......_.........
 0010 01010101 00000001 00746573 742e6300  .........test.c.
 0020 0000002f 7573722f 6c6f6361 6c2f696e  .../usr/local/in
 0030 636c7564 652f6269 74732f74 79706573  clude/bits/types
 0040 2e680000 00002f75 73722f6c 6f63616c  .h..../usr/local
 0050 2f696e63 6c756465 2f776368 61722e68  /include/wchar.h
 0060 00000000 2f757372 2f6c6f63 616c2f69  ..../usr/local/i
 0070 6e636c75 64652f5f 475f636f 6e666967  nclude/_G_config
 0080 2e680000 00002f75 73722f6c 6f63616c  .h..../usr/local
 0090 2f696e63 6c756465 2f67636f 6e762e68  /include/gconv.h
 00a0 00000000 2f757372 2f6c6f63 616c2f69  ..../usr/local/i
 00b0 6e636c75 64652f6c 6962696f 2e680000  nclude/libio.h..
 00c0 00002f75 73722f6c 6f63616c 2f696e63  ../usr/local/inc
 00d0 6c756465 2f737464 696f2e68 00000000  lude/stdio.h....
 00e0 2f757372 2f6c6f63 616c2f6c 69622f67  /usr/local/lib/g
 00f0 63632d6c 69622f69 6136342d 756e6b6e  cc-lib/ia64-unkn
 0100 6f776e2d 6c696e75 782f332e 302e322f  own-linux/3.0.2/
 0110 696e636c 7564652f 73746464 65662e68  include/stddef.h
 0120 00000000 2f757372 2f6c6f63 616c2f6c  ..../usr/local/l
 0130 69622f67 63632d6c 69622f69 6136342d  ib/gcc-lib/ia64-
 0140 756e6b6e 6f776e2d 6c696e75 782f332e  unknown-linux/3.
 0150 302e322f 696e636c 7564652f 73746461  0.2/include/stda
 0160 72672e68 00000000 00000902 60050000  rg.h........`...
 0170 00000040 030a01f0 08f008d6 081e08e2  ...@............
 0180 022f1002 30100240 10021f00 0101      ./..0..@...... =20
Disassembly of section .interp:

40000000000001c8 <.interp>:
40000000000001c8:	Address 0x1c0 is out of bounds.

Disassembly of section .note.ABI-tag:

40000000000001e0 <.note.ABI-tag>:
40000000000001e0:	04 00 00 00 10 00 	[MLX]       invala
40000000000001e6:	00 00 01 00 00 00 	            data8 0x0aa9c8e00
40000000000001ec:	47 4e 55 00=20
40000000000001f0:	00 00 00 00 02 00 	[MII]       data8 0x010000000
40000000000001f6:	00 00 04 00 00 00 	            break.i 0x4000
40000000000001fc:	00 00 00 00       	            break.i 0x0
Disassembly of section .hash:

4000000000000200 <.hash>:
4000000000000200:	03 00 00 00 03 00 	[MII]       data8 0x018000000
4000000000000206:	00 00 00 00 00 00 	            break.i 0x0;;
400000000000020c:	02 00 00 00       	            break.i 0x10;;
4000000000000210:	01 00 00 00 00 00 	[MII]       break.m 0x0
	...
Disassembly of section .dynsym:

4000000000000220 <.dynsym>:
	...
4000000000000238:	0d 00 00 00 12 00 	            break.i 0xd000
	...
400000000000024e:	00 00 14 00       	            break.i 0x0
4000000000000252:	00 00 12 00 00 00 	[-a-]       data8 0x090000000
	...
Disassembly of section .dynstr:

4000000000000268 <.dynstr>:
4000000000000268:	Address 0x260 is out of bounds.

Disassembly of section .gnu.version:

4000000000000298 <.gnu.version>:
4000000000000298:	Address 0x290 is out of bounds.

Disassembly of section .gnu.version_r:

40000000000002a0 <.gnu.version_r>:
40000000000002a0:	01 00 01 00 01 00 	[MII]       nop.m 0x20
40000000000002a6:	00 00 10 00 00 00 	            break.i 0x10000
40000000000002ac:	00 00 00 00       	            break.i 0x0;;
40000000000002b0:	12 69 69 0d 00 00 	[MBB] (p08) break.m 0x1ad2d
40000000000002b6:	02 00 26 00 00 00 	      (p08) break.b 0x26000
40000000000002bc:	00 00 00 00       	            break.b 0x0
Disassembly of section .rela.IA_64.pltoff:

40000000000002c0 <.rela.IA_64.pltoff>:
40000000000002c0:	d0 0a 00 00 00 00 	[MIB] (p22) break.m 0x1
40000000000002c6:	00 60 81 00 00 00 	            break.i 0x81600
40000000000002cc:	01 00 00 00       	            break.b 0x8
	...
40000000000002d8:	e0 0a 00 00 00 00 	            data8 0x02b800000
40000000000002de:	00 60 81 00       	            data8 0xc000000000
40000000000002e2:	00 00 02 00 00 00 	[MII]       data8 0x010000004
	...
Disassembly of section .init:

40000000000002f0 <_init>:
40000000000002f0:	00 10 0d 06 80 05 	[MII]       alloc r34=3Dar.pfs,3,3,0
40000000000002f6:	00 02 30 00 42 20 	            mov r32=3Dr12
40000000000002fc:	04 00 c4 00       	            mov r33=B0
4000000000000300:	0d 60 c0 19 3f 23 	[MFI]       adds r12=3D-16,r12
4000000000000306:	00 00 00 02 00 c0 	            nop.f 0x0
400000000000030c:	81 0c 00 90       	            addl r14r,r1;;
4000000000000310:	0a 78 00 1c 18 10 	[MMI]       ld8 r15=3D[r14];;
4000000000000316:	60 00 3c 0e 72 00 	            cmp.eq p6,p7=3D0,r15
400000000000031c:	00 00 04 00       	            nop.i 0x0
4000000000000320:	1c 00 00 00 01 00 	[MFB]       nop.m 0x0
4000000000000326:	00 00 00 02 00 03 	            nop.f 0x0
400000000000032c:	30 00 00 42       	      (p06) br.cond.dptk.few 400000000=
0000350 <_init+0x60>
4000000000000330:	1d 80 07 18 99 17 	[MFB]       st8 [r12]=3Dr1,-16
4000000000000336:	00 00 00 02 00 00 	            nop.f 0x0
400000000000033c:	08 00 00 50       	            br.call.sptk.many b0@00000=
000000330 <_init+0x40>;;
4000000000000340:	0b 60 40 18 00 21 	[MMI]       adds r12=16,r12;;
4000000000000346:	10 00 30 30 20 00 	            ld8 r1=3D[r12]
400000000000034c:	00 00 04 00       	            nop.i 0x0;;
4000000000000350:	04 00 00 00 01 00 	[MLX]       nop.m 0x0
4000000000000356:	00 00 00 00 00 40 	            movl r2=3D0x340
400000000000035c:	00 04 18 60=20
4000000000000360:	03 00 00 00 01 00 	[MII]       nop.m 0x0
4000000000000366:	30 00 00 60 00 40 	            mov r3=3Dip;;
400000000000036c:	20 18 00 80       	            add r2=3Dr2,r3;;
4000000000000370:	11 00 00 00 01 00 	[MIB]       nop.m 0x0
4000000000000376:	60 10 04 80 03 00 	            mov b6=3Dr2
400000000000037c:	68 00 00 10       	            br.call.sptk.many b0=B6;;
4000000000000380:	00 60 00 40 00 21 	[MII]       mov r12=3Dr32
4000000000000386:	00 10 01 55 00 00 	            mov.i ar.pfs=3Dr34
400000000000038c:	10 0a 00 07       	            mov b0=3Dr33
4000000000000390:	1d 00 00 00 01 00 	[MFB]       nop.m 0x0
4000000000000396:	00 00 00 02 00 80 	            nop.f 0x0
400000000000039c:	08 00 84 00       	            br.ret.sptk.many b0;;
Disassembly of section .plt:

40000000000003a0 <.plt>:
40000000000003a0:	0b 10 00 1c 00 21 	[MMI]       mov r2=3Dr14;;
40000000000003a6:	e0 00 08 00 48 00 	            addl r14=3D0,r2
40000000000003ac:	00 00 04 00       	            nop.i 0x0;;
40000000000003b0:	0b 80 20 1c 18 14 	[MMI]       ld8 r16=3D[r14],8;;
40000000000003b6:	10 41 38 30 28 00 	            ld8 r17=3D[r14],8
40000000000003bc:	00 00 04 00       	            nop.i 0x0;;
40000000000003c0:	11 08 00 1c 18 10 	[MIB]       ld8 r1=3D[r14]
40000000000003c6:	60 88 04 80 03 00 	            mov b6=3Dr17
40000000000003cc:	60 00 80 00       	            br.few b6;;
40000000000003d0:	11 78 00 00 00 24 	[MIB]       mov r15=3D0
40000000000003d6:	00 00 00 02 00 00 	            nop.i 0x0
40000000000003dc:	d0 ff ff 48       	            br.few 40000000000003a0 <_=
init+0xb0>;;
40000000000003e0:	11 78 04 00 00 24 	[MIB]       mov r15=3D1
40000000000003e6:	00 00 00 02 00 00 	            nop.i 0x0
40000000000003ec:	c0 ff ff 48       	            br.few 40000000000003a0 <_=
init+0xb0>;;
	...
4000000000000400:	0b 78 60 03 03 24 	[MMI]       addl r15G2,r1;;
4000000000000406:	00 41 3c 30 28 c0 	            ld8 r16=3D[r15],8
400000000000040c:	01 08 00 84       	            mov r14=3Dr1;;
4000000000000410:	11 08 00 1e 18 10 	[MIB]       ld8 r1=3D[r15]
4000000000000416:	60 80 04 80 03 00 	            mov b6=3Dr16
400000000000041c:	60 00 80 00       	            br.few b6;;
4000000000000420:	0b 78 a0 03 03 24 	[MMI]       addl r15H8,r1;;
4000000000000426:	00 41 3c 30 28 c0 	            ld8 r16=3D[r15],8
400000000000042c:	01 08 00 84       	            mov r14=3Dr1;;
4000000000000430:	11 08 00 1e 18 10 	[MIB]       ld8 r1=3D[r15]
4000000000000436:	60 80 04 80 03 00 	            mov b6=3Dr16
400000000000043c:	60 00 80 00       	            br.few b6;;
Disassembly of section .text:

4000000000000440 <_start>:
4000000000000440:	04 10 1c 00 80 45 	[MLX]       alloc r2=3Dar.pfs,7,0,0
4000000000000446:	02 4c 80 09 00 60 	            movl r3=3D0x9804c0270033f
400000000000044c:	f0 13 1a 60=20
4000000000000450:	05 10 41 18 00 e1 	[MLX]       adds r34=16,r12
4000000000000456:	ff ff ff ff 5f 20 	            movl r1=3D0xdffffffffffffb=
68;;
400000000000045c:	80 f6 db 6f=20
4000000000000460:	09 08 21 44 18 14 	[MMI]       ld8 r33=3D[r34],8
4000000000000466:	a0 00 44 44 08 20 	            mov.m r10=3Dar.bsp
400000000000046c:	01 00 c0 00       	            mov r9=3Dip;;
4000000000000470:	01 00 0c 50 2a 04 	[MII]       mov.m ar.fpsr=3Dr3
4000000000000476:	10 48 04 0a 40 c0 	            sub r1=3Dr9,r1
400000000000047c:	04 61 00 84       	            adds r38=16,r12;;
4000000000000480:	01 58 00 03 00 24 	[MII]       addl r11d,r1
4000000000000486:	00 82 05 00 48 60 	            addl r32H,r1
400000000000048c:	84 0a 00 90       	            addl r35@,r1;;
4000000000000490:	09 18 00 16 18 10 	[MMI]       ld8 r3=3D[r11]
4000000000000496:	00 02 80 30 20 80 	            ld8 r32=3D[r32]
400000000000049c:	84 0b 00 90       	            addl r36V,r1;;
40000000000004a0:	08 18 01 46 18 10 	[MMI]       ld8 r35=3D[r35]
40000000000004a6:	40 02 90 30 20 80 	            ld8 r36=3D[r36]
40000000000004ac:	00 00 00 84       	            mov r4=3Dr0
40000000000004b0:	10 00 28 06 98 11 	[MIB]       st8 [r3]=3Dr10
40000000000004b6:	50 02 20 00 42 00 	            mov r37=3Dr8
40000000000004bc:	70 ff ff 58       	            br.call.sptk.few b0@000000=
00000420 <_init+0x130>
40000000000004c0:	11 00 00 00 00 00 	[MIB]       break.m 0x0
40000000000004c6:	00 00 00 02 00 00 	            nop.i 0x0
40000000000004cc:	00 00 00 20       	            nop.b 0x0;;
40000000000004d0:	0c 00 00 00 01 00 	[MFI]       nop.m 0x0
40000000000004d6:	00 00 00 02 00 00 	            nop.f 0x0
40000000000004dc:	00 00 04 00       	            nop.i 0x0

40000000000004e0 <__do_global_dtors_aux>:
40000000000004e0:	00 18 15 08 80 05 	[MII]       alloc r35=3Dar.pfs,5,4,0
40000000000004e6:	00 42 06 06 48 20 	            addl r32E6,r1
40000000000004ec:	04 00 c4 00       	            mov r33=B0
40000000000004f0:	11 10 01 02 00 21 	[MIB]       mov r34=3Dr1
40000000000004f6:	00 00 00 02 00 00 	            nop.i 0x0
40000000000004fc:	30 00 00 40       	            br.few 4000000000000520 <_=
_do_global_dtors_aux+0x40>;;
4000000000000500:	09 00 3c 40 98 11 	[MMI]       st8 [r32]=3Dr15
4000000000000506:	10 41 40 30 28 00 	            ld8 r17=3D[r16],8
400000000000050c:	00 00 04 00       	            nop.i 0x0;;
4000000000000510:	10 08 00 20 18 10 	[MIB]       ld8 r1=3D[r16]
4000000000000516:	60 88 04 80 03 00 	            mov b6=3Dr17
400000000000051c:	68 00 00 10       	            br.call.sptk.many b0=B6
4000000000000520:	0b 78 00 40 18 10 	[MMI]       ld8 r15=3D[r32];;
4000000000000526:	00 41 3c 30 28 00 	            ld8 r16=3D[r15],8
400000000000052c:	00 00 04 00       	            nop.i 0x0;;
4000000000000530:	1c 00 00 20 06 38 	[MFB]       cmp.eq p0,p6=3Dr0,r16
4000000000000536:	00 00 00 02 00 03 	            nop.f 0x0
400000000000053c:	d0 ff ff 48       	      (p06) br.cond.sptk.few 400000000=
0000500 <__do_global_dtors_aux+0x20>
4000000000000540:	00 08 00 44 00 21 	[MII]       mov r1=3Dr34
4000000000000546:	00 08 05 80 03 00 	            mov b0=3Dr33
400000000000054c:	30 02 aa 00       	            mov.i ar.pfs=3Dr35
4000000000000550:	17 20 02 00 21 00 	[BBB]       br.ret.sptk.many b0
4000000000000556:	00 00 00 00 10 00 	            nop.b 0x0
400000000000055c:	00 00 00 20       	            nop.b 0x0;;

4000000000000560 <my_printf>:
4000000000000560:	00 10 15 08 80 05 	[MII]       alloc r34=3Dar.pfs,5,4,0
4000000000000566:	30 02 30 00 42 20 	            mov r35=3Dr12
400000000000056c:	04 00 c4 00       	            mov r33=B0
4000000000000570:	0a 70 40 03 00 24 	[MMI]       addl r14=80,r1;;
4000000000000576:	40 02 38 30 20 00 	            ld8 r36=3D[r14]
400000000000057c:	04 08 00 84       	            mov r32=3Dr1
4000000000000580:	1d 00 00 00 01 00 	[MFB]       nop.m 0x0
4000000000000586:	00 00 00 02 00 00 	            nop.f 0x0
400000000000058c:	88 fe ff 58       	            br.call.sptk.many b0@00000=
000000400 <_init+0x110>;;
4000000000000590:	00 08 00 40 00 21 	[MII]       mov r1=3Dr32
4000000000000596:	00 10 01 55 00 00 	            mov.i ar.pfs=3Dr34
400000000000059c:	10 0a 00 07       	            mov b0=3Dr33
40000000000005a0:	1d 60 00 46 00 21 	[MFB]       mov r12=3Dr35
40000000000005a6:	00 00 00 02 00 80 	            nop.f 0x0
40000000000005ac:	08 00 84 00       	            br.ret.sptk.many b0;;

40000000000005b0 <main>:
40000000000005b0:	00 10 19 08 80 05 	[MII]       alloc r34=3Dar.pfs,6,4,0
40000000000005b6:	30 02 30 00 42 80 	            mov r35=3Dr12
40000000000005bc:	01 67 fc 8c       	            adds r12=3D-16,r12
40000000000005c0:	01 00 00 00 01 00 	[MII]       nop.m 0x0
40000000000005c6:	10 02 00 62 00 c0 	            mov r33=B0
40000000000005cc:	01 0a 00 90       	            addl r142,r1;;
40000000000005d0:	0d 78 00 1c 18 10 	[MFI]       ld8 r15=3D[r14]
40000000000005d6:	00 00 00 02 00 c0 	            nop.f 0x0
40000000000005dc:	81 09 00 90       	            addl r14$,r1;;
40000000000005e0:	0b 70 00 1c 18 10 	[MMI]       ld8 r14=3D[r14];;
40000000000005e6:	00 70 3c 30 23 c0 	            st8 [r15]=3Dr14
40000000000005ec:	81 0d 00 90       	            addl r14=88,r1;;
40000000000005f0:	0d 20 01 1c 18 10 	[MFI]       ld8 r36=3D[r14]
40000000000005f6:	00 00 00 02 00 c0 	            nop.f 0x0
40000000000005fc:	81 09 00 90       	            addl r14$,r1;;
4000000000000600:	11 28 01 1c 18 10 	[MIB]       ld8 r37=3D[r14]
4000000000000606:	00 02 04 00 42 00 	            mov r32=3Dr1
400000000000060c:	08 fe ff 58       	            br.call.sptk.many b0@00000=
000000400 <_init+0x110>;;
4000000000000610:	0b 08 00 40 00 21 	[MMI]       mov r1=3Dr32;;
4000000000000616:	e0 00 07 00 48 00 	            addl r14=96,r1
400000000000061c:	00 00 04 00       	            nop.i 0x0;;
4000000000000620:	0d 20 01 1c 18 10 	[MFI]       ld8 r36=3D[r14]
4000000000000626:	00 00 00 02 00 c0 	            nop.f 0x0
400000000000062c:	01 0a 00 90       	            addl r142,r1;;
4000000000000630:	1c 28 01 1c 18 10 	[MFB]       ld8 r37=3D[r14]
4000000000000636:	00 00 00 02 00 00 	            nop.f 0x0
400000000000063c:	d8 fd ff 58       	            br.call.sptk.many b0@00000=
000000400 <_init+0x110>
4000000000000640:	0b 08 00 40 00 21 	[MMI]       mov r1=3Dr32;;
4000000000000646:	f0 00 05 00 48 00 	            addl r152,r1
400000000000064c:	00 00 04 00       	            nop.i 0x0;;
4000000000000650:	0b 70 00 1e 18 10 	[MMI]       ld8 r14=3D[r15];;
4000000000000656:	e0 00 38 30 20 00 	            ld8 r14=3D[r14]
400000000000065c:	00 00 04 00       	            nop.i 0x0;;
4000000000000660:	0d 78 00 1c 18 10 	[MFI]       ld8 r15=3D[r14]
4000000000000666:	00 00 00 02 00 c0 	            nop.f 0x0
400000000000066c:	81 70 00 84       	            adds r14=3D8,r14;;
4000000000000670:	11 08 00 1c 18 10 	[MIB]       ld8 r1=3D[r14]
4000000000000676:	60 78 04 80 03 00 	            mov b6=3Dr15
400000000000067c:	68 00 00 10       	            br.call.sptk.many b0=B6;;
4000000000000680:	00 08 00 40 00 21 	[MII]       mov r1=3Dr32
4000000000000686:	00 10 01 55 00 00 	            mov.i ar.pfs=3Dr34
400000000000068c:	10 0a 00 07       	            mov b0=3Dr33
4000000000000690:	1d 60 00 46 00 21 	[MFB]       mov r12=3Dr35
4000000000000696:	00 00 00 02 00 80 	            nop.f 0x0
400000000000069c:	08 00 84 00       	            br.ret.sptk.many b0;;

40000000000006a0 <__do_global_ctors_aux>:
40000000000006a0:	01 20 15 0a 80 05 	[MII]       alloc r36=3Dar.pfs,5,5,0
40000000000006a6:	00 42 07 00 48 20 	            addl r32=104,r1
40000000000006ac:	04 00 c4 00       	            mov r33=B0;;
40000000000006b0:	0b 00 01 40 18 10 	[MMI]       ld8 r32=3D[r32];;
40000000000006b6:	30 c2 83 32 2c 40 	            ld8 r35=3D[r32],-8
40000000000006bc:	04 08 00 84       	            mov r34=3Dr1;;
40000000000006c0:	1c 30 fc 47 00 3b 	[MFB]       cmp.eq p6,p0=3D-1,r35
40000000000006c6:	00 00 00 02 00 03 	            nop.f 0x0
40000000000006cc:	40 00 00 41       	      (p06) br.cond.spnt.few 400000000=
0000700 <__do_global_ctors_aux+0x60>
40000000000006d0:	0a 78 20 46 18 14 	[MMI]       ld8 r15=3D[r35],8;;
40000000000006d6:	10 00 8c 30 20 c0 	            ld8 r1=3D[r35]
40000000000006dc:	f0 08 00 07       	            mov b6=3Dr15
40000000000006e0:	1d 18 e1 41 19 16 	[MFB]       ld8 r35=3D[r32],-8
40000000000006e6:	00 00 00 02 00 00 	            nop.f 0x0
40000000000006ec:	68 00 00 10       	            br.call.sptk.many b0=B6;;
40000000000006f0:	1c 00 fc 47 06 3b 	[MFB]       cmp.eq p0,p6=3D-1,r35
40000000000006f6:	00 00 00 02 00 03 	            nop.f 0x0
40000000000006fc:	e0 ff ff 48       	      (p06) br.cond.sptk.few 400000000=
00006d0 <__do_global_ctors_aux+0x30>
4000000000000700:	00 08 00 44 00 21 	[MII]       mov r1=3Dr34
4000000000000706:	00 08 05 80 03 00 	            mov b0=3Dr33
400000000000070c:	40 02 aa 00       	            mov.i ar.pfs=3Dr36
4000000000000710:	17 20 02 00 21 00 	[BBB]       br.ret.sptk.many b0
4000000000000716:	00 00 00 00 10 00 	            nop.b 0x0
400000000000071c:	00 00 00 20       	            nop.b 0x0;;
Disassembly of section .fini:

4000000000000720 <_fini>:
4000000000000720:	00 10 0d 06 80 05 	[MII]       alloc r34=3Dar.pfs,3,3,0
4000000000000726:	00 02 30 00 42 20 	            mov r32=3Dr12
400000000000072c:	04 00 c4 00       	            mov r33=B0
4000000000000730:	1d 60 c0 19 3f 23 	[MFB]       adds r12=3D-16,r12
4000000000000736:	00 00 00 02 00 00 	            nop.f 0x0
400000000000073c:	00 00 00 20       	            nop.b 0x0;;
4000000000000740:	04 00 00 00 01 c0 	[MLX]       nop.m 0x0
4000000000000746:	ff ff ff ff 7f 40 	            movl r2=3D0xfffffffffffffd=
90
400000000000074c:	00 f1 ef 6f=20
4000000000000750:	03 00 00 00 01 00 	[MII]       nop.m 0x0
4000000000000756:	30 00 00 60 00 40 	            mov r3=3Dip;;
400000000000075c:	20 18 00 80       	            add r2=3Dr2,r3;;
4000000000000760:	11 00 00 00 01 00 	[MIB]       nop.m 0x0
4000000000000766:	60 10 04 80 03 00 	            mov b6=3Dr2
400000000000076c:	68 00 00 10       	            br.call.sptk.many b0=B6;;
4000000000000770:	00 60 00 40 00 21 	[MII]       mov r12=3Dr32
4000000000000776:	00 10 01 55 00 00 	            mov.i ar.pfs=3Dr34
400000000000077c:	10 0a 00 07       	            mov b0=3Dr33
4000000000000780:	1d 00 00 00 01 00 	[MFB]       nop.m 0x0
4000000000000786:	00 00 00 02 00 80 	            nop.f 0x0
400000000000078c:	08 00 84 00       	            br.ret.sptk.many b0;;
Disassembly of section .rodata:

4000000000000790 <.rodata>:
4000000000000790:	48 65 6c 6c 6f 20 	[MMI]       data8 0x1037b63632a
4000000000000796:	57 6f 72 6c 64 0a 	      (p28) cmp.le.and p53,p54=3Dr0,r28
400000000000079c:	00 00 00 00       	      (p20) break.i 0x0
40000000000007a0:	6d 79 5f 70 72 69 	[MFI]       data8 0x14b9382fbcb
40000000000007a6:	6e 74 66 20 69 73 	      (p57) fnma.d.s1 f70=F25,f16,f78
40000000000007ac:	20 61 74 20       	            data8 0x40e8c240e6
40000000000007b0:	30 78 25 6c 6c 78 	[MIB] (p01) cmp.eq.or.andcm p47,p44=3D=
r9,r54
40000000000007b6:	2e 0a 00 00 00 00 	      (p57) break.i 0xa2
40000000000007bc:	00 00 00 00       	            break.b 0x0
40000000000007c0:	64 69 73 69 6e 66 	[MLX] (p11) mov r109=3D-1231012
40000000000007c6:	6f 20 69 73 20 61 	            data8 0xf06040e8c2
40000000000007cc:	74 20 30 78=20
40000000000007d0:	Address 0x7d0 is out of bounds.

Disassembly of section .opd:

40000000000007e0 <.opd>:
40000000000007e0:	60 05 00 00 00 00 	[MII] (p43) break.m 0x0
40000000000007e6:	00 40 f8 08 00 00 	            data8 0x023e10000
40000000000007ec:	00 00 00 60       	            data8 0xc000000000
40000000000007f0:	f0 02 00 00 00 00 	[MIB] (p23) break.m 0x0
40000000000007f6:	00 40 f8 08 00 00 	            data8 0x023e10000
40000000000007fc:	00 00 00 60       	            data8 0xc000000000
4000000000000800:	b0 05 00 00 00 00 	[MIB] (p45) break.m 0x0
4000000000000806:	00 40 f8 08 00 00 	            data8 0x023e10000
400000000000080c:	00 00 00 60       	            data8 0xc000000000
4000000000000810:	20 07 00 00 00 00 	[MII] (p57) break.m 0x0
4000000000000816:	00 40 f8 08 00 00 	            data8 0x023e10000
400000000000081c:	00 00 00 60       	            data8 0xc000000000
	...
Disassembly of section .IA_64.unwind_info:

4000000000000830 <.IA_64.unwind_info>:
4000000000000830:	01 00 00 00 00 00 	[MII]       break.m 0x0
4000000000000836:	01 00 15 e4 14 b0 	            data8 0x5390540004
400000000000083c:	84 26 00 00       	      (p32) break.i 0x13425;;
	...
4000000000000848:	02 00 00 00 00 00 	            break.i 0x2000
400000000000084e:	01 00 47 21       	            break.i 0x80000
4000000000000852:	03 e6 00 e1 01 e4 	[-3-]       data8 0x1080730190a
4000000000000858:	02 2c c0 02 00 00 	            data8 0x100b00b9007
	...
4000000000000866:	00 00 02 00 00 00 	            break.i 0x2000
400000000000086c:	00 00 01 00       	            break.i 0x80000
4000000000000870:	47 21 05 e6 00 e1 	[-3-]       data8 0x1080730290a
4000000000000876:	01 e4 04 61 28 c0 	            data8 0xa184139007
400000000000087c:	02 00 00 00       	            data8 0x000000580
	...
Disassembly of section .IA_64.unwind:

4000000000000888 <.IA_64.unwind>:
4000000000000888:	Address 0x880 is out of bounds.

Disassembly of section .data:

60000000000008d0 <__data_start>:
60000000000008d0:	Address 0x8d0 is out of bounds.

Disassembly of section .ctors:

60000000000008d8 <__CTOR_LIST__>:
60000000000008d8:	Address 0x8d0 is out of bounds.


60000000000008e0 <__CTOR_END__>:
	...
Disassembly of section .dtors:

60000000000008e8 <__DTOR_LIST__>:
60000000000008e8:	Address 0x8e0 is out of bounds.


60000000000008f0 <__DTOR_END__>:
	...
Disassembly of section .got:

60000000000008f8 <_GLOBAL_OFFSET_TABLE_>:
	...
6000000000000910:	e0 07 00 00 00 00 	[MII] (p63) break.m 0x0
6000000000000916:	00 40 f8 0a 00 00 	            data8 0x02be10000
600000000000091c:	00 00 00 60       	            data8 0xc000000000
6000000000000920:	f0 07 00 00 00 00 	[MIB] (p63) break.m 0x0
6000000000000926:	00 40 00 08 00 00 	            data8 0x020010000
600000000000092c:	00 00 00 40       	            br.few 6000000000000920 <_=
GLOBAL_OFFSET_TABLE_+0x28>
6000000000000930:	10 08 00 00 00 00 	[MIB]       break.m 0x1
6000000000000936:	00 40 f0 0a 00 00 	            data8 0x02bc10000
600000000000093c:	00 00 00 60       	            data8 0xc000000000
	...
6000000000000948:	90 07 00 00 00 00 	            data8 0x01e400000
600000000000094e:	00 40 a0 07       	            dep r0=3Dr0,r0,63,1
6000000000000952:	00 00 00 00 00 40 	[MII] (p61) break.m 0x0
6000000000000958:	c0 07 00 00 00 00 	            data8 0x01f010000
600000000000095e:	00 40 d8 08       	            dep r0=3Dr0,r0,63,1
6000000000000962:	Address 0x960 is out of bounds.

Disassembly of section .dynamic:

6000000000000968 <_DYNAMIC>:
6000000000000968:	Address 0x960 is out of bounds.

Disassembly of section .sdata:

6000000000000ab8 <_IO_stdin_used>:
6000000000000ab8:	Address 0xab0 is out of bounds.


6000000000000ac0 <dtor_ptr>:
6000000000000ac0:	Address 0xac0 is out of bounds.

Disassembly of section .IA_64.pltoff:

6000000000000ad0 <.IA_64.pltoff>:
6000000000000ad0:	d0 03 00 00 00 00 	[MIB] (p30) break.m 0x0
6000000000000ad6:	00 40 f8 08 00 00 	            data8 0x023e10000
6000000000000adc:	00 00 00 60       	            data8 0xc000000000
6000000000000ae0:	e0 03 00 00 00 00 	[MII] (p31) break.m 0x0
6000000000000ae6:	00 40 f8 08 00 00 	            data8 0x023e10000
6000000000000aec:	00 00 00 60       	            data8 0xc000000000
---------------------------------------------------------------------------=
-----
-piet


