From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Tue, 05 Apr 2022 20:06:47 +0000
Subject: Re: cleanup swiotlb initialization v8
Message-Id: <48526600-081d-7be1-88cc-cf47cdb0253b@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220404050559.132378-1-hch@lst.de>
In-Reply-To: <20220404050559.132378-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org


On 4/4/22 1:05 AM, Christoph Hellwig wrote:
> Hi all,
>
> this series tries to clean up the swiotlb initialization, including
> that of swiotlb-xen.  To get there is also removes the x86 iommu table
> infrastructure that massively obsfucates the initialization path.
>
> Git tree:
>
>      git://git.infradead.org/users/hch/misc.git swiotlb-init-cleanup
>
> Gitweb:
>
>      http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/swiotlb-init-cleanup




Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

