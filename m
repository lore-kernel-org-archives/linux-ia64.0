From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Tue, 25 Feb 2014 20:45:45 +0000
Subject: Re: [PATCH 3/8] lib: Move prototype declaration to header file include/linux/swiotlb.h
Message-Id: <20140225204545.GA4801@phenom.dumpdata.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7bf34999aea7f3d1441dc8fc344882a814da6e06.1393313946.git.rashika.kheria@gmail.com>
 <f95be69d8113dc58603894701e5a3114723b7acc.1393313946.git.rashika.kheria@gmail.com>
In-Reply-To: <f95be69d8113dc58603894701e5a3114723b7acc.1393313946.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Toshi Kani <toshi.kani@hp.com>, Yijing Wang <wangyijing@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, josh@joshtriplett.org

On Tue, Feb 25, 2014 at 01:14:17PM +0530, Rashika Kheria wrote:
> Move prototype declaration of function to header file
> include/linux/swiotlb.h from arch/ia64/hp/common/hwsw_iommu.c,
> arch/ia64/hp/common/sba_iommu.c and arch/x86/pci/sta2x11-fixup.c because
> it is used by more than one file.
> 
> This eliminates the following warning in lib/swiotlb.c:
> lib/swiotlb.c:240:1: warning: no previous prototype for ‘swiotlb_late_init_with_default_size’ [-Wmissing-prototypes]
> lib/swiotlb.c:537:13: warning: no previous prototype for ‘map_single’ [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

One issue below. Did you compile check it on ia64 and arm?
I presume you did it on x86 right?


> ---
>  arch/ia64/hp/common/hwsw_iommu.c |    3 ---
>  arch/ia64/hp/common/sba_iommu.c  |    2 --
>  arch/x86/pci/sta2x11-fixup.c     |    1 -
>  include/linux/swiotlb.h          |    4 +++-
>  4 files changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/ia64/hp/common/hwsw_iommu.c b/arch/ia64/hp/common/hwsw_iommu.c
> index 1e4cae5..b14cab1 100644
> --- a/arch/ia64/hp/common/hwsw_iommu.c
> +++ b/arch/ia64/hp/common/hwsw_iommu.c
> @@ -20,9 +20,6 @@
>  
>  extern struct dma_map_ops sba_dma_ops, swiotlb_dma_ops;
>  
> -/* swiotlb declarations & definitions: */
> -extern int swiotlb_late_init_with_default_size (size_t size);
> -
>  /*
>   * Note: we need to make the determination of whether or not to use
>   * the sw I/O TLB based purely on the device structure.  Anything else
> diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
> index 8e858b5..b341994 100644
> --- a/arch/ia64/hp/common/sba_iommu.c
> +++ b/arch/ia64/hp/common/sba_iommu.c
> @@ -46,8 +46,6 @@
>  
>  #include <asm/acpi-ext.h>
>  
> -extern int swiotlb_late_init_with_default_size (size_t size);
> -
>  #define PFX "IOC: "
>  
>  /*
> diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
> index 9d8a509..a39000b 100644
> --- a/arch/x86/pci/sta2x11-fixup.c
> +++ b/arch/x86/pci/sta2x11-fixup.c
> @@ -28,7 +28,6 @@
>  #include <linux/list.h>
>  
>  #define STA2X11_SWIOTLB_SIZE (4*1024*1024)
> -extern int swiotlb_late_init_with_default_size(size_t default_size);
>  
>  /*
>   * We build a list of bus numbers that are under the ConneXt. The
> diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
> index a5ffd32..7f419b6 100644
> --- a/include/linux/swiotlb.h
> +++ b/include/linux/swiotlb.h
> @@ -27,7 +27,9 @@ int swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose);
>  extern unsigned long swiotlb_nr_tbl(void);
>  unsigned long swiotlb_size_or_default(void);
>  extern int swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs);
> -
> +int swiotlb_late_init_with_default_size (size_t );

Your editor seems to have added an extra space!

> +phys_addr_t map_single(struct device *hwdev, phys_addr_t phys, size_t size,
> +		       enum dma_data_direction dir);
>  /*
>   * Enumeration for sync targets
>   */
> -- 
> 1.7.9.5
> 
