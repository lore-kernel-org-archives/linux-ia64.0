From: "bibo,mao" <bibo.mao@intel.com>
Date: Mon, 13 Nov 2006 08:28:03 +0000
Subject: [PATCH]ia64 kprobe clears qp bits for special instructions
Message-Id: <45582C93.7090107@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On IA64 there exists some special instructions which 
always need to be executed regradless of qp bits, such
as com.crel.unc, tbit.trel.unc etc.
This patch clears qp bits when inserting kprobe trap code
and disables probepoint on slot 1 for these special 
instructions.

Signed-off-by: bibo,mao <bibo.mao@intel.com>

thanks
bibo,mao

--------------------------------------------------
 arch/ia64/kernel/kprobes.c |  175 ++++++-----
 1 files changed, 122 insertions(+), 53 deletions(-)

diff --git a/arch/ia64/kernel/jprobes.S b/arch/ia64/kernel/jprobes.S
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 51217d6..61f90b4 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -129,48 +129,6 @@ static void __kprobes update_kprobe_inst
 
 /*
  * In this function we check to see if the instruction
- * on which we are inserting kprobe is supported.
- * Returns 0 if supported
- * Returns -EINVAL if unsupported
- */
-static int __kprobes unsupported_inst(uint template, uint  slot,
-				      uint major_opcode,
-				      unsigned long kprobe_inst,
-				      unsigned long addr)
-{
-	if (bundle_encoding[template][slot] = I) {
-		switch (major_opcode) {
-			case 0x0: //I_UNIT_MISC_OPCODE:
-			/*
-			 * Check for Integer speculation instruction
-			 * - Bit 33-35 to be equal to 0x1
-			 */
-			if (((kprobe_inst >> 33) & 0x7) = 1) {
-				printk(KERN_WARNING
-					"Kprobes on speculation inst at <0x%lx> not supported\n",
-					addr);
-				return -EINVAL;
-			}
-
-			/*
-			 * IP relative mov instruction
-			 *  - Bit 27-35 to be equal to 0x30
-			 */
-			if (((kprobe_inst >> 27) & 0x1FF) = 0x30) {
-				printk(KERN_WARNING
-					"Kprobes on \"mov r1=ip\" at <0x%lx> not supported\n",
-					addr);
-				return -EINVAL;
-
-			}
-		}
-	}
-	return 0;
-}
-
-
-/*
- * In this function we check to see if the instruction
  * (qp) cmpx.crel.ctype p1,p2=r2,r3
  * on which we are inserting kprobe is cmp instruction
  * with ctype as unc.
@@ -206,26 +164,136 @@ out:
 }
 
 /*
+ * In this function we check to see if the instruction
+ * on which we are inserting kprobe is supported.
+ * Returns qp value if supported
+ * Returns -EINVAL if unsupported
+ */
+static int __kprobes unsupported_inst(uint template, uint  slot,
+				      uint major_opcode,
+				      unsigned long kprobe_inst,
+				      unsigned long addr)
+{
+	int qp;
+
+	qp = kprobe_inst & 0x3f;
+	if (is_cmp_ctype_unc_inst(template, slot, major_opcode, kprobe_inst)) {
+		if (slot = 1 && qp)  {
+			printk(KERN_WARNING "Kprobes on cmp unc"
+					"instruction on slot 1 at <0x%lx>"
+					"is not supported\n", addr);
+			return -EINVAL;
+
+		}
+		qp = 0;
+	}
+	else if (bundle_encoding[template][slot] = I) {
+		if (major_opcode = 0) {
+			/*
+			 * Check for Integer speculation instruction
+			 * - Bit 33-35 to be equal to 0x1
+			 */
+			if (((kprobe_inst >> 33) & 0x7) = 1) {
+				printk(KERN_WARNING
+					"Kprobes on speculation inst at <0x%lx> not supported\n",
+						addr);
+				return -EINVAL;
+			}
+			/*
+			 * IP relative mov instruction
+			 *  - Bit 27-35 to be equal to 0x30
+			 */
+			if (((kprobe_inst >> 27) & 0x1FF) = 0x30) {
+				printk(KERN_WARNING
+					"Kprobes on \"mov r1=ip\" at <0x%lx> not supported\n",
+						addr);
+				return -EINVAL;
+
+			}
+		}
+		else if ((major_opcode = 5) &&	!(kprobe_inst & (0xFUl << 33)) &&
+				(kprobe_inst & (0x1UL << 12))) {
+			/* test bit instructions, tbit,tnat,tf
+			 * bit 33-36 to be equal to 0
+			 * bit 12 to be equal to 1
+			 */
+			if (slot = 1 && qp) {
+				printk(KERN_WARNING "Kprobes on test bit"
+						"instruction on slot at <0x%lx>"
+						"is not supported\n", addr);
+				return -EINVAL;
+			}
+			qp = 0;
+		}
+	}
+	else if (bundle_encoding[template][slot] = B) {
+		if (major_opcode = 7) {
+			/* IP-Relative Predict major code is 7 */
+			printk(KERN_WARNING "Kprobes on IP-Relative"
+					"Predict is not supported\n");
+			return -EINVAL;
+		}
+		else if (major_opcode = 2) {
+			/* Indirect Predict, major code is 2
+			 * bit 27-32 to be equal to 10 or 11
+			 */
+			int x6=(kprobe_inst >> 27) & 0x3F;
+			if ((x6 = 0x10) || (x6 = 0x11)) {
+				printk(KERN_WARNING "Kprobes on"
+					"Indirect Predict is not supported\n");
+				return -EINVAL;
+			}
+		}
+	}
+	/* kernel does not use float instruction, here for safety kprobe
+	 * will judge whether it is fcmp/flass/float approximation instruction
+	 */
+	else if (unlikely(bundle_encoding[template][slot] = F)) {
+		if ((major_opcode = 4 || major_opcode = 5) &&
+				(kprobe_inst  & (0x1 << 12))) {
+			/* fcmp/fclass unc instruction */
+			if (slot = 1 && qp) {
+				printk(KERN_WARNING "Kprobes on fcmp/fclass "
+					"instruction on slot at <0x%lx> "
+					"is not supported\n", addr);
+				return -EINVAL;
+
+			}
+			qp = 0;
+		}
+		if ((major_opcode = 0 || major_opcode = 1) &&
+			(kprobe_inst & (0x1UL << 33))) {
+			/* float Approximation instruction */
+			if (slot = 1 && qp) {
+				printk(KERN_WARNING "Kprobes on float Approx "
+					"instr at <0x%lx> is not supported\n",
+						addr);
+				return -EINVAL;
+			}
+			qp = 0;
+		}
+	}
+	return qp;
+}
+
+/*
  * In this function we override the bundle with
  * the break instruction at the given slot.
  */
 static void __kprobes prepare_break_inst(uint template, uint  slot,
 					 uint major_opcode,
 					 unsigned long kprobe_inst,
-					 struct kprobe *p)
+					 struct kprobe *p,
+					 int qp)
 {
 	unsigned long break_inst = BREAK_INST;
 	bundle_t *bundle = &p->opcode.bundle;
 
 	/*
 	 * Copy the original kprobe_inst qualifying predicate(qp)
-	 * to the break instruction iff !is_cmp_ctype_unc_inst
-	 * because for cmp instruction with ctype equal to unc,
-	 * which is a special instruction always needs to be
-	 * executed regradless of qp
+	 * to the break instruction 
 	 */
-	if (!is_cmp_ctype_unc_inst(template, slot, major_opcode, kprobe_inst))
-		break_inst |= (0x3f & kprobe_inst);
+	break_inst |= qp;
 
 	switch (slot) {
 	  case 0:
@@ -427,6 +495,7 @@ int __kprobes arch_prepare_kprobe(struct
 	unsigned long kprobe_inst=0;
 	unsigned int slot = addr & 0xf, template, major_opcode = 0;
 	bundle_t *bundle;
+	int qp;
 
 	bundle = &((kprobe_opcode_t *)kprobe_addr)->bundle;
 	template = bundle->quad0.template;
@@ -441,9 +510,9 @@ int __kprobes arch_prepare_kprobe(struct
 	/* Get kprobe_inst and major_opcode from the bundle */
 	get_kprobe_inst(bundle, slot, &kprobe_inst, &major_opcode);
 
-	if (unsupported_inst(template, slot, major_opcode, kprobe_inst, addr))
-			return -EINVAL;
-
+	qp = unsupported_inst(template, slot, major_opcode, kprobe_inst, addr);
+	if (qp < 0)
+		return -EINVAL;
 
 	p->ainsn.insn = get_insn_slot();
 	if (!p->ainsn.insn)
@@ -451,7 +520,7 @@ int __kprobes arch_prepare_kprobe(struct
 	memcpy(&p->opcode, kprobe_addr, sizeof(kprobe_opcode_t));
 	memcpy(p->ainsn.insn, kprobe_addr, sizeof(kprobe_opcode_t));
 
-	prepare_break_inst(template, slot, major_opcode, kprobe_inst, p);
+	prepare_break_inst(template, slot, major_opcode, kprobe_inst, p, qp);
 
 	return 0;
 }
