From: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Date: Thu, 08 May 2014 06:28:58 +0000
Subject: Re: [RFT PATCH -next ] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <20140508061658.GA2384@in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <536A16A6.5040709@hitachi.com>
 <20140507115551.22259.70581.stgit@ltc230.yrl.intra.hitachi.co.jp>
 <20140508044753.GA13413@in.ibm.com>
 <536B18B0.9060209@hitachi.com>
In-Reply-To: <536B18B0.9060209@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Tony Luck <tony.luck@gmail.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, akataria@vmware.com, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, linuxppc-dev@lists.ozlabs.org, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

On Thu, May 08, 2014 at 02:40:00PM +0900, Masami Hiramatsu wrote:
> (2014/05/08 13:47), Ananth N Mavinakayanahalli wrote:
> > On Wed, May 07, 2014 at 08:55:51PM +0900, Masami Hiramatsu wrote:
> > 
> > ...
> > 
> >> +#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF = 1)
> >> +/*
> >> + * On PPC64 ABIv1 the function pointer actually points to the
> >> + * function's descriptor. The first entry in the descriptor is the
> >> + * address of the function text.
> >> + */
> >> +#define constant_function_entry(fn)	(((func_descr_t *)(fn))->entry)
> >> +#else
> >> +#define constant_function_entry(fn)	((unsigned long)(fn))
> >> +#endif
> >> +
> >>  #endif /* __ASSEMBLY__ */
> > 
> > Hi Masami,
> > 
> > You could just use ppc_function_entry() instead.
> 
> No, I think ppc_function_entry() has two problems (on the latest -next kernel)
> 
> At first, that is an inlined functions which is not applied in build time.
> Since the NOKPROBE_SYMBOL() is used outside of any functions as like as
> EXPORT_SYMBOL(), we can only use preprocessed macros.
> Next, on PPC64 ABI*v2*, ppc_function_entry() returns local function entry,
> which seems global function entry + 2 insns. I'm not sure about implementation
> of the kallsyms on PPC64 ABIv2, but I guess we need global function entry
> for kallsyms.

ABIv2 does away with function descriptors and Anton fixed up that
routine to handle the change (the +2 is an artefact of that).

> BTW, could you test this patch on the latest -next tree on PPC64 if possible?

I'll test it, but it may take a bit.

Ananth

