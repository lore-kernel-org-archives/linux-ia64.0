From: "bibo,mao" <bibo.mao@intel.com>
Date: Tue, 31 Oct 2006 12:48:51 +0000
Subject: Re: [PATCH] IA64 trap code 16 bytes atomic copy on montecito
Message-Id: <45474633.90305@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546E55E.3050207@intel.com>
In-Reply-To: <4546E55E.3050207@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now I add ia64_st16 macro in gcc_intrin.h, ia64_memcpy16 seems better.
As for icc intrinsic, I will check icc's header file to see whether
there exits st16/ld16 intrinsics.

thanks
bibo,mao
 
Chen, Kenneth W wrote:
> Mao, Bibo wrote on Tuesday, October 31, 2006 12:19 AM
>>> Also there is no need to resize the register stack frame here, since
>>> this is already a leaf function and there are plenty scratch register
>>> you can use before tap into register stack.  I personally prefer not
>>> to do alloc instruction here.
>>>
>>> And I think it would be a lot easier if you implement an intrinsic
>>> function, like ia64_ld16/ia64_st16 and stick them in include/asm-ia64/
>>> gcc_intrin.h and intel_intrin.h.
>>>
>> but there will be inline asm in c language, it is not benefit for gcc to
>> optimization, I hear that IA64 hates inline asm.
> 
> We hate style like:
> 
> void foo()
> {
> 	int a;
> 
> 	blah()
> 
> 	asm("ld16 ..." :: "" ..."");
> 
> 	bar();
> }
> 
> Because this breaks all icc builds.  It's perfectly fine to add an
> abstraction function that turns the above asm("") into ia64_ld16(). For
> gcc, it expands into an inline asm. For icc, it turns into an intrinsic.
> 
> In fact, for a simple case like ld16 instruction, it is better to use
> intrinsic (or gcc asm with appropriate clobber list) because using a
> function call will pretty much destroy all high level optimization
> around that call. Just imagine all of intermediate value stored in
> scratch registers before the call all become void after the call. With
> asm/intrinsic, the compiler has more knowledge to what's going on and
> can do a better job at it.
> 
> 
> 
diff -Nrup -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/arch/ia64/kernel/kprobes.c 2.6.19-rc2/arch/ia64/kernel/kprobes.c
--- 2.6.19-rc2.org/arch/ia64/kernel/kprobes.c	2006-10-27 16:39:29.000000000 +0800
+++ 2.6.19-rc2/arch/ia64/kernel/kprobes.c	2006-10-31 20:19:38.000000000 +0800
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
@@ -448,6 +453,12 @@ int __kprobes arch_prepare_kprobe(struct
 	p->ainsn.insn = get_insn_slot();
 	if (!p->ainsn.insn)
 		return -ENOMEM;
+	if (unlikely(((unsigned long)&p->opcode & 0xF)
+				|| ((unsigned long)p->ainsn.insn & 0xF))) {
+		printk(KERN_WARNING "Kprobes opcode 16-bytes unalignment\n ");
+		return -EINVAL;
+	}
+
 	memcpy(&p->opcode, kprobe_addr, sizeof(kprobe_opcode_t));
 	memcpy(p->ainsn.insn, kprobe_addr, sizeof(kprobe_opcode_t));
 
@@ -463,7 +474,10 @@ void __kprobes arch_arm_kprobe(struct kp
 
 	flush_icache_range((unsigned long)p->ainsn.insn,
 			(unsigned long)p->ainsn.insn + sizeof(kprobe_opcode_t));
-	memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
+	if (local_cpu_data->features & ITANIUM_CPUID4_AO)
+		ia64_st16((void *)arm_addr, (void *)&p->opcode);
+	else
+		memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
 }
 
@@ -473,8 +487,11 @@ void __kprobes arch_disarm_kprobe(struct
 	unsigned long arm_addr = addr & ~0xFULL;
 
 	/* p->ainsn.insn contains the original unaltered kprobe_opcode_t */
-	memcpy((char *) arm_addr, (char *) p->ainsn.insn,
-					 sizeof(kprobe_opcode_t));
+	if (local_cpu_data->features & ITANIUM_CPUID4_AO)
+		ia64_st16((void *)arm_addr, (void *) p->ainsn.insn);
+	else
+		memcpy((char *) arm_addr, (char *) p->ainsn.insn,
+					sizeof(kprobe_opcode_t));
 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
 }
 
diff -Nrup -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/include/asm-ia64/gcc_intrin.h 2.6.19-rc2/include/asm-ia64/gcc_intrin.h
--- 2.6.19-rc2.org/include/asm-ia64/gcc_intrin.h	2005-08-29 07:41:01.000000000 +0800
+++ 2.6.19-rc2/include/asm-ia64/gcc_intrin.h	2006-10-31 18:34:23.000000000 +0800
@@ -598,4 +598,12 @@ do {								\
 		      :: "r"((x)) : "p6", "p7", "memory");	\
 } while (0)
 
+#define ia64_st16(dest, src)					\
+do {								\
+	unsigned long value;					\
+	asm volatile(";; ld16 %0=[%2];;"			\
+		     "   st16 [%1]=%0;;"			\
+		     :"=r"(value)				\
+		     :"r"(dest), "r"(src) : "memory");		\
+} while(0)
 #endif /* _ASM_IA64_GCC_INTRIN_H */
