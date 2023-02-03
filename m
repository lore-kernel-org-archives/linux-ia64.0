From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:26 +0000
Subject: [RFC PATCH 15/32] ACPI: Move acpi_bus_trim_one() before acpi_scan_hot_remove()
Message-Id: <20230203135043.409192-16-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

A subsequent patch will change acpi_scan_hot_remove() to call
acpi_bus_trim_one() instead of acpi_bus_trim(), meaning it can no longer
rely on the prototype in the header file.

Move these functions further up the file.
No change in behaviour.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/scan.c | 76 ++++++++++++++++++++++-----------------------
 1 file changed, 38 insertions(+), 38 deletions(-)

diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 274344434282..cecf94192771 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -245,6 +245,44 @@ static int acpi_scan_try_to_offline(struct acpi_device *device)
 	return 0;
 }
 
+static int acpi_bus_trim_one(struct acpi_device *adev, void *not_used)
+{
+	struct acpi_scan_handler *handler = adev->handler;
+
+	acpi_dev_for_each_child_reverse(adev, acpi_bus_trim_one, NULL);
+
+	adev->flags.match_driver = false;
+	if (handler) {
+		if (handler->detach)
+			handler->detach(adev);
+
+		adev->handler = NULL;
+	} else {
+		device_release_driver(&adev->dev);
+	}
+	/*
+	 * Most likely, the device is going away, so put it into D3cold before
+	 * that.
+	 */
+	acpi_device_set_power(adev, ACPI_STATE_D3_COLD);
+	adev->flags.initialized = false;
+	acpi_device_clear_enumerated(adev);
+
+	return 0;
+}
+
+/**
+ * acpi_bus_trim - Detach scan handlers and drivers from ACPI device objects.
+ * @adev: Root of the ACPI namespace scope to walk.
+ *
+ * Must be called under acpi_scan_lock.
+ */
+void acpi_bus_trim(struct acpi_device *adev)
+{
+	acpi_bus_trim_one(adev, NULL);
+}
+EXPORT_SYMBOL_GPL(acpi_bus_trim);
+
 static int acpi_scan_hot_remove(struct acpi_device *device)
 {
 	acpi_handle handle = device->handle;
@@ -2453,44 +2491,6 @@ int acpi_bus_scan(acpi_handle handle)
 }
 EXPORT_SYMBOL(acpi_bus_scan);
 
-static int acpi_bus_trim_one(struct acpi_device *adev, void *not_used)
-{
-	struct acpi_scan_handler *handler = adev->handler;
-
-	acpi_dev_for_each_child_reverse(adev, acpi_bus_trim_one, NULL);
-
-	adev->flags.match_driver = false;
-	if (handler) {
-		if (handler->detach)
-			handler->detach(adev);
-
-		adev->handler = NULL;
-	} else {
-		device_release_driver(&adev->dev);
-	}
-	/*
-	 * Most likely, the device is going away, so put it into D3cold before
-	 * that.
-	 */
-	acpi_device_set_power(adev, ACPI_STATE_D3_COLD);
-	adev->flags.initialized = false;
-	acpi_device_clear_enumerated(adev);
-
-	return 0;
-}
-
-/**
- * acpi_bus_trim - Detach scan handlers and drivers from ACPI device objects.
- * @adev: Root of the ACPI namespace scope to walk.
- *
- * Must be called under acpi_scan_lock.
- */
-void acpi_bus_trim(struct acpi_device *adev)
-{
-	acpi_bus_trim_one(adev, NULL);
-}
-EXPORT_SYMBOL_GPL(acpi_bus_trim);
-
 int acpi_bus_register_early_device(int type)
 {
 	struct acpi_device *device = NULL;
-- 
2.30.2
