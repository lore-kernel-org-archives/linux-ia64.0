From: "Suzuki K. Poulose" <suzuki@in.ibm.com>
Date: Thu, 19 Jun 2014 09:57:26 +0000
Subject: Re: [RFT PATCH -next v3] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <53A2B136.108@in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5387F150.5000307@hitachi.com> <20140530031838.17427.75896.stgit@ltc230.yrl.intra.hitachi.co.jp> <539161D6.7020508@hitachi.com> <1403078179.32307.7.camel@concordia> <53A15201.7060404@hitachi.com> <1403141433.4768.1.camel@concordia> <53A26C99.6060000@hitachi.com> <53A285D0.1030106@in.ibm.com> <53A2908E.2000806@hitachi.com>
In-Reply-To: <53A2908E.2000806@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@gmail.com>, Paul Mackerras <paulus@samba.org>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, akataria@vmware.com, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On 06/19/2014 12:56 PM, Masami Hiramatsu wrote:
> (2014/06/19 15:40), Suzuki K. Poulose wrote:
>> On 06/19/2014 10:22 AM, Masami Hiramatsu wrote:
>>> (2014/06/19 10:30), Michael Ellerman wrote:
>>>> On Wed, 2014-06-18 at 17:46 +0900, Masami Hiramatsu wrote:
>>>>> (2014/06/18 16:56), Michael Ellerman wrote:
>>>>>> On Fri, 2014-06-06 at 15:38 +0900, Masami Hiramatsu wrote:
>>>>>>> Ping?
>>>>>>>
>>>>>>> I guess this should go to 3.16 branch, shouldn't it?
>>>>>>
>>>>>>>> diff --git a/arch/powerpc/include/asm/types.h b/arch/powerpc/include/asm/types.h
>>>>>>>> index bfb6ded..8b89d65 100644
>>>>>>>> --- a/arch/powerpc/include/asm/types.h
>>>>>>>> +++ b/arch/powerpc/include/asm/types.h
>>>>>>>> @@ -25,6 +25,17 @@ typedef struct {
>>>>>>>>  	unsigned long env;
>>>>>>>>  } func_descr_t;
>>>>>>>>  
>>>>>>>> +#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF = 1)
>>>>>>>> +/*
>>>>>>>> + * On PPC64 ABIv1 the function pointer actually points to the
>>>>>>>> + * function's descriptor. The first entry in the descriptor is the
>>>>>>>> + * address of the function text.
>>>>>>>> + */
>>>>>>>> +#define function_entry(fn)	(((func_descr_t *)(fn))->entry)
>>>>>>>> +#else
>>>>>>>> +#define function_entry(fn)	((unsigned long)(fn))
>>>>>>>> +#endif
>>>>>>
>>>>>> We already have ppc_function_entry(), can't you use that?
>>>>>
>>>>> I'd like to ask you whether the address which ppc_function_entry() returns on
>>>>> PPC ABIv2 is really same address in kallsyms or not.
>>>>> As you can see, kprobes uses function_entry() to get the actual entry address
>>>>> where kallsyms knows. I have not much information about that, but it seems that
>>>>> the "global entry point" is the address which kallsyms knows, isn't it?
>>>>
>>>> OK. I'm not sure off the top of my head which address kallsyms knows about, but
>>>> yes it's likely that it is the global entry point.
>>>>
>>>> I recently sent a patch to add ppc_global_function_entry(), because we need it
>>>> in the ftrace code. Once that is merged you could use that.
>>>
>>> Yeah, I could use that. But since this is used in arch-independent code (e.g. IA64
>>> needs similar macro), I think we'd better define function_entry() in asm/types.h for
>>> general use (for kallsyms), and rename ppc_function_entry to local_function_entry()
>>> in asm/code-patching.h.
>>>
>>>
>>>> How do you hit the original problem, you don't actually specify in your commit
>>>> message? Something with kprobes obviously, but what exactly? I'll try and
>>>> reproduce it here.
>>>
>>> Ah, those messages should be shown in dmesg when booting if it doesn't work,
>>> because the messages are printed by initialization process of kprobe blacklist.
>>> So, reproducing it is just enabling CONFIG_KPROBES and boot it.
>> Well,  we don't get those messages on Power, since the kallsyms has the
>> entries for ".function_name". The correct way to verify is, either  :
> 
> Hmm, that seems another issue on powerpc. Is that expected(and designed)
> behavior?
AFAIK, yes, it is.
To be more precise :

we have 'foo' and '.foo' for a function foo(), where 'foo' points to the
function_entry and '.foo' points to the actual function.

So, a kallsyms_lookup_size_offset() on both 'foo' and '.foo' will return
a hit. So, if we make sure we use the value of '.foo' (by using the
appropriate macros) we should be fine.

 And if so, how I can verify when initializing blacklist?
> (should I better use kallsyms_lookup() and kallsyms_lookup_name() for
> verification?)
One way to verify would be to make sure the symbol starts with '.' from
the result of the current kallsyms_lookup_size_offset() for PPC.

Thanks
Suzuki

> 
> Thank you,
> 
>>
>> 1) Dump the black_list via xmon ( see :
>> https://lkml.org/lkml/2014/5/29/893 ) and verify the entries.
>>
>> or
>>
>> 2) Issue a kprobe on a black listed entry and hit a success,(which we
>> will, since we don't check the actual function address).
>>
>> Thanks
>> Suzuki
>>
>>
>>>
>>> Thank you,
>>>

