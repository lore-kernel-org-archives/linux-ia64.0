From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 30 Jun 2008 00:06:53 +0000
Subject: Re: [PATCH] ia64: export account_system_vtime
Message-Id: <4868239D.5020202@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1214577950.3232.10.camel@oberon>
In-Reply-To: <1214577950.3232.10.camel@oberon>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Acked-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

Thanks,
H.Seto

Doug Chapman wrote:
> The symbol account_system_vtime is used by the kvm module but
> not exported.  This breaks building with CONFIG_VIRT_CPU_ACCOUNTING
> and CONFIG_KVM=m.
> 
> Signed-off-by: Doug Chapman <doug.chapman@hp.com>
> 
> ---
> diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
> index 8c73643..aad1b7b 100644
> --- a/arch/ia64/kernel/time.c
> +++ b/arch/ia64/kernel/time.c
> @@ -117,6 +117,7 @@ void account_system_vtime(struct task_struct *tsk)
>  
>  	local_irq_restore(flags);
>  }
> +EXPORT_SYMBOL_GPL(account_system_vtime);
>  
>  /*
>   * Called from the timer interrupt handler to charge accumulated user time
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
