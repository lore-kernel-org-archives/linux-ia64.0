From: Dean Roe <roe@sgi.com>
Date: Fri, 13 Aug 2004 17:56:32 +0000
Subject: [PATCH] add coherence id for SGI Altix systems
Message-Id: <200408131756.i7DHuWNi036140@shaft.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Current SGI Altix systems have a NUMAlink domain size of 1024
compute nodes and are fully cache coherent up to 256 compute
nodes (compute nodes are even-numbered).  Systems larger than
256 nodes are partitioned into multiple cache coherent systems.
This patch exports a partition's coherence id to users via the
/proc/sgi_sn/coherence_id file.

Signed-off-by: Dean Roe <roe@sgi.com>



Index: bk-work/include/asm-ia64/sn/sn_cpuid.h
=================================--- bk-work.orig/include/asm-ia64/sn/sn_cpuid.h	2004-08-10 14:23:26.000000000 -0500
+++ bk-work/include/asm-ia64/sn/sn_cpuid.h	2004-08-13 11:04:34.000000000 -0500
@@ -4,7 +4,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2003 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
  */
 
 
@@ -93,6 +93,7 @@
  */
 #define cpu_physical_id_to_nasid(cpi)		((cpi) &0xfff)
 #define cpu_physical_id_to_slice(cpi)		((cpi>>12) & 3)
+#define cpu_physical_id_to_coherence_id(cpi)	(cpu_physical_id_to_nasid(cpi) >> 9)
 #define get_nasid()				((ia64_getreg(_IA64_REG_CR_LID) >> 16) & 0xfff)
 #define get_slice()				((ia64_getreg(_IA64_REG_CR_LID) >> 28) & 0xf)
 #define get_node_number(addr)			(((unsigned long)(addr)>>38) & 0x7ff)
@@ -172,6 +173,11 @@
 
 #define smp_physical_node_id()			(cpuid_to_nasid(smp_processor_id()))
 
+/*
+ * cpuid_to_coherence_id - convert a cpuid to the coherence domain id it
+ * resides on
+ */
+#define cpuid_to_coherence_id(cpuid)	cpu_physical_id_to_coherence_id(cpu_physical_id(cpuid))
 
 #endif /* _ASM_IA64_SN_SN_CPUID_H */
 
Index: bk-work/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
=================================--- bk-work.orig/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	2004-08-10 14:23:59.000000000 -0500
+++ bk-work/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	2004-08-13 11:05:06.000000000 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2003 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
  */
 #include <linux/config.h>
 #include <asm/uaccess.h>
@@ -118,11 +118,33 @@
 	}
 }
 
+static int coherence_id_read_proc(char *page, char **start, off_t off,
+		int count, int *eof, void *data) {
+	return sprintf(page, "%d\n", cpuid_to_coherence_id(smp_processor_id()));
+}
+
+void
+register_sn_coherence_id(void) {
+	struct proc_dir_entry *entry;
+
+	if (!sgi_proc_dir) {
+		sgi_proc_dir = proc_mkdir("sgi_sn", 0);
+	}
+	entry = create_proc_entry("coherence_id", 0444, sgi_proc_dir);
+	if (entry) {
+		entry->nlink = 1;
+		entry->data = 0;
+		entry->read_proc = coherence_id_read_proc;
+		entry->write_proc = NULL;
+	}
+}
+
 void
 register_sn_procfs(void) {
 	register_sn_partition_id();
 	register_sn_serial_numbers();
 	register_sn_force_interrupt();
+	register_sn_coherence_id();
 }
 
 #endif /* CONFIG_PROC_FS */
