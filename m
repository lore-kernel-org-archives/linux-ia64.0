From: Valentin Schneider <vschneid@redhat.com>
Date: Tue, 07 Mar 2023 14:35:51 +0000
Subject: [PATCH v5 0/7] Generic IPI sending tracepoint
Message-Id: <20230307143558.294354-1-vschneid@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org
Cc: "Paul E. McKenney" <paulmck@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Guo Ren <guoren@kernel.org>, "David S. Miller" <davem@davemloft.net>

Background
=====

Detecting IPI *reception* is relatively easy, e.g. using
trace_irq_handler_{entry,exit} or even just function-trace
flush_smp_call_function_queue() for SMP calls.  

Figuring out their *origin*, is trickier as there is no generic tracepoint tied
to e.g. smp_call_function():

o AFAIA x86 has no tracepoint tied to sending IPIs, only receiving them
  (cf. trace_call_function{_single}_entry()).
o arm/arm64 do have trace_ipi_raise(), which gives us the target cpus but also a
  mostly useless string (smp_calls will all be "Function call interrupts").
o Other architectures don't seem to have any IPI-sending related tracepoint.  

I believe one reason those tracepoints used by arm/arm64 ended up as they were
is because these archs used to handle IPIs differently from regular interrupts
(the IRQ driver would directly invoke an IPI-handling routine), which meant they 
never showed up in trace_irq_handler_{entry, exit}. The trace_ipi_{entry,exit}
tracepoints gave a way to trace IPI reception but those have become redundant as
of: 

      56afcd3dbd19 ("ARM: Allow IPIs to be handled as normal interrupts")
      d3afc7f12987 ("arm64: Allow IPIs to be handled as normal interrupts")

which gave IPIs a "proper" handler function used through
generic_handle_domain_irq(), which makes them show up via
trace_irq_handler_{entry, exit}.

Changing stuff up
========
Per the above, it would make sense to reshuffle trace_ipi_raise() and move it
into generic code. This also came up during Daniel's talk on Osnoise at the CPU
isolation MC of LPC 2022 [1]. 

Now, to be useful, such a tracepoint needs to export:
o targeted CPU(s)
o calling context

The only way to get the calling context with trace_ipi_raise() is to trigger a
stack dump, e.g. $(trace-cmd -e ipi* -T echo 42).

