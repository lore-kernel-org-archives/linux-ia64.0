From: Keith Owens <kaos@sgi.com>
Date: Mon, 15 Mar 2004 06:52:09 +0000
Subject: Re: 2.6.3 Heisenbug in unwind.c
Message-Id: <5515.1079333529@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2654.1077624337@ocs3.ocs.com.au>
In-Reply-To: <2654.1077624337@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>An extract of the descriptor triplets looks like this.  It seems that
>the unwind descriptors for .text and .init.text have been merged
>together, as if both sections started at the same offset.
>
>00015a00 00015a70 005ced40
>00015a80 00015b20 005ced58 
>00015ac0 00015d10 005c6828 Illegal insert, belongs to __init text
>00015b20 00015ca0 005ced70
>00015ca0 00015d30 005ced90
>00015d20 00015e50 005c6848 Illegal insert, belongs to __init text
>00015d40 00015f90 005ceda8

One step further on.  The illegal unwind descriptors are being caused
by the linker (GNU ld version 2.14.90.0.4 20030523) sometimes putting
everything from .init.text onwards in an extra output program header.
Has anybody seen this symptom before?

The error is horribly sensitive.  Deleting a single asm(nop) bundle
from a .c file is enough to move from a bad to a good link.  Rerunning
the very last ld step with no change to the input files but adding -q
to ld makes the problem go away.

Good link, with 4 program headers.

ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Intel IA-64
  Version:                           0x1
  Entry point address:               0x4008320
  Start of program headers:          64 (bytes into file)
  Start of section headers:          9240232 (bytes into file)
  Flags:                             0x50, 64-bit, constant gp
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         4
  Size of section headers:           64 (bytes)
  Number of section headers:         34
  Section header string table index: 31

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         a000000100000000  00010000
       00000000005c05b0  0000000000000000  AX       0     0     32768
  [ 2] __ex_table        PROGBITS         a0000001005c05b0  005d05b0
       0000000000002a10  0000000000000000   A       0     0     4
  [ 3] .data.patch.vtop  PROGBITS         a0000001005c2fc0  005d2fc0
       0000000000000020  0000000000000000   A       0     0     4
  [ 4] .data.patch.mckin PROGBITS         a0000001005c2fe0  005d2fe0
       0000000000000020  0000000000000000   A       0     0     4
  [ 5] .IA_64.unwind_inf PROGBITS         a0000001005c3000  005d3000
       0000000000045c08  0000000000000000   A       0     0     8
  [ 6] .IA_64.unwind     IA_64_UNWIND     a000000100608c08  00618c08
       0000000000034758  0000000000000000  AL       1     1     8
  [ 7] .rodata           PROGBITS         a00000010063d360  0064d360
       0000000000058a41  0000000000000000   A       0     0     8
  [ 8] __ksymtab         PROGBITS         a000000100695da8  006a5da8
       0000000000007480  0000000000000000   A       0     0     8
  [ 9] __ksymtab_gpl     PROGBITS         a00000010069d228  006ad228
       0000000000000170  0000000000000000   A       0     0     8
  [10] __kcrctab         PROGBITS         a00000010069d398  006ad398
       0000000000003a40  0000000000000000   A       0     0     8
  [11] __kcrctab_gpl     PROGBITS         a0000001006a0dd8  006b0dd8
       00000000000000b8  0000000000000000   A       0     0     8
  [12] __ksymtab_strings PROGBITS         a0000001006a0e90  006b0e90
       000000000000921a  0000000000000000   A       0     0     8
  [13] .opd              PROGBITS         a0000001006aa0b0  006ba0b0
       0000000000011f30  0000000000000000   A       0     0     16
  [14] .init.text        PROGBITS         a0000001006bc000  006cc000
       000000000002eb70  0000000000000000 WAX       0     0     32
  [15] .init.data        PROGBITS         a0000001006eab70  006fab70
       000000000001a0c8  0000000000000000  WA       0     0     8
  [16] .init.ramfs       PROGBITS         a000000100704c38  00714c38
       0000000000000086  0000000000000000   A       0     0     1
  [17] .init.setup       PROGBITS         a000000100704cc0  00714cc0
       0000000000000290  0000000000000000  WA       0     0     8
  [18] .kdb_initcall.ini PROGBITS         a000000100704f50  00714f50
       0000000000000010  0000000000000000  WA       0     0     8
  [19] __param           PROGBITS         a000000100704f60  00714f60
       00000000000004d8  0000000000000000   A       0     0     8
  [20] .initcall.init    PROGBITS         a000000100705438  00715438
       0000000000000348  0000000000000000  WA       0     0     8
  [21] .con_initcall.ini PROGBITS         a000000100705780  00715780
       0000000000000010  0000000000000000  WA       0     0     8
  [22] .data.init_task   PROGBITS         a000000100708000  00718000
       0000000000008000  0000000000000000  WA       0     0     16
  [23] .data.page_aligne PROGBITS         a000000100710000  00720000
       000000000000c710  0000000000000000 WAX       0     0     1
  [24] .data.cacheline_a PROGBITS         a000000100720000  00730000
       000000000000cd00  0000000000000000  WA       0     0     128
  [25] .data.percpu      PROGBITS         ffffffffffff0000  00740000
       0000000000009278  0000000000000000  WA       0     0     128
  [26] .data             PROGBITS         a000000100740000  00750000
       000000000016cb97  0000000000000000  WA       0     0     128
  [27] .got              PROGBITS         a0000001008acba0  008bcba0
       0000000000011648  0000000000000000 WAp       0     0     8
  [28] .sdata            PROGBITS         a0000001008be1e8  008ce1e8
       0000000000001b18  0000000000000000 WAp       0     0     8
  [29] .sbss             NOBITS           a0000001008bfd00  008cfd00
       00000000000011e8  0000000000000000 WAp       0     0     8
  [30] .bss              NOBITS           a0000001008c0f00  008cfd18
       00000000001eca80  0000000000000000  WA       0     0     128
  [31] .shstrtab         STRTAB           0000000000000000  008cfd18
       0000000000000189  0000000000000000           0     0     1
  [32] .symtab           SYMTAB           0000000000000000  008d0728
       00000000000aefc0  0000000000000018          33   53ec     8
  [33] .strtab           STRTAB           0000000000000000  0097f6e8
       00000000000874d3  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings)
  I (info), L (link order), G (group), x (unknown)
  O (extra OS processing required) o (OS specific), p (processor specific)

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000010000 0xa000000100000000 0x0000000004000000
                 0x000000000072cd00 0x000000000072cd00  RWE    10000
  LOAD           0x0000000000740000 0xffffffffffff0000 0x0000000004730000
                 0x0000000000009278 0x0000000000009278  RW     10000
  LOAD           0x0000000000750000 0xa000000100740000 0x0000000004740000
                 0x000000000017fd00 0x000000000036d980  RW     10000
  IA_64_UNWIND   0x0000000000618c08 0xa000000100608c08 0x0000000004608c08
                 0x0000000000034758 0x0000000000034758  R      8

 Section to Segment mapping:
  Segment Sections...
   00     .text __ex_table .data.patch.vtop .data.patch.mckinley_e9 .IA_64.unwind_info .IA_64.unwind .rodata __ksymtab __ksymtab_gpl __kcrctab __kcrctab_gpl __ksymtab_strings .opd .init.text .init.data .init.ramfs .init.setup .kdb_initcall.init __param .initcall.init .con_initcall.init .data.init_task .data.page_aligned .data.cacheline_aligned 
   01     .data.percpu 
   02     .data .got .sdata .sbss .bss 
   03     .IA_64.unwind 


