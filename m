From: Prarit Bhargava <prarit@redhat.com>
Date: Thu, 05 Jul 2007 15:39:35 +0000
Subject: Re: [IA64] [kdump] machveg=dig on hpzx1 platforms
Message-Id: <468D10B7.4020600@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070621182441.GA21840@suse.de> <467AE260.7030906@hp.com>
In-Reply-To: <467AE260.7030906@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Terry Loftin <terry.loftin@hp.com>
Cc: linux-ia64@vger.kernel.org, Bernhard Walle <bwalle@suse.de>, Khalid Aziz <khalid_aziz@hp.com>, kexec@lists.infradead.org


>
> Here is a patch to do that.  We use this internally, but
> I had forgotten to post it.
>

Not that it matters a huge amount, but this has been in RHEL5 for 
sometime and does fix the "machvec=dig" nuisance.

(Sorry for not replying earlier Terry -- I had a huge backlog of things 
to get to before this ...)

P.


> -T
>
> ---
> diff --git a/arch/ia64/hp/common/sba_iommu.c 
> b/arch/ia64/hp/common/sba_iommu.c
> --- a/arch/ia64/hp/common/sba_iommu.c
> +++ b/arch/ia64/hp/common/sba_iommu.c
> @@ -42,6 +42,9 @@ #include <asm/dma.h>
>  #include <asm/system.h>        /* wmb() */
>
>  #include <asm/acpi-ext.h>
> +#include <linux/crash_dump.h>
> +
> +extern int swiotlb_late_init_with_default_size (size_t size);
>
>  #define PFX "IOC: "
>
> @@ -2026,11 +2029,24 @@ sba_init(void)
>      if (!ia64_platform_is("hpzx1") && 
> !ia64_platform_is("hpzx1_swiotlb"))
>          return 0;
>
> +#ifdef CONFIG_CRASH_DUMP
> +    /* If we are booting a kdump kernel, the sba_iommu will
> +     * cause devices that were not shutdown properly to MCA
> +     * as soon as they are turned back on.  Our only option for
> +     * a successful kdump kernel boot is to use the swiotlb.
> +     */
> +    if (elfcorehdr_addr < ELFCORE_ADDR_MAX) {
> +        if (swiotlb_late_init_with_default_size(64 * (1<<20)) != 0)
> +            panic("Unable to initialize software I/O TLB:"
> +                  " Try machvec=dig boot option");
> +        machvec_init("dig");
> +        return 0;
> +    }
> +#endif
> +
>      acpi_bus_register_driver(&acpi_sba_ioc_driver);
>      if (!ioc_list) {
>  #ifdef CONFIG_IA64_GENERIC
> -        extern int swiotlb_late_init_with_default_size (size_t size);
> -
>          /*
>           * If we didn't find something sba_iommu can claim, we
>           * need to setup the swiotlb and switch to the dig machvec.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
