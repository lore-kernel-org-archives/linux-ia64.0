From: Jack Steiner <steiner@sgi.com>
Date: Tue, 12 Sep 2006 17:13:51 +0000
Subject: Re: IA64 kexec/kdump 2.6.18-rc5 patch
Message-Id: <20060912171351.GA2870@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156837594.2598.15.camel@linux-znh>
In-Reply-To: <1156837594.2598.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hi,
> 	Below is the IA64 kexec/kdump patch against 2.6.18-rc5.
> 
...
> 3. put AP to a loop of hint.pause instead of call pal_halt_light.
> diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/smp.c linux-2.6.18-rc5-kdump/arch/ia64/kernel/smp.c
> --- linux-2.6.18-rc5/arch/ia64/kernel/smp.c	2006-06-18 09:49:35.000000000 +0800
> +++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/smp.c	2006-08-30 10:36:01.000000000 +0800
...
> +void
> +kexec_stop_this_cpu (void *func)
> +{
> +	unsigned long pta, impl_va_bits, pal_base;
> +
> +	/*
> +	 * Remove this CPU by putting it into fake SAL rendezvous
> +	 */
> +	cpu_clear(smp_processor_id(), cpu_online_map);
> +	max_xtp();
> +	ia64_eoi();
> +
> +	/* Disable VHPT */
> +	impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
> +	pta = POW2(61) - POW2(vmlpt_bits);
> +	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
> +
> +	local_irq_disable();
> +	pal_base = __get_cpu_var(ia64_mca_pal_base);
> +	kexec_fake_sal_rendez(func, ap_wakeup_vector, pal_base);
> +}
> +#endif

What was the reason for introducing the kexec_fake_sal_rendez() function instead of
actually returning to the real SAL slave loop. The HOTPLUG_CPU code in play_dead()
in arch/ia64/kernel/process.c is very similar to what is needed.


I'm sure the problem is platform specific, but on the SN platform, the other cpus must be
sent back to the real SAL slave loops. Otherwise, targeting of IO interrupts
will not work correctly in the new kexec'd kernel. 

IO interrupts are distributed across cpus that are not in the SAL slave loop. If 
cpus are idled in the OS instead of SAL, interrrupts are incorrected targeted
to cpus that cannot respond.



-- jack
