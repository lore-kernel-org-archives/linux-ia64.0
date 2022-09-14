From: Gaosheng Cui <cuigaosheng1@huawei.com>
Date: Wed, 14 Sep 2022 12:47:07 +0000
Subject: [PATCH] ia64/kprobes: Remove orphan declarations from arch/ia64/include/asm/kprobes.h
Message-Id: <20220914124707.1483471-1-cuigaosheng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

flush_register_stack() and invalidate_stacked_regs()
have been removed since commit 0aeaf6b3a345 ("ia64/kprobes:
Remove jprobe implementation"), so remove them.

Signed-off-by: Gaosheng Cui <cuigaosheng1@huawei.com>
---
 arch/ia64/include/asm/kprobes.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/ia64/include/asm/kprobes.h b/arch/ia64/include/asm/kprobes.h
index c5cf5e4fb338..9e956768946c 100644
--- a/arch/ia64/include/asm/kprobes.h
+++ b/arch/ia64/include/asm/kprobes.h
@@ -110,8 +110,6 @@ extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
 
-extern void invalidate_stacked_regs(void);
-extern void flush_register_stack(void);
 extern void arch_remove_kprobe(struct kprobe *p);
 
 #endif /* CONFIG_KPROBES */
-- 
2.25.1
