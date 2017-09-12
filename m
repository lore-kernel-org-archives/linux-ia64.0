From: Linus Walleij <linus.walleij@linaro.org>
Date: Tue, 12 Sep 2017 08:09:51 +0000
Subject: Re: [PATCH] [RFC] clocksource: improve GENERIC_CLOCKEVENTS dependency
Message-Id: <CACRpkdbruKbL-Qe6P7rCGwxbprFt5rBWF7-eYpuaVPK7fjhkGA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170905150504.1720954-1-arnd@arndb.de>
In-Reply-To: <20170905150504.1720954-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>
Cc: Daniel Lezcano <daniel.lezcano@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Randy Dunlap <rdunlap@infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@vger.kernel.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ding Tianhong <dingtianhong@huawei.com>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Vineet Gupta <vgupta@synopsys.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Sep 5, 2017 at 5:04 PM, Arnd Bergmann <arnd@arndb.de> wrote:

> We regularly run into build errors when a clocksource driver selects
> CONFIG_TIMER_OF while CONFIG_GENERIC_CLOCKEVENTS is disabled:
>
>  In file included from drivers/clocksource/timer-of.c:25:0:
> drivers/clocksource/timer-of.h:35:28: error: field 'clkevt' has incomplete type
>
> At the moment, three drivers can show this behavior: ARMV7M_SYSTICK,
> CLKSRC_ST_LPC and CLKSRC_NPS. We could add further dependencies as we did
> many times, but I have looked a little bit more at what architectures
> are left that don't use GENERIC_CLOCKEVENTS, and this shows that there
> is a better solution.
>
> On arch/frv and arch/ia64, we never select CONFIG_GENERIC_CLOCKEVENTS
> and we also don't use ARCH_USES_GETTIMEOFFSET, which would
> block the clocksource Kconfig menu. On m68k, some platforms use
> CONFIG_GENERIC_CLOCKEVENTS, some use ARCH_USES_GETTIMEOFFSET, and some
> use neither of them. The good news is that there is no configuration that
> does not set CONFIG_GENERIC_CLOCKEVENTS but that wants to enable any of
> the Kconfig symbols in the menu, so we can simply replace the dependency
> with the stricter one. While in theory one could have a clocksource
> driver without the clockevent infrastructure, this seems unlikely
> to be relevant in the future any more.

As far as I can see this works and makes sense.
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>

> We can probably drop some of the other dependencies as well now,
> e.g. there should generally be no reason to depend on CONFIG_ARM
> unless the driver uses architecture specific assembly.

I think they are just there to cut down on the available menu choices
when doing manual configuration. Which is moot since the machine/subarch
likely selects the right clocksource driver anyway.

About ARM:

For ARM we now have two subarchs not using generic clockevents:
RISC PC and EBSA110.

I think Russell stated these two cannot be converted to generic clockevents
because of hardware limitations I guess, no timer interrupt, simply, which
means no clockevents, or unreliable or not granular enough timers.

IIUC the SA110 does not contain the built-in SoC goodies of the SA1100
so it needs external timer blocks, and those two machines don't have
good enough timers.

That is a bit annoying since even the Commodore 64 has good enough
timers to run generic clock events, had it only had compiler support
and enough memory to run Linux...

Anyways, I'm too ignorant to even fully understand what happens
on a system with just GETTIMEOFFSET and not clockevents, does the
OS just run in an eternal loop and advancing any event in the system
using that time offset?

Yours,
Linus Walleij
