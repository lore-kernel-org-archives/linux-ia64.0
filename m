From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 12 Oct 2020 13:15:25 +0000
Subject: Re: [PATCH 08/13] m68k: m68328: use legacy_timer_tick()
Message-Id: <CAMuHMdWtMZaJ8ETb4g+AfaLeSZ1vyi8-POEaRzmdwh3ha=jieA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-9-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-9-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

Hi Arnd,

On Thu, Oct 8, 2020 at 5:48 PM Arnd Bergmann <arnd@arndb.de> wrote:
> A couple of machines share the m68328 timer code that
> is based on calling timer_interrupt(). Change these
> to the new and slightly more generic legacy_timer_tick()
> helper.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks for your patch!

> --- a/arch/m68k/Kconfig.machine
> +++ b/arch/m68k/Kconfig.machine
> @@ -146,6 +146,7 @@ config PILOT
>  config PILOT3
>         bool "Pilot 1000/5000, PalmPilot Personal/Pro, or PalmIII support"
>         depends on M68328
> +       select LEGACY_TIMER_TICK
>         select PILOT
>         help
>           Support for the Palm Pilot 1000/5000, Personal/Pro and PalmIII.
> @@ -159,18 +160,21 @@ config XCOPILOT_BUGS
>  config UCSIMM
>         bool "uCsimm module support"
>         depends on M68EZ328
> +       select LEGACY_TIMER_TICK
>         help
>           Support for the Arcturus Networks uCsimm module.
>
>  config UCDIMM
>         bool "uDsimm module support"
>         depends on M68VZ328
> +       select LEGACY_TIMER_TICK
>         help
>           Support for the Arcturus Networks uDsimm module.
>
>  config DRAGEN2
>         bool "DragenEngine II board support"
>         depends on M68VZ328
> +       select LEGACY_TIMER_TICK
>         help
>           Support for the DragenEngine II board.

Given this feature is SoC-specific, not platform-specific, perhaps
it makes sense to move the selects to the M68{,EZ,VZ}328 symbols?

Regardless:
Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert


--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
