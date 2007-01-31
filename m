From: Horms <horms@verge.net.au>
Date: Wed, 31 Jan 2007 03:05:56 +0000
Subject: Re: [PATCH] kexec: Avoid migration of already disabled irqs (ia64)
Message-Id: <20070131030553.GH14822@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070130081951.9477.53996.sendpatchset@localhost>
In-Reply-To: <20070130081951.9477.53996.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 30, 2007 at 05:19:51PM +0900, Magnus Damm wrote:
> kexec: Avoid migration of already disabled irqs (ia64)
> 
> This patch fixes up ia64 kexec support for HP rx2620 hardware. It does this 
> by skipping migration of already disabled irqs. This is most likely a problem
> on other ia64 platforms as well, but I've only tested this on one machine
> so far.
> 
> The full story is that handle_bad_irq() gets invoked before starting the new 
> kernel without this patch. This seems to happen when fixup_irqs() calls 
> generic_handle_irq() on already migrated (and disabled) irqs. So by avoiding
> migration of disabled irqs we stay away of handle_bad_irq().
> 
> Signed-off-by: Magnus Damm <magnus@valinux.co.jp>

Although I was not seing this problem on my Tiger2, your change
doesn't seem to break kexec on that patform :)

Acked-by: Simon Horman <horms@verge.net.au>

> ---
> 
>  Tested using kexec-tools-testing 7792798a79b78a5d566f70c9f00237d050b01350
>  on HP rx2620 hardware.
> 
>  Applies on top of 2.6.20-rc6.
> 
>  arch/ia64/kernel/irq.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> --- 0001/arch/ia64/kernel/irq.c
> +++ 0004/arch/ia64/kernel/irq.c	2007-01-30 12:35:10.000000000 +0900
> @@ -122,6 +122,9 @@ static void migrate_irqs(void)
>  	for (irq=0; irq < NR_IRQS; irq++) {
>  		desc = irq_desc + irq;
>  
> +		if (desc->status = IRQ_DISABLED)
> +			continue;
> +
>  		/*
>  		 * No handling for now.
>  		 * TBD: Implement a disable function so we can now
