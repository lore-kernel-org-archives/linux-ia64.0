From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 07 Mar 2007 23:18:59 +0000
Subject: Re: NULL pointer in ia64/irq_chip-mask/unmask function (V3)
Message-Id: <m1y7m8abh8.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703072138.l27LcRVE022938@agluck-lia64.sc.intel.com>
In-Reply-To: <200703072138.l27LcRVE022938@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> This patch now has an extra piece for the SGI specific
> occurance of the same context (as noted by Eric).  Just
> posting here in case I misunderstood, or mis-typed while
> applying. Now supplying no-op functions for SN usage.


Looks ok to me.

> -Tony
>
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
>     [IA64] fix NULL pointer in ia64/irq_chip-mask/unmask function
>     
>     This patch fixes boot failure because irq_desc->mask() is NULL.
>     
>     - Added mask/unmask functions to ia64's irq desc function table.
>     - rename hw_interrupt_type to irq_chip. hw_interrupt_type is old name.
>     - Tony: Added same change to arch/ia64/sn/kernel/irq.c as pointed out
>       by Eric Biederman ... mask/unmask functions there can be no-op.
>     
>     Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Tony Luck <tony.luck@intel.com>
>
> diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
> index d6aab40..dcfbf3e 100644
> --- a/arch/ia64/kernel/iosapic.c
> +++ b/arch/ia64/kernel/iosapic.c
> @@ -446,7 +446,7 @@ #define iosapic_enable_level_irq	unmask_
>  #define iosapic_disable_level_irq	mask_irq
>  #define iosapic_ack_level_irq		nop
>  
> -struct hw_interrupt_type irq_type_iosapic_level = {
> +struct irq_chip irq_type_iosapic_level = {
>  	.name =		"IO-SAPIC-level",
>  	.startup =	iosapic_startup_level_irq,
>  	.shutdown =	iosapic_shutdown_level_irq,
> @@ -454,6 +454,8 @@ struct hw_interrupt_type irq_type_iosapi
>  	.disable =	iosapic_disable_level_irq,
>  	.ack =		iosapic_ack_level_irq,
>  	.end =		iosapic_end_level_irq,
> +	.mask =		mask_irq,
> +	.unmask =	unmask_irq,
>  	.set_affinity =	iosapic_set_affinity
>  };
>  
> @@ -493,7 +495,7 @@ #define iosapic_enable_edge_irq		unmask_
>  #define iosapic_disable_edge_irq	nop
>  #define iosapic_end_edge_irq		nop
>  
> -struct hw_interrupt_type irq_type_iosapic_edge = {
> +struct irq_chip irq_type_iosapic_edge = {
>  	.name =		"IO-SAPIC-edge",
>  	.startup =	iosapic_startup_edge_irq,
>  	.shutdown =	iosapic_disable_edge_irq,
> @@ -501,6 +503,8 @@ struct hw_interrupt_type irq_type_iosapi
>  	.disable =	iosapic_disable_edge_irq,
>  	.ack =		iosapic_ack_edge_irq,
>  	.end =		iosapic_end_edge_irq,
> +	.mask =		mask_irq,
> +	.unmask =	unmask_irq,
>  	.set_affinity =	iosapic_set_affinity
>  };
>  
> diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
> index 8c5bee0..8d2a1bf 100644
> --- a/arch/ia64/sn/kernel/irq.c
> +++ b/arch/ia64/sn/kernel/irq.c
> @@ -205,7 +205,17 @@ static void sn_set_affinity_irq(unsigned
>  		(void)sn_retarget_vector(sn_irq_info, nasid, slice);
>  }
>  
> -struct hw_interrupt_type irq_type_sn = {
> +static void
> +sn_mask_irq(unsigned int irq)
> +{
> +}
> +
> +static void
> +sn_unmask_irq(unsigned int irq)
> +{
> +}
> +
> +struct irq_chip irq_type_sn = {
>  	.name		= "SN hub",
>  	.startup	= sn_startup_irq,
>  	.shutdown	= sn_shutdown_irq,
> @@ -213,6 +223,8 @@ struct hw_interrupt_type irq_type_sn = {
>  	.disable	= sn_disable_irq,
>  	.ack		= sn_ack_irq,
>  	.end		= sn_end_irq,
> +	.mask		= sn_mask_irq,
> +	.unmask		= sn_unmask_irq,
>  	.set_affinity	= sn_set_affinity_irq
>  };
>  
