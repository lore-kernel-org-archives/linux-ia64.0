From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Mon, 10 Dec 2018 04:31:09 +0000
Subject: [PATCH v5 22/25] syscall_get_arch: add "struct task_struct *" argument
Message-Id: <20181210043109.GV6131@altlinux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181210042352.GA6092@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@kernel.org>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Michael Ellerman <mpe@ellerman.id.au>, Eric Paris <eparis@redhat.com>, Paul Moore <paul@paul-moore.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Salter <msalter@redhat.com>, Aurelien Jacquiot <jacquiot.aurelien@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m6>
Cc: Elvira Khabirova <lineprinter@altlinux.org>, Eugene Syromyatnikov <esyr@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org

This argument is required to extend the generic ptrace API with
PTRACE_GET_SYSCALL_INFO request: syscall_get_arch() is going
to be called from ptrace_request() along with syscall_get_nr(),
syscall_get_arguments(), syscall_get_error(), and
syscall_get_return_value() functions with a tracee as their argument.

Reverts: 5e937a9ae913 ("syscall_get_arch: remove useless function arguments")
Reverts: 1002d94d3076 ("syscall.h: fix doc text for syscall_get_arch()")
Reviewed-by: Andy Lutomirski <luto@kernel.org> # for x86
Reviewed-by: Palmer Dabbelt <palmer@sifive.com>
Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts
Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
Cc: Eric Paris <eparis@redhat.com>
Cc: Paul Moore <paul@paul-moore.com>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <jacquiot.aurelien@gmail.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Richard Kuo <rkuo@codeaurora.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Greentime Hu <green.hu@gmail.com>
Cc: Vincent Chen <deanbo422@gmail.com>
Cc: Ley Foon Tan <lftan@altera.com>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>
Cc: Stafford Horne <shorne@gmail.com>
Cc: James E.J. Bottomley <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Albert Ou <aou@eecs.berkeley.edu>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Rich Felker <dalias@libc.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Guan Xuetao <gxt@pku.edu.cn>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Chris Zankel <chris@zankel.net>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Kees Cook <keescook@chromium.org>
Cc: Will Drewry <wad@chromium.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Elvira Khabirova <lineprinter@altlinux.org>
Cc: Eugene Syromyatnikov <esyr@redhat.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: James Hogan <jhogan@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: x86@kernel.org
Cc: linux-alpha@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-c6x-dev@linux-c6x.org
Cc: uclinux-h8-devel@lists.sourceforge.jp
Cc: linux-hexagon@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-mips@vger.kernel.org
Cc: nios2-dev@lists.rocketboards.org
Cc: openrisc@lists.librecores.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-riscv@lists.infradead.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-um@lists.infradead.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-arch@vger.kernel.org
Cc: linux-audit@redhat.com
Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---

Notes:
    v5: fixed asm-generic docs by reverting 1002d94d3076, added Cc
    v2: cleaned up mips part, added Reviewed-by

 arch/alpha/include/asm/syscall.h      |  2 +-
 arch/arc/include/asm/syscall.h        |  2 +-
 arch/arm/include/asm/syscall.h        |  2 +-
 arch/arm64/include/asm/syscall.h      |  4 ++--
 arch/c6x/include/asm/syscall.h        |  2 +-
 arch/csky/include/asm/syscall.h       |  2 +-
 arch/h8300/include/asm/syscall.h      |  2 +-
 arch/hexagon/include/asm/syscall.h    |  2 +-
 arch/ia64/include/asm/syscall.h       |  2 +-
 arch/m68k/include/asm/syscall.h       |  2 +-
 arch/microblaze/include/asm/syscall.h |  2 +-
 arch/mips/include/asm/syscall.h       |  6 +++---
 arch/mips/kernel/ptrace.c             |  2 +-
 arch/nds32/include/asm/syscall.h      |  2 +-
 arch/nios2/include/asm/syscall.h      |  2 +-
 arch/openrisc/include/asm/syscall.h   |  2 +-
 arch/parisc/include/asm/syscall.h     |  4 ++--
 arch/powerpc/include/asm/syscall.h    | 10 ++++++++--
 arch/riscv/include/asm/syscall.h      |  2 +-
 arch/s390/include/asm/syscall.h       |  4 ++--
 arch/sh/include/asm/syscall_32.h      |  2 +-
 arch/sh/include/asm/syscall_64.h      |  2 +-
 arch/sparc/include/asm/syscall.h      |  5 +++--
 arch/unicore32/include/asm/syscall.h  |  2 +-
 arch/x86/include/asm/syscall.h        |  8 +++++---
 arch/x86/um/asm/syscall.h             |  2 +-
 arch/xtensa/include/asm/syscall.h     |  2 +-
 include/asm-generic/syscall.h         |  5 +++--
 kernel/auditsc.c                      |  4 ++--
 kernel/seccomp.c                      |  4 ++--
 30 files changed, 52 insertions(+), 42 deletions(-)

