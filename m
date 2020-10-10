From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 10 Oct 2020 20:31:13 +0000
Subject: Re: [PATCH 01/13] timekeeping: add CONFIG_LEGACY_TIMER_TICK
Message-Id: <CAK8P3a3ZBHJag7MUDNL+hrZQLiJfc8JyZzOtAuarOVwo_GcmmA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-2-arnd@arndb.de>
 <alpine.LNX.2.23.453.2010100820110.12@nippy.intranet>
In-Reply-To: <alpine.LNX.2.23.453.2010100820110.12@nippy.intranet>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Finn Thain <fthain@telegraphics.com.au>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Sat, Oct 10, 2020 at 12:18 AM Finn Thain <fthain@telegraphics.com.au> wrote:
> On Thu, 8 Oct 2020, Arnd Bergmann wrote:
>
> It's good to see this code refactored in this way because, as well as
> de-duplication, it reveals the logic that's common to the relevant
> platforms and may shed some light on the need for that logic.
>
> Yet it's not clear to me that the clockevents framework is able to replace
> that logic on all of the affected hardware. I suppose it remains to be
> seen.

I suspect that the change I did for one platform in patch 13/13 could be
duplicated for all 16 platforms, adding lots of trivial clockevent drivers that
only support periodic ticks, but any platform that can instead support
oneshot timers should probably do that, or it won't provide any better
behavior.

What do others think we should do here?

> As a corollary, cutting edge ("non-legacy") code is often kept out of open
> source projects by the owners of the intellectual property rights.

I'm happy to change the name in any way if you have a suggestion
that the clock event maintainers (Daniel and Thomas) like.

      Arnd
