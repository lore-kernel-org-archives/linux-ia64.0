From: Marco Elver <elver@google.com>
Date: Tue, 07 Jun 2022 13:43:49 +0000
Subject: Re: [PATCH 3/6] bitops: define gen_test_bit() the same way as the rest of functions
Message-Id: <Yp9WFREfdfkho0hm@elver.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220606114908.962562-1-alexandr.lobakin@intel.com>
 <20220606114908.962562-4-alexandr.lobakin@intel.com>
In-Reply-To: <20220606114908.962562-4-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Richard Henderson <rth@twiddle.net>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jun 06, 2022 at 01:49PM +0200, Alexander Lobakin wrote:
> Currently, the generic test_bit() function is defined as a one-liner
> and in case with constant bitmaps the compiler is unable to optimize
> it to a constant. At the same time, gen_test_and_*_bit() are being
> optimized pretty good.
> Define gen_test_bit() the same way as they are defined.
> 
> Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
> ---
>  include/asm-generic/bitops/generic-non-atomic.h | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/asm-generic/bitops/generic-non-atomic.h b/include/asm-generic/bitops/generic-non-atomic.h
> index 7a60adfa6e7d..202d8a3b40e1 100644
> --- a/include/asm-generic/bitops/generic-non-atomic.h
> +++ b/include/asm-generic/bitops/generic-non-atomic.h
> @@ -118,7 +118,11 @@ gen___test_and_change_bit(unsigned int nr, volatile unsigned long *addr)
>  static __always_inline int
>  gen_test_bit(unsigned int nr, const volatile unsigned long *addr)
>  {
> -	return 1UL & (addr[BIT_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
> +	const unsigned long *p = (const unsigned long *)addr + BIT_WORD(nr);
> +	unsigned long mask = BIT_MASK(nr);
> +	unsigned long val = *p;
> +
> +	return !!(val & mask);

Unfortunately this makes the dereference of 'addr' non-volatile, and
effectively weakens test_bit() to the point where I'd no longer consider
it atomic. Per atomic_bitops.txt, test_bit() is atomic.

The generic version has been using a volatile access to make it atomic
(akin to generic READ_ONCE() casting to volatile). The volatile is also
the reason the compiler can't optimize much, because volatile forces a
real memory access.

Yes, confusingly, test_bit() lives in non-atomic.h, and this had caused
confusion before, but the decision was made that moving it will cause
headaches for ppc so it was left alone:
https://lore.kernel.org/all/87a78xgu8o.fsf@dja-thinkpad.axtens.net/T/#u

As for how to make test_bit() more compiler-optimization friendly, I'm
guessing that test_bit() needs some special casing where even the
generic arch_test_bit() is different from the gen_test_bit().
gen_test_bit() should probably assert that whatever it is called with
can actually be evaluated at compile-time so it is never accidentally
used otherwise.

I would also propose adding a comment close to the deref that test_bit()
is atomic and the deref needs to remain volatile, so future people will
not try to do the same optimization.

Thanks,
-- Marco
