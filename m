From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 03 Mar 2008 18:07:22 +0000
Subject: [2.6 patch] fix ia64 kprobes compilation
Message-Id: <20080303180722.GG26072@cs181133002.pp.htv.fi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: prasanna@in.ibm.com, ananth@in.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This patch fixes the following compile error with a recent gcc:

<--  snip  -->

...
  CC      kernel/kprobes.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/kernel/kprobes.c:1066: error: __ksymtab_jprobe_return causes a section type conflict
make[2]: *** [kernel/kprobes.o] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 arch/ia64/kernel/kprobes.c |    5 +++++
 include/asm-ia64/kprobes.h |    4 ----
 2 files changed, 5 insertions(+), 4 deletions(-)

20bd2855f85dd0ac9d76df414aeef8c82d2ec668 foobar
diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index b618487..615c3d2 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -1001,6 +1001,11 @@ int __kprobes setjmp_pre_handler(struct kprobe *p, struct pt_regs *regs)
 	return 1;
 }
 
+/* ia64 does not need this */
+void __kprobes jprobe_return(void)
+{
+}
+
 int __kprobes longjmp_break_handler(struct kprobe *p, struct pt_regs *regs)
 {
 	struct kprobe_ctlblk *kcb = get_kprobe_ctlblk();
diff --git a/include/asm-ia64/kprobes.h b/include/asm-ia64/kprobes.h
index a93ce9e..49684b6 100644
--- a/include/asm-ia64/kprobes.h
+++ b/include/asm-ia64/kprobes.h
@@ -122,10 +122,6 @@ extern int kprobes_fault_handler(struct pt_regs *regs, int trapnr);
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
 
-/* ia64 does not need this */
-static inline void jprobe_return(void)
-{
-}
 extern void invalidate_stacked_regs(void);
 extern void flush_register_stack(void);
 extern void arch_remove_kprobe(struct kprobe *p);

