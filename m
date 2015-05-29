From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 29 May 2015 00:47:58 +0000
Subject: [PATCH 00/15] Replace module_init with device_initcall in non modules
Message-Id: <1432860493-23831-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

This series of commits converts non-modular code that is using
the module_init() call to hook itself into the system to instead
use device_initcall().

The conversion is a runtime no-op, since module_init actually
becomes __initcall in the non-modular case, and that in turn gets
mapped onto device_initcall.

We fix this up now, so that we can relocate module_init from
init.h into module.h in a future series.

The files changed here are just limited to those that would
otherwise have to add module.h to obviously non-modular code, since
we don't want to do that.

This work is factored out from what was a previously larger series[1] so
that there is a common theme and lower patch count to ease review.

Paul.

[1] https://marc.info/?l=linux-kernel&m9033951228828

---

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Chris Zankel <chris@zankel.net>
Cc: David Howells <dhowells@redhat.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Geoff Levand <geoff@infradead.org>
Cc: Helge Deller <deller@gmx.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
Cc: Matt Turner <mattst88@gmail.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Mikael Starvik <starvik@axis.com>
Cc: Mike Turquette <mturquette@linaro.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Scott Wood <scottwood@freescale.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Thomas Meyer <thomas@m3y3r.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-alpha@vger.kernel.org
Cc: linux-am33-list@redhat.com
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-cris-kernel@axis.com
Cc: linux-ia64@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-sh@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: x86@kernel.org

Paul Gortmaker (15):
  x86: don't use module_init in non-modular intel_mid_vrtc.c
  x86: don't use module_init in non-modular devicetree.c code
  powerpc: use device_initcall for registering rtc devices
  powerpc: don't use module_init in non-modular 83xx suspend code
  arm: don't use module_init in non-modular mach-vexpress/spc.c code
  alpha: don't use module_init for non-modular core code
  ia64: don't use module_init for non-modular core kernel/mca.c code
  ia64: don't use module_init in non-modular sim/simscsi.c code
  cris: don't use module_init for non-modular core intmem.c code
  parisc: don't use module_init for non-modular core pdc_cons code
  parisc64: don't use module_init for non-modular core perf code
  mn10300: don't use module_init in non-modular flash.c code
  sh: don't use module_init in non-modular psw.c code
  xtensa: don't use module_init for non-modular core network.c code
  drivers/clk: don't use module_init in clk-nomadik.c which is
    non-modular

 arch/alpha/kernel/srmcons.c                  |  3 +--
 arch/arm/mach-vexpress/spc.c                 |  2 +-
 arch/cris/arch-v32/mm/intmem.c               |  3 +--
 arch/ia64/hp/sim/simscsi.c                   | 11 +----------
 arch/ia64/sn/kernel/mca.c                    |  3 +--
 arch/mn10300/unit-asb2303/flash.c            |  3 +--
 arch/parisc/kernel/pdc_cons.c                |  3 +--
 arch/parisc/kernel/perf.c                    |  3 +--
 arch/powerpc/kernel/time.c                   |  2 +-
 arch/powerpc/platforms/83xx/suspend.c        |  3 +--
 arch/powerpc/platforms/ps3/time.c            |  3 +--
 arch/sh/boards/mach-landisk/psw.c            |  2 +-
 arch/x86/kernel/devicetree.c                 |  2 +-
 arch/x86/platform/intel-mid/intel_mid_vrtc.c |  3 +--
 arch/xtensa/platforms/iss/network.c          |  4 +---
 drivers/clk/clk-nomadik.c                    |  3 +--
 16 files changed, 16 insertions(+), 37 deletions(-)

-- 
2.2.1
