From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 03:55:25 +0000
Subject: [PATCH 10/36] ia64,rcu: convert call_rcu(sn_irq_info_free) to kfree_rcu()
Message-Id: <4D82D7AD.2060205@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Tejun Heo <tj@kernel.org>, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org



The rcu callback sn_irq_info_free() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(sn_irq_info_free).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 arch/ia64/sn/kernel/irq.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index 13c15d9..79ec328 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -136,8 +136,6 @@ static void sn_end_irq(unsigned int irq)
 		force_interrupt(irq);
 }
 
-static void sn_irq_info_free(struct rcu_head *head);
-
 struct sn_irq_info *sn_retarget_vector(struct sn_irq_info *sn_irq_info,
 				       nasid_t nasid, int slice)
 {
@@ -201,7 +199,7 @@ struct sn_irq_info *sn_retarget_vector(struct sn_irq_info *sn_irq_info,
 	spin_lock(&sn_irq_info_lock);
 	list_replace_rcu(&sn_irq_info->list, &new_irq_info->list);
 	spin_unlock(&sn_irq_info_lock);
-	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
+	kfree_rcu(sn_irq_info, rcu);
 
 
 finish_up:
@@ -363,14 +361,6 @@ static void unregister_intr_pda(struct sn_irq_info *sn_irq_info)
 	rcu_read_unlock();
 }
 
-static void sn_irq_info_free(struct rcu_head *head)
-{
-	struct sn_irq_info *sn_irq_info;
-
-	sn_irq_info = container_of(head, struct sn_irq_info, rcu);
-	kfree(sn_irq_info);
-}
-
 void sn_irq_fixup(struct pci_dev *pci_dev, struct sn_irq_info *sn_irq_info)
 {
 	nasid_t nasid = sn_irq_info->irq_nasid;
@@ -426,7 +416,7 @@ void sn_irq_unfixup(struct pci_dev *pci_dev)
 	spin_unlock(&sn_irq_info_lock);
 	if (list_empty(sn_irq_lh[sn_irq_info->irq_irq]))
 		free_irq_vector(sn_irq_info->irq_irq);
-	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
+	kfree_rcu(sn_irq_info, rcu);
 	pci_dev_put(pci_dev);
 
 }
-- 
1.7.4
