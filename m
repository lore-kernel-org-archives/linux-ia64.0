From: Christoph Hellwig <hch@caldera.de>
Date: Wed, 06 Feb 2002 08:35:58 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698806000@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 06, 2002 at 12:29:06AM -0800, David S. Miller wrote:
> What driver wants to get at this type and what are they using it
> for?  dma_addr_t should be used by every driver I am aware of
> except the clustering PCI cards I've been told about and that
> driver isn't in the kernel at this time.
> 
> So who needs it? :-)

The new sym53c8xx driver (sym2), and that one only if is actually is
configured for DAC-mode (SYM_CONF_DMA_ADDRESSING_MODE > 0).

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

