From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Thu, 01 Oct 2009 21:55:16 +0000
Subject: [PATCH take2] ia64: Restore registers in the stack on INIT
Message-Id: <B7CA42E1DC728Dindou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, kexec@lists.infradead.org

Hi,

Thanks for the comments, I updated my patch. The purpose of this patch
is written in the first mail I sent.
http://www.spinics.net/lists/linux-ia64/msg07553.html

I write here the summary of the patch again just in case. The problem
I found is that the registers are not saved anywhere when INIT comes
during fsys mode and we cannot know what happened when we investigate
vmcore captured by kdump. This patch adds new function
finish_pt_regs() so registers can be saved in such a case.

Signed-off-by: Takao Indoh <indou.takao@jp.fujitsu.com>
---
 arch/ia64/kernel/mca.c |  104 +++++++++++++++++++++------------------
 1 file changed, 57 insertions(+), 47 deletions(-)

diff -Nurp linux-2.6.31.org/arch/ia64/kernel/mca.c linux-2.6.31/arch/ia64/kernel/mca.c
--- linux-2.6.31.org/arch/ia64/kernel/mca.c	2009-09-21 17:12:45.000000000 -0400
+++ linux-2.6.31/arch/ia64/kernel/mca.c	2009-10-01 12:00:59.000000000 -0400
@@ -887,6 +887,60 @@ ia64_mca_modify_comm(const struct task_s
 	memcpy(current->comm, comm, sizeof(current->comm));
 }
 
+static void
+finish_pt_regs(struct pt_regs *regs, const pal_min_state_area_t *ms,
+		unsigned long *nat)
+{
+	const u64 *bank;
+
+	/* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
+	 * pmsa_{xip,xpsr,xfs}
+	 */
+	if (ia64_psr(regs)->ic) {
+		regs->cr_iip = ms->pmsa_iip;
+		regs->cr_ipsr = ms->pmsa_ipsr;
+		regs->cr_ifs = ms->pmsa_ifs;
+	} else {
+		regs->cr_iip = ms->pmsa_xip;
+		regs->cr_ipsr = ms->pmsa_xpsr;
+		regs->cr_ifs = ms->pmsa_xfs;
+	}
+	regs->pr = ms->pmsa_pr;
+	regs->b0 = ms->pmsa_br0;
+	regs->ar_rsc = ms->pmsa_rsc;
+	copy_reg(&ms->pmsa_gr[1-1], ms->pmsa_nat_bits, &regs->r1, nat);
+	copy_reg(&ms->pmsa_gr[2-1], ms->pmsa_nat_bits, &regs->r2, nat);
+	copy_reg(&ms->pmsa_gr[3-1], ms->pmsa_nat_bits, &regs->r3, nat);
+	copy_reg(&ms->pmsa_gr[8-1], ms->pmsa_nat_bits, &regs->r8, nat);
+	copy_reg(&ms->pmsa_gr[9-1], ms->pmsa_nat_bits, &regs->r9, nat);
+	copy_reg(&ms->pmsa_gr[10-1], ms->pmsa_nat_bits, &regs->r10, nat);
+	copy_reg(&ms->pmsa_gr[11-1], ms->pmsa_nat_bits, &regs->r11, nat);
+	copy_reg(&ms->pmsa_gr[12-1], ms->pmsa_nat_bits, &regs->r12, nat);
+	copy_reg(&ms->pmsa_gr[13-1], ms->pmsa_nat_bits, &regs->r13, nat);
+	copy_reg(&ms->pmsa_gr[14-1], ms->pmsa_nat_bits, &regs->r14, nat);
+	copy_reg(&ms->pmsa_gr[15-1], ms->pmsa_nat_bits, &regs->r15, nat);
+	if (ia64_psr(regs)->bn)
+		bank = ms->pmsa_bank1_gr;
+	else
+		bank = ms->pmsa_bank0_gr;
+	copy_reg(&bank[16-16], ms->pmsa_nat_bits, &regs->r16, nat);
+	copy_reg(&bank[17-16], ms->pmsa_nat_bits, &regs->r17, nat);
+	copy_reg(&bank[18-16], ms->pmsa_nat_bits, &regs->r18, nat);
+	copy_reg(&bank[19-16], ms->pmsa_nat_bits, &regs->r19, nat);
+	copy_reg(&bank[20-16], ms->pmsa_nat_bits, &regs->r20, nat);
+	copy_reg(&bank[21-16], ms->pmsa_nat_bits, &regs->r21, nat);
+	copy_reg(&bank[22-16], ms->pmsa_nat_bits, &regs->r22, nat);
+	copy_reg(&bank[23-16], ms->pmsa_nat_bits, &regs->r23, nat);
+	copy_reg(&bank[24-16], ms->pmsa_nat_bits, &regs->r24, nat);
+	copy_reg(&bank[25-16], ms->pmsa_nat_bits, &regs->r25, nat);
+	copy_reg(&bank[26-16], ms->pmsa_nat_bits, &regs->r26, nat);
+	copy_reg(&bank[27-16], ms->pmsa_nat_bits, &regs->r27, nat);
+	copy_reg(&bank[28-16], ms->pmsa_nat_bits, &regs->r28, nat);
+	copy_reg(&bank[29-16], ms->pmsa_nat_bits, &regs->r29, nat);
+	copy_reg(&bank[30-16], ms->pmsa_nat_bits, &regs->r30, nat);
+	copy_reg(&bank[31-16], ms->pmsa_nat_bits, &regs->r31, nat);
+}
+
 /* On entry to this routine, we are running on the per cpu stack, see
  * mca_asm.h.  The original stack has not been touched by this event.  Some of
  * the original stack's registers will be in the RBS on this stack.  This stack
@@ -921,7 +975,6 @@ ia64_mca_modify_original_stack(struct pt
 	u64 r12 = ms->pmsa_gr[12-1], r13 = ms->pmsa_gr[13-1];
 	u64 ar_bspstore = regs->ar_bspstore;
 	u64 ar_bsp = regs->ar_bspstore + (loadrs >> 16);
-	const u64 *bank;
 	const char *msg;
 	int cpu = smp_processor_id();
 
@@ -1024,54 +1077,9 @@ ia64_mca_modify_original_stack(struct pt
 	p = (char *)r12 - sizeof(*regs);
 	old_regs = (struct pt_regs *)p;
 	memcpy(old_regs, regs, sizeof(*regs));
-	/* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
-	 * pmsa_{xip,xpsr,xfs}
-	 */
-	if (ia64_psr(regs)->ic) {
-		old_regs->cr_iip = ms->pmsa_iip;
-		old_regs->cr_ipsr = ms->pmsa_ipsr;
-		old_regs->cr_ifs = ms->pmsa_ifs;
-	} else {
-		old_regs->cr_iip = ms->pmsa_xip;
-		old_regs->cr_ipsr = ms->pmsa_xpsr;
-		old_regs->cr_ifs = ms->pmsa_xfs;
-	}
-	old_regs->pr = ms->pmsa_pr;
-	old_regs->b0 = ms->pmsa_br0;
 	old_regs->loadrs = loadrs;