diff --git a/arch/alpha/include/asm/syscall.h b/arch/alpha/include/asm/syscall.h
index 437758bdc49f..288779aa9847 100644
--- a/arch/alpha/include/asm/syscall.h
+++ b/arch/alpha/include/asm/syscall.h
@@ -31,7 +31,7 @@ syscall_get_return_value(struct task_struct *task, struct pt_regs *regs)
 }
 
 static inline int
-syscall_get_arch(void)
+syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_ALPHA;
 }
diff --git a/arch/arc/include/asm/syscall.h b/arch/arc/include/asm/syscall.h
index c7fc4c0c3bcb..caf2697ef5b7 100644
--- a/arch/arc/include/asm/syscall.h
+++ b/arch/arc/include/asm/syscall.h
@@ -70,7 +70,7 @@ syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
 }
 
 static inline int
-syscall_get_arch(void)
+syscall_get_arch(struct task_struct *task)
 {
 	return IS_ENABLED(CONFIG_ISA_ARCOMPACT)
 		? (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)
diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
index 06dea6bce293..3940ceac0bdc 100644
--- a/arch/arm/include/asm/syscall.h
+++ b/arch/arm/include/asm/syscall.h
@@ -104,7 +104,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->ARM_r0 + i, args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	/* ARM tasks don't change audit architectures on the fly. */
 	return AUDIT_ARCH_ARM;
diff --git a/arch/arm64/include/asm/syscall.h b/arch/arm64/include/asm/syscall.h
index ad8be16a39c9..1870df03f774 100644
--- a/arch/arm64/include/asm/syscall.h
+++ b/arch/arm64/include/asm/syscall.h
@@ -117,9 +117,9 @@ static inline void syscall_set_arguments(struct task_struct *task,
  * We don't care about endianness (__AUDIT_ARCH_LE bit) here because
  * AArch64 has the same system calls both on little- and big- endian.
  */
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
-	if (is_compat_task())
+	if (is_compat_thread(task_thread_info(task)))
 		return AUDIT_ARCH_ARM;
 
 	return AUDIT_ARCH_AARCH64;
diff --git a/arch/c6x/include/asm/syscall.h b/arch/c6x/include/asm/syscall.h
index 39dbd1ef994c..595057191c9c 100644
--- a/arch/c6x/include/asm/syscall.h
+++ b/arch/c6x/include/asm/syscall.h
@@ -121,7 +121,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	}
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	return IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)
 		? AUDIT_ARCH_C6XBE : AUDIT_ARCH_C6X;
diff --git a/arch/csky/include/asm/syscall.h b/arch/csky/include/asm/syscall.h
index d637445737b7..150ffb894fa2 100644
--- a/arch/csky/include/asm/syscall.h
+++ b/arch/csky/include/asm/syscall.h
@@ -70,7 +70,7 @@ syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 }
 
 static inline int
-syscall_get_arch(void)
+syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_CSKY;
 }
diff --git a/arch/h8300/include/asm/syscall.h b/arch/h8300/include/asm/syscall.h
index 5c881ffe962a..9cb1f14ddd77 100644
--- a/arch/h8300/include/asm/syscall.h
+++ b/arch/h8300/include/asm/syscall.h
@@ -61,7 +61,7 @@ syscall_get_return_value(struct task_struct *task, struct pt_regs *regs)
 }
 
 static inline int
-syscall_get_arch(void)
+syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_H8300;
 }
diff --git a/arch/hexagon/include/asm/syscall.h b/arch/hexagon/include/asm/syscall.h
index 09c7b2884475..c6bc69513be8 100644
--- a/arch/hexagon/include/asm/syscall.h
+++ b/arch/hexagon/include/asm/syscall.h
@@ -58,7 +58,7 @@ static inline long syscall_get_return_value(struct task_struct *task,
 	return regs->r00;
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_HEXAGON;
 }
diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index 1d0b875fec44..47ab33f5448a 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -81,7 +81,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	ia64_syscall_get_set_arguments(task, regs, i, n, args, 1);
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_IA64;
 }
