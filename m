From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 00:32:42 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705874@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: James Bottomley <James.Bottomley@HansenPartnership.com>
   Date: 15 May 2003 19:31:20 -0500

   	if (ahd->dev_softc != NULL)
   		ahd_pci_set_dma_mask(ahd->dev_softc, 0xFFFFFFFF);
   	*vaddr = pci_alloc_consistent(ahd->dev_softc,
   				      dmat->maxsize, &map->bus_addr);

Funny how whoever wrote this didn't understand that pci_set_dma_mask()
has zero effect on pci_alloc_consistent() behavior.

Someone please tell Justin to fix this broken bit of code.

