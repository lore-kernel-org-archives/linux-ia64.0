From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 30 Apr 2008 07:51:06 +0000
Subject: [PATCH] ia64: fix section mismatch in arch/ia64/kernel/acpi.c
Message-Id: <481824EA.3000103@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <481824BE.2000409@jp.fujitsu.com>
In-Reply-To: <481824BE.2000409@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch kills:

	WARNING: vmlinux.o(.text+0x1702): Section mismatch in
	reference from the function acpi_register_ioapic() to the
	function .devinit.text:iosapic_init()

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/acpi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index c7467f8..19709a0 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -966,7 +966,7 @@ acpi_map_iosapics (void)
 fs_initcall(acpi_map_iosapics);
 #endif				/* CONFIG_ACPI_NUMA */
 
-int acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
+int __ref acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
 {
 	int err;
 
