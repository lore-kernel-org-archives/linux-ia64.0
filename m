From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Date: Wed, 07 May 2014 11:55:51 +0000
Subject: [RFT PATCH -next ] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <20140507115551.22259.70581.stgit@ltc230.yrl.intra.hitachi.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <536A16A6.5040709@hitachi.com>
In-Reply-To: <536A16A6.5040709@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Tony Luck <tony.luck@gmail.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, akataria@vmware.com, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, linuxppc-dev@lists.ozlabs.org, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

On ia64 and ppc64, the function pointer does not point the
entry address of the function, but the address of function
discriptor (which contains the entry address and misc
data.) Since the kprobes passes the function pointer stored
by NOKPROBE_SYMBOL() to kallsyms_lookup_size_offset() for
initalizing its blacklist, it fails and reports many errors
as below.

  Failed to find blacklist 0001013168300000
  Failed to find blacklist 0001013000f0a000
  Failed to find blacklist 000101315f70a000
  Failed to find blacklist 000101324c80a000
  Failed to find blacklist 0001013063f0a000
  Failed to find blacklist 000101327800a000
  Failed to find blacklist 0001013277f0a000
  Failed to find blacklist 000101315a70a000
  Failed to find blacklist 0001013277e0a000
  Failed to find blacklist 000101305a20a000
  Failed to find blacklist 0001013277d0a000
  Failed to find blacklist 00010130bdc0a000
  Failed to find blacklist 00010130dc20a000
  Failed to find blacklist 000101309a00a000
  Failed to find blacklist 0001013277c0a000
  Failed to find blacklist 0001013277b0a000
  Failed to find blacklist 0001013277a0a000
  Failed to find blacklist 000101327790a000
  Failed to find blacklist 000101303140a000
  Failed to find blacklist 0001013a3280a000

To fix this bug, this introduces function_entry() macro to
retrieve the entry address from the given function pointer,
and uses it in NOKPROBE_SYMBOL().


Signed-off-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Reported-by: Tony Luck <tony.luck@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Kevin Hao <haokexin@gmail.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
---
 arch/ia64/include/asm/types.h    |    2 ++
 arch/powerpc/include/asm/types.h |   11 +++++++++++
 include/linux/kprobes.h          |    3 ++-
 include/linux/types.h            |    4 ++++
 4 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/types.h b/arch/ia64/include/asm/types.h
index 4c351b1..6ab7b6c 100644
--- a/arch/ia64/include/asm/types.h
+++ b/arch/ia64/include/asm/types.h
@@ -27,5 +27,7 @@ struct fnptr {
 	unsigned long gp;
 };
 
+#define constant_function_entry(fn) (((struct fnptr *)(fn))->ip)
+
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_IA64_TYPES_H */
diff --git a/arch/powerpc/include/asm/types.h b/arch/powerpc/include/asm/types.h
index bfb6ded..fd297b8 100644
--- a/arch/powerpc/include/asm/types.h
+++ b/arch/powerpc/include/asm/types.h
@@ -25,6 +25,17 @@ typedef struct {
 	unsigned long env;
 } func_descr_t;
 
+#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF = 1)
+/*
+ * On PPC64 ABIv1 the function pointer actually points to the
+ * function's descriptor. The first entry in the descriptor is the
+ * address of the function text.
+ */
+#define constant_function_entry(fn)	(((func_descr_t *)(fn))->entry)
+#else
+#define constant_function_entry(fn)	((unsigned long)(fn))
+#endif
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_POWERPC_TYPES_H */
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index e059507..637eafe 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -40,6 +40,7 @@
 #include <linux/rcupdate.h>
 #include <linux/mutex.h>
 #include <linux/ftrace.h>
+#include <linux/types.h>
 
 #ifdef CONFIG_KPROBES
 #include <asm/kprobes.h>
@@ -485,7 +486,7 @@ static inline int enable_jprobe(struct jprobe *jp)
 #define __NOKPROBE_SYMBOL(fname)			\
 static unsigned long __used				\
 	__attribute__((section("_kprobe_blacklist")))	\
-	_kbl_addr_##fname = (unsigned long)fname;
+	_kbl_addr_##fname = constant_function_entry(fname);
 #define NOKPROBE_SYMBOL(fname)	__NOKPROBE_SYMBOL(fname)
 #else
 #define NOKPROBE_SYMBOL(fname)
diff --git a/include/linux/types.h b/include/linux/types.h
index 4d118ba..78e2d7d 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -212,5 +212,9 @@ struct callback_head {
 };
 #define rcu_head callback_head
 
+#ifndef constant_function_entry
+#define constant_function_entry(fn)	((unsigned long)(fn))
+#endif
+
 #endif /*  __ASSEMBLY__ */
 #endif /* _LINUX_TYPES_H */


