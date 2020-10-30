From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 30 Oct 2020 15:17:58 +0000
Subject: [PATCH v2 15/15] timekeeping: default GENERIC_CLOCKEVENTS to enabled
Message-Id: <20201030151758.1241164-16-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201030151758.1241164-1-arnd@kernel.org>
In-Reply-To: <20201030151758.1241164-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Ungerer <gerg@linux-m68k.org>, Finn Thain <fthain@telegraphics.com.au>, Philip Blundell <philb@gnu.org>, Joshua Thompson <funaho@jurai.org>, Sam Creasey <sammy@sammy.net>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Daniel Lezcano <daniel.lezcano@linaro.org>, John Stultz <john.stultz@linaro.org>, Stephen Boyd <sboyd@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>

From: Arnd Bergmann <arnd@arndb.de>

Almost all machines use GENERIC_CLOCKEVENTS, so it feels wrong to
require each one to select that symbol manually.

Instead, enable it whenever CONFIG_LEGACY_TIMER_TICK is disabled as
a simplification. It should be possible to select both
GENERIC_CLOCKEVENTS and LEGACY_TIMER_TICK from an architecture now
and decide at runtime between the two.

For the clockevents arch-support.txt file, this means that additional
architectures are marked as TODO when they have at least one machine
that still uses LEGACY_TIMER_TICK, rather than being marked 'ok' when
at least one machine has been converted. This means that both m68k and
arm (for riscpc) revert to TODO.

At this point, we could just always enable CONFIG_GENERIC_CLOCKEVENTS
rather than leaving it off when not needed. I built an m68k
defconfig kernel (using gcc-10.1.0) and found that this would add
around 5.5KB in kernel image size:

   text	   data	    bss	    dec	    hex	filename
3861936	1092236	 196656	5150828	 4e986c	obj-m68k/vmlinux-no-clockevent
3866201	1093832	 196184	5156217	 4ead79	obj-m68k/vmlinux-clockevent

On Arm (MACH_RPC), that difference appears to be twice as large,
around 11KB on top of an 6MB vmlinux.

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 .../features/time/clockevents/arch-support.txt       |  6 +++---
 arch/alpha/Kconfig                                   |  1 -
 arch/arc/Kconfig                                     |  1 -
 arch/arm/Kconfig                                     | 12 ------------
 arch/arm64/Kconfig                                   |  1 -
 arch/arm64/Kconfig.platforms                         |  1 -
 arch/c6x/Kconfig                                     |  1 -
 arch/csky/Kconfig                                    |  1 -
 arch/h8300/Kconfig                                   |  1 -
 arch/hexagon/Kconfig                                 |  1 -
 arch/m68k/Kconfig.cpu                                |  1 -
 arch/microblaze/Kconfig                              |  1 -
 arch/mips/Kconfig                                    |  1 -
 arch/nds32/Kconfig                                   |  1 -
 arch/nios2/Kconfig                                   |  1 -
 arch/openrisc/Kconfig                                |  1 -
 arch/powerpc/Kconfig                                 |  1 -
 arch/riscv/Kconfig                                   |  1 -
 arch/s390/Kconfig                                    |  1 -
 arch/sh/Kconfig                                      |  1 -
 arch/sparc/Kconfig                                   |  1 -
 arch/um/Kconfig                                      |  1 -
 arch/x86/Kconfig                                     |  1 -
 arch/xtensa/Kconfig                                  |  1 -
 kernel/time/Kconfig                                  |  2 +-
 25 files changed, 4 insertions(+), 38 deletions(-)

diff --git a/Documentation/features/time/clockevents/arch-support.txt b/Documentation/features/time/clockevents/arch-support.txt
index 61a5c9d68c15..6863a3fbddad 100644
--- a/Documentation/features/time/clockevents/arch-support.txt
+++ b/Documentation/features/time/clockevents/arch-support.txt
@@ -1,6 +1,6 @@
 #
 # Feature name:          clockevents
