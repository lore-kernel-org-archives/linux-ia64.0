From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:19:39 +0000
Subject: [PATCH 07/11] ACPI: processor: introduce acpi_processor_alloc_pdc()
Message-Id: <20091220191939.4274.19125.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

acpi_processor_init_pdc() isn't really doing anything interesting
with the struct acpi_processor * parameter. Its real job is to allocate
the buffer for the _PDC bits.

So rename the function to acpi_processor_alloc_pdc(), and just return
the struct acpi_object_list * it's supposed to allocate.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 drivers/acpi/processor_pdc.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/acpi/processor_pdc.c b/drivers/acpi/processor_pdc.c
index e786e2c..23d2828 100644
--- a/drivers/acpi/processor_pdc.c
+++ b/drivers/acpi/processor_pdc.c
@@ -54,26 +54,24 @@ static void acpi_set_pdc_bits(u32 *buf)
 	arch_acpi_set_pdc_bits(buf);
 }
 
-static void acpi_processor_init_pdc(struct acpi_processor *pr)
+static struct acpi_object_list *acpi_processor_alloc_pdc(void)
 {
 	struct acpi_object_list *obj_list;
 	union acpi_object *obj;
 	u32 *buf;
 
-	pr->pdc = NULL;
-
 	/* allocate and initialize pdc. It will be used later. */
 	obj_list = kmalloc(sizeof(struct acpi_object_list), GFP_KERNEL);
 	if (!obj_list) {
 		printk(KERN_ERR "Memory allocation error\n");
-		return;
+		return NULL;
 	}
 
 	obj = kmalloc(sizeof(union acpi_object), GFP_KERNEL);
 	if (!obj) {
 		printk(KERN_ERR "Memory allocation error\n");
 		kfree(obj_list);
-		return;
+		return NULL;
 	}
 
 	buf = kmalloc(12, GFP_KERNEL);
@@ -81,7 +79,7 @@ static void acpi_processor_init_pdc(struct acpi_processor *pr)
 		printk(KERN_ERR "Memory allocation error\n");
 		kfree(obj);
 		kfree(obj_list);
-		return;
+		return NULL;
 	}
 
 	acpi_set_pdc_bits(buf);
@@ -91,9 +89,8 @@ static void acpi_processor_init_pdc(struct acpi_processor *pr)
 	obj->buffer.pointer = (u8 *) buf;
 	obj_list->count = 1;
 	obj_list->pointer = obj;
-	pr->pdc = obj_list;
 
-	return;
+	return obj_list;
 }
 
 /*
@@ -142,10 +139,17 @@ static void acpi_processor_cleanup_pdc(struct acpi_processor *pr)
 
 void acpi_processor_set_pdc(struct acpi_processor *pr)
 {
+	struct acpi_object_list *obj_list;
+
 	if (arch_has_acpi_pdc() = false)
 		return;
 
-	acpi_processor_init_pdc(pr);
+	obj_list = acpi_processor_alloc_pdc();
+	if (!obj_list)
+		return;
+
+	pr->pdc = obj_list;
+
 	acpi_processor_eval_pdc(pr);
 	acpi_processor_cleanup_pdc(pr);
 }

