From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 04 Aug 2003 21:14:04 +0000
Subject: [PATCH] sn2 module (& other misc.) fixes
Message-Id: <marc-linux-ia64-106003174416756@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This one goes on top of the one I sent you last week.  I'm shooting for
making Linus' tree boot on sn2 as well...

Thanks,
Jesse


diff -Nru a/arch/ia64/sn/io/hwgfs/hcl.c b/arch/ia64/sn/io/hwgfs/hcl.c
--- a/arch/ia64/sn/io/hwgfs/hcl.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/io/hwgfs/hcl.c	Fri Aug  1 16:06:51 2003
@@ -898,6 +898,5 @@
 EXPORT_SYMBOL(hwgraph_info_get_next_LBL);
 EXPORT_SYMBOL(hwgraph_info_export_LBL);
 EXPORT_SYMBOL(hwgraph_info_unexport_LBL);
-EXPORT_SYMBOL(hwgraph_path_lookup);
 EXPORT_SYMBOL(hwgraph_traverse);
 EXPORT_SYMBOL(hwgraph_vertex_name_get);
diff -Nru a/arch/ia64/sn/io/machvec/iomv.c b/arch/ia64/sn/io/machvec/iomv.c
--- a/arch/ia64/sn/io/machvec/iomv.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/io/machvec/iomv.c	Fri Aug  1 16:06:51 2003
@@ -73,3 +73,4 @@
 				SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK)
 		udelay(1);
 }
+EXPORT_SYMBOL(sn_mmiob);
diff -Nru a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c
--- a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Fri Aug  1 16:06:51 2003
@@ -455,7 +455,7 @@
 	struct sn_widget_sysdata *widget_sysdata;
 	struct sn_device_sysdata *device_sysdata;
 	pciio_intr_t intr_handle;
-	int cpuid, bit;
+	int cpuid;
 	vertex_hdl_t device_vertex;
 	pciio_intr_line_t lines;
 	extern void sn_pci_find_bios(void);
@@ -951,7 +951,7 @@
 
 	sn_pci_fixup(1);	/* phase 1 fixups (after buses scanned) */
 
-	return;
+	return 0;
 }
 
 subsys_initcall(sn_pci_init);
diff -Nru a/arch/ia64/sn/io/sn2/ml_SN_init.c b/arch/ia64/sn/io/sn2/ml_SN_init.c
--- a/arch/ia64/sn/io/sn2/ml_SN_init.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/io/sn2/ml_SN_init.c	Fri Aug  1 16:06:51 2003
@@ -10,6 +10,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/bootmem.h>
+#include <linux/module.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/io.h>
 #include <asm/sn/iograph.h>
@@ -29,6 +30,7 @@
 
 nasid_t master_nasid = INVALID_NASID;		/* This is the partition master nasid */
 nasid_t master_baseio_nasid = INVALID_NASID;	/* This is the master base I/O nasid */
+EXPORT_SYMBOL(master_nasid);
 
 
 /*
diff -Nru a/arch/ia64/sn/io/sn2/ml_iograph.c b/arch/ia64/sn/io/sn2/ml_iograph.c
--- a/arch/ia64/sn/io/sn2/ml_iograph.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/io/sn2/ml_iograph.c	Fri Aug  1 16:06:51 2003
@@ -10,6 +10,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/ctype.h>
+#include <linux/module.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/io.h>
@@ -876,6 +877,7 @@
  */
 int num_base_io_scsi_ctlr = 2; /* used by syssgi */
 vertex_hdl_t		base_io_scsi_ctlr_vhdl[NUM_BASE_IO_SCSI_CTLR];
+EXPORT_SYMBOL(base_io_scsi_ctlr_vhdl);
 
 #include <asm/sn/ioerror_handling.h>
 /* #endif */
