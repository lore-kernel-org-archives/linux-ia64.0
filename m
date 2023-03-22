From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 22 Mar 2023 17:22:42 +0000
Subject: Re: [PATCH v5 7/7] sched, smp: Trace smp callback causing an IPI
Message-Id: <20230322172242.GH2357380@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230307143558.294354-1-vschneid@redhat.com>
 <20230307143558.294354-8-vschneid@redhat.com>
 <20230322095329.GS2017917@hirez.programming.kicks-ass.net>
 <xhsmhmt45c703.mognet@vschneid.remote.csb>
 <20230322140434.GC2357380@hirez.programming.kicks-ass.net>
 <xhsmhjzz8d8km.mognet@vschneid.remote.csb>
In-Reply-To: <xhsmhjzz8d8km.mognet@vschneid.remote.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <vschneid@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, "Paul E. McKenney" <paulmck@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Guo Ren <guoren@kernel.org>, "David S. Miller" <davem@davemloft.net>

On Wed, Mar 22, 2023 at 05:01:13PM +0000, Valentin Schneider wrote:

> > So I was thinking something like this:

> Hm, this does get rid of the func being passed down the helpers, but this
> means the trace events are now stateful, i.e. I need the first and last
> events in a CSD stack to figure out which one actually caused the IPI.

Isn't much of tracing stateful? I mean, why am I always writing awk
programs to parse trace output?

The one that is directly followed by
generic_smp_call_function_single_interrupt() (horrible name that), is
the one that tripped the IPI.

> It also requires whoever is looking at the trace to be aware of which IPIs
> are attached to a CSD, and which ones aren't. ATM that's only the resched
> IPI, but per the cover letter there's more to come (e.g. tick_broadcast()
> for arm64/riscv and a few others). For instance:
> 
>        hackbench-157   [001]    10.894320: ipi_send_cpu:         cpu=3 callsite=check_preempt_curr+0x37 callback=0x0

Arguably we should be setting callback to scheduler_ipi(), except
ofcourse, that's not an actual function...

Maybe we can do "extern inline" for the actual users and provide a dummy
function for the symbol when tracing.

>        hackbench-157   [001]    10.895068: ipi_send_cpu:         cpu=3 callsite=try_to_wake_up+0x29e callback=sched_ttwu_pending+0x0
>        hackbench-157   [001]    10.895068: ipi_send_cpu:         cpu=3 callsite=try_to_wake_up+0x29e callback=generic_smp_call_function_single_interrupt+0x0
> 
> That first one sent a RESCHEDULE IPI, the second one a CALL_FUNCTION one,
> but you really have to know what you're looking at...

But you have to know that anyway, you can't do tracing and not know wtf
you're doing. Or rather, if you do, I don't give a crap and you can keep
the pieces :-)

Grepping the callback should be pretty quick resolution at to what trips
it, no?

(also, if you *realllllly* can't manage, we can always add yet another
argument that gives a type thingy)

> Are you worried about the @func being pushed down?

Not really, I was finding it odd that only the first csd was being
logged. Either you should log them all (after all, the target CPU will
run them all and you might still wonder where the heck they came from)
or it should log none and always report that hideous long function name
I can't be arsed to type again :-)

> Staring at x86 asm is not good for the soul,

Scarred for life :-) What's worse, due to being exposed to Intel syntax
at a young age, I'm now permantently confused as to the argument order
of x86 asm.