This is instead introducing a new tracepoint which exports the relevant context
(callsite, and requested callback for when the callsite isn't helpful), and is
usable by all architectures as it sits in generic code. 

Another thing worth mentioning is that depending on the callsite, the _RET_IP_
fed to the tracepoint is not always useful - generic_exec_single() doesn't tell
you much about the actual callback being sent via IPI, which is why the new
tracepoint also has a @callback argument.

Patches
===
o Patches 1-5 spread out the tracepoint across relevant sites.
  Patch 5 ends up sprinkling lots of #include <trace/events/ipi.h> which I'm not
  the biggest fan of, but is the least horrible solution I've been able to come
  up with so far.
  
o Patch 7 is trying to be smart about tracing the callback associated with the
  IPI.

This results in having IPI trace events for:

o smp_call_function*()
o smp_send_reschedule()
o irq_work_queue*()
o standalone uses of __smp_call_single_queue()

This is incomplete, just looking at arm64 there's more IPI types that aren't
covered: 

  IPI_CPU_STOP,
  IPI_CPU_CRASH_STOP,
  IPI_TIMER,
  IPI_WAKEUP,

but apart from IPI_TIMER (cf. tick_broadcast()), those IPIs are both unfrequent
and accompanied with identifiable interference (stopper or cpuhp threads being
scheduled). I've added a point in my todolist to handle those in a later series
for the sake of completeness, but IMO this is ready to use.

Results
===
Using a recent enough libtraceevent (1.7.0 and above):

  $ trace-cmd record -e 'ipi:*' hackbench
  $ trace-cmd report
	 hackbench-159   [002]   136.973122: ipi_send_cpumask:     cpumask=0 callsite=generic_exec_single+0x33 callback=nohz_csd_func+0x0
	 hackbench-159   [002]   136.977945: ipi_send_cpumask:     cpumask=0 callsite=generic_exec_single+0x33 callback=nohz_csd_func+0x0
	 hackbench-159   [002]   136.984576: ipi_send_cpumask:     cpumask=3 callsite=check_preempt_curr+0x37 callback=0x0
	 hackbench-159   [002]   136.985996: ipi_send_cpumask:     cpumask=0 callsite=generic_exec_single+0x33 callback=nohz_csd_func+0x0
	 [...]

Links
==
[1]: https://youtu.be/5gT57y4OzBM?t234

Revisions
====
v4: https://lore.kernel.org/lkml/20230119143619.2733236-1-vschneid@redhat.com/
v3: https://lore.kernel.org/lkml/20221202155817.2102944-1-vschneid@redhat.com/
v2: https://lore.kernel.org/lkml/20221102182949.3119584-1-vschneid@redhat.com/
v1: https://lore.kernel.org/lkml/20221007154145.1877054-1-vschneid@redhat.com/

v5 -> v4
++++++++

o Rebased against 6.3-rc1

v3 -> v4
++++++++

o Rebased against 6.2-rc4
  Re-ran my coccinelle scripts for the treewide change; only loongarch needed
  changes
o Dropped cpumask trace event field patch (now in 6.2-rc1)
o Applied RB and Ack tags
  Ingo, I wasn't sure if you meant to Ack the whole series or just the patch you
  replied to, so since I didn't want to unlawfully forge any tag I only added
  the one.
o Did a small pass on comments and changelogs

v2 -> v3
++++++++

o Dropped the generic export of smp_send_reschedule(), turned it into a macro
  and a bunch of imports
o Dropped the send_call_function_single_ipi() macro madness, split it into sched
  and smp bits using some of Peter's suggestions

v1 -> v2
++++++++

o Ditched single-CPU tracepoint
o Changed tracepoint signature to include callback
o Changed tracepoint callsite field to void *; the parameter is still UL to save
  up on casts due to using _RET_IP_.
o Fixed linking failures due to not exporting smp_send_reschedule()

Valentin Schneider (7):
  trace: Add trace_ipi_send_cpumask()
  sched, smp: Trace IPIs sent via send_call_function_single_ipi()
  smp: Trace IPIs sent via arch_send_call_function_ipi_mask()
  irq_work: Trace self-IPIs sent via arch_irq_work_raise()
  treewide: Trace IPIs sent via smp_send_reschedule()
  smp: reword smp call IPI comment
  sched, smp: Trace smp callback causing an IPI

 arch/alpha/kernel/smp.c                  |  2 +-
 arch/arc/kernel/smp.c                    |  2 +-
 arch/arm/kernel/smp.c                    |  5 +-
 arch/arm/mach-actions/platsmp.c          |  2 +
 arch/arm64/kernel/smp.c                  |  3 +-
 arch/csky/kernel/smp.c                   |  2 +-
 arch/hexagon/kernel/smp.c                |  2 +-
 arch/ia64/kernel/smp.c                   |  4 +-
 arch/loongarch/kernel/smp.c              |  4 +-
 arch/mips/include/asm/smp.h              |  2 +-
 arch/mips/kernel/rtlx-cmp.c              |  2 +
 arch/openrisc/kernel/smp.c               |  2 +-
 arch/parisc/kernel/smp.c                 |  4 +-
 arch/powerpc/kernel/smp.c                |  6 +-
 arch/powerpc/kvm/book3s_hv.c             |  3 +
 arch/powerpc/platforms/powernv/subcore.c |  2 +
 arch/riscv/kernel/smp.c                  |  4 +-
 arch/s390/kernel/smp.c                   |  2 +-
 arch/sh/kernel/smp.c                     |  2 +-
 arch/sparc/kernel/smp_32.c               |  2 +-
 arch/sparc/kernel/smp_64.c               |  2 +-
 arch/x86/include/asm/smp.h               |  2 +-
 arch/x86/kvm/svm/svm.c                   |  4 ++
 arch/x86/kvm/x86.c                       |  2 +
 arch/xtensa/kernel/smp.c                 |  2 +-
 include/linux/smp.h                      | 11 +++-
 include/trace/events/ipi.h               | 22 +++++++
 kernel/irq_work.c                        | 14 ++++-
 kernel/sched/core.c                      | 19 ++++--
 kernel/sched/smp.h                       |  2 +-
 kernel/smp.c                             | 78 +++++++++++++++++++-----
 virt/kvm/kvm_main.c                      |  2 +
 32 files changed, 164 insertions(+), 53 deletions(-)

--
2.31.1
