From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 15 Dec 2004 21:58:14 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412151353370.13325@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 15 Dec 2004, Robin Holt wrote:

> > I have some spot results here that indicate that a single thread may
> > do up to 500000 faults a second with this patch alone.
>
> This sounds impressive, but from my limited understanding of the patches,
> I think it is a misleading figure.  This would require the system to
> sit idle for a period of time between large jobs to ensure that
> enough pages are free so all allocations could be satisfied from the
> pre-zeroed section.

There is enough time for all pages to be zeroed on bootup so there is
a large repository of zeroed pages. Of course if the system uses up that
reservoir and the zeroing is not effectively keeping up then this
will degenerates into the old behavior.

> My understanding (very limited as I only spent 15 minutes looking)
> is that only idle cpus are actually queueing pages for zereoing.
> Is this correct or am I off the mark?

Idle cpus will zero pages and the bte will be used if pages are coalesced
by the buddy allocator above a certain size.

> If that is so, I think we need to rethink this some.  I believe the
> largest benefit would come if you used timers to check for a previous
> page zero operation completing and then queueing up the next.  This
> could be done for all nodes that are owned by a parent node.  That would
> allow a system with many mbricks (and therefore many btes) with very
> few cbricks to effeciently use all the btes for zeroeoing.  Is that
> the intent at any point in this patch life?  Otherwise you end up
> with speedups only when you have idle cpus for zereoing.

Having access to more than one bte per cpu is certainly an interesting
idea. Any suggestions on how to discover these?

(will follow up in next post on your code comments).

