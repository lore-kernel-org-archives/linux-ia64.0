From: "David S. Miller" <davem@redhat.com>
Date: Wed, 06 Feb 2002 08:45:03 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698806001@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Christoph Hellwig <hch@caldera.de>
   Date: Wed, 6 Feb 2002 09:35:58 +0100

   On Wed, Feb 06, 2002 at 12:29:06AM -0800, David S. Miller wrote:
   > So who needs it? :-)
   
   The new sym53c8xx driver (sym2), and that one only if is actually is
   configured for DAC-mode (SYM_CONF_DMA_ADDRESSING_MODE > 0).

It is not using the DMA apis correctly then, it should be using
dma_addr_t which may or may not be 64-bits on a given platform.

The sym2 driver needs to be fixed.

Franks a lot,
David S. Miller
davem@redhat.com

