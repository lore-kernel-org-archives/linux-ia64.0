From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 16 Apr 2003 16:36:23 +0000
Subject: Re: [Linux-ia64] ia64_mca_rendez_int_handler use of hard_smp_processor_id
Message-Id: <marc-linux-ia64-105590723705512@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705289@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705289@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I applied this for 2.4.

On Tuesday 25 March 2003 2:15 pm, Keith Owens wrote:
> Index: 20.5/arch/ia64/kernel/mca.c
> --- 20.5/arch/ia64/kernel/mca.c Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
> +++ 20.5(w)/arch/ia64/kernel/mca.c Wed, 26 Mar 2003 08:14:29 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
> @@ -640,13 +640,10 @@ ia64_mca_wakeup_all(void)
>  void
>  ia64_mca_rendez_int_handler(int rendez_irq, void *arg, struct pt_regs *ptregs)
>  {
> -	int flags, cpu = 0;
> +	int flags, cpu = smp_processor_id();
>  	/* Mask all interrupts */
>  	save_and_cli(flags);
>  
> -#ifdef CONFIG_SMP
> -	cpu = cpu_logical_id(hard_smp_processor_id());
> -#endif
>  	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE;
>  	/* Register with the SAL monarch that the slave has
>  	 * reached SAL


