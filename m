From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 18 Dec 2018 10:24:13 +0000
Subject: [PATCH V3 2/2] Tools: Replace open encodings for NUMA_NO_NODE
Message-Id: <1545127933-10711-3-git-send-email-anshuman.khandual@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl, vkoul@kernel.org, sfr@canb.auug.org.au, dledford@redhat.com, mpe@ellerman.id.au, axboe@kernel.dk, jeffrey.t.kirsher@intel.com, david@redhat.com

From: Stephen Rothwell <sfr@canb.auug.org.au>

This replaces all open encodings in tools with NUMA_NO_NODE.
Also linux/numa.h is now needed for the perf build.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 tools/include/linux/numa.h | 16 ++++++++++++++++
 tools/perf/bench/numa.c    |  6 +++---
 2 files changed, 19 insertions(+), 3 deletions(-)
 create mode 100644 tools/include/linux/numa.h

diff --git a/tools/include/linux/numa.h b/tools/include/linux/numa.h
new file mode 100644
index 0000000..110b0e5
--- /dev/null
+++ b/tools/include/linux/numa.h
@@ -0,0 +1,16 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _LINUX_NUMA_H
+#define _LINUX_NUMA_H
+
+
+#ifdef CONFIG_NODES_SHIFT
+#define NODES_SHIFT     CONFIG_NODES_SHIFT
+#else
+#define NODES_SHIFT     0
+#endif
+
+#define MAX_NUMNODES    (1 << NODES_SHIFT)
+
+#define	NUMA_NO_NODE	(-1)
+
+#endif /* _LINUX_NUMA_H */
diff --git a/tools/perf/bench/numa.c b/tools/perf/bench/numa.c
index 4419551..e0ad5f1 100644
--- a/tools/perf/bench/numa.c
+++ b/tools/perf/bench/numa.c
@@ -298,7 +298,7 @@ static cpu_set_t bind_to_node(int target_node)
 
 	CPU_ZERO(&mask);
 
-	if (target_node = -1) {
+	if (target_node = NUMA_NO_NODE) {
 		for (cpu = 0; cpu < g->p.nr_cpus; cpu++)
 			CPU_SET(cpu, &mask);
 	} else {
@@ -339,7 +339,7 @@ static void bind_to_memnode(int node)
 	unsigned long nodemask;
 	int ret;
 
-	if (node = -1)
+	if (node = NUMA_NO_NODE)
 		return;
 
 	BUG_ON(g->p.nr_nodes > (int)sizeof(nodemask)*8);
@@ -1363,7 +1363,7 @@ static void init_thread_data(void)
 		int cpu;
 
 		/* Allow all nodes by default: */
-		td->bind_node = -1;
+		td->bind_node = NUMA_NO_NODE;
 
 		/* Allow all CPUs by default: */
 		CPU_ZERO(&td->bind_cpumask);
-- 
2.7.4
