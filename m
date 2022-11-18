From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 18 Nov 2022 09:12:43 +0000
Subject: Re: [RFC PATCH v2 8/8] sched, smp: Trace smp callback causing an IPI
Message-Id: <Y3dMiyFn6TG1s5g3@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221102182949.3119584-1-vschneid@redhat.com>
 <20221102183336.3120536-7-vschneid@redhat.com>
 <Y3ZBUMteJysc1/lA@hirez.programming.kicks-ass.net>
 <xhsmhfsehy706.mognet@vschneid.remote.csb>
In-Reply-To: <xhsmhfsehy706.mognet@vschneid.remote.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <vschneid@redhat.com>
Cc: Juri Lelli <juri.lelli@redhat.com>, Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mips@vger.kernel.org, Guo Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, Marc Zyngier <maz@kernel.org>, linux-hexagon@vger.kernel.org, x86@kernel.org, Russell King <linux@armlinux.org.uk>, linux-csky@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, "Paul E. McKenney" <paulmck@kernel.org>, Frederic Weisbecker <frederic@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, Nicholas Piggin <npiggin@gmail.com>, loongarch@lists.linux.dev, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Daniel Bristot de Oliveira <bristot@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Thu, Nov 17, 2022 at 02:45:29PM +0000, Valentin Schneider wrote:

> > +	if (trace_ipi_send_cpumask_enabled()) {
> > +		call_single_data_t *csd;
> > +		smp_call_func_t func;
> > +
> > +		csd = container_of(node, call_single_data_t, node.llist);
> > +
> > +		func = sched_ttwu_pending;
> > +		if (CSD_TYPE(csd) != CSD_TYPE_TTWU)
> > +			func = csd->func;
> > +
> > +		if (raw_smp_call_single_queue(cpu, node))
> > +			trace_ipi_send_cpumask(cpumask_of(cpu), _RET_IP_, func);
> 
> So I went with the tracepoint being placed *before* the actual IPI gets
> sent to have a somewhat sane ordering between trace_ipi_send_cpumask() and
> e.g. trace_call_function_single_entry().
> 
> Packaging the call_single_queue logic makes the code less horrible, but it
> does mix up the event ordering...

Keeps em sharp ;-)

> > +		return;
> > +	}
> > +
> > +	raw_smp_call_single_queue(cpu, node);
> >  }
> >
> >  /*
> > @@ -983,10 +1017,13 @@ static void smp_call_function_many_cond(
> >                * number of CPUs might be zero due to concurrent changes to the
> >                * provided mask.
> >                */
> > -		if (nr_cpus = 1)
> > +		if (nr_cpus = 1) {
> > +			trace_ipi_send_cpumask(cpumask_of(last_cpu), _RET_IP_, func);
> >                       send_call_function_single_ipi(last_cpu);
> 
> This'll yield an IPI event even if no IPI is sent due to the idle task
> polling, no?

Oh, right..
