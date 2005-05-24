From: Rusty Lynch <rusty.lynch@intel.com>
Date: Tue, 24 May 2005 01:04:13 +0000
Subject: [patch 1/1] Add missing jprobe macro for ia64
Message-Id: <200505240104.j4O14Deh016713@linux.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org
Cc: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Rusty Lynch <rusty.lynch@intel.com>

The following minimal patch adds a missing macro that is expected
from each architecture supporting Jprobes, but was left out of
this mornings ia64 support patches.  This patch applies to all the 
previous kprobes patches that have already made it into your next 
mm series.

    --rusty

signed-off-by: Rusty Lynch <Rusty.lynch@intel.com>

 include/asm-ia64/kprobes.h |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-2.6.12-rc4/include/asm-ia64/kprobes.h
=================================--- linux-2.6.12-rc4.orig/include/asm-ia64/kprobes.h
+++ linux-2.6.12-rc4/include/asm-ia64/kprobes.h
@@ -53,6 +53,8 @@ typedef struct _bundle {
 #define LONG_BRANCH_OPCODE		(0xC)
 #define LONG_CALL_OPCODE		(0xD)
 
+#define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)pentry
+
 typedef struct kprobe_opcode {
 	bundle_t bundle;
 } kprobe_opcode_t;
