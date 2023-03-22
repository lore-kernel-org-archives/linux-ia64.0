From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 22 Mar 2023 09:39:55 +0000
Subject: Re: [PATCH v5 1/7] trace: Add trace_ipi_send_cpumask()
Message-Id: <20230322093955.GR2017917@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230307143558.294354-1-vschneid@redhat.com>
 <20230307143558.294354-2-vschneid@redhat.com>
In-Reply-To: <20230307143558.294354-2-vschneid@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <vschneid@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Guo Ren <guoren@kernel.org>, "David S. Miller" <davem@davemloft.net>

On Tue, Mar 07, 2023 at 02:35:52PM +0000, Valentin Schneider wrote:
> trace_ipi_raise() is unsuitable for generically tracing IPI sources due to
> its "reason" argument being an uninformative string (on arm64 all you get
> is "Function call interrupts" for SMP calls).
> 
> Add a variant of it that exports a target cpumask, a callsite and a callback.
> 
> Signed-off-by: Valentin Schneider <vschneid@redhat.com>
> Reviewed-by: Steven Rostedt (Google) <rostedt@goodmis.org>
> ---
>  include/trace/events/ipi.h | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/include/trace/events/ipi.h b/include/trace/events/ipi.h
> index 0be71dad6ec03..b1125dc27682c 100644
> --- a/include/trace/events/ipi.h
> +++ b/include/trace/events/ipi.h
> @@ -35,6 +35,28 @@ TRACE_EVENT(ipi_raise,
>  	TP_printk("target_mask=%s (%s)", __get_bitmask(target_cpus), __entry->reason)
>  );
>  
> +TRACE_EVENT(ipi_send_cpumask,
> +
> +	TP_PROTO(const struct cpumask *cpumask, unsigned long callsite, void *callback),
> +
> +	TP_ARGS(cpumask, callsite, callback),
> +
> +	TP_STRUCT__entry(
> +		__cpumask(cpumask)
> +		__field(void *, callsite)
> +		__field(void *, callback)
> +	),
> +
> +	TP_fast_assign(
> +		__assign_cpumask(cpumask, cpumask_bits(cpumask));
> +		__entry->callsite = (void *)callsite;
> +		__entry->callback = callback;
> +	),
> +
> +	TP_printk("cpumask=%s callsite=%pS callback=%pS",
> +		  __get_cpumask(cpumask), __entry->callsite, __entry->callback)
> +);

Would it make sense to add a variant like: ipi_send_cpu() that records a
single cpu instead of a cpumask. A lot of sites seems to do:
cpumask_of(cpu) for that first argument, and it seems to me it is quite
daft to have to memcpy a full multi-word cpumask in those cases.

Remember, nr_possible_cpus > 64 is quite common these days.
