From: Robin Holt <holt@sgi.com>
Date: Tue, 04 Sep 2007 08:46:22 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled - take 2
Message-Id: <20070904084622.GB4037@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Please don't take this as a review.  I only glanced over it while waiting
for coffee to brew.

How does this align with sn2's tlb shootdown mechanism?  It seems similar
in intent.


On Mon, Sep 03, 2007 at 01:06:20AM -0700, Natalie Protasevich wrote:
> global cache purge in their chipset implementation. (For such cases, Intel provided a SAL 
> table entry to specify if ptc.g is allowed and how many).

This seems odd.  You never use that sal call to initialized noptcg.
Is that an oversight?

> +	/*
> +	 * Wait for other CPUs to finish purging entries.
> +	 */
> +	while (atomic_read(&ia64_global_tlb_flush_cpu_count)) {
> +		/* Nothing */

I think you want a cpu_relax() for hyper-threaded cpus can make
progress.

> -	/* HW requires global serialization of ptc.ga.  */
> +	/* 
> +	 * HW requires global serialization of ptc.ga, and same does
> +	 * IPI based implementation of global TLB purge

How about:
	 * HW requires global serialization of ptc operations */