diff --git a/arch/m68k/include/asm/syscall.h b/arch/m68k/include/asm/syscall.h
index 75a24cf90620..69d2b6eb97fd 100644
--- a/arch/m68k/include/asm/syscall.h
+++ b/arch/m68k/include/asm/syscall.h
@@ -31,7 +31,7 @@ syscall_get_return_value(struct task_struct *task, struct pt_regs *regs)
 }
 
 static inline int
-syscall_get_arch(void)
+syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_M68K;
 }
diff --git a/arch/microblaze/include/asm/syscall.h b/arch/microblaze/include/asm/syscall.h
index 220decd605a4..77a86fafa974 100644
--- a/arch/microblaze/include/asm/syscall.h
+++ b/arch/microblaze/include/asm/syscall.h
@@ -101,7 +101,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 asmlinkage unsigned long do_syscall_trace_enter(struct pt_regs *regs);
 asmlinkage void do_syscall_trace_leave(struct pt_regs *regs);
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_MICROBLAZE;
 }
diff --git a/arch/mips/include/asm/syscall.h b/arch/mips/include/asm/syscall.h
index 04ab927ff47d..466957d0474b 100644
--- a/arch/mips/include/asm/syscall.h
+++ b/arch/mips/include/asm/syscall.h
@@ -146,14 +146,14 @@ extern const unsigned long sys_call_table[];
 extern const unsigned long sys32_call_table[];
 extern const unsigned long sysn32_call_table[];
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	int arch = AUDIT_ARCH_MIPS;
 #ifdef CONFIG_64BIT
-	if (!test_thread_flag(TIF_32BIT_REGS)) {
+	if (!test_tsk_thread_flag(task, TIF_32BIT_REGS)) {
 		arch |= __AUDIT_ARCH_64BIT;
 		/* N32 sets only TIF_32BIT_ADDR */
-		if (test_thread_flag(TIF_32BIT_ADDR))
+		if (test_tsk_thread_flag(task, TIF_32BIT_ADDR))
 			arch |= __AUDIT_ARCH_CONVENTION_MIPS64_N32;
 	}
 #endif
diff --git a/arch/mips/kernel/ptrace.c b/arch/mips/kernel/ptrace.c
index e5ba56c01ee0..e112c525c3a7 100644
--- a/arch/mips/kernel/ptrace.c
+++ b/arch/mips/kernel/ptrace.c
@@ -1272,7 +1272,7 @@ asmlinkage long syscall_trace_enter(struct pt_regs *regs, long syscall)
 		unsigned long args[6];
 
 		sd.nr = syscall;
-		sd.arch = syscall_get_arch();
+		sd.arch = syscall_get_arch(current);
 		syscall_get_arguments(current, regs, 0, 6, args);
 		for (i = 0; i < 6; i++)
 			sd.args[i] = args[i];
diff --git a/arch/nds32/include/asm/syscall.h b/arch/nds32/include/asm/syscall.h
index 569149ca25da..e109acd225e6 100644
--- a/arch/nds32/include/asm/syscall.h
+++ b/arch/nds32/include/asm/syscall.h
@@ -187,7 +187,7 @@ void syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 	memcpy(&regs->uregs[0] + i, args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	return IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)
 		? AUDIT_ARCH_NDS32BE : AUDIT_ARCH_NDS32;
diff --git a/arch/nios2/include/asm/syscall.h b/arch/nios2/include/asm/syscall.h
index cf35e210fc4d..f0f6ae208e78 100644
--- a/arch/nios2/include/asm/syscall.h
+++ b/arch/nios2/include/asm/syscall.h
@@ -136,7 +136,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	}
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_NIOS2;
 }
diff --git a/arch/openrisc/include/asm/syscall.h b/arch/openrisc/include/asm/syscall.h
index 2db9f1cf0694..46b10c674bd2 100644
--- a/arch/openrisc/include/asm/syscall.h
+++ b/arch/openrisc/include/asm/syscall.h
@@ -72,7 +72,7 @@ syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 	memcpy(&regs->gpr[3 + i], args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_OPENRISC;
 }
