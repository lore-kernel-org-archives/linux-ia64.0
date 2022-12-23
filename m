From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Fri, 23 Dec 2022 14:23:00 +0000
Subject: Re: [PATCH 00/19] Introduce __xchg, non-atomic xchg
Message-Id: <20221223142300.1820652-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221222114635.1251934-1-andrzej.hajda@intel.com> <20221222092147.d2bb177c67870884f2e59a9b@linux-foundation.org>
In-Reply-To: <20221222092147.d2bb177c67870884f2e59a9b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Andrzej Hajda <andrzej.hajda@intel.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@vger.kernel.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Arnd Bergmann <arnd@arndb.de>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, Mark Rutland <mark.rutland@arm.com>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 22 Dec 2022 09:21:47 -0800

> On Thu, 22 Dec 2022 12:46:16 +0100 Andrzej Hajda <andrzej.hajda@intel.com> wrote:
> 
> > Hi all,
> > 
> > I hope there will be place for such tiny helper in kernel.
> > Quick cocci analyze shows there is probably few thousands places
> > where it could be useful.
> 
> So to clarify, the intent here is a simple readability cleanup for
> existing open-coded exchange operations.  The intent is *not* to
> identify existing xchg() sites which are unnecessarily atomic and to
> optimize them by using the non-atomic version.
> 
> Have you considered the latter?
> 
> > I am not sure who is good person to review/ack such patches,
> 
> I can take 'em.
> 
> > so I've used my intuition to construct to/cc lists, sorry for mistakes.
> > This is the 2nd approach of the same idea, with comments addressed[0].
> > 
> > The helper is tiny and there are advices we can leave without it, so
> > I want to present few arguments why it would be good to have it:
> > 
> > 1. Code readability/simplification/number of lines:
> > 
> > Real example from drivers/net/ethernet/mellanox/mlx5/core/esw/qos.c:
> > -       previous_min_rate = evport->qos.min_rate;
> > -       evport->qos.min_rate = min_rate;
> > +       previous_min_rate = __xchg(evport->qos.min_rate, min_rate);
> > 
> > For sure the code is more compact, and IMHO more readable.
> > 
> > 2. Presence of similar helpers in other somehow related languages/libs:
> > 
> > a) Rust[1]: 'replace' from std::mem module, there is also 'take'
> >     helper (__xchg(&x, 0)), which is the same as private helper in
> >     i915 - fetch_and_zero, see latest patch.
> > b) C++ [2]: 'exchange' from utility header.
> > 
> > If the idea is OK there are still 2 qestions to answer:
> > 
> > 1. Name of the helper, __xchg follows kernel conventions,
> >     but for me Rust names are also OK.
> 
> I like replace(), or, shockingly, exchange().
> 
> But...   Can we simply make swap() return the previous value?
> 
> 	previous_min_rate = swap(&evport->qos.min_rate, min_rate);

Unforunately, swap()'s arguments get passed by names, not as
pointers, so you can't do

	swap(some_ptr, NULL);

 -- pretty common pattern for xchg.

Thanks,
Olek
