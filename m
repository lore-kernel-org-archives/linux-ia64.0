From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Oct 2002 16:46:27 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805187@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Which IA64 hardware doesn't support _PAGE_MA_WC in the PTE ? My IA64 docs 
> doesn't mention anything about that.

The *processors* all support WC, no problem there.  The problem is
that the *chipset* may not.  The EFI memory descriptor table (from
GetMemoryMap()) tells us which attributes are supported for each
region of address space.

According to the EFI shell "memmap" command, the i2000 (BigSur)
supports WB or UC for memory, and UC for MMIO space.  No
mention of WC, so we have to assume it's not supported.

HP ZX1 machines report that they support WB for memory and
UC for MMIO space.  The ZX1 chipset is supposed to support WC
for MMIO space, so the fact that EFI doesn't report that looks
like a firmware defect.

> Actually I think _PAGE_MA_WC is only applicable to IO memory the same way 
> as _PAGE_MA_UC is. Can't it be handled in the same way ? (you've already 
> done the fix for UC, right ?)

WC could be used for memory as well as for MMIO space -- an
example is for AGP, where drivers like to have main memory
buffers mapped with WC, and the AGP engine can do non-coherent
DMA from the buffers.  That doesn't work on IA64 because we
use large TLB pages to map all of main memory with the WB
attribute, and there's no easy way to support WC mappings
at the same time.

The mmap support for UC currently cheats a little bit.  We
don't look at the EFI tables; we just use UC whenever we mmap
something that isn't main memory (this is in mmap_mem(), BTW).

Bjorn


