From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 07 Aug 2009 20:12:37 +0000
Subject: [PATCH] acpi-cpufreq: Read buffer overflow?
Message-Id: <4A7C8AB5.90503@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If `data->acpi_data.state_count' is 0, we read from data->acpi_data.states[-1].

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Unsure whether this can happen.

diff --git a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
index 7b43545..7cdd1f6 100644
--- a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
+++ b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
@@ -95,7 +95,7 @@ extract_clock (
 		if (value = data->acpi_data.states[i].status)
 			return data->acpi_data.states[i].core_frequency;
 	}
-	return data->acpi_data.states[i-1].core_frequency;
+	return i ? data->acpi_data.states[i-1].core_frequency : 0;
 }
 
 
