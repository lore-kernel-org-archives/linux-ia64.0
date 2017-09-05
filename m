From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 05 Sep 2017 15:04:56 +0000
Subject: [PATCH] [RFC] clocksource: improve GENERIC_CLOCKEVENTS dependency
Message-Id: <20170905150504.1720954-1-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Lezcano <daniel.lezcano@linaro.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Randy Dunlap <rdunlap@infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, Ding Tianhong <dingtianhong@huawei.com>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Vineet Gupta <vgupta@synopsys.com>, linux-kernel@vger.kernel.org

We regularly run into build errors when a clocksource driver selects
CONFIG_TIMER_OF while CONFIG_GENERIC_CLOCKEVENTS is disabled:

 In file included from drivers/clocksource/timer-of.c:25:0:
drivers/clocksource/timer-of.h:35:28: error: field 'clkevt' has incomplete type

At the moment, three drivers can show this behavior: ARMV7M_SYSTICK,
CLKSRC_ST_LPC and CLKSRC_NPS. We could add further dependencies as we did
many times, but I have looked a little bit more at what architectures
are left that don't use GENERIC_CLOCKEVENTS, and this shows that there
is a better solution.

On arch/frv and arch/ia64, we never select CONFIG_GENERIC_CLOCKEVENTS
and we also don't use ARCH_USES_GETTIMEOFFSET, which would
block the clocksource Kconfig menu. On m68k, some platforms use
CONFIG_GENERIC_CLOCKEVENTS, some use ARCH_USES_GETTIMEOFFSET, and some
use neither of them. The good news is that there is no configuration that
does not set CONFIG_GENERIC_CLOCKEVENTS but that wants to enable any of
the Kconfig symbols in the menu, so we can simply replace the dependency
with the stricter one. While in theory one could have a clocksource
driver without the clockevent infrastructure, this seems unlikely
to be relevant in the future any more.

We can probably drop some of the other dependencies as well now,
e.g. there should generally be no reason to depend on CONFIG_ARM
unless the driver uses architecture specific assembly.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/clocksource/Kconfig | 50 ++++++++-------------------------------------
 1 file changed, 9 insertions(+), 41 deletions(-)

diff --git a/drivers/clocksource/Kconfig b/drivers/clocksource/Kconfig
index cc6062049170..c729a88007d0 100644
--- a/drivers/clocksource/Kconfig
+++ b/drivers/clocksource/Kconfig
@@ -1,9 +1,8 @@
 menu "Clock Source drivers"
-	depends on !ARCH_USES_GETTIMEOFFSET
+	depends on GENERIC_CLOCKEVENTS
 
 config TIMER_OF
 	bool
-	depends on GENERIC_CLOCKEVENTS
 	select TIMER_PROBE
 
 config TIMER_ACPI
@@ -30,21 +29,18 @@ config CLKSRC_MMIO
 
 config BCM2835_TIMER
 	bool "BCM2835 timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables the support for the BCM2835 timer driver.
 
 config BCM_KONA_TIMER
 	bool "BCM mobile timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables the support for the BCM Kona mobile timer driver.
 
 config DIGICOLOR_TIMER
 	bool "Digicolor timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	depends on HAS_IOMEM
 	help
@@ -52,7 +48,6 @@ config DIGICOLOR_TIMER
 
 config DW_APB_TIMER
 	bool "DW APB timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	help
 	  Enables the support for the dw_apb timer.
 
@@ -63,7 +58,6 @@ config DW_APB_TIMER_OF
 
 config FTTMR010_TIMER
 	bool "Faraday Technology timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	select CLKSRC_MMIO
 	select TIMER_OF
@@ -90,7 +84,6 @@ config ARMADA_370_XP_TIMER
 
 config MESON6_TIMER
 	bool "Meson6 timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables the support for the Meson6 timer driver.
