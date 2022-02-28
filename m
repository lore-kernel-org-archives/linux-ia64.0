From: "Michael Kelley (LINUX)" <mikelley@microsoft.com>
Date: Mon, 28 Feb 2022 02:53:39 +0000
Subject: RE: [PATCH 08/11] swiotlb: make the swiotlb_init interface more useful
Message-Id: <MN0PR21MB309816A344171B46735CA29CD7019@MN0PR21MB3098.namprd21.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220227143055.335596-1-hch@lst.de>
 <20220227143055.335596-9-hch@lst.de>
In-Reply-To: <20220227143055.335596-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: "x86@kernel.org" <x86@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-hyperv@vger.kernel.org" <linux-hyperv@vger.kernel.org>, "tboot-devel@lists.sourceforge.net" <tboot-devel@lists.sourceforge.net>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>

From: Christoph Hellwig <hch@lst.de> Sent: Sunday, February 27, 2022 6:31 AM
> 
> Pass a bool to pass if swiotlb needs to be enabled based on the
> addressing needs and replace the verbose argument with a set of
> flags, including one to force enable bounce buffering.
> 
> Note that this patch removes the possibility to force xen-swiotlb
> use using swiotlb=force on the command line on x86 (arm and arm64
> never supported that), but this interface will be restored shortly.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/arm/mm/init.c                     |  6 +----
>  arch/arm64/mm/init.c                   |  6 +----
>  arch/ia64/mm/init.c                    |  4 +--
>  arch/mips/cavium-octeon/dma-octeon.c   |  2 +-
>  arch/mips/loongson64/dma.c             |  2 +-
>  arch/mips/sibyte/common/dma.c          |  2 +-
>  arch/powerpc/include/asm/swiotlb.h     |  1 +
>  arch/powerpc/mm/mem.c                  |  3 ++-
>  arch/powerpc/platforms/pseries/setup.c |  3 ---
>  arch/riscv/mm/init.c                   |  8 +-----
>  arch/s390/mm/init.c                    |  3 +--
>  arch/x86/kernel/cpu/mshyperv.c         |  8 ------
>  arch/x86/kernel/pci-dma.c              | 15 ++++++-----
>  arch/x86/mm/mem_encrypt_amd.c          |  3 ---
>  drivers/xen/swiotlb-xen.c              |  4 +--
>  include/linux/swiotlb.h                | 15 ++++++-----
>  include/trace/events/swiotlb.h         | 29 ++++++++-------------
>  kernel/dma/swiotlb.c                   | 35 ++++++++++++++------------
>  18 files changed, 56 insertions(+), 93 deletions(-)

[snip]

> 
> diff --git a/arch/x86/kernel/cpu/mshyperv.c b/arch/x86/kernel/cpu/mshyperv.c
> index 5a99f993e6392..568274917f1cd 100644
> --- a/arch/x86/kernel/cpu/mshyperv.c
> +++ b/arch/x86/kernel/cpu/mshyperv.c
> @@ -336,14 +336,6 @@ static void __init ms_hyperv_init_platform(void)
>  			swiotlb_unencrypted_base = ms_hyperv.shared_gpa_boundary;
>  #endif
>  		}
> -
> -#ifdef CONFIG_SWIOTLB
> -		/*
> -		 * Enable swiotlb force mode in Isolation VM to
> -		 * use swiotlb bounce buffer for dma transaction.
> -		 */
> -		swiotlb_force = SWIOTLB_FORCE;
> -#endif

With this code removed, it's not clear to me what forces the use of the
swiotlb in a Hyper-V isolated VM.  The code in pci_swiotlb_detect_4g() doesn't
catch this case because cc_platform_has(CC_ATTR_HOST_MEM_ENCRYPT)
returns "false" in a Hyper-V guest.  In the Hyper-V guest, it's only
cc_platform_has(CC_ATTR_GUEST_MEM_ENCRYPT) that returns "true".  I'm
looking more closely at the meaning of the CC_ATTR_* values, and it may
be that Hyper-V should also return "true" for CC_ATTR_MEM_ENCRYPT,
but I don't think CC_ATTR_HOST_MEM_ENCRYPT should return "true".

Michael


