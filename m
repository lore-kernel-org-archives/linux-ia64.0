From: Valentin Schneider <vschneid@redhat.com>
Date: Mon, 09 Jan 2023 19:02:08 +0000
Subject: Re: [PATCH v3 3/8] sched, smp: Trace IPIs sent via send_call_function_single_ipi()
Message-Id: <xhsmh4jszedlb.mognet@vschneid.remote.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221202155817.2102944-1-vschneid@redhat.com>
 <20221202155817.2102944-4-vschneid@redhat.com>
 <Y7lRz7oCaAmAhoqS@gmail.com>
In-Reply-To: <Y7lRz7oCaAmAhoqS@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Guo Ren <guoren@kernel.org>, "David S. Miller" <davem@davemloft.net>

On 07/01/23 12:04, Ingo Molnar wrote:
> * Valentin Schneider <vschneid@redhat.com> wrote:
>
>> send_call_function_single_ipi() is the thing that sends IPIs at the bottom
>> of smp_call_function*() via either generic_exec_single() or
>> smp_call_function_many_cond(). Give it an IPI-related tracepoint.
>> 
>> Note that this ends up tracing any IPI sent via __smp_call_single_queue(),
>> which covers __ttwu_queue_wakelist() and irq_work_queue_on() "for free".
>> 
>> Signed-off-by: Valentin Schneider <vschneid@redhat.com>
>> Reviewed-by: Steven Rostedt (Google) <rostedt@goodmis.org>
>
> Acked-by: Ingo Molnar <mingo@kernel.org>
>
> Patch series logistics:
>
>  - No objections from the scheduler side, this feature looks pretty useful.
>

Thanks!

>  - Certain patches are incomplete, others are noted as being merged 
>    separately, so I presume you'll send an updated/completed series 
>    eventually?
>

The first patch from Steve is now in, so can drop it.

The other patches are complete, though I need to rebase them and regenerate
the treewide patch to catch any changes that came with 6.2. I'll do that
this week.

The "incompleteness" pointed out in the cover letter is about the types of
IPIs that can be traced. This series covers the ones that end up invoking
some core code (coincidentally those are the most common ones), others such
as e.g. tick_broadcast() for arm, arm64, riscv and hexagon remain
unaffected.

I'm not that much interested in these (other than maybe the tick broadcast
one they are all fairly unfrequent), but I'm happy to have a shot at them
for the sake of completeness - either in that series or in a followup, up
to you.  

>  - We can merge this via the scheduler tree I suspect, as most callbacks 
>    affected relate to tip:sched/core and tmp:smp/core - but if you have 
>    some other preferred tree that's fine too.
>

Either sound good to me.

> Thanks,
>
> 	Ingo
