From: Bob Picco <bob.picco@hp.com>
Date: Mon, 23 May 2005 21:20:49 +0000
Subject: Re: [patch 4/4] ia64 SPARSEMEM - SPARSEMEM code changes
Message-Id: <20050523212049.GJ2783@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175117.GG2783@localhost.localdomain>
In-Reply-To: <20050523175117.GG2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:	[Mon May 23 2005, 02:08:28PM EDT]
> On Monday, May 23, 2005 10:51 am, Bob Picco wrote:
> > +#ifdef	CONFIG_SPARSEMEM
> > +/**
> > + * register_sparse_mem - notify SPARSEMEM that this memory range
> > exists. + * @start: physical start of range
> > + * @end: physical end of range
> > + * @arg: unused
> > + *
> > + */
> 
> No comment for the function (I guess it's pretty simple...).
I went ahead and added one despite its simplicity.
> 
> > +static int __init register_sparse_mem(unsigned long start, unsigned
> > long end, +	void *arg)
> > +{
> > +	int nid;
> > +
> > +	start = __pa(start) >> PAGE_SHIFT;
> > +	end = __pa(end) >> PAGE_SHIFT;
> > +	nid = early_pfn_to_nid(start);
> > +	(void) memory_present(nid, start, end);
> 
> Is the (void) cast necessary?
At one time it was required but no longer true.  
> 
> > +#ifdef	CONFIG_SPARSEMEM
> > +	efi_memmap_walk(register_sparse_mem, (void *) 0);
> > +#endif
> 
> NULL here instead?
okay
> 
> > -#ifndef CONFIG_DISCONTIGMEM
> > +#ifndef	CONFIG_NEED_MULTIPLE_NODES
okay
> 
> Just use a space instead of a tab I think.
> 
> > +#if	defined(CONFIG_SPARSEMEM) && defined(CONFIG_NUMA)
> 
> Ditto.
okay
> 
> > +/*
> > + * Because of holes evaluate on section limits.
> > + */
> 
> A better comment block here maybe describing return values and such?
Yep
> 
> > +int early_pfn_to_nid(unsigned long pfn)
> > +{
> > +	int i, section = pfn >> PFN_SECTION_SHIFT, ssec, esec;
> > +
> > +	for (i = 0; i < num_node_memblks; i++) {
> > +		ssec = node_memblk[i].start_paddr >> PA_SECTION_SHIFT;
> > +		esec = (node_memblk[i].start_paddr + node_memblk[i].size +
> > +			((1L << PA_SECTION_SHIFT) - 1)) >> PA_SECTION_SHIFT;
> > +		if (section >= ssec && section < esec)
> > +			break;
> > +	}
> > +
> > +	if (i = num_node_memblks)
> > +		return 0;
> > +	else
> > +		return node_memblk[i].nid;
> 
> You could just drop the else here if you wanted, maybe along with a 
> comment by the return 0 saying that the pfn wasn't found?  Or you could 
> turn the 'break' above into return node_memblk[i].nid and make the 
> function return 0 unconditionally if the for loop exited.
Yes I agree.
> 
> So other than that cosmetic stuff, this patch looks ok.
> 
> Jesse
Jesse, 

Thanks for the review.  I'll respin a version 2 of the patchset very soon.
> -

bob
