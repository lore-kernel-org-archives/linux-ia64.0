From: James Hogan <james.hogan@imgtec.com>
Date: Tue, 13 Nov 2012 11:59:08 +0000
Subject: [PATCH 1/1] arch Kconfig: remove references to IRQ_PER_CPU
Message-Id: <1352807948-26920-1-git-send-email-james.hogan@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: uclinux-dist-devel@blackfin.uclinux.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-arch@vger.kernel.org, James Hogan <james.hogan@imgtec.com>, Thomas Gleixner <tglx@linutronix.de>, Mike Frysinger <vapier@gentoo.org>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>

The IRQ_PER_CPU Kconfig symbol was removed in the following commit:

Commit 6a58fb3bad099076f36f0f30f44507bc3275cdb6 ("genirq: Remove
CONFIG_IRQ_PER_CPU") merged in v2.6.39-rc1.

But IRQ_PER_CPU wasn't removed from any of the architecture Kconfig
files where it was defined or selected. It's completely unused so remove
the remaining references.

Signed-off-by: James Hogan <james.hogan@imgtec.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Mike Frysinger <vapier@gentoo.org>
Cc: Richard Kuo <rkuo@codeaurora.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Paul Mundt <lethal@linux-sh.org>
---
Based on v3.7-rc5.

Compile tested defconfigs for bfin, ia64, mips, parisc, powerpc, sh, but
not hexagon.

Grepped entire tree to check no references to CONFIG_IRQ_PER_CPU, and
grepped arch/ for Kconfig files referencing IRQ_PER_CPU.

 arch/blackfin/Kconfig |    1 -
 arch/hexagon/Kconfig  |    1 -
 arch/ia64/Kconfig     |    1 -
 arch/mips/Kconfig     |    1 -
 arch/parisc/Kconfig   |    1 -
 arch/powerpc/Kconfig  |    1 -
 arch/sh/Kconfig       |    3 ---
 7 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/arch/blackfin/Kconfig b/arch/blackfin/Kconfig
index b6f3ad5..c709715 100644
--- a/arch/blackfin/Kconfig
+++ b/arch/blackfin/Kconfig
@@ -38,7 +38,6 @@ config BLACKFIN
 	select HAVE_GENERIC_HARDIRQS
 	select GENERIC_ATOMIC64
 	select GENERIC_IRQ_PROBE
-	select IRQ_PER_CPU if SMP
 	select USE_GENERIC_SMP_HELPERS if SMP
 	select HAVE_NMI_WATCHDOG if NMI_WATCHDOG
 	select GENERIC_SMP_IDLE_THREAD
diff --git a/arch/hexagon/Kconfig b/arch/hexagon/Kconfig
index 0744f7d..800dd9c 100644
--- a/arch/hexagon/Kconfig
+++ b/arch/hexagon/Kconfig
@@ -12,7 +12,6 @@ config HEXAGON
 	# select ARCH_WANT_OPTIONAL_GPIOLIB
 	# select ARCH_REQUIRE_GPIOLIB
 	# select HAVE_CLK
-	# select IRQ_PER_CPU
 	# select GENERIC_PENDING_IRQ if SMP
 	select HAVE_IRQ_WORK
 	select GENERIC_ATOMIC64
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 3279646..00c2e88 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -29,7 +29,6 @@ config IA64
 	select ARCH_DISCARD_MEMBLOCK
 	select GENERIC_IRQ_PROBE
 	select GENERIC_PENDING_IRQ if SMP
-	select IRQ_PER_CPU
 	select GENERIC_IRQ_SHOW
 	select ARCH_WANT_OPTIONAL_GPIOLIB
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index dba9390..d47de79 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -2197,7 +2197,6 @@ source "mm/Kconfig"
 config SMP
 	bool "Multi-Processing support"
 	depends on SYS_SUPPORTS_SMP
-	select IRQ_PER_CPU
 	select USE_GENERIC_SMP_HELPERS
 	help
 	  This enables support for systems with more than one CPU. If you have
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 11def45..6d37987 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -16,7 +16,6 @@ config PARISC
 	select BROKEN_RODATA
 	select GENERIC_IRQ_PROBE
 	select GENERIC_PCI_IOMAP
-	select IRQ_PER_CPU
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_STRNCPY_FROM_USER
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index a902a5c..721dd7b 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -125,7 +125,6 @@ config PPC
 	select HAVE_GENERIC_HARDIRQS
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select SPARSE_IRQ
-	select IRQ_PER_CPU
 	select IRQ_DOMAIN
 	select GENERIC_IRQ_SHOW
 	select GENERIC_IRQ_SHOW_LEVEL
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index babc2b8..6f799ec 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -91,9 +91,6 @@ config GENERIC_CSUM
 config GENERIC_HWEIGHT
 	def_bool y
 
-config IRQ_PER_CPU
-	def_bool y
-
 config GENERIC_GPIO
 	def_bool n
 
-- 
1.7.7.6


