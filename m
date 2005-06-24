From: Rusty Lynch <rusty.lynch@intel.com>
Date: Fri, 24 Jun 2005 16:58:06 +0000
Subject: [ia64][patch] Refuse inserting kprobe on slot 1 - take 2
Message-Id: <200506241658.j5OGw6Kj007412@linux.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, anil.s.keshavamurthy@intel.com

Without the ability to atomically write 16 bytes, we can not update the
middle slot of a bundle, slot 1, unless we stop the machine first.  This 
patch will ensure the ability to robustly insert and remove a kprobe by
refusing to insert a kprobe on slot 1 until a mechanism is in place to 
safely handle this case.

	--rusty

Signed-off-by: Rusty Lynch <rusty.lynch@intel.com>

 arch/ia64/kernel/kprobes.c |    7 +++++++
 1 files changed, 7 insertions(+)

Index: linux-2.6.12-mm1/arch/ia64/kernel/kprobes.c
=================================--- linux-2.6.12-mm1.orig/arch/ia64/kernel/kprobes.c
+++ linux-2.6.12-mm1/arch/ia64/kernel/kprobes.c
@@ -270,6 +270,13 @@ static int valid_kprobe_addr(int templat
 				addr);
 		return -EINVAL;
 	}
+
+	if (slot = 1 && bundle_encoding[template][1] != L) {
+		printk(KERN_WARNING "Inserting kprobes on slot #1 "
+		       "is not supported\n");
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
