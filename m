From: Shaohua Li <shaohua.li@intel.com>
Date: Fri, 09 Jan 2009 02:32:48 +0000
Subject: [PATCH 1/6]Make recordmcount destinct module compile
Message-Id: <1231468368.10683.100.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In IA64, module build and kernel build use different option.
Make recordmcount.pl differentiate the two cases.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 scripts/Makefile.build  |    9 ++++++++-
 scripts/recordmcount.pl |    6 +++---
 2 files changed, 11 insertions(+), 4 deletions(-)

Index: linux/scripts/Makefile.build
=================================--- linux.orig/scripts/Makefile.build	2009-01-09 09:52:01.000000000 +0800
+++ linux/scripts/Makefile.build	2009-01-09 09:52:36.000000000 +0800
@@ -114,6 +114,7 @@ endif
 # Default is built-in, unless we know otherwise
 modkern_cflags := $(CFLAGS_KERNEL)
 quiet_modtag := $(empty)   $(empty)
+is_module := 0
 
 $(real-objs-m)        : modkern_cflags := $(CFLAGS_MODULE)
 $(real-objs-m:.o=.i)  : modkern_cflags := $(CFLAGS_MODULE)
@@ -125,6 +126,11 @@ $(real-objs-m:.o=.i)  : quiet_modtag := 
 $(real-objs-m:.o=.s)  : quiet_modtag := [M]
 $(real-objs-m:.o=.lst): quiet_modtag := [M]
 
+$(real-objs-m)        : is_module := 1
+$(real-objs-m:.o=.i)  : is_module := 1
+$(real-objs-m:.o=.s)  : is_module := 1
+$(real-objs-m:.o=.lst): is_module := 1
+
 $(obj-m)              : quiet_modtag := [M]
 
 # Default for not multi-part modules
@@ -201,7 +207,8 @@ endif
 ifdef CONFIG_FTRACE_MCOUNT_RECORD
 cmd_record_mcount = perl $(srctree)/scripts/recordmcount.pl "$(ARCH)" \
 	"$(if $(CONFIG_64BIT),64,32)" \
-	"$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" "$(NM)" "$(RM)" "$(MV)" "$(@)";
+	"$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" "$(NM)" "$(RM)" "$(MV)" \
+	"$(is_module)" "$(@)";
 endif
 
 define rule_cc_o_c
Index: linux/scripts/recordmcount.pl
=================================--- linux.orig/scripts/recordmcount.pl	2009-01-08 16:09:59.000000000 +0800
+++ linux/scripts/recordmcount.pl	2009-01-09 09:52:36.000000000 +0800
@@ -100,14 +100,14 @@ $P =~ s@.*/@@g;
 
 my $V = '0.1';
 
-if ($#ARGV < 6) {
-	print "usage: $P arch objdump objcopy cc ld nm rm mv inputfile\n";
+if ($#ARGV < 7) {
+	print "usage: $P arch objdump objcopy cc ld nm rm mv is_module inputfile\n";
 	print "version: $V\n";
 	exit(1);
 }
 
 my ($arch, $bits, $objdump, $objcopy, $cc,
-    $ld, $nm, $rm, $mv, $inputfile) = @ARGV;
+    $ld, $nm, $rm, $mv, $is_module, $inputfile) = @ARGV;
 
 # Acceptable sections to record.
 my %text_sections = (


