From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 05 Jul 2021 08:04:41 +0000
Subject: Re: [PATCH -tip v8 08/13] arm: kprobes: Make a space for regs->ARM_pc at kretprobe_trampoline
Message-Id: <YOK9Gbcd63QkU5LB@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162399999702.506599.16339931387573094059.stgit@devnote2>
In-Reply-To: <162399999702.506599.16339931387573094059.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>


* Masami Hiramatsu <mhiramat@kernel.org> wrote:

> Change kretprobe_trampoline to make a space for regs->ARM_pc so that
> kretprobe_trampoline_handler can call instruction_pointer_set()
> safely.

The idiom is "make space", but in any case, what does this mean?

Was the stack frame set up in kretprobe_trampoline() and calling 
trampoline_handler() buggy?

If yes, then explain the bad effects of the bug, and make all of this clear 
in the title & changelog.

Thanks,

	Ingo
