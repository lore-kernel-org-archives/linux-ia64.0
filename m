From: Richard Guy Briggs <rgb@redhat.com>
Date: Wed, 05 Mar 2014 21:27:02 +0000
Subject: [PATCH 1/6][RFC] syscall: define syscall_get_arch() for each audit-supported arch
Message-Id: <cb88576237b1bc4fc7981200c2c23ae05790db0d.1393974970.git.rgb@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1393974970.git.rgb@redhat.com>
In-Reply-To: <cover.1393974970.git.rgb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org
Cc: Richard Guy Briggs <rgb@redhat.com>, eparis@redhat.com, sgrubb@redhat.com, oleg@redhat.com, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linux@openrisc.net, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-arch@vger.kernel.org

Each arch that supports audit requires syscall_get_arch() to able to log and
identify architecture-dependent syscall numbers.  The information is used in at
least two different subsystems, so standardize it in the same call across all
arches.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>

---
 arch/ia64/include/asm/syscall.h       |    7 +++++++
 arch/microblaze/include/asm/syscall.h |    6 ++++++
 arch/mips/include/asm/syscall.h       |    8 +++++++-
 arch/openrisc/include/asm/syscall.h   |    6 ++++++
 arch/parisc/include/asm/syscall.h     |   12 ++++++++++++
 arch/powerpc/include/asm/syscall.h    |   13 +++++++++++++
 arch/sh/include/asm/syscall.h         |   17 +++++++++++++++++
 arch/sparc/include/asm/syscall.h      |    8 ++++++++
 include/uapi/linux/audit.h            |    1 +
 9 files changed, 77 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index a7ff1c6..0fd2a7a 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -15,6 +15,7 @@
 
 #include <linux/sched.h>
 #include <linux/err.h>
+#include <linux/audit.h>
 
 static inline long syscall_get_nr(struct task_struct *task,
 				  struct pt_regs *regs)
@@ -79,4 +80,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 
 	ia64_syscall_get_set_arguments(task, regs, i, n, args, 1);
 }
+
+static inline int syscall_get_arch(struct task_struct *tsk,
+				   struct pt_regs *regs)
+{
+	return AUDIT_ARCH_IA64;
+}
 #endif	/* _ASM_SYSCALL_H */
diff --git a/arch/microblaze/include/asm/syscall.h b/arch/microblaze/include/asm/syscall.h
index 9bc4317..06854da 100644
--- a/arch/microblaze/include/asm/syscall.h
+++ b/arch/microblaze/include/asm/syscall.h
@@ -3,6 +3,7 @@
 
 #include <linux/kernel.h>
 #include <linux/sched.h>
+#include <linux/audit.h>
 #include <asm/ptrace.h>
 
 /* The system call number is given by the user in R12 */
@@ -99,4 +100,9 @@ static inline void syscall_set_arguments(struct task_struct *task,
 asmlinkage long do_syscall_trace_enter(struct pt_regs *regs);
 asmlinkage void do_syscall_trace_leave(struct pt_regs *regs);
 
+static inline int syscall_get_arch(struct tast_struct *tsk,
+				   struct pt_regs *regs)
+{
+	return AUDIT_ARCH_MICROBLAZE;
+}
 #endif /* __ASM_MICROBLAZE_SYSCALL_H */
diff --git a/arch/mips/include/asm/syscall.h b/arch/mips/include/asm/syscall.h
index 81c8913..41ecde4 100644
--- a/arch/mips/include/asm/syscall.h
+++ b/arch/mips/include/asm/syscall.h
@@ -103,7 +103,7 @@ extern const unsigned long sysn32_call_table[];
 
 static inline int __syscall_get_arch(void)
 {
-	int arch = EM_MIPS;
+	int arch = AUDIT_ARCH_MIPS;
 #ifdef CONFIG_64BIT
 	arch |=  __AUDIT_ARCH_64BIT;
 #endif
@@ -113,4 +113,10 @@ static inline int __syscall_get_arch(void)
 	return arch;
 }
 
+static inline int syscall_get_arch(struct task_struct *task,
+				   struct pt_regs *regs)
+{
+	return __syscall_get_arch();
+}
+
 #endif	/* __ASM_MIPS_SYSCALL_H */
diff --git a/arch/openrisc/include/asm/syscall.h b/arch/openrisc/include/asm/syscall.h
index b752bb6..534b9c3 100644
--- a/arch/openrisc/include/asm/syscall.h
+++ b/arch/openrisc/include/asm/syscall.h
@@ -21,6 +21,7 @@
 
 #include <linux/err.h>
 #include <linux/sched.h>
+#include <linux/audit.h>
 
 static inline int
 syscall_get_nr(struct task_struct *task, struct pt_regs *regs)
@@ -71,4 +72,9 @@ syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 	memcpy(&regs->gpr[3 + i], args, n * sizeof(args[0]));
 }
 
+static inline int syscall_get_arch(struct task_struct *tsk,
+				   struct pt_regs *regs)
+{
+	return AUDIT_ARCH_OPENRISC;
+}
 #endif
