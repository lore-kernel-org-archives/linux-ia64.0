From: Mohit Katiyar <mohit_lkw@yahoo.com>
Date: Mon, 16 May 2005 11:49:20 +0000
Subject: Queries on IA -64
Message-Id: <20050516114921.28015.qmail@web54008.mail.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I am first time mailing regarding some booting
procedure for IA-64 Linux . I am having a ZX MIO chip
with 6 GB RAM and 16 KB of page size. I have compiled
the kernel with NUMA off and Virtual mem map on

First in function paging_init 
line    max_dma = virt_to_phys((void *)
MAX_DMA_ADDRESS) >> PAGE_SHIFT;
max_dma comes out to be 0x7fffffffffff and max low pfn
= 0x103ffec
Therefore all the pages move into DMA zone during
initialization .
QUESTION Why do we have such a large max_dma value.
What is the use for that?

Question In which case does trim bottom is called and
in which case trim top will be called??
Second I am trying to esablish connection between efi
descriptor and zone initialization(count_dma_pages in
paging _init)
What I have guessed till now is that count_dma_pages
counts the number of pages available through
efi_memmap_walk. It counts the pages present in the
EFI_MEMORY_WB from the memory mapped passed from the
efi to the kernel. It clubs consecutive type of WB
type memory to count pages by passing start and end
variables to count_dma_pages.It also trims the values
if they are not page aligned.
Now  I am giving the efi memory map and the start and
end values in count_dma_pages.
I have some issues in it
I have mentioned question in betwwen

/************** EFI memory map *********************/
May 13 16:57:01 HORIZON kernel: mem 00 

May 13 16:57:01 HORIZON kernel: type BootServicesData 

May 13 16:57:01 HORIZON kernel: attribute = 0x8 

May 13 16:57:01 HORIZON kernel: range [0x0000000000000000-0x0000000000001000] (0MB)

QUESTION>>>>>>>>Why does count_dma_pages skips this
range as seen from start and end values indicated at
the end of mail

May 13 16:57:01 HORIZON kernel: mem 01 

May 13 16:57:01 HORIZON kernel: type ConventionalMemory 

May 13 16:57:01 HORIZON kernel: attribute = 0x8 

May 13 16:57:01 HORIZON kernel: range [0x0000000000001000-0x00000000000a0000] (0MB)

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

May 13 16:57:02 HORIZON kernel: mem 02 

May 13 16:57:02 HORIZON kernel: type = MemoryMappedIO 

May 13 16:57:02 HORIZON kernel: attribute = 0x3 

May 13 16:57:02 HORIZON kernel: range [0x00000000000a0000-0x00000000000c0000] (0MB)

May 13 16:57:02 HORIZON kernel: mem 03 

May 13 16:57:02 HORIZON kernel: type RuntimeServicesCode 

May 13 16:57:02 HORIZON kernel: attribute 0x8000000000000001 

May 13 16:57:02 HORIZON kernel: range [0x00000000000c0000-0x0000000000100000] (0MB)

May 13 16:57:02 HORIZON kernel: mem 04 

May 13 16:57:02 HORIZON kernel: type ConventionalMemory 

May 13 16:57:03 HORIZON kernel: attribute = 0x8 

May 13 16:57:03 HORIZON kernel: range [0x0000000000100000-0x0000000004000000] (63MB)

May 13 16:57:03 HORIZON kernel: mem 05 

May 13 16:57:03 HORIZON kernel: type = LoaderData 

May 13 16:57:03 HORIZON kernel: attribute = 0x8 

May 13 16:57:03 HORIZON kernel: range [0x0000000004000000-0x0000000004a22000] (10MB)

May 13 16:57:03 HORIZON kernel: mem 06 

May 13 16:57:03 HORIZON kernel: type ConventionalMemory 

May 13 16:57:03 HORIZON kernel: attribute = 0x8 

May 13 16:57:03 HORIZON kernel: range [0x0000000004a22000-0x000000003f5e4000] (939MB)

May 13 16:57:03 HORIZON kernel: mem 07 

May 13 16:57:04 HORIZON kernel: type BootServicesData 

May 13 16:57:04 HORIZON kernel: attribute = 0x8 

May 13 16:57:04 HORIZON kernel: range [0x000000003f5e4000-0x000000003f5e6000] (0MB)

May 13 16:57:04 HORIZON kernel: mem 08 

May 13 16:57:04 HORIZON kernel: type RuntimeServicesCode 

May 13 16:57:04 HORIZON kernel: attribute 0x8000000000000008 

May 13 16:57:04 HORIZON kernel: range [0x000000003f5e6000-0x000000003fac0000] (4MB)

May 13 16:57:04 HORIZON kernel: mem 09 

May 13 16:57:04 HORIZON kernel: type = PalCode 

May 13 16:57:05 HORIZON kernel: attribute 0x8000000000000008 

May 13 16:57:05 HORIZON kernel: range [0x000000003fac0000-0x000000003fb00000] (0MB)

