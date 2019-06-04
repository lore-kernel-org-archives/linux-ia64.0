From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 04 Jun 2019 06:54:01 +0000
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
Message-Id: <20190604065401.GE3402@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Tue, Jun 04, 2019 at 12:04:06PM +0530, Anshuman Khandual wrote:
> diff --git a/mm/memory.c b/mm/memory.c
> index ddf20bd..b6bae8f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -52,6 +52,7 @@
>  #include <linux/pagemap.h>
>  #include <linux/memremap.h>
>  #include <linux/ksm.h>
> +#include <linux/kprobes.h>
>  #include <linux/rmap.h>
>  #include <linux/export.h>
>  #include <linux/delayacct.h>
> @@ -141,6 +142,21 @@ static int __init init_zero_pfn(void)
>  core_initcall(init_zero_pfn);
>  
>  
> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
> +{
> +	int ret = 0;
> +
> +	/*
> +	 * To be potentially processing a kprobe fault and to be allowed
> +	 * to call kprobe_running(), we have to be non-preemptible.
> +	 */
> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
> +			ret = 1;
> +	}
> +	return ret;
> +}

That thing should be called kprobe_page_fault() or something,
notify_page_fault() is a horribly crap name for this function.
