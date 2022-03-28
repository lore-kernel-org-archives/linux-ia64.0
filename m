From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Mon, 28 Mar 2022 19:07:31 +0000
Subject: [PATCH 1/2] ia64: topology: Fix an error handling path in cache_add_dev()
Message-Id: <452b20c160a20754022407acefd2abb170f43d14.1648494330.git.christophe.jaillet@wanadoo.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Zhang Yanmin <yanmin.zhang@intel.com>
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>, linux-ia64@vger.kernel.org

If kobject_init_and_add()fails, kobject_put() needs to be called.
Add the missing call which is already there a few lines below in another
error handling path.

Fixes: f19180056ea0 ("[IA64] Export cpu cache info by sysfs")
Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
This patch is provided as-is and is not even compile tested. I don't have the
cross-building toolchain for that.
---
 arch/ia64/kernel/topology.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 94a848b06f15..6adb84f05cbb 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -354,6 +354,7 @@ static int cache_add_dev(unsigned int cpu)
 				      &cache_ktype_percpu_entry, &sys_dev->kobj,
 				      "%s", "cache");
 	if (unlikely(retval < 0)) {
+		kobject_put(&all_cpu_cache_info[cpu].kobj);
 		cpu_cache_sysfs_exit(cpu);
 		return retval;
 	}
-- 
2.32.0
