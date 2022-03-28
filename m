From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Mon, 28 Mar 2022 19:07:42 +0000
Subject: [PATCH 2/2] ia64: topology: Slightly simplify code
Message-Id: <bdb0d6ebe90f080e2c9749506a622f22299da412.1648494330.git.christophe.jaillet@wanadoo.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <452b20c160a20754022407acefd2abb170f43d14.1648494330.git.christophe.jaillet@wanadoo.fr>
In-Reply-To: <452b20c160a20754022407acefd2abb170f43d14.1648494330.git.christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>, linux-ia64@vger.kernel.org

cpu_cache_sysfs_exit() already clears '&all_cpu_cache_info[cpu].kobj'. So
there is no need to do it twice.

Remove the redundant memset() and slightly simplify code.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
This patch is provided as-is and is not even compile tested. I don't have the
cross-building toolchain for that.
---
 arch/ia64/kernel/topology.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 6adb84f05cbb..df58df614873 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -387,12 +387,8 @@ static int cache_remove_dev(unsigned int cpu)
 	for (i = 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++)
 		kobject_put(&(LEAF_KOBJECT_PTR(cpu,i)->kobj));
 
-	if (all_cpu_cache_info[cpu].kobj.parent) {
+	if (all_cpu_cache_info[cpu].kobj.parent)
 		kobject_put(&all_cpu_cache_info[cpu].kobj);
-		memset(&all_cpu_cache_info[cpu].kobj,
-			0,
-			sizeof(struct kobject));
-	}
 
 	cpu_cache_sysfs_exit(cpu);
 
-- 
2.32.0
