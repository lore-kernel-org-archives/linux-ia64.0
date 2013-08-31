From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Sat, 31 Aug 2013 10:16:00 +0000
Subject: [PATCH 5/6] ACPI / processor: remove unnecessary if (!pr) check
Message-Id: <1377944162-18574-5-git-send-email-hanjun.guo@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org>
In-Reply-To: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-kernel@lists.linaro.org, linaro-acpi@lists.linaro.org, Hanjun Guo <hanjun.guo@linaro.org>

acpi_processor_errata() is only called in acpi_processor_get_info(),
and the argument 'pr' passed to acpi_processor_errata() will be never
NULL, so the if (!pr) check is unnecessary.

Since the 'pr' argument is not used by acpi_processor_errata() any more,
so change the argument into void.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
---
 drivers/acpi/acpi_processor.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index a2a71d0..d1cabe5 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -140,15 +140,11 @@ static int acpi_processor_errata_piix4(struct pci_dev *dev)
 	return 0;
 }
 
-static int acpi_processor_errata(struct acpi_processor *pr)
+static int acpi_processor_errata(void)
 {
 	int result = 0;
 	struct pci_dev *dev = NULL;
 
-
-	if (!pr)
-		return -EINVAL;
-
 	/*
 	 * PIIX4
 	 */
@@ -220,7 +216,7 @@ static int acpi_processor_get_info(struct acpi_device *device)
 	acpi_status status = AE_OK;
 	static int cpu0_initialized;
 
-	acpi_processor_errata(pr);
+	acpi_processor_errata();
 
 	/*
 	 * Check to see if we have bus mastering arbitration control.  This
-- 
1.7.9.5

