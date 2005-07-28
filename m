From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 28 Jul 2005 07:51:11 +0000
Subject: [PATCH 2.6.13-rc3 1/6] failure of acpi_register_gsi() should be handled
Message-Id: <42E88E6F.50805@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E88DC8.7050507@jp.fujitsu.com>
In-Reply-To: <42E88DC8.7050507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


This patch changes the type of return value of acpi_register_gsi()
from "unsigned int" to "int" to indicate an error. If
acpi_register_gsi() fails to register gsi, it returns negative value.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.13-rc3-kanesige/arch/i386/kernel/acpi/boot.c |    6 +++++-
 linux-2.6.13-rc3-kanesige/arch/ia64/kernel/acpi.c      |    6 +++++-
 linux-2.6.13-rc3-kanesige/include/linux/acpi.h         |    2 +-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff -puN arch/i386/kernel/acpi/boot.c~handle-error-acpi_register_gsi arch/i386/kernel/acpi/boot.c
--- linux-2.6.13-rc3/arch/i386/kernel/acpi/boot.c~handle-error-acpi_register_gsi	2005-07-28 01:01:14.000000000 +0900
+++ linux-2.6.13-rc3-kanesige/arch/i386/kernel/acpi/boot.c	2005-07-28 01:01:14.000000000 +0900
@@ -484,7 +484,11 @@ int acpi_gsi_to_irq(u32 gsi, unsigned in
 	return 0;
 }
 
-unsigned int acpi_register_gsi(u32 gsi, int edge_level, int active_high_low)
+/*
+ * success: return IRQ number (>=0)
+ * failure: return < 0
+ */
+int acpi_register_gsi(u32 gsi, int edge_level, int active_high_low)
 {
 	unsigned int irq;
 	unsigned int plat_gsi = gsi;
diff -puN arch/ia64/kernel/acpi.c~handle-error-acpi_register_gsi arch/ia64/kernel/acpi.c
--- linux-2.6.13-rc3/arch/ia64/kernel/acpi.c~handle-error-acpi_register_gsi	2005-07-28 01:01:14.000000000 +0900
+++ linux-2.6.13-rc3-kanesige/arch/ia64/kernel/acpi.c	2005-07-28 01:01:14.000000000 +0900
@@ -563,7 +563,11 @@ acpi_numa_arch_fixup (void)
 }
 #endif /* CONFIG_ACPI_NUMA */
 
-unsigned int
+/*
+ * success: return IRQ number (>=0)
+ * failure: return < 0
+ */
+int
 acpi_register_gsi (u32 gsi, int edge_level, int active_high_low)
 {
 	if (has_8259 && gsi < 16)
diff -puN include/linux/acpi.h~handle-error-acpi_register_gsi include/linux/acpi.h
--- linux-2.6.13-rc3/include/linux/acpi.h~handle-error-acpi_register_gsi	2005-07-28 01:01:14.000000000 +0900
+++ linux-2.6.13-rc3-kanesige/include/linux/acpi.h	2005-07-28 01:01:14.000000000 +0900
@@ -445,7 +445,7 @@ static inline int acpi_boot_table_init(v
 
 #endif 	/*!CONFIG_ACPI_BOOT*/
 
-unsigned int acpi_register_gsi (u32 gsi, int edge_level, int active_high_low);
+int acpi_register_gsi (u32 gsi, int edge_level, int active_high_low);
 int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 
 /*

_


