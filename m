From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 26 Mar 2021 23:49:21 +0000
Subject: Re: [PATCH -tip v5 00/12] kprobes: Fix stacktrace with kretprobes on x86
Message-Id: <20210327084921.89473486c5b73dda94fcb172@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <161676170650.330141.6214727134265514123.stgit@devnote2>
In-Reply-To: <161676170650.330141.6214727134265514123.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Fri, 26 Mar 2021 21:28:26 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> Hello,
> 
> Here is the 5th version of the series to fix the stacktrace with kretprobe
> on x86. After merging this, I'll fix other architectures.
> 
> The previous version is;
> 
> https://lore.kernel.org/bpf/161639518354.895304.15627519393073806809.stgit@devnote2/
> 
> This version fixes a build error from a typo in [1/12] and the
> case of interrupt happens on kretprobe_trampoline+0 in [11/12].
> 
> With this series, unwinder can unwind stack correctly from ftrace as below;
> 
>   # cd /sys/kernel/debug/tracing
>   # echo > trace
>   # echo r vfs_read >> kprobe_events
>   # echo r full_proxy_read >> kprobe_events
>   # echo traceoff:1 > events/kprobes/r_vfs_read_0/trigger
>   # echo stacktrace:1 > events/kprobes/r_full_proxy_read_0/trigger
>   # echo 1 > events/kprobes/enable
>   # echo 1 > options/sym-offset
>   # cat /sys/kernel/debug/kprobes/list
> ffffffff8133b740  r  full_proxy_read+0x0    [FTRACE]
> ffffffff812560b0  r  vfs_read+0x0    [FTRACE]
>   # echo 0 > events/kprobes/enable
>   # cat trace
> # tracer: nop
> #
> # entries-in-buffer/entries-written: 3/3   #P:8
> #
> #                                _-----=> irqs-off
> #                               / _----=> need-resched
> #                              | / _---=> hardirq/softirq
> #                              || / _--=> preempt-depth
> #                              ||| /     delay
> #           TASK-PID     CPU#  ||||   TIMESTAMP  FUNCTION
> #              | |         |   ||||      |         |
>            <...>-135     [005] ...1     9.422114: r_full_proxy_read_0: (vfs_read+0xab/0x1a0 <- full_proxy_read)
>            <...>-135     [005] ...1     9.422158: <stack trace>
>  => kretprobe_trace_func+0x209/0x2f0
>  => kretprobe_dispatcher+0x4a/0x70
>  => __kretprobe_trampoline_handler+0xca/0x150
>  => trampoline_handler+0x44/0x70
>  => kretprobe_trampoline+0x2a/0x50
>  => vfs_read+0xab/0x1a0
>  => ksys_read+0x5f/0xe0
>  => do_syscall_64+0x33/0x40
>  => entry_SYSCALL_64_after_hwframe+0x44/0xae
>  => 0
> 
> This shows the double return probes (vfs_read and full_proxy_read) on the stack
> correctly unwinded. (vfs_read was called from ksys_read+0x5f and full_proxy_read
> was called from vfs_read+0xab)

BTW, this is only for the kretprobe on x86. ORC unwinder (without pt_regs)
still stopped when the kprobe is optimized.


# entries-in-buffer/entries-written: 4/4   #P:8
#
#                                _-----=> irqs-off
#                               / _----=> need-resched
#                              | / _---=> hardirq/softirq
#                              || / _--=> preempt-depth
#                              ||| /     delay
#           TASK-PID     CPU#  ||||   TIMESTAMP  FUNCTION
#              | |         |   ||||      |         |
             cat-138     [005] ...1     9.501630: p_full_proxy_read_5: (full_proxy_read+0x5/0x80)
             cat-138     [005] ...1     9.501675: <stack trace>
 => kprobe_trace_func+0x1d0/0x2c0
 => kprobe_dispatcher+0x39/0x60
 => opt_pre_handler+0x4f/0x80
 => optimized_callback+0xc3/0xf0
 => 0xffffffffa0006032
 => 0

This requires another fix. I think the unwinder can refer the ORC info
(as a bias from the original function) from optprobe_template_func if
it finds the frame address is in the optprobe trampoline buffer.
Note that this is a bit different from the kretprobe_trampoline, because
optprobe trampoline code is cloned for each probed address.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
