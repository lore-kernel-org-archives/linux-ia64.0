From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 04 Dec 2001 18:19:55 +0000
Subject: Re: [Linux-ia64] patch to no longer use ia64's software mmu
Message-Id: <marc-linux-ia64-105590698805595@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Alan> I don't see the need: GFP_DMA is the ISA DMA zone. pci_* API
>   Alan> is used by everyone else [for 2.5].
> 
> Without a 4GB zone, you may end up creating bounce buffers needlessly
> for 32-bit capable DMA devices, no?

Yes - but it becomes an implementation detail. Drivers don't go around
asking for kmalloc in 4Gb zone anymore they ask for PCI memory that a 32bit
pci address can hit. I'm sure a 4Gb zone is what will be there internally
but you don't need GFP_4GBZONE as a visible driver detail.

Alan



