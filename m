From: Grant Grundler <grundler@cup.hp.com>
Date: Tue, 23 Apr 2002 01:34:00 +0000
Subject: Re: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905511@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
> Except that pci_alloc_consistent is supposed to return a 32 bit
> address...

And why is that a problem?
Doesn't (or couldn't) swiotlb allocate memory from a "DMA ZONE"?
(I've only worked on real IOMMU support for parisc-linux)

or do you have a driver/system config that might exhaust available
32-bit address space?

BTW, I agree the DAC support and SAC for pci_alloc_consistent()
is, uhm, not very clear.

thanks,
grant

