From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 06 Jul 2008 05:53:17 +0000
Subject: Re: the printk problem
Message-Id: <20080706055317.GA4212@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com> <20080704111540.ddffd241.akpm@linux-foundation.org> <alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org> <alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org> <1215212420.8970.8.camel@pasglop> <alpine.LFD.1.10.0807041622270.2815@woody.linux-foundation.org> <alpine.LFD.1.10.0807051523180.2847@woody.linux-foundation.org> <20080706052741.GA18928@elte.hu> <alpine.LFD.1.10.0807052232530.3016@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0807052232530.3016@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, parisc-linux@parisc-linux.org, "David S. Miller" <davem@davemloft.net>, Peter Anvin <hpa@zytor.com>, Arjan van de Ven <arjan@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, 6 Jul 2008, Ingo Molnar wrote:
> > 
> > applied (with the commit message below) to tip/x86/debug for v2.6.27 
> > merging, thanks Linus. Can i add your SOB too?
> 
> Sure, add my S-O-B. But I hope/assuem that you also added my earlier 
> patch that added the support for '%pS' too? I'm not entirely sure that 
> should go in an x86-specific branch, since it has nothing x86-specific 
> in it.

yeah, agreed, combined it's not an x86 topic anymore.

[ There's some lkml trouble so i've missed the earlier patch. I'm not 
  sure the email problem is on my side, see how incomplete the 
  discussion is on lkml.org as well:

     http://lkml.org/lkml/2008/6/25/170   ]

Anyway, i have have added this second patch of yours to tip/core/printk 
and moved your first patch over to that topic (which relies on it).

That topic has a few other (smaller) printk enhancements queued for 
v2.6.27 already:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git core/printk

[find other stats below]

so it fits in naturally.

	Ingo

------------------>
Ingo Molnar (1):
      printk: export console_drivers

Jan Kiszka (1):
      printk: don't prefer unsuited consoles on registration

Jiri Slaby (1):
      x86, generic: mark early_printk as asmlinkage

Linus Torvalds (2):
      printk: add support for '%pS'
      x86, 64-bit: standardize printk_address()

Nick Andrew (2):
      printk: refactor processing of line severity tokens
      printk: remember the message level for multi-line output

Tejun Heo (1):
      printk: clean up recursion check related static variables

Thomas Gleixner (2):
      namespacecheck: fix kernel printk.c
      namespacecheck: more kernel/printk.c fixes

 arch/x86/kernel/early_printk.c |    2 +-
 arch/x86/kernel/traps_64.c     |   25 +--------
 include/linux/kernel.h         |    8 +---
 kernel/printk.c                |  107 +++++++++++++++---------------------
 lib/vsprintf.c                 |  118 +++++++++++++++++++++++++++++-----------
 5 files changed, 133 insertions(+), 127 deletions(-)

diff --git a/arch/x86/kernel/early_printk.c b/arch/x86/kernel/early_printk.c
index 643fd86..ff9e735 100644
--- a/arch/x86/kernel/early_printk.c
+++ b/arch/x86/kernel/early_printk.c
@@ -196,7 +196,7 @@ static struct console simnow_console = {
 static struct console *early_console = &early_vga_console;
 static int early_console_initialized;
 
-void early_printk(const char *fmt, ...)
+asmlinkage void early_printk(const char *fmt, ...)
 {
 	char buf[512];
 	int n;
diff --git a/arch/x86/kernel/traps_64.c b/arch/x86/kernel/traps_64.c
index adff76e..f1a95d1 100644
--- a/arch/x86/kernel/traps_64.c
+++ b/arch/x86/kernel/traps_64.c
@@ -104,30 +104,7 @@ int kstack_depth_to_print = 12;
 
 void printk_address(unsigned long address, int reliable)
 {
-#ifdef CONFIG_KALLSYMS
-	unsigned long offset = 0, symsize;
-	const char *symname;
-	char *modname;
-	char *delim = ":";
-	char namebuf[KSYM_NAME_LEN];
-	char reliab[4] = "";
-
-	symname = kallsyms_lookup(address, &symsize, &offset,
-					&modname, namebuf);
-	if (!symname) {
-		printk(" [<%016lx>]\n", address);
-		return;
-	}
-	if (!reliable)
-		strcpy(reliab, "? ");
-
-	if (!modname)
-		modname = delim = "";
-	printk(" [<%016lx>] %s%s%s%s%s+0x%lx/0x%lx\n",
-		address, reliab, delim, modname, delim, symname, offset, symsize);
-#else
-	printk(" [<%016lx>]\n", address);
-#endif
+	printk(" [<%016lx>] %s%pS\n", address, reliable ? "": "? ", (void *) address);
 }
 
 static unsigned long *in_exception_stack(unsigned cpu, unsigned long stack,
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 792bf0a..4cb8d3d 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -184,9 +184,6 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 	__attribute__ ((format (printf, 1, 0)));
 asmlinkage int printk(const char * fmt, ...)
 	__attribute__ ((format (printf, 1, 2))) __cold;
-extern int log_buf_get_len(void);
-extern int log_buf_read(int idx);
-extern int log_buf_copy(char *dest, int idx, int len);
 
 extern int printk_ratelimit_jiffies;
 extern int printk_ratelimit_burst;
@@ -202,9 +199,6 @@ static inline int vprintk(const char *s, va_list args) { return 0; }
 static inline int printk(const char *s, ...)
 	__attribute__ ((format (printf, 1, 2)));
 static inline int __cold printk(const char *s, ...) { return 0; }
-static inline int log_buf_get_len(void) { return 0; }
-static inline int log_buf_read(int idx) { return 0; }
-static inline int log_buf_copy(char *dest, int idx, int len) { return 0; }
 static inline int printk_ratelimit(void) { return 0; }
 static inline int __printk_ratelimit(int ratelimit_jiffies, \
 				     int ratelimit_burst) { return 0; }
@@ -213,7 +207,7 @@ static inline bool printk_timed_ratelimit(unsigned long *caller_jiffies, \
 		{ return false; }
 #endif
 
-extern void __attribute__((format(printf, 1, 2)))
+extern void asmlinkage __attribute__((format(printf, 1, 2)))
 	early_printk(const char *fmt, ...);
 
 unsigned long int_sqrt(unsigned long);
diff --git a/kernel/printk.c b/kernel/printk.c
index 8fb01c3..de1a4f4 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -38,7 +38,7 @@
 /*
  * Architectures can override it:
  */
-void __attribute__((weak)) early_printk(const char *fmt, ...)
+void asmlinkage __attribute__((weak)) early_printk(const char *fmt, ...)
 {
 }
 
@@ -75,6 +75,8 @@ EXPORT_SYMBOL(oops_in_progress);
 static DECLARE_MUTEX(console_sem);
 static DECLARE_MUTEX(secondary_console_sem);
 struct console *console_drivers;
+EXPORT_SYMBOL_GPL(console_drivers);
+
 /*
  * This is used for debugging the mess that is the VT code by
  * keeping track if we have the console semaphore held. It's
@@ -231,7 +233,7 @@ static inline void boot_delay_msec(void)
 /*
  * Return the number of unread characters in the log buffer.
  */
-int log_buf_get_len(void)
+static int log_buf_get_len(void)
 {
 	return logged_chars;
 }
@@ -268,19 +270,6 @@ int log_buf_copy(char *dest, int idx, int len)
 }
 
 /*
- * Extract a single character from the log buffer.
- */
-int log_buf_read(int idx)
-{
-	char ret;
-
-	if (log_buf_copy(&ret, idx, 1) = 1)
-		return ret;
-	else
-		return -1;
-}
-
-/*
  * Commands to do_syslog:
  *
  * 	0 -- Close the log.  Currently a NOP.
@@ -665,18 +654,17 @@ static int acquire_console_semaphore_for_printk(unsigned int cpu)
 	spin_unlock(&logbuf_lock);
 	return retval;
 }
-
-const char printk_recursion_bug_msg [] -			KERN_CRIT "BUG: recent printk recursion!\n";
-static int printk_recursion_bug;
+static const char recursion_bug_msg [] +		KERN_CRIT "BUG: recent printk recursion!\n";
+static int recursion_bug;
+	static int new_text_line = 1;
+static char printk_buf[1024];
 
 asmlinkage int vprintk(const char *fmt, va_list args)
 {
-	static int log_level_unknown = 1;
-	static char printk_buf[1024];
-
-	unsigned long flags;
 	int printed_len = 0;
+	int current_log_level = default_message_loglevel;
+	unsigned long flags;
 	int this_cpu;
 	char *p;
 
@@ -699,7 +687,7 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 		 * it can be printed at the next appropriate moment:
 		 */
 		if (!oops_in_progress) {
-			printk_recursion_bug = 1;
+			recursion_bug = 1;
 			goto out_restore_irqs;
 		}
 		zap_locks();
@@ -709,70 +697,62 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 	spin_lock(&logbuf_lock);
 	printk_cpu = this_cpu;
 
-	if (printk_recursion_bug) {
-		printk_recursion_bug = 0;
-		strcpy(printk_buf, printk_recursion_bug_msg);
-		printed_len = sizeof(printk_recursion_bug_msg);
+	if (recursion_bug) {
+		recursion_bug = 0;
+		strcpy(printk_buf, recursion_bug_msg);
+		printed_len = sizeof(recursion_bug_msg);
 	}
 	/* Emit the output into the temporary buffer */
 	printed_len += vscnprintf(printk_buf + printed_len,
 				  sizeof(printk_buf) - printed_len, fmt, args);
 
+
 	/*
 	 * Copy the output into log_buf.  If the caller didn't provide
 	 * appropriate log level tags, we insert them here
 	 */
 	for (p = printk_buf; *p; p++) {
-		if (log_level_unknown) {
-                        /* log_level_unknown signals the start of a new line */
+		if (new_text_line) {
+			/* If a token, set current_log_level and skip over */
+			if (p[0] = '<' && p[1] >= '0' && p[1] <= '7' &&
+			    p[2] = '>') {
+				current_log_level = p[1] - '0';
+				p += 3;
+				printed_len -= 3;
+			}
+
+			/* Always output the token */
+			emit_log_char('<');
+			emit_log_char(current_log_level + '0');
+			emit_log_char('>');
+			printed_len += 3;
+			new_text_line = 0;
+
 			if (printk_time) {
-				int loglev_char;
+				/* Follow the token with the time */
 				char tbuf[50], *tp;
 				unsigned tlen;
 				unsigned long long t;
 				unsigned long nanosec_rem;
 
-				/*
-				 * force the log level token to be
-				 * before the time output.
-				 */
-				if (p[0] = '<' && p[1] >='0' &&
-				   p[1] <= '7' && p[2] = '>') {
-					loglev_char = p[1];
-					p += 3;
-					printed_len -= 3;
-				} else {
-					loglev_char = default_message_loglevel
-						+ '0';
-				}
 				t = cpu_clock(printk_cpu);
 				nanosec_rem = do_div(t, 1000000000);
-				tlen = sprintf(tbuf,
-						"<%c>[%5lu.%06lu] ",
-						loglev_char,
-						(unsigned long)t,
-						nanosec_rem/1000);
+				tlen = sprintf(tbuf, "[%5lu.%06lu] ",
+						(unsigned long) t,
+						nanosec_rem / 1000);
 
 				for (tp = tbuf; tp < tbuf + tlen; tp++)
 					emit_log_char(*tp);
 				printed_len += tlen;
-			} else {
-				if (p[0] != '<' || p[1] < '0' ||
-				   p[1] > '7' || p[2] != '>') {
-					emit_log_char('<');
-					emit_log_char(default_message_loglevel
-						+ '0');
-					emit_log_char('>');
-					printed_len += 3;
-				}
 			}
-			log_level_unknown = 0;
+
 			if (!*p)
 				break;
 		}
+
 		emit_log_char(*p);
 		if (*p = '\n')
-			log_level_unknown = 1;
+			new_text_line = 1;
 	}
 
 	/*
@@ -1172,8 +1152,11 @@ void register_console(struct console *console)
 			console->index = 0;
 		if (console->setup = NULL ||
 		    console->setup(console, NULL) = 0) {
-			console->flags |= CON_ENABLED | CON_CONSDEV;
-			preferred_console = 0;
+			console->flags |= CON_ENABLED;
+			if (console->device) {
+				console->flags |= CON_CONSDEV;
+				preferred_console = 0;
+			}
 		}
 	}
 
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 6021757..f60c7c0 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -22,6 +22,8 @@
 #include <linux/string.h>
 #include <linux/ctype.h>
 #include <linux/kernel.h>
+#include <linux/kallsyms.h>
+#include <linux/uaccess.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/div64.h>
@@ -482,6 +484,82 @@ static char *number(char *buf, char *end, unsigned long long num, int base, int
 	return buf;
 }
 
+static char *string(char *buf, char *end, char *s, int field_width, int precision, int flags)
+{
+	int len, i;
+
+	if ((unsigned long)s < PAGE_SIZE)
+		s = "<NULL>";
+
+	len = strnlen(s, precision);
+
+	if (!(flags & LEFT)) {
+		while (len < field_width--) {
+			if (buf < end)
+				*buf = ' ';
+			++buf;
+		}
+	}
+	for (i = 0; i < len; ++i) {
+		if (buf < end)
+			*buf = *s;
+		++buf; ++s;
+	}
+	while (len < field_width--) {
+		if (buf < end)
+			*buf = ' ';
+		++buf;
+	}
+	return buf;
+}
+
+static inline void *dereference_function_descriptor(void *ptr)
+{
+#if defined(CONFIG_IA64) || defined(CONFIG_PPC64)
+	void *p;
+	if (!probe_kernel_address(ptr, p))
+		ptr = p;
+#endif
+	return ptr;
+}
+
+
+/*
+ * Show a '%p' thing.  A kernel extension is that the '%p' is followed
+ * by an extra set of alphanumeric characters that are extended format
+ * specifiers.  Right now we just handle 'F' (for symbolic Function
+ * pointers) and 'S' (for Symbolic data pointers), but this can easily
+ * be extended in the future (network address types etc).
+ *
+ * The difference between 'S' and 'F' is that on ia64 and ppc64 function
+ * pointers are really function descriptors, which contain a pointer the
+ * real address. 
+ */
+static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int base, int size, int precision, int type)
+{
+	switch (*fmt) {
+	case 'F':
+		ptr = dereference_function_descriptor(ptr);
+		/* Fallthrough */
+	case 'S': {	/* Other (direct) pointer */
+#if CONFIG_KALLSYMS
+		char sym[KSYM_SYMBOL_LEN];
+		sprint_symbol(sym, (unsigned long) ptr);
+		return string(buf, end, sym, size, precision, type);
+#else
+		type |= SPECIAL;
+		break;
+#endif
+	}
+	}
+	type |= SMALL;
+	if (precision = -1) {
+		precision = 2*sizeof(void *);
+		type |= ZEROPAD;
+	}
+	return number(buf, end, (unsigned long long) ptr, base, size, precision, type);
+}
+
 /**
  * vsnprintf - Format a string and place it in a buffer
  * @buf: The buffer to place the result into
@@ -502,11 +580,9 @@ static char *number(char *buf, char *end, unsigned long long num, int base, int
  */
 int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
 {
-	int len;
 	unsigned long long num;
-	int i, base;
+	int base;
 	char *str, *end, c;
-	const char *s;
 
 	int flags;		/* flags to number() */
 
@@ -622,40 +698,16 @@ int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
 				continue;
 
 			case 's':
-				s = va_arg(args, char *);
-				if ((unsigned long)s < PAGE_SIZE)
-					s = "<NULL>";
-
-				len = strnlen(s, precision);
-
-				if (!(flags & LEFT)) {
-					while (len < field_width--) {
-						if (str < end)
-							*str = ' ';
-						++str;
-					}
-				}
-				for (i = 0; i < len; ++i) {
-					if (str < end)
-						*str = *s;
-					++str; ++s;
-				}
-				while (len < field_width--) {
-					if (str < end)
-						*str = ' ';
-					++str;
-				}
+				str = string(str, end, va_arg(args, char *), field_width, precision, flags);
 				continue;
 
 			case 'p':
-				flags |= SMALL;
-				if (field_width = -1) {
-					field_width = 2*sizeof(void *);
-					flags |= ZEROPAD;
-				}
-				str = number(str, end,
-						(unsigned long) va_arg(args, void *),
+				str = pointer(fmt+1, str, end,
+						va_arg(args, void *),
 						16, field_width, precision, flags);
+				/* Skip all alphanumeric pointer suffixes */
+				while (isalnum(fmt[1]))
+					fmt++;
 				continue;
 
 
