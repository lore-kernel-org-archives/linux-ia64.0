From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 12 Dec 2001 00:17:50 +0000
Subject: Re: [Linux-ia64] updated salinfo patch
Message-Id: <marc-linux-ia64-105590698805687@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805685@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805685@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for the feedback.  Here's another one.

Jesse

On Wed, Dec 12, 2001 at 11:13:07AM +1100, Keith Owens wrote:
> On Tue, 11 Dec 2001 16:01:36 -0800, 
> Jesse Barnes <jbarnes@sgi.com> wrote:
> >+MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
> >+MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
> 
> Better add MODULE_LICENSE("GPL");
> 
> >+int salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data);
> 
> Is there any reason to expose salinfo_read, AFAICT it can be static.
> If you want to expose that function, you need EXPORT_SYMBOL(salinfo_read)
> and salinfo.o must be added to export-objs.


diff -Naur linux-2.4.16-ia64/arch/ia64/kernel/Makefile linux-2.4.16-salinfo/arch/ia64/kernel/Makefile
--- linux-2.4.16-ia64/arch/ia64/kernel/Makefile	Fri Nov  9 14:26:17 2001
+++ linux-2.4.16-salinfo/arch/ia64/kernel/Makefile	Tue Dec 11 15:45:48 2001
@@ -15,7 +15,7 @@
 
 obj-y := acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_ia64.o irq_lsapic.o ivt.o \
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o	\
-	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
+	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o salinfo.o
 obj-$(CONFIG_IA64_GENERIC) += iosapic.o
 obj-$(CONFIG_IA64_DIG) += iosapic.o
 obj-$(CONFIG_IA64_PALINFO) += palinfo.o
diff -Naur linux-2.4.16-ia64/arch/ia64/kernel/sal.c linux-2.4.16-salinfo/arch/ia64/kernel/sal.c
--- linux-2.4.16-ia64/arch/ia64/kernel/sal.c	Fri Nov  9 14:26:17 2001
+++ linux-2.4.16-salinfo/arch/ia64/kernel/sal.c	Tue Dec 11 15:58:39 2001
@@ -19,6 +19,7 @@
 #include <asm/pal.h>
 
 spinlock_t sal_lock = SPIN_LOCK_UNLOCKED;
+unsigned long sal_platform_features = 0;
 
 static struct {
 	void *addr;	/* function entry point */
@@ -152,12 +153,12 @@
 		      case SAL_DESC_PLATFORM_FEATURE:
 		      {
 			      struct ia64_sal_desc_platform_feature *pf = (void *) p;
+			      sal_platform_features = pf->feature_mask;
 			      printk("SAL: Platform features ");
 
-			      if (pf->feature_mask & (1 << 0))
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_BUS_LOCK)
 				      printk("BusLock ");
-
-			      if (pf->feature_mask & (1 << 1)) {
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT) {
 				      printk("IRQ_Redirection ");
 #ifdef CONFIG_SMP
 				      if (no_int_routing)
@@ -166,7 +167,7 @@
 					      smp_int_redirect |= SMP_IRQ_REDIRECTION;
 #endif
 			      }
-			      if (pf->feature_mask & (1 << 2)) {
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT) {
 				      printk("IPI_Redirection ");
 #ifdef CONFIG_SMP
 				      if (no_int_routing) 
@@ -175,6 +176,8 @@
 					      smp_int_redirect |= SMP_IPI_REDIRECTION;
 #endif
 			      }
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_ITC_MAY_DRIFT)
+				      printk("ITC_may_drift ");
 			      printk("\n");
 			      break;
  		      }
diff -Naur linux-2.4.16-ia64/arch/ia64/kernel/salinfo.c linux-2.4.16-salinfo/arch/ia64/kernel/salinfo.c
--- linux-2.4.16-ia64/arch/ia64/kernel/salinfo.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.16-salinfo/arch/ia64/kernel/salinfo.c	Tue Dec 11 16:16:48 2001
@@ -0,0 +1,105 @@
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
+MODULE_LICENSE("GPL");
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
+static int
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
diff -Naur linux-2.4.16-ia64/include/asm-ia64/sal.h linux-2.4.16-salinfo/include/asm-ia64/sal.h
--- linux-2.4.16-ia64/include/asm-ia64/sal.h	Fri Nov  9 14:26:17 2001
+++ linux-2.4.16-salinfo/include/asm-ia64/sal.h	Tue Dec 11 15:45:48 2001
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

