From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Date: Thu, 17 Jul 2014 11:40:57 +0000
Subject: Re: Re: [RESEND PATCH v5] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <53C7B649.1070004@hitachi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140717071121.3130.86341.stgit@kbuild-fedora.novalocal> <20140717093832.GB4232@gmail.com> <53C7B0E6.1050503@hitachi.com>
In-Reply-To: <53C7B0E6.1050503@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, sparse@chrisli.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, akataria@vmware.com, linux-tip-commits@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, anil.s.keshavamurthy@intel.com, "Suzuki K. Poulose" <suzuki@in.ibm.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, linuxppc-dev@lists.ozlabs.org, rdunlap@infradead.org, Tony Luck <tony.luck@gmail.com>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

(2014/07/17 20:17), Masami Hiramatsu wrote:
> (2014/07/17 18:38), Ingo Molnar wrote:
>>
>> * Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com> wrote:
>>
>>> Signed-off-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
>>> Signed-off-by: Suzuki K. Poulose <suzuki@in.ibm.com>
>>
>> Looks good, but this is not a valid SOB sequence: if Suzuki wrote the 
>> patch then he should be the first SOB (and should have a From line as 
>> well), if he acked it along the way then it should be an Acked-by - or 
>> Reviewed-by.
> 
> Ah, OK, so I'll add his name as Fixed-by:.

Oops, I also found that an old comment in the patch description
and unneeded "include". I'll fix and send that asap.

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com


