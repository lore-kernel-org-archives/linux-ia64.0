From: Richard Guy Briggs <rgb@redhat.com>
Date: Wed, 05 Mar 2014 21:27:04 +0000
Subject: [PATCH 3/6][RFC] audit: __audit_syscall_entry: ignore arch arg and call syscall_get_arch() directly
Message-Id: <fc170f50376a56ea82d25fbf1587f64b76177e0f.1393974970.git.rgb@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1393974970.git.rgb@redhat.com>
In-Reply-To: <cover.1393974970.git.rgb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org
Cc: Richard Guy Briggs <rgb@redhat.com>, eparis@redhat.com, sgrubb@redhat.com, oleg@redhat.com, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linux@openrisc.net, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-arch@vger.kernel.org

Since all the callers of syscall_get_arch() presently pass "current" and none
of the arch-specific syscall_get_arch() implementations use the regs parameter,
ignore the passed in arch parameter to __audit_syscall_entry() and call
syscall_get_arch() directly.

Change the audit header file from the kernel internal to the user api version
to get the architecture numbers, but to avoid a circular header reference
between audit and syscall.h

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>

---
 arch/arm/include/asm/syscall.h        |    2 +-
 arch/ia64/include/asm/syscall.h       |    2 +-
 arch/microblaze/include/asm/syscall.h |    2 +-
 arch/mips/include/asm/syscall.h       |    2 +-
 arch/openrisc/include/asm/syscall.h   |    2 +-
 arch/parisc/include/asm/syscall.h     |    2 +-
 arch/powerpc/include/asm/syscall.h    |    2 +-
 arch/s390/include/asm/syscall.h       |    2 +-
 arch/sh/include/asm/syscall.h         |    2 +-
 arch/sparc/include/asm/syscall.h      |    2 +-
 arch/x86/include/asm/syscall.h        |    2 +-
 kernel/auditsc.c                      |    2 +-
 12 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
index 73ddd72..a749123 100644
--- a/arch/arm/include/asm/syscall.h
+++ b/arch/arm/include/asm/syscall.h
@@ -7,7 +7,7 @@
 #ifndef _ASM_ARM_SYSCALL_H
 #define _ASM_ARM_SYSCALL_H
 
-#include <linux/audit.h> /* for AUDIT_ARCH_* */
+#include <uapi/linux/audit.h> /* for AUDIT_ARCH_* */
 #include <linux/elf.h> /* for ELF_EM */
 #include <linux/err.h>
 #include <linux/sched.h>
diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index 0fd2a7a..9c82767 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -15,7 +15,7 @@
 
 #include <linux/sched.h>
 #include <linux/err.h>
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 
 static inline long syscall_get_nr(struct task_struct *task,
 				  struct pt_regs *regs)
diff --git a/arch/microblaze/include/asm/syscall.h b/arch/microblaze/include/asm/syscall.h
index 06854da..e1acf8a 100644
--- a/arch/microblaze/include/asm/syscall.h
+++ b/arch/microblaze/include/asm/syscall.h
@@ -3,7 +3,7 @@
 
 #include <linux/kernel.h>
 #include <linux/sched.h>
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 #include <asm/ptrace.h>
 
 /* The system call number is given by the user in R12 */
diff --git a/arch/mips/include/asm/syscall.h b/arch/mips/include/asm/syscall.h
index 41ecde4..a8234f2 100644
--- a/arch/mips/include/asm/syscall.h
+++ b/arch/mips/include/asm/syscall.h
@@ -13,7 +13,7 @@
 #ifndef __ASM_MIPS_SYSCALL_H
 #define __ASM_MIPS_SYSCALL_H
 
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 #include <linux/elf-em.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
diff --git a/arch/openrisc/include/asm/syscall.h b/arch/openrisc/include/asm/syscall.h
index 534b9c3..2bbe0e9 100644
--- a/arch/openrisc/include/asm/syscall.h
+++ b/arch/openrisc/include/asm/syscall.h
@@ -21,7 +21,7 @@
 
 #include <linux/err.h>
 #include <linux/sched.h>
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 
 static inline int
 syscall_get_nr(struct task_struct *task, struct pt_regs *regs)
diff --git a/arch/parisc/include/asm/syscall.h b/arch/parisc/include/asm/syscall.h
index b3b604f..2bf23b1 100644
--- a/arch/parisc/include/asm/syscall.h
+++ b/arch/parisc/include/asm/syscall.h
@@ -5,7 +5,7 @@
 
 #include <linux/err.h>
 #include <linux/compat.h>
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 #include <asm/ptrace.h>
 
 static inline long syscall_get_nr(struct task_struct *tsk,
diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/asm/syscall.h
index b824eb2..36bd9ef 100644
--- a/arch/powerpc/include/asm/syscall.h
+++ b/arch/powerpc/include/asm/syscall.h
@@ -15,7 +15,7 @@
 
 #include <linux/sched.h>
 #include <linux/compat.h>
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 
 /* ftrace syscalls requires exporting the sys_call_table */
 #ifdef CONFIG_FTRACE_SYSCALLS
diff --git a/arch/s390/include/asm/syscall.h b/arch/s390/include/asm/syscall.h
index cd29d2f..79d1805 100644
--- a/arch/s390/include/asm/syscall.h
+++ b/arch/s390/include/asm/syscall.h
@@ -12,7 +12,7 @@
 #ifndef _ASM_SYSCALL_H
 #define _ASM_SYSCALL_H	1
 
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 #include <linux/sched.h>
 #include <linux/err.h>
 #include <asm/ptrace.h>
diff --git a/arch/sh/include/asm/syscall.h b/arch/sh/include/asm/syscall.h
index f1a79d4..33e60e0 100644
--- a/arch/sh/include/asm/syscall.h
+++ b/arch/sh/include/asm/syscall.h
@@ -9,7 +9,7 @@ extern const unsigned long sys_call_table[];
 # include <asm/syscall_64.h>
 #endif
 
-# include <linux/audit.h>
+# include <uapi/linux/audit.h>
 
 static inline int syscall_get_arch(struct task_struct *tsk,
 				   struct pt_regs *regs)
diff --git a/arch/sparc/include/asm/syscall.h b/arch/sparc/include/asm/syscall.h
index c7a8f75..eddc60e 100644
--- a/arch/sparc/include/asm/syscall.h
+++ b/arch/sparc/include/asm/syscall.h
@@ -3,7 +3,7 @@
 
 #include <linux/kernel.h>
 #include <linux/sched.h>
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 #include <asm/ptrace.h>
 
 /*
diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index aea284b..c98e0ec 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -13,7 +13,7 @@
 #ifndef _ASM_X86_SYSCALL_H
 #define _ASM_X86_SYSCALL_H
 
-#include <linux/audit.h>
+#include <uapi/linux/audit.h>
 #include <linux/sched.h>
 #include <linux/err.h>
 #include <asm/asm-offsets.h>	/* For NR_syscalls */
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 7317f46..0c9fe06 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1461,7 +1461,7 @@ void __audit_syscall_entry(int arch, int major,
 	if (!audit_enabled)
 		return;
 
-	context->arch	    = arch;
+	context->arch	    = syscall_get_arch(current, NULL);
 	context->major      = major;
 	context->argv[0]    = a1;
 	context->argv[1]    = a2;
-- 
1.7.1

