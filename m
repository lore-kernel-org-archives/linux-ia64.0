From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 23 Mar 2021 00:04:29 +0000
Subject: Re: [PATCH -tip v4 08/12] arm: kprobes: Make a space for regs->ARM_pc at kretprobe_trampoline
Message-Id: <20210323090429.da18461654ef9907581dab95@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
        <161639527851.895304.14313883616251450754.stgit@devnote2>
In-Reply-To: <161639527851.895304.14313883616251450754.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Mon, 22 Mar 2021 15:41:18 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> Change kretprobe_trampoline to make a space for regs->ARM_pc so that
> kretprobe_trampoline_handler can call instruction_pointer_set()
> safely.

BTW, if kretprobe_trampoline is replaced with the assembly code,
I think it should fill all the regs as much as possible, because
originally it is written by a software break.
Thus the regs->sp should point the stack address at the entry of 
kretprobe_trampoline, and also regs->lr and regs->pc will be
kretprobe_trampoline, so that user handler can access caller stack.


Thanks, 

> 
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> ---
>  arch/arm/probes/kprobes/core.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm/probes/kprobes/core.c b/arch/arm/probes/kprobes/core.c
> index 1782b41df095..5f3c2b42787f 100644
> --- a/arch/arm/probes/kprobes/core.c
> +++ b/arch/arm/probes/kprobes/core.c
> @@ -397,11 +397,13 @@ int __kprobes kprobe_exceptions_notify(struct notifier_block *self,
>  void __naked __kprobes kretprobe_trampoline(void)
>  {
>  	__asm__ __volatile__ (
> +		"sub	sp, sp, #16		\n\t"
>  		"stmdb	sp!, {r0 - r11}		\n\t"
>  		"mov	r0, sp			\n\t"
>  		"bl	trampoline_handler	\n\t"
>  		"mov	lr, r0			\n\t"
>  		"ldmia	sp!, {r0 - r11}		\n\t"
> +		"add	sp, sp, #16		\n\t"
>  #ifdef CONFIG_THUMB2_KERNEL
>  		"bx	lr			\n\t"
>  #else
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
