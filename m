From: jbarnes@sgi.com (Jesse Barnes)
Date: Sat, 21 Feb 2004 04:42:10 +0000
Subject: Re: [PATCH] Fix 64 bit DMA mapping problem with PCI cards on SN2
Message-Id: <20040221044210.GA28510@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040221010841.GC530871@sgi.com>
In-Reply-To: <20040221010841.GC530871@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, it looks like we accidentally dropped a hunk in the DMA mapping
code.  Can you please push this patch to Linus soon?

Thanks,
Jesse

On Fri, Feb 20, 2004 at 05:08:41PM -0800, Jeremy Higdon wrote:
> PCI cards were forced to 32 bit addresses.  There is significant
> extra overhead to DMA setup with 32 bit, and it is fairly easy to
> run out of mapping resources.
> 
> This patch reenables 64 bit DMA mapping for PCI cards.
