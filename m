From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 00:03:58 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705866@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 18:40:22 -0500
   
   What I did say is that, on our platform, in PCI-X mode, our PCI-X
   Bridge Chipset do NOT support 32-Bit DMA Bus Space.

Sounds like you can't use a whole swath of devices then.
What an entirely unfortunate design decision.

Anyways, now that I understand the problem, merely adding
the consistent_dma_mask attribute to the device struct will
allow drivers to indicate this capability just fine.
The driver goes:

	if (pci_set_consistent_dma_mask(pdev, ~(u64)0))
		goto probe_error;

and then the platform pci_alloc_consistent() can do whatever is
appropriate.

