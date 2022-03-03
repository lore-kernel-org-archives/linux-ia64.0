From: Stefano Stabellini <sstabellini@kernel.org>
Date: Thu, 03 Mar 2022 22:49:29 +0000
Subject: Re: [PATCH 11/12] swiotlb: merge swiotlb-xen initialization into swiotlb
Message-Id: <alpine.DEB.2.22.394.2203031447120.3261@ubuntu-linux-20-04-desktop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de> <20220301105311.885699-12-hch@lst.de> <alpine.DEB.2.22.394.2203011720150.3261@ubuntu-linux-20-04-desktop> <20220302081500.GB23075@lst.de> <alpine.DEB.2.22.394.2203021709470.3261@ubuntu-linux-20-04-desktop>
 <20220303105931.GA15137@lst.de>
In-Reply-To: <20220303105931.GA15137@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

On Thu, 3 Mar 2022, Christoph Hellwig wrote:
> On Wed, Mar 02, 2022 at 05:25:10PM -0800, Stefano Stabellini wrote:
> > Thinking more about it we actually need to drop the xen_initial_domain()
> > check otherwise some cases won't be functional (Dom0 not 1:1 mapped, or
> > DomU 1:1 mapped).
> 
> Hmm, but that would be the case even before this series, right?

Before this series we only have the xen_swiotlb_detect() check in
xen_mm_init, we don't have a second xen_initial_domain() check.

The issue is that this series is adding one more xen_initial_domain()
check in xen_mm_init.
