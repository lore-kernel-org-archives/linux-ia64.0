From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 31 Oct 2001 19:41:58 +0000
Subject: Re: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805420@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 29 Oct 2001, David Mosberger wrote:

> 	- if there is a driver for a fine-grained machine timer, it can
> 	  use it

Right, and this should be some sort of generic interface that glibc can
count on, right?  I've been looking at the multimedia timer spec you
mentioned for ideas about how to implement it.
 
> Yup.  The driver interface needs to allow direct user-level access to
> the fine grained timer.  Though I'd say the interface should be able
> to accommodate hardware that can't map the timer into user space.

Ok, I'll keep that in mind.

Here's a patch against 2.4.13+ia64 to export the sal platform features to
a directory in /proc.  Please let me know if it's ok; I'll start working
on the clock driver if it is.

Thanks,
Jesse

diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.13-ia64/arch/ia64/kernel/Makefile linux-2.4.13-ia64-salinfo/arch/ia64/kernel/Makefile
--- linux-2.4.13-ia64/arch/ia64/kernel/Makefile	Wed Oct 31 11:25:04 2001
+++ linux-2.4.13-ia64-salinfo/arch/ia64/kernel/Makefile	Wed Oct 31 11:27:31 2001
@@ -15,7 +15,7 @@
 
 obj-y := acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_ia64.o irq_lsapic.o ivt.o \
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o	\
-	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
+	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o salinfo.o
 obj-$(CONFIG_IA64_GENERIC) += iosapic.o
 obj-$(CONFIG_IA64_DIG) += iosapic.o
 obj-$(CONFIG_IA64_PALINFO) += palinfo.o
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.13-ia64/arch/ia64/kernel/sal.c linux-2.4.13-ia64-salinfo/arch/ia64/kernel/sal.c
--- linux-2.4.13-ia64/arch/ia64/kernel/sal.c	Wed Oct 31 11:25:04 2001
+++ linux-2.4.13-ia64-salinfo/arch/ia64/kernel/sal.c	Wed Oct 31 11:29:00 2001
@@ -19,6 +19,7 @@
 #include <asm/pal.h>
 
 spinlock_t sal_lock = SPIN_LOCK_UNLOCKED;
+unsigned long sal_platform_features = 0;
 
 static struct {
 	void *addr;	/* function entry point */
@@ -154,11 +155,13 @@
 			      struct ia64_sal_desc_platform_feature *pf = (void *) p;
 			      printk("SAL: Platform features ");
 
-			      if (pf->feature_mask & (1 << 0))
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_BUS_LOCK) {
 				      printk("BusLock ");
-
-			      if (pf->feature_mask & (1 << 1)) {
+      				      sal_platform_features |= IA64_SAL_PLATFORM_FEATURE_BUS_LOCK;
+			      }
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT) {
 				      printk("IRQ_Redirection ");
+				      sal_platform_features |= IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT;
 #ifdef CONFIG_SMP
 				      if (no_int_routing)
 					      smp_int_redirect &= ~SMP_IRQ_REDIRECTION;
@@ -166,14 +169,19 @@
 					      smp_int_redirect |= SMP_IRQ_REDIRECTION;
 #endif
 			      }
