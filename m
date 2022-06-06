From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Mon, 06 Jun 2022 14:21:35 +0000
Subject: Re: [PATCH 2/6] bitops: always define asm-generic non-atomic bitops
Message-Id: <20220606142135.965134-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220606114908.962562-1-alexandr.lobakin@intel.com> <20220606114908.962562-3-alexandr.lobakin@intel.com> <Yp32xDZ/qF8hM6p0@FVFF77S0Q05N>
In-Reply-To: <Yp32xDZ/qF8hM6p0@FVFF77S0Q05N>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Rutland <mark.rutland@arm.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Richard Henderson <rth@twiddle.net>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Mark Rutland <mark.rutland@arm.com>
Date: Mon, 6 Jun 2022 13:44:52 +0100

> On Mon, Jun 06, 2022 at 01:49:03PM +0200, Alexander Lobakin wrote:
> > Move generic non-atomic bitops from the asm-generic header which
> > gets included only when there are no architecture-specific
> > alternatives, to a separate independent file to make them always
> > available.
> > 
> > Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
> > ---
> >  .../asm-generic/bitops/generic-non-atomic.h   | 124 ++++++++++++++++++
> >  include/asm-generic/bitops/non-atomic.h       | 109 ++-------------
> >  2 files changed, 132 insertions(+), 101 deletions(-)
> >  create mode 100644 include/asm-generic/bitops/generic-non-atomic.h
> > 
> > diff --git a/include/asm-generic/bitops/generic-non-atomic.h b/include/asm-generic/bitops/generic-non-atomic.h
> > new file mode 100644
> > index 000000000000..7a60adfa6e7d
> > --- /dev/null
> > +++ b/include/asm-generic/bitops/generic-non-atomic.h
> > @@ -0,0 +1,124 @@
> > +/* SPDX-License-Identifier: GPL-2.0-only */
> > +#ifndef __ASM_GENERIC_BITOPS_GENERIC_NON_ATOMIC_H
> > +#define __ASM_GENERIC_BITOPS_GENERIC_NON_ATOMIC_H
> > +
> > +#include <linux/bits.h>
> > +
> > +#ifndef _LINUX_BITOPS_H
> > +#error only <linux/bitops.h> can be included directly
> > +#endif
> > +
> > +/*
> > + * Generic definitions for bit operations, should not be used in regular code
> > + * directly.
> > + */
> > +
> > +/**
> > + * gen___set_bit - Set a bit in memory
> > + * @nr: the bit to set
> > + * @addr: the address to start counting from
> > + *
> > + * Unlike set_bit(), this function is non-atomic and may be reordered.
> > + * If it's called on the same region of memory simultaneously, the effect
> > + * may be that only one operation succeeds.
> > + */
> > +static __always_inline void
> > +gen___set_bit(unsigned int nr, volatile unsigned long *addr)
> 
> Could we please use 'generic' rather than 'gen' as the prefix?
> 
> That'd match what we did for the generic atomic_*() and atomic64_*() functions
> in commits
> 
> * f8b6455a9d381fc5 ("locking/atomic: atomic: support ARCH_ATOMIC")
> * 1bdadf46eff6804a ("locking/atomic: atomic64: support ARCH_ATOMIC")
> 
> ... and it avoids any potential confusion with 'gen' meaning 'generated' or
> similar.

Sure! Thanks for giving the hint, I do agree it would look better
and will rename in v2.

> 
> Thanks,
> Mark.
> 
> > +{
> > +	unsigned long mask = BIT_MASK(nr);
> > +	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
> > +
> > +	*p  |= mask;
> > +}

[...]

> > -- 
> > 2.36.1

Thanks,
Al
