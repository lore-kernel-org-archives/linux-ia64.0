From: Matt_Domsch@Dell.com
Date: Mon, 09 Jul 2001 14:46:31 +0000
Subject: RE: [Linux-ia64] RE: DMA memory limitation?
Message-Id: <marc-linux-ia64-105590693005826@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005820@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005820@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Is there a patch that fixes the pci_alloc_consistent for 
> older versions of
> the IA-64 kernels?  To do 64bit DMA in my driver I need to pass
> pci_alloc_consistent pci_dev pointer of NULL.  

You're not going to find such a thing, and it wouldn't make sense even if
you did.  See Jeff Garzik's note again:

>> The important thing is that pci_alloc_consistent and the other PCI DMA
>> functions work as advertised on IA64.  If you pass NULL to
>> pci_alloc_consistent, IA64 should give you an ISA DMA-able
>> address.  If you don't, you get a 32-bit PCI DMA address.

Never have I seen a using NULL pci_dev pointer give you a 64-bit DMA
address.  Per Jeff's comment, it should give you an address with a mask of
24-bits (within ISA space, i.e. <16MB), but since you can't add in any ISA
cards on IA-64, this wouldn't make much sense either.

At present, the DMA address is entirely dependent upon pci_dev->dma_mask,
which by default is a 32-bit mask, and which you can set to be a 64-bit
mask.  If you need a 64-bit DMA address, create a new pci_dev structure, set
the mask to ~0L and pass that in.  (This may cause other problems, I can't
say for certain.)

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!




