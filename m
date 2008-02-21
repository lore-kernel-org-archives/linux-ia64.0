From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 21 Feb 2008 23:08:15 +0000
Subject: Re: [PATCH 20/28] ia64/xen: domU xen machine vector without dma api.
Message-Id: <47BE045F.6000604@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

yamahata@valinux.co.jp wrote:
> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> index 78f28d8..9c17a46 100644
> --- a/arch/ia64/kernel/acpi.c
> +++ b/arch/ia64/kernel/acpi.c
> @@ -118,6 +118,10 @@ acpi_get_sysname(void)
>  		return "hpzx1";
>  	} else if (!strcmp(hdr->oem_id, "SGI")) {
>  		return "sn2";
> +#ifdef CONFIG_XEN
> +	} else if (is_running_on_xen() && !strcmp(hdr->oem_id, "XEN")) {
> +		return "xen";
> +#endif
>  	}

Is the #ifdef necessary?  Couldn't you make is_running_on_xen() just 
evaluate to 0 in the non-Xen case?

    J
