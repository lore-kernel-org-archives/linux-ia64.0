From: Christoph Hellwig <hch@caldera.de>
Date: Wed, 06 Feb 2002 17:15:16 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698806008@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 06, 2002 at 06:10:42PM +0100, Christoph Hellwig wrote:
> On Wed, Feb 06, 2002 at 12:45:03AM -0800, David S. Miller wrote:
> > It is not using the DMA apis correctly then, it should be using
> > dma_addr_t which may or may not be 64-bits on a given platform.
> 
> When the sym2 driver is configured with SYM_CONF_DMA_ADDRESSING_MOD > 1
> it uses DAC accessing and needs dma64_addr_t.  It doesn't use it
> when using the default addressing mode.

Sorry, it doesn't use the _dac_ APIs.  Still I'm the opinion that either
architecture should support dma64_addr_t or we need a HAVE_PCI_DAC_API
define.

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

