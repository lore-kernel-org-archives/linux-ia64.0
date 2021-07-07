From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 07 Jul 2021 10:20:57 +0000
Subject: Re: [PATCH -tip v8 11/13] x86/unwind: Recover kretprobe trampoline entry
Message-Id: <YOWACec65qVdTD1y@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162400002631.506599.2413605639666466945.stgit@devnote2>
 <YOLurg5mGHdBc+fz@hirez.programming.kicks-ass.net>
 <20210706004257.9e282b98f447251a380f658f@kernel.org>
 <YOQMV8uE/2bVkPOY@hirez.programming.kicks-ass.net>
 <20210706111136.7c5e9843@oasis.local.home>
 <YOVj2VoyrcOvJfEB@hirez.programming.kicks-ass.net>
 <20210707191510.cb48ca4a20f0502ce6c46508@kernel.org>
In-Reply-To: <20210707191510.cb48ca4a20f0502ce6c46508@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, wuqiang.matt@bytedance.com

On Wed, Jul 07, 2021 at 07:15:10PM +0900, Masami Hiramatsu wrote:

> I actually don't want to keep this feature because no one use it.
> (only systemtap needs it?)

Yeah, you mentioned systemtap, but since that's out-of-tree I don't
care. Their problem.

> Anyway, if we keep the idea-level compatibility (not code level),
> what we need is 'void *data' in the struct kretprobe_instance.
> User who needs it can allocate their own instance data for their
> kretprobes when initialising it and sets in their entry handler.
> 
> Then we can have a simple kretprobe_instance.

When would you do the alloc? When installing the retprobe, but that
might be inside the allocator, which means you can't call the allocator
etc.. :-)

If we look at struct ftrace_ret_stack, it has a few fixed function
fields. The calltime one is all that is needed for the kretprobe
example code.
