From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 14 Apr 2006 18:22:48 +0000
Subject: RE: Setup an IA64 specific reclaim distance
Message-Id: <4t16i2$m876o@orsmga001.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John Hawkes wrote on Friday, April 14, 2006 11:04 AM
> From: "Christoph Lameter" <clameter@sgi.com>
> > Would it not be much simpler to use the SLIT table to estimate the
> > migration costs?
> 
> The current algorithm is very empirical:  for a given pair of CPUs, dirty the
> L2 cache, migrate the task to the 2nd CPU, then measure how long it takes to
> redirty the data.  The SLIT can give you some metric of "distance" between two
> CPUs or two nodes, but the scheduler is looking for something it deems
> directly related to the effects of migrating a cache-hot task.
> 
> Again, my problem with the migration_cost is that it is expensive to
> calculate, and that the calculation takes pains to be accurate to within
> 10-20%, and yet it makes assumptions (e.g., that the migration cost between
> cpu0 and cpu1 is the same as between cpu0 and cpu31) that make its usefulness
> questionable.

That looks like a design flaw in the migration_cost measurement.  I remember
it previously iterates over all cpu and make boot time measurement unbearable
(something like 30 minutes on a moderately sized numa system).  The solution
was to cache one pair of measurement and not to do the rest assuming they are
the same.  That logic appears to be implemented incorrectly if it behaves like
what you've said above.

It is fixable, I suppose.  I will look into it.

- Ken
