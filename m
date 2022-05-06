From: Peng Liu <liupeng256@huawei.com>
Date: Fri, 06 May 2022 01:58:01 +0000
Subject: [PATCH 2/2] null_blk: fix wrong use of nr_online_nodes
Message-Id: <20220506015801.757918-3-liupeng256@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220506015801.757918-1-liupeng256@huawei.com>
In-Reply-To: <20220506015801.757918-1-liupeng256@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bhelgaas@google.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, lorenzo.pieralisi@arm.com, guohanjun@huawei.com, sudeep.holla@arm.com, rafael@kernel.org, lenb@kernel.org, akpm@linux-foundation.org, logang@deltatee.com, martin.oliveira@eideticom.com, thunder.leizhen@huawei.com, axboe@kernel.dk, kch@nvidia.com, ming.lei@redhat.com, shinichiro.kawasaki@wdc.com, mcgrof@kernel.org, jiangguoqing@kylinos.cn, jpittman@redhat.com, dave@stgolabs.net, liupeng256@huawei.com, wangkefeng.wang@huawei.com, linux-block@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Certain systems are designed to have sparse/discontiguous nodes,
a valid node may be greater than nr_online_nodes. So, the use of
"nid >= nr_online_nodes" to judge if a node is online is wrong.

Node id is a basic parameter of the system, a user-configured node
must be checked as early as possible. Otherwise, it may cause panic
when calling some vulnerable functions such as node_online which
will cause panic if a very big node is received.

Check g_home_node once users config it, and use node_available to
make node-checking compatible with sparse/discontiguous nodes.

Fixes: 7ff684a683d7 ("null_blk: prevent crash from bad home_node value")
Signed-off-by: Peng Liu <liupeng256@huawei.com>
Suggested-by: Davidlohr Bueso <dave@stgolabs.net>
---
 drivers/block/null_blk/main.c | 45 ++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 17 deletions(-)

diff --git a/drivers/block/null_blk/main.c b/drivers/block/null_blk/main.c
index 05b1120e6623..995348d6e7e7 100644
--- a/drivers/block/null_blk/main.c
+++ b/drivers/block/null_blk/main.c
@@ -97,7 +97,33 @@ module_param_named(poll_queues, g_poll_queues, int, 0444);
 MODULE_PARM_DESC(poll_queues, "Number of IOPOLL submission queues");
 
 static int g_home_node = NUMA_NO_NODE;
-module_param_named(home_node, g_home_node, int, 0444);
+
+static int null_param_store_val(const char *str, int *val, int min, int max)
+{
+	int ret, new_val;
+
+	ret = kstrtoint(str, 10, &new_val);
+	if (ret)
+		return -EINVAL;
+
+	if (new_val < min || new_val > max)
+		return -EINVAL;
+
+	*val = new_val;
+	return 0;
+}
+
+static int null_set_home_node(const char *str, const struct kernel_param *kp)
+{
+	return null_param_store_val(str, &g_home_node, 0, MAX_NUMNODES - 1);
+}
+
+static const struct kernel_param_ops null_home_node_param_ops = {
+	.set	= null_set_home_node,
+	.get	= param_get_int,
+};
+
+device_param_cb(home_node, &null_home_node_param_ops, &g_home_node, 0444);
 MODULE_PARM_DESC(home_node, "Home node for the device");
 
 #ifdef CONFIG_BLK_DEV_NULL_BLK_FAULT_INJECTION
@@ -120,21 +146,6 @@ MODULE_PARM_DESC(init_hctx, "Fault injection to fail hctx init. init_hctx=<inter
 
 static int g_queue_mode = NULL_Q_MQ;
 
-static int null_param_store_val(const char *str, int *val, int min, int max)
-{
-	int ret, new_val;
-
-	ret = kstrtoint(str, 10, &new_val);
-	if (ret)
-		return -EINVAL;
-
-	if (new_val < min || new_val > max)
-		return -EINVAL;
-
-	*val = new_val;
-	return 0;
-}
-
 static int null_set_queue_mode(const char *str, const struct kernel_param *kp)
 {
 	return null_param_store_val(str, &g_queue_mode, NULL_Q_BIO, NULL_Q_MQ);
@@ -2107,7 +2118,7 @@ static int __init null_init(void)
 		g_max_sectors = BLK_DEF_MAX_SECTORS;
 	}
 
-	if (g_home_node != NUMA_NO_NODE && g_home_node >= nr_online_nodes) {
+	if (!node_available(g_home_node)) {
 		pr_err("invalid home_node value\n");
 		g_home_node = NUMA_NO_NODE;
 	}
-- 
2.25.1
