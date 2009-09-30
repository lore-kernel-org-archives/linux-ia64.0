From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Wed, 30 Sep 2009 18:49:25 +0000
Subject: [PATCH] ia64: Restore registers in the stack on INIT
Message-Id: <AACA41FEBB43F2indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, kexec@lists.infradead.org

Hi all,

When I was investigating vmcore captured by kdump, I noticed that
the backtrace was sometimes not displayed correctly.

The cause is that pt_regs and switch_stack are not saved in the stack
when INIT comes during fsys mode. In fsys mode, r13 register does not
point task_struct of current, so pt_regs and switch_stack are not saved
because of the following code in arch/ia64/kernel/mca.c.

static struct task_struct *
ia64_mca_modify_original_stack(struct pt_regs *regs,
(snip)
        if (r13 != sos->prev_IA64_KR_CURRENT) {
                msg = "inconsistent previous current and r13";
                goto no_mod;
        }

What I'd like to note here is that there is no way to know what happened
when original stack is not modified.
As I wrote above, the registers is not saved in the original stack, and
moreover, the registers in the per cpu stack are useless since they are
incomplete. We can't know why backtrace is not displayed. The only thing
we can get is the message "inconsistent previous current and r13" in the
mprintk buffer. Something problem happened? Or kernel was just in fsys
mode? We cannot know.

Solution1:
 The pt_regs in the per cpu stack are incomplete, so fill in the blanks
 with the appropriate registers so that we can debug using them.

Solution2:
 Save the processor min-state(pal_min_state_area_t) somewhere. When
 debugging, user can get register info from it.

I prefer solution1 because it's easy for user to debug. The
following patch is for solution1. restore_regs(), which is new function
added by this patch, is just copying registers from pal_min_state
to pt_regs.

Any comments would be appreciated.

Thanks,
Takao Indoh

Signed-off-by: Takao Indoh <indou.takao@jp.fujitsu.com>
---
 arch/ia64/kernel/mca.c |  103 +++++++++++++++++++++------------------
 1 file changed, 56 insertions(+), 47 deletions(-)

diff -Nurp linux-2.6.31.org/arch/ia64/kernel/mca.c linux-2.6.31/arch/ia64/kernel/mca.c
--- linux-2.6.31.org/arch/ia64/kernel/mca.c	2009-09-21 17:12:45.000000000 -0400
+++ linux-2.6.31/arch/ia64/kernel/mca.c	2009-09-24 16:15:05.000000000 -0400
@@ -887,6 +887,60 @@ ia64_mca_modify_comm(const struct task_s
 	memcpy(current->comm, comm, sizeof(current->comm));
 }
 
+static void
+restore_regs(struct pt_regs *regs, const pal_min_state_area_t *ms,
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
+	restore_regs(old_regs, ms, &old_unat);
 
 	/* Next stack a struct switch_stack.  mca_asm.S built a partial
 	 * switch_stack, copy it and fill in the blanks using pt_regs and
@@ -1141,6 +1149,7 @@ ia64_mca_modify_original_stack(struct pt
 no_mod:
 	mprintk(KERN_INFO "cpu %d, %s %s, original stack not modified\n",
 			smp_processor_id(), type, msg);
+	restore_regs(regs, ms, &old_unat);
 	return previous_current;
 }
 
