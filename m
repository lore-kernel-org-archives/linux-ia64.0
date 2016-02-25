From: David Daney <ddaney.cavm@gmail.com>
Date: Thu, 25 Feb 2016 00:02:08 +0000
Subject: [PATCH 2/2] numa, mm, cleanup: remove redundant NODE_DATA macro from asm header files.
Message-Id: <1456358528-24213-3-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456358528-24213-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1456358528-24213-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@ezchip.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s39
Cc: linux-kernel@vger.kernel.org, Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, David Daney <david.daney@cavium.com>

From: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>

NODE_DATA is defined across multiple asm header files.
Moving generic definition to asm-generic/mmzone.h to
remove redundant definitions.

Reviewed-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/arm64/include/asm/mmzone.h   |  4 +---
 arch/m32r/include/asm/mmzone.h    |  4 +---
 arch/metag/include/asm/mmzone.h   |  4 +---
 arch/powerpc/include/asm/mmzone.h |  8 ++------
 arch/s390/include/asm/mmzone.h    |  6 +-----
 arch/sh/include/asm/mmzone.h      |  4 +---
 arch/sparc/include/asm/mmzone.h   |  6 ++----
 arch/x86/include/asm/mmzone.h     |  3 +--
 arch/x86/include/asm/mmzone_32.h  |  5 -----
 arch/x86/include/asm/mmzone_64.h  | 17 -----------------
 include/asm-generic/mmzone.h      | 24 ++++++++++++++++++++++++
 11 files changed, 34 insertions(+), 51 deletions(-)
 delete mode 100644 arch/x86/include/asm/mmzone_64.h
 create mode 100644 include/asm-generic/mmzone.h

diff --git a/arch/arm64/include/asm/mmzone.h b/arch/arm64/include/asm/mmzone.h
index a0de9e6..611a1cf 100644
--- a/arch/arm64/include/asm/mmzone.h
+++ b/arch/arm64/include/asm/mmzone.h
@@ -4,9 +4,7 @@
 #ifdef CONFIG_NUMA
 
 #include <asm/numa.h>
-
-extern struct pglist_data *node_data[];
-#define NODE_DATA(nid)		(node_data[(nid)])
+#include  <asm-generic/mmzone.h>
 
 #endif /* CONFIG_NUMA */
 #endif /* __ASM_MMZONE_H */
diff --git a/arch/m32r/include/asm/mmzone.h b/arch/m32r/include/asm/mmzone.h
index 115ced3..e3d66a0 100644
--- a/arch/m32r/include/asm/mmzone.h
+++ b/arch/m32r/include/asm/mmzone.h
@@ -7,12 +7,10 @@
 #define _ASM_MMZONE_H_
 
 #include <asm/smp.h>
+#include  <asm-generic/mmzone.h>
 
 #ifdef CONFIG_DISCONTIGMEM
 
-extern struct pglist_data *node_data[];
-#define NODE_DATA(nid)		(node_data[nid])
-
 #define node_localnr(pfn, nid)	((pfn) - NODE_DATA(nid)->node_start_pfn)
 
 #define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
diff --git a/arch/metag/include/asm/mmzone.h b/arch/metag/include/asm/mmzone.h
index 9c88a9c..b1e95b3 100644
--- a/arch/metag/include/asm/mmzone.h
+++ b/arch/metag/include/asm/mmzone.h
@@ -3,9 +3,7 @@
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
 #include <linux/numa.h>
