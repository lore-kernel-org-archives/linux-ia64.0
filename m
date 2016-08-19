From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:34:11 +0000
Subject: [PATCH v4 13/16] dynamic_debug: port to use linker tables
Message-Id: <1471642454-5679-14-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, ton

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

This removes the custom vmlinux.lds.h hacks and uses
the generalized solution for .data (SECTION_DATA)
entries.

This is much more potential for further fine tuning here
though in the future. For instance, linker tables enable
an extra postfix for order level annotations, this could
easily be used as the KBUILD_MODNAME and with a bit of
linker table changes we may be able to get a direct O(1)
count of the entries for that KBUILD_MODNAME: it would
just be a count on the number of entries for the given
order level. This should help make dynamic_debug_init()
cleaner and also reduce the amount of time it takes at
boot time. Instead of iterating over each print until we
have all for a KBUILD_MODNAME, we'd instead directly
operate on each KBUILD_MODNAME directly.

Tested dynamic debug with dyndbg query ana debugfs control
and it works as expected, for both built-in code and modules.

v4: fix compilation on blackfin
v3: added modular support
v2: introduced this patch into the series

Cc: Barry Song <barry.song@analog.com>
Cc: Mike Frysinger <vapier@gentoo.org>
Cc: Steven Miao <realmz6@gmail.com>
Cc: Michael Matz <matz@suse.de>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 include/asm-generic/vmlinux.lds.h |  5 -----
 include/linux/dynamic_debug.h     |  5 +++--
 lib/dynamic_debug.c               | 13 ++++++-------
 scripts/module-common.lds.S       |  1 +
 4 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 140fbed4a817..ba49b7ad7af2 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -211,11 +211,6 @@
 	*(.data.unlikely)						\
 	STRUCT_ALIGN();							\
 	*(__tracepoints)						\
-	/* implement dynamic printk debug */				\
-	. = ALIGN(8);							\
-	VMLINUX_SYMBOL(__start___verbose) = .;                          \
-	*(__verbose)                                                    \
-	VMLINUX_SYMBOL(__stop___verbose) = .;				\
 	LIKELY_PROFILE()		       				\
 	BRANCH_PROFILE()						\
 	TRACE_PRINTKS()							\
diff --git a/include/linux/dynamic_debug.h b/include/linux/dynamic_debug.h
index 546d68057e3b..a52618a77b09 100644
--- a/include/linux/dynamic_debug.h
+++ b/include/linux/dynamic_debug.h
@@ -4,6 +4,7 @@
 #if defined(CC_HAVE_ASM_GOTO) && defined(CONFIG_JUMP_LABEL)
 #include <linux/jump_label.h>
 #endif
+#include <linux/tables.h>
 
 /*
  * An instance of this structure is created in a special
@@ -50,6 +51,7 @@ int ddebug_add_module(struct _ddebug *tab, unsigned int n,
 				const char *modname);
 
 #if defined(CONFIG_DYNAMIC_DEBUG)
+DECLARE_LINKTABLE(struct _ddebug, __verbose);
 extern int ddebug_remove_module(const char *mod_name);
 extern __printf(2, 3)
 void __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...);
@@ -71,8 +73,7 @@ void __dynamic_netdev_dbg(struct _ddebug *descriptor,
 			  const char *fmt, ...);
 
 #define DEFINE_DYNAMIC_DEBUG_METADATA_KEY(name, fmt, key, init)	\
-	static struct _ddebug  __aligned(8)			\
-	__attribute__((section("__verbose"))) name = {		\
+	static LINKTABLE(__verbose, SECTION_ORDER_ANY) name = {	\
 		.modname = KBUILD_MODNAME,			\
 		.function = __func__,				\
 		.filename = __FILE__,				\
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index da796e2dc4f5..f0060c84c654 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -37,8 +37,7 @@
 #include <linux/device.h>
 #include <linux/netdevice.h>
 
-extern struct _ddebug __start___verbose[];
-extern struct _ddebug __stop___verbose[];
+DEFINE_LINKTABLE(struct _ddebug, __verbose);
 
 struct ddebug_table {
 	struct list_head link;
@@ -978,14 +977,14 @@ static int __init dynamic_debug_init(void)
 	int n = 0, entries = 0, modct = 0;
 	int verbose_bytes = 0;
 
-	if (__start___verbose = __stop___verbose) {
-		pr_warn("_ddebug table is empty in a CONFIG_DYNAMIC_DEBUG build\n");
+	if (LINUX_SECTION_EMPTY(__verbose)) {
+		pr_warn("dynamic debug linker table empty on CONFIG_DYNAMIC_DEBUG build\n");
 		return 1;
 	}
-	iter = __start___verbose;
+	iter = LINUX_SECTION_START(__verbose);
 	modname = iter->modname;
 	iter_start = iter;
-	for (; iter < __stop___verbose; iter++) {
+	LINKTABLE_FOR_EACH(iter, __verbose) {
 		entries++;
 		verbose_bytes += strlen(iter->modname) + strlen(iter->function)
 			+ strlen(iter->filename) + strlen(iter->format);
@@ -1008,7 +1007,7 @@ static int __init dynamic_debug_init(void)
 	ddebug_init_success = 1;
 	vpr_info("%d modules, %d entries and %d bytes in ddebug tables, %d bytes in (readonly) verbose section\n",
 		 modct, entries, (int)(modct * sizeof(struct ddebug_table)),
-		 verbose_bytes + (int)(__stop___verbose - __start___verbose));
+		 verbose_bytes + (int)(LINUX_SECTION_SIZE(__verbose)));
 
 	/* apply ddebug_query boot param, dont unload tables on err */
 	if (ddebug_setup_string[0] != '\0') {
diff --git a/scripts/module-common.lds.S b/scripts/module-common.lds.S
index be3bde1ea0ce..be57ca0994dc 100644
--- a/scripts/module-common.lds.S
+++ b/scripts/module-common.lds.S
@@ -21,6 +21,7 @@ SECTIONS {
 	__kcrctab_unused_gpl	0 : { *(SORT(___kcrctab_unused_gpl+*)) }
 	__kcrctab_gpl_future	0 : { *(SORT(___kcrctab_gpl_future+*)) }
 	__jump_table		0 : { *(SORT(SECTION_TBL(SECTION_DATA, __jump_table, *))) }
+	__verbose		0 : { *(SORT(SECTION_TBL(SECTION_DATA, __verbose, *))) }
 
 	. = ALIGN(8);
 	.init_array		0 : { *(SORT(.init_array.*)) *(.init_array) }
-- 
2.9.2

