From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 09 Feb 2004 16:38:13 +0000
Subject: Re: [RFC] speeding up pci_unmap_sg() for SAC mappings
Message-Id: <1076344693.3752.26.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16423.42731.766788.360790@gargle.gargle.HOWL>
In-Reply-To: <16423.42731.766788.360790@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-02-09 at 08:27, Jes Sorensen wrote:
[snip]
> 
> Christoph suggested that we add an arch dependent pointer to struct
> scatterlist that we can use to short circuit the unmap process.
> 
> Anyone have any strong objections to this? While it can be considered a
> bit hackerish it really should help on performance without making any
> visible changes to the end user.

   I don't necessarily have a strong objections, but I also don't see
this as a problem that all iommus have.  The sba_iommu, for instance,
has a direct translation between dma_addr_t and pdir entries.  There's
no lookup necessary, just a mask and shift.  The swiotlb uses the same
type of approach.  Even with a change to scatterlist, won't you still
have the issue w/ pci_unmap_single?  Perhaps a lookup table within the
iommu code would provide the speedup you're looking for.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

