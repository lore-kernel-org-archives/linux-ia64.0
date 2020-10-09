From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 09 Oct 2020 13:23:59 +0000
Subject: Re: [PATCH 05/13] m68k: coldfire: use legacy_timer_tick()
Message-Id: <CAK8P3a3E1x_T29Az_d-A+wTpqCWj6Z40TaOjcsX-kc+xfpBrRA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-6-arnd@arndb.de>
 <0bf8d0e5-5792-a2dd-884a-c82693b64b19@linux-m68k.org>
In-Reply-To: <0bf8d0e5-5792-a2dd-884a-c82693b64b19@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Ungerer <gerg@linux-m68k.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Fri, Oct 9, 2020 at 2:53 PM Greg Ungerer <gerg@linux-m68k.org> wrote:
>
> Hi Arnd,
>
> On 9/10/20 1:46 am, Arnd Bergmann wrote:
> > Replace the indirect function calls in the timer code
> > with direct calls to the newly added legacy_timer_tick()
> > helper for those that have not yet been converted to
> > generic clockevents.
> >
> > This makes the timer code a little more self-contained.
> >
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> I tested this series on a couple of different ColdFire parts
> (5208 and 5475) and under QEMU emulating the 5208. All checked
> out good, all worked as expected. So for the ColdFire changes:
>
> Tested-by: Greg Ungerer <gerg@linux-m68k.org>

Awesome, thanks for testing!

        Arnd
