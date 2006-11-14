From: "bibo,mao" <bibo.mao@intel.com>
Date: Tue, 14 Nov 2006 01:47:04 +0000
Subject: [PATCH] ia64 enable trap code on slot 1
Message-Id: <45592018.3040203@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
 Because slot 1 of one instr bundle crosses border of two
consecutive 8-bytes, kprobe on slot 1 is disabled. This
patch enables kprobe on slot1, it only replaces higher 8-bytes
trap major code and immediate sum, and remains lower
8-bytes the same.
 For those instructions which must execute regardless qp bits,
kprobe on slot 1 is still disabled.
 
(sorry if you receive duplicates, my original was not sent to
 linux-ia64 mailing list)

Signed-off-by: bibo,mao <bibo.mao@intel.com>

thanks
bibo,mao

-----------------------------------------------------
arch/ia64/kernel/jprobes.S |    3 +-
arch/ia64/kernel/kprobes.c |   51 ++++++++++++++++++---
include/asm-ia64/break.h   |    4 +--
include/asm-ia64/kprobes.h |    1
4 files changed, 42 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/kernel/jprobes.S b/arch/ia64/kernel/jprobes.S
index 5cd6226..6216302 100644
--- a/arch/ia64/kernel/jprobes.S
+++ b/arch/ia64/kernel/jprobes.S
@@ -45,13 +45,14 @@
  * to the correct location.
  */
 #include <asm/asmmacro.h>
+#include <asm-ia64/break.h>
 
 	/*
 	 * void jprobe_break(void)
 	 */
 	.section .kprobes.text, "ax"
 ENTRY(jprobe_break)
-	break.m 0x80300
+	break.m __IA64_BREAK_JPROBE
 END(jprobe_break)
 
 	/*
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 61f90b4..97c7763 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -88,6 +88,7 @@ static void __kprobes update_kprobe_inst
 {
 	p->ainsn.inst_flag = 0;
 	p->ainsn.target_br_reg = 0;
+	p->ainsn.slot = slot;
 
 	/* Check for Break instruction
 	 * Bits 37:40 Major opcode to be zero
@@ -364,12 +365,6 @@ static int __kprobes valid_kprobe_addr(i
 		return -EINVAL;
 	}
 
-	if (slot = 1 && bundle_encoding[template][1] != L) {
-		printk(KERN_WARNING "Inserting kprobes on slot #1 "
-		       "is not supported\n");
-		return -EINVAL;
-	}
-
 	return 0;
 }
 
@@ -527,23 +522,49 @@ int __kprobes arch_prepare_kprobe(struct
 
 void __kprobes arch_arm_kprobe(struct kprobe *p)
 {
-	unsigned long addr = (unsigned long)p->addr;
-	unsigned long arm_addr = addr & ~0xFULL;
+	unsigned long arm_addr;
+	bundle_t *src, *dest;
+
+	arm_addr = ((unsigned long)p->addr) & ~0xFUL;
+	dest = &((kprobe_opcode_t *)arm_addr)->bundle;
+	src = &p->opcode.bundle;
 
 	flush_icache_range((unsigned long)p->ainsn.insn,
 			(unsigned long)p->ainsn.insn + sizeof(kprobe_opcode_t));
-	memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
+	switch (p->ainsn.slot) {
+		case 0:
+			dest->quad0.slot0 = src->quad0.slot0;
+			break;
+		case 1:
+			dest->quad1.slot1_p1 = src->quad1.slot1_p1;
+			break;
+		case 2:
+			dest->quad1.slot2 = src->quad1.slot2;
+			break;
+	}
 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
 }
 
 void __kprobes arch_disarm_kprobe(struct kprobe *p)
 {
-	unsigned long addr = (unsigned long)p->addr;
-	unsigned long arm_addr = addr & ~0xFULL;
+	unsigned long arm_addr;
+	bundle_t *src, *dest;
 
+	arm_addr = ((unsigned long)p->addr) & ~0xFUL;
+	dest = &((kprobe_opcode_t *)arm_addr)->bundle;
 	/* p->ainsn.insn contains the original unaltered kprobe_opcode_t */
-	memcpy((char *) arm_addr, (char *) p->ainsn.insn,
-					 sizeof(kprobe_opcode_t));
+	src = &p->ainsn.insn->bundle;
+	switch (p->ainsn.slot) {
+		case 0:
+			dest->quad0.slot0 = src->quad0.slot0;
+			break;
+		case 1:
+			dest->quad1.slot1_p1 = src->quad1.slot1_p1;
+			break;
+		case 2:
+			dest->quad1.slot2 = src->quad1.slot2;
+			break;
+	}
 	flush_icache_range(arm_addr, arm_addr + sizeof(kprobe_opcode_t));
 }
 
@@ -876,7 +897,9 @@ int __kprobes kprobe_exceptions_notify(s
 	switch(val) {
 	case DIE_BREAK:
 		/* err is break number from ia64_bad_break() */
-		if (args->err = 0x80200 || args->err = 0x80300 || args->err = 0)
+		if ((args->err >> 12) = (__IA64_BREAK_KPROBE >> 12)
+			|| args->err = __IA64_BREAK_JPROBE
+			|| args->err = 0)
 			if (pre_kprobes_handler(args))
 				ret = NOTIFY_STOP;
 		break;
diff --git a/include/asm-ia64/break.h b/include/asm-ia64/break.h
index 8167828..875c1d2 100644
--- a/include/asm-ia64/break.h
+++ b/include/asm-ia64/break.h
@@ -12,8 +12,8 @@ #define _ASM_IA64_BREAK_H
  * OS-specific debug break numbers:
  */
 #define __IA64_BREAK_KDB		0x80100
-#define __IA64_BREAK_KPROBE		0x80200
-#define __IA64_BREAK_JPROBE		0x80300
+#define __IA64_BREAK_KPROBE		0x81000
+#define __IA64_BREAK_JPROBE		0x82000
 
 /*
  * OS-specific break numbers:
diff --git a/include/asm-ia64/kprobes.h b/include/asm-ia64/kprobes.h
index 1b45b71..828ae00 100644
--- a/include/asm-ia64/kprobes.h
+++ b/include/asm-ia64/kprobes.h
@@ -115,6 +115,7 @@ struct arch_specific_insn {
  #define INST_FLAG_BREAK_INST			4
  	unsigned long inst_flag;
  	unsigned short target_br_reg;
+	unsigned short slot;
 };
 
 extern int kprobe_exceptions_notify(struct notifier_block *self,
