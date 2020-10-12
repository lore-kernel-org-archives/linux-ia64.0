From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 12 Oct 2020 13:14:27 +0000
Subject: Re: [PATCH 01/13] timekeeping: add CONFIG_LEGACY_TIMER_TICK
Message-Id: <CAMuHMdW22uxMj3=Yfyz9uZoofT_aNxL2kV6UERgAYbRcw7yb2w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-2-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-2-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Thu, Oct 8, 2020 at 5:47 PM Arnd Bergmann <arnd@arndb.de> wrote:
> All platforms that currently do not use generic clockevents roughly call
> the same set of functions in their timer interrupts: xtime_update(),
> update_process_times() and profile_tick(), sometimes in a different
> sequence.
>
> Add a helper function that performs all three of them, to make the
> callers more uniform and simplify the interface.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert


--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
