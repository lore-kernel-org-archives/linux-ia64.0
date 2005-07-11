From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 11 Jul 2005 17:20:33 +0000
Subject: Re: [NUMA] /proc/<pid>/numa_maps to show on which nodes pages
Message-Id: <1121102433.15095.26.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, pj@sgi.com

On Fri, 2005-07-08 at 14:11 -0700, Christoph Lameter wrote:
> I inherited a large code base from Ray for page migration. There was a
> small patch in there that I find to be very useful since it allows the display
> of the locality of the pages in use by a process. I reworked that patch and came
> up with a /proc/<pid>/numa_maps that gives more information about the vma's of
> a process. numa_maps is indexes by the start address found in /proc/<pid>/maps.
> F.e. with this patch you can see the page use of the "getty" process:

That looks quite useful.  However, it *is* confined to helping NUMA
systems, and I think some modifications could allow it to be used for
memory hotplug.

We're planning to have memory laid out
in /sys/devices/system/memory/memoryXXX, where each memory object has a
fixed size.  If NUMA is on, these objects also point back to their
owning NUMA node.

So, if something like numa_maps existed, but pointed to the memory
object instead of the NUMA node directly, you could still easily derive
the NUMA node.  But, you'd also get information about which particular
bits of memory are being used.  That might be useful for a user that's
getting desperate to remove some memory and wants to kill some processes
that might be less than willing to release that memory.

The downside is that we'll have to get that sysfs stuff working for !
SPARSEMEM configurations.  

-- Dave

