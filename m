From: Finn Thain <fthain@telegraphics.com.au>
Date: Fri, 09 Oct 2020 22:21:38 +0000
Subject: Re: [RFC 13/13] m68k: mac: convert to generic clockevent
Message-Id: <alpine.LNX.2.23.453.2010091900150.12@nippy.intranet>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-14-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-14-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-arm-kernel@lists.infradead.org

Hi Arnd,

Perhaps patch 13 does not belong in this series (?).

All m68k platforms will need conversion before the TODO can be removed 
from Documentation/features/time/clockevents/arch-support.txt.

On m68k, HZ is fixed at 100. Without addressing that, would there be any 
benefit from adopting GENERIC_CLOCKEVENTS as per this RFC patch?

On Thu, 8 Oct 2020, Arnd Bergmann wrote:

> Now that the infrastructure allows kernels to have both legacy timer 
> ticks and clockevent drivers in the same image, start by moving one 
> platform to generic clockevents.
> 
> As qemu only supports the q800 platform among the classic m68k, use that 
> as an example.
> 

Correct VIA emulation is suprisingly difficult, so this kind of work 
should be tested on real hardware.

I say that because when I did the clocksource conversion for m68k I ran 
into a bug in QEMU (since fixed) and also because I once worked on some of 
the bugs in the emulated VIA device used in MAME/MESS.

> I also tried adding oneshot mode, which was successful but broke the 
> clocksource. It's probably not hard to make it work properly, but this 
> is where I've stopped.
> 

I'm not so sure that one timer is able to support both a clocksource 
driver and a clockevent driver. In some cases we may have to drop the 
clocksource driver (i.e. fall back on the jiffies clocksource).

Anyway, even on Macs with only one VIA chip we still have two timers. So I 
think we should try to use Timer 1 as a freerunning clocksource and Timer 
2 as a oneshot clock event. This may result in better accuracy and simpler 
code. This may require some experimentation though.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> I have never tried implementing a clockevent or clocksource
> driver in the past, so this is really just an experiment and
> I expect I got something wrong.
> 

Writing clockevent drivers is new to me too. I'm still trying to discover 
what the implications might be if the only available clockevent device 
offers oneshot mode or periodic mode but not both.
