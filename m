From: Andrew Morton <akpm@osdl.org>
Date: Thu, 17 Aug 2006 07:28:53 +0000
Subject: Re: [patch 3/5] git-ia64 versus genirq
Message-Id: <20060817002853.4621e955.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060817071455.164893000@tabatha.lab.ultramonkey.org>
In-Reply-To: <20060817071455.164893000@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Aug 2006 16:07:22 +0900
horms@tabatha.lab.ultramonkey.org wrote:

> > commit 1f4c5c1fe2a6a74271989ec079af11e2bb8e2826
> > tree a0da63a3dcc3ffd71653ecc039db416dbcaa86d4
> > parent beada884dd437b509c26b39f1a0b0c6b31e6f340
> > author Andrew Morton <akpm@osdl.org> 1151573360 -0700
> > committer Tony Luck <tony.luck@intel.com> 1151607053 -0700
> > 
> > [IA64] git-ia64 versus genirq
> > 
> > Fix the git-ia64 tree after genirq merge.
> > 
> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> > Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> Patch from test branch of Tony Luck's ia64 tree.
> This is needed for ia64 kexec in Linus's tree.
> 

I think you're telling us that Tony needs to get this into mainline, yes?

> 
> 1f4c5c1fe2a6a74271989ec079af11e2bb8e2826
> diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
> index 03c3118..a1a192c 100644
> --- a/arch/ia64/kernel/crash.c
> +++ b/arch/ia64/kernel/crash.c
> @@ -48,7 +48,7 @@ static void device_shootdown(void)
>         u16 pci_command;
>  
>         list_for_each_entry(dev, &pci_devices, global_list) {
> -               desc = irq_descp(dev->irq);
> +	       desc = irq_desc + dev->irq;
>                 if (!desc->action)
>                         continue;
>                 pci_read_config_word(dev, PCI_COMMAND, &pci_command);
> @@ -57,7 +57,7 @@ static void device_shootdown(void)
>                         pci_write_config_word(dev, PCI_COMMAND, pci_command);
>                 }
>                 disable_irq_nosync(dev->irq);
> -               desc->handler->end(dev->irq);
> +               desc->chip->end(dev->irq);
>         }
>  }
>  
> diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
> index 73fbb26..573a6b8 100644
> --- a/arch/ia64/kernel/machine_kexec.c
> +++ b/arch/ia64/kernel/machine_kexec.c
> @@ -63,13 +63,13 @@ #ifdef CONFIG_PCI
>  	while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
>  		if (!(dev->is_enabled))
>  			continue;
> -		idesc = irq_descp(dev->irq);
> +		idesc = irq_desc + dev->irq;
>  		if (!idesc)
>  			continue;
>  		cpu_set(0, mask);
>  		disable_irq_nosync(dev->irq);
> -		idesc->handler->end(dev->irq);
> -		idesc->handler->set_affinity(dev->irq, mask);
> +		idesc->chip->end(dev->irq);
> +		idesc->chip->set_affinity(dev->irq, mask);
>  		idesc->action = NULL;
>  		pci_disable_device(dev);
>  	}
> diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> index 7d855d2..4ef0356 100644
> --- a/kernel/irq/manage.c
> +++ b/kernel/irq/manage.c
> @@ -398,17 +398,10 @@ EXPORT_SYMBOL(request_irq);
>   */
>  void terminate_irqs(void)
>  {
> -	struct irqaction * action;
> -	irq_desc_t *idesc;
> +	irq_desc_t *desc = irq_desc;
>  	int i;
>  
> -	for (i=0; i < NR_IRQS; i++) {
> -		idesc = irq_descp(i);
> -		action = idesc->action;
> -		if (!action)
> -			continue;
> -		if (idesc->handler->end)
> -			idesc->handler->end(i);
> -	}
> +	for (i = 0; i < NR_IRQS; i++, desc++)
> +		if (desc->action && desc->chip->end)
> +			desc->chip->end(i);
>  }
> -
> 
> --
> 
> -- 
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
