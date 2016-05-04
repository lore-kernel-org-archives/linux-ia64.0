From: Matt Fleming <matt@codeblueprint.co.uk>
Date: Wed, 04 May 2016 11:17:48 +0000
Subject: [PATCH 3/5] ia64: Reduce stack usage by iterating over nodemask
Message-Id: <1462360670-27993-4-git-send-email-matt@codeblueprint.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
In-Reply-To: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt Fleming <matt@codeblueprint.co.uk>

GCC complains about sn2_global_tlb_purge() because of the large stack
required by the function,

  arch/ia64/sn/kernel/sn2/sn2_smp.c: In function 'sn2_global_tlb_purge':
  arch/ia64/sn/kernel/sn2/sn2_smp.c:319:1: warning: the frame size of 2176 bytes is larger than 2048 bytes [-Wframe-larger-than=]

2048 bytes of the stack are consumed by the node ID array 'nasids[]'.
But we don't actually need to put the ID array on the stack and can
use nodemask operations.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>
Signed-off-by: Matt Fleming <matt@codeblueprint.co.uk>
---
 arch/ia64/sn/kernel/sn2/sn2_smp.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index f9c8d9fc5939..c98dc965fe82 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -54,7 +54,7 @@ sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
 			       volatile unsigned long *, unsigned long,
 			       volatile unsigned long *, unsigned long);
 void
-sn2_ptc_deadlock_recovery(short *, short, short, int,
+sn2_ptc_deadlock_recovery(nodemask_t, short, short, int,
 			  volatile unsigned long *, unsigned long,
 			  volatile unsigned long *, unsigned long);
 
@@ -169,7 +169,7 @@ sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 	int use_cpu_ptcga;
 	volatile unsigned long *ptc0, *ptc1;
 	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value, old_rr = 0;
-	short nasids[MAX_NUMNODES], nix;
+	short nix;
 	nodemask_t nodes_flushed;
 	int active, max_active, deadlock, flush_opt = sn2_flush_opt;
 
@@ -218,9 +218,7 @@ sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 	}
 
 	itc = ia64_get_itc();
-	nix = 0;
-	for_each_node_mask(cnode, nodes_flushed)
-		nasids[nix++] = cnodeid_to_nasid(cnode);
+	nix = nodes_weight(nodes_flushed);
 
 	rr_value = (mm->context << 3) | REGION_NUMBER(start);
 
@@ -270,8 +268,10 @@ sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 			data0 = (data0 & ~SH2_PTC_ADDR_MASK) | (start & SH2_PTC_ADDR_MASK);
 		deadlock = 0;
 		active = 0;
-		for (ibegin = 0, i = 0; i < nix; i++) {
-			nasid = nasids[i];
+		ibegin = 0;
+		i = 0;
+		for_each_node_mask(cnode, nodes_flushed) {
+			nasid = cnodeid_to_nasid(cnode);
 			if (use_cpu_ptcga && unlikely(nasid = mynasid)) {
 				ia64_ptcga(start, nbits << 2);
 				ia64_srlz_i();
@@ -286,13 +286,14 @@ sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 				if ((deadlock = wait_piowc())) {
 					if (flush_opt = 1)
 						goto done;
-					sn2_ptc_deadlock_recovery(nasids, ibegin, i, mynasid, ptc0, data0, ptc1, data1);
+					sn2_ptc_deadlock_recovery(nodes_flushed, ibegin, i, mynasid, ptc0, data0, ptc1, data1);
 					if (reset_max_active_on_deadlock())
 						max_active = 1;
 				}
 				active = 0;
 				ibegin = i + 1;
 			}
+			i++;
 		}
 		start += (1UL << nbits);
 	} while (start < end);
@@ -327,11 +328,12 @@ done:
  */
 
 void
-sn2_ptc_deadlock_recovery(short *nasids, short ib, short ie, int mynasid,
+sn2_ptc_deadlock_recovery(nodemask_t nodes, short ib, short ie, int mynasid,
 			  volatile unsigned long *ptc0, unsigned long data0,
 			  volatile unsigned long *ptc1, unsigned long data1)
 {
 	short nasid, i;
+	int cnode;
 	unsigned long *piows, zeroval, n;
 
 	__this_cpu_inc(ptcstats.deadlocks);
@@ -339,17 +341,26 @@ sn2_ptc_deadlock_recovery(short *nasids, short ib, short ie, int mynasid,
 	piows = (unsigned long *) pda->pio_write_status_addr;
 	zeroval = pda->pio_write_status_val;
 
+	i = 0;
+	for_each_node_mask(cnode, nodes) {
+		if (i < ib)
+			goto next;
+
+		if (i > ie)
+			break;
 
-	for (i=ib; i <= ie; i++) {
-		nasid = nasids[i];
+		nasid = cnodeid_to_nasid(cnode);
 		if (local_node_uses_ptc_ga(is_shub1()) && nasid = mynasid)
-			continue;
+			goto next;
+
 		ptc0 = CHANGE_NASID(nasid, ptc0);
 		if (ptc1)
 			ptc1 = CHANGE_NASID(nasid, ptc1);
 
 		n = sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows, zeroval);
 		__this_cpu_add(ptcstats.deadlocks2, n);
+next:
+		i++;
 	}
 
 }
-- 
2.7.3

