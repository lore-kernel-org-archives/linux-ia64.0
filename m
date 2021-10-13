From: Sasha Levin <sashal@kernel.org>
Date: Wed, 13 Oct 2021 00:54:41 +0000
Subject: [PATCH AUTOSEL 5.14 17/17] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <20211013005441.699846-17-sashal@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211013005441.699846-1-sashal@kernel.org>
In-Reply-To: <20211013005441.699846-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Bjorn Andersson <bjorn.andersson@linaro.org>, Charles Keepax <ckeepax@opensource.cirrus.com>, Will Deacon <will@kernel.org>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Sasha Levin <sashal@kernel.org>, linux@armlinux.org.uk, catalin.marinas@arm.com, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, geert+renesas@glider.be, linus.walleij@linaro.org, rmk+kernel@armlinux.org.uk, akpm@linux-foundation.org, anshuman.khandual@arm.com, rppt@kernel.org, ardb@kernel.org, u.kleine-koenig@pengutronix.de, lukas.bulwahn@gmail.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, slyfox@gentoo.org, axboe@kernel.dk, rientjes@google.com, dan.j.williams@intel.com, gregkh@linuxfoundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org

From: Arnd Bergmann <arnd@arndb.de>

[ Upstream commit 951cd3a0866d29cb9c01ebc1d9c17590e598226e ]

Compile-testing drivers that require access to a firmware layer
fails when that firmware symbol is unavailable. This happened
twice this week:

 - My proposed to change to rework the QCOM_SCM firmware symbol
   broke on ppc64 and others.

 - The cs_dsp firmware patch added device specific firmware loader
   into drivers/firmware, which broke on the same set of
   architectures.

We should probably do the same thing for other subsystems as well,
but fix this one first as this is a dependency for other patches
getting merged.

Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>
Reviewed-by: Charles Keepax <ckeepax@opensource.cirrus.com>
Acked-by: Will Deacon <will@kernel.org>
Acked-by: Bjorn Andersson <bjorn.andersson@linaro.org>
Cc: Mark Brown <broonie@kernel.org>
Cc: Liam Girdwood <lgirdwood@gmail.com>
Cc: Charles Keepax <ckeepax@opensource.cirrus.com>
Cc: Simon Trimmer <simont@opensource.cirrus.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Reviewed-by: Mark Brown <broonie@kernel.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/arm/Kconfig    | 2 --
 arch/arm64/Kconfig  | 2 --
 arch/ia64/Kconfig   | 2 --
 arch/mips/Kconfig   | 2 --
 arch/parisc/Kconfig | 2 --
 arch/riscv/Kconfig  | 2 --
 arch/x86/Kconfig    | 2 --
 drivers/Kconfig     | 2 ++
 8 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 2fb7012c3246..1c6e03a350ca 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1994,8 +1994,6 @@ config ARCH_HIBERNATION_POSSIBLE
 
 endmenu
 
-source "drivers/firmware/Kconfig"
-
 if CRYPTO
 source "arch/arm/crypto/Kconfig"
 endif
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 62c3c1d2190f..01c682b8b8c7 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -1935,8 +1935,6 @@ source "drivers/cpufreq/Kconfig"
 
 endmenu
 
-source "drivers/firmware/Kconfig"
-
 source "drivers/acpi/Kconfig"
 
 source "arch/arm64/kvm/Kconfig"
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 4993c7ac7ff6..3f867225efc2 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -386,8 +386,6 @@ config CRASH_DUMP
 	  help
 	    Generate crash dump after being started by kexec.
 
-source "drivers/firmware/Kconfig"
-
 endmenu
 
 menu "Power management and ACPI options"
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 6dfb27d531dd..a193b1440f88 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -3343,8 +3343,6 @@ source "drivers/cpuidle/Kconfig"
 
 endmenu
 
-source "drivers/firmware/Kconfig"
-
 source "arch/mips/kvm/Kconfig"
 
 source "arch/mips/vdso/Kconfig"
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 4f8c1fbf8f2f..f1c0ebd9d959 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -385,6 +385,4 @@ config KEXEC_FILE
 
 endmenu
 
-source "drivers/firmware/Kconfig"
-
 source "drivers/parisc/Kconfig"
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index 4f7b70ae7c31..b70e921af40d 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -558,5 +558,3 @@ menu "Power management options"
 source "kernel/power/Kconfig"
 
 endmenu
-
-source "drivers/firmware/Kconfig"
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 88fb922c23a0..ab3153ccecb9 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2854,8 +2854,6 @@ config HAVE_ATOMIC_IOMAP
 	def_bool y
 	depends on X86_32
 
-source "drivers/firmware/Kconfig"
-
 source "arch/x86/kvm/Kconfig"
 
 source "arch/x86/Kconfig.assembler"
diff --git a/drivers/Kconfig b/drivers/Kconfig
index 8bad63417a50..1f96367b4d98 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -17,6 +17,8 @@ source "drivers/bus/Kconfig"
 
 source "drivers/connector/Kconfig"
 
+source "drivers/firmware/Kconfig"
+
 source "drivers/gnss/Kconfig"
 
 source "drivers/mtd/Kconfig"
-- 
2.33.0
