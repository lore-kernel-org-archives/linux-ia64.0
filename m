From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 12 Oct 2020 20:33:34 +0000
Subject: Re: [PATCH 08/13] m68k: m68328: use legacy_timer_tick()
Message-Id: <CAMuHMdXn=1Gsn6hS72BoJ0jZwTVv_nurV0zCdSpUKJ6T5BL=Rg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-9-arnd@arndb.de>
 <CAMuHMdWtMZaJ8ETb4g+AfaLeSZ1vyi8-POEaRzmdwh3ha=jieA@mail.gmail.com> <CAK8P3a1nDZYYwtuniUGxmy=H8LHbOEGSU=Pmi2=LMrLw09x8+w@mail.gmail.com>
In-Reply-To: <CAK8P3a1nDZYYwtuniUGxmy=H8LHbOEGSU=Pmi2=LMrLw09x8+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

Hi Arnd,

On Mon, Oct 12, 2020 at 5:31 PM Arnd Bergmann <arnd@arndb.de> wrote:
> On Mon, Oct 12, 2020 at 3:15 PM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> > Given this feature is SoC-specific, not platform-specific, perhaps
> > it makes sense to move the selects to the M68{,EZ,VZ}328 symbols?
> >
> > Regardless:
> > Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
> Ok, folded in the change blow, using one less line. I couldn't figure

Thanks, looks good.

> out whether
> it should just be part of the CONFIG_M68000 instead, which doesn't appear

It must definitely not be selected by CONFIG_M68000, as the plain MC68000
is a CPU, not an SoC, and does not have the timer.

> to have any machine support by itself. The dragonball CPU configuration
> looks really odd, because you have to build exactly one of M68{,EZ,VZ}328
> into the kernel to get a successful compilation, while Kconfig allows
> many other combinations.

While CONFIG_M68000 could be used for a "pure" MC68000-based machine,
I believe we don't support any yet.
M68{,EZ,VZ}328 select M68000 as they are SoCs containing a 68000
CPU core.
Other m68k SoCs have a CPU32 core, which is a simplified 68020 CPU core
(hmm, what happened to 68360 support? Oh, removed in 2016, so nothing
selects CPU32 anymore).

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
