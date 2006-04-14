From: "John Hawkes" <hawkes@sgi.com>
Date: Fri, 14 Apr 2006 18:04:17 +0000
Subject: Re: Setup an IA64 specific reclaim distance
Message-Id: <003d01c65fed$d90a0c00$6f00a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Christoph Lameter" <clameter@sgi.com>
> Would it not be much simpler to use the SLIT table to estimate the
> migration costs?

If the architecture has a SLIT, perhaps yes.

The current algorithm is very empirical:  for a given pair of CPUs, dirty the
L2 cache, migrate the task to the 2nd CPU, then measure how long it takes to
redirty the data.  The SLIT can give you some metric of "distance" between two
CPUs or two nodes, but the scheduler is looking for something it deems
directly related to the effects of migrating a cache-hot task.

Again, my problem with the migration_cost is that it is expensive to
calculate, and that the calculation takes pains to be accurate to within
10-20%, and yet it makes assumptions (e.g., that the migration cost between
cpu0 and cpu1 is the same as between cpu0 and cpu31) that make its usefulness
questionable.

John Hawkes

