From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Tue, 07 Jun 2022 11:03:10 +0000
Subject: Re: [PATCH 4/6] bitops: unify non-atomic bitops prototypes across architectures
Message-Id: <20220607110310.72649-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220606114908.962562-1-alexandr.lobakin@intel.com> <20220606114908.962562-5-alexandr.lobakin@intel.com> <Yp5oMmzNlq+Ut4So@yury-laptop>
In-Reply-To: <Yp5oMmzNlq+Ut4So@yury-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yury Norov <yury.norov@gmail.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Richard Henderson <rth@twiddle.net>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Yury Norov <yury.norov@gmail.com>
Date: Mon, 6 Jun 2022 13:48:50 -0700

> On Mon, Jun 06, 2022 at 01:49:05PM +0200, Alexander Lobakin wrote:
> > Currently, there is a mess with the prototypes of the non-atomic
> > bitops across the different architectures:
> > 
> > ret	bool, int, unsigned long
> > nr	int, long, unsigned int, unsigned long
> > addr	volatile unsigned long *, volatile void *
> > 
> > Thankfully, it doesn't provoke any bugs, but can sometimes make
> > the compiler angry when it's not handy at all.
> > Adjust all the prototypes to the following standard:
> > 
> > ret	bool				retval can be only 0 or 1
> > nr	unsigned long			native; signed makes no sense
> > addr	volatile unsigned long *	bitmaps are arrays of ulongs
> > 
> > Finally, add some static assertions in order to prevent people from
> > making a mess in this room again.
> > I also used the %__always_inline attribute consistently they always
> > get resolved to the actual operations.
> > 
> > Suggested-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
> > ---
> 
> Reviewed-by: Yury Norov <yury.norov@gmail.com>
> 
> [...]
> 
> > diff --git a/include/linux/bitops.h b/include/linux/bitops.h
> > index 7aaed501f768..5520ac9b1c24 100644
> > --- a/include/linux/bitops.h
> > +++ b/include/linux/bitops.h
> > @@ -26,12 +26,25 @@ extern unsigned int __sw_hweight16(unsigned int w);
> >  extern unsigned int __sw_hweight32(unsigned int w);
> >  extern unsigned long __sw_hweight64(__u64 w);
> >  
> > +#include <asm-generic/bitops/generic-non-atomic.h>
> > +
> >  /*
> >   * Include this here because some architectures need generic_ffs/fls in
> >   * scope
> >   */
> >  #include <asm/bitops.h>
> >  
> > +/* Check that the bitops prototypes are sane */
> > +#define __check_bitop_pr(name)	static_assert(__same_type(name, gen_##name))
> > +__check_bitop_pr(__set_bit);
> > +__check_bitop_pr(__clear_bit);
> > +__check_bitop_pr(__change_bit);
> > +__check_bitop_pr(__test_and_set_bit);
> > +__check_bitop_pr(__test_and_clear_bit);
> > +__check_bitop_pr(__test_and_change_bit);
> > +__check_bitop_pr(test_bit);
> > +#undef __check_bitop_pr
> 
> This one is amazing trick! And the series is good overall. Do you want me to
> take it in bitmap tree, when it's ready, or you'll move it somehow else?

Thanks :) Yeah I'm glad we can use __same_type() (->
__builtin_types_compatible_p()) for functions as well, it simplifies
keeping the prototypes unified a lot.

I'm fine with either your bitmap tree or Arnd's asm-generic tree, so
it was my question which I happily forgot to ask: which of those two
is preferred for the series.

> 
> Thanks,
> Yury

Thanks,
Olek
