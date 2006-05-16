From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 16 May 2006 23:34:57 +0000
Subject: [patch] one-line cleanup on set_irq_affinity_info
Message-Id: <4t153d$13mv2l@azsmga001.ch.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Calls to set_irq_info in set_irq_affinity_info() is redundant because
irq_affinity mask was set just one line immediately above it.  Remove
that duplicate call.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/kernel/irq.c.orig	2006-05-16 17:13:23.000000000 -0700
+++ ./arch/ia64/kernel/irq.c	2006-05-16 17:22:11.000000000 -0700
@@ -101,7 +101,6 @@ void set_irq_affinity_info (unsigned int
 
 	if (irq < NR_IRQS) {
 		irq_affinity[irq] = mask;
-		set_irq_info(irq, mask);
 		irq_redir[irq] = (char) (redir & 0xff);
 	}
 }

