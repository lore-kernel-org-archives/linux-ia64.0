From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 20 Feb 2009 11:52:44 +0000
Subject: [PATCH] IA64: cast has a higher precedence than '?'
Message-Id: <499E998C.9060407@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A cast has a higher precedence than '?'

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index 2f758a4..3fc1832 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -64,7 +64,7 @@ static inline void syscall_set_return_value(struct task_struct *task,
 {
 #ifdef CONFIG_IA32_SUPPORT
 	if (IS_IA32_PROCESS(regs)) {
-		regs->r8 = (long) error ? error : val;
+		regs->r8 = (long) (error ? error : val);
 		return;
 	}
 #endif

