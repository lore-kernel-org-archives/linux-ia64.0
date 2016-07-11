From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 11 Jul 2016 20:53:51 +0000
Subject: [PATCH v5 18/32] signal: Consolidate {TS,TLF}_RESTORE_SIGMASK code
Message-Id: <dc84a1b979d800049bfd0629ed9380238cba2807.1468270393.git.luto@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1468270393.git.luto@kernel.org>
In-Reply-To: <cover.1468270393.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andy Lutomirski <luto@kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@suse.de>, Dmitry Safonov <dsafonov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

In general, there's no need for the "restore sigmask" flag to live in
ti->flags.  alpha, ia64, microblaze, powerpc, sh, sparc (64-bit only),
tile, and x86 use essentially identical alternative implementations,
placing the flag in ti->status.

Replace those optimized implementations with an equally good common
implementation that stores it in a bitfield in struct task_struct
and drop the custom implementations.

Additional architectures can opt in by removing their
TIF_RESTORE_SIGMASK defines.

Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: x86@kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/alpha/include/asm/thread_info.h      | 27 -------------
 arch/ia64/include/asm/thread_info.h       | 28 --------------
 arch/microblaze/include/asm/thread_info.h | 27 -------------
 arch/powerpc/include/asm/thread_info.h    | 25 ------------
 arch/sh/include/asm/thread_info.h         | 26 -------------
 arch/sparc/include/asm/thread_info_64.h   | 24 ------------
 arch/tile/include/asm/thread_info.h       | 27 -------------
 arch/x86/include/asm/thread_info.h        | 24 ------------
 include/linux/sched.h                     | 63 +++++++++++++++++++++++++++++++
 include/linux/thread_info.h               | 41 --------------------
 10 files changed, 63 insertions(+), 249 deletions(-)

diff --git a/arch/alpha/include/asm/thread_info.h b/arch/alpha/include/asm/thread_info.h
index 32e920a83ae5..e9e90bfa2b50 100644
--- a/arch/alpha/include/asm/thread_info.h
+++ b/arch/alpha/include/asm/thread_info.h
@@ -86,33 +86,6 @@ register struct thread_info *__current_thread_info __asm__("$8");
 #define TS_UAC_NOPRINT		0x0001	/* ! Preserve the following three */
 #define TS_UAC_NOFIX		0x0002	/* ! flags as they match          */
 #define TS_UAC_SIGBUS		0x0004	/* ! userspace part of 'osf_sysinfo' */
-#define TS_RESTORE_SIGMASK	0x0008	/* restore signal mask in do_signal() */
-
-#ifndef __ASSEMBLY__
-#define HAVE_SET_RESTORE_SIGMASK	1
-static inline void set_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	ti->status |= TS_RESTORE_SIGMASK;
-	WARN_ON(!test_bit(TIF_SIGPENDING, (unsigned long *)&ti->flags));
-}
-static inline void clear_restore_sigmask(void)
-{
-	current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
-}
-static inline bool test_restore_sigmask(void)
-{
-	return current_thread_info()->status & TS_RESTORE_SIGMASK;
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	if (!(ti->status & TS_RESTORE_SIGMASK))
-		return false;
-	ti->status &= ~TS_RESTORE_SIGMASK;
-	return true;
-}
-#endif
 
 #define SET_UNALIGN_CTL(task,value)	({				\
 	__u32 status = task_thread_info(task)->status & ~UAC_BITMASK;	\
diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/asm/thread_info.h
index f0a72e98e5a4..c7026429816b 100644
--- a/arch/ia64/include/asm/thread_info.h
+++ b/arch/ia64/include/asm/thread_info.h
@@ -121,32 +121,4 @@ struct thread_info {
 /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_AUDIT */
 #define TIF_WORK_MASK		(TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRACE|_TIF_SYSCALL_AUDIT))
 
-#define TS_RESTORE_SIGMASK	2	/* restore signal mask in do_signal() */
-
-#ifndef __ASSEMBLY__
-#define HAVE_SET_RESTORE_SIGMASK	1
-static inline void set_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	ti->status |= TS_RESTORE_SIGMASK;
-	WARN_ON(!test_bit(TIF_SIGPENDING, &ti->flags));
-}
-static inline void clear_restore_sigmask(void)
-{
-	current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
-}
-static inline bool test_restore_sigmask(void)
-{
-	return current_thread_info()->status & TS_RESTORE_SIGMASK;
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	if (!(ti->status & TS_RESTORE_SIGMASK))
-		return false;
-	ti->status &= ~TS_RESTORE_SIGMASK;
-	return true;
-}
-#endif	/* !__ASSEMBLY__ */
-
 #endif /* _ASM_IA64_THREAD_INFO_H */
