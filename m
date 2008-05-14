From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 14 May 2008 16:00:24 +0000
Subject: [PATCH]: Properly unregister legacy interrupts
Message-Id: <20080514160006.21168.22321.sendpatchset@prarit.bos.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

acpi_unregister_gsi() should "undo" what acpi_register_gsi() does.

On systems that have legacy interrupts, acpi_unregister_gsi erroneously calls
iosapci_unregister_intr() which is wrong to do and causes a loud warning.

acpi_unregister_gsi() should just return in these cases.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 78f28d8..f66de49 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -620,6 +620,9 @@ void acpi_unregister_gsi(u32 gsi)
 	if (acpi_irq_model = ACPI_IRQ_MODEL_PLATFORM)
 		return;
 
+	if (has_8259 && gsi < 16)
+		return;
+
 	iosapic_unregister_intr(gsi);
 }
 
