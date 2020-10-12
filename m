From: Linus Walleij <linus.walleij@linaro.org>
Date: Mon, 12 Oct 2020 22:18:27 +0000
Subject: Re: [PATCH 00/13] Clean up legacy clock tick users
Message-Id: <CACRpkdZedudw5VTSaQk3TRiROi87a_=ioqJGxN7Dxq7Qab34-w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Thu, Oct 8, 2020 at 5:47 PM Arnd Bergmann <arnd@arndb.de> wrote:

> When I created the patch removing CONFIG_ARCH_GETTIMEOFFSET,
> I also had a look at CONFIG_GENERIC_CLOCKEVENTS, which is
> selected by most, but not all, platforms today, each of the
> ones that lack it doing the timer tick slightly differently.
>
> The cleanups here make the old platforms a bit more
> consistent, in multiple ways:
>
> - rather than selecting GENERIC_CLOCKEVENTS on modern
>   platforms, select LEGACY_TIMER_TICK on the old ones.
>
> - Hide some more of the internal implementation and only
>   provide a single common entry point for the timer tick,
>   which also makes the behavior more consistent.
>
> - Remove the m68k and arm specific infrastructure pieces
>   and call the common helper directly from each timer
>   interrupt function.
>
> I tested the series on m68k with the qemu q800 target
> platform, both with the legacy_timer_tick() implementation
> and after converting that to a periodic clockevent driver.

I am a big fan of this patch series:
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>

Maybe the RFC patch can be kept in the sidelines but the
rest should be merged ASAP in my opinion, the kernel just
looks so much better after this.

Yours,
Linus Walleij