diff --git a/arch/parisc/include/asm/syscall.h b/arch/parisc/include/asm/syscall.h
index 477511ff7546..310016e1925d 100644
--- a/arch/parisc/include/asm/syscall.h
+++ b/arch/parisc/include/asm/syscall.h
@@ -69,11 +69,11 @@ static inline void syscall_rollback(struct task_struct *task,
 	/* do nothing */
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	int arch = AUDIT_ARCH_PARISC;
 #ifdef CONFIG_64BIT
-	if (!is_compat_task())
+	if (!__is_compat_task(task))
 		arch = AUDIT_ARCH_PARISC64;
 #endif
 	return arch;
diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/asm/syscall.h
index 1d03e753391d..70f9e538e1b3 100644
--- a/arch/powerpc/include/asm/syscall.h
+++ b/arch/powerpc/include/asm/syscall.h
@@ -110,9 +110,15 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		regs->orig_gpr3 = args[0];
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
-	int arch = is_32bit_task() ? AUDIT_ARCH_PPC : AUDIT_ARCH_PPC64;
+	int arch;
+
+	if (IS_ENABLED(CONFIG_PPC64) && !test_tsk_thread_flag(task, TIF_32BIT))
+		arch = AUDIT_ARCH_PPC64;
+	else
+		arch = AUDIT_ARCH_PPC;
+
 #ifdef __LITTLE_ENDIAN__
 	arch |= __AUDIT_ARCH_LE;
 #endif
diff --git a/arch/riscv/include/asm/syscall.h b/arch/riscv/include/asm/syscall.h
index bba3da6ef157..ca120a36a037 100644
--- a/arch/riscv/include/asm/syscall.h
+++ b/arch/riscv/include/asm/syscall.h
@@ -100,7 +100,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->a1 + i * sizeof(regs->a1), args, n * sizeof(regs->a0));
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 #ifdef CONFIG_64BIT
 	return AUDIT_ARCH_RISCV64;
diff --git a/arch/s390/include/asm/syscall.h b/arch/s390/include/asm/syscall.h
index 96f9a9151fde..5a40ea8b90ea 100644
--- a/arch/s390/include/asm/syscall.h
+++ b/arch/s390/include/asm/syscall.h
@@ -92,10 +92,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		regs->orig_gpr2 = args[0];
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 #ifdef CONFIG_COMPAT
-	if (test_tsk_thread_flag(current, TIF_31BIT))
+	if (test_tsk_thread_flag(task, TIF_31BIT))
 		return AUDIT_ARCH_S390;
 #endif
 	return AUDIT_ARCH_S390X;
diff --git a/arch/sh/include/asm/syscall_32.h b/arch/sh/include/asm/syscall_32.h
index 6e118799831c..08de429eccd4 100644
--- a/arch/sh/include/asm/syscall_32.h
+++ b/arch/sh/include/asm/syscall_32.h
@@ -95,7 +95,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	}
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	int arch = AUDIT_ARCH_SH;
 
diff --git a/arch/sh/include/asm/syscall_64.h b/arch/sh/include/asm/syscall_64.h
index 43882580c7f9..9b62a2404531 100644
--- a/arch/sh/include/asm/syscall_64.h
+++ b/arch/sh/include/asm/syscall_64.h
@@ -63,7 +63,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->regs[2 + i], args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	int arch = AUDIT_ARCH_SH;
 
diff --git a/arch/sparc/include/asm/syscall.h b/arch/sparc/include/asm/syscall.h
index 053989e3f6a6..9ffb367c17fd 100644
--- a/arch/sparc/include/asm/syscall.h
+++ b/arch/sparc/include/asm/syscall.h
@@ -128,10 +128,11 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		regs->u_regs[UREG_I0 + i + j] = args[j];
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 #if defined(CONFIG_SPARC64) && defined(CONFIG_COMPAT)
-	return in_compat_syscall() ? AUDIT_ARCH_SPARC : AUDIT_ARCH_SPARC64;
+	return test_tsk_thread_flag(task, TIF_32BIT)
+		? AUDIT_ARCH_SPARC : AUDIT_ARCH_SPARC64;
 #elif defined(CONFIG_SPARC64)
 	return AUDIT_ARCH_SPARC64;
 #else
diff --git a/arch/unicore32/include/asm/syscall.h b/arch/unicore32/include/asm/syscall.h
index e30d08acf359..db8a59ffbcbc 100644
--- a/arch/unicore32/include/asm/syscall.h
+++ b/arch/unicore32/include/asm/syscall.h
@@ -37,7 +37,7 @@ syscall_get_return_value(struct task_struct *task, struct pt_regs *regs)
 }
 
 static inline int
-syscall_get_arch(void)
+syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_UNICORE;
 }
diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index d653139857af..435f3f09279c 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -107,7 +107,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->bx + i, args, n * sizeof(args[0]));
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_I386;
 }
