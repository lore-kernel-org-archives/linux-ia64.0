From: Finn Thain <fthain@telegraphics.com.au>
Date: Thu, 15 Oct 2020 01:18:57 +0000
Subject: Re: [RFC 13/13] m68k: mac: convert to generic clockevent
Message-Id: <alpine.LNX.2.23.453.2010150937430.16@nippy.intranet>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-14-arnd@arndb.de> <alpine.LNX.2.23.453.2010091900150.12@nippy.intranet> <CAK8P3a3rM7gJjdTtcKzr6yi15n6xs-yhEpmSOf3QHfahQwxqkw@mail.gmail.com>
In-Reply-To: <CAK8P3a3rM7gJjdTtcKzr6yi15n6xs-yhEpmSOf3QHfahQwxqkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Sat, 10 Oct 2020, Arnd Bergmann wrote:

> > Perhaps patch 13 does not belong in this series (?).
> >
> > All m68k platforms will need conversion before the TODO can be removed 
> > from Documentation/features/time/clockevents/arch-support.txt.
> 
> Yes, correct. I marked this patch as RFC instead of PATCH, as I'm just 
> trying to find out where it should be headed. I would hope the other 
> patches can just get merged.
> 

I wonder whether we can improve support for your proposed configuration 
i.e. a system with no oneshot clockevent device.

The 16 platforms you identified are not all in that category but I suspect 
that there are others which are (though they don't appear in this series 
because they already use GENERIC_CLOCKEVENTS).

One useful optimization would be some way to elide oneshot clockevent 
support (perhaps with the help of Link Time Optimization).

> > On m68k, HZ is fixed at 100. Without addressing that, would there be 
> > any benefit from adopting GENERIC_CLOCKEVENTS as per this RFC patch?
> 
> I don't think so, I mainly did it to see if there is a problem with 
> mixing the two modes, and I couldn't find any. The behavior seems 
> unchanged before and after my patch, the main difference being a few 
> extra kilobytes in kernel .text for the generic clockevents code.
> 

I think that is a good reason to convert all m68k platforms at once and to 
elide some of the dead code.

> > On Thu, 8 Oct 2020, Arnd Bergmann wrote:
> >
> > > Now that the infrastructure allows kernels to have both legacy timer 
> > > ticks and clockevent drivers in the same image, start by moving one 
> > > platform to generic clockevents.
> > >
> > > As qemu only supports the q800 platform among the classic m68k, use 
> > > that as an example.
> > >
> >
> > Correct VIA emulation is suprisingly difficult, so this kind of work 
> > should be tested on real hardware.
> >
> > I say that because when I did the clocksource conversion for m68k I 
> > ran into a bug in QEMU (since fixed) and also because I once worked on 
> > some of the bugs in the emulated VIA device used in MAME/MESS.
> 
> Good point, though I would be surprised if anything went wrong with this 
> patch on real hardware but not in emulation, as all the register-level 
> interactions with the timer are the same.
> 

On the subject of register accesses, via1[ACR] is shared with ADB drivers, 
so this patch probably has to protect those accesses with 
local_irq_save/restore or local_irq_disable/enable. (I can't be sure of 
the contexts in which .set_state_shutdown and .set_state_periodic methods 
are called.)

> Adding oneshot mode is a completely different matter though, that 
> clearly needs to be tested on real hardware.
> 

Right, and many emulators trade-off timing accuracy for performance which 
makes them unsuitable for testing invasive changes of that sort.

> > > I also tried adding oneshot mode, which was successful but broke the 
> > > clocksource. It's probably not hard to make it work properly, but 
> > > this is where I've stopped.
> > >
> >
> > I'm not so sure that one timer is able to support both a clocksource 
> > driver and a clockevent driver. In some cases we may have to drop the 
> > clocksource driver (i.e. fall back on the jiffies clocksource).
> >
> > Anyway, even on Macs with only one VIA chip we still have two timers. 
> > So I think we should try to use Timer 1 as a freerunning clocksource 
> > and Timer 2 as a oneshot clock event. This may result in better 
> > accuracy and simpler code. This may require some experimentation 
> > though.
> 
> Ah, good. This is partly what I had been hoping for, as my patch can be 
> used as a starting point for that if you want to give it a go.
> 

After looking at the chip documentation I don't think it's viable to use 
the hardware timers in the way I proposed. A VIA register access requires 
at least one full VIA clock cycle (about 1.3 us) which means register 
accesses themselves cause timing delays. They also make clocksource reads 
expensive.

I think this rules out oneshot clockevent devices because if the system 
offered such a device it would preferentially get used as a tick device.

So I think your approach (periodic clockevent device driven by the 
existing periodic tick interrupt) is best for this platform due to 
simplicity (not much code) and performance (good accuracy, no additional 
overhead).

I suspect the same approach would work equally well on other platforms too 
(even though they are probably be capable of oneshot clockevent devices).

>      Arnd
> 
