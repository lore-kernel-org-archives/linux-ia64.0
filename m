From: "bibo,mao" <bibo.mao@intel.com>
Date: Tue, 31 Oct 2006 05:55:42 +0000
Subject: [PATCH] IA64 trap code 16 bytes atomic copy on montecito
Message-Id: <4546E55E.3050207@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi,
  On IA64 kprobe can not insert trap code on slot 1 because
opcode of slot 1 crosses over two consecutive 8-bytes. On
montecito machine 16 bytes atomic operation is avaiable,
This patch implements 16 bytes atomic copy on montecito
machine, so that kprobe can probe any slot on montecito
machine.
  Any comments is welcome.

Signed-off-by: bibo, mao <bibo.mao@intel.com>
  
thanks
bibo,mao 

 arch/ia64/kernel/jprobes.S |   38 +++++++++++++++++++++++++++
 arch/ia64/kernel/kprobes.c |   16 ++++++++++++----
 include/asm-ia64/kprobes.h |    1 +
 3 files changed, 51 insertions(+), 4 deletions(-)
-------------------------------------------------------------

diff -Nruap -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/arch/ia64/kernel/jprobes.S 2.6.19-rc2/arch/ia64/kernel/jprobes.S
--- 2.6.19-rc2.org/arch/ia64/kernel/jprobes.S	2006-03-27 14:41:20.000000000 +0800
+++ 2.6.19-rc2/arch/ia64/kernel/jprobes.S	2006-10-31 12:29:14.000000000 +0800
@@ -87,3 +87,41 @@ GLOBAL_ENTRY(flush_register_stack)
 	br.ret.sptk.many rp
 END(flush_register_stack)
 
+/* this function uses st16/ld16 to atomically copy one bundle
+ * to code area, it requires src address and dest address is
+ * not in UC/UCE/WC area. Currently kernel physical memory
+ * identified map is cachable and WB, so there is no such check.
+ *  input0: represents whether this cpu supports atomic
+ *	    st16/ld16 instruction
+ *  input1: destionation address of bundle copy
+ *  input2: source address of bundle copy
+ *  return: -1 failed, 0 succeed  
+ */
+GLOBAL_ENTRY(kprobe_update_inst_bundle)
+	alloc loc0=ar.pfs,3,1,0,0
+
+	and r15,r34
+	and r14,r33
+	mov r8=-1
+	;;
+	cmp.eq p9,p8=0,r15
+	cmp.eq p7,p6=0,r14
+(p6) 	br.ret.dptk.many b0
+	;;
+	cmp4.eq p7,p6=0,r32
+(p8)	br.ret.dpnt.many b0
+	;;
+(p7)	ld8  r14=[r34],8
+	mov  r8=r0
+(p6)	ld16 r14=[r34]
+	;;
+(p7)	st8  [r33]=r14,8
+(p6)	st16 [r33]=r14
+	;;
+(p7)	ld8  r14=[r34]
+	;;
+(p7)	st8 [r33]=r14
+	nop.i 0x0
+	br.ret.sptk.many b0
+	;;	
+END(kprobe_update_inst_bundle)
diff -Nruap -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/arch/ia64/kernel/kprobes.c 2.6.19-rc2/arch/ia64/kernel/kprobes.c
--- 2.6.19-rc2.org/arch/ia64/kernel/kprobes.c	2006-10-27 16:39:29.000000000 +0800
+++ 2.6.19-rc2/arch/ia64/kernel/kprobes.c	2006-10-31 13:59:52.000000000 +0800
@@ -39,6 +39,8 @@ extern void jprobe_inst_return(void);
 
 DEFINE_PER_CPU(struct kprobe *, current_kprobe) = NULL;
 DEFINE_PER_CPU(struct kprobe_ctlblk, kprobe_ctlblk);
+#define ITANIUM_CPUID4_BIT_AO	2
+#define ITANIUM_CPUID4_AO	(0x1UL << ITANIUM_CPUID4_BIT_AO)
 
 enum instruction_type {A, I, M, F, B, L, X, u};
 static enum instruction_type bundle_encoding[32][3] = {
@@ -284,6 +286,8 @@ static int __kprobes in_ivt_functions(un
 static int __kprobes valid_kprobe_addr(int template, int slot,
 				       unsigned long addr)
 {
+	int atomic;
+
 	if ((slot > 2) || ((bundle_encoding[template][1] = L) && slot > 1)) {
 		printk(KERN_WARNING "Attempting to insert unaligned kprobe "
 				"at 0x%lx\n", addr);
@@ -296,7 +300,8 @@ static int __kprobes valid_kprobe_addr(i
 		return -EINVAL;
 	}
 
-	if (slot = 1 && bundle_encoding[template][1] != L) {
+	atomic = local_cpu_data->features & ITANIUM_CPUID4_AO;
+	if (slot = 1 && !atomic && bundle_encoding[template][1] != L) {
 		printk(KERN_WARNING "Inserting kprobes on slot #1 "
 		       "is not supported\n");
 		return -EINVAL;
@@ -460,10 +465,12 @@ void __kprobes arch_arm_kprobe(struct kp
 {
 	unsigned long addr = (unsigned long)p->addr;
 	unsigned long arm_addr = addr & ~0xFULL;
+	int atomic;
 
+	atomic = local_cpu_data->features & ITANIUM_CPUID4_AO;
 	flush_icache_range((unsigned long)p->ainsn.insn,
 			(unsigned long)p->ainsn.insn + sizeof(kprobe_opcode_t));
-	memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
+	kprobe_update_inst_bundle(atomic, (void *)arm_addr, (void *)&p->opcode);
 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
 }
 
@@ -471,10 +478,11 @@ void __kprobes arch_disarm_kprobe(struct
 {
 	unsigned long addr = (unsigned long)p->addr;
 	unsigned long arm_addr = addr & ~0xFULL;
+	int atomic;
 
+	atomic = local_cpu_data->features & ITANIUM_CPUID4_AO;
 	/* p->ainsn.insn contains the original unaltered kprobe_opcode_t */
-	memcpy((char *) arm_addr, (char *) p->ainsn.insn,
-					 sizeof(kprobe_opcode_t));
+	kprobe_update_inst_bundle(atomic, (void *)arm_addr, (void *) p->ainsn.insn);
 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
 }
 
diff -Nruap -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/include/asm-ia64/kprobes.h 2.6.19-rc2/include/asm-ia64/kprobes.h
--- 2.6.19-rc2.org/include/asm-ia64/kprobes.h	2006-10-27 16:39:34.000000000 +0800
+++ 2.6.19-rc2/include/asm-ia64/kprobes.h	2006-10-31 12:29:36.000000000 +0800
@@ -127,5 +127,6 @@ static inline void jprobe_return(void)
 extern void invalidate_stacked_regs(void);
 extern void flush_register_stack(void);
 extern void arch_remove_kprobe(struct kprobe *p);
+extern int kprobe_update_inst_bundle(int atomic, void *desc, void *src);
 
 #endif				/* _ASM_KPROBES_H */
