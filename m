From: David Rientjes <rientjes@google.com>
Date: Wed, 22 Jul 2015 21:52:48 +0000
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
Message-Id: <alpine.DEB.2.10.1507221445130.21468@chino.kir.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507211428160.3833@chino.kir.corp.google.com> <55AF7F64.1040602@suse.cz>
In-Reply-To: <55AF7F64.1040602@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On Wed, 22 Jul 2015, Vlastimil Babka wrote:

> > alloc_pages_exact_node(), as you said, connotates that the allocation will
> > take place on that node or will fail.  So why not go beyond this patch and
> > actually make alloc_pages_exact_node() set __GFP_THISNODE and then call
> > into a new alloc_pages_prefer_node(), which would be the current
> > alloc_pages_exact_node() implementation, and then fix up the callers?
> 
> OK, but then we have alloc_pages_node(), alloc_pages_prefer_node() and
> alloc_pages_exact_node(). Isn't that a bit too much? The first two
> differ only in tiny bit:
> 
> static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>                                                 unsigned int order)
> {
>         /* Unknown node is current node */
>         if (nid < 0)
>                 nid = numa_node_id();
> 
>         return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
> }
> 
> static inline struct page *alloc_pages_prefer_node(int nid, gfp_t gfp_mask,
>                                                 unsigned int order)
> {
>         VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
> 
>         return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
> }
> 

Eek, yeah, that does look bad.  I'm not even sure the

	if (nid < 0)
		nid = numa_node_id();

is correct; I think this should be comparing to NUMA_NO_NODE rather than
all negative numbers, otherwise we silently ignore overflow and nobody 
ever knows.

> So _prefer_node is just a tiny optimization over the other one. It
> should be maybe called __alloc_pages_node() then? This would perhaps
> discourage users outside of mm/arch code (where it may matter). The
> savings of a skipped branch is likely dubious anyway... It would be also
> nice if alloc_pages_node() could use __alloc_pages_node() internally, but
> I'm not sure if all callers are safe wrt the
> VM_BUG_ON(!node_online(nid)) part.
> 

I'm not sure how large you want to make your patch :)  In a perfect world 
I would think that we wouldn't have an alloc_pages_prefer_node() at all 
and everything would be converted to alloc_pages_node() which would do

	if (nid = NUMA_NO_NODE)
		nid = numa_mem_id();

	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));

and then alloc_pages_exact_node() would do

	return alloc_pages_node(nid, gfp_mask | __GFP_THISNODE, order);

and existing alloc_pages_exact_node() callers fixed up depending on 
whether they set the bit or not.

The only possible downside would be existing users of 
alloc_pages_node() that are calling it with an offline node.  Since it's a 
VM_BUG_ON() that would catch that, I think it should be changed to a 
VM_WARN_ON() and eventually fixed up because it's nonsensical.  
VM_BUG_ON() here should be avoided.

Or just go with a single alloc_pages_node() and rename __GFP_THISNODE to 
__GFP_EXACT_NODE which may accomplish the same thing :)
