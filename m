From: Jes Sorensen <jes@sunsite.dk>
Date: Tue, 10 Jul 2001 15:42:02 +0000
Subject: Re: [Linux-ia64] RE: DMA memory limitation?
Message-Id: <marc-linux-ia64-105590693005838@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005820@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005820@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Matt" = Matt Domsch <Matt_Domsch@Dell.com> writes:

>>> The important thing is that pci_alloc_consistent and the other PCI
>>> DMA functions work as advertised on IA64.  If you pass NULL to
>>> pci_alloc_consistent, IA64 should give you an ISA DMA-able
>>> address.  If you don't, you get a 32-bit PCI DMA address.

Matt> Never have I seen a using NULL pci_dev pointer give you a 64-bit
Matt> DMA address.  Per Jeff's comment, it should give you an address
Matt> with a mask of 24-bits (within ISA space, i.e. <16MB), but since
Matt> you can't add in any ISA cards on IA-64, this wouldn't make much
Matt> sense either.

Well but we don't have any ISA busses on the ia64 boxes. The only
reason to return a 24 bit mask would be for broken devices that
require a 31 or 29 bit or similar mask, but one should set that via
the dma_mask interface anyway.

Jes

