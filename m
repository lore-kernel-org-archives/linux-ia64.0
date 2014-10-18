From: Joseph Wessner <joseph@wessner.org>
Date: Sat, 18 Oct 2014 21:21:10 +0000
Subject: [PATCH] Arch: ia64: kernel: acpi: fixed a brace coding style issue.
Message-Id: <1413667270-28890-1-git-send-email-joseph@wessner.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Joseph Wessner <joseph@wessner.org>

Fixed a coding style issue.

Signed-off-by: Joseph Wessner <joseph@wessner.org>
---
 arch/ia64/kernel/acpi.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 615ef81..12c032e 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -273,9 +273,8 @@ acpi_parse_plat_int_src(struct acpi_subtable_header * header,
 						IOSAPIC_EDGE : IOSAPIC_LEVEL);
 
 	platform_intr_list[plintsrc->type] = vector;
-	if (acpi_madt_rev > 1) {
+	if (acpi_madt_rev > 1)
 		acpi_cpei_override = plintsrc->flags & ACPI_MADT_CPEI_OVERRIDE;
-	}
 
 	/*
 	 * Save the physical id, so we can check when its being removed
-- 
2.1.2

