From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Jan 2013 18:33:48 +0000
Subject: [PATCH] [IA64] Wire up finit_module syscall
Message-Id: <2f8c256f88493da2c1f8cf370bd87a4beefceb1f.1357237777.git.tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linux was granted a new system call to load modules by
file descriptor in:

  commit 34e1169d996ab148490c01b65b4ee371cf8ffba2
  module: add syscall to load module from fd

Wire it up for ia64 (ready for the Chrome port :-)

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/asm/unistd.h      |    2 +-
 arch/ia64/include/uapi/asm/unistd.h |    1 +
 arch/ia64/kernel/entry.S            |    1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 8b3ff2f..c3cc42a 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -11,7 +11,7 @@
 
 
 
-#define NR_syscalls			311 /* length of syscall table */
+#define NR_syscalls			312 /* length of syscall table */
 
 /*
  * The following defines stop scripts/checksyscalls.sh from complaining about
diff --git a/arch/ia64/include/uapi/asm/unistd.h b/arch/ia64/include/uapi/asm/unistd.h
index b706aa5..34fd6fe 100644
--- a/arch/ia64/include/uapi/asm/unistd.h
+++ b/arch/ia64/include/uapi/asm/unistd.h
@@ -324,5 +324,6 @@
 #define __NR_process_vm_readv		1332
 #define __NR_process_vm_writev		1333
 #define __NR_accept4			1334
+#define __NR_finit_module		1335
 
 #endif /* _UAPI_ASM_IA64_UNISTD_H */
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index e25b784..6bfd842 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1785,6 +1785,7 @@ sys_call_table:
 	data8 sys_process_vm_readv
 	data8 sys_process_vm_writev
 	data8 sys_accept4
+	data8 sys_finit_module			// 1335
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
 #endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
-- 
1.7.10.4

