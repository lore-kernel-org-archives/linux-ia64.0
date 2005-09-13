From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 13 Sep 2005 06:49:59 +0000
Subject: [PATCH 2.6.14-rc1] fix typo in acpi_register_ioapic()
Message-Id: <43267697.7020008@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I found a typo in acpi_register_ioapic(). The following patch
fixes this.

Thanks,
Kenji Kaneshige


This patch fixes the typo in acpi_register_ioapic().

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

 arch/ia64/kernel/acpi.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.14-rc1/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.14-rc1.orig/arch/ia64/kernel/acpi.c
+++ linux-2.6.14-rc1/arch/ia64/kernel/acpi.c
@@ -899,7 +899,7 @@ int acpi_register_ioapic(acpi_handle han
 	if ((err = iosapic_init(phys_addr, gsi_base)))
 		return err;
 
-#if CONFIG_ACPI_NUMA
+#ifdef CONFIG_ACPI_NUMA
 	acpi_map_iosapic(handle, 0, NULL, NULL);
 #endif				/* CONFIG_ACPI_NUMA */
 

