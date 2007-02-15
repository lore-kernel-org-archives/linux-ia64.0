From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Thu, 15 Feb 2007 18:11:39 +0000
Subject: [PATCH] fault injection: split up stacktrace filter Kconfig option
Message-Id: <20070215181139.GA3811@APFDCB5C>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is no prompt for CONFIG_STACKTRACE, so
FAULT_INJECTION cannot be selected without LOCKDEP enabled.
(found by Paolo 'Blaisorblade' Giarrusso)

In order to fix such broken Kconfig dependency,
this patch splits up the stacktrace filter support for
fault injection by new Kconfig option, which enables
to use fault injection on the architecture which doesn't have
general stacktrace support.

Cc: "Paolo 'Blaisorblade' Giarrusso" <blaisorblade@yahoo.it>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

---
 lib/Kconfig.debug  |   10 ++++++++--
 lib/fault-inject.c |   41 +++++++++++++++++++++--------------------
 2 files changed, 29 insertions(+), 22 deletions(-)

Index: 2.6-git.orig/lib/Kconfig.debug
=================================--- 2.6-git.orig.orig/lib/Kconfig.debug
+++ 2.6-git.orig/lib/Kconfig.debug
@@ -400,8 +400,6 @@ config LKDTM
 config FAULT_INJECTION
 	bool "Fault-injection framework"
 	depends on DEBUG_KERNEL
-	depends on STACKTRACE
-	select FRAME_POINTER
 	help
 	  Provide fault-injection framework.
 	  For more details, see Documentation/fault-injection/.
@@ -429,3 +427,11 @@ config FAULT_INJECTION_DEBUG_FS
 	depends on FAULT_INJECTION && SYSFS && DEBUG_FS
 	help
 	  Enable configuration of fault-injection capabilities via debugfs.
+
+config FAULT_INJECTION_STACKTRACE_FILTER
+	bool "stacktrace filter for fault-injection capabilities"
+	depends on FAULT_INJECTION_DEBUG_FS && STACKTRACE_SUPPORT
+	select STACKTRACE
+	select FRAME_POINTER
+	help
+	  Provide stacktrace filter for fault-injection capabilities
Index: 2.6-git.orig/lib/fault-inject.c
=================================--- 2.6-git.orig.orig/lib/fault-inject.c
+++ 2.6-git.orig/lib/fault-inject.c
@@ -55,7 +55,7 @@ static bool fail_task(struct fault_attr 
 
 #define MAX_STACK_TRACE_DEPTH 32
 
-#if defined(CONFIG_STACKTRACE)
+#ifdef CONFIG_FAULT_INJECTION_STACKTRACE_FILTER
 
 static bool fail_stacktrace(struct fault_attr *attr)
 {
@@ -90,17 +90,10 @@ static bool fail_stacktrace(struct fault
 
 static inline bool fail_stacktrace(struct fault_attr *attr)
 {
-	static bool firsttime = true;
-
-	if (firsttime) {
-		printk(KERN_WARNING
-		"This architecture does not implement save_stack_trace()\n");
-		firsttime = false;
-	}
-	return false;
+	return true;
 }
 
-#endif
+#endif /* CONFIG_FAULT_INJECTION_STACKTRACE_FILTER */
 
 /*
  * This code is stolen from failmalloc-1.0
@@ -217,6 +210,8 @@ void cleanup_fault_attr_dentries(struct 
 	debugfs_remove(attr->dentries.task_filter_file);
 	attr->dentries.task_filter_file = NULL;
 
+#ifdef CONFIG_FAULT_INJECTION_STACKTRACE_FILTER
+
 	debugfs_remove(attr->dentries.stacktrace_depth_file);
 	attr->dentries.stacktrace_depth_file = NULL;
 
@@ -232,6 +227,8 @@ void cleanup_fault_attr_dentries(struct 
 	debugfs_remove(attr->dentries.reject_end_file);
 	attr->dentries.reject_end_file = NULL;
 
+#endif /* CONFIG_FAULT_INJECTION_STACKTRACE_FILTER */
+
 	if (attr->dentries.dir)
 		WARN_ON(!simple_empty(attr->dentries.dir));
 
@@ -269,6 +266,13 @@ int init_fault_attr_dentries(struct faul
 	attr->dentries.task_filter_file = debugfs_create_bool("task-filter",
 						mode, dir, &attr->task_filter);
 
+	if (!attr->dentries.probability_file || !attr->dentries.interval_file ||
+	    !attr->dentries.times_file || !attr->dentries.space_file ||
+	    !attr->dentries.verbose_file || !attr->dentries.task_filter_file)
+		goto fail;
+
+#ifdef CONFIG_FAULT_INJECTION_STACKTRACE_FILTER
+
 	attr->dentries.stacktrace_depth_file  		debugfs_create_ul_MAX_STACK_TRACE_DEPTH(
 			"stacktrace-depth", mode, dir, &attr->stacktrace_depth);
@@ -285,18 +289,15 @@ int init_fault_attr_dentries(struct faul
 	attr->dentries.reject_end_file  		debugfs_create_ul("reject-end", mode, dir, &attr->reject_end);
 
-
-	if (!attr->dentries.probability_file || !attr->dentries.interval_file
-	    || !attr->dentries.times_file || !attr->dentries.space_file
-	    || !attr->dentries.verbose_file || !attr->dentries.task_filter_file
-	    || !attr->dentries.stacktrace_depth_file
-	    || !attr->dentries.require_start_file
-	    || !attr->dentries.require_end_file
-	    || !attr->dentries.reject_start_file
-	    || !attr->dentries.reject_end_file
-	    )
+	if (!attr->dentries.stacktrace_depth_file ||
+	    !attr->dentries.require_start_file ||
+	    !attr->dentries.require_end_file ||
+	    !attr->dentries.reject_start_file ||
+	    !attr->dentries.reject_end_file)
 		goto fail;
 
+#endif /* CONFIG_FAULT_INJECTION_STACKTRACE_FILTER */
+
 	return 0;
 fail:
 	cleanup_fault_attr_dentries(attr);
