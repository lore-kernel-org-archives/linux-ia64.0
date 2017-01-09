From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Mon, 09 Jan 2017 14:58:27 +0000
Subject: [PATCH v6 09/14] jump_label: port __jump_table to linker tables
Message-Id: <20170109145833.11502-10-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161222023811.21246-1-mcgrof@kernel.org>
 <20170109145833.11502-1-mcgrof@kernel.org>
In-Reply-To: <20170109145833.11502-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, wangnan0@huawei.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, joro@8bytes.org, x86@kernel.org, fontana@sharpeleven.org, dsahern@gmail.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux@roeck-us.net, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org

Move the __jump_table from the a custom section solution
to a generic solution, this avoiding extra vmlinux.lds.h
customizations.

This also demos the use of the .data linker table and of
the shared asm call push_section_tbl().

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
architectures to just use "\n", this is defined as ASM_CMD_SEP,
and if an architecture needs to override they can do so on their
architecture sections.h prior to including asm-generic/sections.h

v6: rename table macro as suggested by Andy Shevchenko

v5:

o Use ..tbl instead of .tbl as suggested by Nicholas Piggin.
  This is the typical way to avoid clash with compiler generated
  section.

o Replace section macros with section names

o Use LINKTABLE_START() and LINKTABLE_END()

o fixed tile jump label port -- tile got jump label support as of commit
  65a792e84f25d1 ("tile/jump_label: add jump label support for TILE-Gx"),
  as such we just needed to adjust the asm to account for the new
  linker table API use. This commit was merged as of v4.5-rc1.

v4:

o Some architectures allow linker scripts to follow including header
  files, some others do not, so if you need a helper on a linker script
  you need to explicitly include it. So for instance although
  scripts/module-common.lds.S includes <asm/tables.h> and this file
  includes <asm/section-core.h>, you still need to explicitly
  include it on the linker script. This issue is present on ARM.

o as per Josh Poimboeuf open code the section table name instead
  of including the kernel section headers, the simplicity and
  independence from the kernel is preferred.

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
 arch/tile/include/asm/jump_label.h    |  5 +++--
 arch/x86/include/asm/jump_label.h     | 10 ++++++----
 include/asm-generic/vmlinux.lds.h     |  5 -----
 include/linux/jump_label.h            |  4 ++--
 kernel/jump_label.c                   | 17 ++++++++++-------
 scripts/module-common.lds             |  1 +
 tools/objtool/special.c               |  2 +-
 13 files changed, 48 insertions(+), 34 deletions(-)

diff --git a/arch/arm/include/asm/jump_label.h b/arch/arm/include/asm/jump_label.h
index 34f7b6980d21..609e0592a942 100644
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
+		 push_section_tbl_any(.data, __jump_table, aw)
 		 ".word 1b, %l[l_yes], %c0\n\t"
 		 ".popsection\n\t"
 		 : :  "i" (&((char *)key)[branch]) :  : l_yes);
