From: Christoph Hellwig <hch@lst.de>
Date: Wed, 02 Mar 2022 09:22:04 +0000
Subject: Re: [PATCH 07/11] x86: remove the IOMMU table infrastructure
Message-Id: <20220302092204.GA24139@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220227143055.335596-1-hch@lst.de> <20220227143055.335596-8-hch@lst.de> <CADxRZqxrjp4erFNorH+XqubZWLRNjw2E14z7vOW537no1eKnhw@mail.gmail.com>
In-Reply-To: <CADxRZqxrjp4erFNorH+XqubZWLRNjw2E14z7vOW537no1eKnhw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anatoly Pugachev <matorola@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390 <linux-s390@vger.kernel.org>, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

On Wed, Mar 02, 2022 at 12:18:26PM +0300, Anatoly Pugachev wrote:
> Is it possible to keep documentation comments in source files? Or are
> they completely irrelevant now?

That ones you quoted are very much irrelevant now.  And the behaviour
of the swiotlb disabling will have to change (this patchset is a bit
of a preparation for now) as we now use per-device dma_ops and the
dma-iommu can dip into the swiotlb pool for untrusted devices.  In
practive we'll basically have to always initialize the swiotlb buffer
now.
