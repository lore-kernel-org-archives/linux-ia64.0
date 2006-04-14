From: "John Hawkes" <hawkes@sgi.com>
Date: Fri, 14 Apr 2006 17:36:40 +0000
Subject: Re: Setup an IA64 specific reclaim distance
Message-Id: <002101c65fe9$fd76fc50$6f00a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Christoph Lameter" <clameter@sgi.com>
> > Is the right value for this any any way related to the "migration_cost"
> > that we spend many seconds of boot time computing?
>
> I am not familiar with that. Does the migration_cost take the
> SLIT node distances into consideration?

No.  The migration_cost is an empirical runtime calculation that estimates the
relative cost of migrating a task within each level of sched domain.  And even
that is sometimes grossly inaccurate because only two arbitrary CPUs are
chosen for this calculation within one sched domain at each level, thus
assuming that the migration_cost is the same between any and all two CPUs in
that sched domain, and that all the sched domains for a given level exhibit
equivalent migration_cost behavior.

For example, one level of sched domain is the all-CPUs sched domain.  For a
NUMA system it is unlikely that the migration_cost between cpu0 and cpu1 is
the same as between cpu0 and cpu511, and yet only cpu0 and cpu1 are chosen.
Another sched domain level on sn2 platforms, typically two CPUs per node, is
32p.  Again, there the migration_cost between cpu0 and cpu1 is different than
cpu0 and cpu31.

John Hawkes

