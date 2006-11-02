From: "bibo,mao" <bibo.mao@intel.com>
Date: Thu, 02 Nov 2006 06:51:18 +0000
Subject: Re: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take
Message-Id: <45499566.7020800@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> "bibo,mao" (on Thu, 02 Nov 2006 11:11:42 +0800) wrote:
>> +#define ia64_ld16(low, addr)						\
>> +	asm volatile(";;ld16 %0=[%1];;":"=r"(low):"r"(addr):"memory")
>> +#define ia64_st16(low, addr)						\
>> +	asm volatile(";;st16 [%1]=%0;;"::"r"(low),"r"(addr):"memory")
>> ...
>> +#define ia64_st16(low, addr)    __st16(__sttype_none, __sthint_none, addr, low)
>> +#define ia64_ld16(low, addr)					\
>> +  	low =  __ld16(__ldtype_none, __ldtype_none, addr)
>> +
> 
> ld16 clobbers ar.csd, that needs to be added to the definition of
> ia64_ld16.
It seems that gcc does not support inline asm clobber for ar.csd register, 
so here I leave clobber register as empty.
> 
> ia64_ld16 does not need a memory clobber.
memory clobber is removed here.
> 
> Strictly speaking, ia64_st16 does not need a memory clobber.  addr
> should be a write operand (not read as you have it) and gcc should see
> that addr is clobbered.  However we clobber 16 bytes starting at addr
> and I suspect that gcc has no way of telling about the second set of 8
> bytes.  In this case, we may have to stick with a memory clobber on
> ia64_st16.
> 
>> +#define kprobe_update_bundle(dest, src)		\
>> +do {						\
>> +	unsigned long low;			\
>> +	ia64_ld16(low, src);			\
>> +	ia64_st16(low, dest);			\
>> +} while (0)
> 
> Using unsigned long (8 bytes) is misleading for a 16 byte operation.
> Not sure what we can do about that.

-------------------------------------------------------------------
diff -Nrup -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/arch/ia64/kernel/kprobes.c 2.6.19-rc2/arch/ia64/kernel/kprobes.c
--- 2.6.19-rc2.org/arch/ia64/kernel/kprobes.c	2006-10-27 16:39:29.000000000 +0800
+++ 2.6.19-rc2/arch/ia64/kernel/kprobes.c	2006-11-01 19:05:18.000000000 +0800
@@ -296,7 +296,7 @@ static int __kprobes valid_kprobe_addr(i
 		return -EINVAL;
 	}
 
