From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Wed, 31 Mar 2021 08:44:47 +0000
Subject: [PATCH] ia64: fix user_stack_pointer() for ptrace()
Message-Id: <20210331084447.2561532-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Sergei Trofimovich <slyfox@gentoo.org>, Oleg Nesterov <oleg@redhat.com>, linux-ia64@vger.kernel.org, "Dmitry V . Levin" <ldv@altlinux.org>

ia64 has two stacks:
- memory stack (or stack), pointed at by by r12
- register backing store (register stack), pointed at
  ar.bsp/ar.bspstore with complications around dirty
  register frame on CPU.

In https://bugs.gentoo.org/769614 Dmitry noticed that
PTRACE_GET_SYSCALL_INFO returns register stack instead
memory stack.

The bug comes from the fact that user_stack_pointer() and
current_user_stack_pointer() don't return the same register:

  ulong user_stack_pointer(struct pt_regs *regs) { return regs->ar_bspstore; }
  #define current_user_stack_pointer() (current_pt_regs()->r12)

The change gets both back in sync.

I think ptrace(PTRACE_GET_SYSCALL_INFO) is the only affected user
by this bug on ia64.

The change fixes 'rt_sigreturn.gen.test' strace test where
it was observed initially.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Oleg Nesterov <oleg@redhat.com>
CC: linux-ia64@vger.kernel.org
Bug: https://bugs.gentoo.org/769614
Reported-by: Dmitry V. Levin <ldv@altlinux.org>
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 arch/ia64/include/asm/ptrace.h | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/ia64/include/asm/ptrace.h b/arch/ia64/include/asm/ptrace.h
index b3aa46090101..08179135905c 100644
--- a/arch/ia64/include/asm/ptrace.h
+++ b/arch/ia64/include/asm/ptrace.h
@@ -54,8 +54,7 @@
 
 static inline unsigned long user_stack_pointer(struct pt_regs *regs)
 {
-	/* FIXME: should this be bspstore + nr_dirty regs? */
-	return regs->ar_bspstore;
+	return regs->r12;
 }
 
 static inline int is_syscall_success(struct pt_regs *regs)
@@ -79,11 +78,6 @@ static inline long regs_return_value(struct pt_regs *regs)
 	unsigned long __ip = instruction_pointer(regs);			\
 	(__ip & ~3UL) + ((__ip & 3UL) << 2);				\
 })
-/*
- * Why not default?  Because user_stack_pointer() on ia64 gives register
- * stack backing store instead...
- */
-#define current_user_stack_pointer() (current_pt_regs()->r12)
 
   /* given a pointer to a task_struct, return the user's pt_regs */
 # define task_pt_regs(t)		(((struct pt_regs *) ((char *) (t) + IA64_STK_OFFSET)) - 1)
-- 
2.31.1