@@ -105,14 +98,12 @@ config ORION_TIMER
 
 config OWL_TIMER
 	bool "Owl timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables the support for the Actions Semi Owl timer driver.
 
 config SUN4I_TIMER
 	bool "Sun4i timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	select CLKSRC_MMIO
 	select TIMER_OF
@@ -135,7 +126,6 @@ config TEGRA_TIMER
 
 config VT8500_TIMER
 	bool "VT8500 timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	help
 	  Enables support for the VT8500 driver.
@@ -148,7 +138,6 @@ config CADENCE_TTC_TIMER
 
 config ASM9260_TIMER
 	bool "ASM9260 timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	select TIMER_OF
 	help
@@ -171,28 +160,24 @@ config CLKSRC_NOMADIK_MTU_SCHED_CLOCK
 
 config CLKSRC_DBX500_PRCMU
 	bool "Clocksource PRCMU Timer" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	help
 	  Use the always on PRCMU Timer as clocksource
 
 config CLPS711X_TIMER
 	bool "Cirrus logic timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables support for the Cirrus Logic PS711 timer.
 
 config ATLAS7_TIMER
 	bool "Atlas7 timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables support for the Atlas7 timer.
 
 config MXS_TIMER
 	bool "Mxs timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	select STMP_DEVICE
 	help
@@ -200,14 +185,12 @@ config MXS_TIMER
 
 config PRIMA2_TIMER
 	bool "Prima2 timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables support for the Prima2 timer.
 
 config U300_TIMER
 	bool "U300 timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on ARM
 	select CLKSRC_MMIO
 	help
@@ -215,14 +198,12 @@ config U300_TIMER
 
 config NSPIRE_TIMER
 	bool "NSpire timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables support for the Nspire timer.
 
 config KEYSTONE_TIMER
 	bool "Keystone timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on ARM || ARM64
 	select CLKSRC_MMIO
 	help
@@ -230,7 +211,6 @@ config KEYSTONE_TIMER
 
 config INTEGRATOR_AP_TIMER
 	bool "Integrator-ap timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables support for the Integrator-ap timer.
@@ -253,7 +233,7 @@ config CLKSRC_EFM32
 
 config CLKSRC_LPC32XX
 	bool "Clocksource for LPC32XX" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS && HAS_IOMEM
+	depends on HAS_IOMEM
 	depends on ARM
 	select CLKSRC_MMIO
 	select TIMER_OF
@@ -262,7 +242,7 @@ config CLKSRC_LPC32XX
 
 config CLKSRC_PISTACHIO
 	bool "Clocksource for Pistachio SoC" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS && HAS_IOMEM
+	depends on HAS_IOMEM
 	select TIMER_OF
 	help
 	  Enables the clocksource for the Pistachio SoC.
@@ -298,7 +278,6 @@ config CLKSRC_MPS2
 
 config ARC_TIMERS
 	bool "Support for 32-bit TIMERn counters in ARC Cores" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select TIMER_OF
 	help
 	  These are legacy 32-bit TIMER0 and TIMER1 counters found on all ARC cores
@@ -307,7 +286,6 @@ config ARC_TIMERS
 
 config ARC_TIMERS_64BIT
 	bool "Support for 64-bit counters in ARC HS38 cores" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on ARC_TIMERS
 	select TIMER_OF
 	help
@@ -407,7 +385,6 @@ config ATMEL_PIT
 
 config ATMEL_ST
 	bool "Atmel ST timer support" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select TIMER_OF
 	select MFD_SYSCON
 	help
@@ -426,7 +403,6 @@ config CLKSRC_EXYNOS_MCT
 
 config CLKSRC_SAMSUNG_PWM
 	bool "PWM timer driver for Samsung S3C, S5P" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	help
 	  This is a new clocksource driver for the PWM timer found in
@@ -436,7 +412,6 @@ config CLKSRC_SAMSUNG_PWM
 
 config FSL_FTM_TIMER
 	bool "Freescale FlexTimer Module driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	select CLKSRC_MMIO
 	help
