From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 29 Jul 2021 14:05:56 +0000
Subject: [PATCH -tip v10 00/16] kprobes: Fix stacktrace with kretprobes on x86
Message-Id: <162756755600.301564.4957591913842010341.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

Hello,

This is the 10th version of the series to fix the stacktrace with kretprobe on x86.

The previous version is here;

 https://lore.kernel.org/bpf/162601048053.1318837.1550594515476777588.stgit@devnote2/

This version is rebased on top of new kprobes cleanup series(*1) and merging
Josh's objtool update series (*2)(*3) as [6/16] and [7/16].

(*1) https://lore.kernel.org/bpf/162748615977.59465.13262421617578791515.stgit@devnote2/
(*2) https://lore.kernel.org/bpf/20210710192433.x5cgjsq2ksvaqnss@treble/
(*3) https://lore.kernel.org/bpf/20210710192514.ghvksi3ozhez4lvb@treble/

Changes from v9:
 - Add Josh's objtool update patches with a build error fix as [6/16] and [7/16].
 - Add a API document for kretprobe_find_ret_addr() and check cur != NULL in [5/16].

With this series, unwinder can unwind stack correctly from ftrace as below;

  # cd /sys/kernel/debug/tracing
  # echo > trace
  # echo 1 > options/sym-offset
  # echo r vfs_read >> kprobe_events
  # echo r full_proxy_read >> kprobe_events
  # echo traceoff:1 > events/kprobes/r_vfs_read_0/trigger
  # echo stacktrace:1 > events/kprobes/r_full_proxy_read_0/trigger
  # echo 1 > events/kprobes/enable
  # cat /sys/kernel/debug/kprobes/list
ffffffff8133b740  r  full_proxy_read+0x0    [FTRACE]
ffffffff812560b0  r  vfs_read+0x0    [FTRACE]
  # echo 0 > events/kprobes/enable
  # cat trace
# tracer: nop
#
# entries-in-buffer/entries-written: 3/3   #P:8
#
#                                _-----=> irqs-off
#                               / _----=> need-resched
#                              | / _---=> hardirq/softirq
#                              || / _--=> preempt-depth
#                              ||| /     delay
#           TASK-PID     CPU#  ||||   TIMESTAMP  FUNCTION
#              | |         |   ||||      |         |
           <...>-134     [007] ...1    16.185877: r_full_proxy_read_0: (vfs_read+0x98/0x180 <- full_proxy_read)
           <...>-134     [007] ...1    16.185901: <stack trace>
 => kretprobe_trace_func+0x209/0x300
 => kretprobe_dispatcher+0x4a/0x70
 => __kretprobe_trampoline_handler+0xd4/0x170
 => trampoline_handler+0x43/0x60
 => kretprobe_trampoline+0x2a/0x50
 => vfs_read+0x98/0x180
 => ksys_read+0x5f/0xe0
 => do_syscall_64+0x37/0x90
 => entry_SYSCALL_64_after_hwframe+0x44/0xae
           <...>-134     [007] ...1    16.185902: r_vfs_read_0: (ksys_read+0x5f/0xe0 <- vfs_read)

This shows the double return probes (vfs_read() and full_proxy_read()) on the stack
correctly unwinded. (vfs_read() returns to 'ksys_read+0x5f' and full_proxy_read()
returns to 'vfs_read+0x98')

This also changes the kretprobe behavisor a bit, now the instraction pointer in
the 'pt_regs' passed to kretprobe user handler is correctly set the real return
address. So user handlers can get it via instruction_pointer() API, and can use
stack_trace_save_regs().

You can also get this series from 
 git://git.kernel.org/pub/scm/linux/kernel/git/mhiramat/linux.git kprobes/kretprobe-stackfix-v9


Thank you,

---

Josh Poimboeuf (3):
      objtool: Add frame-pointer-specific function ignore
      objtool: Ignore unwind hints for ignored functions
      x86/kprobes: Add UNWIND_HINT_FUNC on kretprobe_trampoline()

