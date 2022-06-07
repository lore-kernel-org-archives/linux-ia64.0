From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Tue, 07 Jun 2022 15:47:59 +0000
Subject: Re: [PATCH 0/6] bitops: let optimize out non-atomic bitops on compile-time constants
Message-Id: <20220607154759.43549-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220606114908.962562-1-alexandr.lobakin@intel.com> <CAMuHMdXR0Nu+RENB8rFnJFiW=T0P7Kq_XAG7t1MF=fdyD6pUGw@mail.gmail.com>
In-Reply-To: <CAMuHMdXR0Nu+RENB8rFnJFiW=T0P7Kq_XAG7t1MF=fdyD6pUGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Richard Henderson <rth@twiddle.net>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, alpha <linux-alpha@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 7 Jun 2022 14:45:41 +0200

> Hi Alexander,

Hi!

> 
> On Mon, Jun 6, 2022 at 1:50 PM Alexander Lobakin
> <alexandr.lobakin@intel.com> wrote:
> > While I was working on converting some structure fields from a fixed
> > type to a bitmap, I started observing code size increase not only in
> > places where the code works with the converted structure fields, but
> > also where the converted vars were on the stack. That said, the
> > following code:
> >
> >         DECLARE_BITMAP(foo, BITS_PER_LONG) = { }; // -> unsigned long foo[1];
> >         unsigned long bar = BIT(BAR_BIT);
> >         unsigned long baz = 0;
> >
> >         __set_bit(FOO_BIT, foo);
> >         baz |= BIT(BAZ_BIT);
> >
> >         BUILD_BUG_ON(!__builtin_constant_p(test_bit(FOO_BIT, foo));
> >         BUILD_BUG_ON(!__builtin_constant_p(bar & BAR_BIT));
> >         BUILD_BUG_ON(!__builtin_constant_p(baz & BAZ_BIT));
> >
> > triggers the first assertion on x86_64, which means that the
> > compiler is unable to evaluate it to a compile-time initializer
> > when the architecture-specific bitop is used even if it's obvious.
> > I found that this is due to that many architecture-specific
> > non-atomic bitop implementations use inline asm or other hacks which
> > are faster or more robust when working with "real" variables (i.e.
> > fields from the structures etc.), but the compilers have no clue how
> > to optimize them out when called on compile-time constants.
> >
> > So, in order to let the compiler optimize out such cases, expand the
> > test_bit() and __*_bit() definitions with a compile-time condition
> > check, so that they will pick the generic C non-atomic bitop
> > implementations when all of the arguments passed are compile-time
> > constants, which means that the result will be a compile-time
> > constant as well and the compiler will produce more efficient and
> > simple code in 100% cases (no changes when there's at least one
> > non-compile-time-constant argument).
> > The condition itself:
> >
> > if (
> > __builtin_constant_p(nr) &&     /* <- bit position is constant */
> > __builtin_constant_p(!!addr) && /* <- compiler knows bitmap addr is
> >                                       always either NULL or not */
> > addr &&                         /* <- bitmap addr is not NULL */
> > __builtin_constant_p(*addr)     /* <- compiler knows the value of
> >                                       the target bitmap */
> > )
> >         /* then pick the generic C variant
> > else
> >         /* old code path, arch-specific
> >
> > I also tried __is_constexpr() as suggested by Andy, but it was
> > always returning 0 ('not a constant') for the 2,3 and 4th
> > conditions.
> >
> > The savings on x86_64 with LLVM are insane (.text):
> >
> > $ scripts/bloat-o-meter -c vmlinux.{base,test}
> > add/remove: 72/75 grow/shrink: 182/518 up/down: 53925/-137810 (-83885)
> >
> > $ scripts/bloat-o-meter -c vmlinux.{base,mod}
> > add/remove: 7/1 grow/shrink: 1/19 up/down: 1135/-4082 (-2947)
> >
> > $ scripts/bloat-o-meter -c vmlinux.{base,all}
> > add/remove: 79/76 grow/shrink: 184/537 up/down: 55076/-141892 (-86816)
> 
> Thank you!
> 
> I gave it a try on m68k, and am a bit disappointed seeing an increase
> in code size:
> 
>     add/remove: 49/13 grow/shrink: 279/138 up/down: 6434/-3342 (3092)

Ufff, that sucks =\
Could you please try to compile the following code snippet (with the
series applied)?

	unsigned long map;

	bitmap_zero(&map, BITS_PER_LONG);
	__set_bit(1, &map);
	BUILD_BUG_ON(!__builtin_constant_p(map));

If it fails during the vmlinux linkage, it will mean that on your
architecture/setup the compiler is unable to optimize the generic
implementations to compile-time constants and I'll need to debug
this more (probably via some compiler explorer).
You could also check the vmlinux size after applying each patch
to see which one does this if you feel like it :)

> 
> This is atari_defconfig on a tree based on v5.19-rc1, with
> m68k-linux-gnu-gcc (Ubuntu 9.4.0-1ubuntu1~20.04) 9.4.0, GNU ld (GNU
> Binutils for Ubuntu) 2.34).
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds

Thanks,
Olek
