From: "bibo, mao" <bibo.mao@intel.com>
Date: Thu, 29 Jun 2006 09:29:18 +0000
Subject: [PATCH] kprobe invalidate icache of jump buffer
Message-Id: <44A39D6E.1050302@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,   

Kprobe inserts breakpoint instruction in probepoint and then jump to jmp buffer,
the jump buffer icache must be consistent with dcache. Here is the patch invalidates
jump buffer icache area. 

Without this patch, in some machines there will be fault when jumping to jmp buffer
where icache content is inconsistent with dcache.

This patch has been tested in my IA32, x86_64 and IA64 box, but is not tested in SPARC64
and powerpc architecture. It is based on kernel 2.6.17 version.
 
Signed-off-by: bibo,mao <bibo.mao@intel.com>
 
Thanks
bibo,mao 

diff -Nruap 2.6.17.org/arch/i386/kernel/kprobes.c 2.6.17.mbo/arch/i386/kernel/kprobes.c
--- 2.6.17.org/arch/i386/kernel/kprobes.c	2006-06-29 03:50:15.000000000 +0800
+++ 2.6.17.mbo/arch/i386/kernel/kprobes.c	2006-06-29 08:41:49.000000000 +0800
@@ -114,6 +114,9 @@ int __kprobes arch_prepare_kprobe(struct
 	} else {
 		p->ainsn.boostable = -1;
 	}
+	flush_icache_range((unsigned long)p->ainsn.insn,
+			(unsigned long)p->ainsn.insn + MAX_INSN_SIZE * sizeof(kprobe_opcode_t));
+				
 	return 0;
 }
 
@@ -131,6 +134,12 @@ void __kprobes arch_disarm_kprobe(struct
 			   (unsigned long) p->addr + sizeof(kprobe_opcode_t));
 }
 
