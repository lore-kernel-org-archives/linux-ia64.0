From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Sep 2015 20:50:18 +0000
Subject: [PATCH] ia64: Enable userfaultfd and membarrier system calls
Message-Id: <70e33205810465119702be0f69549a15072c6581.1442352474.git.tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/asm/unistd.h      | 2 +-
 arch/ia64/include/uapi/asm/unistd.h | 2 ++
 arch/ia64/kernel/entry.S            | 2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 95c39b95e97e..99c96a5e6016 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -11,7 +11,7 @@
 
 
 
-#define NR_syscalls			319 /* length of syscall table */
+#define NR_syscalls			321 /* length of syscall table */
 
 /*
  * The following defines stop scripts/checksyscalls.sh from complaining about
diff --git a/arch/ia64/include/uapi/asm/unistd.h b/arch/ia64/include/uapi/asm/unistd.h
index 461079560c78..98e94e19a5a0 100644
--- a/arch/ia64/include/uapi/asm/unistd.h
+++ b/arch/ia64/include/uapi/asm/unistd.h
@@ -332,5 +332,7 @@
 #define __NR_memfd_create		1340
 #define __NR_bpf			1341
 #define __NR_execveat			1342
+#define __NR_userfaultfd		1343
+#define __NR_membarrier			1344
 
 #endif /* _UAPI_ASM_IA64_UNISTD_H */
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index ae0de7bf5525..37cc7a65cd3e 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1768,5 +1768,7 @@ sys_call_table:
 	data8 sys_memfd_create			// 1340
 	data8 sys_bpf
 	data8 sys_execveat
+	data8 sys_userfaultfd
+	data8 sys_membarrier
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
-- 
2.1.4

