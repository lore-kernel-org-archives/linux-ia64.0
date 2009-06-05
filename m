From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 05 Jun 2009 15:20:02 +0000
Subject: Re: [Patch 4/5] module: trim exception table in module_free()
Message-Id: <200906060038.03089.rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090604014813.6332.18486.sendpatchset@localhost.localdomain> <200906041800.54696.rusty@rustcorp.com.au> <4A278C62.8000801@redhat.com>
In-Reply-To: <4A278C62.8000801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, jdike@addtoit.com, hch@infradead.org, mingo@elte.hu, akpm@linux-foundation.org, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 4 Jun 2009 06:27:06 pm Amerigo Wang wrote:
> Rusty Russell wrote:
> > I've taken this one to make it more generic.  I'll leave the x86
> > maintainers to apply the rest.
>
> Thank you. But this one depends on the previous, I don't think you can
> apply this without the previous ones.

Here's what I ended up with: I need to rig up a test and make sure it goes to
all the maintainers and linux-next.

Subject: module: trim exception table on init free.

It's theoretically possible that there are exception table entries
which point into the (freed) init text of modules.  These could cause
future problems if other modules get loaded into that memory and cause
an exception as we'd see the wrong fixup.

Amerigo fixed this long-standing FIXME in the x86 version, but this
patch is more general.

This implements trim_init_extable(); most archs are simple since they
use the standard lib/extable.c sort code.  Alpha and IA64 use relative
addresses in their fixups, so thier trimming is a slight variation.

Sparc32 is unique; it doesn't seem to define ARCH_HAS_SORT_EXTABLE,
yet it defines its own sort_extable() which overrides the one in lib.
It doesn't sort, so we have to mark deleted entries instead of
actually trimming them.

Inspired-by: Amerigo Wang <amwang@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 arch/alpha/mm/extable.c             |   19 +++++++++++++++++++
 arch/ia64/mm/extable.c              |   24 ++++++++++++++++++++++++
 arch/sparc/include/asm/uaccess_32.h |    3 +++
 arch/sparc/mm/extable.c             |   27 +++++++++++++++++++++++++++
 include/linux/module.h              |    1 +
 kernel/module.c                     |    1 +
 lib/extable.c                       |   17 +++++++++++++++++
 7 files changed, 92 insertions(+)

diff --git a/arch/alpha/mm/extable.c b/arch/alpha/mm/extable.c
--- a/arch/alpha/mm/extable.c
+++ b/arch/alpha/mm/extable.c
@@ -48,6 +48,25 @@ void sort_extable(struct exception_table
 	     cmp_ex, swap_ex);
 }
 
+/*
+ * Any entry referring to the module init will be at the beginning or
+ * the end.
+ */
+void trim_init_extable(struct module *m)
+{
+	/*trim the beginning*/
+	while (m->num_exentries &&
+	       within_module_init(ex_to_addr(&m->extable[0]), m)) {
+		m->extable++;
+		m->num_exentries--;
+	}
+	/*trim the end*/
+	while (m->num_exentries &&
+	       within_module_init(ex_to_addr(&m->extable[m->num_exentries-1]),
+				  m))
+		m->num_exentries--;
+}
+
 const struct exception_table_entry *
 search_extable(const struct exception_table_entry *first,
 	       const struct exception_table_entry *last,
diff --git a/arch/ia64/mm/extable.c b/arch/ia64/mm/extable.c
--- a/arch/ia64/mm/extable.c
+++ b/arch/ia64/mm/extable.c
@@ -53,6 +53,30 @@ void sort_extable (struct exception_tabl
 	     cmp_ex, swap_ex);
 }
 
