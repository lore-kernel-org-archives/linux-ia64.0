From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 22 Mar 2006 01:08:18 +0000
Subject: Re: [PATCH: 002/017]Memory hotplug for new nodes v.4.(change name
Message-Id: <1142989698.10906.224.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317162757.C63B.Y-GOTO@jp.fujitsu.com>
	 <1142615538.10906.67.camel@localhost.localdomain>
	 <20060318102653.57c6a2af.kamezawa.hiroyu@jp.fujitsu.com>
	 <1142964013.10906.158.camel@localhost.localdomain>
	 <20060322090514.6d6826fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060322090514.6d6826fc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: y-goto@jp.fujitsu.com, akpm@osdl.org, tony.luck@intel.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Wed, 2006-03-22 at 09:05 +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Mar 2006 10:00:12 -0800
> Dave Hansen <haveblue@us.ibm.com> wrote:
> > At some point in the process, you need to export the NUMA node layout to
> > the rest of the system, to say which pages go in which node.  I'm just
> > saying that you should do that _before_ add_memory().
> > 
> To do so, we have to maintain new pfn_to_nid() function.
> We have to maintain a new table/list and have to consider name of it :).

I completely spaced out, and forgot that we use sparsemem and 'struct
pages' for pfn_to_nid() now.  I've been buried too deep in the i386
discontigmem physnode_map[].  Sorry.

If I missed it before, please refresh my memory.  But, if we're
providing arch_nid_probe(addr), then why don't we just call it inside of
add_memory() on the start address, instead of in the generic code?

I'm also getting a bit confused in your patches whether add_memory() is
the _original_ add_memory(), or the new one.  It tends to get lost in 17
patches. :(

I don't really like the arch_nid_probe() name.  We need to make it very
apparent that it is to be used _only_ for memory hotplug operations.  It
has no meaning for anything else.

	hotplug_physaddr_to_nid()?

Maybe with a "memory_" in front.  Maybe even
memory_add_physaddr_to_nid()?

It was probably to keep from changing as little code as possible, but
please convert the u64 values to pfns as soon as possible.  I noticed
that hotadd_new_pgdat() still deals with them, and does the shift as
well.  Is that really necessary.

The u64s should not be kept for more than one level of calls.  That
level of calls should be the firmware.  So, let the firmware call into
the VM code with u64s, then have all of the plain VM code deal in pfns.

-- Dave

