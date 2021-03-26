From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 26 Mar 2021 14:20:09 +0000
Subject: Re: [PATCH -tip v4 10/12] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <20210326102009.265f359c@gandalf.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
        <161639530062.895304.16962383429668412873.stgit@devnote2>
        <20210323223007.GG4746@worktop.programming.kicks-ass.net>
        <20210324104058.7c06aaeb0408e24db6ba46f8@kernel.org>
        <20210326030503.7fa72da34e25ad35cf5ed3de@kernel.org>
        <20210326210349.22f6d34b229dd3a139a53686@kernel.org>
In-Reply-To: <20210326210349.22f6d34b229dd3a139a53686@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Fri, 26 Mar 2021 21:03:49 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> I confirmed this is not related to this series, but occurs when I build kernels with different
> configs without cleanup.
> 
> Once I build kernel with CONFIG_UNWIND_GUESS=y (for testing), and after that,
> I build kernel again with CONFIG_UNWIND_ORC=y (but without make clean), this
> happened. In this case, I guess ORC data might be corrupted?
> When I cleanup and rebuild, the stacktrace seems correct.

Hmm, that should be fixed. Seems like we are missing a dependency somewhere.

-- Steve
