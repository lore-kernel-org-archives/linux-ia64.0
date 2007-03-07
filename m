From: Horms <horms@verge.net.au>
Date: Wed, 07 Mar 2007 07:55:14 +0000
Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
Message-Id: <20070307075512.GA19315@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 07, 2007 at 12:50:12PM +0800, Zou, Nanhai wrote:
> On Wed, Mar 07, 2007 at 11:46, Horms wrote:
> > 
> > I think that the manual option is also important because it
> > maintains feature-compatibility with other architectures. I don't
> > consider it a hack that might work purely for the purposes of
> > debugging.
> 
> I don't understand why we need to maintain compatibility with other
> architectures here. Manfully choose may confuse user, XXX@16M may work
> on one arch,but not on another arch. Other architectures need manually
> choose crash kernel region simply because they do not support kernel
> automatically choose feature. 
>
> I keep the XXX@YYY format to just make kdump script compatible, do
> that distributions does not need to maintain different kdump scripts
> for different arches. 

From my point of view, what you say in the paragraph immediately above
is the crux of the point. There is a case for compatibility.  And
furthermore, that compatibility really ought to be correct rather than a
bit of a hack. (Or in this case a bit more of a hack than the auto
select code path.)

> > With regards to 70 lines of extra code, it can probably be consolidated
> > a bit - for insance I think that the ckeck contained in
> > kdump_region_verify_rsvd_region() is more important than the other
> > checks which I guess could be disposed of if the length of the code
> > really is a problem. But in any case the new code is almost entirely in
> > __init. So I don't really see that it is a big concern.
> > 
> > As for the partly-overlaped case in kdump_region_verify_rsvd_region().
> > I'm not entirely sure what you are getting at there. Are you talking
> > about an optimisation to the check, or a correctness problem?
> > 
>  (reserve_region.start < base && reserve_region.end < base + size)
>   or
>  (reserve_region.end > base && reserve_region.end > base + size) will pass the check

Thanks, is this logic better?

kdump_region_verify_rsvd_region (unsigned long base, unsigned long size,
                                struct rsvd_region *rsvd_regions, int n)
{
	int i;

	for (i = 0; i < n; i++) {
		/* Assume that start < end && size > 0 */
		if (__pa(rsvd_regions[i].start) >= base + size &&
		    __pa(rsvd_regions[i].end) < base)
			continue;
		printk(KERN_WARNING "Kdump: crashkernel region 0x%lx-0x%lx "
		       "clashes with reserved region 0x%lx-0x%lx\n", base,
		       base + size - 1, __pa(rsvd_regions[i].start),
		       __pa(rsvd_regions[i].end));
		return 0;
	}
	return 1;
}

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

