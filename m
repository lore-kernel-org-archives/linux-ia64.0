From: Jack Steiner <steiner@sgi.com>
Date: Wed, 02 Feb 2005 23:33:20 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <20050202233319.GA7925@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 02, 2005 at 02:10:32PM -0500, Jes Sorensen wrote:

General comment: 

1) I may be paranoid, but I'm nervous about using memory visible to 
  the VM system for fetchops. If ANYTHING in the kernel makes a 
  reference to the memory and causes a TLB dropin to occur,
  then we are exposed to data corruption. If memory being used for
  fetchops is loaded into the cache, either directly or by speculation, 
  then data corruption of the uncached fetchop memory can occur.
  
  Am I being overly paranoid? How can we be certain that nothing will
  ever reference the fetchop memory alocated from the general VM
  pool. lcrash, for example.
  
2) Is there a limit on the number of mspec pages that can be allocated?
  Is there a shaker that will cause unused mspec granules to be freed?
  What prevents a malicious/stupid/buggy user from filling the system with 
  mspec pages?

3) Is an "mspec" address a physical address or an uncached virtual address?
  Some places in the code appear inconsistent. For example:

	mspec_free_page(TO_PHYS(maddr))
		vs.
	maddr;          /* phys addr of start of mspecs. */
 


A few code specific issues:

...
+                       printk(KERN_WARNING "smp_call_function failed for "
+                              "mspec_ipi_visibility! (%i)\n", status);
+       }
+
+       sn_flush_all_caches((unsigned long)tmp, IA64_GRANULE_SIZE);

Don't the TLBs need to be flushed before you flush caches. Otherwise,
the cpu may reload data via speculation.

I dont see any TLB flushing of the kernel TLB entries that map the
chunks. That needs to be done.
...

+       /*
+        * The kernel requires a page structure to be returned upon
+        * success, but there are no page structures for low granule pages.
+        * remap_page_range() creates the pte for us and we return a
+        * bogus page back to the kernel fault handler to keep it happy
+        * (the page is freed immediately there).
+        */

Ugly hack. Isn't there a better way? (I know this isn't your code & you
probably don't like this either. I had hoped for a cleaner solution in
2.6....)


...

+                               /*
+                                * Use the bte to ensure cache lines
+                                * are actually pulled from the
+                                * processor back to the md.
+                                */
+

This doesn't need to be done if the memory was being used for fetchops or
uncached memory.



+               s <<= 1;
+       }
+       a = (unsigned long) h[j].next;

It appears that you are keeping a linked list of free memory WITHIN the 
mspec memory itself. If I'm reading this correctly, all the addresses are uncached
virtual addresses so that should be ok. However, it might be good to add 
debugging code to make sure that you never cause a cachable reference to be made to any
of the fetchop memory. The resulting data corruption problems are almost 
impossible to debug.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


