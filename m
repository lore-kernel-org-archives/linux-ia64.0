From: Finn Thain <fthain@telegraphics.com.au>
Date: Sun, 18 Oct 2020 00:54:54 +0000
Subject: Re: [RFC 13/13] m68k: mac: convert to generic clockevent
Message-Id: <alpine.LNX.2.23.453.2010180810010.6@nippy.intranet>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-14-arnd@arndb.de> <alpine.LNX.2.23.453.2010091900150.12@nippy.intranet> <CAK8P3a3rM7gJjdTtcKzr6yi15n6xs-yhEpmSOf3QHfahQwxqkw@mail.gmail.com> <alpine.LNX.2.23.453.2010150937430.16@nippy.intranet>
 <CAK8P3a2ymv79j1edtJ983-VgjtxvT_6co7V0VRnHzcneW+0ZtA@mail.gmail.com>
In-Reply-To: <CAK8P3a2ymv79j1edtJ983-VgjtxvT_6co7V0VRnHzcneW+0ZtA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Thu, 15 Oct 2020, Arnd Bergmann wrote:

> On Thu, Oct 15, 2020 at 3:19 AM Finn Thain <fthain@telegraphics.com.au> wrote:
> >
> > On Sat, 10 Oct 2020, Arnd Bergmann wrote:
> >
> > > > Perhaps patch 13 does not belong in this series (?).
> > > >
> > > > All m68k platforms will need conversion before the TODO can be removed
> > > > from Documentation/features/time/clockevents/arch-support.txt.
> > >
> > > Yes, correct. I marked this patch as RFC instead of PATCH, as I'm just
> > > trying to find out where it should be headed. I would hope the other
> > > patches can just get merged.
> > >
> >
> > I wonder whether we can improve support for your proposed configuration
> > i.e. a system with no oneshot clockevent device.
> >
> > The 16 platforms you identified are not all in that category but I suspect
> > that there are others which are (though they don't appear in this series
> > because they already use GENERIC_CLOCKEVENTS).
> >
> > One useful optimization would be some way to elide oneshot clockevent
> > support (perhaps with the help of Link Time Optimization).
> 
> I think this already happens if one picks CONFIG_HZ_PERIODIC while
> disabling HIGH_RES_TIMERS. In that case, CONFIG_TICK_ONESHOT
> remains disabled.
> 

That configuration still produces the same 5 KiB of bloat. I see that 
kernel/time/Kconfig has this --

# Core internal switch. Selected by NO_HZ_COMMON / HIGH_RES_TIMERS. This is
# only related to the tick functionality. Oneshot clockevent devices
# are supported independent of this.
config TICK_ONESHOT
        bool

But my question was really about both kinds of dead code (oneshot device 
support and oneshot tick support). Anyway, after playing with the code for 
a bit I don't see any easy way to reduce the growth in text size.

> ...
> > After looking at the chip documentation I don't think it's viable to 
> > use the hardware timers in the way I proposed. A VIA register access 
> > requires at least one full VIA clock cycle (about 1.3 us) which means 
> > register accesses themselves cause timing delays. They also make 
> > clocksource reads expensive.
> >
> > I think this rules out oneshot clockevent devices because if the 
> > system offered such a device it would preferentially get used as a 
> > tick device.
> >
> > So I think your approach (periodic clockevent device driven by the 
> > existing periodic tick interrupt) is best for this platform due to 
> > simplicity (not much code) and performance (good accuracy, no 
> > additional overhead).
> 
> Yes, makes sense. I think the one remaining problem with the periodic 
> mode in this driver is that it can drop timer ticks when interrupts are 
> disabled for too long, while in oneshot mode there may be a way to know 
> how much time has passed since the last tick as long as the counter does 
> not overflow.

Is there any benefit from adopting a oneshot tick (rather than periodic) 
if no clocksource is consulted when calculating the next interval? (I'm 
assuming NO_HZ is not in use, for reasons discussed below.)

> I would agree that despite this oneshot mode is probably worse overall 
> for timekeeping if the register accesses introduce systematic errors.
> 

It probably has to be tried. But consulting a VIA clocksource on every 
tick would be expensive on this platform, so if that was the only way to 
avoid cumulative errors, I'd probably just stick with the periodic tick.

> ...
> The arm/rpc timer seems to be roughly in the same category as most of 
> the m68k ones or the i8253 counter on a PC. It's possible that some of 
> them could use the same logic as drivers/clocksource/i8253.o as long as 
> there is any hardware oneshot mode.
> 

There appear to be 15 platforms in that category. 4 have no clocksource 
besides the jiffies clocksource, meaning there's no practical alternative 
to using a periodic tick, like you did in your RFC patch:

arch/m68k/apollo/config.c
arch/m68k/q40/q40ints.c
arch/m68k/sun3/sun3ints.c
arch/m68k/sun3x/time.c

The other 11 platforms in that category also have 'synthetic' clocksources 
derived from a timer reload interrupt. In 3 cases, the clocksource read 
method does not (or can not) check for a pending counter reload interrupt. 
For these also, I see no practical alternative to the approach you've 
taken in your RFC patch:

arch/m68k/68000/timers.c
arch/m68k/atari/time.c
arch/m68k/coldfire/timers.c

That leaves 8 platforms that have reliable clocksource devices which 
should be able to provide an accurate reading even in the presence of a 
dropped tick (due to drivers disabling interrupts for too long):

arch/arm/mach-rpc/time.c
arch/m68k/amiga/config.c
arch/m68k/bvme6000/config.c
arch/m68k/coldfire/sltimers.c
arch/m68k/hp300/time.c
arch/m68k/mac/via.c
arch/m68k/mvme147/config.c
arch/m68k/mvme16x/config.c

But is there any reason to adopt a oneshot tick on any of these platforms, 
if NO_HZ won't eliminate the timer interrupt that's needed to run a 
'synthetic' clocksource?
