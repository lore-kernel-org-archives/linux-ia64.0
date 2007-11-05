From: Simon Horman <horms@verge.net.au>
Date: Mon, 05 Nov 2007 02:17:20 +0000
Subject: Re: [PATCH] iounmap if tioce_kern_init fails in ia64/sn/pci/tioce_provider.c
Message-Id: <20071105021719.GH16909@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472DA917.9050000@tiscali.nl>
In-Reply-To: <472DA917.9050000@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Nov 04, 2007 at 12:12:23PM +0100, Roel Kluin wrote:
> Do iounmap if tioce_kern_init fails

This is covered by a subsequent patch, right?

> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
> index cee9379..128ed07 100644
> --- a/arch/ia64/sn/pci/tioce_provider.c
> +++ b/arch/ia64/sn/pci/tioce_provider.c
> @@ -1008,6 +1008,7 @@ tioce_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
>  
>  	tioce_kern = tioce_kern_init(tioce_common);
>  	if (tioce_kern = NULL) {
> +		iounmap(tioce_common->ce_pcibus.bs_base);
>  		kfree(tioce_common);
>  		return NULL;
>  	}
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

