From: Steffen Persvold <sp@scali.com>
Date: Thu, 17 Oct 2002 18:31:22 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805188@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Oct 2002, Bjorn Helgaas wrote:

> > Which IA64 hardware doesn't support _PAGE_MA_WC in the PTE ? My IA64 docs 
> > doesn't mention anything about that.
> 
> The *processors* all support WC, no problem there.  The problem is
> that the *chipset* may not.  The EFI memory descriptor table (from
> GetMemoryMap()) tells us which attributes are supported for each
> region of address space.
> 
> According to the EFI shell "memmap" command, the i2000 (BigSur)
> supports WB or UC for memory, and UC for MMIO space.  No
> mention of WC, so we have to assume it's not supported.
> 
> HP ZX1 machines report that they support WB for memory and
> UC for MMIO space.  The ZX1 chipset is supposed to support WC
> for MMIO space, so the fact that EFI doesn't report that looks
> like a firmware defect.
> 

So what does "supported" by the chipset actually mean ? I've tested the 
SCI cards in both BigSurs and ZX2000 and it works fine on IO memory 
(roughly 330 MByte on both platforms).

I was in under the impression that WC can be implemented in different 
sections of the system (processor->memorycontroller, 
memorycontroller->pci etc), and that the section we control with the 
WC attribute in the PTE is transactions on the 
processor->memorycontroller bus (as it is on the IA32 systems with MTRRs). 
Then the question of wether the memory contoller (chipset) is able to 
support large bursts of data on the processor->memorycontroller bus comes 
down to buffer space in the memory controller, and I can't really imagine 
that this isn't large enough (haven't checked though).

_But_ I agree that if the firmware has the ability to report this (and 
we can trust the information) we should take advantage of it (sort of the 
same thing which is done when someone tries to create a WC memory region 
on IA32, not all processors supports this).

> > Actually I think _PAGE_MA_WC is only applicable to IO memory the same way 
> > as _PAGE_MA_UC is. Can't it be handled in the same way ? (you've already 
> > done the fix for UC, right ?)
> 
> WC could be used for memory as well as for MMIO space -- an
> example is for AGP, where drivers like to have main memory
> buffers mapped with WC, and the AGP engine can do non-coherent
> DMA from the buffers.  That doesn't work on IA64 because we
> use large TLB pages to map all of main memory with the WB
> attribute, and there's no easy way to support WC mappings
> at the same time.
> 

I can't really see why mapping main memory with WC (processor) should 
affect the DMA performance of the AGP card. The other way around (mapping 
the AGP card's memory with WC) makes sense though and I know a lot of 
drivers that does this.

> The mmap support for UC currently cheats a little bit.  We
> don't look at the EFI tables; we just use UC whenever we mmap
> something that isn't main memory (this is in mmap_mem(), BTW).
> 

Some time ago I submitted a patch do David to allow mapping IO pages with 
WC in kernel space (ioremap()). Back then I remember this discussion about 
multiple processes having different PTE attributes on the same pages, so I 
guess this stuff with PTE attributes should be cleaned up (for all archs 
really).

Regards,
 -- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


