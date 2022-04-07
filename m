From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Thu, 07 Apr 2022 00:31:48 +0000
Subject: Re: cleanup swiotlb initialization v8
Message-Id: <Yk4w9N7IATu20RaM@char.us.oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220404050559.132378-1-hch@lst.de>
In-Reply-To: <20220404050559.132378-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

On Mon, Apr 04, 2022 at 07:05:44AM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> this series tries to clean up the swiotlb initialization, including
> that of swiotlb-xen.  To get there is also removes the x86 iommu table
> infrastructure that massively obsfucates the initialization path.
> 
> Git tree:
> 
>     git://git.infradead.org/users/hch/misc.git swiotlb-init-cleanup
> 
> Gitweb:
> 
>     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/swiotlb-init-cleanup
> 
> Changes since v7:
>  - rebased to Linux 5.18-rc1
>  - better document the lower bound swiotlb size for xen-swiotlb
>  - improve the nslabs calculation for the retry case in
>    swiotlb_init_remap and swiotlb_init_late

Hey Christoph,

Feel free to tack on

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

on them if you would like.

Thank you for doing the spring cleaning of this codebase!
