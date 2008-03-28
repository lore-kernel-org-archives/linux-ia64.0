From: akpm@linux-foundation.org
Date: Fri, 28 Mar 2008 21:27:02 +0000
Subject: [patch 2/5] kprobes: kprobe-booster for ia64
Message-Id: <200803282127.m2SLR2Tv011049@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Masami Hiramatsu <mhiramat@redhat.com>

Add kprobe-booster support on ia64.

Kprobe-booster improves the performance of kprobes by eliminating single-step,
where possible.  Currently, kprobe-booster is implemented on x86 and x86-64. 
This is an ia64 port.

On ia64, kprobe-booster executes a copied bundle directly, instead of single
stepping.  Bundles which have B or X unit and which may cause an exception
(including break) are not executed directly.  And also, to prevent hitting
break exceptions on the copied bundle, only the hindmost kprobe is executed
directly if several kprobes share a bundle and are placed in different slots. 
Note: set_brl_inst() is used for preparing an instruction buffer(it does not
modify any active code), so it does not need any atomic operation.

Signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
Cc: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: bibo,mao <bibo.mao@intel.com>
Cc: Rusty Lynch <rusty.lynch@intel.com>
Cc: Prasanna S Panchamukhi <prasanna@in.ibm.com>
Cc: Jim Keniston <jkenisto@us.ibm.com>
Cc: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/kprobes.c |  133 ++++++++++++++++++++++++++++-------
 include/asm-ia64/kprobes.h |    7 +
 2 files changed, 113 insertions(+), 27 deletions(-)

diff -puN arch/ia64/kernel/kprobes.c~kprobes-kprobe-booster-for-ia64 arch/ia64/kernel/kprobes.c
--- a/arch/ia64/kernel/kprobes.c~kprobes-kprobe-booster-for-ia64
+++ a/arch/ia64/kernel/kprobes.c
@@ -78,6 +78,20 @@ static enum instruction_type bundle_enco
   { u, u, u },  			/* 1F */
 };
 
