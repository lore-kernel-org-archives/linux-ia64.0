From: John Keller <jpk@sgi.com>
Date: Fri, 02 Feb 2007 20:54:12 +0000
Subject: [PATCH 1/1] -  Altix: more ACPI PRT support
Message-Id: <20070202205412.14367.60290.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org
Cc: ayoung@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

The SN Altix platform does not conform to the 
IOSAPIC IRQ routing model. Add code in acpi_unregister_gsi()
to check if (acpi_irq_model = ACPI_IRQ_MODEL_PLATFORM) and
return.

Signed-off-by: John Keller <jpk@sgi.com>
---

Due to an oversight, this code was not added previously when
similar code was added to acpi_register_gsi().

http://marc.theaimsgroup.com/?l=linux-acpi&m6680983430121&w=2

 arch/ia64/kernel/acpi.c |    3 +++
 1 file changed, 3 insertions(+)


Index: linux-2.6/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/acpi.c	2007-02-02 14:44:31.000000000 -0600
+++ linux-2.6/arch/ia64/kernel/acpi.c	2007-02-02 14:47:44.658143727 -0600
@@ -609,6 +609,9 @@ EXPORT_SYMBOL(acpi_register_gsi);
 
 void acpi_unregister_gsi(u32 gsi)
 {
+	if (acpi_irq_model = ACPI_IRQ_MODEL_PLATFORM)
+		return;
+
 	iosapic_unregister_intr(gsi);
 }
 
