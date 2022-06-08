From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 08 Jun 2022 09:55:08 +0000
Subject: Re: [PATCH 0/6] bitops: let optimize out non-atomic bitops on compile-time constants
Message-Id: <CAMuHMdUeM_ntgZzmeHVMJ_8neyOSRUa_xDNE46eM7cHt_sDj1g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220606114908.962562-1-alexandr.lobakin@intel.com>
 <CAMuHMdXR0Nu+RENB8rFnJFiW=T0P7Kq_XAG7t1MF=fdyD6pUGw@mail.gmail.com> <20220607154759.43549-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220607154759.43549-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Richard Henderson <rth@twiddle.net>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, alpha <linux-alpha@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Olek,

On Tue, Jun 7, 2022 at 5:51 PM Alexander Lobakin
<alexandr.lobakin@intel.com> wrote:
> From: Geert Uytterhoeven <geert@linux-m68k.org>
> > On Mon, Jun 6, 2022 at 1:50 PM Alexander Lobakin
> > <alexandr.lobakin@intel.com> wrote:
> > > While I was working on converting some structure fields from a fixed
> > > type to a bitmap, I started observing code size increase not only in
> > > places where the code works with the converted structure fields, but
> > > also where the converted vars were on the stack. That said, the
> > > following code:
> > >
> > >         DECLARE_BITMAP(foo, BITS_PER_LONG) = { }; // -> unsigned long foo[1];
> > >         unsigned long bar = BIT(BAR_BIT);
> > >         unsigned long baz = 0;
> > >
> > >         __set_bit(FOO_BIT, foo);
> > >         baz |= BIT(BAZ_BIT);
> > >
> > >         BUILD_BUG_ON(!__builtin_constant_p(test_bit(FOO_BIT, foo));
> > >         BUILD_BUG_ON(!__builtin_constant_p(bar & BAR_BIT));
> > >         BUILD_BUG_ON(!__builtin_constant_p(baz & BAZ_BIT));
> > >
> > > triggers the first assertion on x86_64, which means that the
> > > compiler is unable to evaluate it to a compile-time initializer
> > > when the architecture-specific bitop is used even if it's obvious.
> > > I found that this is due to that many architecture-specific
> > > non-atomic bitop implementations use inline asm or other hacks which
> > > are faster or more robust when working with "real" variables (i.e.
> > > fields from the structures etc.), but the compilers have no clue how
> > > to optimize them out when called on compile-time constants.
> > >
> > > So, in order to let the compiler optimize out such cases, expand the
> > > test_bit() and __*_bit() definitions with a compile-time condition
> > > check, so that they will pick the generic C non-atomic bitop
> > > implementations when all of the arguments passed are compile-time
> > > constants, which means that the result will be a compile-time
> > > constant as well and the compiler will produce more efficient and
> > > simple code in 100% cases (no changes when there's at least one
> > > non-compile-time-constant argument).
> > > The condition itself:
> > >
> > > if (
> > > __builtin_constant_p(nr) &&     /* <- bit position is constant */
> > > __builtin_constant_p(!!addr) && /* <- compiler knows bitmap addr is
> > >                                       always either NULL or not */
> > > addr &&                         /* <- bitmap addr is not NULL */
> > > __builtin_constant_p(*addr)     /* <- compiler knows the value of
> > >                                       the target bitmap */
> > > )
> > >         /* then pick the generic C variant
> > > else
> > >         /* old code path, arch-specific
> > >
> > > I also tried __is_constexpr() as suggested by Andy, but it was
> > > always returning 0 ('not a constant') for the 2,3 and 4th
> > > conditions.
> > >
> > > The savings on x86_64 with LLVM are insane (.text):
> > >
> > > $ scripts/bloat-o-meter -c vmlinux.{base,test}
> > > add/remove: 72/75 grow/shrink: 182/518 up/down: 53925/-137810 (-83885)
> > >
> > > $ scripts/bloat-o-meter -c vmlinux.{base,mod}
> > > add/remove: 7/1 grow/shrink: 1/19 up/down: 1135/-4082 (-2947)
> > >
> > > $ scripts/bloat-o-meter -c vmlinux.{base,all}
> > > add/remove: 79/76 grow/shrink: 184/537 up/down: 55076/-141892 (-86816)
> >
> > Thank you!
> >
> > I gave it a try on m68k, and am a bit disappointed seeing an increase
> > in code size:
> >
> >     add/remove: 49/13 grow/shrink: 279/138 up/down: 6434/-3342 (3092)
>
> Ufff, that sucks =\
> Could you please try to compile the following code snippet (with the
> series applied)?
>
>         unsigned long map;
>
>         bitmap_zero(&map, BITS_PER_LONG);
>         __set_bit(1, &map);
>         BUILD_BUG_ON(!__builtin_constant_p(map));
>
> If it fails during the vmlinux linkage, it will mean that on your
> architecture/setup the compiler is unable to optimize the generic
> implementations to compile-time constants and I'll need to debug
> this more (probably via some compiler explorer).

Builds and links fine.

> You could also check the vmlinux size after applying each patch
> to see which one does this if you feel like it :)

The (incremental) impact of the various patches is shown below:

    bitops: unify non-atomic bitops prototypes across architectures
      add/remove: 4/11 grow/shrink: 123/160 up/down: 1700/-2786 (-1086)

    bitops: let optimize out non-atomic bitops on compile-time constants
      add/remove: 50/7 grow/shrink: 280/101 up/down: 6798/-2620 (4178)

I.e. the total impact is -1086 + 4178 = +3092

Looking at the impact of the last change on a single file, with rather
small functions to make it easier to analyze, the results are:

    bloat-o-meter net/core/sock.o{.orig,}
    add/remove: 3/1 grow/shrink: 20/3 up/down: 286/-68 (218)
    Function                                     old     new   delta
    sock_flag                                      -      38     +38
    sock_set_flag                                  -      22     +22
    sock_reset_flag                                -      22     +22
    sock_recv_errqueue                           264     284     +20
    sock_alloc_send_pskb                         406     424     +18
    __sock_set_timestamps                        104     122     +18
    sock_setsockopt                             2412    2428     +16
    sock_pfree                                    52      66     +14
    sock_wfree                                   236     248     +12
    sk_wait_data                                 222     234     +12
    sk_destruct                                   70      82     +12
    sk_wake_async                                 40      50     +10
    sk_set_memalloc                               74      84     +10
    __sock_queue_rcv_skb                         254     264     +10
    __sk_backlog_rcv                              92     102     +10
    sock_getsockopt                             1734    1742      +8
    sock_no_linger                                36      42      +6
    sk_clone_lock                                478     484      +6
    sk_clear_memalloc                             98     104      +6
    __sk_receive_skb                             194     200      +6
    sock_init_data                               344     348      +4
    __sock_cmsg_send                             196     200      +4
    sk_common_release                            152     154      +2
    sock_set_keepalive                            62      60      -2
    sock_enable_timestamp                         80      72      -8
    sock_valbool_flag                             34      12     -22
    bset_mem_set_bit                              36       -     -36
    Total: Before862, After080, chg +1.16%

Several small inline functions are no longer inlined.
And e.g. __sk_backlog_rcv() increases as it now calls sock_flag()
out-of-line, and needs to save more on the stack:

 __sk_backlog_rcv:
+       move.l %a3,-(%sp)       |,
        move.l %d2,-(%sp)       |,
-       move.l 8(%sp),%a0       | sk, sk
-| arch/m68k/include/asm/bitops.h:163:  return (addr[nr >> 5] & (1UL
<< (nr & 31))) != 0;
-       move.l 76(%a0),%d0      | MEM[(const long unsigned int
*)sk_6(D) + 76B], _14
+       move.l 12(%sp),%a3      | sk, sk
 | net/core/sock.c:330:         BUG_ON(!sock_flag(sk, SOCK_MEMALLOC));
-       btst #14,%d0    |, _14
-       jne .L193               |
+       pea 14.w                |
+       move.l %a3,-(%sp)       | sk,
+       jsr sock_flag           |
+       addq.l #8,%sp   |,
+       tst.b %d0       | tmp50
+       jne .L192               |
        pea 330.w               |
        pea .LC0                |
        pea .LC3                |
        jsr _printk             |
        trap #7

Note that the above is with atari_defconfig, which has
CONFIG_CC_OPTIMIZE_FOR_SIZE=y.

Switching to CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y results in a kernel
that is ca. 25% larger, and the net impact of this series is:

    add/remove: 24/27 grow/shrink: 227/233 up/down: 7494/-8080 (-586)

i.e. a reduction in size...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
