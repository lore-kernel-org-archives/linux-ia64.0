From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 24 May 2007 18:22:10 +0000
Subject: [PATCH] ia64-acpi section mismatch
Message-Id: <20070524112210.307857c7.randy.dunlap@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

On 2.6.22-rc2-git5:
WARNING: arch/ia64/kernel/built-in.o(.text+0x12): Section mismatch: reference to .init.text:acpi_find_rsdp (between 'acpi_get_sysname' and 'acpi_request_vector')

Looks like acpi_get_sysname() can be marked __init...

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 arch/ia64/kernel/acpi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2622-rc2g5.orig/arch/ia64/kernel/acpi.c
+++ linux-2622-rc2g5/arch/ia64/kernel/acpi.c
@@ -67,7 +67,7 @@ EXPORT_SYMBOL(pm_power_off);
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
 
-const char *acpi_get_sysname(void)
+const char * __init acpi_get_sysname(void)
 {
 #ifdef CONFIG_IA64_GENERIC
 	unsigned long rsdp_phys;
