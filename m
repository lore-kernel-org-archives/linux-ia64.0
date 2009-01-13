From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 06:11:14 +0000
Subject: [PATCH 4/9] ftrace, ia64: Add recordmcount for ia64
Message-Id: <20090113061147.742218543@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de, Steven Rostedt <srostedt@redhat.com>

From: Shaohua Li <shaohua.li@intel.com>

Add recordmcount for ia64.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 scripts/recordmcount.pl |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/scripts/recordmcount.pl b/scripts/recordmcount.pl
index 070042b..2ded5c8 100755
--- a/scripts/recordmcount.pl
+++ b/scripts/recordmcount.pl
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
-- 
1.5.6.5

-- 
