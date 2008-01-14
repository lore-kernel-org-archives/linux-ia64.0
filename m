From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 14 Jan 2008 02:24:24 +0000
Subject: [PATCH] Fix kprobes on ia64
Message-Id: <20080114022423.GH18741@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>


If CONFIG_KPROBES is set, we get the error during build:

kernel/kprobes.c:1057: error: __ksymtab_jprobe_return causes a section
type conflict

This is because ia64 defines a static inline jprobe_return which kprobes
attempts to EXPORT_SYMBOL.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index e3a5d81..ecc25b3 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1053,11 +1053,11 @@ EXPORT_SYMBOL_GPL(register_kprobe);
 EXPORT_SYMBOL_GPL(unregister_kprobe);
 EXPORT_SYMBOL_GPL(register_jprobe);
 EXPORT_SYMBOL_GPL(unregister_jprobe);
+
 #ifdef CONFIG_KPROBES
+#ifndef __ia64__ /* It's static inline */
 EXPORT_SYMBOL_GPL(jprobe_return);
 #endif
-
-#ifdef CONFIG_KPROBES
 EXPORT_SYMBOL_GPL(register_kretprobe);
 EXPORT_SYMBOL_GPL(unregister_kretprobe);
 #endif

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
