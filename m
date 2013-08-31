From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Sat, 31 Aug 2013 10:16:01 +0000
Subject: [PATCH 6/6] ACPI / processor: Remove outdated comments
Message-Id: <1377944162-18574-6-git-send-email-hanjun.guo@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org>
In-Reply-To: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-kernel@lists.linaro.org, linaro-acpi@lists.linaro.org, Hanjun Guo <hanjun.guo@linaro.org>

acpi_get_processor_id() can be find nowhere, and the acpi id
is synchronized to APIC id when acpi_get_cpuid() is called, so
the comments can be removed.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
---
 drivers/acpi/acpi_processor.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index d1cabe5..fa2412e 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -240,11 +240,6 @@ static int acpi_processor_get_info(struct acpi_device *device)
 			return -ENODEV;
 		}
 
-		/*
-		 * TBD: Synch processor ID (via LAPIC/LSAPIC structures) on SMP.
-		 *      >>> 'acpi_get_processor_id(acpi_id, &id)' in
-		 *      arch/xxx/acpi.c
-		 */
 		pr->acpi_id = object.processor.proc_id;
 	} else {
 		/*
-- 
1.7.9.5

