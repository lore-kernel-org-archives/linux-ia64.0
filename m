From: "Michael Kelley (LINUX)" <mikelley@microsoft.com>
Date: Sun, 06 Mar 2022 17:01:27 +0000
Subject: RE: [PATCH 10/12] swiotlb: add a SWIOTLB_ANY flag to lift the low memory restriction
Message-Id: <MN0PR21MB3098558B83B5A520FFCCE6D1D7079@MN0PR21MB3098.namprd21.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de>
 <20220301105311.885699-11-hch@lst.de>
 <MN0PR21MB3098F7AFC85BE5D83B0E64E5D7059@MN0PR21MB3098.namprd21.prod.outlook.com>
 <556312e4-da86-b980-475c-1cfd7818ffdc@oracle.com>
In-Reply-To: <556312e4-da86-b980-475c-1cfd7818ffdc@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dongli Zhang <dongli.zhang@oracle.com>, Christoph Hellwig <hch@lst.de>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: "x86@kernel.org" <x86@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-hyperv@vger.kernel.org" <linux-hyperv@vger.kernel.org>, "tboot-devel@lists.sourceforge.net" <tboot-devel@lists.sourceforge.net>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>

From: Dongli Zhang <dongli.zhang@oracle.com> Sent: Friday, March 4, 2022 10:28 AM
> 
> Hi Michael,
> 
> On 3/4/22 10:12 AM, Michael Kelley (LINUX) wrote:
> > From: Christoph Hellwig <hch@lst.de> Sent: Tuesday, March 1, 2022 2:53 AM
> >>
> >> Power SVM wants to allocate a swiotlb buffer that is not restricted to low memory for
> >> the trusted hypervisor scheme.  Consolidate the support for this into the swiotlb_init
> >> interface by adding a new flag.
> >
> > Hyper-V Isolated VMs want to do the same thing of not restricting the swiotlb
> > buffer to low memory.  That's what Tianyu Lan's patch set[1] is proposing.
> > Hyper-V synthetic devices have no DMA addressing limitations, and the
> > likelihood of using a PCI pass-thru device with addressing limitations in an
> > Isolated VM seems vanishingly small.
> >
> > So could use of the SWIOTLB_ANY flag be generalized?  Let Hyper-V init
> > code set the flag before swiotlb_init() is called.  Or provide a CONFIG
> > variable that Hyper-V Isolated VMs could set.
> 
> I used to send 64-bit swiotlb, while at that time people thought it was the same
> as Restricted DMA patchset.
> 
> https://lore.kernel.org/all/20210203233709.19819-1-dongli.zhang@oracle.com/
> 
> However, I do not think Restricted DMA patchset is going to supports 64-bit (or
> high memory) DMA. Is this what you are looking for?

Yes, it looks like your patchset would do what we want for Hyper-V Isolated
VMs, but it is a more complex solution than is needed.  My assertion is that
in some environments, such as Hyper-V Isolated VMs, we're willing to assume
all devices are 64-bit DMA capable, and to stop carrying the legacy baggage.
Bounce buffering is used for a different scenario (memory encryption), and
the bounce buffers can be allocated in high memory.   There's no need for a
2nd swiotlb buffer.

Michael
