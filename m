From: =?ISO-8859-1?Q?G=E9rard_Roudier?= <groudier@free.fr>
Date: Tue, 05 Feb 2002 21:34:37 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698806011@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


On Wed, 6 Feb 2002, David Mosberger wrote:

> >>>>> On Wed, 6 Feb 2002 18:10:42 +0100, Christoph Hellwig <hch@caldera.d=
e> said:
>
>   Christoph> On Wed, Feb 06, 2002 at 12:45:03AM -0800, David S. Miller
>   Christoph> wrote:
>   >> It is not using the DMA apis correctly then, it should be using
>   >> dma_addr_t which may or may not be 64-bits on a given platform.
>
>   Christoph> When the sym2 driver is configured with
>   Christoph> SYM_CONF_DMA_ADDRESSING_MOD > 1 it uses DAC accessing and
>   Christoph> needs dma64_addr_t.  It doesn't use it when using the
>   Christoph> default addressing mode.
>
> The driver never uses the pci_dac* interface, hence it should not use
> dma64_addr_t.  If the driver needs a 64-bit wide type, u64 will do
> fine.

The driver was ready for PCI DAC months before the Linux way to do DAC was
stabilized to the current one. Given the discussion on the harmless way
the sym2 driver is using dma64_addr_t, it seems to me that this interface
may still move.

This let me think that the real problem is not the sym2 driver here, but
rather the Linux IO interfaces saga that lasts from years.

For now just replacing all occurrences (in fact only 1) of the offending
dma64 thing in sym_glue.c by the corresponding dma thing should do the
trick and close this thread as a result.

If you want to discuss about either PCI DAC under Linux or Linux-i64 arch
(that btw seems to be dead prior to have born) then, please, change the
subject of this thread.

  G=E9rard.


