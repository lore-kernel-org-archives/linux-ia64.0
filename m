From: Christoph Hellwig <hch@lst.de>
Date: Wed, 01 Jun 2022 17:57:43 +0000
Subject: Re: [PATCH 09/15] swiotlb: make the swiotlb_init interface more useful
Message-Id: <20220601175743.GA28082@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220404050559.132378-1-hch@lst.de> <20220404050559.132378-10-hch@lst.de> <YpehC7BwBlnuxplF@dev-arch.thelio-3990X> <20220601173441.GB27582@lst.de> <YpemDuzdoaO3rijX@Ryzen-9-3900X.>
In-Reply-To: <YpemDuzdoaO3rijX@Ryzen-9-3900X.>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nathan Chancellor <nathan@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

On Wed, Jun 01, 2022 at 10:46:54AM -0700, Nathan Chancellor wrote:
> On Wed, Jun 01, 2022 at 07:34:41PM +0200, Christoph Hellwig wrote:
> > Can you send me the full dmesg and the content of
> > /sys/kernel/debug/swiotlb/io_tlb_nslabs for a good and a bad boot?
> 
> Sure thing, they are attached! If there is anything else I can provide
> or test, I am more than happy to do so.

Nothing interesting.  But the performance numbers almost look like
swiotlb=force got ignored before (even if I can't explain why).
Do you get a similar performance with the new kernel without
swiotlb=force as the old one with that argument by any chance?
