From: Sam Creasey <sammy@sammy.net>
Date: Mon, 16 Nov 2020 23:27:03 +0000
Subject: Re: [RFC 13/13] m68k: mac: convert to generic clockevent
Message-Id: <20201116232703.GV14088@anhedonia-3>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-14-arnd@arndb.de> <alpine.LNX.2.23.453.2010091900150.12@nippy.intranet> <CAK8P3a3rM7gJjdTtcKzr6yi15n6xs-yhEpmSOf3QHfahQwxqkw@mail.gmail.com> <alpine.LNX.2.23.453.2010150937430.16@nippy.intranet> <CAK8P3a3i6cum_9xGgsbxjXXvbRsP8Po5qLZ0Agb3c4gZTKC9GQ@mail.gmail.com> <CAMuHMdUyGH=ORa4yHivMeJZaGQ3kEXi1kr9=P+u1y3QQnC+-4g@mail.gmail.com> <alpine.LNX.2.23.453.2011061343030.13@nippy.intranet>
In-Reply-To: <alpine.LNX.2.23.453.2011061343030.13@nippy.intranet>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Finn Thain <fthain@telegraphics.com.au>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Fri, Nov 06, 2020 at 01:52:01PM +1100, Finn Thain wrote:
> On Fri, 23 Oct 2020, Geert Uytterhoeven wrote:
> 
> > > > > The arm/rpc timer seems to be roughly in the same category as most 
> > > > > of the m68k ones or the i8253 counter on a PC. It's possible that 
> > > > > some of them could use the same logic as 
> > > > > drivers/clocksource/i8253.o as long as there is any hardware 
> > > > > oneshot mode.
> > > >
> > > > There appear to be 15 platforms in that category. 4 have no 
> > > > clocksource besides the jiffies clocksource, meaning there's no 
> > > > practical alternative to using a periodic tick, like you did in your 
> > > > RFC patch:
> > > >
> > > > arch/m68k/apollo/config.c
> > > > arch/m68k/q40/q40ints.c
> > > > arch/m68k/sun3/sun3ints.c
> > > > arch/m68k/sun3x/time.c
> > >
> > > Do any of these have users? I'm fairly sure sun3x has never worked in 
> > > mainline, sun3 seems to still need the same few patches it did 20 
> > > years ago. I couldn't find much about Linux on Apollo or q40, the 
> > > information on the web for either of them seems to all be for 
> > > linux-2.4 kernels.
> > 
> > They probably don't have any users.
> 
> I have access to several Sun 3 machines but no time to work on that port, 
> unfortunately.
> 
> Are these 4 platforms (those with no clocksource besides the "jiffies" 
> clocksource) the only reason for CONFIG_TIME_LOW_RES on m68k?

Sun3x was probably at least as close (if not closer) than Sun3 to
working in mainline back in the day, but unfortunately I'm in the same
place as Finn...  I've got the hardware, but time is harder to come
by.

-- Sam
