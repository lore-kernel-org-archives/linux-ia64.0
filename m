From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 23 Feb 2004 21:36:49 +0000
Subject: Re: CPU only nodes (no memory) patch for NUMA/DISCONTIG
Message-Id: <20040223213649.GA8680@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <403A583C.7010808@hp.com>
In-Reply-To: <403A583C.7010808@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 02:45:00PM -0500, Robert Picco wrote:
> David:
> 
> Jesse has reviewed this for me and we are in agreement.  CPU only nodes 
> are moved to a node with memory which is at the closest relative 
> distance per the SLIT information.  Any node reassignments will result 
> in the compression of the nodes and renumbering the nid values where 
> appropriate.

I really just reviewed the feature, I think it actually ends up being a
little better (or at least easier to get right) for situations where a
node has CPUs but no memory than the early bootmem scheme I was
proposing.  I haven't looked at the code much though (aside from asking
for a function comment and DECLARE_BITMAP usage), so I'm not sure about
that part of it...

> There is hope our firmware folks will handle interleaved memory 
> correctly in regards to SLIT and PXM.  There should be more data on this 
> later in the week.  No matter what the outcome of a firmware change,  
> the patch will work.

Cool, keep us posted.

> /*
> + * This function will move nodes with only CPUs (no memory)
> + * to a node with memory which is at the minimum numa_slit distance.
> + * Any reassigments will result in the compression of the nodes
> + * and renumbering the nid values where appropriate.
> + */

May as well use the kdoc style function comment here, just to be
consistent with the rest of the file (it's documented somewhere in
Documentation/kernel-doc-nano-HOWTO.txt).

Thanks,
Jesse
