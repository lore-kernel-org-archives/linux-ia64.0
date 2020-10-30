From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 30 Oct 2020 15:17:43 +0000
Subject: [PATCH v2 00/15] timers: clean up ARCH_GETTIMEOFFSET, LEGACY_TIMER_TICK
Message-Id: <20201030151758.1241164-1-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

From: Arnd Bergmann <arnd@arndb.de>

This is a resend of the combined cleanups for CONFIG_ARCH_GETTIMEOFFSET,
which gets removed, and CONFIG_LEGACY_TIMER_TICK, which replaces
CONFIG_GENERIC_CLOCKEVENTS, with the reverse meaning.

CONFIG_ARCH_GETTIMEOFFSET has been gradually phased out from all
platforms, with only ARM EBSA110 recently. As this has no more
known users, the first three patches remove EBSA110 along with
one platform specific driver and the ARCH_GETTIMEOFFSET
infrastructure.

When I created the patch removing CONFIG_ARCH_GETTIMEOFFSET, I also
had a look at CONFIG_GENERIC_CLOCKEVENTS, which is selected by most,
but not all, platforms today, each of the ones that lack it doing the
timer tick slightly differently.

The cleanups here make the old platforms a bit more consistent, in
multiple ways:

- rather than selecting GENERIC_CLOCKEVENTS on modern
  platforms, select LEGACY_TIMER_TICK on the old ones.

- Hide some more of the internal implementation and only
  provide a single common entry point for the timer tick,
  which also makes the behavior more consistent.

- Remove the m68k and arm specific infrastructure pieces
  and call the common helper directly from each timer
  interrupt function.

I tested the series on m68k with the qemu q800 target platform, both
with the legacy_timer_tick() implementation and after converting that
to a periodic clockevent driver (not included in v2).

Since the patches touch a lot of architecture specific code, I've created
a branch in my asm-generic tree[1] and plan to send it for the v5.11 merge
window. If any maintainer has conflicting changes or wants to build on
top of my work, feel free to merge that into additional subsystem trees.

	Arnd

[1] git://git.kernel.org/pub/scm/linux/kernel/git/arnd/asm-generic.git \
							asm-generic-timers

