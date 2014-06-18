From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Date: Wed, 18 Jun 2014 08:46:57 +0000
Subject: Re: Re: [RFT PATCH -next v3] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc6
Message-Id: <53A15201.7060404@hitachi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5387F150.5000307@hitachi.com>  <20140530031838.17427.75896.stgit@ltc230.yrl.intra.hitachi.co.jp>  <539161D6.7020508@hitachi.com> <1403078179.32307.7.camel@concordia>
In-Reply-To: <1403078179.32307.7.camel@concordia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <michael@ellerman.id.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Suzuki K. Poulose" <suzuki@in.ibm.com>, Tony Luck <tony.luck@gmail.com>, Paul Mackerras <paulus@samba.org>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, akataria@vmware.com, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

(2014/06/18 16:56), Michael Ellerman wrote:
> On Fri, 2014-06-06 at 15:38 +0900, Masami Hiramatsu wrote:
>> Ping?
>>
>> I guess this should go to 3.16 branch, shouldn't it?
> 
>>> diff --git a/arch/powerpc/include/asm/types.h b/arch/powerpc/include/asm/types.h
>>> index bfb6ded..8b89d65 100644
>>> --- a/arch/powerpc/include/asm/types.h
>>> +++ b/arch/powerpc/include/asm/types.h
>>> @@ -25,6 +25,17 @@ typedef struct {
>>>  	unsigned long env;
>>>  } func_descr_t;
>>>  
>>> +#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF = 1)
>>> +/*
>>> + * On PPC64 ABIv1 the function pointer actually points to the
>>> + * function's descriptor. The first entry in the descriptor is the
>>> + * address of the function text.
>>> + */
>>> +#define function_entry(fn)	(((func_descr_t *)(fn))->entry)
>>> +#else
>>> +#define function_entry(fn)	((unsigned long)(fn))
>>> +#endif
> 
> We already have ppc_function_entry(), can't you use that?

I'd like to ask you whether the address which ppc_function_entry() returns on
PPC ABIv2 is really same address in kallsyms or not.
As you can see, kprobes uses function_entry() to get the actual entry address
where kallsyms knows. I have not much information about that, but it seems that
the "global entry point" is the address which kallsyms knows, isn't it?

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com