+void __kprobes kprobe_flush_icache(struct kprobe *p)
+{
+	flush_icache_range((unsigned long) p->ainsn.insn,
+		(unsigned long) p->ainsn.insn + MAX_INSN_SIZE * sizeof(kprobe_opcode_t));
+}
+
 void __kprobes arch_remove_kprobe(struct kprobe *p)
 {
 	mutex_lock(&kprobe_mutex);
diff -Nruap 2.6.17.org/arch/ia64/kernel/kprobes.c 2.6.17.mbo/arch/ia64/kernel/kprobes.c
--- 2.6.17.org/arch/ia64/kernel/kprobes.c	2006-06-29 03:50:15.000000000 +0800
+++ 2.6.17.mbo/arch/ia64/kernel/kprobes.c	2006-06-29 07:36:51.000000000 +0800
@@ -445,29 +445,39 @@ int __kprobes arch_prepare_kprobe(struct
 			return -EINVAL;
 
 	prepare_break_inst(template, slot, major_opcode, kprobe_inst, p);
+	addr = (unsigned long)&p->opcode.bundle & ~0xFULL;
+	flush_icache_range(addr, addr + sizeof(bundle_t));
 
 	return 0;
 }
 
 void __kprobes arch_arm_kprobe(struct kprobe *p)
 {
-	unsigned long addr = (unsigned long)p->addr;
-	unsigned long arm_addr = addr & ~0xFULL;
+	unsigned long arm_addr;
 
+	arm_addr = (unsigned long)p->addr & ~0xFULL;
 	memcpy((char *)arm_addr, &p->ainsn.insn.bundle, sizeof(bundle_t));
 	flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
 }
 
 void __kprobes arch_disarm_kprobe(struct kprobe *p)
 {
-	unsigned long addr = (unsigned long)p->addr;
-	unsigned long arm_addr = addr & ~0xFULL;
+	unsigned long arm_addr;
 
+	arm_addr = (unsigned long)p->addr & ~0xFULL;
 	/* p->opcode contains the original unaltered bundle */
 	memcpy((char *) arm_addr, (char *) &p->opcode.bundle, sizeof(bundle_t));
 	flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
 }
 
+void __kprobes kprobe_flush_icache(struct kprobe *p)
+{
+        unsigned long arm_addr;
+
+        arm_addr = (unsigned long)&p->opcode.bundle & ~0xFULL;
+        flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
+}
+
 /*
  * We are resuming execution after a single step fault, so the pt_regs
  * structure reflects the register state after we executed the instruction
diff -Nruap 2.6.17.org/arch/powerpc/kernel/kprobes.c 2.6.17.mbo/arch/powerpc/kernel/kprobes.c
--- 2.6.17.org/arch/powerpc/kernel/kprobes.c	2006-06-29 03:50:15.000000000 +0800
+++ 2.6.17.mbo/arch/powerpc/kernel/kprobes.c	2006-06-29 08:17:31.000000000 +0800
@@ -63,6 +63,8 @@ int __kprobes arch_prepare_kprobe(struct
 		memcpy(p->ainsn.insn, p->addr, MAX_INSN_SIZE * sizeof(kprobe_opcode_t));
 		p->opcode = *p->addr;
 	}
+	flush_icache_range((unsigned long)p->ainsn.insn,
+			(unsigned long)p->ainsn.insn + MAX_INSN_SIZE * sizeof(kprobe_opcode_t));
 
 	return ret;
 }
@@ -81,6 +83,12 @@ void __kprobes arch_disarm_kprobe(struct
 			   (unsigned long) p->addr + sizeof(kprobe_opcode_t));
 }
 
+void __kprobes kprobe_flush_icache(struct kprobe *p)
+{
+	flush_icache_range((unsigned long)p->ainsn.insn,
+			(unsigned long)p->ainsn.insn + MAX_INSN_SIZE * sizeof(kprobe_opcode_t));
+}
+
 void __kprobes arch_remove_kprobe(struct kprobe *p)
 {
 	mutex_lock(&kprobe_mutex);
diff -Nruap 2.6.17.org/arch/sparc64/kernel/kprobes.c 2.6.17.mbo/arch/sparc64/kernel/kprobes.c
--- 2.6.17.org/arch/sparc64/kernel/kprobes.c	2006-06-29 03:50:15.000000000 +0800
+++ 2.6.17.mbo/arch/sparc64/kernel/kprobes.c	2006-06-29 08:13:52.000000000 +0800
@@ -48,6 +48,8 @@ int __kprobes arch_prepare_kprobe(struct
 	p->ainsn.insn[0] = *p->addr;
 	p->ainsn.insn[1] = BREAKPOINT_INSTRUCTION_2;
 	p->opcode = *p->addr;
+	flushi(&p->ainsn.insn[0]);
+	flushi(&p->ainsn.insn[1]);
 	return 0;
 }
 
@@ -63,6 +65,12 @@ void __kprobes arch_disarm_kprobe(struct
 	flushi(p->addr);
 }
 
+void __kprobe kprobe_flush_icache(struct kprobe *p)
+{
+	flushi(&p->ainsn.insn[0]);
+	flushi(&p->ainsn.insn[1]);
+}
+
 static void __kprobes save_previous_kprobe(struct kprobe_ctlblk *kcb)
 {
 	kcb->prev_kprobe.kp = kprobe_running();
diff -Nruap 2.6.17.org/arch/x86_64/kernel/kprobes.c 2.6.17.mbo/arch/x86_64/kernel/kprobes.c
--- 2.6.17.org/arch/x86_64/kernel/kprobes.c	2006-06-29 03:50:15.000000000 +0800
+++ 2.6.17.mbo/arch/x86_64/kernel/kprobes.c	2006-06-29 08:36:50.000000000 +0800
@@ -76,6 +76,8 @@ int __kprobes arch_prepare_kprobe(struct
 		return -ENOMEM;
 	}
 	arch_copy_kprobe(p);
+	flush_icache_range((unsigned long) p->ainsn.insn,
+			(unsigned long) p->ainsn.insn + MAX_INSN_SIZE * sizeof(kprobe_opcode_t));
 	return 0;
 }
 
@@ -185,7 +187,7 @@ static s32 __kprobes *is_riprel(u8 *insn
 static void __kprobes arch_copy_kprobe(struct kprobe *p)
 {
 	s32 *ripdisp;
-	memcpy(p->ainsn.insn, p->addr, MAX_INSN_SIZE);
+	memcpy(p->ainsn.insn, p->addr, MAX_INSN_SIZE * sizeof(kprobe_opcode_t));
 	ripdisp = is_riprel(p->ainsn.insn);
 	if (ripdisp) {
 		/*
@@ -222,6 +224,12 @@ void __kprobes arch_disarm_kprobe(struct
 			   (unsigned long) p->addr + sizeof(kprobe_opcode_t));
 }
 
+void __kprobes kprobe_flush_icache(struct kprobe *p)
+{
+	flush_icache_range((unsigned long) p->ainsn.insn,
+		(unsigned long) p->ainsn.insn + MAX_INSN_SIZE * sizeof(kprobe_opcode_t));
+}
+
 void __kprobes arch_remove_kprobe(struct kprobe *p)
 {
 	mutex_lock(&kprobe_mutex);
diff -Nruap 2.6.17.org/include/linux/kprobes.h 2.6.17.mbo/include/linux/kprobes.h
--- 2.6.17.org/include/linux/kprobes.h	2006-06-29 03:50:19.000000000 +0800
+++ 2.6.17.mbo/include/linux/kprobes.h	2006-06-29 08:20:12.000000000 +0800
@@ -157,6 +157,7 @@ extern struct mutex kprobe_mutex;
 extern int arch_prepare_kprobe(struct kprobe *p);
 extern void arch_arm_kprobe(struct kprobe *p);
 extern void arch_disarm_kprobe(struct kprobe *p);
+extern void kprobe_flush_icache(struct kprobe *p);
 extern int arch_init_kprobes(void);
 extern void show_registers(struct pt_regs *regs);
 extern kprobe_opcode_t *get_insn_slot(void);
diff -Nruap 2.6.17.org/kernel/kprobes.c 2.6.17.mbo/kernel/kprobes.c
--- 2.6.17.org/kernel/kprobes.c	2006-06-29 03:50:19.000000000 +0800
+++ 2.6.17.mbo/kernel/kprobes.c	2006-06-29 07:18:28.000000000 +0800
@@ -419,6 +419,7 @@ static int __kprobes register_aggr_kprob
 			return -ENOMEM;
 		add_aggr_kprobe(ap, old_p);
 		copy_kprobe(ap, p);
+		kprobe_flush_icache(ap);
 		ret = add_new_kprobe(ap, p);
 	}
 	return ret;
