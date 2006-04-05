From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 05 Apr 2006 17:31:42 +0000
Subject: Re: Fix ia64 bit ops: Full barriers for bit operations returning a
Message-Id: <Pine.LNX.4.64.0604051030510.1768@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 5 Apr 2006, Zoltan Menyhart wrote:

> Christoph Lameter wrote:
> 
> > Could decomplicate this? Just use acquire / release and avoid the additional
> > intrinsics. The purpose is first of all correctness. Then we can add some
> > whiz bang on top. Also please sent patches inline not as attachments.
> 
> I could have misunderstood what you wrote yesterday:
> 
> > > Could you consider using some cache hints, like "ld8.bias.nta"?
> > > "bias" is a hint to acquire exclusive ownership.
> > > "nta" is a hint to allocate the cache line only in L2
> > > (and side effect: to bias it to be replaced).
> > > All of the Itanium 2 processor's atomic instructions are handled
> > > exclusively by the L2 cache.
> > 
> > Could you come up with a patch? Currently, I do not seem to be able to spend
> > enough time on it.
> 
> I thought you had asked for both the correct fencing and the cache hints.

Oh. Sorry.

The new patch seems to be okay but it still was not sent inline and is
therefore difficult to review for most of us.

