From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 04 Dec 2003 22:55:09 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107057901709452@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 4 Dec 2003 16:56:20 -0500, Bill Nottingham <notting@redhat.com> said:

  Bill> Trying to boot a 2.6test ia64 kernel here, I'm getting:
  Bill> Loadin vmlinux...Loading Linux... 
  Bill> alloc.c(line 132):allocator: AllocatePages(2, 2, 3377699721561477, 0x40000000) failed (Not Found)
  Bill> plain_loader.c(line 291):plain_elf64: AllocatePages(3377699721561477, 0x40000000) for kernel failed

  Bill> Is the kernel just horribly misbuilt somehow, or is something else
  Bill> going on?

In case it helps, attached is what the program headers of a good
vmlinux-2.6.0-test11 kernel should look like.

	--david

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000010000 0xa000000100000000 0x0000000004000000
                 0x000000000082e9b0 0x000000000082e9b0  R E    10000
  LOAD           0x0000000000840000 0xa000000100830000 0x0000000004830000
                 0x000000000005cb80 0x000000000005cb80  RWE    10000
  LOAD           0x00000000008a0000 0xffffffffffff0000 0x0000000004890000
                 0x0000000000008428 0x0000000000008428  RW     10000
  LOAD           0x00000000008b0000 0xa0000001008a0000 0x00000000048a0000
                 0x0000000000169360 0x00000000001bc8b8  RW     10000
  IA_64_UNWIND   0x0000000000781c58 0xa000000100771c58 0x0000000004771c58
                 0x000000000002e5f0 0x000000000002e5f0  R      8

 Section to Segment mapping:
  Segment Sections...
   00     .text __ex_table .data.patch.vtop .data.patch.mckinley_e9 .IA_64.unwind_info .IA_64.unwind .rodata __ksymtab __ksymtab_gpl __kcrctab __kcrctab_gpl __ksymtab_strings .opd 
   01     .init.text .init.data .init.ramfs .init.setup __param .initcall.init .con_initcall.init .data.init_task .data.page_aligned .data.cacheline_aligned 
   02     .data.percpu 
   03     .data .got .sdata .sbss .bss 
   04     .IA_64.unwind 
