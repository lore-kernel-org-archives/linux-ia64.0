From: Grant Grundler <grundler@cup.hp.com>
Date: Thu, 17 Oct 2002 22:10:13 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805191@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Steffen Persvold wrote:
> Kinda complicated though... I thought the IO system didn't use coherence
> protocols, and it was because of that we needed API functions such as
> pci_dma_sync_single() and pci_dma_sync_sg() to manually ensure coherence..

The original problem was some IOMMU's can not support a static translation
for all physical memory - ie virt_to_bus() wouldn't work.
"manual coherence" works because the design accomodates SW IOTLB
("bounce buffers") model.

Supported HP PARISC and IA64 IOMMU's participate in the coherency protocol.

grant

