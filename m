From: Jes Sorensen <jes@trained-monkey.org>
Date: Mon, 09 Feb 2004 15:27:39 +0000
Subject: [RFC] speeding up pci_unmap_sg() for SAC mappings
Message-Id: <16423.42731.766788.360790@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I was looking at the sn2 PCI mapping code and realized how it is costing
to do a basic pci_unmap because the code has to search a table to figure
out which struct dmamap entry matches a given dma address. Clearly the
sn code could be improved in terms of how it is currently implemented,
however there is still the fundamental problem of mapping from a
dma_addr_t to a dma-map entry which I believe all IOMMU code
implmentations suffer from. The pretty way to clean this up would
probably require changing the whole mapping API, however one of the most
interesting cases is pci_unmap_sg.

Christoph suggested that we add an arch dependent pointer to struct
scatterlist that we can use to short circuit the unmap process.

Anyone have any strong objections to this? While it can be considered a
bit hackerish it really should help on performance without making any
visible changes to the end user.

Comments?

Cheers,
Jes