+/* Insert a long branch code */
+static void __kprobes set_brl_inst(void *from, void *to)
+{
+	s64 rel = ((s64) to - (s64) from) >> 4;
+	bundle_t *brl;
+	brl = (bundle_t *) ((u64) from & ~0xf);
+	brl->quad0.template = 0x05;	/* [MLX](stop) */
+	brl->quad0.slot0 = NOP_M_INST;	/* nop.m 0x0 */
+	brl->quad0.slot1_p0 = ((rel >> 20) & 0x7fffffffff) << 2;
+	brl->quad1.slot1_p1 = (((rel >> 20) & 0x7fffffffff) << 2) >> (64 - 46);
+	/* brl.cond.sptk.many.clr rel<<4 (qp=0) */
+	brl->quad1.slot2 = BRL_INST(rel >> 59, rel & 0xfffff);
+}
+
 /*
  * In this function we check to see if the instruction
  * is IP relative instruction and update the kprobe
@@ -496,6 +510,77 @@ void __kprobes arch_prepare_kretprobe(st
 	regs->b0 = ((struct fnptr *)kretprobe_trampoline)->ip;
 }
 
+/* Check the instruction in the slot is break */
+static int __kprobes __is_ia64_break_inst(bundle_t *bundle, uint slot)
+{
+	unsigned int major_opcode;
+	unsigned int template = bundle->quad0.template;
+	unsigned long kprobe_inst;
+
+	/* Move to slot 2, if bundle is MLX type and kprobe slot is 1 */
+	if (slot = 1 && bundle_encoding[template][1] = L)
+		slot++;
+
+	/* Get Kprobe probe instruction at given slot*/
+	get_kprobe_inst(bundle, slot, &kprobe_inst, &major_opcode);
+
+	/* For break instruction,
+	 * Bits 37:40 Major opcode to be zero
+	 * Bits 27:32 X6 to be zero
+	 * Bits 32:35 X3 to be zero
+	 */
+	if (major_opcode || ((kprobe_inst >> 27) & 0x1FF)) {
+		/* Not a break instruction */
+		return 0;
+	}
+
+	/* Is a break instruction */
+	return 1;
+}
+
+/*
+ * In this function, we check whether the target bundle modifies IP or
+ * it triggers an exception. If so, it cannot be boostable.
+ */
+static int __kprobes can_boost(bundle_t *bundle, uint slot,
+			       unsigned long bundle_addr)
+{
+	unsigned int template = bundle->quad0.template;
+
+	do {
+		if (search_exception_tables(bundle_addr + slot) ||
+		    __is_ia64_break_inst(bundle, slot))
+			return 0;	/* exception may occur in this bundle*/
+	} while ((++slot) < 3);
+	template &= 0x1e;
+	if (template >= 0x10 /* including B unit */ ||
+	    template = 0x04 /* including X unit */ ||
+	    template = 0x06) /* undefined */
+		return 0;
+
+	return 1;
+}
+
+/* Prepare long jump bundle and disables other boosters if need */
+static void __kprobes prepare_booster(struct kprobe *p)
+{
+	unsigned long addr = (unsigned long)p->addr & ~0xFULL;
+	unsigned int slot = (unsigned long)p->addr & 0xf;
+	struct kprobe *other_kp;
+
+	if (can_boost(&p->ainsn.insn[0].bundle, slot, addr)) {
+		set_brl_inst(&p->ainsn.insn[1].bundle, (bundle_t *)addr + 1);
+		p->ainsn.inst_flag |= INST_FLAG_BOOSTABLE;
+	}
+
+	/* disables boosters in previous slots */
+	for (; addr < (unsigned long)p->addr; addr++) {
+		other_kp = get_kprobe((void *)addr);
+		if (other_kp)
+			other_kp->ainsn.inst_flag &= ~INST_FLAG_BOOSTABLE;
+	}
+}
+
 int __kprobes arch_prepare_kprobe(struct kprobe *p)
 {
 	unsigned long addr = (unsigned long) p->addr;
@@ -530,6 +615,8 @@ int __kprobes arch_prepare_kprobe(struct
 
 	prepare_break_inst(template, slot, major_opcode, kprobe_inst, p, qp);
 
+	prepare_booster(p);
+
 	return 0;
 }
 
@@ -543,7 +630,9 @@ void __kprobes arch_arm_kprobe(struct kp
 	src = &p->opcode.bundle;
 
 	flush_icache_range((unsigned long)p->ainsn.insn,
-			(unsigned long)p->ainsn.insn + sizeof(kprobe_opcode_t));
+			   (unsigned long)p->ainsn.insn +
+			   sizeof(kprobe_opcode_t) * MAX_INSN_SIZE);
+
 	switch (p->ainsn.slot) {
 		case 0:
 			dest->quad0.slot0 = src->quad0.slot0;
@@ -584,13 +673,13 @@ void __kprobes arch_disarm_kprobe(struct
 void __kprobes arch_remove_kprobe(struct kprobe *p)
 {
 	mutex_lock(&kprobe_mutex);
-	free_insn_slot(p->ainsn.insn, 0);
+	free_insn_slot(p->ainsn.insn, p->ainsn.inst_flag & INST_FLAG_BOOSTABLE);
 	mutex_unlock(&kprobe_mutex);
 }
 /*
  * We are resuming execution after a single step fault, so the pt_regs
  * structure reflects the register state after we executed the instruction
- * located in the kprobe (p->ainsn.insn.bundle).  We still need to adjust
+ * located in the kprobe (p->ainsn.insn->bundle).  We still need to adjust
  * the ip to point back to the original stack address. To set the IP address
  * to original stack address, handle the case where we need to fixup the
  * relative IP address and/or fixup branch register.
@@ -607,7 +696,7 @@ static void __kprobes resume_execution(s
 	if (slot = 1 && bundle_encoding[template][1] = L)
 		slot = 2;
 
-	if (p->ainsn.inst_flag) {
+	if (p->ainsn.inst_flag & ~INST_FLAG_BOOSTABLE) {
 
 		if (p->ainsn.inst_flag & INST_FLAG_FIX_RELATIVE_IP_ADDR) {
 			/* Fix relative IP address */
@@ -686,33 +775,12 @@ static void __kprobes prepare_ss(struct 
 static int __kprobes is_ia64_break_inst(struct pt_regs *regs)
 {
 	unsigned int slot = ia64_psr(regs)->ri;
-	unsigned int template, major_opcode;
-	unsigned long kprobe_inst;
 	unsigned long *kprobe_addr = (unsigned long *)regs->cr_iip;
 	bundle_t bundle;
 
 	memcpy(&bundle, kprobe_addr, sizeof(bundle_t));
-	template = bundle.quad0.template;
-
-	/* Move to slot 2, if bundle is MLX type and kprobe slot is 1 */
-	if (slot = 1 && bundle_encoding[template][1] = L)
-		slot++;
-
-	/* Get Kprobe probe instruction at given slot*/
-	get_kprobe_inst(&bundle, slot, &kprobe_inst, &major_opcode);
-
-	/* For break instruction,
-	 * Bits 37:40 Major opcode to be zero
-	 * Bits 27:32 X6 to be zero
-	 * Bits 32:35 X3 to be zero
-	 */
-	if (major_opcode || ((kprobe_inst >> 27) & 0x1FF) ) {
-		/* Not a break instruction */
-		return 0;
-	}
 
-	/* Is a break instruction */
-	return 1;
+	return __is_ia64_break_inst(&bundle, slot);
 }
 
 static int __kprobes pre_kprobes_handler(struct die_args *args)
@@ -802,6 +870,19 @@ static int __kprobes pre_kprobes_handler
 		return 1;
 
 ss_probe:
+#if !defined(CONFIG_PREEMPT) || defined(CONFIG_PM)
+	if (p->ainsn.inst_flag = INST_FLAG_BOOSTABLE && !p->post_handler) {
+		/* Boost up -- we can execute copied instructions directly */
+		ia64_psr(regs)->ri = p->ainsn.slot;
+		regs->cr_iip = (unsigned long)&p->ainsn.insn->bundle & ~0xFULL;
+		/* turn single stepping off */
+		ia64_psr(regs)->ss = 0;
+
+		reset_current_kprobe();
+		preempt_enable_no_resched();
+		return 1;
+	}
+#endif
 	prepare_ss(p, regs);
 	kcb->kprobe_status = KPROBE_HIT_SS;
 	return 1;
diff -puN include/asm-ia64/kprobes.h~kprobes-kprobe-booster-for-ia64 include/asm-ia64/kprobes.h
--- a/include/asm-ia64/kprobes.h~kprobes-kprobe-booster-for-ia64
+++ a/include/asm-ia64/kprobes.h
@@ -30,8 +30,12 @@
 #include <asm/break.h>
 
 #define __ARCH_WANT_KPROBES_INSN_SLOT
-#define MAX_INSN_SIZE   1
+#define MAX_INSN_SIZE   2	/* last half is for kprobe-booster */
 #define BREAK_INST	(long)(__IA64_BREAK_KPROBE << 6)
+#define NOP_M_INST	(long)(1<<27)
+#define BRL_INST(i1, i2) ((long)((0xcL << 37) |	/* brl */ \
+				(0x1L << 12) |	/* many */ \
+				(((i1) & 1) << 36) | ((i2) << 13))) /* imm */
 
 typedef union cmp_inst {
 	struct {
@@ -112,6 +116,7 @@ struct arch_specific_insn {
  #define INST_FLAG_FIX_RELATIVE_IP_ADDR		1
  #define INST_FLAG_FIX_BRANCH_REG		2
  #define INST_FLAG_BREAK_INST			4
+ #define INST_FLAG_BOOSTABLE			8
  	unsigned long inst_flag;
  	unsigned short target_br_reg;
 	unsigned short slot;
_
