From: Robin Holt <robinmholt@gmail.com>
Date: Tue, 21 Jul 2015 14:14:40 +0000
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
Message-Id: <CAPp3RGryq96pEErEw8x=UV_=xsZS4ACD15uAEaOVT5CgcLzzEQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Christoph Lameter <cl@linux.com>, Cliff Whickman <cpw@sgi.com>

On Tue, Jul 21, 2015 at 8:55 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
> allocator: do not check NUMA node ID when the caller knows the node is valid")
> as an optimized variant of alloc_pages_node(), that doesn't allow the node id
> to be -1. Unfortunately the name of the function can easily suggest that the
> allocation is restricted to the given node. In truth, the node is only
> preferred, unless __GFP_THISNODE is among the gfp flags.
>
...
> Cc: Robin Holt <robinmholt@gmail.com>

Acked-by: Robin Holt <robinmholt@gmail.com>
