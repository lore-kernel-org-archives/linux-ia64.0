From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Sat, 31 Aug 2013 10:15:59 +0000
Subject: [PATCH 4/6] ACPI / processor: remove some dead code in acpi_processor_get_info()
Message-Id: <1377944162-18574-4-git-send-email-hanjun.guo@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org>
In-Reply-To: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-kernel@lists.linaro.org, linaro-acpi@lists.linaro.org, Jiang Liu <jiang.liu@huawei.com>, Hanjun Guo <hanjun.guo@linaro.org>

From: Jiang Liu <jiang.liu@huawei.com>

errata.smp is used by anywhere, so variable assignment is meanless,
remove it.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
---
 drivers/acpi/acpi_processor.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index 488e5d8..a2a71d0 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -220,9 +220,6 @@ static int acpi_processor_get_info(struct acpi_device *device)
 	acpi_status status = AE_OK;
 	static int cpu0_initialized;
 
-	if (num_online_cpus() > 1)
-		errata.smp = TRUE;
-
 	acpi_processor_errata(pr);
 
 	/*
-- 
1.7.9.5