diff --git a/arch/microblaze/include/asm/thread_info.h b/arch/microblaze/include/asm/thread_info.h
index 383f387b4eee..e7e8954e9815 100644
--- a/arch/microblaze/include/asm/thread_info.h
+++ b/arch/microblaze/include/asm/thread_info.h
@@ -148,33 +148,6 @@ static inline struct thread_info *current_thread_info(void)
  */
 /* FPU was used by this task this quantum (SMP) */
 #define TS_USEDFPU		0x0001
-#define TS_RESTORE_SIGMASK	0x0002
-
-#ifndef __ASSEMBLY__
-#define HAVE_SET_RESTORE_SIGMASK 1
-static inline void set_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	ti->status |= TS_RESTORE_SIGMASK;
-	WARN_ON(!test_bit(TIF_SIGPENDING, (unsigned long *)&ti->flags));
-}
-static inline void clear_restore_sigmask(void)
-{
-	current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
-}
-static inline bool test_restore_sigmask(void)
-{
-	return current_thread_info()->status & TS_RESTORE_SIGMASK;
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	if (!(ti->status & TS_RESTORE_SIGMASK))
-		return false;
-	ti->status &= ~TS_RESTORE_SIGMASK;
-	return true;
-}
-#endif
 
 #endif /* __KERNEL__ */
 #endif /* _ASM_MICROBLAZE_THREAD_INFO_H */
diff --git a/arch/powerpc/include/asm/thread_info.h b/arch/powerpc/include/asm/thread_info.h
index 8febc3f66d53..cfc35195f95e 100644
--- a/arch/powerpc/include/asm/thread_info.h
+++ b/arch/powerpc/include/asm/thread_info.h
@@ -134,40 +134,15 @@ static inline struct thread_info *current_thread_info(void)
 /* Don't move TLF_NAPPING without adjusting the code in entry_32.S */
 #define TLF_NAPPING		0	/* idle thread enabled NAP mode */
 #define TLF_SLEEPING		1	/* suspend code enabled SLEEP mode */
-#define TLF_RESTORE_SIGMASK	2	/* Restore signal mask in do_signal */
 #define TLF_LAZY_MMU		3	/* tlb_batch is active */
 #define TLF_RUNLATCH		4	/* Is the runlatch enabled? */
 
 #define _TLF_NAPPING		(1 << TLF_NAPPING)
 #define _TLF_SLEEPING		(1 << TLF_SLEEPING)
-#define _TLF_RESTORE_SIGMASK	(1 << TLF_RESTORE_SIGMASK)
 #define _TLF_LAZY_MMU		(1 << TLF_LAZY_MMU)
 #define _TLF_RUNLATCH		(1 << TLF_RUNLATCH)
 
 #ifndef __ASSEMBLY__
-#define HAVE_SET_RESTORE_SIGMASK	1
-static inline void set_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	ti->local_flags |= _TLF_RESTORE_SIGMASK;
-	WARN_ON(!test_bit(TIF_SIGPENDING, &ti->flags));
-}
-static inline void clear_restore_sigmask(void)
-{
-	current_thread_info()->local_flags &= ~_TLF_RESTORE_SIGMASK;
-}
-static inline bool test_restore_sigmask(void)
-{
-	return current_thread_info()->local_flags & _TLF_RESTORE_SIGMASK;
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	if (!(ti->local_flags & _TLF_RESTORE_SIGMASK))
-		return false;
-	ti->local_flags &= ~_TLF_RESTORE_SIGMASK;
-	return true;
-}
 
 static inline bool test_thread_local_flags(unsigned int flags)
 {
diff --git a/arch/sh/include/asm/thread_info.h b/arch/sh/include/asm/thread_info.h
index 2afa321157be..6c65dcd470ab 100644
--- a/arch/sh/include/asm/thread_info.h
+++ b/arch/sh/include/asm/thread_info.h
@@ -151,19 +151,10 @@ extern void init_thread_xstate(void);
  * ever touches our thread-synchronous status, so we don't
  * have to worry about atomic accesses.
  */
-#define TS_RESTORE_SIGMASK	0x0001	/* restore signal mask in do_signal() */
 #define TS_USEDFPU		0x0002	/* FPU used by this task this quantum */
 
 #ifndef __ASSEMBLY__
 
-#define HAVE_SET_RESTORE_SIGMASK	1
-static inline void set_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	ti->status |= TS_RESTORE_SIGMASK;
-	WARN_ON(!test_bit(TIF_SIGPENDING, (unsigned long *)&ti->flags));
-}
-
 #define TI_FLAG_FAULT_CODE_SHIFT	24
 
 /*
@@ -182,23 +173,6 @@ static inline unsigned int get_thread_fault_code(void)
 	return ti->flags >> TI_FLAG_FAULT_CODE_SHIFT;
 }
 
-static inline void clear_restore_sigmask(void)
-{
-	current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
-}
-static inline bool test_restore_sigmask(void)
-{
-	return current_thread_info()->status & TS_RESTORE_SIGMASK;
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	if (!(ti->status & TS_RESTORE_SIGMASK))
-		return false;
-	ti->status &= ~TS_RESTORE_SIGMASK;
-	return true;
-}
-
 #endif	/* !__ASSEMBLY__ */
 
 #endif /* __KERNEL__ */
diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
index bde59825d06c..3d7b925f6516 100644
--- a/arch/sparc/include/asm/thread_info_64.h
+++ b/arch/sparc/include/asm/thread_info_64.h
@@ -222,32 +222,8 @@ register struct thread_info *current_thread_info_reg asm("g6");
  *
  * Note that there are only 8 bits available.
  */
-#define TS_RESTORE_SIGMASK	0x0001	/* restore signal mask in do_signal() */
 
 #ifndef __ASSEMBLY__
-#define HAVE_SET_RESTORE_SIGMASK	1
-static inline void set_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	ti->status |= TS_RESTORE_SIGMASK;
-	WARN_ON(!test_bit(TIF_SIGPENDING, &ti->flags));
-}
-static inline void clear_restore_sigmask(void)
-{
-	current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
-}
-static inline bool test_restore_sigmask(void)
-{
-	return current_thread_info()->status & TS_RESTORE_SIGMASK;
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	if (!(ti->status & TS_RESTORE_SIGMASK))
-		return false;
-	ti->status &= ~TS_RESTORE_SIGMASK;
-	return true;
-}
 
 #define thread32_stack_is_64bit(__SP) (((__SP) & 0x1) != 0)
 #define test_thread_64bit_stack(__SP) \
diff --git a/arch/tile/include/asm/thread_info.h b/arch/tile/include/asm/thread_info.h
index c1467ac59ce6..b7659b8f1117 100644
--- a/arch/tile/include/asm/thread_info.h
+++ b/arch/tile/include/asm/thread_info.h
@@ -166,32 +166,5 @@ extern void _cpu_idle(void);
 #ifdef __tilegx__
 #define TS_COMPAT		0x0001	/* 32-bit compatibility mode */
 #endif
-#define TS_RESTORE_SIGMASK	0x0008	/* restore signal mask in do_signal */
-
-#ifndef __ASSEMBLY__
-#define HAVE_SET_RESTORE_SIGMASK	1
-static inline void set_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	ti->status |= TS_RESTORE_SIGMASK;
-	WARN_ON(!test_bit(TIF_SIGPENDING, &ti->flags));
-}
-static inline void clear_restore_sigmask(void)
-{
-	current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
-}
-static inline bool test_restore_sigmask(void)
-{
-	return current_thread_info()->status & TS_RESTORE_SIGMASK;
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	if (!(ti->status & TS_RESTORE_SIGMASK))
-		return false;
-	ti->status &= ~TS_RESTORE_SIGMASK;
-	return true;
-}
-#endif	/* !__ASSEMBLY__ */
 
 #endif /* _ASM_TILE_THREAD_INFO_H */
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index 89bff044a6f5..b45ffdda3549 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -219,32 +219,8 @@ static inline unsigned long current_stack_pointer(void)
  * have to worry about atomic accesses.
  */
 #define TS_COMPAT		0x0002	/* 32bit syscall active (64BIT)*/
-#define TS_RESTORE_SIGMASK	0x0008	/* restore signal mask in do_signal() */
 
 #ifndef __ASSEMBLY__
