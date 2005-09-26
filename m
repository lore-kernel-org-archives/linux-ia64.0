From: Grant Grundler <iod00d@hp.com>
Date: Mon, 26 Sep 2005 22:46:03 +0000
Subject: Re: [patch 2.6.14-rc2 0/5] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <20050926224603.GD16113@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F047E9021@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F047E9021@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "John W. Linville" <linville@tuxdriver.com>, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>, gregkh@suse.de

On Mon, Sep 26, 2005 at 03:08:23PM -0700, Luck, Tony wrote:
> Historically swiotlb.c was written with just PCI in mind (hence
> all the comments ("... implement the PCI DMA API",  "The PCI address
> to use is returned", "teardown the PCI dma mapping") and a few
> error messages ("PCI-DMA: Out of SW-IOMMU space ...", "PCI-DMA: Memory
> would be corrupted", "PCI-DMA: Random memory would be DMAed").
> Perhaps back then the only options were PCI and ISA????

Yes. The DMA interface davem/et al introduce in linux-2.4 only
supported "PCI-Like" busses. Ie the API required struct pci_dev.

> Matthew is probably technically right in that this is a more
> generic interface ... but is it actually being used for anything
> other than PCI?  Will it ever be so used?

Besides 32-bit PCI devices, I expect legacy 24-bit E/ISA DMA will
need it.  Is ISA ~= PCI? I never got a clear answer on that.
I'm inclined to say it's not.

But since swiotlb complies with DMA-API interface and is not related
to any particular type of bus, I'd rather it go into lib/ instead of
drivers/pci.

hth,
grant
