From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 12 Oct 2020 15:30:49 +0000
Subject: Re: [PATCH 08/13] m68k: m68328: use legacy_timer_tick()
Message-Id: <CAK8P3a1nDZYYwtuniUGxmy=H8LHbOEGSU=Pmi2=LMrLw09x8+w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201008154651.1901126-1-arnd@arndb.de> <20201008154651.1901126-9-arnd@arndb.de>
 <CAMuHMdWtMZaJ8ETb4g+AfaLeSZ1vyi8-POEaRzmdwh3ha=jieA@mail.gmail.com>
In-Reply-To: <CAMuHMdWtMZaJ8ETb4g+AfaLeSZ1vyi8-POEaRzmdwh3ha=jieA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Mon, Oct 12, 2020 at 3:15 PM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>
> Given this feature is SoC-specific, not platform-specific, perhaps
> it makes sense to move the selects to the M68{,EZ,VZ}328 symbols?
>
> Regardless:
> Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>

Ok, folded in the change blow, using one less line. I couldn't figure
out whether
it should just be part of the CONFIG_M68000 instead, which doesn't appear
to have any machine support by itself. The dragonball CPU configuration
looks really odd, because you have to build exactly one of M68{,EZ,VZ}328
into the kernel to get a successful compilation, while Kconfig allows
many other combinations.

     Arnd

diff --git a/arch/m68k/Kconfig.cpu b/arch/m68k/Kconfig.cpu
index 322a35ef14c6..648054d4f860 100644
--- a/arch/m68k/Kconfig.cpu
+++ b/arch/m68k/Kconfig.cpu
@@ -104,6 +104,7 @@ config M68060
 config M68328
        bool "MC68328"
        depends on !MMU
+       select LEGACY_TIMER_TICK
        select M68000
        help
          Motorola 68328 processor support.
@@ -111,6 +112,7 @@ config M68328
 config M68EZ328
        bool "MC68EZ328"
        depends on !MMU
+       select LEGACY_TIMER_TICK
        select M68000
        help
          Motorola 68EX328 processor support.
@@ -118,6 +120,7 @@ config M68EZ328
 config M68VZ328
        bool "MC68VZ328"
        depends on !MMU
+       select LEGACY_TIMER_TICK
        select M68000
        help
          Motorola 68VZ328 processor support.
diff --git a/arch/m68k/Kconfig.machine b/arch/m68k/Kconfig.machine
index 0ff9338b958e..e3c835440d9a 100644
--- a/arch/m68k/Kconfig.machine
+++ b/arch/m68k/Kconfig.machine
@@ -146,7 +146,6 @@ config PILOT
 config PILOT3
        bool "Pilot 1000/5000, PalmPilot Personal/Pro, or PalmIII support"
        depends on M68328
-       select LEGACY_TIMER_TICK
        select PILOT
        help
          Support for the Palm Pilot 1000/5000, Personal/Pro and PalmIII.
@@ -160,21 +159,18 @@ config XCOPILOT_BUGS
 config UCSIMM
        bool "uCsimm module support"
        depends on M68EZ328
-       select LEGACY_TIMER_TICK
        help
          Support for the Arcturus Networks uCsimm module.

 config UCDIMM
        bool "uDsimm module support"
        depends on M68VZ328
-       select LEGACY_TIMER_TICK
        help
          Support for the Arcturus Networks uDsimm module.

 config DRAGEN2
        bool "DragenEngine II board support"
        depends on M68VZ328
-       select LEGACY_TIMER_TICK
        help
          Support for the DragenEngine II board.