-#         Kconfig:       GENERIC_CLOCKEVENTS
+#         Kconfig:       !LEGACY_TIMER_TICK
 #         description:   arch support generic clock events
 #
     -----------------------
@@ -8,14 +8,14 @@
     -----------------------
     |       alpha: |  ok  |
     |         arc: |  ok  |
-    |         arm: |  ok  |
+    |         arm: | TODO |
     |       arm64: |  ok  |
     |         c6x: |  ok  |
     |        csky: |  ok  |
     |       h8300: |  ok  |
     |     hexagon: |  ok  |
     |        ia64: | TODO |
-    |        m68k: |  ok  |
+    |        m68k: | TODO |
     |  microblaze: |  ok  |
     |        mips: |  ok  |
     |       nds32: |  ok  |
diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index d6e9fc7a7b19..f0a700946cac 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -27,7 +27,6 @@ config ALPHA
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select AUDIT_ARCH
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CPU_VULNERABILITIES
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_STRNCPY_FROM_USER
diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index 0a89cc9def65..061eb8e23739 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -19,7 +19,6 @@ config ARC
 	select COMMON_CLK
 	select DMA_DIRECT_REMAP
 	select GENERIC_ATOMIC64 if !ISA_ARCV2 || !(ARC_HAS_LL64 && ARC_HAS_LLSC)
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_FIND_FIRST_BIT
 	# for now, we don't need GENERIC_IRQ_PROBE, CONFIG_GENERIC_IRQ_CHIP
 	select GENERIC_IRQ_SHOW
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index dbadfa186f72..04a37a4cd9e0 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -321,7 +321,6 @@ config ARCH_MULTIPLATFORM
 	select AUTO_ZRELADDR
 	select TIMER_OF
 	select COMMON_CLK
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_IRQ_MULTI_HANDLER
 	select HAVE_PCI
 	select PCI_DOMAINS_GENERIC if PCI
@@ -336,7 +335,6 @@ config ARM_SINGLE_ARMV7M
 	select TIMER_OF
 	select COMMON_CLK
 	select CPU_V7M
-	select GENERIC_CLOCKEVENTS
 	select NO_IOPORT_MAP
 	select SPARSE_IRQ
 	select USE_OF
@@ -351,7 +349,6 @@ config ARCH_EP93XX
 	select CLKDEV_LOOKUP
 	select CLKSRC_MMIO
 	select CPU_ARM920T
-	select GENERIC_CLOCKEVENTS
 	select GPIOLIB
 	select HAVE_LEGACY_CLK
 	help
@@ -361,7 +358,6 @@ config ARCH_FOOTBRIDGE
 	bool "FootBridge"
 	select CPU_SA110
 	select FOOTBRIDGE
-	select GENERIC_CLOCKEVENTS
 	select HAVE_IDE
 	select NEED_MACH_IO_H if !MMU
 	select NEED_MACH_MEMORY_H
@@ -389,7 +385,6 @@ config ARCH_IXP4XX
 	select ARCH_SUPPORTS_BIG_ENDIAN
 	select CPU_XSCALE
 	select DMABOUNCE if PCI
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_IRQ_MULTI_HANDLER
 	select GPIO_IXP4XX
 	select GPIOLIB
@@ -405,7 +400,6 @@ config ARCH_IXP4XX
 config ARCH_DOVE
 	bool "Marvell Dove"
 	select CPU_PJ4
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_IRQ_MULTI_HANDLER
 	select GPIOLIB
 	select HAVE_PCI
@@ -429,7 +423,6 @@ config ARCH_PXA
 	select CLKSRC_MMIO
 	select TIMER_OF
 	select CPU_XSCALE if !CPU_XSC3
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_IRQ_MULTI_HANDLER
 	select GPIO_PXA
 	select GPIOLIB
@@ -470,7 +463,6 @@ config ARCH_SA1100
 	select COMMON_CLK
 	select CPU_FREQ
 	select CPU_SA1100
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_IRQ_MULTI_HANDLER
 	select GPIOLIB
 	select HAVE_IDE
