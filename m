From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sun, 29 Aug 2021 14:22:14 +0000
Subject: [RFC PATCH 0/1] Non stack-intrusive return probe event
Message-Id: <163024693462.457128.1437820221831758047.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <162756755600.301564.4957591913842010341.stgit@devnote2>
In-Reply-To: <162756755600.301564.4957591913842010341.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

Hello,

For a long time, we tackled to fix some issues around kretprobe.
One of the latest action was the stacktrace fix on x86 in this
thread.

https://lore.kernel.org/bpf/162756755600.301564.4957591913842010341.stgit@devnote2/

However, there seems no progress/further discussion. So I would
like to make another approach for this (and the other issues.)

Here is my idea -- replace kretprobe with kprobe.
In other words, put a kprobe on the "return instruction" directly
instead of modifying the kernel stack. This can solve most
of the kretprobe disadvantges. E.g.

- Since it doesn't change the kernel stack, any special stack
  unwinder fixup is not needed anymore.
- No "max-instance" limitations anymore, because it will use
  kprobes directly.
- Scalability performance will be improved as same as kprobes.
  No list-operation in probe-runtime.

Here is a PoC code which introduces "retinsn_probe" event as a part
of ftrace kprobe event. I don't think we need to replace the
kretprobe. This should be a higher layer feature, because some
kernel functions can have multiple "return instructions". Thus,
the "retinsn_probe" must manage multiple kprobes. That means the
"retinsn_probe" will be a user of kprobes. I decided to make it
inside the ftrace "kprobe-event". This gives us another advantage
for eBPF support. Because eBPF uses "kprobe-event" instead of
"kprobe" directly, if the "retinsn_probe" is implemented in the
"kprobe-event", eBPF can use it without any change.
Anyway, this can be co-exist with kretprobe. So as far as any
user uses kretprobe, we can keep it.


Example
===For example, I ran a shell script, which was used in the
stacktrace fix series.

----
mount -t debugfs debugfs /sys/kernel/debug/
cd /sys/kernel/debug/tracing
echo > trace
echo 1 > options/sym-offset
echo r vfs_read >> kprobe_events
echo r full_proxy_read >> kprobe_events
echo traceoff:1 > events/kprobes/r_vfs_read_0/trigger
echo stacktrace:1 > events/kprobes/r_full_proxy_read_0/trigger
echo 1 > events/kprobes/enable
cat /sys/kernel/debug/kprobes/list
echo 0 > events/kprobes/enable
cat trace
----

This is the result.
----
ffffffff813b420e  k  full_proxy_read+0x6e    
ffffffff812b7c0a  k  vfs_read+0xda  
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
             cat-136     [007] d.Z.     8.038381: r_full_proxy_read_0: (vfs_read+0x9b/0x180 <- full_proxy_read)
             cat-136     [007] d.Z.     8.038386: <stack trace>
 => kretprobe_trace_func+0x209/0x300
 => retinsn_dispatcher+0x7a/0xa0
 => kprobe_post_process+0x28/0x80
 => kprobe_int3_handler+0x166/0x1a0
 => exc_int3+0x47/0x140
 => asm_exc_int3+0x31/0x40
 => vfs_read+0x9b/0x180
 => ksys_read+0x68/0xe0
 => do_syscall_64+0x3b/0x90
 => entry_SYSCALL_64_after_hwframe+0x44/0xae
             cat-136     [007] d.Z.     8.038387: r_vfs_read_0: (ksys_read+0x68/0xe0 <- vfs_read)
----

You can see the return probe events are translated to kprobes
instead of kretprobes. And also, on the stacktrace, we can see
an int3 calls the kprobe and decode stacktrace correctly.


TODO
==
Of course, this is just an PoC code, there are many TODOs.

- This PoC code only supports x86 at this moment. But I think this
  can be done on the other architectures. What it needs is
  to implement "find_return_instructions()".
- Code cleanup is not enough. I have to remove "kretprobe" from
 "trace_kprobe" data structure, rewrite related functions etc.
- It has to handle "tail-call" optimized code, which replaces
  a "call + return" into "jump". find_return_instruction() should
  detect it and decode the jump destination too.


Thank you,


---

Masami Hiramatsu (1):
      [PoC] tracing: kprobe: Add non-stack intrusion return probe event


 arch/x86/kernel/kprobes/core.c |   59 +++++++++++++++++++++
 kernel/trace/trace_kprobe.c    |  110 ++++++++++++++++++++++++++++++++++++++--
 2 files changed, 164 insertions(+), 5 deletions(-)

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
