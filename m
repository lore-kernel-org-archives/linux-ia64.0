From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 19 Sep 2005 18:23:33 +0000
Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by freezing time
Message-Id: <Pine.LNX.4.62.0509191122220.25963@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 19 Sep 2005, David Mosberger-Tang wrote:

> > I still think that the proposed patch is the best compromise solution
> > since it restored the normal flow of time as soon as possible.
> 
> I disagree.  Time jumps are much worse than making time go slightly
> faster/slower for a period of time.  What's even better, the timeouts
> you're seeing when making time jump almost certainly will just
> disappear, which is extremely nice.

Ok then we can simply remove the time_interpolator_reset() call from 
my patch. Then the self-tuning interpolator logic will compensate for the 
difference over time.

