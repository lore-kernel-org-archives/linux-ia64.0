From: Nicolin Chen <nicoleotsuka@gmail.com>
Date: Tue, 01 Sep 2020 20:53:47 +0000
Subject: Re: [RESEND][PATCH 1/7] powerpc/iommu: Avoid overflow at boundary_size
Message-Id: <20200901205346.GA17362@Asurada-Nvidia>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200831203811.8494-1-nicoleotsuka@gmail.com>
 <20200831203811.8494-2-nicoleotsuka@gmail.com>
 <87lfht1vav.fsf@mpe.ellerman.id.au>
In-Reply-To: <87lfht1vav.fsf@mpe.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: benh@kernel.crashing.org, paulus@samba.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, tony.luck@intel.com, fenghua.yu@intel.com, schnelle@linux.ibm.com, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, sfr@canb.auug.org.au, hch@lst.de, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org

On Tue, Sep 01, 2020 at 11:27:36PM +1000, Michael Ellerman wrote:
> Nicolin Chen <nicoleotsuka@gmail.com> writes:
> > The boundary_size might be as large as ULONG_MAX, which means
> > that a device has no specific boundary limit. So either "+ 1"
> > or passing it to ALIGN() would potentially overflow.
> >
> > According to kernel defines:
> >     #define ALIGN_MASK(x, mask) (((x) + (mask)) & ~(mask))
> >     #define ALIGN(x, a)	ALIGN_MASK(x, (typeof(x))(a) - 1)
> >
> > We can simplify the logic here:
> >   ALIGN(boundary + 1, 1 << shift) >> shift
> > = ALIGN_MASK(b + 1, (1 << s) - 1) >> s
> > = {[b + 1 + (1 << s) - 1] & ~[(1 << s) - 1]} >> s
> > = [b + 1 + (1 << s) - 1] >> s
> > = [b + (1 << s)] >> s
> > = (b >> s) + 1
> >
> > So fixing a potential overflow with the safer shortcut.
> >
> > Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > Signed-off-by: Nicolin Chen <nicoleotsuka@gmail.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > ---
> >  arch/powerpc/kernel/iommu.c | 11 +++++------
> >  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> Are you asking for acks, or for maintainers to merge the patches
> individually?

I was expecting that but Christoph just suggested me to squash them
into one so he would merge it: https://lkml.org/lkml/2020/9/1/159

Though I feel it'd be nice to get maintainers' acks before merging.

> > diff --git a/arch/powerpc/kernel/iommu.c b/arch/powerpc/kernel/iommu.c
> > index 9704f3f76e63..c01ccbf8afdd 100644
> > --- a/arch/powerpc/kernel/iommu.c
> > +++ b/arch/powerpc/kernel/iommu.c
> > @@ -236,15 +236,14 @@ static unsigned long iommu_range_alloc(struct device *dev,
> >  		}
> >  	}
> >  
> > -	if (dev)
> > -		boundary_size = ALIGN(dma_get_seg_boundary(dev) + 1,
> > -				      1 << tbl->it_page_shift);
> > -	else
> > -		boundary_size = ALIGN(1UL << 32, 1 << tbl->it_page_shift);
> >  	/* 4GB boundary for iseries_hv_alloc and iseries_hv_map */
> > +	boundary_size = dev ? dma_get_seg_boundary(dev) : U32_MAX;
> 
> Is there any path that passes a NULL dev anymore?
> 
> Both iseries_hv_alloc() and iseries_hv_map() were removed years ago.
> See:
>   8ee3e0d69623 ("powerpc: Remove the main legacy iSerie platform code")
> 
> 
> So maybe we should do a lead-up patch that drops the NULL dev support,
> which will then make this patch simpler.

The next version of this change will follow Christoph's suggestion
by having a helper function that takes care of !dev internally.

Thanks
Nic

> 
> 
> > +	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
> > +	boundary_size = (boundary_size >> tbl->it_page_shift) + 1;
> >  
> >  	n = iommu_area_alloc(tbl->it_map, limit, start, npages, tbl->it_offset,
> > -			     boundary_size >> tbl->it_page_shift, align_mask);
> > +			     boundary_size, align_mask);
> >  	if (n = -1) {
> >  		if (likely(pass = 0)) {
> >  			/* First try the pool from the start */
> > -- 
> > 2.17.1
