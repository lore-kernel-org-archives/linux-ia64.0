From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 05 Jul 2021 08:34:58 +0000
Subject: Re: [PATCH -tip v8 13/13] x86/kprobes: Fixup return address in generic trampoline handler
Message-Id: <YOLEMvR1bCQiIMcl@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162400004562.506599.7549585083316952768.stgit@devnote2>
In-Reply-To: <162400004562.506599.7549585083316952768.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>


* Masami Hiramatsu <mhiramat@kernel.org> wrote:

> In x86, kretprobe trampoline address on the stack frame will
> be replaced with the real return address after returning from
> trampoline_handler. Before fixing the return address, the real
> return address can be found in the current->kretprobe_instances.
> 
> However, since there is a window between updating the
> current->kretprobe_instances and fixing the address on the stack,
> if an interrupt caused at that timing and the interrupt handler
> does stacktrace, it may fail to unwind because it can not get
> the correct return address from current->kretprobe_instances.
> 
> This will minimize that window by fixing the return address
> right before updating current->kretprobe_instances.

Is there still a window? I.e. is it "minimized" (to how big of a window?), 
or eliminated?

> +void arch_kretprobe_fixup_return(struct pt_regs *regs,
> +				 unsigned long correct_ret_addr)
> +{
> +	unsigned long *frame_pointer;
> +
> +	frame_pointer = ((unsigned long *)&regs->sp) + 1;
> +
> +	/* Replace fake return address with real one. */
> +	*frame_pointer = correct_ret_addr;

Firstly, why does &regs->sp have to be forced to 'unsigned long *'? 

pt_regs::sp is 'unsigned long' on both 32-bit and 64-bit kernels AFAICS.

Secondly, the new code modified by your patch now looks like this:

        frame_pointer = ((unsigned long *)&regs->sp) + 1;
 
+       kretprobe_trampoline_handler(regs, frame_pointer);

where:

+void arch_kretprobe_fixup_return(struct pt_regs *regs,
+                                unsigned long correct_ret_addr)
+{
+       unsigned long *frame_pointer;
+
+       frame_pointer = ((unsigned long *)&regs->sp) + 1;
+
+       /* Replace fake return address with real one. */
+       *frame_pointer = correct_ret_addr;
+}

So we first do:

        frame_pointer = ((unsigned long *)&regs->sp) + 1;

... and pass that in to arch_kretprobe_fixup_return() as 
'correct_ret_addr', which does:

+       frame_pointer = ((unsigned long *)&regs->sp) + 1;
+	*frame_pointer = correct_ret_addr;

... which looks like the exact same thing as:

	*frame_pointer = frame_pointer;

... obfuscated through a thick layer of type casts?

Thanks,

	Ingo
