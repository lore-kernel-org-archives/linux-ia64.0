From: Baoquan He <bhe@redhat.com>
Date: Mon, 05 May 2014 04:48:25 +0000
Subject: [Patch v3 1/2] introduce variable acpi_lapic into ia64
Message-Id: <1399265306-8553-1-git-send-email-bhe@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, dyoung@redhat.com, Baoquan He <bhe@redhat.com>

This variable was defined and assigned in x86, is used to indicate
whether LAPIC exists in MADT. Now introduce it into ia64 to help
make correct judgment when get information for acpi processor later.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 arch/ia64/include/asm/acpi.h | 1 +
 arch/ia64/kernel/acpi.c      | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index d651102..b478219 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -85,6 +85,7 @@ ia64_acpi_release_global_lock (unsigned int *lock)
 	((Acq) = ia64_acpi_release_global_lock(&facs->global_lock))
 
 #ifdef	CONFIG_ACPI
+extern int acpi_lapic;
 #define acpi_disabled 0	/* ACPI always enabled on IA64 */
 #define acpi_noirq 0	/* ACPI always enabled on IA64 */
 #define acpi_pci_disabled 0 /* ACPI PCI always enabled on IA64 */
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 0d407b3..615ef81 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -56,6 +56,7 @@
 
 #define PREFIX			"ACPI: "
 
+int acpi_lapic;
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
 
@@ -676,6 +677,8 @@ int __init early_acpi_boot_init(void)
 	if (ret < 1)
 		printk(KERN_ERR PREFIX
 		       "Error parsing MADT - no LAPIC entries\n");
+	else
+		acpi_lapic = 1;
 
 #ifdef CONFIG_SMP
 	if (available_cpus = 0) {
-- 
1.8.5.3

