From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Feb 2007 03:33:35 +0000
Subject: Re: [patch 03/13] ia64: swiotlb bug fixes
Message-Id: <20070206033335.GA10712@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200702060021.l160L48p004187@shell0.pdx.osdl.net>
In-Reply-To: <200702060021.l160L48p004187@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 05, 2007 at 04:20:00PM -0800, akpm@linux-foundation.org wrote:
> From: "Jan Beulich" <jbeulich@novell.com>
> 
> This patch fixes
> - marking I-cache clean of pages DMAed to now only done for IA64
> - broken multiple inclusion in include/asm-x86_64/swiotlb.h
> - missing call to mark_clean in swiotlb_sync_sg()
> - a (perhaps only theoretical) issue in swiotlb_dma_supported() when
>   io_tlb_end is exactly at the end of memory
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> Cc: "Luck, Tony" <tony.luck@intel.com>
> Cc: Andi Kleen <ak@suse.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Andi,

Are you OK with these changes (and the ones in parts 4, 5, 6 that
also touch swiotlb)?  They build cleanly on x86_64, but I haven't
tested them there.

I can run them all through my tree to Linus if you are OK with that.

-Tony