-	old_regs->ar_rsc = ms->pmsa_rsc;
 	old_unat = old_regs->ar_unat;
-	copy_reg(&ms->pmsa_gr[1-1], ms->pmsa_nat_bits, &old_regs->r1, &old_unat);
-	copy_reg(&ms->pmsa_gr[2-1], ms->pmsa_nat_bits, &old_regs->r2, &old_unat);
-	copy_reg(&ms->pmsa_gr[3-1], ms->pmsa_nat_bits, &old_regs->r3, &old_unat);
-	copy_reg(&ms->pmsa_gr[8-1], ms->pmsa_nat_bits, &old_regs->r8, &old_unat);
-	copy_reg(&ms->pmsa_gr[9-1], ms->pmsa_nat_bits, &old_regs->r9, &old_unat);
-	copy_reg(&ms->pmsa_gr[10-1], ms->pmsa_nat_bits, &old_regs->r10, &old_unat);
-	copy_reg(&ms->pmsa_gr[11-1], ms->pmsa_nat_bits, &old_regs->r11, &old_unat);
-	copy_reg(&ms->pmsa_gr[12-1], ms->pmsa_nat_bits, &old_regs->r12, &old_unat);
-	copy_reg(&ms->pmsa_gr[13-1], ms->pmsa_nat_bits, &old_regs->r13, &old_unat);
-	copy_reg(&ms->pmsa_gr[14-1], ms->pmsa_nat_bits, &old_regs->r14, &old_unat);
-	copy_reg(&ms->pmsa_gr[15-1], ms->pmsa_nat_bits, &old_regs->r15, &old_unat);
-	if (ia64_psr(old_regs)->bn)
-		bank = ms->pmsa_bank1_gr;
-	else
-		bank = ms->pmsa_bank0_gr;
-	copy_reg(&bank[16-16], ms->pmsa_nat_bits, &old_regs->r16, &old_unat);
-	copy_reg(&bank[17-16], ms->pmsa_nat_bits, &old_regs->r17, &old_unat);
-	copy_reg(&bank[18-16], ms->pmsa_nat_bits, &old_regs->r18, &old_unat);
-	copy_reg(&bank[19-16], ms->pmsa_nat_bits, &old_regs->r19, &old_unat);
-	copy_reg(&bank[20-16], ms->pmsa_nat_bits, &old_regs->r20, &old_unat);
-	copy_reg(&bank[21-16], ms->pmsa_nat_bits, &old_regs->r21, &old_unat);
-	copy_reg(&bank[22-16], ms->pmsa_nat_bits, &old_regs->r22, &old_unat);
-	copy_reg(&bank[23-16], ms->pmsa_nat_bits, &old_regs->r23, &old_unat);
-	copy_reg(&bank[24-16], ms->pmsa_nat_bits, &old_regs->r24, &old_unat);
-	copy_reg(&bank[25-16], ms->pmsa_nat_bits, &old_regs->r25, &old_unat);
-	copy_reg(&bank[26-16], ms->pmsa_nat_bits, &old_regs->r26, &old_unat);
-	copy_reg(&bank[27-16], ms->pmsa_nat_bits, &old_regs->r27, &old_unat);
-	copy_reg(&bank[28-16], ms->pmsa_nat_bits, &old_regs->r28, &old_unat);
-	copy_reg(&bank[29-16], ms->pmsa_nat_bits, &old_regs->r29, &old_unat);
-	copy_reg(&bank[30-16], ms->pmsa_nat_bits, &old_regs->r30, &old_unat);
-	copy_reg(&bank[31-16], ms->pmsa_nat_bits, &old_regs->r31, &old_unat);
+	finish_pt_regs(old_regs, ms, &old_unat);
 
 	/* Next stack a struct switch_stack.  mca_asm.S built a partial
 	 * switch_stack, copy it and fill in the blanks using pt_regs and
@@ -1141,6 +1149,8 @@ ia64_mca_modify_original_stack(struct pt
 no_mod:
 	mprintk(KERN_INFO "cpu %d, %s %s, original stack not modified\n",
 			smp_processor_id(), type, msg);
+	old_unat = regs->ar_unat;
+	finish_pt_regs(regs, ms, &old_unat);
 	return previous_current;
 }
 
