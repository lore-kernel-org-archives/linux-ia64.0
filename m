From: David Gibson <david@gibson.dropbear.id.au>
Date: Mon, 16 Jan 2012 08:09:40 +0000
Subject: Re: [PATCH 04/14] PowerPC: adapt for dma_map_ops changes
Message-Id: <20120116080940.GF4512@truffala.fritz.box>
List-Id: <linux-ia64.vger.kernel.org>
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
 <1324643253-3024-5-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1324643253-3024-5-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

On Fri, Dec 23, 2011 at 01:27:23PM +0100, Marek Szyprowski wrote:
> From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> 
> Adapt core PowerPC architecture code for dma_map_ops changes: replace
> alloc/free_coherent with generic alloc/free methods.
> 
> Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Looks sane.

Reviewed-by: David Gibson <david@gibson.dropbear.id.au>

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