-#define HAVE_SET_RESTORE_SIGMASK	1
-static inline void set_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	ti->status |= TS_RESTORE_SIGMASK;
-	WARN_ON(!test_bit(TIF_SIGPENDING, (unsigned long *)&ti->flags));
-}
-static inline void clear_restore_sigmask(void)
-{
-	current_thread_info()->status &= ~TS_RESTORE_SIGMASK;
-}
-static inline bool test_restore_sigmask(void)
-{
-	return current_thread_info()->status & TS_RESTORE_SIGMASK;
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	struct thread_info *ti = current_thread_info();
-	if (!(ti->status & TS_RESTORE_SIGMASK))
-		return false;
-	ti->status &= ~TS_RESTORE_SIGMASK;
-	return true;
-}
 
 static inline bool in_ia32_syscall(void)
 {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 26869dba21f1..569df670407a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1545,6 +1545,9 @@ struct task_struct {
 	/* unserialized, strictly 'current' */
 	unsigned in_execve:1; /* bit to tell LSMs we're in execve */
 	unsigned in_iowait:1;
+#if !defined(TIF_RESTORE_SIGMASK)
+	unsigned restore_sigmask:1;
+#endif
 #ifdef CONFIG_MEMCG
 	unsigned memcg_may_oom:1;
 #ifndef CONFIG_SLOB
@@ -2664,6 +2667,66 @@ extern void sigqueue_free(struct sigqueue *);
 extern int send_sigqueue(struct sigqueue *,  struct task_struct *, int group);
 extern int do_sigaction(int, struct k_sigaction *, struct k_sigaction *);
 
+#ifdef TIF_RESTORE_SIGMASK
+/*
+ * Legacy restore_sigmask accessors.  These are inefficient on
+ * SMP architectures because they require atomic operations.
+ */
+
+/**
+ * set_restore_sigmask() - make sure saved_sigmask processing gets done
+ *
+ * This sets TIF_RESTORE_SIGMASK and ensures that the arch signal code
+ * will run before returning to user mode, to process the flag.  For
+ * all callers, TIF_SIGPENDING is already set or it's no harm to set
+ * it.  TIF_RESTORE_SIGMASK need not be in the set of bits that the
+ * arch code will notice on return to user mode, in case those bits
+ * are scarce.  We set TIF_SIGPENDING here to ensure that the arch
+ * signal code always gets run when TIF_RESTORE_SIGMASK is set.
+ */
+static inline void set_restore_sigmask(void)
+{
+	set_thread_flag(TIF_RESTORE_SIGMASK);
+	WARN_ON(!test_thread_flag(TIF_SIGPENDING));
+}
+static inline void clear_restore_sigmask(void)
+{
+	clear_thread_flag(TIF_RESTORE_SIGMASK);
+}
+static inline bool test_restore_sigmask(void)
+{
+	return test_thread_flag(TIF_RESTORE_SIGMASK);
+}
+static inline bool test_and_clear_restore_sigmask(void)
+{
+	return test_and_clear_thread_flag(TIF_RESTORE_SIGMASK);
+}
+
+#else	/* TIF_RESTORE_SIGMASK */
+
+/* Higher-quality implementation, used if TIF_RESTORE_SIGMASK doesn't exist. */
+static inline void set_restore_sigmask(void)
+{
+	current->restore_sigmask = true;
+	WARN_ON(!test_thread_flag(TIF_SIGPENDING));
+}
+static inline void clear_restore_sigmask(void)
+{
+	current->restore_sigmask = false;
+}
+static inline bool test_restore_sigmask(void)
+{
+	return current->restore_sigmask;
+}
+static inline bool test_and_clear_restore_sigmask(void)
+{
+	if (!current->restore_sigmask)
+		return false;
+	current->restore_sigmask = false;
+	return true;
+}
+#endif
+
 static inline void restore_saved_sigmask(void)
 {
 	if (test_and_clear_restore_sigmask())
diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index b4c2a485b28a..352b1542f5cc 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -105,47 +105,6 @@ static inline int test_ti_thread_flag(struct thread_info *ti, int flag)
 
 #define tif_need_resched() test_thread_flag(TIF_NEED_RESCHED)
 
-#if defined TIF_RESTORE_SIGMASK && !defined HAVE_SET_RESTORE_SIGMASK
-/*
- * An arch can define its own version of set_restore_sigmask() to get the
- * job done however works, with or without TIF_RESTORE_SIGMASK.
- */
-#define HAVE_SET_RESTORE_SIGMASK	1
-
-/**
- * set_restore_sigmask() - make sure saved_sigmask processing gets done
- *
- * This sets TIF_RESTORE_SIGMASK and ensures that the arch signal code
- * will run before returning to user mode, to process the flag.  For
- * all callers, TIF_SIGPENDING is already set or it's no harm to set
- * it.  TIF_RESTORE_SIGMASK need not be in the set of bits that the
- * arch code will notice on return to user mode, in case those bits
- * are scarce.  We set TIF_SIGPENDING here to ensure that the arch
- * signal code always gets run when TIF_RESTORE_SIGMASK is set.
- */
-static inline void set_restore_sigmask(void)
-{
-	set_thread_flag(TIF_RESTORE_SIGMASK);
-	WARN_ON(!test_thread_flag(TIF_SIGPENDING));
-}
-static inline void clear_restore_sigmask(void)
-{
-	clear_thread_flag(TIF_RESTORE_SIGMASK);
-}
-static inline bool test_restore_sigmask(void)
-{
-	return test_thread_flag(TIF_RESTORE_SIGMASK);
-}
-static inline bool test_and_clear_restore_sigmask(void)
-{
-	return test_and_clear_thread_flag(TIF_RESTORE_SIGMASK);
-}
-#endif	/* TIF_RESTORE_SIGMASK && !HAVE_SET_RESTORE_SIGMASK */
-
-#ifndef HAVE_SET_RESTORE_SIGMASK
-#error "no set_restore_sigmask() provided and default one won't work"
-#endif
-
 #endif	/* __KERNEL__ */
 
 #endif /* _LINUX_THREAD_INFO_H */
-- 
2.7.4

