From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 23 Mar 2021 22:30:07 +0000
Subject: Re: [PATCH -tip v4 10/12] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <20210323223007.GG4746@worktop.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
 <161639530062.895304.16962383429668412873.stgit@devnote2>
In-Reply-To: <161639530062.895304.16962383429668412873.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Mon, Mar 22, 2021 at 03:41:40PM +0900, Masami Hiramatsu wrote:
>  	".global kretprobe_trampoline\n"
>  	".type kretprobe_trampoline, @function\n"
>  	"kretprobe_trampoline:\n"
>  #ifdef CONFIG_X86_64

So what happens if we get an NMI here? That is, after the RET but before
the push? Then our IP points into the trampoline but we've not done that
push yet.

> +	/* Push fake return address to tell the unwinder it's a kretprobe */
> +	"	pushq $kretprobe_trampoline\n"
>  	UNWIND_HINT_FUNC
> +	/* Save the sp-8, this will be fixed later */
> +	"	pushq %rsp\n"
>  	"	pushfq\n"
>  	SAVE_REGS_STRING
>  	"	movq %rsp, %rdi\n"
>  	"	call trampoline_handler\n"
>  	RESTORE_REGS_STRING
> +	"	addq $8, %rsp\n"
>  	"	popfq\n"
