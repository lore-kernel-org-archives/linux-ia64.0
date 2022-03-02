From: Christoph Hellwig <hch@lst.de>
Date: Wed, 02 Mar 2022 08:07:46 +0000
Subject: Re: [PATCH 07/11] x86: remove the IOMMU table infrastructure
Message-Id: <20220302080746.GA23075@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220227143055.335596-1-hch@lst.de> <20220227143055.335596-8-hch@lst.de> <Yh5j5q5n/GyU0/1n@0xbeefdead.lan>
In-Reply-To: <Yh5j5q5n/GyU0/1n@0xbeefdead.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

On Tue, Mar 01, 2022 at 01:20:22PM -0500, Konrad Rzeszutek Wilk wrote:
> I think you also need to check for IBM Calgary?

The IBM Calgary IOMMU support is long gone.
