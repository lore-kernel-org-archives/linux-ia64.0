From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 23 Aug 2004 17:51:32 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040823185132.A19424@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 23, 2004 at 11:50:59AM -0500, Dean Nelson wrote:
> Just an FYI, XPC needs to use the enable_shub_wars_1_1() macro which
> accesses pda->shub_1_1_found. So we do need to export per_cpu__pda_percpu.
> I've switched EXPORT_SYMBOL() to EXPORT_PER_CPU_SYMBOL() instead.

What about making enable_shub_wars_1_1() a function instead and exporting
that one?  That's the export a sensible interface instead of random symbols
thing, it shouldn't be _that_ hard to get..