diff -Nru a/arch/ia64/sn/io/sn2/shub.c b/arch/ia64/sn/io/sn2/shub.c
--- a/arch/ia64/sn/io/sn2/shub.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/io/sn2/shub.c	Fri Aug  1 16:06:51 2003
@@ -199,10 +199,9 @@
 {
         cnodeid_t       cnode;
         uint64_t        longarg;
-        vertex_hdl_t	d;
 	int		nasid;
 
-        cnode = (cnodeid_t)hwgraph_fastinfo_get(d);
+        cnode = (cnodeid_t)file->f_dentry->d_fsdata;
 
         switch (cmd) {
 	case SNDRV_SHUB_CONFIGURE:
diff -Nru a/arch/ia64/sn/io/sn2/shuberror.c b/arch/ia64/sn/io/sn2/shuberror.c
--- a/arch/ia64/sn/io/sn2/shuberror.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/io/sn2/shuberror.c	Fri Aug  1 16:06:51 2003
@@ -52,7 +52,6 @@
 hub_error_clear(nasid_t nasid)
 {
 	int i;
-	hubreg_t idsr;
 
     /*
      * Make sure spurious write response errors are cleared
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/kernel/setup.c	Fri Aug  1 16:06:51 2003
@@ -51,6 +51,7 @@
 #include <linux/compiler.h>
 #include <linux/sched.h>
 #include <linux/root_dev.h>
+#include <linux/module.h>
 
 #include <asm/io.h>
 #include <asm/sal.h>
@@ -88,10 +89,15 @@
 unsigned long sn_rtc_cycles_per_second;   
 
 partid_t sn_partid = -1;
+EXPORT_SYMBOL(sn_partid);
+
 char sn_system_serial_number_string[128];
 u64 sn_partition_serial_number;
+EXPORT_SYMBOL(sn_system_serial_number_string);
+EXPORT_SYMBOL(sn_partition_serial_number);
 
 short physical_node_map[MAX_PHYSNODE_ID];
+EXPORT_SYMBOL(physical_node_map);
 
 /*
  * This is the address of the RRegs in the HSpace of the global
diff -Nru a/arch/ia64/sn/kernel/sn2/cache.c b/arch/ia64/sn/kernel/sn2/cache.c
--- a/arch/ia64/sn/kernel/sn2/cache.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/kernel/sn2/cache.c	Fri Aug  1 16:06:51 2003
@@ -8,7 +8,9 @@
  *
  */
 
-#include <asm/pgalloc.h>
+#include <linux/module.h>
+#include <asm/cacheflush.h>
+#include <asm/system.h>
 
 /**
  * sn_flush_all_caches - flush a range of address from all caches (incl. L4)
@@ -26,3 +28,4 @@
 	flush_icache_range(flush_addr, flush_addr+bytes);
 	mb();
 }
+EXPORT_SYMBOL(sn_flush_all_caches);
diff -Nru a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c	Fri Aug  1 16:06:51 2003
@@ -41,6 +41,7 @@
 #include <linux/interrupt.h>
 #include <linux/irq.h>
 #include <linux/mmzone.h>
+#include <linux/module.h>
 
 #include <asm/processor.h>
 #include <asm/irq.h>
@@ -214,6 +215,7 @@
 	}
 
 }
+EXPORT_SYMBOL(sn_send_IPI_phys);
 
 /**
  * sn2_send_IPI - send an IPI to a processor
diff -Nru a/arch/ia64/sn/kernel/sn_ksyms.c b/arch/ia64/sn/kernel/sn_ksyms.c
--- a/arch/ia64/sn/kernel/sn_ksyms.c	Fri Aug  1 16:06:51 2003
+++ b/arch/ia64/sn/kernel/sn_ksyms.c	Fri Aug  1 16:06:51 2003
@@ -13,48 +13,25 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-
+#include <linux/mm.h>
 #include <asm/machvec.h>
 #include <asm/sn/intr.h>
-
-#include <linux/mm.h>
 #include <asm/sn/sgi.h>
-extern vertex_hdl_t          base_io_scsi_ctlr_vhdl[];
 #include <asm/sn/types.h>
-extern cnodeid_t master_node_get(devfs_handle_t vhdl);
 #include <asm/sn/arch.h>
-EXPORT_SYMBOL(base_io_scsi_ctlr_vhdl);
-EXPORT_SYMBOL(master_node_get);
+#include <asm/sn/bte.h>
+#include <asm/sal.h>
+#include <asm/sn/sn_sal.h>
 
 #ifdef CONFIG_IA64_SGI_SN_DEBUG
 EXPORT_SYMBOL(__pa_debug);
 EXPORT_SYMBOL(__va_debug);
 #endif
 
-/* Support IPIs for loaded modules. */
-EXPORT_SYMBOL(sn_send_IPI_phys);
-
-/* symbols referenced by partitioning modules */
-#include <asm/sn/bte.h>
 EXPORT_SYMBOL(bte_copy);
 EXPORT_SYMBOL(bte_unaligned_copy);
-#include <asm/sal.h>
 EXPORT_SYMBOL(ia64_sal);
-EXPORT_SYMBOL(physical_node_map);
-
-#include <asm/sn/sn_sal.h>
 EXPORT_SYMBOL(sal_lock);
-EXPORT_SYMBOL(sn_partid);
 EXPORT_SYMBOL(sn_local_partid);
-EXPORT_SYMBOL(sn_system_serial_number_string);
-EXPORT_SYMBOL(sn_partition_serial_number);
-
-EXPORT_SYMBOL(sn_mmiob);
-
-/* added by tduffy 04.08.01 to fix depmod issues */
-#include <linux/mmzone.h>
 
-extern nasid_t master_nasid;
-EXPORT_SYMBOL(master_nasid);
 
-EXPORT_SYMBOL(sn_flush_all_caches);
diff -Nru a/include/asm-ia64/sn/xtalk/xtalk.h b/include/asm-ia64/sn/xtalk/xtalk.h
--- a/include/asm-ia64/sn/xtalk/xtalk.h	Fri Aug  1 16:06:51 2003
+++ b/include/asm-ia64/sn/xtalk/xtalk.h	Fri Aug  1 16:06:51 2003
@@ -19,7 +19,7 @@
 /*
  * User-level device driver visible types
  */
-typedef char            xwidgetnum_t;	/* xtalk widget number  (0..15) */
+typedef int            xwidgetnum_t;	/* xtalk widget number  (0..15) */
 
 #define XWIDGET_NONE		(-1)
 
