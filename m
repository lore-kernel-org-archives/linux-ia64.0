From: Bill Nottingham <notting@redhat.com>
Date: Thu, 04 Dec 2003 22:25:28 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107057690306724@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill Nottingham (notting@redhat.com) said: 
> > The AllocatePages() says you are trying to allocate 3377699721561477 4KB pages.
> > Clearly not something you want. Is the output of readelf -e on vmlinux decent?
> 
> As much as I can tell, it is. Not that that means much from me.

Comparing readelf output, one big difference is where it loads the
percpu data segment:

2.6.0-test11:

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000010000 0xa000000100000000 0x0000000004000000
                 0x00000000005a0c00 0x00000000005a0c00  RWE    10000
  LOAD           0x00000000005c0000 0xffffffffffff0000 0x00000000045b0000
                 0x00000000000084a8 0x00000000000084a8  RW     10000
  LOAD           0x00000000005d0000 0xa0000001005c0000 0x00000000045c0000
                 0x00000000000a3004 0x0000000000131e48  RW     10000
  IA_64_UNWIND   0x00000000004c8568 0xa0000001004b8568 0x00000000044b8568
                 0x0000000000029898 0x0000000000029898  R      8

 Section to Segment mapping:
  Segment Sections...
   00     .text __ex_table .data.patch.vtop .data.patch.mckinley_e9 .machvec .IA_64.unwind_info .IA_64.unwind .rodata __ksymtab __ksymtab_gpl __kcrctab __kcrctab_gpl __ksymtab_strings .opd .init.text .init.data .init.ramfs .init.setup .initcall.init .con_initcall.init .security_initcall.init .data.init_task .data.page_aligned .data.cacheline_aligned
   01     .data.percpu
   02     .data .got .sdata .sbss .bss
   03     .IA_64.unwind

2.5.64:

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000010000 0xe000000004400000 0x0000000004400000
                 0x00000000005dee80 0x00000000005dee80  RWE    10000
  LOAD           0x00000000005f0000 0xa000000000010000 0x00000000049e0000
                 0x0000000000002a60 0x0000000000002a60  RW     10000
  LOAD           0x0000000000600000 0xe0000000049f0000 0x00000000049f0000
                 0x000000000008a808 0x0000000000164790  RW     10000
  IA_64_UNWIND   0x00000000004e4898 0xe0000000048d4898 0x00000000048d4898
                 0x0000000000026fa0 0x0000000000026fa0  R      8

 Section to Segment mapping:
  Segment Sections...
   00     .text .text.lock __ex_table .IA_64.unwind_info .IA_64.unwind .rodata .opd .init.text .init.data .init.ramfs .init.setup .initcall.init .data.init_task .data.page_aligned .data.cacheline_aligned
   01     .data.percpu
   02     .data .got .sdata .sbss .bss
   03     .IA_64.unwind

