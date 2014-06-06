From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Date: Fri, 06 Jun 2014 06:38:14 +0000
Subject: Re: [RFT PATCH -next v3] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <539161D6.7020508@hitachi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5387F150.5000307@hitachi.com> <20140530031838.17427.75896.stgit@ltc230.yrl.intra.hitachi.co.jp>
In-Reply-To: <20140530031838.17427.75896.stgit@ltc230.yrl.intra.hitachi.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Suzuki K. Poulose" <suzuki@in.ibm.com>, Tony Luck <tony.luck@gmail.com>, Paul Mackerras <paulus@samba.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, akataria@vmware.com, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, linuxppc-dev@lists.ozlabs.org, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

Ping?

I guess this should go to 3.16 branch, shouldn't it?

(2014/05/30 12:18), Masami Hiramatsu wrote:
> On ia64 and ppc64, the function pointer does not point the
> entry address of the function, but the address of function
> discriptor (which contains the entry address and misc
> data.) Since the kprobes passes the function pointer stored
> by NOKPROBE_SYMBOL() to kallsyms_lookup_size_offset() for
> initalizing its blacklist, it fails and reports many errors
> as below.
> 
>   Failed to find blacklist 0001013168300000
>   Failed to find blacklist 0001013000f0a000
>   Failed to find blacklist 000101315f70a000
>   Failed to find blacklist 000101324c80a000
>   Failed to find blacklist 0001013063f0a000
>   Failed to find blacklist 000101327800a000
>   Failed to find blacklist 0001013277f0a000
>   Failed to find blacklist 000101315a70a000
>   Failed to find blacklist 0001013277e0a000
>   Failed to find blacklist 000101305a20a000
>   Failed to find blacklist 0001013277d0a000
>   Failed to find blacklist 00010130bdc0a000
>   Failed to find blacklist 00010130dc20a000
>   Failed to find blacklist 000101309a00a000
>   Failed to find blacklist 0001013277c0a000
>   Failed to find blacklist 0001013277b0a000
>   Failed to find blacklist 0001013277a0a000
>   Failed to find blacklist 000101327790a000
>   Failed to find blacklist 000101303140a000
>   Failed to find blacklist 0001013a3280a000
> 
> To fix this bug, this introduces function_entry() macro to
> retrieve the entry address from the given function pointer,
> and uses for kallsyms_lookup_size_offset() while initializing
> blacklist.
> 
> Changes in v3:
>  - Fix a bug to get blacklist address based on function entry
>    instead of function descriptor. (Suzuki's work, Thanks!)
> 
> Changes in V2:
>  - Use function_entry() macro when lookin up symbols instead
>    of storing it.
>  - Update for the latest -next.
> 
> Signed-off-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
> Signed-off-by: Suzuki K. Poulose <suzuki@in.ibm.com>
> Reported-by: Tony Luck <tony.luck@gmail.com>
> Cc: Suzuki K. Poulose <suzuki@in.ibm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Kevin Hao <haokexin@gmail.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> ---
>  arch/ia64/include/asm/types.h    |    2 ++
>  arch/powerpc/include/asm/types.h |   11 +++++++++++
>  include/linux/types.h            |    4 ++++
>  kernel/kprobes.c                 |   11 +++++++----
>  4 files changed, 24 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/types.h b/arch/ia64/include/asm/types.h
> index 4c351b1..95279dd 100644
> --- a/arch/ia64/include/asm/types.h
> +++ b/arch/ia64/include/asm/types.h
> @@ -27,5 +27,7 @@ struct fnptr {
>  	unsigned long gp;
>  };
>  
> +#define function_entry(fn) (((struct fnptr *)(fn))->ip)
> +
>  #endif /* !__ASSEMBLY__ */
>  #endif /* _ASM_IA64_TYPES_H */
> diff --git a/arch/powerpc/include/asm/types.h b/arch/powerpc/include/asm/types.h
> index bfb6ded..8b89d65 100644
> --- a/arch/powerpc/include/asm/types.h
> +++ b/arch/powerpc/include/asm/types.h
> @@ -25,6 +25,17 @@ typedef struct {
>  	unsigned long env;
>  } func_descr_t;
>  
> +#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF = 1)
> +/*
> + * On PPC64 ABIv1 the function pointer actually points to the
> + * function's descriptor. The first entry in the descriptor is the
> + * address of the function text.
> + */
> +#define function_entry(fn)	(((func_descr_t *)(fn))->entry)
> +#else
> +#define function_entry(fn)	((unsigned long)(fn))
> +#endif
> +
>  #endif /* __ASSEMBLY__ */
>  
>  #endif /* _ASM_POWERPC_TYPES_H */
> diff --git a/include/linux/types.h b/include/linux/types.h
> index a0bb704..3b95369 100644
> --- a/include/linux/types.h
> +++ b/include/linux/types.h
> @@ -213,5 +213,9 @@ struct callback_head {
>  };
>  #define rcu_head callback_head
>  
> +#ifndef function_entry
> +#define function_entry(fn)	((unsigned long)(fn))
> +#endif
> +
>  #endif /*  __ASSEMBLY__ */
>  #endif /* _LINUX_TYPES_H */
> diff --git a/kernel/kprobes.c b/kernel/kprobes.c
> index 2ac9f13..3f2d6d4 100644
> --- a/kernel/kprobes.c
> +++ b/kernel/kprobes.c
> @@ -32,6 +32,7 @@
>   *		<prasanna@in.ibm.com> added function-return probes.
>   */
>  #include <linux/kprobes.h>
> +#include <linux/types.h>
>  #include <linux/hash.h>
>  #include <linux/init.h>
>  #include <linux/slab.h>
> @@ -2042,16 +2043,18 @@ static int __init populate_kprobe_blacklist(unsigned long *start,
>  	unsigned long offset = 0, size = 0;
>  
>  	for (iter = start; iter < end; iter++) {
> -		if (!kallsyms_lookup_size_offset(*iter, &size, &offset)) {
> -			pr_err("Failed to find blacklist %p\n", (void *)*iter);
> +		unsigned long entry = function_entry(*iter);
> +		if (!kallsyms_lookup_size_offset(entry, &size, &offset)) {
> +			pr_err("Failed to find blacklist at %p\n",
> +			       (void *)entry);
>  			continue;
>  		}
>  
>  		ent = kmalloc(sizeof(*ent), GFP_KERNEL);
>  		if (!ent)
>  			return -ENOMEM;
> -		ent->start_addr = *iter;
> -		ent->end_addr = *iter + size;
> +		ent->start_addr = entry;
> +		ent->end_addr = entry + size;
>  		INIT_LIST_HEAD(&ent->list);
>  		list_add_tail(&ent->list, &kprobe_blacklist);
>  	}
> 
> 
> 


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com


