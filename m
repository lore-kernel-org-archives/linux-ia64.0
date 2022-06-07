From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Tue, 07 Jun 2022 10:57:18 +0000
Subject: Re: [PATCH 5/6] bitops: wrap non-atomic bitops with a transparent macro
Message-Id: <20220607105718.72434-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220606114908.962562-1-alexandr.lobakin@intel.com> <20220606114908.962562-6-alexandr.lobakin@intel.com> <Yp4q5KlIxmlznvuh@FVFF77S0Q05N.cambridge.arm.com>
In-Reply-To: <Yp4q5KlIxmlznvuh@FVFF77S0Q05N.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Rutland <mark.rutland@arm.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Richard Henderson <rth@twiddle.net>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Mark Rutland <mark.rutland@arm.com>
Date: Mon, 6 Jun 2022 17:27:16 +0100

> On Mon, Jun 06, 2022 at 01:49:06PM +0200, Alexander Lobakin wrote:
> > In preparation for altering the non-atomic bitops with a macro, wrap
> > them in a transparent definition. This requires prepending one more
> > '_' to their names in order to be able to do that seamlessly.
> > sparc32 already has the triple-underscored functions, so I had to
> > rename them ('___' -> 'sp32_').
> 
> Could we use an 'arch_' prefix here, like we do for the atomics, or is that
> already overloaded?

Yeah it is, for example, x86 has 'arch_' functions defined in its
architecture headers[0] and at the same time uses generic
instrumented '__' helpers[1], so on x86 both underscored and 'arch_'
are defined and they are not the same.
Same with those sparc32 triple-underscored, sparc32 at the same time
uses generic non-instrumented, so it has underscored, 'arch_' and
triple-underscored.

In general, bitops are overloaded with tons of prefixes already :)
I'm not really glad that I introduced one more level, but not that
we have many options here.

> 
> Thanks,
> Mark.
> 
> > 
> > Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
> > ---

[...]

> > -- 
> > 2.36.1

Thanks,
Olek
