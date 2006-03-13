From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 13 Mar 2006 16:55:51 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <4415A417.4050203@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:

> Could you measure the effect that this has? We seem to be getting into 
> some special processor behavior here.

Telling the truth: I cannot measure it.

The architecture ia64 defines some hints which *may* increase the performance.

If you have a sequence that does not cost a penny and may run faster...
If you have a shorter and somewhat faster sequence because of the elimination
of "cmp" that had to wait the completion the "cmpxchg"...
... why not?

> The last that I heard about nta was that it just skips the marking of a 
> cacheline as recent. Thus the cacheline will be a more likely candidate to 
> be evicted from the caches. Are you sure that the processors can bypass 
> the L1D and L3?

Please refer to e.g. the I2 Proc. Ref. Man. for SW Dev. & Opt. - may 2004
table 5-4 on page 41.

Thanks,

Zoltan