-
-extern struct pglist_data *node_data[];
-#define NODE_DATA(nid)		(node_data[nid])
+#include  <asm-generic/mmzone.h>
 
 static inline int pfn_to_nid(unsigned long pfn)
 {
diff --git a/arch/powerpc/include/asm/mmzone.h b/arch/powerpc/include/asm/mmzone.h
index 7b58917..da0c5ba 100644
--- a/arch/powerpc/include/asm/mmzone.h
+++ b/arch/powerpc/include/asm/mmzone.h
@@ -19,12 +19,6 @@
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
 
-extern struct pglist_data *node_data[];
-/*
- * Return a pointer to the node data for node n.
- */
-#define NODE_DATA(nid)		(node_data[nid])
-
 /*
  * Following are specific to this numa platform.
  */
@@ -42,5 +36,7 @@ u64 memory_hotplug_max(void);
 #define memory_hotplug_max() memblock_end_of_DRAM()
 #endif /* CONFIG_NEED_MULTIPLE_NODES */
 
+#include  <asm-generic/mmzone.h>
+
 #endif /* __KERNEL__ */
 #endif /* _ASM_MMZONE_H_ */
diff --git a/arch/s390/include/asm/mmzone.h b/arch/s390/include/asm/mmzone.h
index a9e834e..91f1fcc 100644
--- a/arch/s390/include/asm/mmzone.h
+++ b/arch/s390/include/asm/mmzone.h
@@ -7,10 +7,6 @@
 #ifndef _ASM_S390_MMZONE_H
 #define _ASM_S390_MMZONE_H
 
-#ifdef CONFIG_NUMA
+#include  <asm-generic/mmzone.h>
 
-extern struct pglist_data *node_data[];
-#define NODE_DATA(nid) (node_data[nid])
-
-#endif /* CONFIG_NUMA */
 #endif /* _ASM_S390_MMZONE_H */
diff --git a/arch/sh/include/asm/mmzone.h b/arch/sh/include/asm/mmzone.h
index 15a8496..c070d00 100644
--- a/arch/sh/include/asm/mmzone.h
+++ b/arch/sh/include/asm/mmzone.h
@@ -5,9 +5,7 @@
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
 #include <linux/numa.h>
-
-extern struct pglist_data *node_data[];
-#define NODE_DATA(nid)		(node_data[nid])
+#include  <asm-generic/mmzone.h>
 
 static inline int pfn_to_nid(unsigned long pfn)
 {
diff --git a/arch/sparc/include/asm/mmzone.h b/arch/sparc/include/asm/mmzone.h
index 99d9b9f..ef1365b 100644
--- a/arch/sparc/include/asm/mmzone.h
+++ b/arch/sparc/include/asm/mmzone.h
@@ -5,13 +5,11 @@
 
 #include <linux/cpumask.h>
 
-extern struct pglist_data *node_data[];
-
-#define NODE_DATA(nid)		(node_data[nid])
-
 extern int numa_cpu_lookup_table[];
 extern cpumask_t numa_cpumask_lookup_table[];
 
 #endif /* CONFIG_NEED_MULTIPLE_NODES */
 
+#include  <asm-generic/mmzone.h>
+
 #endif /* _SPARC64_MMZONE_H */
diff --git a/arch/x86/include/asm/mmzone.h b/arch/x86/include/asm/mmzone.h
index d497bc4..8b9a0c2 100644
--- a/arch/x86/include/asm/mmzone.h
+++ b/arch/x86/include/asm/mmzone.h
@@ -1,5 +1,4 @@
+#include  <asm-generic/mmzone.h>
 #ifdef CONFIG_X86_32
 # include <asm/mmzone_32.h>
-#else
-# include <asm/mmzone_64.h>
 #endif
diff --git a/arch/x86/include/asm/mmzone_32.h b/arch/x86/include/asm/mmzone_32.h
index 1ec990b..09f7cfb 100644
--- a/arch/x86/include/asm/mmzone_32.h
+++ b/arch/x86/include/asm/mmzone_32.h
@@ -8,11 +8,6 @@
 
 #include <asm/smp.h>
 
-#ifdef CONFIG_NUMA
-extern struct pglist_data *node_data[];
-#define NODE_DATA(nid)	(node_data[nid])
-#endif /* CONFIG_NUMA */
-
 #ifdef CONFIG_DISCONTIGMEM
 
 /*
diff --git a/arch/x86/include/asm/mmzone_64.h b/arch/x86/include/asm/mmzone_64.h
deleted file mode 100644
index 129d9aa..0000000
--- a/arch/x86/include/asm/mmzone_64.h
+++ /dev/null
@@ -1,17 +0,0 @@
-/* K8 NUMA support */
-/* Copyright 2002,2003 by Andi Kleen, SuSE Labs */
-/* 2.5 Version loosely based on the NUMAQ Code by Pat Gaughen. */
-#ifndef _ASM_X86_MMZONE_64_H
-#define _ASM_X86_MMZONE_64_H
-
-#ifdef CONFIG_NUMA
-
-#include <linux/mmdebug.h>
-#include <asm/smp.h>
-
-extern struct pglist_data *node_data[];
-
-#define NODE_DATA(nid)		(node_data[nid])
-
-#endif
-#endif /* _ASM_X86_MMZONE_64_H */
diff --git a/include/asm-generic/mmzone.h b/include/asm-generic/mmzone.h
new file mode 100644
index 0000000..ec0fc4c
--- /dev/null
+++ b/include/asm-generic/mmzone.h
@@ -0,0 +1,24 @@
+/*
+ * linux/include/asm-generic/mmzone.h
+ *
+ * Author: Ganapatrao Kulkarni <gkulkarni@cavium.com>
+ * Copyright (C) 2016 Cavium Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#ifndef _ASM_GENERIC_MMZONE_H
+#define _ASM_GENERIC_MMZONE_H
+
+#if defined(CONFIG_NUMA) || defined(CONFIG_NEED_MULTIPLE_NODES)
+
+#ifndef NODE_DATA
+extern struct pglist_data *node_data[];
+#define NODE_DATA(nid)          (node_data[(nid)])
+#endif
+
+#endif
+#endif /* _ASM_GENERIC_MMZONE_H */
-- 
1.8.3.1

