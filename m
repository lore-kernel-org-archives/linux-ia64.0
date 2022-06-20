From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 20 Jun 2022 12:07:27 +0000
Subject: Re: [PATCH v3 0/7] bitops: let optimize out non-atomic bitops on compile-time constants
Message-Id: <CAMuHMdXYmtTf=e++fArH4K=vUtRxFd6=toD8An5KxrkRDkkOwg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220617144031.2549432-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220617144031.2549432-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, alpha <linux-alpha@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Olek,

On Fri, Jun 17, 2022 at 6:51 PM Alexander Lobakin
<alexandr.lobakin@intel.com> wrote:
> While I was working on converting some structure fields from a fixed
> type to a bitmap, I started observing code size increase not only in
> places where the code works with the converted structure fields, but
> also where the converted vars were on the stack. That said, the
> following code:
>
>         DECLARE_BITMAP(foo, BITS_PER_LONG) = { }; // -> unsigned long foo[1];
>         unsigned long bar = BIT(BAR_BIT);
>         unsigned long baz = 0;
>
>         __set_bit(FOO_BIT, foo);
>         baz |= BIT(BAZ_BIT);
>
>         BUILD_BUG_ON(!__builtin_constant_p(test_bit(FOO_BIT, foo));
>         BUILD_BUG_ON(!__builtin_constant_p(bar & BAR_BIT));
>         BUILD_BUG_ON(!__builtin_constant_p(baz & BAZ_BIT));
>
> triggers the first assertion on x86_64, which means that the
> compiler is unable to evaluate it to a compile-time initializer
> when the architecture-specific bitop is used even if it's obvious.
> I found that this is due to that many architecture-specific
> non-atomic bitop implementations use inline asm or other hacks which
> are faster or more robust when working with "real" variables (i.e.
> fields from the structures etc.), but the compilers have no clue how
> to optimize them out when called on compile-time constants.
>
> So, in order to let the compiler optimize out such cases, expand the
> test_bit() and __*_bit() definitions with a compile-time condition
> check, so that they will pick the generic C non-atomic bitop
> implementations when all of the arguments passed are compile-time
> constants, which means that the result will be a compile-time
> constant as well and the compiler will produce more efficient and
> simple code in 100% cases (no changes when there's at least one
> non-compile-time-constant argument).
> The condition itself:
>
> if (
> __builtin_constant_p(nr) &&     /* <- bit position is constant */
> __builtin_constant_p(!!addr) && /* <- compiler knows bitmap addr is
>                                       always either NULL or not */
> addr &&                         /* <- bitmap addr is not NULL */
> __builtin_constant_p(*addr)     /* <- compiler knows the value of
>                                       the target bitmap */
> )
>         /* then pick the generic C variant
> else
>         /* old code path, arch-specific
>
> I also tried __is_constexpr() as suggested by Andy, but it was
> always returning 0 ('not a constant') for the 2,3 and 4th
> conditions.
>
> The savings are architecture, compiler and compiler flags dependent,
> for example, on x86_64 -O2:
>
> GCC 12: add/remove: 78/29 grow/shrink: 332/525 up/down: 31325/-61560 (-30235)
> LLVM 13: add/remove: 79/76 grow/shrink: 184/537 up/down: 55076/-141892 (-86816)
> LLVM 14: add/remove: 10/3 grow/shrink: 93/138 up/down: 3705/-6992 (-3287)
>
> and ARM64 (courtesy of Mark[0]):
>
> GCC 11: add/remove: 92/29 grow/shrink: 933/2766 up/down: 39340/-82580 (-43240)
> LLVM 14: add/remove: 21/11 grow/shrink: 620/651 up/down: 12060/-15824 (-3764)
>
> And the following:
>
>         DECLARE_BITMAP(flags, __IP_TUNNEL_FLAG_NUM) = { };
>         __be16 flags;
>
>         __set_bit(IP_TUNNEL_CSUM_BIT, flags);
>
>         tun_flags = cpu_to_be16(*flags & U16_MAX);
>
>         if (test_bit(IP_TUNNEL_VTI_BIT, flags))
>                 tun_flags |= VTI_ISVTI;
>
>         BUILD_BUG_ON(!__builtin_constant_p(tun_flags));
>
> doesn't blow up anymore (which is being checked now at build time),
> so that we can now e.g. use fixed bitmaps in compile-time assertions
> etc.
>
> The series has been in intel-next for a while with no reported issues.
>
> From v2[1]:
> * collect several Reviewed-bys (Andy, Yury);
> * add a comment to generic_test_bit() that it is atomic-safe and
>   must always stay like that (the first version of this series
>   errorneously tried to change this) (Andy, Marco);
> * unify the way how architectures define platform-specific bitops,
>   both supporting instrumentation and not: now they define only
>   'arch_' versions and asm-generic includes take care of the rest;
> * micro-optimize the diffstat of 0004/0007 (__check_bitop_pr())
>   (Andy);
> * add compile-time tests to lib/test_bitmap to make sure everything
>   works as expected on any setup (Yury).

Thanks for the update!

Still seeing
add/remove: 49/13 grow/shrink: 280/137 up/down: 6464/-3328 (3136)

on m68k atari_defconfig (i.e.CONFIG_CC_OPTIMIZE_FOR_SIZE=y)
with gcc version 9.4.0 (Ubuntu 9.4.0-1ubuntu1~20.04).

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
