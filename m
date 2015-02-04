From: al.stone@linaro.org
Date: Wed, 04 Feb 2015 00:21:43 +0000
Subject: [PATCH v2 4/5] ACPI: arm64: use the arch-specific ACPI _OSI method and ACPI blacklist
Message-Id: <1423009304-5007-5-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1423009304-5007-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1423009304-5007-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <al.stone@linaro.org>

Set the defaults for the arm64 kernel so that the arch-specific _OSI
method and blacklist are always used for ACPI.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 arch/arm64/Kconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 915aa16..d01d3f7 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -1,5 +1,7 @@
 config ARM64
 	def_bool y
+	select ACPI_ARCH_SPECIFIC_OSI if ACPI
+	select ACPI_ARCH_SPECIFIC_BLACKLIST if ACPI
 	select ACPI_REDUCED_HARDWARE_ONLY if ACPI
 	select ARCH_BINFMT_ELF_RANDOMIZE_PIE
 	select ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
-- 
2.1.0

