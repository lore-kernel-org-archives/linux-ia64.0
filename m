From: Ashok Raj <ashok.raj@intel.com>
Date: Thu, 14 Jul 2005 17:50:43 +0000
Subject: Re: [RFC][patch 3/10] Multiple vector domain support - introduce gsv
Message-Id: <20050714105043.A2630@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D62F3E.2090609@jp.fujitsu.com>
In-Reply-To: <42D62F3E.2090609@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 14, 2005 at 06:24:14PM +0900, Kenji Kaneshige wrote:

Hi Kaneshige,

Iam in the process of reviewing in detail, but here are a few that 
came by,


>  int
> @@ -290,8 +293,22 @@ ia64_send_ipi (int cpu, int vector, int 
>  void __init
>  ia64_vector_domain_init (void)
>  {
> +	int domain, vec, gsv;
> +
>  	/* Attach BSP to domain #0 */
>  	ia64_attach_cpu_to_domain(0);
> +
> +	/*
> +	 * Make special mapping between per CPU IRQs and GSVs
> +	 */
> +	for (gsv = 0; gsv < NR_GSVS; gsv++) {
> +		vec = gsv_to_vector(gsv);
> +		if (vec < IA64_FIRST_DEVICE_VECTOR ||
> +		    vec > IA64_LAST_DEVICE_VECTOR) {
> +			ia64_gsv_to_irq_map[gsv] = vec;
> +			ia64_irq_to_gsv_map[vec] = vec;

Should the above be = gsv instead of vec?
> +			ia64_irq_to_gsv_map[vec] = vec;
---------------------------------------------------^^^^


> +
> +/*
> + * Convert global system vector to the corresponding IRQ.
> + */
> +static inline int
> +gsv_to_irq (unsigned int gsv)
> +{
> +	if (gsv > NR_GSVS)

Should the above be (gsv >= NR_GSVS)?? 

> +		return -1;
> +	return ia64_gsv_to_irq_map[gsv];
> +}
> +

-- 
Cheers,
Ashok Raj
- Open Source Technology Center
