From: Grant Grundler <iod00d@hp.com>
Date: Fri, 16 May 2003 01:51:12 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705883@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 06:32:31PM -0500, Colin Ngam wrote:
> I do not understand what you are saying .. how would a consistent_dma_mask
> attribute in the device struct helps pci_alloc_consistent() to return a dma
> hanlde that can have the Upper 32 Bits Non 0's...

Colin,
davem has offered a counter proposal that makes way more sense
that adding parameters to the dma_*() API. It won't change existing
code or existing behaviors. And yes, Documentation/DMA_mapping.txt
(API documentation) has to change to reflect that.

Device Drivers SGI cares about will have to be modified to call
pci_set_consistent_dma_mask() before calling pci_alloc_consistent().

hth,
grant

