From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 19:38:31 +0000
Subject: RE: Patch [2/2] relax per-cpu TLB requirement to DTC
Message-Id: <Pine.LNX.4.64.0610131234310.26780@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <000201c6eeea$2b134940$ff0da8c0@amr.corp.intel.com>
In-Reply-To: <000201c6eeea$2b134940$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 13 Oct 2006, Chen, Kenneth W wrote:

> > Also there may be a conflict since we both use high address bits?
> 
> Yes, there will be conflict, but easily fixable. My patch keys on PERCPU_ADDR,
> which should have bits 16-63 set to one.  An easy condition to check before
> further decoding into variable page size.

Hmm...

> There are a few details that your patch needs polishing in alt_dtlb_miss
> handler: I don't think you would want to branch into dtlb_fault, because
> there are no vhpt table in region7.  Branching to dtlb_fault will dereference

Right this is only done in order to get to the nested_dtlb_miss handler. 
We could simply avoid that by deferencing the original address again.

> a hashed address which will result a guaranteed nested_dtlb_miss fault,
> And I think it is also dangerous to reference hashed vhpt address on region
> 7 address as your patch will fully utilize all the virtual address there.
> Nonetheless, this double fault should be easy to optimize away. 

I am using the original address not the hashed address in order to make 
sure that a nested fault happens.
> 
> I'm a bit uneasy about making nested_dtlb_miss now more frequently used
> function. The code that walks the page table there isn't really as optimized
> as vhpt_miss handler. We either optimize that or tap into vhpt_miss handler.

I'd would be great to optimize that further. However, as you already noted 
we cannot generate a hashed vhpt address without causing address 
conflicts (plus we will have other problems as well since the page size 
is not 16k but 16MB so the translations will be off) and therefore the 
vhpt_miss handler may not work.
