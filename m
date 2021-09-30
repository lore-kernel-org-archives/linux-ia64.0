From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 30 Sep 2021 23:11:12 +0000
Subject: Re: [PATCH -tip v11 00/27] kprobes: Fix stacktrace with kretprobes on x86
Message-Id: <87wnmx64mn.ffs@tglx>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
 <20210929112408.35b0ffe06b372533455d890d@kernel.org>
 <CAADnVQ+0v601toAz7wWPy2gxNtiJNZy6UpLmw_Dg+0G8ByJS6A@mail.gmail.com>
 <874ka17t8s.ffs@tglx> <20210930172206.1a34279b@oasis.local.home>
In-Reply-To: <20210930172206.1a34279b@oasis.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Masami Hiramatsu <mhiramat@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, bpf <bpf@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, Kernel Team <kernel-team@fb.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

On Thu, Sep 30 2021 at 17:22, Steven Rostedt wrote:
> On Thu, 30 Sep 2021 21:34:11 +0200
> Thomas Gleixner <tglx@linutronix.de> wrote:
>
>> Masami, feel free to merge them over your tree. If not, let me know and
>> I'll pick them up tomorrow morning.
>
> Masami usually goes through my tree. Want me to take it or do you want
> to?

Now I'm really confused. Masami poke Ingo to merge stuff which goes
usually through your tree !?!

But sure, feel free to pick it up. I have enough stuff on my plate
already.

Thanks,

        tglx
