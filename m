From: David Daney <ddaney.cavm@gmail.com>
Date: Tue, 24 May 2016 22:35:43 +0000
Subject: [PATCH v7 13/15] ACPI / processor: Add acpi_map_madt_entry().
Message-Id: <1464129345-18985-14-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

From: David Daney <david.daney@cavium.com>

Follow-on arm64 ACPI/NUMA patches need to map MADT entries very early
(before kmalloc is usable).

Add acpi_map_madt_entry() which, indirectly, uses
early_memremap()/early_memunmap() to access the table and parse out
the mpidr.  The existing implementation of map_madt_entry() is
modified to take a pointer to the MADT as a parameter and the callers
adjusted.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/acpi/processor_core.c | 26 ++++++++++++++++++++++----
 include/acpi/processor.h      |  1 +
 2 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index 33a38d6..9125d7d 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -108,13 +108,12 @@ static int map_gicc_mpidr(struct acpi_subtable_header *entry,
 	return -EINVAL;
 }
 
-static phys_cpuid_t map_madt_entry(int type, u32 acpi_id)
+static phys_cpuid_t map_madt_entry(struct acpi_table_madt *madt,
+				   int type, u32 acpi_id)
 {
 	unsigned long madt_end, entry;
 	phys_cpuid_t phys_id = PHYS_CPUID_INVALID;	/* CPU hardware ID */
-	struct acpi_table_madt *madt;
 
-	madt = get_madt_table();
 	if (!madt)
 		return phys_id;
 
@@ -145,6 +144,25 @@ static phys_cpuid_t map_madt_entry(int type, u32 acpi_id)
 	return phys_id;
 }
 
+phys_cpuid_t __init acpi_map_madt_entry(u32 acpi_id)
+{
+	struct acpi_table_madt *madt = NULL;
+	acpi_size tbl_size;
+	phys_cpuid_t rv;
+
+	acpi_get_table_with_size(ACPI_SIG_MADT, 0,
+				 (struct acpi_table_header **)&madt,
+				 &tbl_size);
+	if (!madt)
+		return PHYS_CPUID_INVALID;
+
+	rv = map_madt_entry(madt, 1, acpi_id);
+
+	early_acpi_os_unmap_memory(madt, tbl_size);
+
+	return rv;
+}
+
 static phys_cpuid_t map_mat_entry(acpi_handle handle, int type, u32 acpi_id)
 {
 	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
@@ -185,7 +203,7 @@ phys_cpuid_t acpi_get_phys_id(acpi_handle handle, int type, u32 acpi_id)
 
 	phys_id = map_mat_entry(handle, type, acpi_id);
 	if (invalid_phys_cpuid(phys_id))
-		phys_id = map_madt_entry(type, acpi_id);
+		phys_id = map_madt_entry(get_madt_table(), type, acpi_id);
 
 	return phys_id;
 }
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index 6f1805d..f473e66 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -309,6 +309,7 @@ static inline int acpi_processor_get_bios_limit(int cpu, unsigned int *limit)
 
 /* in processor_core.c */
 phys_cpuid_t acpi_get_phys_id(acpi_handle, int type, u32 acpi_id);
+phys_cpuid_t acpi_map_madt_entry(u32 acpi_id);
 int acpi_map_cpuid(phys_cpuid_t phys_id, u32 acpi_id);
 int acpi_get_cpuid(acpi_handle, int type, u32 acpi_id);
 
-- 
1.7.11.7

