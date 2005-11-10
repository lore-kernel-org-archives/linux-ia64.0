From: Jack Steiner <steiner@sgi.com>
Date: Thu, 10 Nov 2005 02:54:21 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051110025421.GA3765@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 09, 2005 at 04:27:48PM -0800, Luck, Tony wrote:
> >Is it possible you are mixing up MAX_NUMALINK_NODES (the maximum
> >system size, i.e., the maximum number of nodes in a numalink domain)
> >with CONFIG_NR_CPUS (the maximum SSI size)?
> >
> >I'm pretty confident SGI has not proposed setting CONFIG_NR_CPUS384
> >to any OSV. ;-)
> 
> It's always possible that I'm confused.  Here's the message where
> Robin introduced the rationale for 4-level page tables:

You are not confused, but this is a confusing area. A lot of 
the terminology that we use to describe these configurations has
been misused or poorly defined.

Altix currently supports a max SSI of 256 nodes (1024p). However, multiple
SSIs can be interconnected via NUMALINK. 

XPMEM provides the ability for a single task running within an SSI
to access ALL the memory thruout the NUMALINK fabric, ie. memory
can be exported from a task running within one SSI to a task 
running in another SSI. 


For example, if you have:

	128 GB per SSI 
	16 SSIs connected via NUMALINK

a task running within an SSI can access all 2TB of memory (excluding memory
used by the kernel)

	Note: SSI = fat node = cluster 

> 
>  http://tinyurl.com/bewsk
> 
> In that he says "current = 2048" ... which I think is how many
> cpus can be in the whole box ... 512 is the current max cpus in
> a coherence domain (and thus the max that a single instance of
> Linux will see today).
> 
> With Montecito (dual core, two threads in each core) the number
> of cpus Linux sees will be quadrupled in a system with the same
> number of sockets.  Add more sockets, and the 16384 number may
> not be impossible.
> 
> -Tony

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


