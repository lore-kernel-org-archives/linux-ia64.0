From: Younggyun Koh <young@cc.gatech.edu>
Date: Fri, 18 Jun 2004 01:12:01 +0000
Subject: can't boot - AllocatePages() failed
Message-Id: <Pine.GSO.4.58.0406172103310.6449@tokyo.cc.gatech.edu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

i was trying to boot hp zx6000 itanium 2 machine with linux
kernel 2.4.18-e.41.

but when it starts to load kernel image, it shows following error
messages...

ConvertPages: Incompatible memory types
alloc.c(line 132):allocator: AllocatePages(2, 2, 3940649673950356,
0x4400000) failed (Not Found)

gzip.c(line 436):gzip_ia64 : AllocatePages(3940649673950356, 0x4400000)
for kernel failed

gzip.c(line 439):relocation is disabled, cannot load kernel
gzip.c(line 594):gzip_ia64 : invalid exec header
Start of Red Hat Linux Advanced Workstation failed: Load Error

how can i solve this problem?

the version of my elilo is 3.3a and the result of readelf -l vmlinux is

Elf file type is EXEC (Executable file)
Entry point 0x4408000
There are 3 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000010000 0xe000000004400000 0x0000000004400000
                 0x00000000005ffe48 0x000000000065ae98  RWE    10000
  LOAD           0x0000000000613340 0xe000000004893340 0xe000000004893340
                 0x0000000000000020 0x0000000000000020  R      10000
  IA_64_UNWIND   0x000000000044fbc8 0xe00000000483fbc8 0x000000000483fbc8
                 0x000000000001c8a8 0x000000000001c8a8  R      8

 Section to Segment mapping:
  Segment Sections...
   00     .text __ex_table .machvec __ksymtab __kallsyms
.IA_64.unwind_info .IA_64.unwind .rodata
.modinfo .kstrtab .opd .text.init .data.init .setup.init .initcall.init
init_task .data.page_aligned .data.cacheline_aligned .data .got .sdata
.sbss .bss
   01     .modinfo
   02     .IA_64.unwind

thank you,

			-Younggyun Koh (young@cc.gatech.edu)
