From: Marcelo Tosatti <mtosatti@redhat.com>
Date: Fri, 07 Oct 2022 19:58:19 +0000
Subject: Re: [RFC PATCH 0/5] Generic IPI sending tracepoint
Message-Id: <Y0CFnWDpMNGajIRD@fuller.cnet>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221007154145.1877054-1-vschneid@redhat.com>
In-Reply-To: <20221007154145.1877054-1-vschneid@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <vschneid@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, "Paul E. McKenney" <paulmck@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Guo Ren <guoren@kernel.org>, "David S. Miller" <davem@davemloft.net>

Hi Valentin,

On Fri, Oct 07, 2022 at 04:41:40PM +0100, Valentin Schneider wrote:
> Background
> =====
> 
> Detecting IPI *reception* is relatively easy, e.g. using
> trace_irq_handler_{entry,exit} or even just function-trace
> flush_smp_call_function_queue() for SMP calls.  
> 
> Figuring out their *origin*, is trickier as there is no generic tracepoint tied
> to e.g. smp_call_function():
> 
> o AFAIA x86 has no tracepoint tied to sending IPIs, only receiving them
>   (cf. trace_call_function{_single}_entry()).
> o arm/arm64 do have trace_ipi_raise(), which gives us the target cpus but also a
>   mostly useless string (smp_calls will all be "Function call interrupts").
> o Other architectures don't seem to have any IPI-sending related tracepoint.  
> 
> I believe one reason those tracepoints used by arm/arm64 ended up as they were
> is because these archs used to handle IPIs differently from regular interrupts
> (the IRQ driver would directly invoke an IPI-handling routine), which meant they 
> never showed up in trace_irq_handler_{entry, exit}. The trace_ipi_{entry,exit}
> tracepoints gave a way to trace IPI reception but those have become redundant as
> of: 
> 
>       56afcd3dbd19 ("ARM: Allow IPIs to be handled as normal interrupts")
>       d3afc7f12987 ("arm64: Allow IPIs to be handled as normal interrupts")
> 
> which gave IPIs a "proper" handler function used through
> generic_handle_domain_irq(), which makes them show up via
> trace_irq_handler_{entry, exit}.
> 
> Changing stuff up
> ========> 
> Per the above, it would make sense to reshuffle trace_ipi_raise() and move it
> into generic code. This also came up during Daniel's talk on Osnoise at the CPU
> isolation MC of LPC 2022 [1]. 
> 
> Now, to be useful, such a tracepoint needs to export:
> o targeted CPU(s)
> o calling context
> 
> The only way to get the calling context with trace_ipi_raise() is to trigger a
> stack dump, e.g. $(trace-cmd -e ipi* -T echo 42).
> 
> As for the targeted CPUs, the existing tracepoint does export them, albeit in
> cpumask form, which is quite inconvenient from a tooling perspective. For
> instance, as far as I'm aware, it's not possible to do event filtering on a
> cpumask via trace-cmd.

https://man7.org/linux/man-pages/man1/trace-cmd-set.1.html

       -f filter
           Specify a filter for the previous event. This must come after
           a -e. This will filter what events get recorded based on the
           content of the event. Filtering is passed to the kernel
           directly so what filtering is allowed may depend on what
           version of the kernel you have. Basically, it will let you
           use C notation to check if an event should be processed or
           not.

               =, >=, <=, >, <, &, |, && and ||

           The above are usually safe to use to compare fields.

This looks overkill to me (consider large number of bits set in mask).

+#define trace_ipi_send_cpumask(callsite, mask) do {            \
+	if (static_key_false(&__tracepoint_ipi_send_cpu.key)) { \
+               int cpu;                                        \
+               for_each_cpu(cpu, mask)                         \
+                       trace_ipi_send_cpu(callsite, cpu);	\
+	}                                                       \
+} while (0)


> 
> Because of the above points, this is introducing a new tracepoint.
> 
> Patches
> ===> 
> This results in having trace events for:
> 
> o smp_call_function*()
> o smp_send_reschedule()
> o irq_work_queue*()
> 
> This is incomplete, just looking at arm64 there's more IPI types that aren't covered:
> 
>   IPI_CPU_STOP,
>   IPI_CPU_CRASH_STOP,
>   IPI_TIMER,
>   IPI_WAKEUP,
> 
> ... But it feels like a good starting point.

Can't you have a single tracepoint (or variant with cpumask) that would
cover such cases as well?

Maybe (as parameters for tracepoint):

	* type (reschedule, smp_call_function, timer, wakeup, ...).

	* function address: valid for smp_call_function, irq_work_queue
	  types.

> Another thing worth mentioning is that depending on the callsite, the _RET_IP_
> fed to the tracepoint is not always useful - generic_exec_single() doesn't tell
> you much about the actual callback being sent via IPI, so there might be value
> in exploding the single tracepoint into at least one variant for smp_calls.

Not sure i grasp what you mean by "exploding the single tracepoint...",
but yes knowing the function or irq work function is very useful.

> 
> Links
> ==> 
> [1]: https://youtu.be/5gT57y4OzBM?t234
> 
> Valentin Schneider (5):
>   trace: Add trace_ipi_send_{cpu, cpumask}
>   sched, smp: Trace send_call_function_single_ipi()
>   smp: Add a multi-CPU variant to send_call_function_single_ipi()
>   irq_work: Trace calls to arch_irq_work_raise()
>   treewide: Rename and trace arch-definitions of smp_send_reschedule()
> 
>  arch/alpha/kernel/smp.c          |  2 +-
>  arch/arc/kernel/smp.c            |  2 +-
>  arch/arm/kernel/smp.c            |  5 +----
>  arch/arm64/kernel/smp.c          |  3 +--
>  arch/csky/kernel/smp.c           |  2 +-
>  arch/hexagon/kernel/smp.c        |  2 +-
>  arch/ia64/kernel/smp.c           |  4 ++--
>  arch/loongarch/include/asm/smp.h |  2 +-
>  arch/mips/include/asm/smp.h      |  2 +-
>  arch/openrisc/kernel/smp.c       |  2 +-
>  arch/parisc/kernel/smp.c         |  4 ++--
>  arch/powerpc/kernel/smp.c        |  4 ++--
>  arch/riscv/kernel/smp.c          |  4 ++--
>  arch/s390/kernel/smp.c           |  2 +-
>  arch/sh/kernel/smp.c             |  2 +-
>  arch/sparc/kernel/smp_32.c       |  2 +-
>  arch/sparc/kernel/smp_64.c       |  2 +-
>  arch/x86/include/asm/smp.h       |  2 +-
>  arch/xtensa/kernel/smp.c         |  2 +-
>  include/linux/smp.h              |  1 +
>  include/trace/events/ipi.h       | 27 +++++++++++++++++++++++++++
>  kernel/irq_work.c                | 12 +++++++++++-
>  kernel/sched/core.c              |  7 +++++--
>  kernel/smp.c                     | 18 +++++++++++++++++-
>  24 files changed, 84 insertions(+), 31 deletions(-)
> 
> --
> 2.31.1
> 
> 
