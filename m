From: =?ISO-8859-1?Q?G=E9rard_Roudier?= <groudier@free.fr>
Date: Wed, 06 Feb 2002 21:38:27 +0000
Subject: Re: [Linux-ia64] Proper fix for sym53c8xx_2 driver and dma64_addr_t
Message-Id: <marc-linux-ia64-105590698806020@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805991@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805991@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


On Wed, 6 Feb 2002, David S. Miller wrote:

>    From: Christoph Hellwig <hch@caldera.de>
>    Date: Wed, 6 Feb 2002 18:10:42 +0100
>
>    When the sym2 driver is configured with SYM_CONF_DMA_ADDRESSING_MOD > 1
>    it uses DAC accessing and needs dma64_addr_t.  It doesn't use it
>    when using the default addressing mode.
>
> NO it damn well does not!  If the platform is NEVER GOING TO GIVE the
> driver a 64-bit address (because, for example, it has IOMMU hardware),
> dma_addr_t need only be 32-bits and that it how it is declared on
> several platforms.
>
> Please read the DMA API documentation.
>
> dma64_addr_t is _ONLY_, I REPEAT _ONLY_ to be used when the driver
> is making use of the following routines for it's DMA usage:
>
> 	pci_dac_page_to_dma
> 	pci_dac_dma_to_page
> 	pci_dac_dma_to_offset
> 	pci_dac_dma_sync_single
>
> And NO SCSI OR NET driver should ever use these routines.
>
> In fact, no driver in the tree right now should be using this.
> The only known example that needs those interfaces are clustering
> cards.  And thats it!
>
> Everything in the tree right now should use only pci_map_single and
> friends, and it should set the device DMA mask bits properly to
> indicate DAC capability.  Do you see any pci_map_single, pci_map_sg,
> etc. implementation working with dma64_addr_t arguments?  If so, thats
> a huge bug and it must be fixed.

You should calm down, in my opinion. All the burden about the PCI dma API
is your fault to you David and you David. :)
It takes a too long time for you 2 Davids to agree about this API.

Personnally, I donnot care about dma64_addr_t versus dma_addr_t being 32,
64 even 69 bits (why not, some machine with 36 bit addressing are still in
use).

Just change the topic, please. The sym2 driver has nothing to do with this
boring thread.

  G=E9rard.


