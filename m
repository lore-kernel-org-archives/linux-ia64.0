From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 12 Oct 2020 13:15:57 +0000
Subject: Re: [PATCH 12/13] timekeeping: default GENERIC_CLOCKEVENTS to enabled
Message-Id: <CAMuHMdWS5JoXho97oxcavE_OFdv+tnr+da1WV_D7sOE_YbxQxA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-13-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-13-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Thu, Oct 8, 2020 at 5:48 PM Arnd Bergmann <arnd@arndb.de> wrote:
> Almost all machines use GENERIC_CLOCKEVENTS, so it feels wrong to
> require each one to select that symbol manually.
>
> Instead, enable it whenever CONFIG_LEGACY_TIMER_TICK is disabled as
> a simplification. It should be possible to select both
> GENERIC_CLOCKEVENTS and LEGACY_TIMER_TICK from an architecture now
> and decide at runtime between the two.
>
> For the clockevents arch-support.txt file, this means that additional
> architectures are marked as TODO when they have at least one machine
> that still uses LEGACY_TIMER_TICK, rather than being marked 'ok' when
> at least one machine has been converted. This means that both m68k and
> arm (for riscpc) revert to TODO.
>
> At this point, we could just always enable CONFIG_GENERIC_CLOCKEVENTS
> rather than leaving it off when not needed. I built an m68k
> defconfig kernel (using gcc-10.1.0) and found that this would add
> around 5.5KB in kernel image size:
>
>    text    data     bss     dec     hex filename
> 3861936 1092236  196656 5150828  4e986c obj-m68k/vmlinux-no-clockevent
> 3866201 1093832  196184 5156217  4ead79 obj-m68k/vmlinux-clockevent
>
> On Arm (MACH_RPC), that difference appears to be twice as large,
> around 11KB on top of an 6MB vmlinux.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>

>  arch/m68k/Kconfig.cpu                                |  1 -

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
