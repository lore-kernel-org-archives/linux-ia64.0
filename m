From: David Rientjes <rientjes@google.com>
Date: Tue, 21 Jul 2015 21:31:09 +0000
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
Message-Id: <alpine.DEB.2.10.1507211428160.3833@chino.kir.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On Tue, 21 Jul 2015, Vlastimil Babka wrote:

> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
> allocator: do not check NUMA node ID when the caller knows the node is valid")
> as an optimized variant of alloc_pages_node(), that doesn't allow the node id
> to be -1. Unfortunately the name of the function can easily suggest that the
> allocation is restricted to the given node. In truth, the node is only
> preferred, unless __GFP_THISNODE is among the gfp flags.
> 
> The misleading name has lead to mistakes in the past, see 5265047ac301 ("mm,
> thp: really limit transparent hugepage allocation to local node") and
> b360edb43f8e ("mm, mempolicy: migrate_to_node should only migrate to node").
> 
> To prevent further mistakes, this patch renames the function to
> alloc_pages_prefer_node() and documents it together with alloc_pages_node().
> 

alloc_pages_exact_node(), as you said, connotates that the allocation will 
take place on that node or will fail.  So why not go beyond this patch and 
actually make alloc_pages_exact_node() set __GFP_THISNODE and then call 
into a new alloc_pages_prefer_node(), which would be the current 
alloc_pages_exact_node() implementation, and then fix up the callers?
