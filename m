From: Tim Abbott <tabbott@ksplice.com>
Date: Wed, 16 Sep 2009 16:42:42 +0000
Subject: [PATCH v2 1/3] ia64: Use .ref.text, not .text.init for start_ap.
Message-Id: <1253119364-19359-2-git-send-email-tabbott@ksplice.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253119364-19359-1-git-send-email-tabbott@ksplice.com>
In-Reply-To: <1253119364-19359-1-git-send-email-tabbott@ksplice.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>, Tim Abbott <tabbott@ksplice.com>

It seems that start_ap doesn't need to be in a special location in the
kernel, but it references some init code so it should be in .ref.text.

Since this is the only thing in the .text.head section, eliminate
.text.head from the linker script.

Signed-off-by: Tim Abbott <tabbott@ksplice.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/head.S        |    2 +-
 arch/ia64/kernel/vmlinux.lds.S |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index e6c5c3d..07c7efb 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -182,7 +182,7 @@ swapper_pg_dir:
 halt_msg:
 	stringz "Halting kernel\n"
 
-	.section .text.head,"ax"
+	__REF
 
 	.global start_ap
 
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index eb4214d..e7a040e 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -51,8 +51,6 @@ SECTIONS
 	KPROBES_TEXT
 	*(.gnu.linkonce.t*)
     }
-  .text.head : AT(ADDR(.text.head) - LOAD_OFFSET)
-	{ *(.text.head) }
   .text2 : AT(ADDR(.text2) - LOAD_OFFSET)
 	{ *(.text2) }
 #ifdef CONFIG_SMP
-- 
1.6.3.3

