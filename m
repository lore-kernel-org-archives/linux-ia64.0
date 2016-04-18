From: David Daney <ddaney.cavm@gmail.com>
Date: Mon, 18 Apr 2016 21:14:12 +0000
Subject: [PATCH v4 14/14] arm64, acpi, numa: Default enable ACPI_NUMA with NUMA
Message-Id: <1461014052-30788-15-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

From: Robert Richter <rrichter@cavium.com>

Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/acpi/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 5ce9f66..bacf245 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -292,7 +292,7 @@ config ACPI_NUMA
 	bool "NUMA support"
 	depends on NUMA
 	depends on (X86 || IA64 || ARM64)
-	default y if IA64_GENERIC || IA64_SGI_SN2
+	default y if IA64_GENERIC || IA64_SGI_SN2 || ARM64
 
 config ACPI_CUSTOM_DSDT_FILE
 	string "Custom DSDT Table file to include"
-- 
1.7.11.7

