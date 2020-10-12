From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 12 Oct 2020 13:15:13 +0000
Subject: Re: [PATCH 10/13] m68k: remove timer_interrupt() function
Message-Id: <CAMuHMdUQMgE2ny-nuUeYjn-gcpvav2rp-11oTQp-GZ5TX9Z8Pw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-11-arnd@arndb.de>
In-Reply-To: <20201008154651.1901126-11-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

Hi Arnd,

On Thu, Oct 8, 2020 at 5:48 PM Arnd Bergmann <arnd@arndb.de> wrote:
> This gets passed to a number of init functions, but is
> ignored everywhere, so remove the function and change the
> mach_sched_init callback to take no arguments.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

And finally (for Amiga and Atari/ARAnyM):
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

> --- a/arch/m68k/include/asm/machdep.h
> +++ b/arch/m68k/include/asm/machdep.h
> @@ -33,8 +33,7 @@ extern void (*mach_l2_flush) (int);
>  extern void (*mach_beep) (unsigned int, unsigned int);
>
>  /* Hardware clock functions */
> -extern void hw_timer_init(irq_handler_t handler);
> -extern unsigned long hw_timer_offset(void);

Yeah, this never-used prototype, which entered through the nommu merge,
can go.  But that's not really related to this patch.

Gr{oetje,eeting}s,

                        Geert


--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
