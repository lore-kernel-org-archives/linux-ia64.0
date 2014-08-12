From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Tue, 12 Aug 2014 22:48:35 +0000
Subject: [PATCH v2] arch: Kconfig: Let all little endian architectures define CPU_LITTLE_ENDIAN explicitly
Message-Id: <53EA99C3.90203@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: akpm@linux-foundation.org, Geert Uytterhoeven <geert@linux-m68k.org>, Jean Delvare <jdelvare@suse.de>, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, msalter@redhat.com, a-jacquiot@ti.com, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org

x86 and ia64 are always little endian. And another architectures may be
little endian: mips, sh, powerpc, and m32r (may mark CPU_LITTLE_ENDIAN
explicitly); also arm(64) and c6x (which may be !CPU_BIG_ENDIAN).

Some drivers (e.g. some of "drivers/isdn/hisax") may only support little
endian (CPU_LITTLE_ENDIAN), and some drivers may only support big endian
(!CPU_LITTLE_ENDIAN).

So export all little endian architectures within kernel wide, so can let
Kconfig easier for the modules which only support little endian or only
for big endian (assume !CPU_LITTLE_ENDIAN is same as CPU_BIG_ENDIAN).


Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 arch/arm/Kconfig   | 5 +++++
 arch/arm64/Kconfig | 4 ++++
 arch/c6x/Kconfig   | 4 ++++
 arch/ia64/Kconfig  | 3 +++
 arch/x86/Kconfig   | 3 +++
 5 files changed, 19 insertions(+)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index c49a775..0510a5d 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -199,6 +199,11 @@ config NEED_DMA_MAP_STATE
 config ARCH_SUPPORTS_UPROBES
 	def_bool y
 
+config CPU_LITTLE_ENDIAN
+	depends on !CPU_BIG_ENDIAN
+	def_bool y
+
+
 config ARCH_HAS_DMA_SET_COHERENT_MASK
 	bool
 
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 62b4ae1..290a253 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -129,6 +129,10 @@ config KERNEL_MODE_NEON
 config FIX_EARLYCON_MEM
 	def_bool y
 
+config CPU_LITTLE_ENDIAN
+	depends on !CPU_BIG_ENDIAN
+	def_bool y
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
diff --git a/arch/c6x/Kconfig b/arch/c6x/Kconfig
index 77ea09b..56a8f53 100644
--- a/arch/c6x/Kconfig
+++ b/arch/c6x/Kconfig
@@ -48,6 +48,10 @@ config C6X_BIG_KERNEL
 
 	  If unsure, say N.
 
+config CPU_LITTLE_ENDIAN
+	depends on !CPU_BIG_ENDIAN
+	def_bool y
+
 source "init/Kconfig"
 
 # Use the generic interrupt handling code in kernel/irq/
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 64aefb7..fa12d34 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -133,6 +133,9 @@ config AUDIT_ARCH
 	bool
 	default y
 
+config CPU_LITTLE_ENDIAN
+	def_bool y
+
 menuconfig PARAVIRT_GUEST
 	bool "Paravirtualized guest support"
 	depends on BROKEN
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 541e7cc..a1b3568 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -270,6 +270,9 @@ config ARCH_SUPPORTS_UPROBES
 config FIX_EARLYCON_MEM
 	def_bool y
 
+config CPU_LITTLE_ENDIAN
+	def_bool y
+
 source "init/Kconfig"
 source "kernel/Kconfig.freezer"
 
-- 
1.7.11.7
