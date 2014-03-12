From: tip-bot for Thomas Gleixner <tipbot@zytor.com>
Date: Wed, 12 Mar 2014 12:15:26 +0000
Subject: [tip:irq/core] ia64: Validate online cpus in irq_set_affinity() callbacks
Message-Id: <tip-785aebd0cfff52e735ad4fd188d3726b5affc8e5@git.kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140304203100.650414633@linutronix.de>
In-Reply-To: <20140304203100.650414633@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, fenghua.yu@intel.com, tglx@linutronix.de

Commit-ID:  785aebd0cfff52e735ad4fd188d3726b5affc8e5
Gitweb:     http://git.kernel.org/tip/785aebd0cfff52e735ad4fd188d3726b5affc8e5
Author:     Thomas Gleixner <tglx@linutronix.de>
AuthorDate: Tue, 4 Mar 2014 20:43:38 +0000
Committer:  Thomas Gleixner <tglx@linutronix.de>
CommitDate: Wed, 12 Mar 2014 13:07:40 +0100

ia64: Validate online cpus in irq_set_affinity() callbacks

The [user space] interface does not filter out offline cpus. It merily
guarantees that the mask contains at least one online cpu.

So the selector in the irq chip implementation needs to make sure to
pick only an online cpu because otherwise:

     Offline Core 1
     Set affinity to 0xe (is valid due to online mask 0xd)
     cpumask_first will pick core 1, which is offline

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: ia64 <linux-ia64@vger.kernel.org>
Link: http://lkml.kernel.org/r/20140304203100.650414633@linutronix.de
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/kernel/msi_ia64.c  | 10 ++--------
 arch/ia64/sn/kernel/irq.c    |  4 ++--
 arch/ia64/sn/kernel/msi_sn.c |  2 +-
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index fb2f1e6..c430f91 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -17,12 +17,9 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 {
 	struct msi_msg msg;
 	u32 addr, data;
-	int cpu = first_cpu(*cpu_mask);
+	int cpu = cpumask_first_and(cpu_mask, cpu_online_mask);
 	unsigned int irq = idata->irq;
 
-	if (!cpu_online(cpu))
-		return -1;
-
 	if (irq_prepare_move(irq, cpu))
 		return -1;
 
@@ -139,10 +136,7 @@ static int dmar_msi_set_affinity(struct irq_data *data,
 	unsigned int irq = data->irq;
 	struct irq_cfg *cfg = irq_cfg + irq;
 	struct msi_msg msg;
-	int cpu = cpumask_first(mask);
-
-	if (!cpu_online(cpu))
-		return -1;
+	int cpu = cpumask_first_and(mask, cpu_online_mask);
 
 	if (irq_prepare_move(irq, cpu))
 		return -1;
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index 62cf4dd..85d0951 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -209,8 +209,8 @@ static int sn_set_affinity_irq(struct irq_data *data,
 	nasid_t nasid;
 	int slice;
 
-	nasid = cpuid_to_nasid(cpumask_first(mask));
-	slice = cpuid_to_slice(cpumask_first(mask));
+	nasid = cpuid_to_nasid(cpumask_first_and(mask, cpu_online_mask));
+	slice = cpuid_to_slice(cpumask_first_and(mask, cpu_online_mask));
 
 	list_for_each_entry_safe(sn_irq_info, sn_irq_info_safe,
 				 sn_irq_lh[irq], list)
diff --git a/arch/ia64/sn/kernel/msi_sn.c b/arch/ia64/sn/kernel/msi_sn.c
index 2b98b9e..afc58d2 100644
--- a/arch/ia64/sn/kernel/msi_sn.c
+++ b/arch/ia64/sn/kernel/msi_sn.c
@@ -166,7 +166,7 @@ static int sn_set_msi_irq_affinity(struct irq_data *data,
 	struct sn_pcibus_provider *provider;
 	unsigned int cpu, irq = data->irq;
 
-	cpu = cpumask_first(cpu_mask);
+	cpu = cpumask_first_and(cpu_mask, cpu_online_mask);
 	sn_irq_info = sn_msi_info[irq].sn_irq_info;
 	if (sn_irq_info = NULL || sn_irq_info->irq_int_bit >= 0)
 		return -1;
