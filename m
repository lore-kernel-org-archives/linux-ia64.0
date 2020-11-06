From: Finn Thain <fthain@telegraphics.com.au>
Date: Fri, 06 Nov 2020 03:12:08 +0000
Subject: Re: [RFC 13/13] m68k: mac: convert to generic clockevent
Message-Id: <alpine.LNX.2.23.453.2011061352370.6@nippy.intranet>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-14-arnd@arndb.de> <alpine.LNX.2.23.453.2010091900150.12@nippy.intranet> <CAK8P3a3rM7gJjdTtcKzr6yi15n6xs-yhEpmSOf3QHfahQwxqkw@mail.gmail.com> <alpine.LNX.2.23.453.2010150937430.16@nippy.intranet>
 <CAK8P3a3i6cum_9xGgsbxjXXvbRsP8Po5qLZ0Agb3c4gZTKC9GQ@mail.gmail.com> <alpine.LNX.2.23.453.2010241025410.6@nippy.intranet> <580c3542-92cc-7e33-a43d-bf6a68134a46@linux-m68k.org>
In-Reply-To: <580c3542-92cc-7e33-a43d-bf6a68134a46@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Ungerer <gerg@linux-m68k.org>
Cc: Arnd Bergmann <arnd@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Fri, 30 Oct 2020, Greg Ungerer wrote:

> > 
> > > ...
> > > > The other 11 platforms in that category also have 'synthetic' 
> > > > clocksources derived from a timer reload interrupt. In 3 cases, 
> > > > the clocksource read method does not (or can not) check for a 
> > > > pending counter reload interrupt. For these also, I see no 
> > > > practical alternative to the approach you've taken in your RFC 
> > > > patch:
> > > > 
> > > > arch/m68k/68000/timers.c
> > > > arch/m68k/atari/time.c
> > > > arch/m68k/coldfire/timers.c
> > > 
> > > Agreed. It's possible there is a way, but I don't see one either.
> > > 
> > 
> > For arch/m68k/68000/timers.c, I suppose we may be able to check for 
> > the TMR1 bit in the Interrupt Status Register at 0xFFFFF30C or the 
> > COMP bit in the Timer Status Register at 0xFFFFF60A. But testing that 
> > patch could be difficult.
> > 
> > I expect that equivalent flags are available in Coldfire registers, 
> > making it possible to improve upon mcftmr_read_clk() and 
> > m68328_read_clk() if need be -- that is, if it turns out that the 
> > clocksource interrupt was subject to higher priority IRQs that would 
> > slow down the clocksource or defeat its monotonicity.
> > 
> > The other difficulty is a lack of hardware timers. There's only one 
> > timer on MC68EZ328. On Atari, for now only Timer C is available though 
> > Michael has said that it would be possible to free up Timer D. Some 
> > Coldfire chips have only 2 timers and the second timer seems to be 
> > allocated to profiling.
> 
> FWIW, I would have no problem with ditching the profiling clock, and 
> using both on ColdFire platforms that have this. I doubt anyone has used 
> that profiling setup in a _very_ long time.
> 

If we ditched the Coldfire profiling clock, it would be possible to 
dedicate one hardware timer to the clocksource device and the other to the 
(oneshot) clockevent device.

That's a win if it means that the clocksource can use the full counter 
width (making timer interrupts less frequent and timer interrupt latency 
less problematic) and run at higher frequency (making the clocksource more 
precise).

Also, note that hrtimers won't work with a periodic clockevent device (as 
in Arnd's RFC patch). If you want hrtimers, I think you'll need both 
hardware timers or else re-implement the existing synthetic clocksource 
using the same oneshot timer driving a new oneshot clockevent device.

Please note that the lack of a spare hardware timer is a separate issue to 
the failure of mcftmr_read_clk() and m68328_read_clk() to check the timer 
reload interrupt flag (which may make those clocksources needlessly 
susceptible to issues caused by timer interrupt latency...).
