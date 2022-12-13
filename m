From: Palmer Dabbelt <palmer@dabbelt.com>
Date: Tue, 13 Dec 2022 16:18:13 +0000
Subject: Re: [PATCH v3 0/8] Generic IPI sending tracepoint
Message-Id: <mhng-ed30efdc-5b5b-40fa-8661-f99d4e2991ed@palmer-ri-x1c9>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20221202155817.2102944-1-vschneid@redhat.com>
References: <20221202155817.2102944-1-vschneid@redhat.com>
In-Reply-To: <20221202155817.2102944-1-vschneid@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: vschneid@redhat.com
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, paulmck@kernel.org, rostedt@goodmis.org, peterz@infradead.org, tglx@linutronix.de, bigeasy@linutronix.de, juri.lelli@redhat.com, bristot@redhat.com, mtosatti@redhat.com, frederic@kernel.org, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, Marc Zyngier <maz@kernel.org>, mark.rutland@arm.com, linux@armlinux.org.uk, npiggin@gmail.com, guoren@kernel.org, davem@davemloft.net

On Fri, 02 Dec 2022 07:58:09 PST (-0800), vschneid@redhat.com wrote:
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
> This is instead introducing a new tracepoint which exports the relevant context
> (callsite, and requested callback for when the callsite isn't helpful), and is
> usable by all architectures as it sits in generic code.
>
> Another thing worth mentioning is that depending on the callsite, the _RET_IP_
> fed to the tracepoint is not always useful - generic_exec_single() doesn't tell
> you much about the actual callback being sent via IPI, which is why the new
> tracepoint also has a @callback argument.
>
> Patches
> ===>
> o Patch 1 is included for convenience and will be merged independently. FYI I
>   have libtraceevent patches [2] to improve the
>   pretty-printing of cpumasks using the new type, which look like:
>   <...>-3322  [021]   560.402583: ipi_send_cpumask:     cpumask,17,21 callsite=on_each_cpu_cond_mask+0x40 callback=flush_tlb_func+0x0
>   <...>-187   [010]   562.590584: ipi_send_cpumask:     cpumask=0-23 callsite=on_each_cpu_cond_mask+0x40 callback=do_sync_core+0x0
>
> o Patches 2-6 spread out the tracepoint across relevant sites.
>   Patch 6 ends up sprinkling lots of #include <trace/events/ipi.h> which I'm not
>   the biggest fan of, but is the least horrible solution I've been able to come
>   up with so far.
>
> o Patch 8 is trying to be smart about tracing the callback associated with the
>   IPI.
>
> This results in having IPI trace events for:
>
> o smp_call_function*()
> o smp_send_reschedule()
> o irq_work_queue*()
> o standalone uses of __smp_call_single_queue()
>
> This is incomplete, just looking at arm64 there's more IPI types that aren't
> covered:
>
>   IPI_CPU_STOP,
>   IPI_CPU_CRASH_STOP,
>   IPI_TIMER,
>   IPI_WAKEUP,
>
> ... But it feels like a good starting point.
>
> Links
> ==>
> [1]: https://youtu.be/5gT57y4OzBM?t234
> [2]: https://lore.kernel.org/all/20221116144154.3662923-1-vschneid@redhat.com/
>
> Revisions
> ====>
> v2 -> v3
> ++++++++
>
> o Dropped the generic export of smp_send_reschedule(), turned it into a macro
>   and a bunch of imports
> o Dropped the send_call_function_single_ipi() macro madness, split it into sched
>   and smp bits using some of Peter's suggestions
>
> v1 -> v2
> ++++++++
>
> o Ditched single-CPU tracepoint
> o Changed tracepoint signature to include callback
> o Changed tracepoint callsite field to void *; the parameter is still UL to save
>   up on casts due to using _RET_IP_.
> o Fixed linking failures due to not exporting smp_send_reschedule()
>
> Steven Rostedt (Google) (1):
>   tracing: Add __cpumask to denote a trace event field that is a
>     cpumask_t
>
> Valentin Schneider (7):
>   trace: Add trace_ipi_send_cpumask()
>   sched, smp: Trace IPIs sent via send_call_function_single_ipi()
>   smp: Trace IPIs sent via arch_send_call_function_ipi_mask()
>   irq_work: Trace self-IPIs sent via arch_irq_work_raise()
>   treewide: Trace IPIs sent via smp_send_reschedule()
>   smp: reword smp call IPI comment
>   sched, smp: Trace smp callback causing an IPI
>
>  arch/alpha/kernel/smp.c                      |  2 +-
>  arch/arc/kernel/smp.c                        |  2 +-
>  arch/arm/kernel/smp.c                        |  5 +-
>  arch/arm/mach-actions/platsmp.c              |  2 +
>  arch/arm64/kernel/smp.c                      |  3 +-
>  arch/csky/kernel/smp.c                       |  2 +-
>  arch/hexagon/kernel/smp.c                    |  2 +-
>  arch/ia64/kernel/smp.c                       |  4 +-
>  arch/loongarch/include/asm/smp.h             |  2 +-
>  arch/mips/include/asm/smp.h                  |  2 +-
>  arch/mips/kernel/rtlx-cmp.c                  |  2 +
>  arch/openrisc/kernel/smp.c                   |  2 +-
>  arch/parisc/kernel/smp.c                     |  4 +-
>  arch/powerpc/kernel/smp.c                    |  6 +-
>  arch/powerpc/kvm/book3s_hv.c                 |  3 +
>  arch/powerpc/platforms/powernv/subcore.c     |  2 +
>  arch/riscv/kernel/smp.c                      |  4 +-
>  arch/s390/kernel/smp.c                       |  2 +-
>  arch/sh/kernel/smp.c                         |  2 +-
>  arch/sparc/kernel/smp_32.c                   |  2 +-
>  arch/sparc/kernel/smp_64.c                   |  2 +-
>  arch/x86/include/asm/smp.h                   |  2 +-
>  arch/x86/kvm/svm/svm.c                       |  4 +
>  arch/x86/kvm/x86.c                           |  2 +
>  arch/xtensa/kernel/smp.c                     |  2 +-
>  include/linux/smp.h                          |  8 +-
>  include/trace/bpf_probe.h                    |  6 ++
>  include/trace/events/ipi.h                   | 22 ++++++
>  include/trace/perf.h                         |  6 ++
>  include/trace/stages/stage1_struct_define.h  |  6 ++
>  include/trace/stages/stage2_data_offsets.h   |  6 ++
>  include/trace/stages/stage3_trace_output.h   |  6 ++
>  include/trace/stages/stage4_event_fields.h   |  6 ++
>  include/trace/stages/stage5_get_offsets.h    |  6 ++
>  include/trace/stages/stage6_event_callback.h | 20 +++++
>  include/trace/stages/stage7_class_define.h   |  2 +
>  kernel/irq_work.c                            | 14 +++-
>  kernel/sched/core.c                          | 19 +++--
>  kernel/sched/smp.h                           |  2 +-
>  kernel/smp.c                                 | 78 ++++++++++++++++----
>  samples/trace_events/trace-events-sample.c   |  2 +-
>  samples/trace_events/trace-events-sample.h   | 34 +++++++--
>  virt/kvm/kvm_main.c                          |  1 +
>  43 files changed, 250 insertions(+), 61 deletions(-)

Acked-by: Palmer Dabbelt <palmer@rivosinc.com> # riscv
