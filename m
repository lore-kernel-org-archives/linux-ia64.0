From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 05 Aug 2003 00:06:31 +0000
Subject: Re: [PATCH] sn2 module (& other misc.) fixes
Message-Id: <marc-linux-ia64-106004201526166@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106003174416756@msgid-missing>
In-Reply-To: <marc-linux-ia64-106003174416756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 04, 2003 at 04:31:32PM -0700, David Mosberger wrote:
> >>>>> On Mon, 4 Aug 2003 14:14:04 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> This one goes on top of the one I sent you last week.  I'm
>   Jesse> shooting for making Linus' tree boot on sn2 as well...
> 
> This one didn't apply for me.  I just updated the to-linus-2.5 tree.
> Can you rediff against that?

Sure, does this one work for you?

Thanks,
Jesse

diff -Nru a/arch/ia64/sn/io/hwgfs/hcl.c b/arch/ia64/sn/io/hwgfs/hcl.c
--- a/arch/ia64/sn/io/hwgfs/hcl.c	Mon Aug  4 17:02:37 2003
+++ b/arch/ia64/sn/io/hwgfs/hcl.c	Mon Aug  4 17:02:37 2003
@@ -898,6 +898,5 @@
 EXPORT_SYMBOL(hwgraph_info_get_next_LBL);
 EXPORT_SYMBOL(hwgraph_info_export_LBL);
 EXPORT_SYMBOL(hwgraph_info_unexport_LBL);
-EXPORT_SYMBOL(hwgraph_path_lookup);
 EXPORT_SYMBOL(hwgraph_traverse);
 EXPORT_SYMBOL(hwgraph_vertex_name_get);
diff -Nru a/arch/ia64/sn/io/machvec/iomv.c b/arch/ia64/sn/io/machvec/iomv.c
--- a/arch/ia64/sn/io/machvec/iomv.c	Mon Aug  4 17:02:37 2003
+++ b/arch/ia64/sn/io/machvec/iomv.c	Mon Aug  4 17:02:37 2003
@@ -73,3 +73,4 @@
 				SH_PIO_WRITE_STATUS_0_PENDING_WRITE_COUNT_MASK)
 		udelay(1);
 }
+EXPORT_SYMBOL(sn_mmiob);
diff -Nru a/arch/ia64/sn/io/sn2/shub.c b/arch/ia64/sn/io/sn2/shub.c
--- a/arch/ia64/sn/io/sn2/shub.c	Mon Aug  4 17:02:37 2003
+++ b/arch/ia64/sn/io/sn2/shub.c	Mon Aug  4 17:02:37 2003
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
--- a/arch/ia64/sn/io/sn2/shuberror.c	Mon Aug  4 17:02:37 2003
+++ b/arch/ia64/sn/io/sn2/shuberror.c	Mon Aug  4 17:02:37 2003
@@ -52,7 +52,6 @@
 hub_error_clear(nasid_t nasid)
 {
 	int i;
-	hubreg_t idsr;
 
     /*
      * Make sure spurious write response errors are cleared
diff -Nru a/arch/ia64/sn/kernel/sn2/cache.c b/arch/ia64/sn/kernel/sn2/cache.c
--- a/arch/ia64/sn/kernel/sn2/cache.c	Mon Aug  4 17:02:37 2003
+++ b/arch/ia64/sn/kernel/sn2/cache.c	Mon Aug  4 17:02:37 2003
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
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c	Mon Aug  4 17:02:37 2003
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c	Mon Aug  4 17:02:37 2003
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
--- a/arch/ia64/sn/kernel/sn_ksyms.c	Mon Aug  4 17:02:37 2003
+++ b/arch/ia64/sn/kernel/sn_ksyms.c	Mon Aug  4 17:02:37 2003
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
--- a/include/asm-ia64/sn/xtalk/xtalk.h	Mon Aug  4 17:02:37 2003
+++ b/include/asm-ia64/sn/xtalk/xtalk.h	Mon Aug  4 17:02:37 2003
@@ -19,7 +19,7 @@
 /*
  * User-level device driver visible types
  */
-typedef char            xwidgetnum_t;	/* xtalk widget number  (0..15) */
+typedef int            xwidgetnum_t;	/* xtalk widget number  (0..15) */
 
 #define XWIDGET_NONE		(-1)
 