@@ -485,7 +477,6 @@ config ARCH_S3C24XX
 	bool "Samsung S3C24XX SoCs"
 	select ATAGS
 	select CLKSRC_SAMSUNG_PWM
-	select GENERIC_CLOCKEVENTS
 	select GPIO_SAMSUNG
 	select GPIOLIB
 	select GENERIC_IRQ_MULTI_HANDLER
@@ -509,7 +500,6 @@ config ARCH_OMAP1
 	select ARCH_OMAP
 	select CLKDEV_LOOKUP
 	select CLKSRC_MMIO
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_IRQ_CHIP
 	select GENERIC_IRQ_MULTI_HANDLER
 	select GPIOLIB
@@ -772,7 +762,6 @@ config ARCH_ACORN
 
 config PLAT_IOP
 	bool
-	select GENERIC_CLOCKEVENTS
 
 config PLAT_ORION
 	bool
@@ -1163,7 +1152,6 @@ config HAVE_SMP
 config SMP
 	bool "Symmetric Multi-Processing"
 	depends on CPU_V6K || CPU_V7
-	depends on GENERIC_CLOCKEVENTS
 	depends on HAVE_SMP
 	depends on MMU || ARM_MPU
 	select IRQ_WORK
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index f858c352f72a..fee87e4104fd 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -101,7 +101,6 @@ config ARM64
 	select FRAME_POINTER
 	select GENERIC_ALLOCATOR
 	select GENERIC_ARCH_TOPOLOGY
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CLOCKEVENTS_BROADCAST
 	select GENERIC_CPU_AUTOPROBE
 	select GENERIC_CPU_VULNERABILITIES
diff --git a/arch/arm64/Kconfig.platforms b/arch/arm64/Kconfig.platforms
index 6f2494dd6d60..748e6d8c3b94 100644
--- a/arch/arm64/Kconfig.platforms
+++ b/arch/arm64/Kconfig.platforms
@@ -256,7 +256,6 @@ config ARCH_TEGRA
 	select ARM_GIC_PM
 	select CLKSRC_MMIO
 	select TIMER_OF
-	select GENERIC_CLOCKEVENTS
 	select GPIOLIB
 	select PINCTRL
 	select PM
diff --git a/arch/c6x/Kconfig b/arch/c6x/Kconfig
index 48d66bf0465d..bdeeac28b1be 100644
--- a/arch/c6x/Kconfig
+++ b/arch/c6x/Kconfig
@@ -19,7 +19,6 @@ config C6X
 	select IRQ_DOMAIN
 	select OF
 	select OF_EARLY_FLATTREE
-	select GENERIC_CLOCKEVENTS
 	select MODULES_USE_ELF_RELA
 	select MMU_GATHER_NO_RANGE if MMU
 	select SET_FS
diff --git a/arch/csky/Kconfig b/arch/csky/Kconfig
index 268fad5f51cf..28fdf8303dff 100644
--- a/arch/csky/Kconfig
+++ b/arch/csky/Kconfig
@@ -28,7 +28,6 @@ config CSKY
 	select GENERIC_LIB_UCMPDI2
 	select GENERIC_ALLOCATOR
 	select GENERIC_ATOMIC64
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CPU_DEVICES
 	select GENERIC_IRQ_CHIP
 	select GENERIC_IRQ_PROBE
diff --git a/arch/h8300/Kconfig b/arch/h8300/Kconfig
index 7945de067e9f..3e3e0f16f7e0 100644
--- a/arch/h8300/Kconfig
+++ b/arch/h8300/Kconfig
@@ -12,7 +12,6 @@ config H8300
 	select FRAME_POINTER
 	select GENERIC_CPU_DEVICES
 	select MODULES_USE_ELF_RELA
-	select GENERIC_CLOCKEVENTS
 	select COMMON_CLK
 	select ARCH_WANT_FRAME_POINTERS
 	select OF
