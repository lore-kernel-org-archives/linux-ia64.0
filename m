From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 27 Jan 2016 10:55:23 +0000
Subject: [PATCH v2 resend 6/6] arm64: switch to relative exception tables
Message-Id: <1453892123-17973-7-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453892123-17973-1-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1453892123-17973-1-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, hpa@zytor.com, heiko.carstens@de.ibm.com, rth@twiddle.net, tony.luck@intel.com, will.deacon@arm.com
Cc: deller@gmx.de, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Instead of using absolute addresses for both the exception location
and the fixup, use offsets relative to the exception table entry values.
Not only does this cut the size of the exception table in half, it is
also a prerequisite for KASLR, since absolute exception table entries
are subject to dynamic relocation, which is incompatible with the sorting
of the exception table that occurs at build time.

This patch also introduces the _ASM_EXTABLE preprocessor macro (which
exists on x86 as well) and its _asm_extable assembly counterpart, as
shorthands to emit exception table entries.

Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/include/asm/assembler.h      | 15 +++++++---
 arch/arm64/include/asm/futex.h          | 12 +++-----
 arch/arm64/include/asm/uaccess.h        | 30 +++++++++++---------
 arch/arm64/include/asm/word-at-a-time.h |  7 ++---
 arch/arm64/kernel/armv8_deprecated.c    |  7 ++---
 arch/arm64/mm/extable.c                 |  2 +-
 scripts/sortextable.c                   |  2 +-
 7 files changed, 38 insertions(+), 37 deletions(-)

diff --git a/arch/arm64/include/asm/assembler.h b/arch/arm64/include/asm/assembler.h
index bb7b72734c24..d8bfcc1ce923 100644
--- a/arch/arm64/include/asm/assembler.h
+++ b/arch/arm64/include/asm/assembler.h
@@ -94,12 +94,19 @@
 	dmb	\opt
 	.endm
 
+/*
+ * Emit an entry into the exception table
+ */
+	.macro		_asm_extable, from, to
+	.pushsection	__ex_table, "a"
+	.align		3
+	.long		(\from - .), (\to - .)
+	.popsection
+	.endm
+
 #define USER(l, x...)				\
 9999:	x;					\
