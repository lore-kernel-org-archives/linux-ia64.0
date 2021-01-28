From: Masahiro Yamada <masahiroy@kernel.org>
Date: Thu, 28 Jan 2021 00:50:46 +0000
Subject: [PATCH 04/27] x86/entry/x32: rename __x32_compat_sys_* to __x64_compat_sys_*
Message-Id: <20210128005110.2613902-5-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210128005110.2613902-1-masahiroy@kernel.org>
In-Reply-To: <20210128005110.2613902-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, x86@kernel.org
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>

In arch/x86/entry/syscall_x32.c, the macros are mapped to symbols
as follows:

  __SYSCALL_COMMON(nr, sym)  -->  __x64_<sym>
  __SYSCALL_X32(nr, sym)     -->  __x32_<sym>

Originally, the syscalls in the x32 special range (512-547) were all
compat.

This assumption is now broken after the following commits:

  55db9c0e8534 ("net: remove compat_sys_{get,set}sockopt")
  5f764d624a89 ("fs: remove the compat readv/writev syscalls")
  598b3cec831f ("fs: remove compat_sys_vmsplice")
  c3973b401ef2 ("mm: remove compat_process_vm_{readv,writev}")

Those commits redefined __x32_sys_* to __x64_sys_* because there is
no stub like __x32_sys_*.

I think defining as follows is sensible and cleaner.

  __SYSCALL_COMMON(nr, sym)  -->  __x64_<sym>
  __SYSCALL_X32(nr, sym)     -->  __x64_<sym>

The ugly #define __x32_sys_* will go away.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/x86/entry/syscall_x32.c           | 16 ++--------------
 arch/x86/include/asm/syscall_wrapper.h | 10 +++++-----
 2 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/arch/x86/entry/syscall_x32.c b/arch/x86/entry/syscall_x32.c
index f2fe0a33bcfd..3fea8fb9cd6a 100644
--- a/arch/x86/entry/syscall_x32.c
+++ b/arch/x86/entry/syscall_x32.c
@@ -8,27 +8,15 @@
 #include <asm/unistd.h>
 #include <asm/syscall.h>
 
-/*
- * Reuse the 64-bit entry points for the x32 versions that occupy different
- * slots in the syscall table.
- */
-#define __x32_sys_readv		__x64_sys_readv
-#define __x32_sys_writev	__x64_sys_writev
-#define __x32_sys_getsockopt	__x64_sys_getsockopt
-#define __x32_sys_setsockopt	__x64_sys_setsockopt
-#define __x32_sys_vmsplice	__x64_sys_vmsplice
-#define __x32_sys_process_vm_readv	__x64_sys_process_vm_readv
-#define __x32_sys_process_vm_writev	__x64_sys_process_vm_writev
-
 #define __SYSCALL_64(nr, sym)
 
-#define __SYSCALL_X32(nr, sym) extern long __x32_##sym(const struct pt_regs *);
+#define __SYSCALL_X32(nr, sym) extern long __x64_##sym(const struct pt_regs *);
 #define __SYSCALL_COMMON(nr, sym) extern long __x64_##sym(const struct pt_regs *);
 #include <asm/syscalls_64.h>
 #undef __SYSCALL_X32
 #undef __SYSCALL_COMMON
 
-#define __SYSCALL_X32(nr, sym) [nr] = __x32_##sym,
+#define __SYSCALL_X32(nr, sym) [nr] = __x64_##sym,
 #define __SYSCALL_COMMON(nr, sym) [nr] = __x64_##sym,
 
 asmlinkage const sys_call_ptr_t x32_sys_call_table[__NR_x32_syscall_max+1] = {
diff --git a/arch/x86/include/asm/syscall_wrapper.h b/arch/x86/include/asm/syscall_wrapper.h
index 80c08c7d5e72..6a2827d0681f 100644
--- a/arch/x86/include/asm/syscall_wrapper.h
+++ b/arch/x86/include/asm/syscall_wrapper.h
@@ -17,7 +17,7 @@ extern long __ia32_sys_ni_syscall(const struct pt_regs *regs);
  * __x64_sys_*()         - 64-bit native syscall
  * __ia32_sys_*()        - 32-bit native syscall or common compat syscall
  * __ia32_compat_sys_*() - 32-bit compat syscall
- * __x32_compat_sys_*()  - 64-bit X32 compat syscall
+ * __x64_compat_sys_*()  - 64-bit X32 compat syscall
  *
  * The registers are decoded according to the ABI:
  * 64-bit: RDI, RSI, RDX, R10, R8, R9
@@ -166,17 +166,17 @@ extern long __ia32_sys_ni_syscall(const struct pt_regs *regs);
  * with x86_64 obviously do not need such care.
  */
 #define __X32_COMPAT_SYS_STUB0(name)					\
-	__SYS_STUB0(x32, compat_sys_##name)
+	__SYS_STUB0(x64, compat_sys_##name)
 
 #define __X32_COMPAT_SYS_STUBx(x, name, ...)				\
-	__SYS_STUBx(x32, compat_sys##name,				\
+	__SYS_STUBx(x64, compat_sys##name,				\
 		    SC_X86_64_REGS_TO_ARGS(x, __VA_ARGS__))
 
 #define __X32_COMPAT_COND_SYSCALL(name)					\
-	__COND_SYSCALL(x32, compat_sys_##name)
+	__COND_SYSCALL(x64, compat_sys_##name)
 
 #define __X32_COMPAT_SYS_NI(name)					\
-	__SYS_NI(x32, compat_sys_##name)
+	__SYS_NI(x64, compat_sys_##name)
 #else /* CONFIG_X86_X32 */
 #define __X32_COMPAT_SYS_STUB0(name)
 #define __X32_COMPAT_SYS_STUBx(x, name, ...)
-- 
2.27.0
