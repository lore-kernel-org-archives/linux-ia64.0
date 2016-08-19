From: Al Stone <ahs3@redhat.com>
Date: Fri, 19 Aug 2016 23:28:49 +0000
Subject: [PATCH 1/2] ia64: remove extraneous white space
Message-Id: <1471649330-32415-2-git-send-email-ahs3@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471649330-32415-1-git-send-email-ahs3@redhat.com>
In-Reply-To: <1471649330-32415-1-git-send-email-ahs3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: ahs3@redhat.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, trivial@kernel.org

Signed-off-by: Al Stone <ahs3@redhat.com>
---
 arch/ia64/sn/kernel/sn2/sn2_smp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index c98dc96..8701b2f 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -234,11 +234,11 @@ sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 		data0 = (1UL << SH2_PTC_A_SHFT) |
 			(nbits << SH2_PTC_PS_SHFT) |
 		    	(1UL << SH2_PTC_START_SHFT);
-		ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH2_PTC + 
+		ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH2_PTC +
 			(rr_value << SH2_PTC_RID_SHFT));
 		ptc1 = NULL;
 	}
-	
+
 
 	mynasid = get_nasid();
 	use_cpu_ptcga = local_node_uses_ptc_ga(shub1);
@@ -322,7 +322,7 @@ done:
 /*
  * sn2_ptc_deadlock_recovery
  *
- * Recover from PTC deadlocks conditions. Recovery requires stepping thru each 
+ * Recover from PTC deadlocks conditions. Recovery requires stepping thru each
  * TLB flush transaction.  The recovery sequence is somewhat tricky & is
  * coded in assembly language.
  */
@@ -417,7 +417,7 @@ EXPORT_SYMBOL(sn_send_IPI_phys);
  * @redirect: redirect the IPI?
  *
  * Sends an IPI (InterProcessor Interrupt) to the processor specified by
- * @cpuid.  @vector specifies the command to send, while @delivery_mode can 
+ * @cpuid.  @vector specifies the command to send, while @delivery_mode can
  * be one of the following
  *
  * %IA64_IPI_DM_INT - pend an interrupt
-- 
2.7.4

