From: Steffen Persvold <sp@scali.com>
Date: Fri, 18 Oct 2002 02:32:29 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805192@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Oct 2002, Grant Grundler wrote:

> Steffen Persvold wrote:
> > Kinda complicated though... I thought the IO system didn't use coherence
> > protocols, and it was because of that we needed API functions such as
> > pci_dma_sync_single() and pci_dma_sync_sg() to manually ensure coherence..
> 
> The original problem was some IOMMU's can not support a static translation
> for all physical memory - ie virt_to_bus() wouldn't work.
> "manual coherence" works because the design accomodates SW IOTLB
> ("bounce buffers") model.
> 
> Supported HP PARISC and IA64 IOMMU's participate in the coherency protocol.
> 

True, but I still can't see how a PTE with the WC attribute (in the CPU 
MMU) can affect the coherency protocol the IOMMU uses on DMA read 
transfers. I thought the WC attribute just controlled how the CPU buffered 
data.

Anyway, although I agree that the availability of the WC feature should be 
checked with the information from the firware, I don't agree that this 
should be done now on the 2.4 series. Atleast don't remove WC (or UC) 
support in any 2.4 kernels before the validation routines are ready and 
implemented.

Regards,
-- 
  Steffen Persvold   |       Scali AS      
 mailto:sp@scali.com |  http://www.scali.com
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY


