From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Tue, 08 May 2007 16:22:47 +0000
Subject: [patch] save and restore cpus_allowed in cpu_idle_wait
Message-Id: <20070508162246.GC27756@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Save and Restore the task's cpus_allowed mask, across the set_cpus_allowed()
in cpu_idle_wait(). Without this, we will endup corrupting task's cpu affinity.

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
---

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index ae96d41..cba6ac3 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -237,6 +237,7 @@ void cpu_idle_wait(void)
 {
 	unsigned int cpu, this_cpu = get_cpu();
 	cpumask_t map;
+	cpumask_t tmp = current->cpus_allowed;
 
 	set_cpus_allowed(current, cpumask_of_cpu(this_cpu));
 	put_cpu();
@@ -258,6 +259,7 @@ void cpu_idle_wait(void)
 		}
 		cpus_and(map, map, cpu_online_map);
 	} while (!cpus_empty(map));
+	set_cpus_allowed(current, tmp);
 }
 EXPORT_SYMBOL_GPL(cpu_idle_wait);
 
