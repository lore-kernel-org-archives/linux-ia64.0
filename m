From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 16 Sep 2015 13:59:19 +0000
Subject: [PATCH v2 1/5] ACPI / processor : add support for ACPI0010 processor container
Message-Id: <1442411963-14398-2-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
 <1442411963-14398-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1442411963-14398-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>

ACPI 6.0 adds support for optional processor container device which may
contain child objects that are either processor devices or other processor
containers. This allows representing hierarchical processor topologies.

It is declared using the _HID of ACPI0010. It is an abstract container
used to represent CPU topology and should not be used to hotplug
purposes.

This patch enables the support for these ACPI processor containers and
ensures the generic container/module devices are not created for them.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
---
 drivers/acpi/acpi_processor.c | 17 +++++++++++++++++
 include/acpi/processor.h      |  1 +
 2 files changed, 18 insertions(+)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index 985b8a83184e..6df6c0270cb1 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -496,7 +496,24 @@ static struct acpi_scan_handler processor_handler = {
 	},
 };
 
+static int acpi_processor_container_attach(struct acpi_device *dev,
+					   const struct acpi_device_id *id)
+{
+	return 1;
+}
+
+static const struct acpi_device_id processor_container_ids[] = {
+	{ ACPI_PROCESSOR_CONTAINER_HID, },
+	{ }
+};
+
+static struct acpi_scan_handler processor_container_handler = {
+	.ids = processor_container_ids,
+	.attach = acpi_processor_container_attach,
+};
+
 void __init acpi_processor_init(void)
 {
 	acpi_scan_add_handler_with_hotplug(&processor_handler, "processor");
+	acpi_scan_add_handler(&processor_container_handler);
 }
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index ff5f135f16b1..51b61dcdbd9c 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -9,6 +9,7 @@
 #define ACPI_PROCESSOR_CLASS		"processor"
 #define ACPI_PROCESSOR_DEVICE_NAME	"Processor"
 #define ACPI_PROCESSOR_DEVICE_HID	"ACPI0007"
+#define ACPI_PROCESSOR_CONTAINER_HID	"ACPI0010"
 
 #define ACPI_PROCESSOR_BUSY_METRIC	10
 
-- 
1.9.1

