From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:24:44 +0000
Subject: [RFC v3 10/13] jump_label: port __jump_table to linker tables
Message-Id: <1469222687-1600-11-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@linux-foun

Move the __jump_table from the a custom section solution
to a generic solution, this avoiding extra vmlinux.lds.h
customizations.

This also demos the use of the .data (SECTION_DATA) linker
table and of the shared asm call push_section_tbl().

Built-in kernel functionality was tested with CONFIG_STATIC_KEYS_SELFTEST.
Moduler  kernel functionality was tested with CONFIG_TEST_STATIC_KEYS.
Both work as expected.

Since __jump_table sections are also supported per
module this also required expanding module-common.lds.S
to capture and fold all .data.tlb.__jump_table.* onto
the the section __jump_table -- in this case for modules
need to keep a reference in place, given the alternative
is to use DEFINE_LINKTABLE(struct jump_entry, __jump_table)
per module -- and later through macro hacks instantiate
the jump entries per module upon init. This is doable but
we'd loose out on the sorting of the table using the
linker, to sort we'd always still need to expand the
module common linker script. An alternative mechanism
is possible which would make these custom module sections
extensions dynamic without requiring manual changes, this
however is best done later through a separate evolution
once linker tables are in place.

A careful reviewer may note that some architectures use
"\n\t" to separate asm code, while others just use a new line.
Upon review last time it was deemed reasonable to for all
architectures to juse use "\n", this is defined as ASM_CMD_SEP,
and if an architecture needs to override they can do so on their
architecture sections.h prior to including asm-generic/sections.h

v3:

o More elaborate tests performed
o first modular support use case, module tested was
  CONFIG_TEST_STATIC_KEYS (lib/test_static_keys.ko), this
  required us to extend module-common.lds.S
o use generic push_section_tbl_any() for all architectures
o Makes use of ASM_CMD_SEP to enable architectures to override later
  if needed
o guard tables.h inclusion and table definition with __KERNEL__

v2: introduced in this series

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 arch/arm/include/asm/jump_label.h     |  6 ++++--
 arch/arm64/include/asm/jump_label.h   |  6 ++++--
 arch/mips/include/asm/jump_label.h    |  6 ++++--
 arch/powerpc/include/asm/jump_label.h |  8 +++++---
 arch/s390/include/asm/jump_label.h    |  6 ++++--
 arch/sparc/include/asm/jump_label.h   |  6 ++++--
 arch/x86/include/asm/jump_label.h     | 10 ++++++----
 include/asm-generic/vmlinux.lds.h     |  4 ----
 include/linux/jump_label.h            | 10 ++++++----
 kernel/jump_label.c                   | 17 ++++++++++-------
 scripts/module-common.lds.S           |  5 +++++
 tools/objtool/special.c               |  8 +++++++-
 12 files changed, 59 insertions(+), 33 deletions(-)

diff --git a/arch/arm/include/asm/jump_label.h b/arch/arm/include/asm/jump_label.h
index 34f7b6980d21..960135a7b88e 100644
--- a/arch/arm/include/asm/jump_label.h
+++ b/arch/arm/include/asm/jump_label.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_ARM_JUMP_LABEL_H
 #define _ASM_ARM_JUMP_LABEL_H
 
