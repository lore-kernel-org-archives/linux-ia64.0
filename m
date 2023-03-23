From: Valentin Schneider <vschneid@redhat.com>
Date: Thu, 23 Mar 2023 18:31:37 +0000
Subject: Re: [PATCH v5 7/7] sched, smp: Trace smp callback causing an IPI
Message-Id: <xhsmh8rfncoae.mognet@vschneid.remote.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230307143558.294354-1-vschneid@redhat.com>
 <20230307143558.294354-8-vschneid@redhat.com>
 <20230322095329.GS2017917@hirez.programming.kicks-ass.net>
 <xhsmhmt45c703.mognet@vschneid.remote.csb>
 <20230322140434.GC2357380@hirez.programming.kicks-ass.net>
 <xhsmhbkkjcu4q.mognet@vschneid.remote.csb>
 <20230323174129.GA2753619@hirez.programming.kicks-ass.net>
In-Reply-To: <20230323174129.GA2753619@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, "Paul E. McKenney" <paulmck@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Guo Ren <guoren@kernel.org>, "David S. Miller" <davem@davemloft.net>

On 23/03/23 18:41, Peter Zijlstra wrote:
> On Thu, Mar 23, 2023 at 04:25:25PM +0000, Valentin Schneider wrote:
>> On 22/03/23 15:04, Peter Zijlstra wrote:
>> > @@ -798,14 +794,20 @@ static void smp_call_function_many_cond(
>> >  		}
>> >  
>> >  		/*
>> > +		 * Trace each smp_function_call_*() as an IPI, actual IPIs
>> > +		 * will be traced with func=generic_smp_call_function_single_ipi().
>> > +		 */
>> > +		trace_ipi_send_cpumask(cfd->cpumask_ipi, _RET_IP_, func);
>> 
>> I just got a trace pointing out this can emit an event even though no IPI
>> is sent if e.g. the cond_func predicate filters all CPUs in the argument
>> mask:
>> 
>>   ipi_send_cpumask:     cpumask= callsite=on_each_cpu_cond_mask+0x3c callback=flush_tlb_func+0x0
>> 
>> Maybe something like so on top?
>> 
>> ---
>> diff --git a/kernel/smp.c b/kernel/smp.c
>> index ba5478814e677..1dc452017d000 100644
>> --- a/kernel/smp.c
>> +++ b/kernel/smp.c
>> @@ -791,6 +791,8 @@ static void smp_call_function_many_cond(const struct cpumask *mask,
>>  			}
>>  		}
>>  
>> +		if (!nr_cpus)
>> +			goto local;
>
> Hmm, this isn't right. You can get nr_cpus=0 even though it did add
> some to various lists but never was first.
>

Duh, glanced over that.

> But urgh, even if we were to say count nr_queued we'd never get the mask
> right, because we don't track which CPUs have the predicate matched,
> only those we need to actually send an IPI to :/
>
> Ooh, I think we can clear those bits from cfd->cpumask, arguably that's
> a correctness fix too, because the 'run_remote && wait' case shouldn't
> wait on things we didn't queue.
>

Yeah, that makes sense to me. Just one tiny suggestion below.

> Hmm?
>
>
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -728,9 +728,9 @@ static void smp_call_function_many_cond(
>  	int cpu, last_cpu, this_cpu = smp_processor_id();
>  	struct call_function_data *cfd;
>  	bool wait = scf_flags & SCF_WAIT;
> +	int nr_cpus = 0, nr_queued = 0;
>  	bool run_remote = false;
>  	bool run_local = false;
> -	int nr_cpus = 0;
>  
>  	lockdep_assert_preemption_disabled();
>  
> @@ -772,8 +772,10 @@ static void smp_call_function_many_cond(
>  		for_each_cpu(cpu, cfd->cpumask) {
>  			call_single_data_t *csd = per_cpu_ptr(cfd->csd, cpu);
>  
> -			if (cond_func && !cond_func(cpu, info))
> +			if (cond_func && !cond_func(cpu, info)) {
> +				__cpumask_clear_cpu(cpu, cfd->cpumask);
>  				continue;
> +			}
>  
>  			csd_lock(csd);
>  			if (wait)
> @@ -789,13 +791,15 @@ static void smp_call_function_many_cond(
>  				nr_cpus++;
>  				last_cpu = cpu;
>  			}
> +			nr_queued++;
>  		}
>  
>  		/*
>  		 * Trace each smp_function_call_*() as an IPI, actual IPIs
>  		 * will be traced with func=generic_smp_call_function_single_ipi().
>  		 */
> -		trace_ipi_send_cpumask(cfd->cpumask_ipi, _RET_IP_, func);
> +		if (nr_queued)

With your change to cfd->cpumask, we could ditch nr_queued and make this

                if (!cpumask_empty(cfd->cpumask))

since cfd->cpumask now only contains CPUs that have had a CSD queued.

> +			trace_ipi_send_cpumask(cfd->cpumask, _RET_IP_, func);
>  
>  		/*
>  		 * Choose the most efficient way to send an IPI. Note that the
