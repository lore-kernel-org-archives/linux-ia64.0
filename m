From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun, 25 Oct 2020 12:45:52 +0000
Subject: Re: [RFC 13/13] m68k: mac: convert to generic clockevent
Message-Id: <CAMuHMdWoxWGkq_=AbGZxU=UFASBH3qT0ANqgTzLOZxjjjmYqQA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-14-arnd@arndb.de>
 <alpine.LNX.2.23.453.2010091900150.12@nippy.intranet> <CAK8P3a3rM7gJjdTtcKzr6yi15n6xs-yhEpmSOf3QHfahQwxqkw@mail.gmail.com>
 <alpine.LNX.2.23.453.2010150937430.16@nippy.intranet> <CAK8P3a3i6cum_9xGgsbxjXXvbRsP8Po5qLZ0Agb3c4gZTKC9GQ@mail.gmail.com>
 <CAMuHMdUyGH=ORa4yHivMeJZaGQ3kEXi1kr9=P+u1y3QQnC+-4g@mail.gmail.com>
In-Reply-To: <CAMuHMdUyGH=ORa4yHivMeJZaGQ3kEXi1kr9=P+u1y3QQnC+-4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Finn Thain <fthain@telegraphics.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Fri, Oct 23, 2020 at 11:24 AM Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> On Fri, Oct 23, 2020 at 9:52 AM Arnd Bergmann <arnd@kernel.org> wrote:
> > On Sun, Oct 18, 2020 at 2:55 AM Finn Thain <fthain@telegraphics.com.au> wrote:
> > > On Thu, 15 Oct 2020, Arnd Bergmann wrote:
> > > > On Thu, Oct 15, 2020 at 3:19 AM Finn Thain <fthain@telegraphics.com.au> wrote:
> > > > > On Sat, 10 Oct 2020, Arnd Bergmann wrote:
> > >
> > > That configuration still produces the same 5 KiB of bloat. I see that
> > > kernel/time/Kconfig has this --
> > >
> > > # Core internal switch. Selected by NO_HZ_COMMON / HIGH_RES_TIMERS. This is
> > > # only related to the tick functionality. Oneshot clockevent devices
> > > # are supported independent of this.
> > > config TICK_ONESHOT
> > >         bool
> > >
> > > But my question was really about both kinds of dead code (oneshot device
> > > support and oneshot tick support). Anyway, after playing with the code for
> > > a bit I don't see any easy way to reduce the growth in text size.
> >
> > Did you look more deeply into where those 5KB are? Is this just
> > the code in kernel/time/{clockevents,tick-common}.c and the
> > added platform specific bits, or is there something more?
> > I suppose the sysfs interface and the clockevents_update_freq()
> > logic are not really needed on m68k, but it wouldn't make much
> > sense to split those out either.
> >
> > How does the 5KB bloat compare to the average bloat we get
> > from one release to the next? Geert has been collecting statistics
> > for this.
>
> It would be a fair share of the typical increase of ca. 30 KiB per
> kernel release. Still, it would be lost in the noise of the increase for
> v5.10-rc1:
>
>     add/remove: 1200/455 grow/shrink: 1419/821 up/down: 468970/-93714 (375256)
>     Function                                     old     new   delta
>     _printk_rb_static_infos                        -  180224 +180224
>     write_buf                                   8192   32768  +24576
>     _printk_rb_static_descs                        -   24576  +24576
>     HUF_decompress4X4_usingDTable_internal         -    5664   +5664
>     HUF_decompress4X2_usingDTable_internal         -    5006   +5006
>     __ext4_ioctl                                   -    4774   +4774
>     sock_ops_convert_ctx_access                 3840    8462   +4622
>     ZSTD_decompressSequences                       -    3100   +3100

FTR, 3.9 KiB reclaimed by upgrading from gcc 8.4.0 in Ubuntu 18.04LTS to
gcc 9.3.0 in Ubuntu 20.04LTS.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