+#include <asm/tables.h>
+
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
@@ -12,7 +14,7 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
 {
 	asm_volatile_goto("1:\n\t"
 		 WASM(nop) "\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		 ".word 1b, %l[l_yes], %c0\n\t"
 		 ".popsection\n\t"
 		 : :  "i" (&((char *)key)[branch]) :  : l_yes);
@@ -26,7 +28,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 {
 	asm_volatile_goto("1:\n\t"
 		 WASM(b) " %l[l_yes]\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		 ".word 1b, %l[l_yes], %c0\n\t"
 		 ".popsection\n\t"
 		 : :  "i" (&((char *)key)[branch]) :  : l_yes);
diff --git a/arch/arm64/include/asm/jump_label.h b/arch/arm64/include/asm/jump_label.h
index 1b5e0e843c3a..aa52cd2607e3 100644
--- a/arch/arm64/include/asm/jump_label.h
+++ b/arch/arm64/include/asm/jump_label.h
@@ -19,6 +19,8 @@
 #ifndef __ASM_JUMP_LABEL_H
 #define __ASM_JUMP_LABEL_H
 
+#include <asm/tables.h>
+
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
@@ -29,7 +31,7 @@
 static __always_inline bool arch_static_branch(struct static_key *key, bool branch)
 {
 	asm goto("1: nop\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		 ".align 3\n\t"
 		 ".quad 1b, %l[l_yes], %c0\n\t"
 		 ".popsection\n\t"
@@ -43,7 +45,7 @@ l_yes:
 static __always_inline bool arch_static_branch_jump(struct static_key *key, bool branch)
 {
 	asm goto("1: b %l[l_yes]\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		 ".align 3\n\t"
 		 ".quad 1b, %l[l_yes], %c0\n\t"
 		 ".popsection\n\t"
diff --git a/arch/mips/include/asm/jump_label.h b/arch/mips/include/asm/jump_label.h
index e77672539e8e..78e70cb98592 100644
--- a/arch/mips/include/asm/jump_label.h
+++ b/arch/mips/include/asm/jump_label.h
@@ -8,6 +8,8 @@
 #ifndef _ASM_MIPS_JUMP_LABEL_H
 #define _ASM_MIPS_JUMP_LABEL_H
 
+#include <asm/tables.h>
+
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
@@ -30,7 +32,7 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
 {
 	asm_volatile_goto("1:\t" NOP_INSN "\n\t"
 		"nop\n\t"
-		".pushsection __jump_table,  \"aw\"\n\t"
+		push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		WORD_INSN " 1b, %l[l_yes], %0\n\t"
 		".popsection\n\t"
 		: :  "i" (&((char *)key)[branch]) : : l_yes);
@@ -44,7 +46,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 {
 	asm_volatile_goto("1:\tj %l[l_yes]\n\t"
 		"nop\n\t"
-		".pushsection __jump_table,  \"aw\"\n\t"
+		push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		WORD_INSN " 1b, %l[l_yes], %0\n\t"
 		".popsection\n\t"
 		: :  "i" (&((char *)key)[branch]) : : l_yes);
diff --git a/arch/powerpc/include/asm/jump_label.h b/arch/powerpc/include/asm/jump_label.h
index 9af103a23975..bf68a8766773 100644
--- a/arch/powerpc/include/asm/jump_label.h
+++ b/arch/powerpc/include/asm/jump_label.h
@@ -10,6 +10,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <asm/tables.h>
+
 #ifndef __ASSEMBLY__
 #include <linux/types.h>
 
@@ -23,7 +25,7 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
 {
 	asm_volatile_goto("1:\n\t"
 		 "nop\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		 JUMP_ENTRY_TYPE "1b, %l[l_yes], %c0\n\t"
 		 ".popsection \n\t"
 		 : :  "i" (&((char *)key)[branch]) : : l_yes);
@@ -37,7 +39,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 {
 	asm_volatile_goto("1:\n\t"
 		 "b %l[l_yes]\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		 JUMP_ENTRY_TYPE "1b, %l[l_yes], %c0\n\t"
 		 ".popsection \n\t"
 		 : :  "i" (&((char *)key)[branch]) : : l_yes);
@@ -62,7 +64,7 @@ struct jump_entry {
 #else
 #define ARCH_STATIC_BRANCH(LABEL, KEY)		\
 1098:	nop;					\
-	.pushsection __jump_table, "aw";	\
+	push_section_tbl_any(SECTION_DATA, __jump_table, aw); \
 	FTR_ENTRY_LONG 1098b, LABEL, KEY;	\
 	.popsection
 #endif
diff --git a/arch/s390/include/asm/jump_label.h b/arch/s390/include/asm/jump_label.h
index 9be198f5ee79..17f02aec4644 100644
--- a/arch/s390/include/asm/jump_label.h
+++ b/arch/s390/include/asm/jump_label.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_S390_JUMP_LABEL_H
 #define _ASM_S390_JUMP_LABEL_H
 
+#include <asm/tables.h>
+
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
@@ -16,7 +18,7 @@
 static __always_inline bool arch_static_branch(struct static_key *key, bool branch)
 {
 	asm_volatile_goto("0:	brcl 0,"__stringify(JUMP_LABEL_NOP_OFFSET)"\n"
-		".pushsection __jump_table, \"aw\"\n"
+		push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		".balign 8\n"
 		".quad 0b, %l[label], %0\n"
 		".popsection\n"
@@ -30,7 +32,7 @@ label:
 static __always_inline bool arch_static_branch_jump(struct static_key *key, bool branch)
 {
 	asm_volatile_goto("0:	brcl 15, %l[label]\n"
-		".pushsection __jump_table, \"aw\"\n"
+		push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		".balign 8\n"
 		".quad 0b, %l[label], %0\n"
 		".popsection\n"
diff --git a/arch/sparc/include/asm/jump_label.h b/arch/sparc/include/asm/jump_label.h
index 62d0354d1727..dde1275233f7 100644
--- a/arch/sparc/include/asm/jump_label.h
+++ b/arch/sparc/include/asm/jump_label.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_SPARC_JUMP_LABEL_H
 #define _ASM_SPARC_JUMP_LABEL_H
 
+#include <asm/tables.h>
+
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
@@ -12,7 +14,7 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
 	asm_volatile_goto("1:\n\t"
 		 "nop\n\t"
 		 "nop\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		 ".align 4\n\t"
 		 ".word 1b, %l[l_yes], %c0\n\t"
 		 ".popsection \n\t"
@@ -28,7 +30,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 	asm_volatile_goto("1:\n\t"
 		 "b %l[l_yes]\n\t"
 		 "nop\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		 ".align 4\n\t"
 		 ".word 1b, %l[l_yes], %c0\n\t"
 		 ".popsection \n\t"
diff --git a/arch/x86/include/asm/jump_label.h b/arch/x86/include/asm/jump_label.h
index adc54c12cbd1..d25fafa3df4b 100644
--- a/arch/x86/include/asm/jump_label.h
+++ b/arch/x86/include/asm/jump_label.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_X86_JUMP_LABEL_H
 #define _ASM_X86_JUMP_LABEL_H
 
+#include <asm/tables.h>
+
 #ifndef HAVE_JUMP_LABEL
 /*
  * For better or for worse, if jump labels (the gcc extension) are missing,
@@ -34,7 +36,7 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
 {
 	asm_volatile_goto("1:"
 		".byte " __stringify(STATIC_KEY_INIT_NOP) "\n\t"
-		".pushsection __jump_table,  \"aw\" \n\t"
+		push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		_ASM_ALIGN "\n\t"
 		_ASM_PTR "1b, %l[l_yes], %c0 + %c1 \n\t"
 		".popsection \n\t"
@@ -50,7 +52,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 	asm_volatile_goto("1:"
 		".byte 0xe9\n\t .long %l[l_yes] - 2f\n\t"
 		"2:\n\t"
-		".pushsection __jump_table,  \"aw\" \n\t"
+		push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 		_ASM_ALIGN "\n\t"
 		_ASM_PTR "1b, %l[l_yes], %c0 + %c1 \n\t"
 		".popsection \n\t"
@@ -85,7 +87,7 @@ struct jump_entry {
 	.else
 	.byte		STATIC_KEY_INIT_NOP
 	.endif
-	.pushsection __jump_table, "aw"
+	push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 	_ASM_ALIGN
 	_ASM_PTR	.Lstatic_jump_\@, \target, \key
 	.popsection
@@ -101,7 +103,7 @@ struct jump_entry {
 	.long		\target - .Lstatic_jump_after_\@
 .Lstatic_jump_after_\@:
 	.endif
-	.pushsection __jump_table, "aw"
+	push_section_tbl_any(SECTION_DATA, __jump_table, aw)
 	_ASM_ALIGN
 	_ASM_PTR	.Lstatic_jump_\@, \target, \key + 1
 	.popsection
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 8e31a4454841..e186432a82e6 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -210,10 +210,6 @@
 	STRUCT_ALIGN();							\
 	*(__tracepoints)						\
 	/* implement dynamic printk debug */				\
-	. = ALIGN(8);                                                   \
-	VMLINUX_SYMBOL(__start___jump_table) = .;                       \
-	*(__jump_table)                                                 \
-	VMLINUX_SYMBOL(__stop___jump_table) = .;                        \
 	. = ALIGN(8);							\
 	VMLINUX_SYMBOL(__start___verbose) = .;                          \
 	*(__verbose)                                                    \
diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
index 661af564fae8..e6acdd8cd62b 100644
--- a/include/linux/jump_label.h
+++ b/include/linux/jump_label.h
@@ -130,8 +130,10 @@ static __always_inline bool static_key_true(struct static_key *key)
 	return !arch_static_branch(key, true);
 }
 
-extern struct jump_entry __start___jump_table[];
-extern struct jump_entry __stop___jump_table[];
+#ifndef __KERNEL__
+ #include <linux/tables.h>
+ DECLARE_LINKTABLE(struct jump_entry, __jump_table);
+#endif /* __KERNEL__ */
 
 extern void jump_label_init(void);
 extern void jump_label_lock(void);
@@ -384,6 +386,6 @@ extern bool ____wrong_branch_error(void);
 #define static_branch_enable(x)		static_key_enable(&(x)->key)
 #define static_branch_disable(x)	static_key_disable(&(x)->key)
 
-#endif	/* _LINUX_JUMP_LABEL_H */
-
 #endif /* __ASSEMBLY__ */
+
+#endif	/* _LINUX_JUMP_LABEL_H */
diff --git a/kernel/jump_label.c b/kernel/jump_label.c
index f19aa02a8f48..72dd2026ea3f 100644
--- a/kernel/jump_label.c
+++ b/kernel/jump_label.c
@@ -15,9 +15,12 @@
 #include <linux/static_key.h>
 #include <linux/jump_label_ratelimit.h>
 #include <linux/bug.h>
+#include <linux/tables.h>
 
 #ifdef HAVE_JUMP_LABEL
 
+DEFINE_LINKTABLE(struct jump_entry, __jump_table);
+
 /* mutex to protect coming/going of the the jump_label table */
 static DEFINE_MUTEX(jump_label_mutex);
 
@@ -274,8 +277,6 @@ static void __jump_label_update(struct static_key *key,
 
 void __init jump_label_init(void)
 {
-	struct jump_entry *iter_start = __start___jump_table;
-	struct jump_entry *iter_stop = __stop___jump_table;
 	struct static_key *key = NULL;
 	struct jump_entry *iter;
 
@@ -289,9 +290,10 @@ void __init jump_label_init(void)
 	BUILD_BUG_ON((int)ATOMIC_INIT(1) != 1);
 
 	jump_label_lock();
-	jump_label_sort_entries(iter_start, iter_stop);
+	jump_label_sort_entries(LINUX_SECTION_START(__jump_table),
+				LINUX_SECTION_END(__jump_table));
 
-	for (iter = iter_start; iter < iter_stop; iter++) {
+	LINKTABLE_FOR_EACH(iter, __jump_table) {
 		struct static_key *iterk;
 
 		/* rewrite NOPs */
@@ -533,8 +535,9 @@ early_initcall(jump_label_init_module);
  */
 int jump_label_text_reserved(void *start, void *end)
 {
-	int ret = __jump_label_text_reserved(__start___jump_table,
-			__stop___jump_table, start, end);
+	int ret = __jump_label_text_reserved(LINUX_SECTION_START(__jump_table),
+					     LINUX_SECTION_END(__jump_table),
+					     start, end);
 
 	if (ret)
 		return ret;
@@ -547,7 +550,7 @@ int jump_label_text_reserved(void *start, void *end)
 
 static void jump_label_update(struct static_key *key)
 {
-	struct jump_entry *stop = __stop___jump_table;
+	struct jump_entry *stop = LINUX_SECTION_END(__jump_table);
 	struct jump_entry *entry = static_key_entries(key);
 #ifdef CONFIG_MODULES
 	struct module *mod;
diff --git a/scripts/module-common.lds.S b/scripts/module-common.lds.S
index 73a2c7da0e55..d51140103ece 100644
--- a/scripts/module-common.lds.S
+++ b/scripts/module-common.lds.S
@@ -3,6 +3,10 @@
  * Archs are free to supply their own linker scripts.  ld will
  * combine them automatically.
  */
+
+#include <asm/sections.h>
+#include <asm/tables.h>
+
 SECTIONS {
 	/DISCARD/ : { *(.discard) }
 
@@ -16,6 +20,7 @@ SECTIONS {
 	__kcrctab_unused	0 : { *(SORT(___kcrctab_unused+*)) }
 	__kcrctab_unused_gpl	0 : { *(SORT(___kcrctab_unused_gpl+*)) }
 	__kcrctab_gpl_future	0 : { *(SORT(___kcrctab_gpl_future+*)) }
+	__jump_table		0 : { *(SORT(SECTION_TBL(SECTION_DATA, __jump_table, *))) }
 
 	. = ALIGN(8);
 	.init_array		0 : { *(SORT(.init_array.*)) *(.init_array) }
diff --git a/tools/objtool/special.c b/tools/objtool/special.c
index bff8abb3a4aa..f0ad369f994b 100644
--- a/tools/objtool/special.c
+++ b/tools/objtool/special.c
@@ -26,6 +26,10 @@
 #include "special.h"
 #include "warn.h"
 
+#include "../../include/asm-generic/sections.h"
+#include "../../include/asm-generic/tables.h"
+#include "../../include/linux/stringify.h"
+
 #define EX_ENTRY_SIZE		12
 #define EX_ORIG_OFFSET		0
 #define EX_NEW_OFFSET		4
@@ -63,7 +67,9 @@ struct special_entry entries[] = {
 		.feature = ALT_FEATURE_OFFSET,
 	},
 	{
-		.sec = "__jump_table",
+		.sec = __stringify(SECTION_TBL(SECTION_DATA,
+				               __jump_table,
+					       SECTION_ORDER_ANY)),
 		.jump_or_nop = true,
 		.size = JUMP_ENTRY_SIZE,
 		.orig = JUMP_ORIG_OFFSET,
-- 
2.8.4