@@ -26,7 +28,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 {
 	asm_volatile_goto("1:\n\t"
 		 WASM(b) " %l[l_yes]\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(.data, __jump_table, aw)
 		 ".word 1b, %l[l_yes], %c0\n\t"
 		 ".popsection\n\t"
 		 : :  "i" (&((char *)key)[branch]) :  : l_yes);
diff --git a/arch/arm64/include/asm/jump_label.h b/arch/arm64/include/asm/jump_label.h
index 1b5e0e843c3a..bb56ac4fafb5 100644
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
+		 push_section_tbl_any(.data, __jump_table, aw)
 		 ".align 3\n\t"
 		 ".quad 1b, %l[l_yes], %c0\n\t"
 		 ".popsection\n\t"
@@ -43,7 +45,7 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
 static __always_inline bool arch_static_branch_jump(struct static_key *key, bool branch)
 {
 	asm goto("1: b %l[l_yes]\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(.data, __jump_table, aw)
 		 ".align 3\n\t"
 		 ".quad 1b, %l[l_yes], %c0\n\t"
 		 ".popsection\n\t"
diff --git a/arch/mips/include/asm/jump_label.h b/arch/mips/include/asm/jump_label.h
index e77672539e8e..07289a1b1bcd 100644
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
+		push_section_tbl_any(.data, __jump_table, aw)
 		WORD_INSN " 1b, %l[l_yes], %0\n\t"
 		".popsection\n\t"
 		: :  "i" (&((char *)key)[branch]) : : l_yes);
@@ -44,7 +46,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 {
 	asm_volatile_goto("1:\tj %l[l_yes]\n\t"
 		"nop\n\t"
-		".pushsection __jump_table,  \"aw\"\n\t"
+		push_section_tbl_any(.data, __jump_table, aw)
 		WORD_INSN " 1b, %l[l_yes], %0\n\t"
 		".popsection\n\t"
 		: :  "i" (&((char *)key)[branch]) : : l_yes);
diff --git a/arch/powerpc/include/asm/jump_label.h b/arch/powerpc/include/asm/jump_label.h
index 9a287e0ac8b1..7a75623740d0 100644
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
 		 "nop # arch_static_branch\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(.data, __jump_table, aw)
 		 JUMP_ENTRY_TYPE "1b, %l[l_yes], %c0\n\t"
 		 ".popsection \n\t"
 		 : :  "i" (&((char *)key)[branch]) : : l_yes);
@@ -37,7 +39,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 {
 	asm_volatile_goto("1:\n\t"
 		 "b %l[l_yes] # arch_static_branch_jump\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(.data, __jump_table, aw)
 		 JUMP_ENTRY_TYPE "1b, %l[l_yes], %c0\n\t"
 		 ".popsection \n\t"
 		 : :  "i" (&((char *)key)[branch]) : : l_yes);
@@ -62,7 +64,7 @@ struct jump_entry {
 #else
 #define ARCH_STATIC_BRANCH(LABEL, KEY)		\
 1098:	nop;					\
-	.pushsection __jump_table, "aw";	\
+	push_section_tbl_any(.data, __jump_table, aw); \
 	FTR_ENTRY_LONG 1098b, LABEL, KEY;	\
 	.popsection
 #endif
diff --git a/arch/s390/include/asm/jump_label.h b/arch/s390/include/asm/jump_label.h
index 9be198f5ee79..58e53af49e7e 100644
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
+		push_section_tbl_any(.data, __jump_table, aw)
 		".balign 8\n"
 		".quad 0b, %l[label], %0\n"
 		".popsection\n"
@@ -30,7 +32,7 @@ static __always_inline bool arch_static_branch(struct static_key *key, bool bran
 static __always_inline bool arch_static_branch_jump(struct static_key *key, bool branch)
 {
 	asm_volatile_goto("0:	brcl 15, %l[label]\n"
-		".pushsection __jump_table, \"aw\"\n"
+		push_section_tbl_any(.data, __jump_table, aw)
 		".balign 8\n"
 		".quad 0b, %l[label], %0\n"
 		".popsection\n"
diff --git a/arch/sparc/include/asm/jump_label.h b/arch/sparc/include/asm/jump_label.h
index 62d0354d1727..35d3e5d31821 100644
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
+		 push_section_tbl_any(.data, __jump_table, aw)
 		 ".align 4\n\t"
 		 ".word 1b, %l[l_yes], %c0\n\t"
 		 ".popsection \n\t"
@@ -28,7 +30,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 	asm_volatile_goto("1:\n\t"
 		 "b %l[l_yes]\n\t"
 		 "nop\n\t"
-		 ".pushsection __jump_table,  \"aw\"\n\t"
+		 push_section_tbl_any(.data, __jump_table, aw)
 		 ".align 4\n\t"
 		 ".word 1b, %l[l_yes], %c0\n\t"
 		 ".popsection \n\t"
diff --git a/arch/tile/include/asm/jump_label.h b/arch/tile/include/asm/jump_label.h
index cde7573f397b..9bd989daad4a 100644
--- a/arch/tile/include/asm/jump_label.h
+++ b/arch/tile/include/asm/jump_label.h
@@ -16,6 +16,7 @@
 #define _ASM_TILE_JUMP_LABEL_H
 
 #include <arch/opcode.h>
+#include <asm/tables.h>
 
 #define JUMP_LABEL_NOP_SIZE	TILE_BUNDLE_SIZE_IN_BYTES
 
@@ -24,7 +25,7 @@ static __always_inline bool arch_static_branch(struct static_key *key,
 {
 	asm_volatile_goto("1:\n\t"
 		"nop" "\n\t"
-		".pushsection __jump_table,  \"aw\"\n\t"
+		push_section_tbl_any(.data, __jump_table, aw)
 		".quad 1b, %l[l_yes], %0 + %1 \n\t"
 		".popsection\n\t"
 		: :  "i" (key), "i" (branch) : : l_yes);
@@ -38,7 +39,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key,
 {
 	asm_volatile_goto("1:\n\t"
 		"j %l[l_yes]" "\n\t"
-		".pushsection __jump_table,  \"aw\"\n\t"
+		push_section_tbl_any(.data, __jump_table, aw)
 		".quad 1b, %l[l_yes], %0 + %1 \n\t"
 		".popsection\n\t"
 		: :  "i" (key), "i" (branch) : : l_yes);
diff --git a/arch/x86/include/asm/jump_label.h b/arch/x86/include/asm/jump_label.h
index adc54c12cbd1..627df4752db0 100644
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
+		push_section_tbl_any(.data, __jump_table, aw)
 		_ASM_ALIGN "\n\t"
 		_ASM_PTR "1b, %l[l_yes], %c0 + %c1 \n\t"
 		".popsection \n\t"
@@ -50,7 +52,7 @@ static __always_inline bool arch_static_branch_jump(struct static_key *key, bool
 	asm_volatile_goto("1:"
 		".byte 0xe9\n\t .long %l[l_yes] - 2f\n\t"
 		"2:\n\t"
-		".pushsection __jump_table,  \"aw\" \n\t"
+		push_section_tbl_any(.data, __jump_table, aw)
 		_ASM_ALIGN "\n\t"
 		_ASM_PTR "1b, %l[l_yes], %c0 + %c1 \n\t"
 		".popsection \n\t"
@@ -85,7 +87,7 @@ struct jump_entry {
 	.else
 	.byte		STATIC_KEY_INIT_NOP
 	.endif
-	.pushsection __jump_table, "aw"
+	push_section_tbl_any(.data, __jump_table, aw)
 	_ASM_ALIGN
 	_ASM_PTR	.Lstatic_jump_\@, \target, \key
 	.popsection
@@ -101,7 +103,7 @@ struct jump_entry {
 	.long		\target - .Lstatic_jump_after_\@
 .Lstatic_jump_after_\@:
 	.endif
-	.pushsection __jump_table, "aw"
+	push_section_tbl_any(.data, __jump_table, aw)
 	_ASM_ALIGN
 	_ASM_PTR	.Lstatic_jump_\@, \target, \key + 1
 	.popsection
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 8a5325d75932..887d844f0406 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -216,11 +216,6 @@
 	*(.data.unlikely)						\
 	STRUCT_ALIGN();							\
 	*(__tracepoints)						\
-	/* implement dynamic printk debug */				\
-	. = ALIGN(8);                                                   \
-	VMLINUX_SYMBOL(__start___jump_table) = .;                       \
-	KEEP(*(__jump_table))                                           \
-	VMLINUX_SYMBOL(__stop___jump_table) = .;                        \
 	. = ALIGN(8);							\
 	VMLINUX_SYMBOL(__start___verbose) = .;                          \
 	KEEP(*(__verbose))                                              \
diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
index b63d6b7b0db0..e6277888b558 100644
--- a/include/linux/jump_label.h
+++ b/include/linux/jump_label.h
@@ -117,6 +117,7 @@ enum jump_label_type {
 struct module;
 
 #ifdef HAVE_JUMP_LABEL
+#include <linux/tables.h>
 
 #define JUMP_TYPE_FALSE	0UL
 #define JUMP_TYPE_TRUE	1UL
@@ -132,8 +133,7 @@ static __always_inline bool static_key_true(struct static_key *key)
 	return !arch_static_branch(key, true);
 }
 
-extern struct jump_entry __start___jump_table[];
-extern struct jump_entry __stop___jump_table[];
+DECLARE_LINKTABLE(struct jump_entry, __jump_table);
 
 extern void jump_label_init(void);
 extern void jump_label_lock(void);
diff --git a/kernel/jump_label.c b/kernel/jump_label.c
index 93ad6c1fb9b6..4252f17eaeb5 100644
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
 
@@ -292,9 +293,10 @@ void __init jump_label_init(void)
 		return;
 
 	jump_label_lock();
-	jump_label_sort_entries(iter_start, iter_stop);
+	jump_label_sort_entries(LINKTABLE_START(__jump_table),
+				LINKTABLE_END(__jump_table));
 
-	for (iter = iter_start; iter < iter_stop; iter++) {
+	linktable_for_each(iter, __jump_table) {
 		struct static_key *iterk;
 
 		/* rewrite NOPs */
@@ -539,8 +541,9 @@ early_initcall(jump_label_init_module);
  */
 int jump_label_text_reserved(void *start, void *end)
 {
-	int ret = __jump_label_text_reserved(__start___jump_table,
-			__stop___jump_table, start, end);
+	int ret = __jump_label_text_reserved(LINKTABLE_START(__jump_table),
+					     LINKTABLE_END(__jump_table),
+					     start, end);
 
 	if (ret)
 		return ret;
@@ -553,7 +556,7 @@ int jump_label_text_reserved(void *start, void *end)
 
 static void jump_label_update(struct static_key *key)
 {
-	struct jump_entry *stop = __stop___jump_table;
+	struct jump_entry *stop = LINKTABLE_END(__jump_table);
 	struct jump_entry *entry = static_key_entries(key);
 #ifdef CONFIG_MODULES
 	struct module *mod;
diff --git a/scripts/module-common.lds b/scripts/module-common.lds
index 73a2c7da0e55..db0e724556c5 100644
--- a/scripts/module-common.lds
+++ b/scripts/module-common.lds
@@ -16,6 +16,7 @@ SECTIONS {
 	__kcrctab_unused	0 : { *(SORT(___kcrctab_unused+*)) }
 	__kcrctab_unused_gpl	0 : { *(SORT(___kcrctab_unused_gpl+*)) }
 	__kcrctab_gpl_future	0 : { *(SORT(___kcrctab_gpl_future+*)) }
+	__jump_table		0 : { *(SORT(.data..tbl.__jump_table.*)) }
 
 	. = ALIGN(8);
 	.init_array		0 : { *(SORT(.init_array.*)) *(.init_array) }
diff --git a/tools/objtool/special.c b/tools/objtool/special.c
index bff8abb3a4aa..79968e118294 100644
--- a/tools/objtool/special.c
+++ b/tools/objtool/special.c
@@ -63,7 +63,7 @@ struct special_entry entries[] = {
 		.feature = ALT_FEATURE_OFFSET,
 	},
 	{
-		.sec = "__jump_table",
+		.sec = ".data..tbl.__jump_table.any",
 		.jump_or_nop = true,
 		.size = JUMP_ENTRY_SIZE,
 		.orig = JUMP_ORIG_OFFSET,
-- 
2.11.0