-	.section __ex_table,"a";		\
-	.align	3;				\
-	.quad	9999b,l;			\
-	.previous
+	_asm_extable	9999b, l
 
 /*
  * Register aliases.
diff --git a/arch/arm64/include/asm/futex.h b/arch/arm64/include/asm/futex.h
index 007a69fc4f40..1ab15a3b5a0e 100644
--- a/arch/arm64/include/asm/futex.h
+++ b/arch/arm64/include/asm/futex.h
@@ -42,10 +42,8 @@
 "4:	mov	%w0, %w5\n"						\
 "	b	3b\n"							\
 "	.popsection\n"							\
-"	.pushsection __ex_table,\"a\"\n"				\
-"	.align	3\n"							\
-"	.quad	1b, 4b, 2b, 4b\n"					\
-"	.popsection\n"							\
+	_ASM_EXTABLE(1b, 4b)						\
+	_ASM_EXTABLE(2b, 4b)						\
 	ALTERNATIVE("nop", SET_PSTATE_PAN(1), ARM64_HAS_PAN,		\
 		    CONFIG_ARM64_PAN)					\
 	: "=&r" (ret), "=&r" (oldval), "+Q" (*uaddr), "=&r" (tmp)	\
@@ -133,10 +131,8 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 "4:	mov	%w0, %w6\n"
 "	b	3b\n"
 "	.popsection\n"
-"	.pushsection __ex_table,\"a\"\n"
-"	.align	3\n"
-"	.quad	1b, 4b, 2b, 4b\n"
-"	.popsection\n"
+	_ASM_EXTABLE(1b, 4b)
+	_ASM_EXTABLE(2b, 4b)
 	: "+r" (ret), "=&r" (val), "+Q" (*uaddr), "=&r" (tmp)
 	: "r" (oldval), "r" (newval), "Ir" (-EFAULT)
 	: "memory");
diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index b2ede967fe7d..dc11577fab7e 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -36,11 +36,11 @@
 #define VERIFY_WRITE 1
 
 /*
- * The exception table consists of pairs of addresses: the first is the
- * address of an instruction that is allowed to fault, and the second is
- * the address at which the program should continue.  No registers are
- * modified, so it is entirely up to the continuation code to figure out
- * what to do.
+ * The exception table consists of pairs of relative offsets: the first
+ * is the relative offset to an instruction that is allowed to fault,
+ * and the second is the relative offset at which the program should
+ * continue. No registers are modified, so it is entirely up to the
+ * continuation code to figure out what to do.
  *
  * All the routines below use bits of fixup code that are out of line
  * with the main instruction path.  This means when everything is well,
@@ -50,9 +50,11 @@
 
 struct exception_table_entry
 {
-	unsigned long insn, fixup;
+	int insn, fixup;
 };
 
+#define ARCH_HAS_RELATIVE_EXTABLE
+
 extern int fixup_exception(struct pt_regs *regs);
 
 #define KERNEL_DS	(-1UL)
@@ -105,6 +107,12 @@ static inline void set_fs(mm_segment_t fs)
 #define access_ok(type, addr, size)	__range_ok(addr, size)
 #define user_addr_max			get_fs
 
+#define _ASM_EXTABLE(from, to)						\
+	"	.pushsection	__ex_table, \"a\"\n"			\
+	"	.align		3\n"					\
+	"	.long		(" #from " - .), (" #to " - .)\n"	\
+	"	.popsection\n"
+
 /*
  * The "__xxx" versions of the user access functions do not verify the address
  * space - it must have been done previously with a separate "access_ok()"
@@ -123,10 +131,7 @@ static inline void set_fs(mm_segment_t fs)
 	"	mov	%1, #0\n"					\
 	"	b	2b\n"						\
 	"	.previous\n"						\
-	"	.section __ex_table,\"a\"\n"				\
-	"	.align	3\n"						\
-	"	.quad	1b, 3b\n"					\
-	"	.previous"						\
+	_ASM_EXTABLE(1b, 3b)						\
 	: "+r" (err), "=&r" (x)						\
 	: "r" (addr), "i" (-EFAULT))
 
@@ -190,10 +195,7 @@ do {									\
 	"3:	mov	%w0, %3\n"					\
 	"	b	2b\n"						\
 	"	.previous\n"						\
-	"	.section __ex_table,\"a\"\n"				\
-	"	.align	3\n"						\
-	"	.quad	1b, 3b\n"					\
-	"	.previous"						\
+	_ASM_EXTABLE(1b, 3b)						\
 	: "+r" (err)							\
 	: "r" (x), "r" (addr), "i" (-EFAULT))
 
diff --git a/arch/arm64/include/asm/word-at-a-time.h b/arch/arm64/include/asm/word-at-a-time.h
index aab5bf09e9d9..2b79b8a89457 100644
--- a/arch/arm64/include/asm/word-at-a-time.h
+++ b/arch/arm64/include/asm/word-at-a-time.h
@@ -16,6 +16,8 @@
 #ifndef __ASM_WORD_AT_A_TIME_H
 #define __ASM_WORD_AT_A_TIME_H
 
+#include <asm/uaccess.h>
+
 #ifndef __AARCH64EB__
 
 #include <linux/kernel.h>
@@ -81,10 +83,7 @@ static inline unsigned long load_unaligned_zeropad(const void *addr)
 #endif
 	"	b	2b\n"
 	"	.popsection\n"
-	"	.pushsection __ex_table,\"a\"\n"
-	"	.align	3\n"
-	"	.quad	1b, 3b\n"
-	"	.popsection"
+	_ASM_EXTABLE(1b, 3b)
 	: "=&r" (ret), "=&r" (offset)
 	: "r" (addr), "Q" (*(unsigned long *)addr));
 
diff --git a/arch/arm64/kernel/armv8_deprecated.c b/arch/arm64/kernel/armv8_deprecated.c
index 3e01207917b1..c37202c0c838 100644
--- a/arch/arm64/kernel/armv8_deprecated.c
+++ b/arch/arm64/kernel/armv8_deprecated.c
@@ -297,11 +297,8 @@ static void __init register_insn_emulation_sysctl(struct ctl_table *table)
 	"4:	mov		%w0, %w5\n"			\
 	"	b		3b\n"				\
 	"	.popsection"					\
-	"	.pushsection	 __ex_table,\"a\"\n"		\
-	"	.align		3\n"				\
-	"	.quad		0b, 4b\n"			\
-	"	.quad		1b, 4b\n"			\
-	"	.popsection\n"					\
+	_ASM_EXTABLE(0b, 4b)					\
+	_ASM_EXTABLE(1b, 4b)					\
 	ALTERNATIVE("nop", SET_PSTATE_PAN(1), ARM64_HAS_PAN,	\
 		CONFIG_ARM64_PAN)				\
 	: "=&r" (res), "+r" (data), "=&r" (temp)		\
diff --git a/arch/arm64/mm/extable.c b/arch/arm64/mm/extable.c
index 79444279ba8c..81acd4706878 100644
--- a/arch/arm64/mm/extable.c
+++ b/arch/arm64/mm/extable.c
@@ -11,7 +11,7 @@ int fixup_exception(struct pt_regs *regs)
 
 	fixup = search_exception_tables(instruction_pointer(regs));
 	if (fixup)
-		regs->pc = fixup->fixup;
+		regs->pc = (unsigned long)&fixup->fixup + fixup->fixup;
 
 	return fixup != NULL;
 }
diff --git a/scripts/sortextable.c b/scripts/sortextable.c
index c2423d913b46..af247c70fb66 100644
--- a/scripts/sortextable.c
+++ b/scripts/sortextable.c
@@ -282,12 +282,12 @@ do_file(char const *const fname)
 	case EM_386:
 	case EM_X86_64:
 	case EM_S390:
+	case EM_AARCH64:
 		custom_sort = sort_relative_table;
 		break;
 	case EM_ARCOMPACT:
 	case EM_ARCV2:
 	case EM_ARM:
-	case EM_AARCH64:
 	case EM_MICROBLAZE:
 	case EM_MIPS:
 	case EM_XTENSA:
-- 
2.5.0

