From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 09 Dec 2003 01:57:04 +0000
Subject: Re: q-tools OOPS: Fixed perfmon.
Message-Id: <marc-linux-ia64-107093546208043@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092926502909@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092926502909@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter,

Yes, clearly you do not want to preempt in the perfmon interrupt handler.
I think we need to also make sure we do not preempt during the perfmonctl()
system call, at least until we verify that there is no assumptions in there.
Similarly in all the VFS entry points, such as pfm_close(). I will try
and see what I can do before the end of the week.

Thanks for your patch.

On Tue, Dec 09, 2003 at 11:17:56AM +1100, Peter Chubb wrote:
> >>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:
> 
> Stephane> I don't think that perfmon-2 support CONFIG_PREEMPT. Try
> Stephane> without it.
> 
> Here's a  fix for non-preemption safety in perfmon.c.
> 
> I haven't tried it while running a preemption stress test, but this
> allows q-syscollect to work.
> 
> === arch/ia64/kernel/perfmon.c 1.67 vs edited ==> --- 1.67/arch/ia64/kernel/perfmon.c   Tue Oct 28 17:36:50 2003
> +++ edited/arch/ia64/kernel/perfmon.c Tue Dec  9 10:55:58 2003
> @@ -5475,7 +5475,7 @@
> 	int this_cpu;
> 	int ret;
>  
> -	this_cpu = smp_processor_id();
> +	this_cpu = get_cpu();
> 	min      = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_min;
> 	max      = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_max;
>  
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

-Stephane
