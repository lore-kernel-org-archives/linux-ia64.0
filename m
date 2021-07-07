From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 07 Jul 2021 08:36:28 +0000
Subject: Re: [PATCH -tip v8 11/13] x86/unwind: Recover kretprobe trampoline entry
Message-Id: <YOVnjCxOORB4epjr@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162400002631.506599.2413605639666466945.stgit@devnote2>
 <YOLurg5mGHdBc+fz@hirez.programming.kicks-ass.net>
 <20210706004257.9e282b98f447251a380f658f@kernel.org>
 <YOQMV8uE/2bVkPOY@hirez.programming.kicks-ass.net>
 <20210706111136.7c5e9843@oasis.local.home>
 <YOVj2VoyrcOvJfEB@hirez.programming.kicks-ass.net>
In-Reply-To: <YOVj2VoyrcOvJfEB@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, wuqiang.matt@bytedance.com

On Wed, Jul 07, 2021 at 10:20:41AM +0200, Peter Zijlstra wrote:

> > > Steve, can you clarify the ftrace side here? Afaict return_to_handler()
> > > is similarly affected.
> > 
> > I'm not exactly sure what the issue is. As Masami stated, kretprobe
> > uses a ret to return to the calling function, but ftrace uses a jmp.
> 
> I'll have to re-read the ftrace bits, but from the top of my head you
> cannot do an indirect jump and preserve all registers at the same time,
> so a return stub must use jump from stack aka. ret.

Hmm... there's callee clobbered regs ofcourse, which don't need to be
preserved. And that's exactly what ftrace seems to be doing, and I don't
think there's any reason why kretprobe cannot do the same. Lemme try.