@@ -236,10 +236,12 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		}
 }
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 	/* x32 tasks should be considered AUDIT_ARCH_X86_64. */
-	return in_ia32_syscall() ? AUDIT_ARCH_I386 : AUDIT_ARCH_X86_64;
+	return (IS_ENABLED(CONFIG_IA32_EMULATION) &&
+		task->thread_info.status & TS_COMPAT)
+		? AUDIT_ARCH_I386 : AUDIT_ARCH_X86_64;
 }
 #endif	/* CONFIG_X86_32 */
 
diff --git a/arch/x86/um/asm/syscall.h b/arch/x86/um/asm/syscall.h
index ef898af102d1..56a2f0913e3c 100644
--- a/arch/x86/um/asm/syscall.h
+++ b/arch/x86/um/asm/syscall.h
@@ -9,7 +9,7 @@ typedef asmlinkage long (*sys_call_ptr_t)(unsigned long, unsigned long,
 					  unsigned long, unsigned long,
 					  unsigned long, unsigned long);
 
-static inline int syscall_get_arch(void)
+static inline int syscall_get_arch(struct task_struct *task)
 {
 #ifdef CONFIG_X86_32
 	return AUDIT_ARCH_I386;
diff --git a/arch/xtensa/include/asm/syscall.h b/arch/xtensa/include/asm/syscall.h
index d529c855a144..008e9da4d126 100644
--- a/arch/xtensa/include/asm/syscall.h
+++ b/arch/xtensa/include/asm/syscall.h
@@ -72,7 +72,7 @@ syscall_get_return_value(struct task_struct *task, struct pt_regs *regs)
 }
 
 static inline int
-syscall_get_arch(void)
+syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_XTENSA;
 }
diff --git a/include/asm-generic/syscall.h b/include/asm-generic/syscall.h
index 0c938a4354f6..e0d060b43321 100644
--- a/include/asm-generic/syscall.h
+++ b/include/asm-generic/syscall.h
@@ -144,14 +144,15 @@ void syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 
 /**
  * syscall_get_arch - return the AUDIT_ARCH for the current system call
+ * @task:	task of interest, must be blocked
  *
  * Returns the AUDIT_ARCH_* based on the system call convention in use.
  *
- * It's only valid to call this when current is stopped on entry to a system
+ * It's only valid to call this when @task is stopped on entry to a system
  * call, due to %TIF_SYSCALL_TRACE, %TIF_SYSCALL_AUDIT, or %TIF_SECCOMP.
  *
  * Architectures which permit CONFIG_HAVE_ARCH_SECCOMP_FILTER must
  * provide an implementation of this.
  */
-int syscall_get_arch(void);
+int syscall_get_arch(struct task_struct *task);
 #endif	/* _ASM_SYSCALL_H */
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index b2d1f043f17f..1319e3e7b16c 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1537,7 +1537,7 @@ void __audit_syscall_entry(int major, unsigned long a1, unsigned long a2,
 			return;
 	}
 
-	context->arch	    = syscall_get_arch();
+	context->arch	    = syscall_get_arch(current);
 	context->major      = major;
 	context->argv[0]    = a1;
 	context->argv[1]    = a2;
@@ -2495,7 +2495,7 @@ void audit_seccomp(unsigned long syscall, long signr, int code)
 		return;
 	audit_log_task(ab);
 	audit_log_format(ab, " sig=%ld arch=%x syscall=%ld compat=%d ip=0x%lx code=0x%x",
-			 signr, syscall_get_arch(), syscall,
+			 signr, syscall_get_arch(current), syscall,
 			 in_compat_syscall(), KSTK_EIP(current), code);
 	audit_log_end(ab);
 }
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index f2ae2324c232..77cb87bd2eae 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -82,7 +82,7 @@ static void populate_seccomp_data(struct seccomp_data *sd)
 	unsigned long args[6];
 
 	sd->nr = syscall_get_nr(task, regs);
-	sd->arch = syscall_get_arch();
+	sd->arch = syscall_get_arch(task);
 	syscall_get_arguments(task, regs, 0, 6, args);
 	sd->args[0] = args[0];
 	sd->args[1] = args[1];
@@ -529,7 +529,7 @@ static void seccomp_init_siginfo(kernel_siginfo_t *info, int syscall, int reason
 	info->si_code = SYS_SECCOMP;
 	info->si_call_addr = (void __user *)KSTK_EIP(current);
 	info->si_errno = reason;
-	info->si_arch = syscall_get_arch();
+	info->si_arch = syscall_get_arch(current);
 	info->si_syscall = syscall;
 }
 
-- 
ldv
