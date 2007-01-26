From: Len Brown <lenb@kernel.org>
Date: Fri, 26 Jan 2007 05:38:53 +0000
Subject: [PATCH] IA64: fix ACPI Kconfig issues
Message-Id: <200701260038.53310.lenb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0109E59A@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0109E59A@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

All IA64 systems except IA64_HP_SIM include ACPI and PCI.
So prevent IA64 Kconfigs that try to do irritating things like building
PCI without building ACPI.

Signed-off-by: Len Brown <len.brown@intel.com>

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index fcacfe2..4b35c93 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -11,6 +11,8 @@ menu "Processor type and features"
 
 config IA64
 	bool
+	select PCI if (!IA64_HP_SIM)
+	select ACPI if (!IA64_HP_SIM)
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
@@ -84,8 +86,6 @@ choice
 
 config IA64_GENERIC
 	bool "generic"
-	select ACPI
-	select PCI
 	select NUMA
 	select ACPI_NUMA
 	help
