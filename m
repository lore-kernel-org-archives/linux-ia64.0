From: Michael Ellerman <michael@ellerman.id.au>
Date: Wed, 18 Jun 2014 07:56:19 +0000
Subject: Re: [RFT PATCH -next v3] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <1403078179.32307.7.camel@concordia>
List-Id: <linux-ia64.vger.kernel.org>
References: <5387F150.5000307@hitachi.com>
	 <20140530031838.17427.75896.stgit@ltc230.yrl.intra.hitachi.co.jp>
	 <539161D6.7020508@hitachi.com>
In-Reply-To: <539161D6.7020508@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Suzuki K. Poulose" <suzuki@in.ibm.com>, Tony Luck <tony.luck@gmail.com>, Paul Mackerras <paulus@samba.org>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, akataria@vmware.com, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Fri, 2014-06-06 at 15:38 +0900, Masami Hiramatsu wrote:
> Ping?
> 
> I guess this should go to 3.16 branch, shouldn't it?

> > diff --git a/arch/powerpc/include/asm/types.h b/arch/powerpc/include/asm/types.h
> > index bfb6ded..8b89d65 100644
> > --- a/arch/powerpc/include/asm/types.h
> > +++ b/arch/powerpc/include/asm/types.h
> > @@ -25,6 +25,17 @@ typedef struct {
> >  	unsigned long env;
> >  } func_descr_t;
> >  
> > +#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF = 1)
> > +/*
> > + * On PPC64 ABIv1 the function pointer actually points to the
> > + * function's descriptor. The first entry in the descriptor is the
> > + * address of the function text.
> > + */
> > +#define function_entry(fn)	(((func_descr_t *)(fn))->entry)
> > +#else
> > +#define function_entry(fn)	((unsigned long)(fn))
> > +#endif

We already have ppc_function_entry(), can't you use that?

cheers


