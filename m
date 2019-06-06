From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 06 Jun 2019 02:15:52 +0000
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
Message-Id: <016a4808-527d-7164-b8a0-3173a4ecfa25@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
 <20190604215325.GA2025@bombadil.infradead.org>
In-Reply-To: <20190604215325.GA2025@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 06/05/2019 03:23 AM, Matthew Wilcox wrote:
> On Tue, Jun 04, 2019 at 12:04:06PM +0530, Anshuman Khandual wrote:
>> +++ b/arch/x86/mm/fault.c
>> @@ -46,23 +46,6 @@ kmmio_fault(struct pt_regs *regs, unsigned long addr)
>>  	return 0;
>>  }
>>  
>> -static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
>> -{
> ...
>> -}
> 
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 0e8834a..c5a8dcf 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1778,6 +1778,7 @@ static inline int pte_devmap(pte_t pte)
>>  }
>>  #endif
>>  
>> +int notify_page_fault(struct pt_regs *regs, unsigned int trap);
> 
> Why is it now out-of-line?  

Did not get it. AFAICS it is the same from last version and does not cross
80 characters limit on that line.

> 
>> +++ b/mm/memory.c
>> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
>> +{
>> +	int ret = 0;
>> +
>> +	/*
>> +	 * To be potentially processing a kprobe fault and to be allowed
>> +	 * to call kprobe_running(), we have to be non-preemptible.
>> +	 */
>> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
>> +			ret = 1;
>> +	}
>> +	return ret;
>> +}
>> +
> 
> I would argue this should be in kprobes.h as a static nokprobe_inline.

We can do that. Though it will be a stand alone (not inside #ifdef) as it
already takes care of CONFIG_KPROBES via kprobes_built_in(). Will change
it and in which case the above declaration in mm.h would not be required.
