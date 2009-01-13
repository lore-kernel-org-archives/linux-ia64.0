From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 06:11:11 +0000
Subject: [PATCH 1/9] ftrace, ia64: make recordmcount destinct module compile
Message-Id: <20090113061147.147906400@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de, Steven Rostedt <srostedt@redhat.com>

From: Shaohua Li <shaohua.li@intel.com>

In IA64, module build and kernel build use different option.
Make recordmcount.pl differentiate the two cases.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Acked-by: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 scripts/Makefile.build  |   13 +++++++------
 scripts/recordmcount.pl |    6 +++---
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 5d90030..b5efa98 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -112,13 +112,13 @@ endif
 # ---------------------------------------------------------------------------
 
 # Default is built-in, unless we know otherwise
-modkern_cflags := $(CFLAGS_KERNEL)
+modkern_cflags = $(if $(part-of-module), $(CFLAGS_MODULE), $(CFLAGS_KERNEL))
 quiet_modtag := $(empty)   $(empty)
 
-$(real-objs-m)        : modkern_cflags := $(CFLAGS_MODULE)
-$(real-objs-m:.o=.i)  : modkern_cflags := $(CFLAGS_MODULE)
-$(real-objs-m:.o=.s)  : modkern_cflags := $(CFLAGS_MODULE)
-$(real-objs-m:.o=.lst): modkern_cflags := $(CFLAGS_MODULE)
+$(real-objs-m)        : part-of-module := y
+$(real-objs-m:.o=.i)  : part-of-module := y
+$(real-objs-m:.o=.s)  : part-of-module := y
+$(real-objs-m:.o=.lst): part-of-module := y
 
 $(real-objs-m)        : quiet_modtag := [M]
 $(real-objs-m:.o=.i)  : quiet_modtag := [M]
@@ -215,7 +215,8 @@ endif
 ifdef CONFIG_FTRACE_MCOUNT_RECORD
 cmd_record_mcount = perl $(srctree)/scripts/recordmcount.pl "$(ARCH)" \
 	"$(if $(CONFIG_64BIT),64,32)" \
-	"$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" "$(NM)" "$(RM)" "$(MV)" "$(@)";
+	"$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" "$(NM)" "$(RM)" "$(MV)" \
+	"$(if $(part-of-module),1,0)" "$(@)";
 endif
 
 define rule_cc_o_c
diff --git a/scripts/recordmcount.pl b/scripts/recordmcount.pl
index fe83141..282485a 100755
--- a/scripts/recordmcount.pl
+++ b/scripts/recordmcount.pl
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
-- 
1.5.6.5

-- 