-	if (slot = 1 && bundle_encoding[template][1] != L) {
+	if (slot = 1 && bundle_encoding[template][1] != L && !ATOMIC_UPDATE) {
 		printk(KERN_WARNING "Inserting kprobes on slot #1 "
 		       "is not supported\n");
 		return -EINVAL;
@@ -448,6 +448,12 @@ int __kprobes arch_prepare_kprobe(struct
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
 
@@ -463,7 +469,10 @@ void __kprobes arch_arm_kprobe(struct kp
 
 	flush_icache_range((unsigned long)p->ainsn.insn,
 			(unsigned long)p->ainsn.insn + sizeof(kprobe_opcode_t));
-	memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
+	if (ATOMIC_UPDATE)
+		kprobe_update_bundle((void *)arm_addr, (void *)&p->opcode);
+	else
+		memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
 }
 
@@ -473,8 +482,11 @@ void __kprobes arch_disarm_kprobe(struct
 	unsigned long arm_addr = addr & ~0xFULL;
 
 	/* p->ainsn.insn contains the original unaltered kprobe_opcode_t */
-	memcpy((char *) arm_addr, (char *) p->ainsn.insn,
-					 sizeof(kprobe_opcode_t));
+	if (ATOMIC_UPDATE)
+		kprobe_update_bundle((void *)arm_addr, (void *) p->ainsn.insn);
+	else
+		memcpy((char *) arm_addr, (char *) p->ainsn.insn,
+					sizeof(kprobe_opcode_t));
 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
 }
 
diff -Nrup -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/include/asm-ia64/gcc_intrin.h 2.6.19-rc2/include/asm-ia64/gcc_intrin.h
--- 2.6.19-rc2.org/include/asm-ia64/gcc_intrin.h	2005-08-29 07:41:01.000000000 +0800
+++ 2.6.19-rc2/include/asm-ia64/gcc_intrin.h	2006-11-02 15:28:41.000000000 +0800
@@ -598,4 +598,23 @@ do {								\
 		      :: "r"((x)) : "p6", "p7", "memory");	\
 } while (0)
 
+/* ld16/st16 instruction will fault if issued to UC, UCE, or WC memory.
+ * An aligned ld16/st16 instruction is performed as an atomic 16-byte
+ * memory reference. For these instructions, the address specified must
+ * be 16-byte aligned.
+ * ia64_ld16 macro will load the lower 64 bits to low parameter, and higher
+ * 64 bits value is put to ar.csd register. In order to get the 128 bits
+ * value, this can be used:
+ *	ia64_ld16(low, addr);
+ *	high = ia64_getreg(_IA64_REG_AR_CSD); 
+ * ia64_st16 macro will store low parameter value to lower 64 bits, and
+ * ar.csd register to higher 64 bits. In order to store 128 bits value
+ * this can be used:
+ *	ia64_setreg(_IA64_REG_AR_CSD, high);
+ *	ia64_st16(low, addr);
+ */
+#define ia64_ld16(low, addr)						\
+	asm volatile(";;ld16 %0, ar.csd =[%1];; ":"=r"(low): "r"(addr))
+#define ia64_st16(low, addr)						\
+	asm volatile(";;st16 [%1]=%0, ar.csd;; "::"r"(low),"r"(addr):"memory")
 #endif /* _ASM_IA64_GCC_INTRIN_H */
diff -Nrup -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/include/asm-ia64/intel_intrin.h 2.6.19-rc2/include/asm-ia64/intel_intrin.h
--- 2.6.19-rc2.org/include/asm-ia64/intel_intrin.h	2006-07-24 10:47:13.000000000 +0800
+++ 2.6.19-rc2/include/asm-ia64/intel_intrin.h	2006-11-01 18:38:13.000000000 +0800
@@ -152,6 +152,10 @@ do {							\
 	}						\
 } while (0)
 
+#define ia64_st16(low, addr)    __st16(__sttype_none, __sthint_none, addr, low)
+#define ia64_ld16(low, addr)					\
+  	low =  __ld16(__ldtype_none, __ldtype_none, addr)
+
 #define __builtin_trap()	__break(0);
 
 #endif /* _ASM_IA64_INTEL_INTRIN_H */
diff -Nrup -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/include/asm-ia64/kprobes.h 2.6.19-rc2/include/asm-ia64/kprobes.h
--- 2.6.19-rc2.org/include/asm-ia64/kprobes.h	2006-10-27 16:39:34.000000000 +0800
+++ 2.6.19-rc2/include/asm-ia64/kprobes.h	2006-11-02 15:20:54.000000000 +0800
@@ -88,6 +88,7 @@ struct kprobe_ctlblk {
 #define SLOT0_OPCODE_SHIFT	(37)
 #define SLOT1_p1_OPCODE_SHIFT	(37 - (64-46))
 #define SLOT2_OPCODE_SHIFT 	(37)
+#define ATOMIC_UPDATE		(local_cpu_data->features & ITANIUM_CPUID4_AO)
 
 #define INDIRECT_CALL_OPCODE		(1)
 #define IP_RELATIVE_CALL_OPCODE		(5)
@@ -96,6 +97,17 @@ struct kprobe_ctlblk {
 #define LONG_BRANCH_OPCODE		(0xC)
 #define LONG_CALL_OPCODE		(0xD)
 #define flush_insn_slot(p)		do { } while (0)
+/* this macro will first get 128 bits value from src address,
+ * and then copy this 128 bits value to dest address. It uses
+ * ar.csd register to load and store higher 64 bits value,
+ * and low 64 bits value is passed by low variant.
+ */ 
+#define kprobe_update_bundle(dest, src)		\
+do {						\
+	unsigned long low;			\
+	ia64_ld16(low, src);			\
+	ia64_st16(low, dest);			\
+} while (0)
 
 typedef struct kprobe_opcode {
 	bundle_t bundle;
diff -Nrup -X 2.6.19-rc2.org/Documentation/dontdiff 2.6.19-rc2.org/include/asm-ia64/kregs.h 2.6.19-rc2/include/asm-ia64/kregs.h
--- 2.6.19-rc2.org/include/asm-ia64/kregs.h	2005-08-29 07:41:01.000000000 +0800
+++ 2.6.19-rc2/include/asm-ia64/kregs.h	2006-11-01 18:54:37.000000000 +0800
@@ -160,4 +160,7 @@
 #define IA64_ISR_CODE_LFETCH	4
 #define IA64_ISR_CODE_PROBEF	5
 
+/* CPUID 4 Register */
+#define ITANIUM_CPUID4_AO_BIT	2
+#define ITANIUM_CPUID4_AO	(__IA64_UL(1) << ITANIUM_CPUID4_AO_BIT)
 #endif /* _ASM_IA64_kREGS_H */
