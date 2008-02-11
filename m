From: Jes Sorensen <jes@sgi.com>
Date: Mon, 11 Feb 2008 14:10:19 +0000
Subject: [patch] CONFIG_SGI_SN2 - auto select NUMA and ACPI_NUMA
Message-Id: <47B0574B.4040506@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020801080300010709080004"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020801080300010709080004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

A small tidy up patch to auto-select CONFIG_NUMA and CONFIG_ACPI_NUMA
when selecting CONFIG_SGI_SN2 - this is to match whats done for
CONFIG_IA64_GENERIC.

Cheers,
Jes


--------------020801080300010709080004
Content-Type: text/plain;
 name="sn2-select-numa.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sn2-select-numa.diff"

Auto select CONFIG_NUMA and CONFIG_ACPI_NUMA when picking SN2, similar
to how they are selected automatically for CONFIG_IA64_GENERIC.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/Kconfig |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/arch/ia64/Kconfig
===================================================================
--- linux-2.6.orig/arch/ia64/Kconfig
+++ linux-2.6/arch/ia64/Kconfig
@@ -154,6 +154,8 @@ config IA64_HP_ZX1_SWIOTLB
 
 config IA64_SGI_SN2
 	bool "SGI-SN2"
+	select NUMA
+	select ACPI_NUMA
 	help
 	  Selecting this option will optimize the kernel for use on sn2 based
 	  systems, but the resulting kernel binary will not run on other

--------------020801080300010709080004--