Bad link, with 5 program headers.

ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Intel IA-64
  Version:                           0x1
  Entry point address:               0x4568be0
  Start of program headers:          64 (bytes into file)
  Start of section headers:          8808232 (bytes into file)
  Flags:                             0x50, 64-bit, constant gp
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         5
  Size of section headers:           64 (bytes)
  Number of section headers:         34
  Section header string table index: 31

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         a000000100000000  00010000
       00000000005c05d0  0000000000000000  AX       0     0     32768
  [ 2] __ex_table        PROGBITS         a0000001005c05d0  005d05d0
       0000000000002a10  0000000000000000   A       0     0     4
  [ 3] .data.patch.vtop  PROGBITS         a0000001005c2fe0  005d2fe0
       0000000000000020  0000000000000000   A       0     0     4
  [ 4] .data.patch.mckin PROGBITS         a0000001005c3000  005d3000
       0000000000000020  0000000000000000   A       0     0     4
  [ 5] .IA_64.unwind_inf PROGBITS         a0000001005c4000  005d4000
       0000000000045c08  0000000000000000   A       0     0     8
  [ 6] .IA_64.unwind     IA_64_UNWIND     a000000100609c08  00619c08
       0000000000034758  0000000000000000  AL       1     1     8
  [ 7] .rodata           PROGBITS         a00000010063e360  0064e360
       0000000000058a3d  0000000000000000   A       0     0     8
  [ 8] __ksymtab         PROGBITS         a000000100696da0  006a6da0
       0000000000007480  0000000000000000   A       0     0     8
  [ 9] __ksymtab_gpl     PROGBITS         a00000010069e220  006ae220
       0000000000000170  0000000000000000   A       0     0     8
  [10] __kcrctab         PROGBITS         a00000010069e390  006ae390
       0000000000003a40  0000000000000000   A       0     0     8
  [11] __kcrctab_gpl     PROGBITS         a0000001006a1dd0  006b1dd0
       00000000000000b8  0000000000000000   A       0     0     8
  [12] __ksymtab_strings PROGBITS         a0000001006a1e88  006b1e88
       000000000000921c  0000000000000000   A       0     0     8
  [13] .opd              PROGBITS         a0000001006ab0b0  006bb0b0
       0000000000011f30  0000000000000000   A       0     0     16
  [14] .init.text        PROGBITS         a0000001006c0000  006d0000
       000000000002eb80  0000000000000000 WAX       0     0     32
  [15] .init.data        PROGBITS         a0000001006eeb80  006feb80
       000000000001a0c1  0000000000000000  WA       0     0     8
  [16] .init.ramfs       PROGBITS         a000000100708c41  00718c41
       0000000000000086  0000000000000000   A       0     0     1
  [17] .init.setup       PROGBITS         a000000100708cd0  00718cd0
       0000000000000290  0000000000000000  WA       0     0     8
  [18] .kdb_initcall.ini PROGBITS         a000000100708f60  00718f60
       0000000000000010  0000000000000000  WA       0     0     8
  [19] __param           PROGBITS         a000000100708f70  00718f70
       00000000000004d8  0000000000000000   A       0     0     8
  [20] .initcall.init    PROGBITS         a000000100709448  00719448
       0000000000000348  0000000000000000  WA       0     0     8
  [21] .con_initcall.ini PROGBITS         a000000100709790  00719790
       0000000000000010  0000000000000000  WA       0     0     8
  [22] .data.init_task   PROGBITS         a00000010070c000  0071c000
       0000000000008000  0000000000000000  WA       0     0     16
  [23] .data.page_aligne PROGBITS         a000000100714000  00724000
       000000000000c710  0000000000000000 WAX       0     0     1
  [24] .data.cacheline_a PROGBITS         a000000100724000  00734000
       000000000000cc84  0000000000000000  WA       0     0     128
  [25] .data.percpu      PROGBITS         ffffffffffff0000  00750000
       0000000000009260  0000000000000000  WA       0     0     128
  [26] .data             PROGBITS         a000000100750000  00760000
       00000000000f33c0  0000000000000000  WA       0     0     128
  [27] .got              PROGBITS         a0000001008433c0  008533c0
       0000000000011648  0000000000000000 WAp       0     0     8
  [28] .sdata            PROGBITS         a000000100854a08  00864a08
       0000000000001b18  0000000000000000 WAp       0     0     8
  [29] .sbss             NOBITS           a000000100856520  00866520
       00000000000011e4  0000000000000000 WAp       0     0     8
  [30] .bss              NOBITS           a000000100857780  0086659c
       00000000001ecb20  0000000000000000  WA       0     0     128
  [31] .shstrtab         STRTAB           0000000000000000  0086659c
       0000000000000189  0000000000000000           0     0     1
  [32] .symtab           SYMTAB           0000000000000000  00866fa8
       00000000000aef78  0000000000000018          33   53e9     8
  [33] .strtab           STRTAB           0000000000000000  00915f20
       00000000000874d3  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings)
  I (info), L (link order), G (group), x (unknown)
  O (extra OS processing required) o (OS specific), p (processor specific)

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000010000 0xa000000100000000 0x0000000004000000
                 0x00000000006bcfe0 0x00000000006bcfe0  R E    10000
  LOAD           0x00000000006d0000 0xa0000001006c0000 0x00000000046c0000
                 0x0000000000070c84 0x0000000000070c84  RWE    10000
  LOAD           0x0000000000750000 0xffffffffffff0000 0x0000000004740000
                 0x0000000000009260 0x0000000000009260  RW     10000
  LOAD           0x0000000000760000 0xa000000100750000 0x0000000004750000
                 0x0000000000106520 0x00000000002f42a0  RW     10000
  IA_64_UNWIND   0x0000000000619c08 0xa000000100609c08 0x0000000004609c08
                 0x0000000000034758 0x0000000000034758  R      8

 Section to Segment mapping:
  Segment Sections...
   00     .text __ex_table .data.patch.vtop .data.patch.mckinley_e9 .IA_64.unwind_info .IA_64.unwind .rodata __ksymtab __ksymtab_gpl __kcrctab __kcrctab_gpl __ksymtab_strings .opd 
   01     .init.text .init.data .init.ramfs .init.setup .kdb_initcall.init __param .initcall.init .con_initcall.init .data.init_task .data.page_aligned .data.cacheline_aligned 
   02     .data.percpu 
   03     .data .got .sdata .sbss .bss 
   04     .IA_64.unwind 

