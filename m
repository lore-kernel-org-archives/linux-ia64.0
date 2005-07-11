From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 11 Jul 2005 18:02:26 +0000
Subject: Re: [NUMA] /proc/<pid>/numa_maps to show on which nodes pages reside
Message-Id: <Pine.LNX.4.62.0507111058270.21618@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
 <1121102433.15095.26.camel@localhost>
In-Reply-To: <1121102433.15095.26.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, pj@sgi.com

On Mon, 11 Jul 2005, Dave Hansen wrote:

> So, if something like numa_maps existed, but pointed to the memory
> object instead of the NUMA node directly, you could still easily derive
> the NUMA node.  But, you'd also get information about which particular
> bits of memory are being used.  That might be useful for a user that's
> getting desperate to remove some memory and wants to kill some processes
> that might be less than willing to release that memory.

We really need both I guess. If you dealing with a batch scheduler that
wants to move memory around between nodes in order to optimize programs 
then you nedd to have numa_maps. Maybe we need to have two: numa_maps 
and memory_maps?

> The downside is that we'll have to get that sysfs stuff working for !
> SPARSEMEM configurations.  

If we have two maps then we can avoid that.