@@ -450,7 +425,6 @@ config VF_PIT_TIMER
 
 config OXNAS_RPS_TIMER
 	bool "Oxford Semiconductor OXNAS RPS Timers driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select TIMER_OF
 	select CLKSRC_MMIO
 	help
@@ -461,7 +435,7 @@ config SYS_SUPPORTS_SH_CMT
 
 config MTK_TIMER
 	bool "Mediatek timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS && HAS_IOMEM
+	depends on HAS_IOMEM
 	select TIMER_OF
 	select CLKSRC_MMIO
 	help
@@ -479,7 +453,6 @@ config SYS_SUPPORTS_EM_STI
 config CLKSRC_JCORE_PIT
 	bool "J-Core PIT timer driver" if COMPILE_TEST
 	depends on OF
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	select CLKSRC_MMIO
 	help
@@ -488,7 +461,6 @@ config CLKSRC_JCORE_PIT
 
 config SH_TIMER_CMT
 	bool "Renesas CMT timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	default SYS_SUPPORTS_SH_CMT
 	help
@@ -498,7 +470,6 @@ config SH_TIMER_CMT
 
 config SH_TIMER_MTU2
 	bool "Renesas MTU2 timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	default SYS_SUPPORTS_SH_MTU2
 	help
@@ -508,14 +479,12 @@ config SH_TIMER_MTU2
 
 config RENESAS_OSTM
 	bool "Renesas OSTM timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	select CLKSRC_MMIO
 	help
 	  Enables the support for the Renesas OSTM.
 
 config SH_TIMER_TMU
 	bool "Renesas TMU timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	default SYS_SUPPORTS_SH_TMU
 	help
@@ -525,7 +494,7 @@ config SH_TIMER_TMU
 
 config EM_TIMER_STI
 	bool "Renesas STI timer driver" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS && HAS_IOMEM
+	depends on HAS_IOMEM
 	default SYS_SUPPORTS_EM_STI
 	help
 	  This enables build of a clocksource and clockevent driver for
@@ -566,7 +535,6 @@ config CLKSRC_TANGO_XTAL
 
 config CLKSRC_PXA
 	bool "Clocksource for PXA or SA-11x0 platform" if COMPILE_TEST
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAS_IOMEM
 	select CLKSRC_MMIO
 	help
@@ -575,20 +543,20 @@ config CLKSRC_PXA
 
 config H8300_TMR8
         bool "Clockevent timer for the H8300 platform" if COMPILE_TEST
-        depends on GENERIC_CLOCKEVENTS && HAS_IOMEM
+        depends on HAS_IOMEM
 	help
 	  This enables the 8 bits timer for the H8300 platform.
 
 config H8300_TMR16
         bool "Clockevent timer for the H83069 platform" if COMPILE_TEST
-        depends on GENERIC_CLOCKEVENTS && HAS_IOMEM
+        depends on HAS_IOMEM
 	help
 	  This enables the 16 bits timer for the H8300 platform with the
 	  H83069 cpu.
 
 config H8300_TPU
         bool "Clocksource for the H8300 platform" if COMPILE_TEST
-        depends on GENERIC_CLOCKEVENTS && HAS_IOMEM
+        depends on HAS_IOMEM
 	help
 	  This enables the clocksource for the H8300 platform with the
 	  H8S2678 cpu.
@@ -600,7 +568,7 @@ config CLKSRC_IMX_GPT
 
 config CLKSRC_IMX_TPM
 	bool "Clocksource using i.MX TPM" if COMPILE_TEST
-	depends on ARM && CLKDEV_LOOKUP && GENERIC_CLOCKEVENTS
+	depends on ARM && CLKDEV_LOOKUP
 	select CLKSRC_MMIO
 	help
 	  Enable this option to use IMX Timer/PWM Module (TPM) timer as
-- 
2.9.0

