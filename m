From: Christoph Lameter <cl@linux.com>
Date: Tue, 21 Jul 2015 14:05:35 +0000
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
Message-Id: <alpine.DEB.2.11.1507210901150.28813@east.gentwo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On Tue, 21 Jul 2015, Vlastimil Babka wrote:

> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
> allocator: do not check NUMA node ID when the caller knows the node is valid")
> as an optimized variant of alloc_pages_node(), that doesn't allow the node id
> to be -1. Unfortunately the name of the function can easily suggest that the
> allocation is restricted to the given node. In truth, the node is only
> preferred, unless __GFP_THISNODE is among the gfp flags.

Yup. I complained about this when this was introduced. Glad to see this
fixed. Initially this was alloc_pages_node() which just means that a node
is specified. The exact behavior of the allocation is determined by flags
such as GFP_THISNODE. I'd rather have that restored because otherwise we
get into weird code like the one below. And such an arrangement also
leaves the way open to add more flags in the future that may change the
allocation behavior.


>  	area->nid = nid;
>  	area->order = order;
> -	area->pages = alloc_pages_exact_node(area->nid,
> +	area->pages = alloc_pages_prefer_node(area->nid,
>  						GFP_KERNEL|__GFP_THISNODE,
>  						area->order);

This is not preferring a node but requiring alloction on that node.
