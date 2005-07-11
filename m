From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 11 Jul 2005 20:31:15 +0000
Subject: Re: [NUMA] /proc/<pid>/numa_maps to show on which nodes pages
Message-Id: <1121113875.15095.45.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
	 <1121102433.15095.26.camel@localhost>
	 <Pine.LNX.4.62.0507111058270.21618@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507111058270.21618@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, pj@sgi.com

On Mon, 2005-07-11 at 11:02 -0700, Christoph Lameter wrote:
> On Mon, 11 Jul 2005, Dave Hansen wrote:
> 
> > So, if something like numa_maps existed, but pointed to the memory
> > object instead of the NUMA node directly, you could still easily derive
> > the NUMA node.  But, you'd also get information about which particular
> > bits of memory are being used.  That might be useful for a user that's
> > getting desperate to remove some memory and wants to kill some processes
> > that might be less than willing to release that memory.
> 
> We really need both I guess. If you dealing with a batch scheduler that
> wants to move memory around between nodes in order to optimize programs 
> then you nedd to have numa_maps. Maybe we need to have two: numa_maps 
> and memory_maps?

Well, my point was that, if we have two, the numa_maps can be completely
derived in userspace from the information in memory_maps plus sysfs
alone.  So, why increase the kernel's complexity with two
implementations that can do the exact same thing?  Yes, it might make
the batch scheduler do one more pathname lookup, but that's not the
kernel's problem :)

BTW, are you planning on using SPARSEMEM whenever NUMA is enabled in the
future?  

-- Dave