+static inline unsigned long ex_to_addr(const struct exception_table_entry *x)
+{
+	return (unsigned long)&x->insn + x->insn;
+}
+
+/*
+ * Any entry referring to the module init will be at the beginning or
+ * the end.
+ */
+void trim_init_extable(struct module *m)
+{
+	/*trim the beginning*/
+	while (m->num_exentries &&
+	       within_module_init(ex_to_addr(&m->extable[0]), m)) {
+		m->extable++;
+		m->num_exentries--;
+	}
+	/*trim the end*/
+	while (m->num_exentries &&
+	       within_module_init(ex_to_addr(&m->extable[m->num_exentries-1]),
+				  m))
+		m->num_exentries--;
+}
+
 const struct exception_table_entry *
 search_extable (const struct exception_table_entry *first,
 		const struct exception_table_entry *last,
diff --git a/arch/sparc/include/asm/uaccess_32.h b/arch/sparc/include/asm/uaccess_32.h
--- a/arch/sparc/include/asm/uaccess_32.h
+++ b/arch/sparc/include/asm/uaccess_32.h
@@ -17,6 +17,9 @@
 
 #ifndef __ASSEMBLY__
 
+#define ARCH_HAS_SORT_EXTABLE
+#define ARCH_HAS_SEARCH_EXTABLE
+
 /* Sparc is not segmented, however we need to be able to fool access_ok()
  * when doing system calls from kernel mode legitimately.
  *
diff --git a/arch/sparc/mm/extable.c b/arch/sparc/mm/extable.c
--- a/arch/sparc/mm/extable.c
+++ b/arch/sparc/mm/extable.c
@@ -28,6 +28,10 @@ search_extable(const struct exception_ta
 	 *	word 3: last insn address + 4 bytes
 	 *	word 4: fixup code address
 	 *
+	 * Deleted entries are encoded as:
+	 *	word 1: unused
+	 *	word 2: -1
+	 *
 	 * See asm/uaccess.h for more details.
 	 */
 
@@ -39,6 +43,10 @@ search_extable(const struct exception_ta
 			continue;
 		}
 
+		/* A deleted entry; see trim_init_extable */
+		if (walk->fixup = -1)
+			continue;
+
 		if (walk->insn = value)
 			return walk;
 	}
@@ -57,6 +65,25 @@ search_extable(const struct exception_ta
         return NULL;
 }
 
+/* We could memmove them around; easier to mark the trimmed ones. */
+void trim_init_extable(struct module *m)
+{
+	unsigned int i;
+	bool range;
+
+	for (i = 0; i < m->num_exentries; i += range ? 2 : 1) {
+		range = m->extable[i].fixup = 0;
+
+		if (within_module_init(m->extable[i].insn)) {
+			m->extable[i].fixup = -1;
+			if (range)
+				m->extable[i+1].fixup = -1;
+		}
+		if (range)
+			i++;
+	}
+}
+
 /* Special extable search, which handles ranges.  Returns fixup */
 unsigned long search_extables_range(unsigned long addr, unsigned long *g2)
 {
diff --git a/include/linux/module.h b/include/linux/module.h
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -77,6 +77,7 @@ search_extable(const struct exception_ta
 void sort_extable(struct exception_table_entry *start,
 		  struct exception_table_entry *finish);
 void sort_main_extable(void);
+void trim_init_extable(struct module *m);
 
 #ifdef MODULE
 #define MODULE_GENERIC_TABLE(gtype,name)			\
diff --git a/kernel/module.c b/kernel/module.c
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2394,6 +2394,7 @@ SYSCALL_DEFINE3(init_module, void __user
 	mutex_lock(&module_mutex);
 	/* Drop initial reference. */
 	module_put(mod);
+	trim_init_extable(mod);
 	module_free(mod, mod->module_init);
 	mod->module_init = NULL;
 	mod->init_size = 0;
diff --git a/lib/extable.c b/lib/extable.c
--- a/lib/extable.c
+++ b/lib/extable.c
@@ -39,6 +39,23 @@ void sort_extable(struct exception_table
 	sort(start, finish - start, sizeof(struct exception_table_entry),
 	     cmp_ex, NULL);
 }
+
+/*
+ * If the exception table is sorted, any referring to the module init
+ * will be at the beginning or the end.
+ */
+void trim_init_extable(struct module *m)
+{
+	/*trim the beginning*/
+	while (m->num_exentries && within_module_init(m->extable[0].insn, m)) {
+		m->extable++;
+		m->num_exentries--;
+	}
+	/*trim the end*/
+	while (m->num_exentries &&
+		within_module_init(m->extable[m->num_exentries-1].insn, m))
+		m->num_exentries--;
+}
 #endif
 
 #ifndef ARCH_HAS_SEARCH_EXTABLE

