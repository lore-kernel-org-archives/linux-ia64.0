From: Tejun Heo <tj@kernel.org>
Date: Sat, 24 Jan 2015 14:03:16 +0000
Subject: [PATCH 10/32] ia64: use %*pb[l] to print bitmaps including cpumasks and nodemasks
Message-Id: <1422108218-25398-11-git-send-email-tj@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1422108218-25398-1-git-send-email-tj@kernel.org>
In-Reply-To: <1422108218-25398-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

printk and friends can now formap bitmaps using '%*pb[l]'.  cpumask
and nodemask also provide cpumask_pr_args() and nodemask_pr_args()
respectively which can be used to generate the two printf arguments
necessary to format the specified cpu/nodemask.

This patch is dependent on the following two patches.

 lib/vsprintf: implement bitmap printing through '%*pb[l]'
 cpumask, nodemask: implement cpumask/nodemask_pr_args()

Please wait till the forementioned patches are merged to mainline
before applying to subsystem trees.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/topology.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index f295f9a..965ab42 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -217,14 +217,12 @@ static ssize_t show_number_of_sets(struct cache_info *this_leaf, char *buf)
 
 static ssize_t show_shared_cpu_map(struct cache_info *this_leaf, char *buf)
 {
-	ssize_t	len;
 	cpumask_t shared_cpu_map;
 
 	cpumask_and(&shared_cpu_map,
 				&this_leaf->shared_cpu_map, cpu_online_mask);
-	len = cpumask_scnprintf(buf, NR_CPUS+1, &shared_cpu_map);
-	len += sprintf(buf+len, "\n");
-	return len;
+	return scnprintf(buf, PAGE_SIZE, "%*pb\n",
+			 cpumask_pr_args(&shared_cpu_map));
 }
 
 static ssize_t show_type(struct cache_info *this_leaf, char *buf)
-- 
2.1.0

