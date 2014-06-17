From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 17 Jun 2014 23:03:59 +0000
Subject: Re: [RFT PATCH -next v3] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <CA+8MBbJ=piCBmiN_=ycN_kQ4LbZcjz7UXR2Bbohd6z67mghmZg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5387F150.5000307@hitachi.com>
	<20140530031838.17427.75896.stgit@ltc230.yrl.intra.hitachi.co.jp>
	<539161D6.7020508@hitachi.com>
In-Reply-To: <539161D6.7020508@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Suzuki K. Poulose" <suzuki@in.ibm.com>, Paul Mackerras <paulus@samba.org>, Jeremy Fitzhardinge <jeremy@goop.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, akataria@vmware.com, Kevin Hao <haokexin@gmail.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, linuxppc-dev@lists.ozlabs.org, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

On Thu, Jun 5, 2014 at 11:38 PM, Masami Hiramatsu
<masami.hiramatsu.pt@hitachi.com> wrote:
> Ping?
>
> I guess this should go to 3.16 branch, shouldn't it?
>
> (2014/05/30 12:18), Masami Hiramatsu wrote:
>> On ia64 and ppc64, the function pointer does not point the
>> entry address of the function, but the address of function
>> discriptor (which contains the entry address and misc
>> data.) Since the kprobes passes the function pointer stored
>> by NOKPROBE_SYMBOL() to kallsyms_lookup_size_offset() for
>> initalizing its blacklist, it fails and reports many errors
>> as below.
>>
>>   Failed to find blacklist 0001013168300000

Yes please ... just found this problem on ia64 in mainline
and was happy to see this fix for it.

Tested-by: Tony Luck <tony.luck@intel.com>

-Tony
