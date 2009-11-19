From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Thu, 19 Nov 2009 21:39:22 +0000
Subject: [PATCH] Save I-resources to ia64_sal_os_state
Message-Id: <51CA6960C1E2ECindou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This is a patch related to this discussion.
http://www.spinics.net/lists/linux-ia64/msg07605.html

When INIT is sent, ip/psr/pfs register is stored to the I-resources
(iip/ipsr/ifs registers), and they are copied in the min-state save
area(pmsa_{iip,ipsr,ifs}).

Therefore, in creating pt_regs at ia64_mca_modify_original_stack(),
cr_{iip,ipsr,ifs} should be derived from pmsa_{iip,ipsr,ifs}. But
current code copies pmsa_{xip,xpsr,xfs} to cr_{iip,ipsr,ifs}
when PSR.ic is 0.

finish_pt_regs(struct pt_regs *regs, const pal_min_state_area_t *ms,
                unsigned long *nat)
{
(snip)
        if (ia64_psr(regs)->ic) {
                regs->cr_iip = ms->pmsa_iip;
                regs->cr_ipsr = ms->pmsa_ipsr;
                regs->cr_ifs = ms->pmsa_ifs;
        } else {
                regs->cr_iip = ms->pmsa_xip;
                regs->cr_ipsr = ms->pmsa_xpsr;
                regs->cr_ifs = ms->pmsa_xfs;
        }

It's ok when PSR.ic is not 0. But when PSR.ic is 0, this could be
a problem when we investigate kernel as the value of regs->cr_iip does
not point to where INIT really interrupted.

At first I tried to change finish_pt_regs() so that it uses always
pmsa_{iip,ipsr,ifs} for cr_{iip,ipsr,ifs}, but Keith Owens pointed out
it could cause another problem if I change it.

>The only problem I can think of is an MCA/INIT
>arriving while code like SAVE_MIN or SAVE_REST is executing.  Back
>tracing at that point using pmsa_iip is going to be a problem, you have
>no idea what state the registers or stack are in.

I confirmed he was right, so I decided to keep it as-is and to
save pmsa_{iip,ipsr,ifs} to ia64_sal_os_state for debugging.

An attached patch is just adding new members into ia64_sal_os_state to
save pmsa_{iip,ipsr,ifs}.

Any comments would be appreciated.

Thanks,
Takao Indoh

Signed-off-by: Takao Indoh <indou.takao@jp.fujitsu.com>
---
 arch/ia64/include/asm/mca.h |    5 +++++
 arch/ia64/kernel/mca.c      |   11 ++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff -Nurp linux-2.6-ia64.org/arch/ia64/include/asm/mca.h linux-2.6-ia64/arch/ia64/include/asm/mca.h
--- linux-2.6-ia64.org/arch/ia64/include/asm/mca.h	2009-11-09 17:32:21.000000000 -0500
+++ linux-2.6-ia64/arch/ia64/include/asm/mca.h	2009-11-09 17:34:41.000000000 -0500
@@ -106,6 +106,11 @@ struct ia64_sal_os_state {
 	unsigned long		os_status;		/* OS status to SAL, enum below */
 	unsigned long		context;		/* 0 if return to same context
 							   1 if return to new context */
+
+	/* I-resources */
+	unsigned long		iip;
+	unsigned long		ipsr;
+	unsigned long		ifs;
 };
 
 enum {
diff -Nurp linux-2.6-ia64.org/arch/ia64/kernel/mca.c linux-2.6-ia64/arch/ia64/kernel/mca.c
--- linux-2.6-ia64.org/arch/ia64/kernel/mca.c	2009-11-09 17:32:21.000000000 -0500
+++ linux-2.6-ia64/arch/ia64/kernel/mca.c	2009-11-09 17:34:41.000000000 -0500
@@ -888,9 +888,10 @@ ia64_mca_modify_comm(const struct task_s
 }
 
 static void
-finish_pt_regs(struct pt_regs *regs, const pal_min_state_area_t *ms,
+finish_pt_regs(struct pt_regs *regs, struct ia64_sal_os_state *sos,
 		unsigned long *nat)
 {
+	const pal_min_state_area_t *ms = sos->pal_min_state;
 	const u64 *bank;
 
 	/* If ipsr.ic then use pmsa_{iip,ipsr,ifs}, else use
@@ -904,6 +905,10 @@ finish_pt_regs(struct pt_regs *regs, con
 		regs->cr_iip = ms->pmsa_xip;
 		regs->cr_ipsr = ms->pmsa_xpsr;
 		regs->cr_ifs = ms->pmsa_xfs;
+
+		sos->iip = ms->pmsa_iip;
+		sos->ipsr = ms->pmsa_ipsr;
+		sos->ifs = ms->pmsa_ifs;
 	}
 	regs->pr = ms->pmsa_pr;
 	regs->b0 = ms->pmsa_br0;
@@ -1079,7 +1084,7 @@ ia64_mca_modify_original_stack(struct pt
 	memcpy(old_regs, regs, sizeof(*regs));
 	old_regs->loadrs = loadrs;
 	old_unat = old_regs->ar_unat;
-	finish_pt_regs(old_regs, ms, &old_unat);
+	finish_pt_regs(old_regs, sos, &old_unat);
 
 	/* Next stack a struct switch_stack.  mca_asm.S built a partial
 	 * switch_stack, copy it and fill in the blanks using pt_regs and
@@ -1150,7 +1155,7 @@ no_mod:
 	mprintk(KERN_INFO "cpu %d, %s %s, original stack not modified\n",
 			smp_processor_id(), type, msg);
 	old_unat = regs->ar_unat;
-	finish_pt_regs(regs, ms, &old_unat);
+	finish_pt_regs(regs, sos, &old_unat);
 	return previous_current;
 }
 