Masami Hiramatsu (13):
      ia64: kprobes: Fix to pass correct trampoline address to the handler
      kprobes: treewide: Replace arch_deref_entry_point() with dereference_symbol_descriptor()
      kprobes: treewide: Remove trampoline_address from kretprobe_trampoline_handler()
      kprobes: treewide: Make it harder to refer kretprobe_trampoline directly
      kprobes: Add kretprobe_find_ret_addr() for searching return address
      ARC: Add instruction_pointer_set() API
      ia64: Add instruction_pointer_set() API
      arm: kprobes: Make space for instruction pointer on stack
      kprobes: Enable stacktrace from pt_regs in kretprobe handler
      x86/kprobes: Push a fake return address at kretprobe_trampoline
      x86/unwind: Recover kretprobe trampoline entry
      tracing: Show kretprobe unknown indicator only for kretprobe_trampoline
      x86/kprobes: Fixup return address in generic trampoline handler


 arch/arc/include/asm/kprobes.h                |    2 
 arch/arc/include/asm/ptrace.h                 |    5 +
 arch/arc/kernel/kprobes.c                     |   13 +-
 arch/arm/probes/kprobes/core.c                |   11 +-
 arch/arm64/include/asm/kprobes.h              |    2 
 arch/arm64/kernel/probes/kprobes.c            |    5 -
 arch/arm64/kernel/probes/kprobes_trampoline.S |    4 -
 arch/csky/include/asm/kprobes.h               |    2 
 arch/csky/kernel/probes/kprobes.c             |    4 -
 arch/csky/kernel/probes/kprobes_trampoline.S  |    4 -
 arch/ia64/include/asm/ptrace.h                |    5 +
 arch/ia64/kernel/kprobes.c                    |   15 +--
 arch/mips/kernel/kprobes.c                    |   15 +--
 arch/parisc/kernel/kprobes.c                  |    6 +
 arch/powerpc/include/asm/kprobes.h            |    2 
 arch/powerpc/kernel/kprobes.c                 |   29 ++---
 arch/powerpc/kernel/optprobes.c               |    2 
 arch/powerpc/kernel/stacktrace.c              |    2 
 arch/riscv/include/asm/kprobes.h              |    2 
 arch/riscv/kernel/probes/kprobes.c            |    4 -
 arch/riscv/kernel/probes/kprobes_trampoline.S |    4 -
 arch/s390/include/asm/kprobes.h               |    2 
 arch/s390/kernel/kprobes.c                    |   12 +-
 arch/s390/kernel/stacktrace.c                 |    2 
 arch/sh/include/asm/kprobes.h                 |    2 
 arch/sh/kernel/kprobes.c                      |   12 +-
 arch/sparc/include/asm/kprobes.h              |    2 
 arch/sparc/kernel/kprobes.c                   |   12 +-
 arch/x86/include/asm/kprobes.h                |    1 
 arch/x86/include/asm/unwind.h                 |   23 ++++
 arch/x86/include/asm/unwind_hints.h           |    5 +
 arch/x86/kernel/kprobes/core.c                |   71 ++++++++++---
 arch/x86/kernel/unwind_frame.c                |    3 -
 arch/x86/kernel/unwind_guess.c                |    3 -
 arch/x86/kernel/unwind_orc.c                  |   21 +++-
 include/linux/kprobes.h                       |   44 +++++++-
 include/linux/objtool.h                       |   12 ++
 kernel/kprobes.c                              |  133 +++++++++++++++++++------
 kernel/trace/trace_output.c                   |   17 +--
 lib/error-inject.c                            |    3 -
 tools/include/linux/objtool.h                 |   12 ++
 tools/objtool/check.c                         |    2 
 42 files changed, 360 insertions(+), 172 deletions(-)

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
