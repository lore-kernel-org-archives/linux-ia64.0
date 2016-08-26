From: Julia Lawall <julia.lawall@lip6.fr>
Date: Fri, 26 Aug 2016 19:57:34 +0000
Subject: Re: [PATCH 1/5] IA64-IRQ: Use kmalloc_array() in sn_irq_lh_init()
Message-Id: <alpine.DEB.2.10.1608261557130.3645@hadrien>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net> <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
In-Reply-To: <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>



On Fri, 26 Aug 2016, SF Markus Elfring wrote:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 26 Aug 2016 18:32:53 +0200
>
> * A multiplication for the size determination of a memory allocation
>   indicated that an array data structure should be processed.
>   Thus use the corresponding function "kmalloc_array".
>
>   This issue was detected by using the Coccinelle software.
>
> * Replace the specification of data structures by pointer dereferences
>   to make the corresponding size determination a bit safer according to
>   the Linux coding style convention.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  arch/ia64/sn/kernel/irq.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
> index 85d0951..c7f9eea 100644
> --- a/arch/ia64/sn/kernel/irq.c
> +++ b/arch/ia64/sn/kernel/irq.c
> @@ -474,12 +474,12 @@ void __init sn_irq_lh_init(void)
>  {
>  	int i;
>
> -	sn_irq_lh = kmalloc(sizeof(struct list_head *) * NR_IRQS, GFP_KERNEL);
> +	sn_irq_lh = kmalloc_array(NR_IRQS, sizeof(*sn_irq_lh), GFP_KERNEL);
>  	if (!sn_irq_lh)
>  		panic("SN PCI INIT: Failed to allocate memory for PCI init\n");
>
>  	for (i = 0; i < NR_IRQS; i++) {
> -		sn_irq_lh[i] = kmalloc(sizeof(struct list_head), GFP_KERNEL);
> +		sn_irq_lh[i] = kmalloc(*sn_irq_lh[i], GFP_KERNEL);

Did a sizeof get lost here?

julia

>  		if (!sn_irq_lh[i])
>  			panic("SN PCI INIT: Failed IRQ memory allocation\n");
>
> --
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
