From: Thiago Farina <tfransosi@gmail.com>
Date: Fri, 29 Apr 2011 16:28:02 +0000
Subject: [PATCH] acpi-cpufreq.c: Fix return statements.
Message-Id: <1304094482-32445-1-git-send-email-tfransosi@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Return statement is not a function so remove superfluous use of parenthesis.

Signed-off-by: Thiago Farina <tfransosi@gmail.com>
---
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
index 22f6152..af35a9b 100644
--- a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
+++ b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
@@ -209,7 +209,7 @@ processor_set_freq (
 
 migrate_end:
 	set_cpus_allowed_ptr(current, &saved_mask);
-	return (retval);
+	return retval;
 }
 
 
@@ -240,11 +240,11 @@ acpi_cpufreq_target (
 	result = cpufreq_frequency_table_target(policy,
 			data->freq_table, target_freq, relation, &next_state);
 	if (result)
-		return (result);
+		return result;
 
 	result = processor_set_freq(data, policy->cpu, next_state);
 
-	return (result);
+	return result;
 }
 
 
@@ -260,7 +260,7 @@ acpi_cpufreq_verify (
 	result = cpufreq_frequency_table_verify(policy,
 			data->freq_table);
 
-	return (result);
+	return result;
 }
 
 
@@ -277,7 +277,7 @@ acpi_cpufreq_cpu_init (
 
 	data = kzalloc(sizeof(struct cpufreq_acpi_io), GFP_KERNEL);
 	if (!data)
-		return (-ENOMEM);
+		return -ENOMEM;
 
 	acpi_io_data[cpu] = data;
 
@@ -363,7 +363,7 @@ acpi_cpufreq_cpu_init (
 	 * writing something to the appropriate registers. */
 	data->resume = 1;
 
-	return (result);
+	return result;
 
  err_freqfree:
 	kfree(data->freq_table);
@@ -373,7 +373,7 @@ acpi_cpufreq_cpu_init (
 	kfree(data);
 	acpi_io_data[cpu] = NULL;
 
-	return (result);
+	return result;
 }
 
 
@@ -393,7 +393,7 @@ acpi_cpufreq_cpu_exit (
 		kfree(data);
 	}
 
-	return (0);
+	return 0;
 }
 
 
@@ -430,7 +430,6 @@ acpi_cpufreq_exit (void)
 	dprintk("acpi_cpufreq_exit\n");
 
 	cpufreq_unregister_driver(&acpi_cpufreq_driver);
-	return;
 }
 
 
-- 
1.7.5.rc2.5.g60e19

