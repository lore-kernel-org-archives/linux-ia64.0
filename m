From: Michael Ellerman <michael@ellerman.id.au>
Date: Tue, 26 Jun 2007 01:48:51 +0000
Subject: [PATCH 3/3] Make jprobes a little safer for users
Message-Id: <7a070581b2fe53ea65216e86c86abc4f40464341.1182822366.git.michael@ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
In-Reply-To: <78935473b1f70c863ab0be7d6cf4bcb04922b20b.1182822366.git.michael@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, anil.s.keshavamurthy@intel.com, ananth@in.ibm.com

I realise jprobes are a razor-blades-included type of interface, but
that doesn't mean we can't try and make them safer to use. This guy I
know once wrote code like this:

struct jprobe jp = { .kp.symbol_name = "foo", .entry = "jprobe_foo" };

And then his kernel exploded. Oops.

This patch adds an arch hook, arch_deref_entry_point() (I don't like it either)
which takes the void * in a struct jprobe, and gives back the text address
that it represents.

We can then use that in register_jprobe() to check that the entry point
we're passed is actually in the kernel text, rather than just some random
value.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---
 arch/ia64/kernel/kprobes.c    |    7 ++++++-
 arch/powerpc/kernel/kprobes.c |   11 ++++++++---
 kernel/kprobes.c              |    9 +++++++++
 3 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 5bc46f1..5dc98b5 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -936,10 +936,15 @@ static void ia64_get_bsp_cfm(struct unw_frame_info *info, void *arg)
 	return;
 }
 
+unsigned long arch_deref_entry_point(void *entry)
+{
+	return ((struct fnptr *)entry)->ip;
+}
+
 int __kprobes setjmp_pre_handler(struct kprobe *p, struct pt_regs *regs)
 {
 	struct jprobe *jp = container_of(p, struct jprobe, kp);
-	unsigned long addr = ((struct fnptr *)(jp->entry))->ip;
+	unsigned long addr = arch_deref_entry_point(jp->entry);
 	struct kprobe_ctlblk *kcb = get_kprobe_ctlblk();
 	struct param_bsp_cfm pa;
 	int bytes;
diff --git a/arch/powerpc/kernel/kprobes.c b/arch/powerpc/kernel/kprobes.c
index 0c96611..440f5a8 100644
--- a/arch/powerpc/kernel/kprobes.c
+++ b/arch/powerpc/kernel/kprobes.c
@@ -492,6 +492,13 @@ int __kprobes kprobe_exceptions_notify(struct notifier_block *self,
 	return ret;
 }
 
+#ifdef CONFIG_PPC64
+unsigned long arch_deref_entry_point(void *entry)
+{
+	return (unsigned long)(((func_descr_t *)entry)->entry);
+}
+#endif
+
 int __kprobes setjmp_pre_handler(struct kprobe *p, struct pt_regs *regs)
 {
 	struct jprobe *jp = container_of(p, struct jprobe, kp);
@@ -500,11 +507,9 @@ int __kprobes setjmp_pre_handler(struct kprobe *p, struct pt_regs *regs)
 	memcpy(&kcb->jprobe_saved_regs, regs, sizeof(struct pt_regs));
 
 	/* setup return addr to the jprobe handler routine */
+	regs->nip = arch_deref_entry_point(jp->entry);
 #ifdef CONFIG_PPC64
-	regs->nip = (unsigned long)(((func_descr_t *)jp->entry)->entry);
 	regs->gpr[2] = (unsigned long)(((func_descr_t *)jp->entry)->toc);
-#else
-	regs->nip = (unsigned long)jp->entry;
 #endif
 
 	return 1;
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 9e47d8c..3e9f513 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -675,9 +675,18 @@ static struct notifier_block kprobe_exceptions_nb = {
 	.priority = 0x7fffffff /* we need to be notified first */
 };
 
+unsigned long __weak arch_deref_entry_point(void *entry)
+{
+	return (unsigned long)entry;
+}
 
 int __kprobes register_jprobe(struct jprobe *jp)
 {
+	unsigned long addr = arch_deref_entry_point(jp->entry);
+
+	if (!kernel_text_address(addr))
+		return -EINVAL;
+
 	/* Todo: Verify probepoint is a function entry point */
 	jp->kp.pre_handler = setjmp_pre_handler;
 	jp->kp.break_handler = longjmp_break_handler;
-- 
1.5.1.3.g7a33b

