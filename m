From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Date: Thu, 19 Jun 2014 11:20:45 +0000
Subject: Re: Re: Re: [RFT PATCH -next v3] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and 
Message-Id: <53A2C78D.9060708@hitachi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5387F150.5000307@hitachi.com> <20140530031838.17427.75896.stgit@ltc230.yrl.intra.hitachi.co.jp> <539161D6.7020508@hitachi.com> <1403078179.32307.7.camel@concordia> <53A15201.7060404@hitachi.com> <1403141433.4768.1.camel@concordia> <53A26C99.6060000@hitachi.com> <53A285D0.1030106@in.ibm.com> <53A2908E.2000806@hitachi.com> <53A2B136.108@in.ibm.com> <53A2C315.9030006@hitachi.com>
In-Reply-To: <53A2C315.9030006@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Suzuki K. Poulose" <suzuki@in.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@gmail.com>, Paul Mackerras <paulus@samba.org>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, akataria@vmware.com, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

(2014/06/19 20:01), Masami Hiramatsu wrote:

>>>>> Ah, those messages should be shown in dmesg when booting if it doesn't work,
>>>>> because the messages are printed by initialization process of kprobe blacklist.
>>>>> So, reproducing it is just enabling CONFIG_KPROBES and boot it.
>>>> Well,  we don't get those messages on Power, since the kallsyms has the
>>>> entries for ".function_name". The correct way to verify is, either  :
>>>
>>> Hmm, that seems another issue on powerpc. Is that expected(and designed)
>>> behavior?
>> AFAIK, yes, it is.
>> To be more precise :
>>
>> we have 'foo' and '.foo' for a function foo(), where 'foo' points to the
>> function_entry and '.foo' points to the actual function.
> 
> Ah, I see. So if we run
> 
>   func_ptr p = foo;
>   return p = kallsyms_lookup_name(".foo");
> 
> it returns true.

One more thing I should know, is the address of ".function_name" within the
kernel text? In other words, does kernel_text_address() return true for that
address? If not, it's easy to verify the address.

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com