May 13 16:57:05 HORIZON kernel: mem 10 

May 13 16:57:05 HORIZON kernel: type BootServicesData 

May 13 16:57:05 HORIZON kernel: attribute = 0x8 

May 13 16:57:05 HORIZON kernel: range [0x000000003fb00000-0x000000003fb2c000] (0MB)

May 13 16:57:05 HORIZON kernel: mem 11 

May 13 16:57:05 HORIZON kernel: type ACPIReclaimMemory 

May 13 16:57:05 HORIZON kernel: attribute = 0x8 

May 13 16:57:06 HORIZON kernel: range [0x000000003fb2c000-0x000000003fb38000] (0MB)

May 13 16:57:06 HORIZON kernel: mem 12 

May 13 16:57:06 HORIZON kernel: type RuntimeServicesData 

May 13 16:57:06 HORIZON kernel: attribute 0x8000000000000008 

May 13 16:57:06 HORIZON kernel: range [0x000000003fb38000-0x0000000040000000] (4MB)

May 13 16:57:06 HORIZON kernel: mem 13 

May 13 16:57:06 HORIZON kernel: type = MemoryMappedIO 

May 13 16:57:07 HORIZON kernel: attribute = 0x1 

May 13 16:57:07 HORIZON kernel: range [0x0000000080000000-0x00000000fe000000] (2016MB)

May 13 16:57:07 HORIZON kernel: mem 14 

May 13 16:57:07 HORIZON kernel: type = MemoryMappedIO 

May 13 16:57:07 HORIZON kernel: attribute 0x8000000000000001 

May 13 16:57:07 HORIZON kernel: range [0x00000000fed00000-0x0000000100000000] (19MB)

May 13 16:57:07 HORIZON kernel: mem 15 

May 13 16:57:07 HORIZON kernel: type ConventionalMemory 

May 13 16:57:08 HORIZON kernel: attribute = 0x8 

May 13 16:57:08 HORIZON kernel: range [0x0000000100000000-0x0000000180000000] (2048MB)

May 13 16:57:08 HORIZON kernel: mem 16 

May 13 16:57:08 HORIZON kernel: type ConventionalMemory 

May 13 16:57:09 HORIZON kernel: attribute = 0x8 

May 13 16:57:09 HORIZON kernel: range [0x0000004040000000-0x00000040fef8a000] (3055MB)

May 13 16:57:09 HORIZON kernel: mem 17 

May 13 16:57:09 HORIZON kernel: type = LoaderData 

May 13 16:57:09 HORIZON kernel: attribute = 0x8 

May 13 16:57:09 HORIZON kernel: range [0x00000040fef8a000-0x00000040fefa6000] (0MB)

May 13 16:57:09 HORIZON kernel: mem 18 

May 13 16:57:10 HORIZON kernel: type = LoaderCode 

May 13 16:57:10 HORIZON kernel: attribute = 0x8 

May 13 16:57:10 HORIZON kernel: range [0x00000040fefa6000-0x00000040feffe000] (0MB)

May 13 16:57:10 HORIZON kernel: mem 19 

May 13 16:57:10 HORIZON kernel: type ConventionalMemory 

May 13 16:57:10 HORIZON kernel: attribute = 0x8 

May 13 16:57:10 HORIZON kernel: range [0x00000040feffe000-0x00000040ff2ee000] (2MB)

May 13 16:57:10 HORIZON kernel: mem 20 

May 13 16:57:10 HORIZON kernel: type BootServicesData 

May 13 16:57:10 HORIZON kernel: attribute = 0x8 

May 13 16:57:11 HORIZON kernel: range [0x00000040ff2ee000-0x00000040ff801000] (5MB)

May 13 16:57:11 HORIZON kernel: mem 21 

May 13 16:57:11 HORIZON kernel: type ConventionalMemory 

May 13 16:57:11 HORIZON kernel: attribute = 0x8 

May 13 16:57:11 HORIZON kernel: range [0x00000040ff801000-0x00000040ff802000] (0MB)

May 13 16:57:11 HORIZON kernel: mem 22 

May 13 16:57:11 HORIZON kernel: type BootServicesData 

May 13 16:57:11 HORIZON kernel: attribute = 0x8 

May 13 16:57:11 HORIZON kernel: range [0x00000040ff802000-0x00000040ff804000] (0MB)

May 13 16:57:11 HORIZON kernel: mem 23 

May 13 16:57:11 HORIZON kernel: type ConventionalMemory 

May 13 16:57:12 HORIZON kernel: attribute = 0x8 

May 13 16:57:12 HORIZON kernel: range [0x00000040ff804000-0x00000040ff806000] (0MB)

May 13 16:57:12 HORIZON kernel: mem 24 

May 13 16:57:12 HORIZON kernel: type BootServicesData 

May 13 16:57:12 HORIZON kernel: attribute = 0x8 

May 13 16:57:12 HORIZON kernel: range [0x00000040ff806000-0x00000040ff9fa000] (1MB)

