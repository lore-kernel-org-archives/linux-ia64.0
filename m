From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:19:45 +0000
Subject: [PATCH 08/11] ACPI: processor: change acpi_processor_eval_pdc
Message-Id: <20091220191944.4274.97945.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

acpi_processor_eval_pdc() really only needs a handle and an
acpi_object_list * to do its work.

No need to pass in a struct acpi_processor *, so let's be more specific
about what we want.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 drivers/acpi/processor_pdc.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/acpi/processor_pdc.c b/drivers/acpi/processor_pdc.c
index 23d2828..974de4e 100644
--- a/drivers/acpi/processor_pdc.c
+++ b/drivers/acpi/processor_pdc.c
@@ -97,13 +97,11 @@ static struct acpi_object_list *acpi_processor_alloc_pdc(void)
  * _PDC is required for a BIOS-OS handshake for most of the newer
  * ACPI processor features.
  */
-static int acpi_processor_eval_pdc(struct acpi_processor *pr)
+static int
+acpi_processor_eval_pdc(acpi_handle handle, struct acpi_object_list *pdc_in)
 {
-	struct acpi_object_list *pdc_in = pr->pdc;
 	acpi_status status = AE_OK;
 
-	if (!pdc_in)
-		return status;
 	if (idle_nomwait) {
 		/*
 		 * If mwait is disabled for CPU C-states, the C2C3_FFH access
@@ -118,7 +116,7 @@ static int acpi_processor_eval_pdc(struct acpi_processor *pr)
 		buffer[2] &= ~(ACPI_PDC_C_C2C3_FFH | ACPI_PDC_C_C1_FFH);
 
 	}
-	status = acpi_evaluate_object(pr->handle, "_PDC", pdc_in, NULL);
+	status = acpi_evaluate_object(handle, "_PDC", pdc_in, NULL);
 
 	if (ACPI_FAILURE(status))
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
@@ -148,9 +146,7 @@ void acpi_processor_set_pdc(struct acpi_processor *pr)
 	if (!obj_list)
 		return;
 
-	pr->pdc = obj_list;
-
-	acpi_processor_eval_pdc(pr);
+	acpi_processor_eval_pdc(pr->handle, obj_list);
 	acpi_processor_cleanup_pdc(pr);
 }
 EXPORT_SYMBOL_GPL(acpi_processor_set_pdc);

