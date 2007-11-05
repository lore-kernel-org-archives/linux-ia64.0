From: Simon Horman <horms@verge.net.au>
Date: Mon, 05 Nov 2007 02:16:42 +0000
Subject: Re: [PATCH] Also iounmap when kzalloc fails in tioca_bus_fixup (ia64/sn/pci/tioca_provider.c)
Message-Id: <20071105021641.GG16909@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472D0958.9030203@tiscali.nl>
In-Reply-To: <472D0958.9030203@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Nov 04, 2007 at 12:50:48AM +0100, Roel Kluin wrote:
> Also iounmap when kzalloc fails

This looks correct to me, so long as calling iounmap() actually
reverses ioremap() in this case.

> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
> index ef048a6..de1ec5c 100644
> --- a/arch/ia64/sn/pci/tioca_provider.c
> +++ b/arch/ia64/sn/pci/tioca_provider.c
> @@ -618,6 +618,7 @@ tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
>  
>  	tioca_kern = kzalloc(sizeof(struct tioca_kernel), GFP_KERNEL);
>  	if (!tioca_kern) {
> +		iounmap(tioca_common->ca_common.bs_base);
>  		kfree(tioca_common);
>  		return NULL;
>  	}
> @@ -637,6 +638,7 @@ tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
>  	/* init GART */
>  
>  	if (tioca_gart_init(tioca_kern) < 0) {
> +		iounmap(tioca_common->ca_common.bs_base);
>  		kfree(tioca_kern);
>  		kfree(tioca_common);
>  		return NULL;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

