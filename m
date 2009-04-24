From: Masami Hiramatsu <mhiramat@redhat.com>
Date: Fri, 24 Apr 2009 02:21:26 +0000
Subject: Re: [PATCH][BUGFIX] utrace/ia64: Fix syscall_get_set_args_cb() to
Message-Id: <49F12226.3070108@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <49EFA4DA.9020402@redhat.com>
In-Reply-To: <49EFA4DA.9020402@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>, Roland McGrath <roland@redhat.com>, David Smith <dsmith@redhat.com>, systemtap-ml <systemtap@sources.redhat.com>

Hi,

Actually, this patch is not only for utrace, but also fixing /proc/pid/syscall.
I made a small program which reads /proc/pid/syscall via both of read() and syscall().

Without this patch:
---
read() read: 1026 0x3 0x60000fffffcb75e8 0x100 0x60000fffffcb7700 0x0 0x20000000000b03f0 0x600007ffffcbc020
0xa000000000010721

syscall() read: 1026 0x402 0x3 0x60000fffffcb75e8 0x100 0x2a8 0x0 0x600007ffffcbc048 0x2000000000209730
---
You can see "0x402"(1026) appeared at syscall() read result.

With this patch:
---
read() read: 1026 0x3 0x60000fffff8a35c8 0x100 0x60000fffff8a36e0 0x0 0x20000000000b03f0 0x600007ffff8a8020
0xa000000000010721

syscall() read: 1026 0x3 0x60000fffff8a35c8 0x100 0x2a8 0x0 0x4 0x600007ffff8a8048 0x2000000000209730
---
Here, you can see that "0x402" disappeared from syscall() case.

Thank you,

Masami Hiramatsu wrote:
> Fix syscall_get_set_args_cb() to decode user-stack correctly in case of
> syscall() which allocates locals in user-stack. If locals (cfm.sol) exist
> on the stack, we have to skip it for getting real systemcall arguments.
> 
> And also, fix the number of getting arguments which must be less than
> (nr outputs - args->i) instead of nr outputs, because args->i is the
> indent number (this means, syscall_get_set_args_cb() get/set arguments
> from (i)th to (i+n)th.)
> 
> Signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
> Cc: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
> Cc: Roland McGrath <roland@redhat.com>
> Cc: David Smith <dsmith@redhat.com>
> ---
>  arch/ia64/kernel/ptrace.c |   13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> Index: 2.6-rc/arch/ia64/kernel/ptrace.c
> =================================> --- 2.6-rc.orig/arch/ia64/kernel/ptrace.c
> +++ 2.6-rc/arch/ia64/kernel/ptrace.c
> @@ -2189,6 +2189,10 @@ struct syscall_get_set_args {
>  	int rw;
>  };
> 
> +#define CFM_SOF(cfm) ((cfm) & 0x7f)			/* Size of frame */
> +#define CFM_SOL(cfm) (((cfm) >> 7) & 0x7f)		/* Size of locals */
> +#define CFM_OUT(cfm) (CFM_SOF(cfm) - CFM_SOL(cfm))	/* Size of outputs */
> +
>  static void syscall_get_set_args_cb(struct unw_frame_info *info, void *data)
>  {
>  	struct syscall_get_set_args *args = data;
> @@ -2205,15 +2209,18 @@ static void syscall_get_set_args_cb(stru
> 
>  	count = 0;
>  	if (in_syscall(pt))
> -		count = min_t(int, args->n, cfm & 0x7f);
> +		/* args->i + args->n must be less equal than nr outputs */
> +		count = min_t(int, args->n, CFM_OUT(cfm) - args->i);
> 
>  	for (i = 0; i < count; i++) {
> +		/* Skips dirties and locals */
>  		if (args->rw)
> -			*ia64_rse_skip_regs(krbs, ndirty + i + args->i) > +			*ia64_rse_skip_regs(krbs,
> +				ndirty + CFM_SOL(cfm) + args->i + i) >  				args->args[i];
>  		else
>  			args->args[i] = *ia64_rse_skip_regs(krbs,
> -				ndirty + i + args->i);
> +				ndirty + CFM_SOL(cfm) + args->i + i);
>  	}
> 
>  	if (!args->rw) {

-- 
Masami Hiramatsu

Software Engineer
Hitachi Computer Products (America) Inc.
Software Solutions Division

e-mail: mhiramat@redhat.com

