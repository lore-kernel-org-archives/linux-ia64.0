From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 06 Feb 2002 17:15:22 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698806007@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Feb 2002 18:10:42 +0100, Christoph Hellwig <hch@caldera.de> said:

  Christoph> On Wed, Feb 06, 2002 at 12:45:03AM -0800, David S. Miller
  Christoph> wrote:
  >> It is not using the DMA apis correctly then, it should be using
  >> dma_addr_t which may or may not be 64-bits on a given platform.

  Christoph> When the sym2 driver is configured with
  Christoph> SYM_CONF_DMA_ADDRESSING_MOD > 1 it uses DAC accessing and
  Christoph> needs dma64_addr_t.  It doesn't use it when using the
  Christoph> default addressing mode.

The driver never uses the pci_dac* interface, hence it should not use
dma64_addr_t.  If the driver needs a 64-bit wide type, u64 will do
fine.

	--david

