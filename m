From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 24 Mar 2005 22:57:47 +0000
Subject: [PATCH] use common pxm function
Message-Id: <1111705067.8284.14.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   That patch below simplifies a couple places where we search for _PXM
values in ACPI namespace.  Thanks,

	Alex

-- 
Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/hp/common/sba_iommu.c 1.51 vs edited ==--- 1.51/arch/ia64/hp/common/sba_iommu.c	2005-03-11 11:57:59 -07:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2005-03-24 14:35:28 -07:00
@@ -1928,43 +1928,17 @@
 static void __init
 sba_map_ioc_to_node(struct ioc *ioc, acpi_handle handle)
 {
-	struct acpi_buffer buffer = {ACPI_ALLOCATE_BUFFER, NULL};
-	union acpi_object *obj;
-	acpi_handle phandle;
 	unsigned int node;
+	int pxm;
 
 	ioc->node = MAX_NUMNODES;
 
-	/*
-	 * Check for a _PXM on this node first.  We don't typically see
-	 * one here, so we'll end up getting it from the parent.
-	 */
-	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_PXM", NULL, &buffer))) {
-		if (ACPI_FAILURE(acpi_get_parent(handle, &phandle)))
-			return;
+	pxm = acpi_get_pxm(handle);
 
-		/* Reset the acpi buffer */
-		buffer.length = ACPI_ALLOCATE_BUFFER;
-		buffer.pointer = NULL;
-
-		if (ACPI_FAILURE(acpi_evaluate_object(phandle, "_PXM", NULL,
-		                                      &buffer)))
-			return;
-	}
-
-	if (!buffer.length || !buffer.pointer)
-		return;
-
-	obj = buffer.pointer;
-
-	if (obj->type != ACPI_TYPE_INTEGER ||
-	    obj->integer.value >= MAX_PXM_DOMAINS) {
-		acpi_os_free(buffer.pointer);
+	if (pxm < 0)
 		return;
-	}
 
-	node = pxm_to_nid_map[obj->integer.value];
-	acpi_os_free(buffer.pointer);
+	node = pxm_to_nid_map[pxm];
 
 	if (node >= MAX_NUMNODES || !node_online(node))
 		return;
=== arch/ia64/kernel/acpi.c 1.83 vs edited ==--- 1.83/arch/ia64/kernel/acpi.c	2005-01-10 14:55:30 -07:00
+++ edited/arch/ia64/kernel/acpi.c	2005-03-24 14:35:35 -07:00
@@ -779,7 +779,7 @@
 	union acpi_object *obj;
 	struct acpi_table_iosapic *iosapic;
 	unsigned int gsi_base;
-	int node;
+	int pxm, node;
 
 	/* Only care about objects w/ a method that returns the MADT */
 	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
@@ -805,29 +805,16 @@
 	gsi_base = iosapic->global_irq_base;
 
 	acpi_os_free(buffer.pointer);
-	buffer.length = ACPI_ALLOCATE_BUFFER;
-	buffer.pointer = NULL;
 
 	/*
-	 * OK, it's an IOSAPIC MADT entry, look for a _PXM method to tell
+	 * OK, it's an IOSAPIC MADT entry, look for a _PXM value to tell
 	 * us which node to associate this with.
 	 */
-	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_PXM", NULL, &buffer)))
+	pxm = acpi_get_pxm(handle);
+	if (pxm < 0)
 		return AE_OK;
 
-	if (!buffer.length || !buffer.pointer)
-		return AE_OK;
-
-	obj = buffer.pointer;
-
-	if (obj->type != ACPI_TYPE_INTEGER ||
-	    obj->integer.value >= MAX_PXM_DOMAINS) {
-		acpi_os_free(buffer.pointer);
-		return AE_OK;
-	}
-
-	node = pxm_to_nid_map[obj->integer.value];
-	acpi_os_free(buffer.pointer);
+	node = pxm_to_nid_map[pxm];
 
 	if (node >= MAX_NUMNODES || !node_online(node) ||
 	    cpus_empty(node_to_cpumask(node)))


