From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Sep 2004 22:23:46 +0000
Subject: RE: INIT dumps broken?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020516A2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Correctly understanding the proper way to translate addresses for
>the various regions would be the first step.
>
>The top 3 bits of the virtual address is the virtual region number.  
>
>If it is a region 7 (0xe) address, then masking off the top 3 bits 
>yields the correct physical address.
>
>If it is a region 5 (0xa) address, then a "tpa" instruction (using 
>the TLB) should yield the correct physical address (assuming there is
>a valid TLB entry for that virtual address).
>
>Would that be the correct way to translate the addresses?
>
>Are there exceptions, such as region 7 addresses where masking off 
>the top 3 bits would not yield the correct physical address?
>
>How should region 5 addresses without a valid TLB mapping be handled?
>
>Are there any other regions that need handling, and if so, how?


For this case we can use the "tpa" (and I'm just about to check-in
a change to do that).  The TLB is functional for an INIT signal, we
don't use this call in the MCA path when the TLB might be broken.

Here's a breakdown of kernel virtual address space (in 2.6 kernel,
there are a few differences in 2.4):

Region 7:  Almost all of this is mapped 1:1 with physical memory
using the mapping "virtual = physical + PAGE_OFFSET", so you can
almost always turn a region 7 address into a physical address by
just subtracting PAGE_OFFSET ... or more simply by clearing bits
{63:61} (since PAGE_OFFSET is 0xE000000000000000).  The exception
in region 7 is the top 64Kbytes (0xffffffffffff0000-0xffffffffffffffff)
which is the percpu area hard-wired by DTR[1] in the TLB to a
different physical address on each cpu.

Region 6: All mapped 1:1 with uncacheable physical memory using
the mapping "virtual = physical + 0xC000000000000000"

Region 5:  Lots of different stuff in here.  Going from low to
high:
0xA000000000000000 : unmapped (redzone above user space) ... or I
thought it was ... I see some symbols in here, hmmm?
0xA000000000010000 : gate page
0xA000000100000000 : base of kernel. mapped by ITR[0] & DTR[0]
0xA000000200000000 : VMALLOC_START. Virtual playground for vmalloc
                     mapped in PAGE_SIZE discreet pieces.
0xA0007xxxxxxxxxxx : If you have CONFIG_VIRT_MEM_MAP on, and if the
                     kernel is using it, then the top of the vmalloc
                     area is used for page structs (mem_map/vmem_map).
0xA000800000000000 : end of vmalloc area (when PAGE_SIZEk)
0xBFFCxxxxxxxxxxxx : VHPT for ptes mapped in region 5


Whether you can use "tpa" on an address depends on a few factors. If
psr.dt is 1, then most cases will work (possibly involving a TLB fault
to get the answer).  When psr.dt is 0 (e.g. in our INIT handler), then
we check the DTLB ... if that fails then there will be a AltDTLB fault
or a DataNestedTLB fault (depending on whether psr.ic is set).  In
general in these cases we only want to use "tpa" for addresses that
are locked in the TLB by one of the DTR[] registers.

-Tony