diff --git a/arch/parisc/include/asm/syscall.h b/arch/parisc/include/asm/syscall.h
index 8bdfd2c..b3b604f 100644
--- a/arch/parisc/include/asm/syscall.h
+++ b/arch/parisc/include/asm/syscall.h
@@ -4,6 +4,8 @@
 #define _ASM_PARISC_SYSCALL_H_
 
 #include <linux/err.h>
+#include <linux/compat.h>
+#include <linux/audit.h>
 #include <asm/ptrace.h>
 
 static inline long syscall_get_nr(struct task_struct *tsk,
@@ -37,4 +39,14 @@ static inline void syscall_get_arguments(struct task_struct *tsk,
 	}
 }
 
+static inline int syscall_get_arch(struct task_struct *tsk,
+				   struct pt_regs *regs)
+{
+	int arch = AUDIT_ARCH_PARISC;
+#ifdef CONFIG_64BIT
+	if (!is_compat_task())
+		arch = AUDIT_ARCH_PARISC64;
+#endif
+	return arch;
+}
 #endif /*_ASM_PARISC_SYSCALL_H_*/
diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/asm/syscall.h
index b54b2ad..b824eb2 100644
--- a/arch/powerpc/include/asm/syscall.h
+++ b/arch/powerpc/include/asm/syscall.h
@@ -14,6 +14,8 @@
 #define _ASM_SYSCALL_H	1
 
 #include <linux/sched.h>
+#include <linux/compat.h>
+#include <linux/audit.h>
 
 /* ftrace syscalls requires exporting the sys_call_table */
 #ifdef CONFIG_FTRACE_SYSCALLS
@@ -86,4 +88,15 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->gpr[3 + i], args, n * sizeof(args[0]));
 }
 
+static inline int syscall_get_arch(struct task_struct *tsk,
+				   struct pt_regs *regs)
+{
+	int arch = AUDIT_ARCH_PPC;
+
+#ifdef CONFIG_PPC64
+	if (!is_32bit_task())
+		arch = AUDIT_ARCH_PPC64;
+#endif
+	return arch;
+}
 #endif	/* _ASM_SYSCALL_H */
diff --git a/arch/sh/include/asm/syscall.h b/arch/sh/include/asm/syscall.h
index 847128d..f1a79d4 100644
--- a/arch/sh/include/asm/syscall.h
+++ b/arch/sh/include/asm/syscall.h
@@ -9,4 +9,21 @@ extern const unsigned long sys_call_table[];
 # include <asm/syscall_64.h>
 #endif
 
+# include <linux/audit.h>
+
+static inline int syscall_get_arch(struct task_struct *tsk,
+				   struct pt_regs *regs)
+{
+	int arch = AUDIT_ARCH_SH;
+
+#ifdef CONFIG_64BIT
+	arch |= __AUDIT_ARCH_64BIT;
+#endif
+#ifdef CONFIG_CPU_LITTLE_ENDIAN
+	arch |= __AUDIT_ARCH_LE;
+#endif
+
+	return arch;
+}
+
 #endif /* __ASM_SH_SYSCALL_H */
diff --git a/arch/sparc/include/asm/syscall.h b/arch/sparc/include/asm/syscall.h
index 025a02a..c7a8f75 100644
--- a/arch/sparc/include/asm/syscall.h
+++ b/arch/sparc/include/asm/syscall.h
@@ -3,6 +3,7 @@
 
 #include <linux/kernel.h>
 #include <linux/sched.h>
+#include <linux/audit.h>
 #include <asm/ptrace.h>
 
 /*
@@ -124,4 +125,11 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		regs->u_regs[UREG_I0 + i + j] = args[j];
 }
 
+static inline int syscall_get_arch(struct task_struct *tsk,
+				   struct pt_regs *regs)
+{
+	return test_thread_flag(TIF_32BIT) ? AUDIT_ARCH_SPARC
+					   : AUDIT_ARCH_SPARC64;
+}
+
 #endif /* __ASM_SPARC_SYSCALL_H */
diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
index 2d48fe1..b9c4826 100644
--- a/include/uapi/linux/audit.h
+++ b/include/uapi/linux/audit.h
@@ -342,6 +342,7 @@ enum {
 #define AUDIT_ARCH_IA64		(EM_IA_64|__AUDIT_ARCH_64BIT|__AUDIT_ARCH_LE)
 #define AUDIT_ARCH_M32R		(EM_M32R)
 #define AUDIT_ARCH_M68K		(EM_68K)
+#define AUDIT_ARCH_MICROBLAZE	(EM_MICROBLAZE)
 #define AUDIT_ARCH_MIPS		(EM_MIPS)
 #define AUDIT_ARCH_MIPSEL	(EM_MIPS|__AUDIT_ARCH_LE)
 #define AUDIT_ARCH_MIPS64	(EM_MIPS|__AUDIT_ARCH_64BIT)
-- 
1.7.1

