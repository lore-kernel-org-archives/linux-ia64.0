From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 26 Jan 2005 19:23:06 +0000
Subject: RE: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02CAA715@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>It seems logical to me that MCA data be close to the node/cpu using
>it, but workable if it is not.

Since performance is not an issue here, and there isn't a functionality
reason for allocating per-node, I'd vote for whatever is the cleanest
code implementation.  Part of the pit I've dug myself into is caused by
the complexity of the contig/discontig code ... if we can make it simpler,
perhaps I won't break it all again.

-Tony
