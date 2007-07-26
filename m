From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 26 Jul 2007 06:31:34 +0000
Subject: [PATCH 2/3] Fix wrong assumption in acpi_gsi_to_irq
Message-Id: <1185431495.3917.68.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64's acpi_gsi_to_irq() function assumes irq = vector. But in
fact irq can be different from vector. This patch fix this wrong
assumption.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/acpi.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

Index: linux-2.6.23-rc1/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/kernel/acpi.c
+++ linux-2.6.23-rc1/arch/ia64/kernel/acpi.c
@@ -739,16 +739,15 @@ int __init acpi_boot_init(void)
 
 int acpi_gsi_to_irq(u32 gsi, unsigned int *irq)
 {
-	int vector;
+	int tmp;
 
 	if (has_8259 && gsi < 16)
 		*irq = isa_irq_to_vector(gsi);
 	else {
-		vector = gsi_to_vector(gsi);
-		if (vector = -1)
+		tmp = gsi_to_irq(gsi);
+		if (tmp = -1)
 			return -1;
-
-		*irq = vector;
+		*irq = tmp;
 	}
 	return 0;
 }


