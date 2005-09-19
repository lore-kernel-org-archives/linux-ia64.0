From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 19 Sep 2005 18:04:06 +0000
Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by freezing time
Message-Id: <Pine.LNX.4.62.0509191059160.25829@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 9 Sep 2005, David Mosberger-Tang wrote:

> I see your point about non-interrupt sources but the idea can be
> generalized: rather than letting time catch up in a single huge jump,
> do it gradually.  Say for every timer tick, you advance by one extra
> tick.  I _think_ that could work well in practice.

The time interpolator can do that too. If we remove the 
time_interpolator_reset() then we will have a huge difference between 
xtime and gettimeofday() that is slowly reduced.

However, any mechanism like that will have a time running strangely fast 
for awhile which may cause other subsystems to misbehave.

I still think that the proposed patch is the best compromise solution 
since it restored the normal flow of time as soon as possible. 

Maybe the time period for the time freeze to take effect should be 
configurable?

