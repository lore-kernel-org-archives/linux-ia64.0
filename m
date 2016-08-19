From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:34:14 +0000
Subject: [PATCH v4 16/16] kprobes: port blacklist kprobes to linker table
Message-Id: <1471642454-5679-17-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, ton

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

kprobe makes use of two sections, the one dealing with the actual
kprobes was recently ported using the standard section range API.
The blacklist functionality of kprobes is still using a custom
section and declaring its custom section using the linker script
as follows:

type  Linux-section custom section name  begin                    end
table .init.data    _kprobe_blacklist    __start_kprobe_blacklist __stop_kprobe_blacklist

This ports the _kprobe_blacklist custom section to the standard
Linux linker table API allowing us remove all the custom blacklist
kprobe section declarations from the linker script.

This has been tested by trying to register a kprobe on a blacklisted
symbol (these are declared with NOKPROBE_SYMBOL()), and confirms that
this fails to work as expected. This was tested with:

 # insmod samples/kprobes/kprobe_example.ko symbol="get_kprobe"

This fails to load as expected with:

insmod: ERROR: could not insert module samples/kprobes/kprobe_example.ko: Invalid parameters

v3: this patch was introduced in this series

Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 include/asm-generic/kprobes.h     |  4 ++--
 include/asm-generic/vmlinux.lds.h | 10 ----------
 include/linux/kprobes.h           |  2 ++
 kernel/kprobes.c                  | 11 ++++-------
 4 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/include/asm-generic/kprobes.h b/include/asm-generic/kprobes.h
index 7b986f4b7ccd..23a49a4c7a38 100644
--- a/include/asm-generic/kprobes.h
+++ b/include/asm-generic/kprobes.h
@@ -3,14 +3,14 @@
 
 #if defined(__KERNEL__) && !defined(__ASSEMBLY__)
 #ifdef CONFIG_KPROBES
+#include <linux/tables.h>
 #include <asm/ranges.h>
 /*
  * Blacklist ganerating macro. Specify functions which is not probed
  * by using this macro.
  */
 # define __NOKPROBE_SYMBOL(fname)				\
-static unsigned long __used					\
-	__attribute__((__section__("_kprobe_blacklist")))	\
+static LINKTABLE_INIT_DATA(_kprobe_blacklist, all)		\
 	_kbl_addr_##fname = (unsigned long)fname;
 # define NOKPROBE_SYMBOL(fname)	__NOKPROBE_SYMBOL(fname)
 /* Use this to forbid a kprobes attach on very low level functions */
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index f2444d82d02a..47ef04de9958 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -114,15 +114,6 @@
 #define BRANCH_PROFILE()
 #endif
 
-#ifdef CONFIG_KPROBES
-#define KPROBE_BLACKLIST()	. = ALIGN(8);				      \
-				VMLINUX_SYMBOL(__start_kprobe_blacklist) = .; \
-				*(_kprobe_blacklist)			      \
-				VMLINUX_SYMBOL(__stop_kprobe_blacklist) = .;
-#else
-#define KPROBE_BLACKLIST()
-#endif
-
 #ifdef CONFIG_EVENT_TRACING
 #define FTRACE_EVENTS()	. = ALIGN(8);					\
 			VMLINUX_SYMBOL(__start_ftrace_events) = .;	\
@@ -525,7 +516,6 @@
 	*(SECTION_INIT_RODATA)						\
 	FTRACE_EVENTS()							\
 	TRACE_SYSCALLS()						\
-	KPROBE_BLACKLIST()						\
 	MEM_DISCARD(init.rodata)					\
 	CLK_OF_TABLES()							\
 	RESERVEDMEM_OF_TABLES()						\
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 445cc6fe7afa..2707820cbb56 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -44,8 +44,10 @@
 
 #ifdef CONFIG_KPROBES
 #include <linux/ranges.h>
+#include <linux/tables.h>
 
 DECLARE_SECTION_RANGE(kprobes);
+DECLARE_LINKTABLE(unsigned long, _kprobe_blacklist);
 
 /* kprobe_status settings */
 #define KPROBE_HIT_ACTIVE	0x00000001
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 387605682622..4801aa3b4adf 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -2053,14 +2053,13 @@ NOKPROBE_SYMBOL(dump_kprobe);
  * since a kprobe need not necessarily be at the beginning
  * of a function.
  */
-static int __init populate_kprobe_blacklist(unsigned long *start,
-					     unsigned long *end)
+static int __init populate_kprobe_blacklist(void)
 {
 	unsigned long *iter;
 	struct kprobe_blacklist_entry *ent;
 	unsigned long entry, offset = 0, size = 0;
 
-	for (iter = start; iter < end; iter++) {
+	LINKTABLE_FOR_EACH(iter, _kprobe_blacklist) {
 		entry = arch_deref_entry_point((void *)*iter);
 
 		if (!kernel_text_address(entry) ||
@@ -2125,8 +2124,7 @@ static struct notifier_block kprobe_module_nb = {
 };
 
 /* Markers of _kprobe_blacklist section */
-extern unsigned long __start_kprobe_blacklist[];
-extern unsigned long __stop_kprobe_blacklist[];
+DEFINE_LINKTABLE_INIT_DATA(unsigned long, _kprobe_blacklist);
 
 /* Actual kprobes section range */
 DEFINE_SECTION_RANGE(kprobes, SECTION_TEXT);
@@ -2143,8 +2141,7 @@ static int __init init_kprobes(void)
 		raw_spin_lock_init(&(kretprobe_table_locks[i].lock));
 	}
 
-	err = populate_kprobe_blacklist(__start_kprobe_blacklist,
-					__stop_kprobe_blacklist);
+	err = populate_kprobe_blacklist();
 	if (err) {
 		pr_err("kprobes: failed to populate blacklist: %d\n", err);
 		pr_err("Please take care of using kprobes.\n");
-- 
2.9.2

