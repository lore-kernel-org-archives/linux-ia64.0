From: "Suzuki K. Poulose" <suzuki@in.ibm.com>
Date: Thu, 29 May 2014 19:25:28 +0000
Subject: Re: [RFT PATCH -next v2] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <538786D8.1070303@in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5383249A.6060407@in.ibm.com> <20140527063121.4399.38014.stgit@ltc230.yrl.intra.hitachi.co.jp>
In-Reply-To: <20140527063121.4399.38014.stgit@ltc230.yrl.intra.hitachi.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Tony Luck <tony.luck@gmail.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, akataria@vmware.com, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On 05/27/2014 12:01 PM, Masami Hiramatsu wrote:
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
> Changes in V2:
>  - Use function_entry() macro when lookin up symbols instead
>    of storing it.
>  - Update for the latest -next.
> 
> Signed-off-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
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
>  kernel/kprobes.c                 |    4 +++-
>  4 files changed, 20 insertions(+), 1 deletion(-)
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
> index 2ac9f13..3859c88 100644
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
> @@ -2042,7 +2043,8 @@ static int __init populate_kprobe_blacklist(unsigned long *start,
>  	unsigned long offset = 0, size = 0;
>  
>  	for (iter = start; iter < end; iter++) {
> -		if (!kallsyms_lookup_size_offset(*iter, &size, &offset)) {
> +		if (!kallsyms_lookup_size_offset(function_entry(*iter),
> +						 &size, &offset)) {

On powerpc we will be able to resolve the *iter to func_descr and won't
get the below error with/without this patch. So we have to actually
verify the kprobe_blacklist contents to make sure everything is alright.

>  			pr_err("Failed to find blacklist %p\n", (void *)*iter);
>  			continue;
>  		}
> 

There is a bug here.
You need to set the ent->start using the function_entry(*iter) and not
*iter. Or else you just avoid the 'Warning' and still have an invalid
black list. As shown below :

    2e:mon> ls kprobe_blacklist
    kprobe_blacklist: c00000000104dad0
    2e:mon> d c00000000104dad0 10
    c00000000104dad0: c0000003aff800a0 c0000003aff809a0
    2e:mon> d c0000003aff800a0 20 (struct kprobe_blacklist *)
    c0000003aff800a0: c0000003aff800c0 c00000000104dad0
    c0000003aff800b0: c0000000010ef138 c0000000010ef188
                      start ^^         end ^^
    2e:mon> la c0000000010ef138 (start)
    c0000000010ef138: notify_die+0x0/0x10 <- still points to the
function descriptor
    2e:mon> la c0000000010ef188 (end)
    c0000000010ef188: __blocking_notifier_call_chain+0x0/0x10


Following patch fixes the issue, with the patch :

1:mon> ls kprobe_blacklist
kprobe_blacklist: c00000000104dad0
1:mon> d c00000000104dad0 10
c00000000104dad0: c0000003ae1a00a0 c0000003ae1a09a0
1:mon> d c0000003ae1a00a0 20 (struct kprobe_blacklist *)
c0000003ae1a00a0: c0000003ae1a00c0 c00000000104dad0
c0000003ae1a00b0: c0000000000b14d0 c0000000000b1520
                      start ^^         end ^^
1:mon> la c0000000000b14d0
c0000000000b14d0: .notify_die+0x0/0x50
1:mon> la c0000000000b1520
c0000000000b1520: .atomic_notifier_chain_register+0x0/0xa0

1:mon> di c0000000000b14d0 10 (.notify_die)
c0000000000b14d0  7c0802a6	mflr	r0
c0000000000b14d4  7c691b78	mr	r9,r3

commit ed51674aca8e0496641f565421ab6691a873e80a
Author: Suzuki K. Poulose <suzuki@in.ibm.com>
Date:   Fri May 30 00:23:01 2014 +0530

diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 3859c88..b81d626 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -2043,7 +2043,8 @@ static int __init
populate_kprobe_blacklist(unsigned long *start,
        unsigned long offset = 0, size = 0;

        for (iter = start; iter < end; iter++) {
-               if (!kallsyms_lookup_size_offset(function_entry(*iter),
+               unsigned long entry = function_entry(*iter);
+               if (!kallsyms_lookup_size_offset(entry,
                                                 &size, &offset)) {
                        pr_err("Failed to find blacklist %p\n", (void
*)*iter);
                        continue;
@@ -2052,8 +2053,8 @@ static int __init
populate_kprobe_blacklist(unsigned long *start,
                ent = kmalloc(sizeof(*ent), GFP_KERNEL);
                if (!ent)
                        return -ENOMEM;
-               ent->start_addr = *iter;
-               ent->end_addr = *iter + size;
+               ent->start_addr = entry;
+               ent->end_addr = entry + size;
                INIT_LIST_HEAD(&ent->list);
                list_add_tail(&ent->list, &kprobe_blacklist);
        }


Thanks
Suzuki