Arnd Bergmann (15):
  ARM: remove ebsa110 platform
  net: remove am79c961a driver
  timekeeping: remove arch_gettimeoffset
  timekeeping: add CONFIG_LEGACY_TIMER_TICK
  ia64: convert to legacy_timer_tick
  ARM: rpc: use legacy_timer_tick
  parisc: use legacy_timer_tick
  m68k: coldfire: use legacy_timer_tick()
  m68k: split heartbeat out of timer function
  m68k: sun3/sun3c: use legacy_timer_tick
  m68k: m68328: use legacy_timer_tick()
  m68k: change remaining timers to legacy_timer_tick
  m68k: remove timer_interrupt() function
  timekeeping: remove xtime_update
  timekeeping: default GENERIC_CLOCKEVENTS to enabled

 .../time/clockevents/arch-support.txt         |   8 +-
 .../time/modern-timekeeping/arch-support.txt  |  33 -
 MAINTAINERS                                   |   8 -
 arch/alpha/Kconfig                            |   1 -
 arch/arc/Kconfig                              |   1 -
 arch/arm/Kconfig                              |  37 +-
 arch/arm/Kconfig.debug                        |   6 +-
 arch/arm/Makefile                             |   8 -
 arch/arm/configs/ebsa110_defconfig            |  74 --
 arch/arm/include/asm/mach/time.h              |   2 -
 arch/arm/kernel/Makefile                      |   6 +-
 arch/arm/kernel/time.c                        |  14 -
 arch/arm/mach-ebsa110/Makefile                |   8 -
 arch/arm/mach-ebsa110/Makefile.boot           |   5 -
 arch/arm/mach-ebsa110/core.c                  | 323 --------
 arch/arm/mach-ebsa110/core.h                  |  38 -
 .../mach-ebsa110/include/mach/entry-macro.S   |  33 -
 arch/arm/mach-ebsa110/include/mach/hardware.h |  21 -
 arch/arm/mach-ebsa110/include/mach/io.h       |  89 --
 arch/arm/mach-ebsa110/include/mach/irqs.h     |  17 -
 arch/arm/mach-ebsa110/include/mach/memory.h   |  22 -
 .../mach-ebsa110/include/mach/uncompress.h    |  41 -
 arch/arm/mach-ebsa110/io.c                    | 440 ----------
 arch/arm/mach-ebsa110/leds.c                  |  71 --
 arch/arm/mach-rpc/time.c                      |   2 +-
 arch/arm64/Kconfig                            |   1 -
 arch/arm64/Kconfig.platforms                  |   1 -
 arch/c6x/Kconfig                              |   1 -
 arch/csky/Kconfig                             |   1 -
 arch/h8300/Kconfig                            |   1 -
 arch/hexagon/Kconfig                          |   1 -
 arch/ia64/Kconfig                             |   1 +
 arch/ia64/kernel/time.c                       |  36 +-
 arch/m68k/68000/timers.c                      |   7 +-
 arch/m68k/Kconfig.cpu                         |  37 +-
 arch/m68k/Kconfig.machine                     |  11 +
 arch/m68k/amiga/config.c                      |  11 +-
 arch/m68k/apollo/config.c                     |  11 +-
 arch/m68k/atari/config.c                      |   2 +-
 arch/m68k/atari/time.c                        |   9 +-
 arch/m68k/bvme6000/config.c                   |   9 +-
 arch/m68k/coldfire/Makefile                   |  32 +-
 arch/m68k/coldfire/pit.c                      |   2 +-
 arch/m68k/coldfire/sltimers.c                 |   8 +-
 arch/m68k/coldfire/timers.c                   |   8 +-
 arch/m68k/hp300/time.c                        |   8 +-
 arch/m68k/hp300/time.h                        |   2 +-
 arch/m68k/include/asm/machdep.h               |  12 +-
 arch/m68k/kernel/setup_mm.c                   |   2 +-
 arch/m68k/kernel/setup_no.c                   |   2 +-
 arch/m68k/kernel/time.c                       |  18 +-
 arch/m68k/mac/config.c                        |   6 +-
 arch/m68k/mac/via.c                           |   8 +-
 arch/m68k/mvme147/config.c                    |   9 +-
 arch/m68k/mvme16x/config.c                    |   9 +-
 arch/m68k/q40/config.c                        |   2 +-
 arch/m68k/q40/q40ints.c                       |  10 +-
 arch/m68k/sun3/config.c                       |   4 +-
 arch/m68k/sun3/sun3ints.c                     |   3 +-
 arch/m68k/sun3x/time.c                        |   5 +-
 arch/m68k/sun3x/time.h                        |   2 +-
 arch/microblaze/Kconfig                       |   1 -
 arch/mips/Kconfig                             |   1 -
 arch/nds32/Kconfig                            |   1 -
 arch/nios2/Kconfig                            |   1 -
 arch/openrisc/Kconfig                         |   1 -
 arch/parisc/Kconfig                           |   2 +-
 arch/parisc/kernel/time.c                     |   9 +-
 arch/powerpc/Kconfig                          |   1 -
 arch/riscv/Kconfig                            |   1 -
 arch/s390/Kconfig                             |   1 -
 arch/sh/Kconfig                               |   1 -
 arch/sparc/Kconfig                            |   1 -
 arch/um/Kconfig                               |   1 -
 arch/x86/Kconfig                              |   1 -
 arch/xtensa/Kconfig                           |   1 -
 drivers/Makefile                              |   2 -
 drivers/clocksource/Kconfig                   |   2 +-
 drivers/net/ethernet/amd/Kconfig              |  10 +-
 drivers/net/ethernet/amd/Makefile             |   1 -
 drivers/net/ethernet/amd/am79c961a.c          | 763 ------------------
 drivers/net/ethernet/amd/am79c961a.h          | 143 ----
 drivers/watchdog/Kconfig                      |   2 +-
 include/linux/time.h                          |  13 -
 include/linux/timekeeping.h                   |   3 +-
 kernel/time/Kconfig                           |  18 +-
 kernel/time/Makefile                          |   1 +
 kernel/time/clocksource.c                     |   8 -
 kernel/time/tick-legacy.c                     |  37 +
 kernel/time/timekeeping.c                     |  41 +-
 kernel/time/timekeeping.h                     |   1 +
 kernel/trace/Kconfig                          |   2 -
 92 files changed, 218 insertions(+), 2453 deletions(-)
 delete mode 100644 Documentation/features/time/modern-timekeeping/arch-support.txt
 delete mode 100644 arch/arm/configs/ebsa110_defconfig
 delete mode 100644 arch/arm/mach-ebsa110/Makefile
 delete mode 100644 arch/arm/mach-ebsa110/Makefile.boot
 delete mode 100644 arch/arm/mach-ebsa110/core.c
 delete mode 100644 arch/arm/mach-ebsa110/core.h
 delete mode 100644 arch/arm/mach-ebsa110/include/mach/entry-macro.S
 delete mode 100644 arch/arm/mach-ebsa110/include/mach/hardware.h
 delete mode 100644 arch/arm/mach-ebsa110/include/mach/io.h
 delete mode 100644 arch/arm/mach-ebsa110/include/mach/irqs.h
 delete mode 100644 arch/arm/mach-ebsa110/include/mach/memory.h
 delete mode 100644 arch/arm/mach-ebsa110/include/mach/uncompress.h
 delete mode 100644 arch/arm/mach-ebsa110/io.c
 delete mode 100644 arch/arm/mach-ebsa110/leds.c
 delete mode 100644 drivers/net/ethernet/amd/am79c961a.c
 delete mode 100644 drivers/net/ethernet/amd/am79c961a.h
 create mode 100644 kernel/time/tick-legacy.c

Cc: Russell King <linux@armlinux.org.uk>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Greg Ungerer <gerg@linux-m68k.org>
Cc: Finn Thain <fthain@telegraphics.com.au>
Cc: Philip Blundell <philb@gnu.org>
Cc: Joshua Thompson <funaho@jurai.org>
Cc: Sam Creasey <sammy@sammy.net>
Cc: "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>
Cc: Helge Deller <deller@gmx.de>
Cc: Daniel Lezcano <daniel.lezcano@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Stephen Boyd <sboyd@kernel.org>
Cc: Linus Walleij <linus.walleij@linaro.org>
Cc: <linux-ia64@vger.kernel.org>
Cc: Parisc List <linux-parisc@vger.kernel.org>
Cc: linux-m68k <linux-m68k@lists.linux-m68k.org>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>


-- 
2.27.0
