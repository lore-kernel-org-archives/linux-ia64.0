From: Shaohua Li <shaohua.li@intel.com>
Date: Fri, 09 Jan 2009 02:32:52 +0000
Subject: [PATCH 2/6]explictly ignore a file in recordmcount.pl
Message-Id: <1231468372.10683.101.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In IA64, a function pointer isn't a 'unsigned long' but a
'struct {unsigned long ip, unsigned long gp}'. MCOUNT_ADDR is determined
at link time not compile time, so explictly ignore kernel/trace/ftrace.o
in recordmcount.pl.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 kernel/trace/ftrace.c   |   10 +---------
 scripts/recordmcount.pl |    5 +++++
 2 files changed, 6 insertions(+), 9 deletions(-)

Index: linux/kernel/trace/ftrace.c
=================================--- linux.orig/kernel/trace/ftrace.c	2009-01-09 09:52:01.000000000 +0800
+++ linux/kernel/trace/ftrace.c	2009-01-09 09:52:43.000000000 +0800
@@ -263,14 +263,6 @@ static void ftrace_update_pid_func(void)
 # error Dynamic ftrace depends on MCOUNT_RECORD
 #endif
 
-/*
- * Since MCOUNT_ADDR may point to mcount itself, we do not want
- * to get it confused by reading a reference in the code as we
- * are parsing on objcopy output of text. Use a variable for
- * it instead.
- */
-static unsigned long mcount_addr = MCOUNT_ADDR;
-
 enum {
 	FTRACE_ENABLE_CALLS		= (1 << 0),
 	FTRACE_DISABLE_CALLS		= (1 << 1),
@@ -575,7 +567,7 @@ ftrace_code_disable(struct module *mod, 
 
 	ip = rec->ip;
 
-	ret = ftrace_make_nop(mod, rec, mcount_addr);
+	ret = ftrace_make_nop(mod, rec, MCOUNT_ADDR);
 	if (ret) {
 		ftrace_bug(ret, ip);
 		rec->flags |= FTRACE_FL_FAILED;
Index: linux/scripts/recordmcount.pl
=================================--- linux.orig/scripts/recordmcount.pl	2009-01-09 09:52:36.000000000 +0800
+++ linux/scripts/recordmcount.pl	2009-01-09 09:52:43.000000000 +0800
@@ -109,6 +109,11 @@ if ($#ARGV < 7) {
 my ($arch, $bits, $objdump, $objcopy, $cc,
     $ld, $nm, $rm, $mv, $is_module, $inputfile) = @ARGV;
 
+# This file refers to mcount and shouldn't be ftraced, so let's ignore it
+if ($inputfile eq "kernel/trace/ftrace.o") {
+    exit(0);
+}
+
 # Acceptable sections to record.
 my %text_sections = (
      ".text" => 1,


