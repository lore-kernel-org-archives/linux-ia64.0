From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 03 Jun 2019 04:53:20 +0000
Subject: Re: [RFC] mm: Generalize notify_page_fault()
Message-Id: <6338fef8-e097-a76e-5c07-455d0d9b6e24@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
 <20190530110639.GC23461@bombadil.infradead.org>
 <4f9a610d-e856-60f6-4467-09e9c3836771@arm.com>
 <20190530133954.GA2024@bombadil.infradead.org>
 <f1995445-d5ab-f292-d26c-809581002184@arm.com>
 <20190531174854.GA31852@bombadil.infradead.org>
In-Reply-To: <20190531174854.GA31852@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrey Konovalov <andreyknvl@google.com>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 05/31/2019 11:18 PM, Matthew Wilcox wrote:
> On Fri, May 31, 2019 at 02:17:43PM +0530, Anshuman Khandual wrote:
>> On 05/30/2019 07:09 PM, Matthew Wilcox wrote:
>>> On Thu, May 30, 2019 at 05:31:15PM +0530, Anshuman Khandual wrote:
>>>> On 05/30/2019 04:36 PM, Matthew Wilcox wrote:
>>>>> The two handle preemption differently.  Why is x86 wrong and this one
>>>>> correct?
>>>>
>>>> Here it expects context to be already non-preemptible where as the proposed
>>>> generic function makes it non-preemptible with a preempt_[disable|enable]()
>>>> pair for the required code section, irrespective of it's present state. Is
>>>> not this better ?
>>>
>>> git log -p arch/x86/mm/fault.c
>>>
>>> search for 'kprobes'.
>>>
>>> tell me what you think.
>>
>> Are you referring to these following commits
>>
>> a980c0ef9f6d ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
>> b506a9d08bae ("x86: code clarification patch to Kprobes arch code")
>>
>> In particular the later one (b506a9d08bae). It explains how the invoking context
>> in itself should be non-preemptible for the kprobes processing context irrespective
>> of whether kprobe_running() or perhaps smp_processor_id() is safe or not. Hence it
>> does not make much sense to continue when original invoking context is preemptible.
>> Instead just bail out earlier. This seems to be making more sense than preempt
>> disable-enable pair. If there are no concerns about this change from other platforms,
>> I will change the preemption behavior in proposed generic function next time around.
> 
> Exactly.
> 
> So, any of the arch maintainers know of a reason they behave differently
> from x86 in this regard?  Or can Anshuman use the x86 implementation
> for all the architectures supporting kprobes?

So the generic notify_page_fault() will be like this.

int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
{
        int ret = 0;

        /*
         * To be potentially processing a kprobe fault and to be allowed
         * to call kprobe_running(), we have to be non-preemptible.
         */
        if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
                if (kprobe_running() && kprobe_fault_handler(regs, trap))
                        ret = 1;
        }
        return ret;
}
