From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sat, 20 Mar 2021 01:04:28 +0000
Subject: Re: [PATCH -tip v3 07/11] ia64: Add instruction_pointer_set() API
Message-Id: <20210320100428.7cd2acb7d5c084ce293249d9@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <161615650355.306069.17260992641363840330.stgit@devnote2>
        <161615658087.306069.12036720803234007510.stgit@devnote2>
In-Reply-To: <161615658087.306069.12036720803234007510.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org

On Fri, 19 Mar 2021 21:23:01 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> Add instruction_pointer_set() API for ia64.
> 
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> ---
>  arch/ia64/include/asm/ptrace.h |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/include/asm/ptrace.h b/arch/ia64/include/asm/ptrace.h
> index b3aa46090101..e382f1a6bff3 100644
> --- a/arch/ia64/include/asm/ptrace.h
> +++ b/arch/ia64/include/asm/ptrace.h
> @@ -45,6 +45,7 @@
>  #include <asm/current.h>
>  #include <asm/page.h>
>  
> +# define ia64_psr(regs)			((struct ia64_psr *) &(regs)->cr_ipsr)
>  /*
>   * We use the ia64_psr(regs)->ri to determine which of the three
>   * instructions in bundle (16 bytes) took the sample. Generate
> @@ -71,6 +72,12 @@ static inline long regs_return_value(struct pt_regs *regs)
>  		return -regs->r8;
>  }
>  
> +static inline void instruction_pointer_set(struct pt_regs *regs, unsigned long val)
> +{
> +	ia64_psr(regs)->ri = (val & 0xf);
> +	regs->cr_iip = (val & ~0xfULL);
> +}

Oops, this caused a build error. Thanks for the kernel test bot.

It seems that all code which accessing to the "struct ia64_psr" in asm/ptrace.h
has to be a macro, because "struct ia64_psr" is defined in the asm/processor.h
which includes asm/ptrace.h (for pt_regs?).
If the code is defined as an inline function, the "struct ia64_psr" is evaluated
at that point, and caused build error.

arch/ia64/include/asm/ptrace.h:77:16: error: dereferencing pointer to incomplete type 'struct ia64_psr'

But macro code evaluation is postponed until it is used...

Let me update it.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
