From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 12 Oct 2020 13:15:51 +0000
Subject: Re: [PATCH 11/13] timekeeping: remove xtime_update
Message-Id: <CAMuHMdU7bn7rzG-0xzr4St1uArGoOhw6dy7HCkrHRvYqM38Wxg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-12-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-12-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

Hi Arnd,

On Thu, Oct 8, 2020 at 5:48 PM Arnd Bergmann <arnd@arndb.de> wrote:
> There are no more users of xtime_update aside from legacy_timer_tick(),
> so fold it into that function and remove the declaration.
>
> update_process_times() is now only called inside of the kernel/time/
> code, so the declaration can be moved there.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks for your patch!

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>

The comment about xtime_update() in arch/ia64/kernel/time.c needs
an update.
Does the comment about update_process_times() in
arch/openrisc/kernel/time.c needs an update, too?

For Amiga and Atari/ARAnyM:
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert


--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
