From: "David S. Miller" <davem@redhat.com>
Date: Sun, 18 May 2003 09:35:33 +0000
Subject: [Linux-ia64] Re: [patch] support 64 bit pci_alloc_consistent
Message-Id: <marc-linux-ia64-105590723705931@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Arjan van de Ven <arjanv@redhat.com>
   Date: 18 May 2003 11:29:02 +0200

   #define PCI_DMA_64BIT 0xffffffffffffffffULL
   #define PCI_DMA_32BIT 0xffffffffULL
   
   void pci_set_dma_capabilities(device, 
                  u64 streaming_mask, u64 persistent_mask);
   u64 pci_get_effective_streaming_mask(device);
   u64 pci_get_effective_persistent_mask(device);
   
   if for some reason the architecture PCI code needs or wants to reduce
   the DMA mask

WHile logically you are correct, the probing code is going to
look basically identical.

Instead of frobbing around with pci_set_dma() calls, you're going
to be frobbing around with pci_get_effective*() calls and branching
based upon that.

I really see no value in this.  Both are effectively equivalent
and the present setup has the advantage that it has existed for
some time and driver authors (at least some :-) know how to use
it already.

