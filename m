From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 04 Sep 2003 19:06:46 +0000
Subject: RE: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106270289913935@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Thanks Xavier, I've included this in the latest discontig patch, which
> I'll post again next week I think (with the fixes David wanted for
> reentrance).
> 
> Jesse
> 
> On Tue, Sep 02, 2003 at 07:27:53PM +0200, Xavier Bru wrote:
> > Hello Martin,
> > 
> > I finally found the reason for crashing at init time:
> > On node 0, our test configuration has:
> >  2 GB of memory at address 0
> >  2 GB of memory at address 6 GB (due to PCI hole).
> > 
> > Current code for acpi_numa_memory_affinity_init ignores physical
> > memory bank if the hole (4GB) is bigger than the bank (2 GB).
> > As the node_memblk is not present for address 6 GB, paddr_to_nid
> > returns -1 and alloc_bootmem_pages_node crashes with a Null pointer.
> > 
> > As we now have CONFIG_VIRTUAL_MEM_MAP=y, I suppose we 
> should also use
> > sparse memory in same node. (Am I right ?)
> > 
> > Now 2.6.0 test4  boots OK in NUMA with:
> > 
> > . Jesse's discontig patch
> > . Tony's trim patch
> > . alloc_bootmem patch
> > . and this small one :-)
> > 
> > diff --exclude-from /users/xb/proc/diff.exclude -Nur 
> linux-2.6.0-test4/arch/ia64/kernel/acpi.c 0t4/arch/ia64/kernel/acpi.c
> > --- linux-2.6.0-test4/arch/ia64/kernel/acpi.c	
> 2003-08-23 01:55:43.000000000 +0200
> > +++ 0t4/arch/ia64/kernel/acpi.c	2003-09-02 
> 15:37:17.000000000 +0200
> > @@ -423,9 +423,8 @@
> >  
> >  	if (min_hole_size) {
> >  		if (min_hole_size > size) {
> > -			printk(KERN_ERR "Too huge memory hole. 
> Ignoring %ld MBytes at %lx\n",
> > +			printk(KERN_WARNING "Huge memory hole. 
> Using %ld MBytes at %lx\n",
> >  			       size/(1024*1024), paddr);
> > -			return;
> >  		}
> >  	}

What are the remaining issues with sparse memory within a node?
CONFIG_VIRTUAL_MEM_MAP should be able to cope with this without
wasting memory on "struct page" for non-existent pages in the holes.

Presumably there are some bootmem bitmap size issues if the gaps
within nodes are too huge.  But a few GB shouldn't be a problem (with
a 16K page size, each GB of memory/hole only takes 8K of bitmap).

Is there anything else that blows up?

If not, then could we just drop the printk altogether?

-Tony
