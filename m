From: James Bottomley <James.Bottomley@steeleye.com>
Date: Sun, 18 May 2003 14:17:48 +0000
Subject: [Linux-ia64] Re: [patch] support 64 bit pci_alloc_consistent
Message-Id: <marc-linux-ia64-105590723705933@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2003-05-18 at 04:29, Arjan van de Ven wrote:
> An interface like
> 
> #define PCI_DMA_64BIT 0xffffffffffffffffULL
> #define PCI_DMA_32BIT 0xffffffffULL

This we can add now.

> void pci_set_dma_capabilities(device, 
>                u64 streaming_mask, u64 persistent_mask);
> u64 pci_get_effective_streaming_mask(device);
> u64 pci_get_effective_persistent_mask(device);
> 

I see the value in this for weird mask devices, but I don't think it's a
"must fix" for 2.6 since the weird mask devices can advertise a lower
standard supported mask.

The aic driver, for instance, seems to have a 39 bit addressing range
(it uses 32 bit addr and 32 bit len descriptors, but reduces len to 24
bits to steal the extra byte for 7 bits extra addressing).  However, it
is forced to request the full 64 bit address mask---I've never worked
out what will happen to it on a machine with more than 512GB memory.

The lack of a coherent_mask is causing breakage on some platforms, so
putting it in is a 2.6 must fix thing.

James


