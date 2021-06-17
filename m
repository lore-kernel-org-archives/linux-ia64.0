From: Josh Poimboeuf <jpoimboe@redhat.com>
Date: Thu, 17 Jun 2021 04:41:24 +0000
Subject: Re: [PATCH -tip v7 11/13] x86/unwind: Recover kretprobe trampoline entry
Message-Id: <20210617044124.pv4xm47cum4faaeo@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <162209754288.436794.3904335049560916855.stgit@devnote2>
 <162209764814.436794.15907711942126944591.stgit@devnote2>
In-Reply-To: <162209764814.436794.15907711942126944591.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Thu, May 27, 2021 at 03:40:48PM +0900, Masami Hiramatsu wrote:
> Since the kretprobe replaces the function return address with
> the kretprobe_trampoline on the stack, x86 unwinders can not
> continue the stack unwinding at that point, or record
> kretprobe_trampoline instead of correct return address.
> 
> To fix this issue, find the correct return address from task's
> kretprobe_instances as like as function-graph tracer does.
> 
> With this fix, the unwinder can correctly unwind the stack
> from kretprobe event on x86, as below.
> 
>            <...>-135     [003] ...1     6.722338: r_full_proxy_read_0: (vfs_read+0xab/0x1a0 <- full_proxy_read)
>            <...>-135     [003] ...1     6.722377: <stack trace>
>  => kretprobe_trace_func+0x209/0x2f0
>  => kretprobe_dispatcher+0x4a/0x70
>  => __kretprobe_trampoline_handler+0xca/0x150
>  => trampoline_handler+0x44/0x70
>  => kretprobe_trampoline+0x2a/0x50
>  => vfs_read+0xab/0x1a0
>  => ksys_read+0x5f/0xe0
>  => do_syscall_64+0x33/0x40
>  => entry_SYSCALL_64_after_hwframe+0x44/0xae
> 
> 
> Reported-by: Daniel Xu <dxu@dxuuu.xyz>
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> Suggested-by: Josh Poimboeuf <jpoimboe@redhat.com>
> Tested-by: Andrii Nakryik <andrii@kernel.org>

Acked-by: Josh Poimboeuf <jpoimboe@redhat.com>

-- 
Josh
