From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 21 Mar 2013 03:50:30 +0000
Subject: [PATCH] mm/IA64: fix build error for numa_clear_node() under IA64
Message-Id: <1363837830-41596-1-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Jianguo Wu <wujianguo@huawei.com>, Yijing Wang <wangyijing@huawei.com>

numa_clear_node() function is not implemented under IA64,
it will be called in unmap_cpu_on_node() in mm/memory_hotplug.c.
This cause build error under IA64, this patch add numa_clear_node()
in IA64 to fix this problem.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/ia64/include/asm/numa.h |    5 ++---
 arch/ia64/mm/numa.c          |    5 +++++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/include/asm/numa.h b/arch/ia64/include/asm/numa.h
index 2e27ef1..2db0a6c 100644
--- a/arch/ia64/include/asm/numa.h
+++ b/arch/ia64/include/asm/numa.h
@@ -67,14 +67,13 @@ extern int paddr_to_nid(unsigned long paddr);
 
 extern void map_cpu_to_node(int cpu, int nid);
 extern void unmap_cpu_from_node(int cpu, int nid);
-
+extern void numa_clear_node(int cpu);
 
 #else /* !CONFIG_NUMA */
 #define map_cpu_to_node(cpu, nid)	do{}while(0)
 #define unmap_cpu_from_node(cpu, nid)	do{}while(0)
-
 #define paddr_to_nid(addr)	0
-
+#define numa_clear_node(cpu)	do { } while (0)
 #endif /* CONFIG_NUMA */
 
 #endif /* _ASM_IA64_NUMA_H */
diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
index 3efea7d..9488922 100644
--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -73,6 +73,11 @@ int __meminit __early_pfn_to_nid(unsigned long pfn)
 	return -1;
 }
 
+void numa_clear_node(int cpu)
+{
+	unmap_cpu_from_node(cpu, NUMA_NO_NODE);
+}
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
  *  SRAT information is stored in node_memblk[], then we can use SRAT
-- 
1.7.1


