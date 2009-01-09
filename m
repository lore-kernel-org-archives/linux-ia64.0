From: Shaohua Li <shaohua.li@intel.com>
Date: Fri, 09 Jan 2009 02:32:59 +0000
Subject: [PATCH 4/6]Add recordmcount for ia64
Message-Id: <1231468379.10683.103.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add recordmcount for ia64.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 scripts/recordmcount.pl |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux/scripts/recordmcount.pl
=================================--- linux.orig/scripts/recordmcount.pl	2009-01-09 09:53:56.000000000 +0800
+++ linux/scripts/recordmcount.pl	2009-01-09 09:55:55.000000000 +0800
@@ -206,6 +206,13 @@ if ($arch eq "x86_64") {
     $alignment = 2;
     $section_type = '%progbits';
 
+} elsif ($arch eq "ia64") {
+    $mcount_regex = "^\\s*([0-9a-fA-F]+):.*\\s_mcount\$";
+    $type = "data8";
+
+    if ($is_module eq "0") {
+        $cc .= " -mconstant-gp";
+    }
 } else {
     die "Arch $arch is not supported with CONFIG_FTRACE_MCOUNT_RECORD";
 }


