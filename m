From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Tue, 22 Jan 2008 19:42:07 +0000
Subject: [PATCH] [IA64]: constify function pointer tables
Message-Id: <Pine.LNX.4.64.0801222041410.5722@fbirervta.pbzchgretzou.qr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
---
 arch/ia64/hp/common/sba_iommu.c     |    2 +-
 arch/ia64/kernel/perfmon.c          |    2 +-
 arch/ia64/kernel/setup.c            |    2 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c   |    2 +-
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 45bf04e..8c0ae4f 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1871,7 +1871,7 @@ ioc_show(struct seq_file *s, void *v)
 	return 0;
 }
 
-static struct seq_operations ioc_seq_ops = {
+static const struct seq_operations ioc_seq_ops = {
 	.start = ioc_start,
 	.next  = ioc_next,
 	.stop  = ioc_stop,
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 73e7c2e..4d35756 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -5795,7 +5795,7 @@ pfm_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-struct seq_operations pfm_seq_ops = {
+const struct seq_operations pfm_seq_ops = {
 	.start =	pfm_proc_start,
  	.next =		pfm_proc_next,
  	.stop =		pfm_proc_stop,
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 4ac2b1f..68097f8 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -658,7 +658,7 @@ c_stop (struct seq_file *m, void *v)
 {
 }
 
-struct seq_operations cpuinfo_op = {
+const struct seq_operations cpuinfo_op = {
 	.start =	c_start,
 	.next =		c_next,
 	.stop =		c_stop,
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index f3c6932..dfc6bf1 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -523,7 +523,7 @@ static ssize_t sn2_ptc_proc_write(struct file *file, const char __user *user, si
 	return count;
 }
 
-static struct seq_operations sn2_ptc_seq_ops = {
+static const struct seq_operations sn2_ptc_seq_ops = {
 	.start = sn2_ptc_seq_start,
 	.next = sn2_ptc_seq_next,
 	.stop = sn2_ptc_seq_stop,
diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index 1a8e496..ca88274 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -577,7 +577,7 @@ static void sn_topology_stop(struct seq_file *m, void *v)
 /*
  * /proc/sgi_sn/sn_topology, read-only using seq_file
  */
-static struct seq_operations sn_topology_seq_ops = {
+static const struct seq_operations sn_topology_seq_ops = {
 	.start = sn_topology_start,
 	.next = sn_topology_next,
 	.stop = sn_topology_stop,
-- 
1.5.3.4

