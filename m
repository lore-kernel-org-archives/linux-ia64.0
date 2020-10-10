From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 10 Oct 2020 18:52:01 +0000
Subject: Re: [RFC 13/13] m68k: mac: convert to generic clockevent
Message-Id: <CAK8P3a3rM7gJjdTtcKzr6yi15n6xs-yhEpmSOf3QHfahQwxqkw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-14-arnd@arndb.de>
 <alpine.LNX.2.23.453.2010091900150.12@nippy.intranet>
In-Reply-To: <alpine.LNX.2.23.453.2010091900150.12@nippy.intranet>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Finn Thain <fthain@telegraphics.com.au>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Sat, Oct 10, 2020 at 12:21 AM Finn Thain <fthain@telegraphics.com.au> wrote:
>
> Hi Arnd,
>
> Perhaps patch 13 does not belong in this series (?).
>
> All m68k platforms will need conversion before the TODO can be removed
> from Documentation/features/time/clockevents/arch-support.txt.

Yes, correct. I marked this patch as RFC instead of PATCH, as I'm
just trying to find out where it should be headed. I would hope the
other patches can just get merged.

> On m68k, HZ is fixed at 100. Without addressing that, would there be any
> benefit from adopting GENERIC_CLOCKEVENTS as per this RFC patch?

I don't think so, I mainly did it to see if there is a problem with mixing
the two modes, and I couldn't find any. The behavior seems unchanged
before and after my patch, the main difference being a few extra kilobytes
in kernel .text for the generic clockevents code.

> On Thu, 8 Oct 2020, Arnd Bergmann wrote:
>
> > Now that the infrastructure allows kernels to have both legacy timer
> > ticks and clockevent drivers in the same image, start by moving one
> > platform to generic clockevents.
> >
> > As qemu only supports the q800 platform among the classic m68k, use that
> > as an example.
> >
>
> Correct VIA emulation is suprisingly difficult, so this kind of work
> should be tested on real hardware.
>
> I say that because when I did the clocksource conversion for m68k I ran
> into a bug in QEMU (since fixed) and also because I once worked on some of
> the bugs in the emulated VIA device used in MAME/MESS.

Good point, though I would be surprised if anything went wrong with
this patch on real hardware but not in emulation, as all the register-level
interactions with the timer are the same.

Adding oneshot mode is a completely different matter though, that
clearly needs to be tested on real hardware.

> > I also tried adding oneshot mode, which was successful but broke the
> > clocksource. It's probably not hard to make it work properly, but this
> > is where I've stopped.
> >
>
> I'm not so sure that one timer is able to support both a clocksource
> driver and a clockevent driver. In some cases we may have to drop the
> clocksource driver (i.e. fall back on the jiffies clocksource).
>
> Anyway, even on Macs with only one VIA chip we still have two timers. So I
> think we should try to use Timer 1 as a freerunning clocksource and Timer
> 2 as a oneshot clock event. This may result in better accuracy and simpler
> code. This may require some experimentation though.

Ah, good. This is partly what I had been hoping for, as my patch
can be used as a starting point for that if you want to give it a go.

     Arnd
