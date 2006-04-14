From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 14 Apr 2006 17:41:05 +0000
Subject: Re: Setup an IA64 specific reclaim distance
Message-Id: <Pine.LNX.4.64.0604141040340.18724@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 14 Apr 2006, John Hawkes wrote:

> For example, one level of sched domain is the all-CPUs sched domain.  For a
> NUMA system it is unlikely that the migration_cost between cpu0 and cpu1 is
> the same as between cpu0 and cpu511, and yet only cpu0 and cpu1 are chosen.
> Another sched domain level on sn2 platforms, typically two CPUs per node, is
> 32p.  Again, there the migration_cost between cpu0 and cpu1 is different than
> cpu0 and cpu31.

Would it not be much simpler to use the SLIT table to estimate the 
migration costs?

