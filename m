From: Matt_Domsch@Dell.com
Date: Fri, 06 Jul 2001 15:56:47 +0000
Subject: [Linux-ia64] RE: DMA memory limitation?
Message-Id: <marc-linux-ia64-105590693005820@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The important thing is that pci_alloc_consistent and the other PCI DMA
> functions work as advertised on IA64.  If you pass NULL to
> pci_alloc_consistent, IA64 should give you an ISA DMA-able 
> address.  If
> you don't, you get a 32-bit PCI DMA address.  Use of GFP_DMA is a
> arch-specific detail, so don't let me confuse you there.

Until recently, on IA-64, pci_alloc_consistent() given a NULL pci_dev would
fault.  It's been fixed in at least the most recent IA-64 patch.
pci_map_single() and pci_map_sg() still have the same problem, as they
dereference pci_dev w/o checking for NULL first.


-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!