diff --git a/arch/hexagon/Kconfig b/arch/hexagon/Kconfig
index f2afabbadd43..6e00c16a36b5 100644
--- a/arch/hexagon/Kconfig
+++ b/arch/hexagon/Kconfig
@@ -27,7 +27,6 @@ config HEXAGON
 	select GENERIC_IOMAP
 	select GENERIC_SMP_IDLE_THREAD
 	select STACKTRACE_SUPPORT
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CLOCKEVENTS_BROADCAST
 	select MODULES_USE_ELF_RELA
 	select GENERIC_CPU_DEVICES
diff --git a/arch/m68k/Kconfig.cpu b/arch/m68k/Kconfig.cpu
index 648054d4f860..ce09f993d858 100644
--- a/arch/m68k/Kconfig.cpu
+++ b/arch/m68k/Kconfig.cpu
@@ -318,7 +318,6 @@ config M54xx
 
 config COLDFIRE_PIT_TIMER
 	bool
-	select GENERIC_CLOCKEVENTS
 
 config COLDFIRE_TIMERS
 	bool
diff --git a/arch/microblaze/Kconfig b/arch/microblaze/Kconfig
index 33925ffed68f..2f0d3f431faf 100644
--- a/arch/microblaze/Kconfig
+++ b/arch/microblaze/Kconfig
@@ -17,7 +17,6 @@ config MICROBLAZE
 	select COMMON_CLK
 	select DMA_DIRECT_REMAP if MMU
 	select GENERIC_ATOMIC64
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CPU_DEVICES
 	select GENERIC_IDLE_POLL_SETUP
 	select GENERIC_IRQ_PROBE
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 2000bb2b0220..077c4ae09550 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -21,7 +21,6 @@ config MIPS
 	select CPU_NO_EFFICIENT_FFS if (TARGET_ISA_REV < 1)
 	select CPU_PM if CPU_IDLE
 	select GENERIC_ATOMIC64 if !64BIT
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CMOS_UPDATE
 	select GENERIC_CPU_AUTOPROBE
 	select GENERIC_GETTIMEOFDAY
diff --git a/arch/nds32/Kconfig b/arch/nds32/Kconfig
index e8e541fd2267..62313902d75d 100644
--- a/arch/nds32/Kconfig
+++ b/arch/nds32/Kconfig
@@ -17,7 +17,6 @@ config NDS32
 	select DMA_DIRECT_REMAP
 	select GENERIC_ATOMIC64
 	select GENERIC_CPU_DEVICES
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_IRQ_CHIP
 	select GENERIC_IRQ_SHOW
 	select GENERIC_IOREMAP
diff --git a/arch/nios2/Kconfig b/arch/nios2/Kconfig
index c7c6ba6bec9d..c24955c81c92 100644
--- a/arch/nios2/Kconfig
+++ b/arch/nios2/Kconfig
@@ -10,7 +10,6 @@ config NIOS2
 	select COMMON_CLK
 	select TIMER_OF
 	select GENERIC_ATOMIC64
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CPU_DEVICES
 	select GENERIC_IRQ_PROBE
 	select GENERIC_IRQ_SHOW
