From: Nicholas Krause <xerofoify@gmail.com>
Date: Fri, 18 Jul 2014 05:25:02 +0000
Subject: [PATCH] ia64: Fix me add register r8
Message-Id: <1405661102-11967-1-git-send-email-xerofoify@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The function user_stack_pointer was not returning the correct value \
as stated by a Fix Me message before the function declaration. I
fixed the return value to add register r8 as that register stores
dirty pages.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 arch/ia64/include/asm/ptrace.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/ptrace.h b/arch/ia64/include/asm/ptrace.h
index 8451439..eaef692 100644
--- a/arch/ia64/include/asm/ptrace.h
+++ b/arch/ia64/include/asm/ptrace.h
@@ -53,8 +53,7 @@
 
 static inline unsigned long user_stack_pointer(struct pt_regs *regs)
 {
-	/* FIXME: should this be bspstore + nr_dirty regs? */
-	return regs->ar_bspstore;
+	return regs->ar_bspstore + regs->r8;
 }
 
 static inline int is_syscall_success(struct pt_regs *regs)
-- 
1.9.1

