From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Tue, 25 Mar 2014 20:57:53 +0000
Subject: [PATCH v3 2/5] efi: Export arch_tables variable
Message-Id: <1395781076-12000-3-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com, Daniel Kiper <daniel.kiper@oracle.com>

Export arch_tables variable. Xen init function calls efi_config_init()
which takes it as an argument.

Additionally, put __initdata in place suggested by include/linux/init.h.

Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
---
 arch/x86/platform/efi/efi.c |    2 +-
 include/linux/efi.h         |    2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index e4af217..26651c6 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -70,7 +70,7 @@ static efi_system_table_t efi_systab __initdata;
 
 unsigned long x86_efi_facility;
 
-static __initdata efi_config_table_type_t arch_tables[] = {
+efi_config_table_type_t arch_tables[] __initdata = {
 #ifdef CONFIG_X86_UV
 	{UV_SYSTEM_TABLE_GUID, "UVsystab", &efi.uv_systab},
 #endif
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 67ba1a0..f00ef14 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -583,6 +583,8 @@ extern struct efi {
 	struct efi_memory_map *memmap;
 } efi;
 
+extern efi_config_table_type_t arch_tables[] __initdata;
+
 static inline int
 efi_guidcmp (efi_guid_t left, efi_guid_t right)
 {
-- 
1.7.10.4

