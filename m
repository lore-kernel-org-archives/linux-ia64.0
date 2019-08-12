From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 12 Aug 2019 15:04:50 +0000
Subject: [PATCH 3/5] efi: ia64: move SAL systab handling out of generic EFI code
Message-Id: <20190812150452.27983-4-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190812150452.27983-1-ard.biesheuvel@linaro.org>
In-Reply-To: <20190812150452.27983-1-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, James Morse <james.morse@arm.com>, Mario Limonciello <mario.limonciello@dell.com>, Narendra K <Narendra.K@dell.com>, Xiaofei Tan <tanxiaofei@huawei.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

The SAL systab is an Itanium specific EFI configuration table, so
move its handling into arch/ia64 where it belongs.

Cc; Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/ia64/include/asm/sal.h       | 1 +
 arch/ia64/include/asm/sn/sn_sal.h | 2 +-
 arch/ia64/kernel/efi.c            | 3 +++
 arch/ia64/kernel/setup.c          | 2 +-
 arch/x86/platform/efi/efi.c       | 1 -
 drivers/firmware/efi/efi.c        | 2 --
 include/linux/efi.h               | 1 -
 7 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/include/asm/sal.h b/arch/ia64/include/asm/sal.h
index 588f33156da6..08f5b6aaed73 100644
--- a/arch/ia64/include/asm/sal.h
+++ b/arch/ia64/include/asm/sal.h
@@ -43,6 +43,7 @@
 #include <asm/pal.h>
 #include <asm/fpu.h>
 
+extern unsigned long sal_systab_phys;
 extern spinlock_t sal_lock;
 
 /* SAL spec _requires_ eight args for each call. */
diff --git a/arch/ia64/include/asm/sn/sn_sal.h b/arch/ia64/include/asm/sn/sn_sal.h
index 1f5ff470a5a1..5142c444652d 100644
--- a/arch/ia64/include/asm/sn/sn_sal.h
+++ b/arch/ia64/include/asm/sn/sn_sal.h
@@ -167,7 +167,7 @@
 static inline u32
 sn_sal_rev(void)
 {
-	struct ia64_sal_systab *systab = __va(efi.sal_systab);
+	struct ia64_sal_systab *systab = __va(sal_systab_phys);
 
 	return (u32)(systab->sal_b_rev_major << 8 | systab->sal_b_rev_minor);
 }
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 3795d18276c4..0a34dcc435c6 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -47,8 +47,11 @@
 
 static __initdata unsigned long palo_phys;
 
+unsigned long sal_systab_phys = EFI_INVALID_TABLE_ADDR;
+
 static __initdata efi_config_table_type_t arch_tables[] = {
 	{PROCESSOR_ABSTRACTION_LAYER_OVERWRITE_GUID, "PALO", &palo_phys},
+	{SAL_SYSTEM_TABLE_GUID, "SALsystab", &sal_systab_phys},
 	{NULL_GUID, NULL, 0},
 };
 
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index c9cfa760cd57..0e1b4eb149b4 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -572,7 +572,7 @@ setup_arch (char **cmdline_p)
 	find_memory();
 
 	/* process SAL system table: */
-	ia64_sal_init(__va(efi.sal_systab));
+	ia64_sal_init(__va(sal_systab_phys));
 
 #ifdef CONFIG_ITANIUM
 	ia64_patch_rse((u64) __start___rse_patchlist, (u64) __end___rse_patchlist);
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 9866a3584765..6697c109c449 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -70,7 +70,6 @@ static const unsigned long * const efi_tables[] = {
 	&efi.acpi20,
 	&efi.smbios,
 	&efi.smbios3,
-	&efi.sal_systab,
 	&efi.boot_info,
 	&efi.hcdp,
 	&efi.uga,
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 4dfd873373bd..801925c5bcfb 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -39,7 +39,6 @@ struct efi __read_mostly efi = {
 	.acpi20			= EFI_INVALID_TABLE_ADDR,
 	.smbios			= EFI_INVALID_TABLE_ADDR,
 	.smbios3		= EFI_INVALID_TABLE_ADDR,
-	.sal_systab		= EFI_INVALID_TABLE_ADDR,
 	.boot_info		= EFI_INVALID_TABLE_ADDR,
 	.hcdp			= EFI_INVALID_TABLE_ADDR,
 	.uga			= EFI_INVALID_TABLE_ADDR,
@@ -456,7 +455,6 @@ static __initdata efi_config_table_type_t common_tables[] = {
 	{ACPI_TABLE_GUID, "ACPI", &efi.acpi},
 	{HCDP_TABLE_GUID, "HCDP", &efi.hcdp},
 	{MPS_TABLE_GUID, "MPS", &efi.mps},
-	{SAL_SYSTEM_TABLE_GUID, "SALsystab", &efi.sal_systab},
 	{SMBIOS_TABLE_GUID, "SMBIOS", &efi.smbios},
 	{SMBIOS3_TABLE_GUID, "SMBIOS 3.0", &efi.smbios3},
 	{UGA_IO_PROTOCOL_GUID, "UGA", &efi.uga},
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 171bb1005a10..f88318b85fb0 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -984,7 +984,6 @@ extern struct efi {
 	unsigned long acpi20;		/* ACPI table  (ACPI 2.0) */
 	unsigned long smbios;		/* SMBIOS table (32 bit entry point) */
 	unsigned long smbios3;		/* SMBIOS table (64 bit entry point) */
-	unsigned long sal_systab;	/* SAL system table */
 	unsigned long boot_info;	/* boot info table */
 	unsigned long hcdp;		/* HCDP table */
 	unsigned long uga;		/* UGA table */
-- 
2.17.1
