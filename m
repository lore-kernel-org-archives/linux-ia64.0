From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:31:09 +0000
Subject: [PATCH v2 09/11] ACPI: processor: open code acpi_processor_cleanup_pdc
Message-Id: <20091220193109.5545.705.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220192731.5545.20582.stgit@bob.kio>
In-Reply-To: <20091220192731.5545.20582.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

We have the acpi_object_list * right there in acpi_processor_set_pdc()
so it doesn't seem necessary for an entire helper function just to
free it.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 drivers/acpi/processor_pdc.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/acpi/processor_pdc.c b/drivers/acpi/processor_pdc.c
index 974de4e..deeba22 100644
--- a/drivers/acpi/processor_pdc.c
+++ b/drivers/acpi/processor_pdc.c
@@ -125,16 +125,6 @@ acpi_processor_eval_pdc(acpi_handle handle, struct acpi_object_list *pdc_in)
 	return status;
 }
 
-static void acpi_processor_cleanup_pdc(struct acpi_processor *pr)
-{
-	if (pr->pdc) {
-		kfree(pr->pdc->pointer->buffer.pointer);
-		kfree(pr->pdc->pointer);
-		kfree(pr->pdc);
-		pr->pdc = NULL;
-	}
-}
-
 void acpi_processor_set_pdc(struct acpi_processor *pr)
 {
 	struct acpi_object_list *obj_list;
@@ -147,7 +137,10 @@ void acpi_processor_set_pdc(struct acpi_processor *pr)
 		return;
 
 	acpi_processor_eval_pdc(pr->handle, obj_list);
-	acpi_processor_cleanup_pdc(pr);
+
+	kfree(obj_list->pointer->buffer.pointer);
+	kfree(obj_list->pointer);
+	kfree(obj_list);
 }
 EXPORT_SYMBOL_GPL(acpi_processor_set_pdc);
 

