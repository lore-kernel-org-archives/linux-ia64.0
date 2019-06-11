From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Tue, 11 Jun 2019 04:46:52 +0000
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as kprobe_page_fault()
Message-Id: <f6d295c8-574d-3e64-79ae-2f7d3ff4c9f0@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
 <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
In-Reply-To: <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mackerras <paulus@samba.org>, Matthew Wilcox <willy@infradead.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



Le 10/06/2019 à 04:39, Anshuman Khandual a écrit :
> 
> 
> On 06/07/2019 09:01 PM, Christophe Leroy wrote:
>>
>>
>> Le 07/06/2019 à 12:34, Anshuman Khandual a écrit :
>>> Very similar definitions for notify_page_fault() are being used by multiple
>>> architectures duplicating much of the same code. This attempts to unify all
>>> of them into a generic implementation, rename it as kprobe_page_fault() and
>>> then move it to a common header.
>>>
>>> kprobes_built_in() can detect CONFIG_KPROBES, hence new kprobe_page_fault()
>>> need not be wrapped again within CONFIG_KPROBES. Trap number argument can
>>> now contain upto an 'unsigned int' accommodating all possible platforms.
>>>
>>> kprobe_page_fault() goes the x86 way while dealing with preemption context.
>>> As explained in these following commits the invoking context in itself must
>>> be non-preemptible for kprobes processing context irrespective of whether
>>> kprobe_running() or perhaps smp_processor_id() is safe or not. It does not
>>> make much sense to continue when original context is preemptible. Instead
>>> just bail out earlier.
>>>
>>> commit a980c0ef9f6d
>>> ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
>>>
>>> commit b506a9d08bae ("x86: code clarification patch to Kprobes arch code")
>>>
>>> Cc: linux-arm-kernel@lists.infradead.org
>>> Cc: linux-ia64@vger.kernel.org
>>> Cc: linuxppc-dev@lists.ozlabs.org
>>> Cc: linux-s390@vger.kernel.org
>>> Cc: linux-sh@vger.kernel.org
>>> Cc: sparclinux@vger.kernel.org
>>> Cc: x86@kernel.org
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Matthew Wilcox <willy@infradead.org>
>>> Cc: Mark Rutland <mark.rutland@arm.com>
>>> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
>>> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
>>> Cc: Andrey Konovalov <andreyknvl@google.com>
>>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>>> Cc: Paul Mackerras <paulus@samba.org>
>>> Cc: Russell King <linux@armlinux.org.uk>
>>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>>> Cc: Will Deacon <will.deacon@arm.com>
>>> Cc: Tony Luck <tony.luck@intel.com>
>>> Cc: Fenghua Yu <fenghua.yu@intel.com>
>>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>>> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>> Cc: Peter Zijlstra <peterz@infradead.org>
>>> Cc: Ingo Molnar <mingo@redhat.com>
>>> Cc: Andy Lutomirski <luto@kernel.org>
>>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>>>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>> Testing:
>>>
>>> - Build and boot tested on arm64 and x86
>>> - Build tested on some other archs (arm, sparc64, alpha, powerpc etc)
>>>
>>> Changes in RFC V3:
>>>
>>> - Updated the commit message with an explaination for new preemption behaviour
>>> - Moved notify_page_fault() to kprobes.h with 'static nokprobe_inline' per Matthew
>>> - Changed notify_page_fault() return type from int to bool per Michael Ellerman
>>> - Renamed notify_page_fault() as kprobe_page_fault() per Peterz
>>>
>>> Changes in RFC V2: (https://patchwork.kernel.org/patch/10974221/)
>>>
>>> - Changed generic notify_page_fault() per Mathew Wilcox
>>> - Changed x86 to use new generic notify_page_fault()
>>> - s/must not/need not/ in commit message per Matthew Wilcox
>>>
>>> Changes in RFC V1: (https://patchwork.kernel.org/patch/10968273/)
>>>
>>>    arch/arm/mm/fault.c      | 24 +-----------------------
>>>    arch/arm64/mm/fault.c    | 24 +-----------------------
>>>    arch/ia64/mm/fault.c     | 24 +-----------------------
>>>    arch/powerpc/mm/fault.c  | 23 ++---------------------
>>>    arch/s390/mm/fault.c     | 16 +---------------
>>>    arch/sh/mm/fault.c       | 18 ++----------------
>>>    arch/sparc/mm/fault_64.c | 16 +---------------
>>>    arch/x86/mm/fault.c      | 21 ++-------------------
>>>    include/linux/kprobes.h  | 16 ++++++++++++++++
>>>    9 files changed, 27 insertions(+), 155 deletions(-)
>>>
>>
>> [...]
>>
>>> diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
>>> index 443d980..064dd15 100644
>>> --- a/include/linux/kprobes.h
>>> +++ b/include/linux/kprobes.h
>>> @@ -458,4 +458,20 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
>>>    }
>>>    #endif
>>>    +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
>>> +                          unsigned int trap)
>>> +{
>>> +    int ret = 0;
>>
>> ret is pointless.
>>
>>> +
>>> +    /*
>>> +     * To be potentially processing a kprobe fault and to be allowed
>>> +     * to call kprobe_running(), we have to be non-preemptible.
>>> +     */
>>> +    if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>>> +        if (kprobe_running() && kprobe_fault_handler(regs, trap))
>>
>> don't need an 'if A if B', can do 'if A && B'
> 
> Which will make it a very lengthy condition check.

Yes. But is that a problem at all ?

For me the following would be easier to read.

if (kprobes_built_in() && !preemptible() && !user_mode(regs) &&
     kprobe_running() && kprobe_fault_handler(regs, trap))
	ret = 1;

Christophe

> 
>>
>>> +            ret = 1;
>>
>> can do 'return true;' directly here
>>
>>> +    }
>>> +    return ret;
>>
>> And 'return false' here.
> 
> Makes sense, will drop ret.
> 
