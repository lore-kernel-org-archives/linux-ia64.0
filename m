From: Robin Holt <holt@sgi.com>
Date: Wed, 10 Nov 2004 17:30:39 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <20041110173039.GA15217@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411081547.iA8FlH90124208@ben.americas.sgi.com> <41919EA5.7030200@yahoo.com.au>
In-Reply-To: <41919EA5.7030200@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Russ Anderson <rja@sgi.com>, Matthew Wilcox <matthew@wil.cx>, "Martin J. Bligh" <mbligh@aracnet.com>, Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Wed, Nov 10, 2004 at 03:52:53PM +1100, Nick Piggin wrote:
> Sorry for wandering off topic here... did I imagine it or did I read
> that you'd tried to get 2048 CPUs going in a single system at NASA?

We could not try it.  The current hardware only supports coherence across
256 nodes with a max of 2 cpus per node.

There is a method to use memory on nodes from the other coherence domains
provided there are no cpus at all in that coherence domain.  In that case,
the hardware uses the coherence domain of the requestor.  What that gives
us is a theoretical case where we could have 1024 nodes with memory, but
only 256 of them with cpus.  I forget what the design limit for memory
per node is, but I do know DIMMs that large are not currently available.

> 
> I guess the lack of triumphant press release means it didn't go well,
> or that I was imagining things.
> 
> Also, are you using 2.6 kernels on these 512 CPU systems? or are your
> 2.4 kernels still holding together at that many CPUs?

Our 2.4 kernel is performing better than the 2.6.  That is because
the 2.4 kernel has a lot more tweaks for our customers than the 2.6.
All of our 2.6 work is being pushed towards the community, so we should
get parity soon.

Robin
