From: Grant Grundler <iod00d@hp.com>
Date: Mon, 09 Feb 2004 16:52:08 +0000
Subject: Re: [RFC] speeding up pci_unmap_sg() for SAC mappings
Message-Id: <20040209165208.GC27604@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16423.42731.766788.360790@gargle.gargle.HOWL>
In-Reply-To: <16423.42731.766788.360790@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 09, 2004 at 10:27:39AM -0500, Jes Sorensen wrote:
> I was looking at the sn2 PCI mapping code and realized how it is costing
> to do a basic pci_unmap because the code has to search a table to figure
> out which struct dmamap entry matches a given dma address. Clearly the
> sn code could be improved in terms of how it is currently implemented,
> however there is still the fundamental problem of mapping from a
> dma_addr_t to a dma-map entry which I believe all IOMMU code
> implmentations suffer from.

Not the two implementations I helped write.
Did you have some particular other (non-ia64) implementations in mind?

Neither ccio-dma (parisc only) nor sba_iommu (parisc, ia64) maintain
any seperate tables outside the bitmap to manage "free/used".
All relevant info is stored directly in the IO Pdir (or NOT if
the IO Pdir is being bypassed - ia64 only).

> The pretty way to clean this up would
> probably require changing the whole mapping API, however one of the most
> interesting cases is pci_unmap_sg.

HPUX uses a "DMA Handle" to reference a "DMA Object".
That works too but is not as simple and not lighter weight.

> Christoph suggested that we add an arch dependent pointer to struct
> scatterlist that we can use to short circuit the unmap process.

yeah, I understand how that might help.
But it doesn't solve the problem for networking drivers.

And it will grow the cacheline footprint of the SG list.
Right now we are at 32 bytes (28 bytes used) - 4 per cacheline.
Alignment requirements would push that to 40 bytes per entry.
While this isn't a big deal, it will impact all platforms.

> Anyone have any strong objections to this? While it can be considered a
> bit hackerish it really should help on performance without making any
> visible changes to the end user.

Another even more hackerish idea is to use the remaining "int" (4 bytes)
as an index into a table.

> Comments?

Can one extract an "index" from contents of dma_address field?
If so, then the same "index" should work for pci_map_single() as well.

Is it necessary to touch the IOMMU for 64-bit capable devices? 
Any way to differentiate 32 vs 64-bit and PCI vs PCI-X mappings
so the problem can be handled seperately for each "class" of mapping?

If only 32-bit PCI devices have this problem, I think I'd rather
not see 'struct scatterlist' grow.

hth,
grant
