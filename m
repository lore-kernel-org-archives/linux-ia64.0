From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:31 +0000
Subject: [PATCH 16/50] ia64/pv_ops: hook pal_call_static() for paravirtualization.
Message-Id: <12047411461848-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/pal.S    |    5 +++--
 include/asm-ia64/privop.h |    1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
index 0b53344..d52fd70 100644
--- a/arch/ia64/kernel/pal.S
+++ b/arch/ia64/kernel/pal.S
@@ -16,6 +16,7 @@
 #include <asm/processor.h>
 
 	.data
+	.globl pal_entry_point
 pal_entry_point:
 	data8 ia64_pal_default_handler
 	.text
@@ -52,7 +53,7 @@ END(ia64_pal_default_handler)
  * in0         Index of PAL service
  * in1 - in3   Remaining PAL arguments
  */
-GLOBAL_ENTRY(ia64_pal_call_static)
+GLOBAL_ENTRY(native_pal_call_static)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(4)
 	alloc loc1 = ar.pfs,4,5,0,0
 	movl loc2 = pal_entry_point
@@ -86,7 +87,7 @@ GLOBAL_ENTRY(ia64_pal_call_static)
 	;;
 	srlz.d				// seralize restoration of psr.l
 	br.ret.sptk.many b0
-END(ia64_pal_call_static)
+END(native_pal_call_static)
 
 /*
  * Make a PAL call using the stacked registers calling convention.
diff --git a/include/asm-ia64/privop.h b/include/asm-ia64/privop.h
index 11d26f7..7b9de4f 100644
--- a/include/asm-ia64/privop.h
+++ b/include/asm-ia64/privop.h
@@ -21,6 +21,7 @@
 #define ia64_leave_syscall		native_leave_syscall
 #define ia64_work_processed_syscall	native_work_processed_syscall
 #define ia64_leave_kernel		native_leave_kernel
+#define ia64_pal_call_static		native_pal_call_static
 #endif /* !IA64_PARAVIRTUALIZED_ENTRY */
 
 #endif /* _ASM_IA64_PRIVOP_H */
-- 
1.5.3

