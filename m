From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Oct 2004 09:38:08 +0000
Subject: [patch] fix UP build
Message-Id: <200410060938.i969c8aj004600@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Looks like my __iomem patch from yesterday inadvertently broke UP
builds.  Patch below fixes it.

Thanks,

	--david

ia64: fix UP build

Put back a secondary declaration of ipi_base_addr in hardirq.h.  It
really is needed for UP builds and there doesn't seem to be an easy
way to avoid include-hell otherwise.

=== include/asm-ia64/hardirq.h 1.16 vs edited ==--- 1.16/include/asm-ia64/hardirq.h	2004-09-07 23:32:57 -07:00
+++ edited/include/asm-ia64/hardirq.h	2004-10-05 07:06:15 -07:00
@@ -60,4 +60,6 @@
 # error HARDIRQ_BITS is too low!
 #endif
 
+extern void __iomem *ipi_base_addr;
+
 #endif /* _ASM_IA64_HARDIRQ_H */
