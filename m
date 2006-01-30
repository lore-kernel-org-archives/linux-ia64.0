From: "John Hawkes" <hawkes@sgi.com>
Date: Mon, 30 Jan 2006 20:43:22 +0000
Subject: Re: boot-time slowdown for measure_migration_cost
Message-Id: <008901c625dd$d02e6760$6f00a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601271403.27065.bjorn.helgaas@hp.com> <20060130172140.GB11793@elte.hu> <20060130185301.GA4622@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@elte.hu>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: "Luck, Tony" <tony.luck@intel.com>
...
> So the variation in the computed value of migration_cost was at worst
> 2% with these modifications to the algorithm.  Do you really need to know
> the value to this accuracy?  What 2nd order bad effects would occur from
> using an off-by-2% value for scheduling decisions?
>
> On the plus side Prarit's results show that this time isn't scaling with
> NR_CPUS ... apparently just cache size and number of domains are significant
> in the time to compute.

Yes, the calculation is done just once per domain level, and a desire to
achieve great accuracy for the calculation presupposes that the cpuM-to-cpuN
migration cost for a given domain level is identical (or very close) across
all the CPU pairs.  That is, for a given domain level, only one CPU pair are
chosen for the calculation.  For the ia64/sn2 NUMA Altix, and I suspect for
other NUMA platforms, this just isn't true for the middle domain level (i.e.,
the level that appears when the CPU count is >32p) -- i.e., some CPU pairs are
"closer" than other pairs.  The variation for other CPU pairs in this domain
level is certainly much greater than 2%.

John Hawkes

