From: Simon Horman <horms@verge.net.au>
Date: Mon, 05 Nov 2007 02:15:03 +0000
Subject: Re: iounmap after ioremap in arch/ia64/sn/pci/pcibr/pcibr_provider.c
Message-Id: <20071105021501.GF16909@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472D07AE.1000202@tiscali.nl>
In-Reply-To: <472D07AE.1000202@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Nov 04, 2007 at 12:43:42AM +0100, Roel Kluin wrote:
> A better discription, maybe?
> --
> iounmap after ioremap

Again, this looks correct to me, so long as calling iounmap() actually
reverses ioremap() in this case.

> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
> index ab3eaf8..00d1b85 100644
> --- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
> +++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
> @@ -186,6 +186,7 @@ pcibr_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
>  
>  	if (!soft->pbi_int_ate_resource.ate) {
>  		kfree(soft);
> +		iounmap(soft->pbi_buscommon.bs_base);
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

