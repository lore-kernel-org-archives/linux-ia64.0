From: Grant Grundler <iod00d@hp.com>
Date: Thu, 16 Oct 2003 19:29:58 +0000
Subject: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106633278923482@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

CONFIG_CRYPTO requires asm/kmaps_types.h.
patch below clones kmap_types.h from asm-i386.

This doesn't feel like a great solution.
Willy suggested the right fix might be to not require all arches to
provide asm/kmap_types.h.  I'll let the folks who know WTH kmap_types.h
is really for debate and submit this with the hope of getting the
ia64-linux to build with CONFIG_CRYPTO.

grant


diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-ia64-2.4-orig/include/asm-ia64/kmap_types.h linux-ia64-2.4/include/asm-ia64/kmap_types.h
--- linux-ia64-2.4-orig/include/asm-ia64/kmap_types.h	Wed Dec 31 16:00:00 1969
+++ linux-ia64-2.4/include/asm-ia64/kmap_types.h	Thu Oct 16 08:29:53 2003
@@ -0,0 +1,16 @@
+#ifndef _ASM_KMAP_TYPES_H
+#define _ASM_KMAP_TYPES_H
+
+enum km_type {
+	KM_BOUNCE_READ,
+	KM_SKB_SUNRPC_DATA,
+	KM_SKB_DATA_SOFTIRQ,
+	KM_USER0,
+	KM_USER1,
+	KM_BH_IRQ,
+	KM_SOFTIRQ0,
+	KM_SOFTIRQ1,
+	KM_TYPE_NR
+};
+
+#endif
