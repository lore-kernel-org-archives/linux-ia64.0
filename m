From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 02 Dec 2015 14:10:44 +0000
Subject: [PATCH v3 3/5] ACPI / processor_idle: replace PREFIX with pr_fmt
Message-Id: <1449065446-26115-4-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>

Like few of the other ACPI modules, replace PREFIX with pr_fmt and
change all the printk call sites to use pr_* companion functions
in processor_idle.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
---
 drivers/acpi/processor_idle.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index a24067b850d2..fadce354d2b7 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -23,6 +23,7 @@
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
+#define pr_fmt(fmt) "ACPI: " fmt
 
 #include <linux/module.h>
 #include <linux/acpi.h>
@@ -42,8 +43,6 @@
 #include <asm/apic.h>
 #endif
 
-#define PREFIX "ACPI: "
-
 #define ACPI_PROCESSOR_CLASS            "processor"
 #define _COMPONENT              ACPI_PROCESSOR_COMPONENT
 ACPI_MODULE_NAME("processor_idle");
@@ -80,9 +79,9 @@ static int set_max_cstate(const struct dmi_system_id *id)
 	if (max_cstate > ACPI_PROCESSOR_MAX_POWER)
 		return 0;
 
-	printk(KERN_NOTICE PREFIX "%s detected - limiting to C%ld max_cstate."
-	       " Override with \"processor.max_cstate=%d\"\n", id->ident,
-	       (long)id->driver_data, ACPI_PROCESSOR_MAX_POWER + 1);
+	pr_notice("%s detected - limiting to C%ld max_cstate."
+		  " Override with \"processor.max_cstate=%d\"\n", id->ident,
+		  (long)id->driver_data, ACPI_PROCESSOR_MAX_POWER + 1);
 
 	max_cstate = (long)id->driver_data;
 
@@ -314,7 +313,7 @@ static int acpi_processor_get_power_info_cst(struct acpi_processor *pr)
 
 	/* There must be at least 2 elements */
 	if (!cst || (cst->type != ACPI_TYPE_PACKAGE) || cst->package.count < 2) {
-		printk(KERN_ERR PREFIX "not enough elements in _CST\n");
+		pr_err("not enough elements in _CST\n");
 		ret = -EFAULT;
 		goto end;
 	}
@@ -323,7 +322,7 @@ static int acpi_processor_get_power_info_cst(struct acpi_processor *pr)
 
 	/* Validate number of power states. */
 	if (count < 1 || count != cst->package.count - 1) {
-		printk(KERN_ERR PREFIX "count given by _CST is not valid\n");
+		pr_err("count given by _CST is not valid\n");
 		ret = -EFAULT;
 		goto end;
 	}
@@ -432,11 +431,9 @@ static int acpi_processor_get_power_info_cst(struct acpi_processor *pr)
 		 * (From 1 through ACPI_PROCESSOR_MAX_POWER - 1)
 		 */
 		if (current_count >= (ACPI_PROCESSOR_MAX_POWER - 1)) {
-			printk(KERN_WARNING
-			       "Limiting number of power states to max (%d)\n",
-			       ACPI_PROCESSOR_MAX_POWER);
-			printk(KERN_WARNING
-			       "Please increase ACPI_PROCESSOR_MAX_POWER if needed.\n");
+			pr_warn("Limiting number of power states to max (%d)\n",
+				ACPI_PROCESSOR_MAX_POWER);
+			pr_warn("Please increase ACPI_PROCESSOR_MAX_POWER if needed.\n");
 			break;
 		}
 	}
@@ -1060,8 +1057,8 @@ int acpi_processor_power_init(struct acpi_processor *pr)
 			retval = cpuidle_register_driver(&acpi_idle_driver);
 			if (retval)
 				return retval;
-			printk(KERN_DEBUG "ACPI: %s registered with cpuidle\n",
-					acpi_idle_driver.name);
+			pr_debug("%s registered with cpuidle\n",
+				 acpi_idle_driver.name);
 		}
 
 		dev = kzalloc(sizeof(*dev), GFP_KERNEL);
-- 
1.9.1

