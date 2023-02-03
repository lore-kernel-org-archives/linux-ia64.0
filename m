From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:22 +0000
Subject: [RFC PATCH 11/32] ACPI: processor: Add support for processors described as container packages
Message-Id: <20230203135043.409192-12-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

ACPI has two ways of describing processors in the DSDT. Either as a device
object with HID ACPI0007, or as a type 'C' package inside a Processor
Container. The ACPI processor driver probes CPUs described as devices, but
not those described as packages.

Duplicate descriptions are not allowed, the ACPI processor driver already
parses the UID from both devices and containers. acpi_processor_get_info()
returns an error if the UID exists twice in the DSDT.

The missing probe for CPUs described as packages creates a problem for
move the cpu_register() calls into the acpi_processor driver, as CPUs
described like this don't get registered, leading to errors from other
subsystems when they try to add new sysfs entries to the CPU node.
(e.g. topology_sysfs_init()'s use of topology_add_dev() via cpuhp)

To fix this, parse the processor container and call acpi_processor_add()
for each processor that is discovered like this. The processor container
handler is added with acpi_scan_add_handler(), so no detach call will
arrive.

Qemu TCG describes CPUs using packages in a processor container.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/acpi_processor.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index 16b314340e68..52668fa22c51 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -528,9 +528,33 @@ static struct acpi_scan_handler processor_handler = {
 	},
 };
 
+static acpi_status acpi_processor_container_walk(acpi_handle handle,
+						  u32 lvl,
+						  void *context,
+						  void **rv)
+{
+	struct acpi_device *adev;
+	acpi_status status;
+
+	adev = acpi_get_acpi_dev(handle);
+	if (!adev)
+		return AE_ERROR;
+
+	status = acpi_processor_add(adev, &processor_device_ids[0]);
+	acpi_put_acpi_dev(adev);
+
+	return status;
+}
+
 static int acpi_processor_container_attach(struct acpi_device *dev,
 					   const struct acpi_device_id *id)
 {
+	acpi_walk_namespace(ACPI_TYPE_PROCESSOR, dev->handle,
+						ACPI_UINT32_MAX,
+						acpi_processor_container_walk,
+						NULL, NULL, NULL);
+
+
 	return 1;
 }
 
-- 
2.30.2