-			      if (pf->feature_mask & (1 << 2)) {
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT) {
 				      printk("IPI_Redirection ");
+				      sal_platform_features |= IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT;
 #ifdef CONFIG_SMP
 				      if (no_int_routing) 
 					      smp_int_redirect &= ~SMP_IPI_REDIRECTION;
 				      else
 					      smp_int_redirect |= SMP_IPI_REDIRECTION;
 #endif
+			      }
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_ITC_MAY_DRIFT) {
+				      printk("ITC_may_drift ");
+				      sal_platform_features |= IA64_SAL_PLATFORM_FEATURE_ITC_MAY_DRIFT;
 			      }
 			      printk("\n");
 			      break;
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.13-ia64/arch/ia64/kernel/salinfo.c linux-2.4.13-ia64-salinfo/arch/ia64/kernel/salinfo.c
--- linux-2.4.13-ia64/arch/ia64/kernel/salinfo.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.13-ia64-salinfo/arch/ia64/kernel/salinfo.c	Wed Oct 31 11:36:35 2001
@@ -0,0 +1,104 @@
+/*
+ * salinfo.c
+ *
+ * Creates entries in /proc/sal for various system features.
+ *
+ * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
+ *
+ * 10/30/2001	jbarnes@sgi.com		copied much of Stephane's palinfo
+ *					code to create this file
+ */
+
+#include <linux/types.h>
+#include <linux/proc_fs.h>
+#include <linux/module.h>
+
+#include <asm/sal.h>
+
+MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
+MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
+
+int salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data);
+
+typedef struct {
+	const char		*name;		/* name of the proc entry */
+	unsigned long           feature;        /* feature bit */
+	struct proc_dir_entry	*entry;		/* registered entry (removal) */
+} salinfo_entry_t;
+
+/*
+ * List {name,feature} pairs for every entry in /proc/sal/<feature>
+ * that this module exports
+ */
+static salinfo_entry_t salinfo_entries[]={
+	{ "bus_lock",           IA64_SAL_PLATFORM_FEATURE_BUS_LOCK, },
+	{ "irq_redirection",	IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT, },
+	{ "ipi_redirection",	IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT, },
+	{ "itc_may_drift",	IA64_SAL_PLATFORM_FEATURE_ITC_MAY_DRIFT, },
+};
+
+#define NR_SALINFO_ENTRIES (sizeof(salinfo_entries)/sizeof(salinfo_entry_t))
+
+/*
+ * One for each feature and one more for the directory entry...
+ */
+static struct proc_dir_entry *salinfo_proc_entries[NR_SALINFO_ENTRIES + 1];
+
+static int __init
+salinfo_init(void)
+{
+	struct proc_dir_entry *salinfo_dir; /* /proc/sal dir entry */
+	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
+	int i;
+
+	salinfo_dir = proc_mkdir("sal", NULL);
+	
+	for (i=0; i < NR_SALINFO_ENTRIES; i++) {
+		/* pass the feature bit in question as misc data */
+		*sdir++ = create_proc_read_entry (salinfo_entries[i].name, 0, salinfo_dir,
+						  salinfo_read, (void *)salinfo_entries[i].feature);
+	}
+	*sdir++ = salinfo_dir;
+
+	return 0;
+}
+
+static void __exit
+salinfo_exit(void)
+{
+	int i = 0;
+
+	for (i = 0; i < NR_SALINFO_ENTRIES ; i++) {
+		if (salinfo_proc_entries[i])
+			remove_proc_entry (salinfo_proc_entries[i]->name, NULL);
+	}
+}
+
+/*
+ * 'data' contains an integer that corresponds to the feature we're
+ * testing
+ */
+int
+salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data)
+{
+	int len = 0;
+
+	MOD_INC_USE_COUNT;
+
+	len = sprintf(page, (sal_platform_features & (unsigned long)data) ? "1" : "0");
+
+	if (len <= off+count) *eof = 1;
+
+	*start = page + off;
+	len   -= off;
+
+	if (len>count) len = count;
+	if (len<0) len = 0;
+
+	MOD_DEC_USE_COUNT;
+
+	return len;
+}
+
+module_init(salinfo_init);
+module_exit(salinfo_exit);
diff -Naur --exclude=*~ --exclude=TAGS linux-2.4.13-ia64/include/asm-ia64/sal.h linux-2.4.13-ia64-salinfo/include/asm-ia64/sal.h
--- linux-2.4.13-ia64/include/asm-ia64/sal.h	Wed Oct 31 11:25:05 2001
+++ linux-2.4.13-ia64-salinfo/include/asm-ia64/sal.h	Wed Oct 31 11:32:32 2001
@@ -149,6 +149,7 @@
 #define IA64_SAL_PLATFORM_FEATURE_BUS_LOCK		(1 << 0)
 #define IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT	(1 << 1)
 #define IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT	(1 << 2)
+#define IA64_SAL_PLATFORM_FEATURE_ITC_MAY_DRIFT 	(1 << 3)
 
 typedef struct ia64_sal_desc_platform_feature {
 	u8 type;
@@ -775,5 +776,7 @@
 		*scratch_buf_size_needed = isrv.v1;
 	return isrv.status;
 }
+
+extern unsigned long sal_platform_features;
 
 #endif /* _ASM_IA64_PAL_H */