diff --git a/arch/openrisc/Kconfig b/arch/openrisc/Kconfig
index 6233c6293180..591acc5990dc 100644
--- a/arch/openrisc/Kconfig
+++ b/arch/openrisc/Kconfig
@@ -24,7 +24,6 @@ config OPENRISC
 	select GENERIC_CPU_DEVICES
 	select HAVE_UID16
 	select GENERIC_ATOMIC64
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CLOCKEVENTS_BROADCAST
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index e9f13fe08492..57e2c75f76e9 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -163,7 +163,6 @@ config PPC
 	select EDAC_ATOMIC_SCRUB
 	select EDAC_SUPPORT
 	select GENERIC_ATOMIC64			if PPC32
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CLOCKEVENTS_BROADCAST	if SMP
 	select GENERIC_CMOS_UPDATE
 	select GENERIC_CPU_AUTOPROBE
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index 44377fd7860e..3842bbb4fe62 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -37,7 +37,6 @@ config RISCV
 	select EDAC_SUPPORT
 	select GENERIC_ARCH_TOPOLOGY if SMP
 	select GENERIC_ATOMIC64 if !64BIT
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_EARLY_IOREMAP
 	select GENERIC_GETTIMEOFDAY if HAVE_GENERIC_VDSO
 	select GENERIC_IOREMAP
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 4a2a12be04c9..db246781844d 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -116,7 +116,6 @@ config S390
 	select CLONE_BACKWARDS2
 	select DMA_OPS if PCI
 	select DYNAMIC_FTRACE if FUNCTION_TRACER
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CPU_AUTOPROBE
 	select GENERIC_CPU_VULNERABILITIES
 	select GENERIC_FIND_FIRST_BIT
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 159da4ed578f..5fa580219a86 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -16,7 +16,6 @@ config SUPERH
 	select CPU_NO_EFFICIENT_FFS
 	select DMA_DECLARE_COHERENT
 	select GENERIC_ATOMIC64
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CMOS_UPDATE if SH_SH03 || SH_DREAMCAST
 	select GENERIC_IDLE_POLL_SETUP
 	select GENERIC_IRQ_SHOW
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index a6ca135442f9..718c51cf2c6c 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -39,7 +39,6 @@ config SPARC
 	select HAVE_EBPF_JIT if SPARC64
 	select HAVE_DEBUG_BUGVERBOSE
 	select GENERIC_SMP_IDLE_THREAD
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
 	select MODULES_USE_ELF_RELA
diff --git a/arch/um/Kconfig b/arch/um/Kconfig
index 4b799fad8b48..43333e36e0ba 100644
--- a/arch/um/Kconfig
+++ b/arch/um/Kconfig
@@ -17,7 +17,6 @@ config UML
 	select NO_DMA
 	select GENERIC_IRQ_SHOW
 	select GENERIC_CPU_DEVICES
-	select GENERIC_CLOCKEVENTS
 	select HAVE_GCC_PLUGINS
 	select SET_FS
 	select TTY # Needed for line.c
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index f6946b81f74a..0498d7596ccc 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -108,7 +108,6 @@ config X86
 	select DCACHE_WORD_ACCESS
 	select EDAC_ATOMIC_SCRUB
 	select EDAC_SUPPORT
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_CLOCKEVENTS_BROADCAST	if X86_64 || (X86_32 && X86_LOCAL_APIC)
 	select GENERIC_CLOCKEVENTS_MIN_ADJUST
 	select GENERIC_CMOS_UPDATE
diff --git a/arch/xtensa/Kconfig b/arch/xtensa/Kconfig
index d0dfa50bd0bb..2611ba336af8 100644
--- a/arch/xtensa/Kconfig
+++ b/arch/xtensa/Kconfig
@@ -16,7 +16,6 @@ config XTENSA
 	select COMMON_CLK
 	select DMA_REMAP if MMU
 	select GENERIC_ATOMIC64
-	select GENERIC_CLOCKEVENTS
 	select GENERIC_IRQ_SHOW
 	select GENERIC_PCI_IOMAP
 	select GENERIC_SCHED_CLOCK
diff --git a/kernel/time/Kconfig b/kernel/time/Kconfig
index c6867f29d279..9a41848b6ebb 100644
--- a/kernel/time/Kconfig
+++ b/kernel/time/Kconfig
@@ -28,7 +28,7 @@ config GENERIC_TIME_VSYSCALL
 
 # The generic clock events infrastructure
 config GENERIC_CLOCKEVENTS
-	bool
+	def_bool !LEGACY_TIMER_TICK
 
 # Architecture can handle broadcast in a driver-agnostic way
 config ARCH_HAS_TICK_BROADCAST
-- 
2.27.0
