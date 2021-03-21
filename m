From: Josh Poimboeuf <jpoimboe@redhat.com>
Date: Sun, 21 Mar 2021 17:50:04 +0000
Subject: Re: [PATCH -tip v3 05/11] x86/kprobes: Add UNWIND_HINT_FUNC on kretprobe_trampoline code
Message-Id: <20210321174855.oqqtvgb2xwyk4klf@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <161615650355.306069.17260992641363840330.stgit@devnote2>
 <161615655969.306069.4545805781593088526.stgit@devnote2>
 <20210320211616.a976fc66d0c51e13d3121e2f@kernel.org>
In-Reply-To: <20210320211616.a976fc66d0c51e13d3121e2f@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org

On Sat, Mar 20, 2021 at 09:16:16PM +0900, Masami Hiramatsu wrote:
> On Fri, 19 Mar 2021 21:22:39 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > From: Josh Poimboeuf <jpoimboe@redhat.com>
> > 
> > Add UNWIND_HINT_FUNC on kretporbe_trampoline code so that ORC
> > information is generated on the kretprobe_trampoline correctly.
> > 
> 
> Test bot also found a new warning for this.
> 
> > >> arch/x86/kernel/kprobes/core.o: warning: objtool: kretprobe_trampoline()+0x25: call without frame pointer save/setup
> 
> With CONFIG_FRAME_POINTER=y.
> 
> Of course this can be fixed with additional "push %bp; mov %sp, %bp" before calling
> trampoline_handler. But actually we know that this function has a bit special
> stack frame too. 
> 
> Can I recover STACK_FRAME_NON_STANDARD(kretprobe_trampoline) when CONFIG_FRAME_POINTER=y ?

Yes, that's what I'd recommend.

-- 
Josh
