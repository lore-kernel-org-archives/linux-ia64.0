From: Russ Anderson <rja@sgi.com>
Date: Wed, 02 Feb 2005 20:25:04 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200502022025.j12KP4qo16406216@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Any progress?
> 
> The only visible effect of this patch should be that the
> ia64_mca_cpu structures for all cpus will be in one big block,
> instead of scattered across nodes.  Perhaps there is an overrun
> problem so one cpu is corrupting data that belongs to an adjacent
> cpu.  When the allocations are scattered you might notice this
> less often?

Yes, I suspect something along those lines.
I'm actively digging into it.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
