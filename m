From: mel@skynet.ie (Mel Gorman)
Date: Wed, 14 Mar 2007 19:49:41 +0000
Subject: Re: [QUICKLIST 4/6] x86_64: Single Quicklist
Message-Id: <20070314194941.GA21862@skynet.ie>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com> <20070311020944.19905.87599.sendpatchset@schroedinger.engr.sgi.com> <200703110854.05799.ak@suse.de> <Pine.LNX.4.64.0703110939140.24216@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703110939140.24216@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, ak@suse.com, linux-ia64@vger.kernel.org, holt@sgi.com, mpm@selenic.com

On (11/03/07 09:44), Christoph Lameter didst pronounce:
> On Sun, 11 Mar 2007, Andi Kleen wrote:
> 
> > This and i386 version are ok to me, although it might be better to just
> > finish __GFP_ZERO support to do this.
> 
> This would not work for pgds on i386 and x86_64
> 
> GFP_ZERO support the way I have done it in the past would mean another set 
> of buddy lists in the page allocator and another issue with fragmentation. 
> So I have stayed away from it although patches exist in my archives (See 
> my ftp.kernel.org archive).

I haven't checked this in a while but when we experimented with keeping
zero'd pages on separate lists before, the performance sucked. I haven't
looked at it in a *long* time though.

> 
> Maybe we could implemento limited GFP_ZERO support by just keeping an 
> additional per cpu list of pages?

I imagine that adding an additional per-cpu list will not be welcome.

> The issue with that one is that a page
> may grow cold on that list.

And that growing cold appeared to hurt before. It could be checked out
again though. The anti-fragmentation breaks out the buddy lists already
and has the ability to search the per-cpu lists for pages of an
appropriate type.

I'll try and find an hour or two to hack something together to see what
it looks like but I suspect it'll still be a performance loss. At least
then though, we can see if quicklists are a better plan or not.

> One usually want the page to be hot in the 
> cache when it is allocated. This is different for page table pages. Page 
> table pages are typically sparsely accessed.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