May 13 16:57:12 HORIZON kernel: mem 25 

May 13 16:57:12 HORIZON kernel: type ConventionalMemory 

May 13 16:57:12 HORIZON kernel: attribute = 0x8 

May 13 16:57:12 HORIZON kernel: range [0x00000040ff9fa000-0x00000040ff9fb000] (0MB)

May 13 16:57:12 HORIZON kernel: mem 26 

May 13 16:57:13 HORIZON kernel: type BootServicesData 

May 13 16:57:13 HORIZON kernel: attribute = 0x8 

May 13 16:57:13 HORIZON kernel: range [0x00000040ff9fb000-0x00000040ff9fe000] (0MB)

May 13 16:57:13 HORIZON kernel: mem 27 

May 13 16:57:13 HORIZON kernel: type ConventionalMemory 

May 13 16:57:13 HORIZON kernel: attribute = 0x8 

May 13 16:57:13 HORIZON kernel: range [0x00000040ff9fe000-0x00000040ffc66000] (2MB)

May 13 16:57:13 HORIZON kernel: mem 28 

May 13 16:57:14 HORIZON kernel: type RuntimeServicesCode 

May 13 16:57:14 HORIZON kernel: attribute 0x8000000000000008 

May 13 16:57:14 HORIZON kernel: range [0x00000040ffc66000-0x00000040ffca4000] (0MB)

May 13 16:57:14 HORIZON kernel: mem 29 

May 13 16:57:14 HORIZON kernel: type BootServicesCode 

May 13 16:57:14 HORIZON kernel: attribute = 0x8 

May 13 16:57:14 HORIZON kernel: range [0x00000040ffca4000-0x00000040ffdfe000] (1MB)

May 13 16:57:14 HORIZON kernel: mem 30 

May 13 16:57:14 HORIZON kernel: type ConventionalMemory 

May 13 16:57:15 HORIZON kernel: attribute = 0x8 

May 13 16:57:15 HORIZON kernel: range [0x00000040ffdfe000-0x00000040ffe10000] (0MB)

May 13 16:57:15 HORIZON kernel: mem 31 

May 13 16:57:15 HORIZON kernel: type RuntimeServicesCode 

May 13 16:57:15 HORIZON kernel: attribute 0x8000000000000008 

May 13 16:57:15 HORIZON kernel: range [0x00000040ffe10000-0x00000040ffe7e000] (0MB)

May 13 16:57:15 HORIZON kernel: mem 32 

May 13 16:57:15 HORIZON kernel: type ConventionalMemory 

May 13 16:57:15 HORIZON kernel: attribute = 0x8 

May 13 16:57:15 HORIZON kernel: range [0x00000040ffe7e000-0x00000040fffb2000] (1MB)

May 13 16:57:15 HORIZON kernel: mem 33 

May 13 16:57:15 HORIZON kernel: type RuntimeServicesData 

May 13 16:57:15 HORIZON kernel: attribute 0x8000000000000008 

May 13 16:57:15 HORIZON kernel: range [0x00000040fffb2000-0x0000004100000000] (0MB)

May 13 16:57:15 HORIZON kernel: mem 34 

May 13 16:57:16 HORIZON kernel: type = MemoryMappedIO 

May 13 16:57:16 HORIZON kernel: attribute = 0x1 

May 13 16:57:16 HORIZON kernel: range [0x0000080000000000-0x0000100000000000] (8388608MB)

May 13 16:57:16 HORIZON kernel: mem 35 

May 13 16:57:16 HORIZON kernel: type MemoryMappedIOPortSpace 

May 13 16:57:16 HORIZON kernel: attribute 0x8000000000000001 

May 13 16:57:16 HORIZON kernel: range [0x0003fffffc000000-0x0004000000000000] (64MB)
/************** EFI memory map ends
*********************/


/****Start and end values from count dma
pages********/
May 13 16:57:18 HORIZON kernel: From count dma pages
start=0xe000000001000000 end=0xe00000003f5e4000

May 13 16:57:18 HORIZON kernel: From count dma pages
start=0xe00000003fb00000 end=0xe00000003fb2c000

May 13 16:57:18 HORIZON kernel: From count dma pages
start=0xe000000100000000 end=0xe000000180000000

May 13 16:57:18 HORIZON kernel: From count dma pages
start=0xe000004040000000 end=0xe0000040ffc64000

May 13 16:57:18 HORIZON kernel: From count dma pages
start=0xe0000040ffca4000 end=0xe0000040ffe10000

May 13 16:57:18 HORIZON kernel: From count dma pages
start=0xe0000040ffe80000 end=0xe0000040fffb0000





I have one more question different from the league

If i compile my kernel with Virtual mem map off and
NUMA off i my available free ram decreases by about 1
GB . I am not able to figure it out??





I know my mail has become quite long but I will be
thankful for your pains!!

TIA

Mohit Katiyar 



		
Yahoo! Mail
Stay connected, organized, and protected. Take the tour:
http://tour.mail.yahoo.com/mailtour.html

