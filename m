From: Robin Holt <holt@sgi.com>
Date: Thu, 20 Nov 2003 19:20:55 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106935637430513@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 20, 2003 at 09:25:45AM -0800, Grant Grundler wrote:
> On Wed, Nov 19, 2003 at 08:09:15PM -0800, John Hawkes wrote:
> > I'd like to hear an argument about why sched_clock() needs sub-microsecond
> > accuracy, instead of just using jiffies, when one use of sched_clock() is to
> > compare a delta time against cache_decay_ticks, which is a
> > "jiffies"-granularity value, and the other use is to determine the relative
> > computebound-vs-interactive characteristics of the process.
> 
> In general, it seems like bouncing the jiffies cacheline around is more of
> a problem than the need for accuracy. This sounds like a similar problem
> Jack Steiner wrote about before (updating interrupt counts):

The jiffies cacheline is always used shared except by cpu 0 when updating it
once per tick.  The interrupt counts problem was that every cpu would receive
the tick interrupt and try to update (grab exclusive copy) the same cacheline.

Different problem.  Jiffies is not as much of a concern.

> 
> | Updating the counter causes a cache line to be bounced between
> | cpus at a rate of at least HZ*active_cpus. (The number of bus transactions
> | is at least 2X higher because the line is first obtained for
> | shared usage, then upgraded to modified. In addition, multiple references
> | are made to the line for each interrupt. On a big system, it is unlikely that
> | a cpu can hold the line for entire time that the interrupt is being
> | serviced).
> 
> hth,
> grant
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
