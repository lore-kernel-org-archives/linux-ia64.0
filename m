From: Arnd Bergmann <arnd@kernel.org>
Date: Sun, 01 Nov 2020 09:53:33 +0000
Subject: Re: [PATCH v2 00/15] timers: clean up ARCH_GETTIMEOFFSET, LEGACY_TIMER_TICK
Message-Id: <CAK8P3a3Dg2UEN4MoVhHMUU=xd5x+uiue4nqZDeHBBK_CG6+LoA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org> <alpine.LNX.2.23.453.2011011441010.32@nippy.intranet>
In-Reply-To: <alpine.LNX.2.23.453.2011011441010.32@nippy.intranet>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Finn Thain <fthain@telegraphics.com.au>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Sun, Nov 1, 2020 at 4:47 AM Finn Thain <fthain@telegraphics.com.au> wrote:
>
> On Fri, 30 Oct 2020, Arnd Bergmann wrote:
>
> > CONFIG_ARCH_GETTIMEOFFSET has been gradually phased out from all
> > platforms, with only ARM EBSA110 recently. As this has no more known
> > users, the first three patches remove EBSA110 along with one platform
> > specific driver and the ARCH_GETTIMEOFFSET infrastructure.
> >
>
> The CONFIG_ARCH_GETTIMEOFFSET patches weren't part of v1. Is there some
> kind of dependency here?

There is technically a dependency, though nobody would notice
in practice: removing the ARM timer tick function in patch 6 would
break the ebsa110 platform if we didn't first remove it in patch 1.
Changing ebsa110 to use legacy_timer_tick in turn would introduce
a conflict against the removal patch.

Neither of those is particularly harmful as there are no users of
the affected ebsa110 code, but keeping the two series together
avoids getting complaints from the build bots.

      Arnd
