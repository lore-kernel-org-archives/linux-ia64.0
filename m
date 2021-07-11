From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sun, 11 Jul 2021 02:07:38 +0000
Subject: Re: [PATCH 2/2] objtool: Ignore unwind hints for ignored functions
Message-Id: <20210711110738.f745f62b6858e2d5d9006cd6@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
        <162399996966.506599.810050095040575221.stgit@devnote2>
        <YOK8pzp8B2V+1EaU@gmail.com>
        <20210710003140.8e561ad33d42f9ac78de6a15@kernel.org>
        <20210710104104.3a270168811ac38420093276@kernel.org>
        <20210710190143.lrcsyal2ggubv43v@treble>
        <20210710192514.ghvksi3ozhez4lvb@treble>
In-Reply-To: <20210710192514.ghvksi3ozhez4lvb@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Sat, 10 Jul 2021 12:25:14 -0700
Josh Poimboeuf <jpoimboe@redhat.com> wrote:

> If a function is ignored, also ignore its hints.  This is useful for the
> case where the function ignore is conditional on frame pointers, e.g.
> STACK_FRAME_NON_STANDARD_FP().

This also looks good to me, and test with my series works fine.

Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>

Thanks!

> 
> Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
> ---
>  tools/objtool/check.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/tools/objtool/check.c b/tools/objtool/check.c
> index e5947fbb9e7a..67cbdcfcabae 100644
> --- a/tools/objtool/check.c
> +++ b/tools/objtool/check.c
> @@ -2909,7 +2909,7 @@ static int validate_unwind_hints(struct objtool_file *file, struct section *sec)
>  	}
>  
>  	while (&insn->list != &file->insn_list && (!sec || insn->sec = sec)) {
> -		if (insn->hint && !insn->visited) {
> +		if (insn->hint && !insn->visited && !insn->ignore) {
>  			ret = validate_branch(file, insn->func, insn, state);
>  			if (ret && backtrace)
>  				BT_FUNC("<== (hint)", insn);
> -- 
> 2.31.1
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
