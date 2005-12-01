From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Thu, 01 Dec 2005 20:06:36 +0000
Subject: Re: [PATCH] save parameter registers and restore them for jprobe handling
Message-Id: <20051201120636.A7726@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E84040B3BF4@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E84040B3BF4@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 30, 2005 at 09:19:02PM -0800, Zhang, Yanmin wrote:

> How about the new patch? I add a new function in arch/ia64/kernel/entry.S.
> 
I agree with Ken, move the assembly function to arch/ia64/kernel/jprobe.S file.
Also, please see my comments.

>  int __kprobes setjmp_pre_handler(struct kprobe *p, struct pt_regs *regs)
>  {
[...]
>  	/* save architectural state */
Wrong comment above, we are not saving architectural state. 
I guess the comment should be
"Callee owns the argument space and could overwrite it, eg
tail call optimization. So to be absolutely safe
we save the argument space before transfering the control
to instrumented jprobe function which runs in 
the process context"

> @@ -785,8 +821,19 @@ int __kprobes setjmp_pre_handler(struct 
>  int __kprobes longjmp_break_handler(struct kprobe *p, struct pt_regs *regs)
>  {
[....]
> +	unw_init_running(ia64_get_bsp_cfm, &pa);
Just an optimization, avoid calling unw_init_running()
and just save bsp and cfm in the previous call and
reuse it. I think you can save in the kcb
structure.

> +	bytes = (char *)ia64_rse_skip_regs(pa.bsp, pa.cfm & 0x3f)
> +				- (char *)pa.bsp;
Again Comment please.. like
	/* restoring the original argument space */
> +	memcpy( pa.bsp,
> +		kcb->jprobes_saved_stacked_regs,
> +		bytes );

-Anil Keshavamurthy
