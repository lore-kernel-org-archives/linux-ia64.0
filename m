From: Shaohua Li <shaohua.li@intel.com>
Date: Fri, 09 Jan 2009 02:32:56 +0000
Subject: [PATCH 3/6]Add macro for ftrace_caller
Message-Id: <1231468376.10683.102.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The same reason as last patch (function isn't a 'unsigned long').
Define FTRACE_ADDR.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 include/linux/ftrace.h |    4 ++++
 kernel/trace/ftrace.c  |    2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

Index: linux/include/linux/ftrace.h
=================================--- linux.orig/include/linux/ftrace.h	2009-01-09 09:52:01.000000000 +0800
+++ linux/include/linux/ftrace.h	2009-01-09 09:52:56.000000000 +0800
@@ -126,6 +126,10 @@ extern int ftrace_update_ftrace_func(ftr
 extern void ftrace_caller(void);
 extern void ftrace_call(void);
 extern void mcount_call(void);
+
+#ifndef FTRACE_ADDR
+#define FTRACE_ADDR ((unsigned long)ftrace_caller)
+#endif
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
 extern void ftrace_graph_caller(void);
 extern int ftrace_enable_ftrace_graph_caller(void);
Index: linux/kernel/trace/ftrace.c
=================================--- linux.orig/kernel/trace/ftrace.c	2009-01-09 09:52:43.000000000 +0800
+++ linux/kernel/trace/ftrace.c	2009-01-09 09:52:56.000000000 +0800
@@ -455,7 +455,7 @@ __ftrace_replace_code(struct dyn_ftrace 
 	unsigned long ip, fl;
 	unsigned long ftrace_addr;
 
-	ftrace_addr = (unsigned long)ftrace_caller;
+	ftrace_addr = (unsigned long)FTRACE_ADDR;
 
 	ip = rec->ip;
 


