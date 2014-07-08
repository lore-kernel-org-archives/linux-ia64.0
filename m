From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Date: Tue, 08 Jul 2014 12:07:02 +0000
Subject: Re: [PATCH v5 2/2] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <53BBDEE6.1080800@hitachi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404276081.7254.1.camel@concordia> <20140702070029.14689.18485.stgit@kbuild-fedora.novalocal>
In-Reply-To: <20140702070029.14689.18485.stgit@kbuild-fedora.novalocal>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Tony Luck <tony.luck@gmail.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, linux-tip-commits@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, akataria@vmware.com, anil.s.keshavamurthy@intel.com, "Suzuki K. Poulose" <suzuki@in.ibm.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, linuxppc-dev@lists.ozlabs.org, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

Ping?

This patch can be applied without 1/2, and will fix ia64/ppc64 problem.

Thank you,

(2014/07/02 16:00), Masami Hiramatsu wrote:
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
> Changes in v5:
>  - Use arch_deref_entry_point() instead of function_entry().
> 
> Changes in v4:
>  - Add kernel_text_address() check for verifying the address.
>  - Moved on the latest linus tree.
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
> Reported-by: Tony Luck <tony.luck@gmail.com>
> Tested-by: Tony Luck <tony.luck@intel.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
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
>  kernel/kprobes.c |   15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/kprobes.c b/kernel/kprobes.c
> index 3214289..ec370cc 100644
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
> @@ -2037,19 +2038,23 @@ static int __init populate_kprobe_blacklist(unsigned long *start,
>  {
>  	unsigned long *iter;
>  	struct kprobe_blacklist_entry *ent;
> -	unsigned long offset = 0, size = 0;
> +	unsigned long entry, offset = 0, size = 0;
>  
>  	for (iter = start; iter < end; iter++) {
> -		if (!kallsyms_lookup_size_offset(*iter, &size, &offset)) {
> -			pr_err("Failed to find blacklist %p\n", (void *)*iter);
> +		entry = arch_deref_entry_point((void *)*iter);
> +
> +		if (!kernel_text_address(entry) ||
> +		    !kallsyms_lookup_size_offset(entry, &size, &offset)) {
> +			pr_err("Failed to find blacklist at %p\n",
> +				(void *)entry);
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com


