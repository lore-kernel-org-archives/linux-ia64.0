From: Alex Tsariounov <alext@fc.hp.com>
Date: Thu, 04 Nov 2004 17:59:28 +0000
Subject: Re: [RFC] prefer allocations from nodes w/o CPUs
Message-Id: <20041104175928.GA2427@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411040857.25664.jbarnes@engr.sgi.com>
In-Reply-To: <200411040857.25664.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 04, 2004 at 09:49:53AM -0800, Jesse Barnes wrote:
> On Thursday, November 4, 2004 9:33 am, Jesse Barnes wrote:
> > Memory local to the node will come first, followed by the closest memory
> > that doesn't have associated CPUs, followed by memory belonging to other
> > CPUs.
> 
> Actually, I lied.  There's a bug in find_next_best_node that prevents the 
> local node from coming first if the PENALTY_FOR_NODE_WITH_CPUS is set high 
> enough.  Here's the fix (I'll send it to Andrew shortly).

Great!  Thanks for the review.

Alex
