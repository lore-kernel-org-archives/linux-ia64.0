From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 30 May 2019 12:13:15 +0000
Subject: Re: [RFC] mm: Generalize notify_page_fault()
Message-Id: <4f9a610d-e856-60f6-4467-09e9c3836771@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
 <20190530110639.GC23461@bombadil.infradead.org>
In-Reply-To: <20190530110639.GC23461@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrey Konovalov <andreyknvl@google.com>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 05/30/2019 04:36 PM, Matthew Wilcox wrote:
> On Thu, May 30, 2019 at 11:25:13AM +0530, Anshuman Khandual wrote:
>> Similar notify_page_fault() definitions are being used by architectures
>> duplicating much of the same code. This attempts to unify them into a
>> single implementation, generalize it and then move it to a common place.
>> kprobes_built_in() can detect CONFIG_KPROBES, hence notify_page_fault()
>> must not be wrapped again within CONFIG_KPROBES. Trap number argument can
> 
> This is a funny quirk of the English language.  "must not" means "is not
> allowed to be", not "does not have to be".

You are right. Noted for future. Thanks !

> 
>> @@ -141,6 +142,19 @@ static int __init init_zero_pfn(void)
>>  core_initcall(init_zero_pfn);
>>  
>>  
>> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
>> +{
>> +	int ret = 0;
>> +
>> +	if (kprobes_built_in() && !user_mode(regs)) {
>> +		preempt_disable();
>> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
>> +			ret = 1;
>> +		preempt_enable();
>> +	}
>> +	return ret;
>> +}
>> +
>>  #if defined(SPLIT_RSS_COUNTING)
> 
> Comparing this to the canonical implementation (ie x86), it looks similar.
> 
> static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
> {
>         if (!kprobes_built_in())
>                 return 0;
>         if (user_mode(regs))
>                 return 0;
>         /*
>          * To be potentially processing a kprobe fault and to be allowed to call
>          * kprobe_running(), we have to be non-preemptible.
>          */
>         if (preemptible())
>                 return 0;
>         if (!kprobe_running())
>                 return 0;
>         return kprobe_fault_handler(regs, X86_TRAP_PF);
> }
> 
> The two handle preemption differently.  Why is x86 wrong and this one
> correct?

Here it expects context to be already non-preemptible where as the proposed
generic function makes it non-preemptible with a preempt_[disable|enable]()
pair for the required code section, irrespective of it's present state. Is
not this better ?
