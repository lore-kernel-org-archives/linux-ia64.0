From: Dimitri Sivanich <sivanich@sgi.com>
Date: Wed, 22 Feb 2012 01:17:41 +0000
Subject: Re: [PATCH] ia64: genirq fixup for SGI/SN
Message-Id: <20120222011741.GA31796@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120210153055.GA1317@suse.de>
In-Reply-To: <20120210153055.GA1317@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Acked-by: Dimitri Sivanich <sivanich@sgi.com>

On Fri, Feb 10, 2012 at 04:30:56PM +0100, Raymund Will wrote:
> This patch allows the system to boot and enables the console and at least
> some hardware drivers, as well as some platform error handling.
> 
> Tested on a variety of SGI Altix system without issues.
> 
> Original work from Dimitri Sivanich.
> 
> Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
> Test-by: Raymund Will <rw@suse.de>
> ---
>  arch/ia64/sn/kernel/huberror.c          |    2 ++
>  arch/ia64/sn/kernel/irq.c               |    2 ++
>  arch/ia64/sn/pci/pcibr/pcibr_provider.c |    1 +
>  arch/ia64/sn/pci/tioca_provider.c       |    1 +
>  arch/ia64/sn/pci/tioce_provider.c       |    1 +
>  drivers/tty/serial/sn_console.c         |    1 +
>  6 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/ia64/sn/kernel/huberror.c b/arch/ia64/sn/kernel/huberror.c
> index 08b0d9b..f925dec 100644
> --- a/arch/ia64/sn/kernel/huberror.c
> +++ b/arch/ia64/sn/kernel/huberror.c
> @@ -192,6 +192,7 @@ void hub_error_init(struct hubdev_info *hubdev_info)
>  		    hubdev_info);
>  		return;
>  	}
> +	irq_set_handler(SGI_II_ERROR, handle_level_irq);
>  	sn_set_err_irq_affinity(SGI_II_ERROR);
>  }
>  
> @@ -213,6 +214,7 @@ void ice_error_init(struct hubdev_info *hubdev_info)
>                         hubdev_info);
>  		return;
>  	}
> +	irq_set_handler(SGI_TIO_ERROR, handle_level_irq);
>  	sn_set_err_irq_affinity(SGI_TIO_ERROR);
>  }
>  
> diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
> index dfac09a..62cf4dd 100644
> --- a/arch/ia64/sn/kernel/irq.c
> +++ b/arch/ia64/sn/kernel/irq.c
> @@ -352,6 +352,8 @@ void sn_irq_fixup(struct pci_dev *pci_dev, struct sn_irq_info *sn_irq_info)
>  	spin_lock(&sn_irq_info_lock);
>  	list_add_rcu(&sn_irq_info->list, sn_irq_lh[sn_irq_info->irq_irq]);
>  	reserve_irq_vector(sn_irq_info->irq_irq);
> +	if (sn_irq_info->irq_int_bit != -1)
> +		irq_set_handler(sn_irq_info->irq_irq, handle_level_irq);
>  	spin_unlock(&sn_irq_info_lock);
>  
>  	register_intr_pda(sn_irq_info);
> diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
> index 8886a0b..8dbbef4 100644
> --- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
> +++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
> @@ -146,6 +146,7 @@ pcibr_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
>  		printk(KERN_WARNING
>  		       "pcibr cannot allocate interrupt for error handler\n");
>  	}
> +	irq_set_handler(SGI_PCIASIC_ERROR, handle_level_irq);
>  	sn_set_err_irq_affinity(SGI_PCIASIC_ERROR);
>  
>  	/* 
> diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
> index e77c477..a70b11f 100644
> --- a/arch/ia64/sn/pci/tioca_provider.c
> +++ b/arch/ia64/sn/pci/tioca_provider.c
> @@ -649,6 +649,7 @@ tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
>  		       __func__, SGI_TIOCA_ERROR,
>  		       (int)tioca_common->ca_common.bs_persist_busnum);
>  
> +	irq_set_handler(SGI_TIOCA_ERROR, handle_level_irq);
>  	sn_set_err_irq_affinity(SGI_TIOCA_ERROR);
>  
>  	/* Setup locality information */
> diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
> index 27faba0..46d3df4 100644
> --- a/arch/ia64/sn/pci/tioce_provider.c
> +++ b/arch/ia64/sn/pci/tioce_provider.c
> @@ -1037,6 +1037,7 @@ tioce_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
>  		       tioce_common->ce_pcibus.bs_persist_segment,
>  		       tioce_common->ce_pcibus.bs_persist_busnum);
>  
> +	irq_set_handler(SGI_PCIASIC_ERROR, handle_level_irq);
>  	sn_set_err_irq_affinity(SGI_PCIASIC_ERROR);
>  	return tioce_common;
>  }
> diff --git a/drivers/tty/serial/sn_console.c b/drivers/tty/serial/sn_console.c
> index 238c7df..8e4129c 100644
> --- a/drivers/tty/serial/sn_console.c
> +++ b/drivers/tty/serial/sn_console.c
> @@ -743,6 +743,7 @@ static void __init sn_sal_switch_to_interrupts(struct sn_cons_port *port)
>  			spin_lock_irqsave(&port->sc_port.lock, flags);
>  			port->sc_port.irq = SGI_UART_VECTOR;
>  			port->sc_ops = &intr_ops;
> +			irq_set_handler(port->sc_port.irq, handle_level_irq);
>  
>  			/* turn on receive interrupts */
>  			ia64_sn_console_intr_enable(SAL_CONSOLE_INTR_RECV);
> -- 
> 1.7.6.1
> 
> -- 
> Raymund Will                                                rw@SuSE.de
> SUSE LINUX Products GmbH    GF: Jeff Hawn     HRB 16746 (AG Nuernberg)
