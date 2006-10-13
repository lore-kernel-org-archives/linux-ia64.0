From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 13 Oct 2006 19:25:42 +0000
Subject: RE: Patch [2/2] relax per-cpu TLB requirement to DTC
Message-Id: <000401c6eefd$60b10bb0$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <000201c6eeea$2b134940$ff0da8c0@amr.corp.intel.com>
In-Reply-To: <000201c6eeea$2b134940$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Friday, October 13, 2006 11:54 AM
> On Fri, 13 Oct 2006, Chen, Kenneth W wrote:
> 
> > -	andcm r18=0x10,r18	// bit 4=~address-bit(61)
> > +(p10)	sub r19=r19,r26
> > +(p10)	mov cr.itir=r25
> >  	cmp.ne p8,p0=r0,r23
> 
> This look somewhat familiar. Any chance that you could merge my mods to 
> the alt_dtlb_miss handler? Both have to modify ITIR. 


I suppose so.


> Also there may be a conflict since we both use high address bits?

Yes, there will be conflict, but easily fixable. My patch keys on PERCPU_ADDR,
which should have bits 16-63 set to one.  An easy condition to check before
further decoding into variable page size.

There are a few details that your patch needs polishing in alt_dtlb_miss
handler: I don't think you would want to branch into dtlb_fault, because
there are no vhpt table in region7.  Branching to dtlb_fault will dereference
a hashed address which will result a guaranteed nested_dtlb_miss fault,
And I think it is also dangerous to reference hashed vhpt address on region
7 address as your patch will fully utilize all the virtual address there.
Nonetheless, this double fault should be easy to optimize away. 

I'm a bit uneasy about making nested_dtlb_miss now more frequently used
function. The code that walks the page table there isn't really as optimized
as vhpt_miss handler. We either optimize that or tap into vhpt_miss handler.

- Ken
