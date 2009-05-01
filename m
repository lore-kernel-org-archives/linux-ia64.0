From: Tim Abbott <tabbott@MIT.EDU>
Date: Fri, 01 May 2009 00:04:03 +0000
Subject: [PATCH 1/5] ia64: Use .ref.text, not .text.init for start_ap.
Message-Id: <1241136247-10623-2-git-send-email-tabbott@mit.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1241136247-10623-1-git-send-email-tabbott@mit.edu>
In-Reply-To: <1241136247-10623-1-git-send-email-tabbott@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>, Anders Kaseorg <andersk@MIT.EDU>, Waseem Daher <wdaher@MIT.EDU>, Denys Vlasenko <vda.linux@googlemail.com>, Jeff Arnold <jbarnold@MIT.EDU>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Tim Abbott <tabbott@MIT.EDU>

It seems that start_ap doesn't need to be in a special location in the
kernel, but it references some init code so it should be in .ref.text.

Since this is the only thing in the .text.head section, eliminate
.text.head from the linker script.

Signed-off-by: Tim Abbott <tabbott@mit.edu>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/head.S        |    2 +-
 arch/ia64/kernel/vmlinux.lds.S |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 23f846d..8239ff6 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -181,7 +181,7 @@ swapper_pg_dir:
 halt_msg:
 	stringz "Halting kernel\n"
 
-	.section .text.head,"ax"
+	__REF
 
 	.global start_ap
 
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 4a95e86..fa3a558 100644
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
1.6.2.1

