From: Jay Lan <jlan@sgi.com>
Date: Fri, 10 Nov 2006 23:59:20 +0000
Subject: [PATCH 1/2] IA64 kdump: Machine vector code for new SAL call
Message-Id: <45551258.8090305@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040304020604000502020103"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040304020604000502020103
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Attach a patch for adding a machine vector notifying the platform
specific code from Jack Steiner. His signature in the attached patch.




--------------040304020604000502020103
Content-Type: text/plain;
 name="patch_warm_reboot"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_warm_reboot"

The SN prom requires that some internal state be reset prior to kexec'ing 
a new kernel. 

Add a machine vector notifying the platform-specific code that a kexec
is about to occur. The SN code for this machine vector will issue a SAL call.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/include/asm-ia64/machvec.h
===================================================================
--- linux.orig/include/asm-ia64/machvec.h	2006-10-31 18:44:46.098133313 -0800
+++ linux/include/asm-ia64/machvec.h	2006-10-31 18:47:22.264068143 -0800
@@ -35,6 +35,7 @@ typedef int ia64_mv_pci_legacy_read_t (s
 typedef int ia64_mv_pci_legacy_write_t (struct pci_bus *, u16 port, u32 val,
 					u8 size);
 typedef void ia64_mv_migrate_t(struct task_struct * task);
+typedef void ia64_mv_kernel_launch_event_t(void);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
@@ -205,6 +206,7 @@ struct ia64_machine_vector {
 	ia64_mv_readq_relaxed_t *readq_relaxed;
 	ia64_mv_migrate_t *migrate;
 	ia64_mv_msi_init_t *msi_init;
+	ia64_mv_kernel_launch_event_t *kernel_launch_event;
 } __attribute__((__aligned__(16))); /* align attrib? see above comment */
 
 #define MACHVEC_INIT(name)			\
@@ -251,6 +253,7 @@ struct ia64_machine_vector {
 	platform_readq_relaxed,			\
 	platform_migrate,			\
 	platform_msi_init,			\
+	platform_kernel_launch_event,		\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -303,6 +306,9 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_tlb_migrate_finish
 # define platform_tlb_migrate_finish	machvec_noop_mm
 #endif
+#ifndef platform_kernel_launch_event
+# define platform_kernel_launch_event	machvec_noop
+#endif
 #ifndef platform_dma_init
 # define platform_dma_init		swiotlb_init
 #endif
Index: linux/include/asm-ia64/machvec_sn2.h
===================================================================
--- linux.orig/include/asm-ia64/machvec_sn2.h	2006-10-31 18:44:46.098133313 -0800
+++ linux/include/asm-ia64/machvec_sn2.h	2006-10-31 18:47:22.268068193 -0800
@@ -67,6 +67,7 @@ extern ia64_mv_dma_sync_sg_for_device	sn
 extern ia64_mv_dma_mapping_error	sn_dma_mapping_error;
 extern ia64_mv_dma_supported		sn_dma_supported;
 extern ia64_mv_migrate_t		sn_migrate;
+extern ia64_mv_kernel_launch_event_t	sn_kernel_launch_event;
 extern ia64_mv_msi_init_t		sn_msi_init;
 
 
@@ -119,6 +120,7 @@ extern ia64_mv_msi_init_t		sn_msi_init;
 #define platform_dma_mapping_error		sn_dma_mapping_error
 #define platform_dma_supported		sn_dma_supported
 #define platform_migrate		sn_migrate
+#define platform_kernel_launch_event	sn_kernel_launch_event
 #ifdef CONFIG_PCI_MSI
 #define platform_msi_init		sn_msi_init
 #else
Index: linux/include/asm-ia64/sn/sn_sal.h
===================================================================
--- linux.orig/include/asm-ia64/sn/sn_sal.h	2006-10-31 18:44:46.098133313 -0800
+++ linux/include/asm-ia64/sn/sn_sal.h	2006-11-07 10:30:01.859754859 -0800
@@ -87,6 +87,8 @@
 #define  SN_SAL_INJECT_ERROR			   0x02000067
 #define  SN_SAL_SET_CPU_NUMBER			   0x02000068
 
+#define SN_SAL_KERNEL_LAUNCH_EVENT		   0x02000069
+
 /*
  * Service-specific constants
  */
@@ -1154,4 +1156,13 @@ ia64_sn_set_cpu_number(int cpu)
 	SAL_CALL_NOLOCK(rv, SN_SAL_SET_CPU_NUMBER, cpu, 0, 0, 0, 0, 0, 0);
 	return rv.status;
 }
+
+static inline int
+ia64_sn_kernel_launch_event(void)
+{
+	struct ia64_sal_retval rv;
+
+	SAL_CALL_NOLOCK(rv, SN_SAL_KERNEL_LAUNCH_EVENT, 0, 0, 0, 0, 0, 0, 0);
+	return rv.status;
+}
 #endif /* _ASM_IA64_SN_SN_SAL_H */
Index: linux/arch/ia64/sn/kernel/setup.c
===================================================================
--- linux.orig/arch/ia64/sn/kernel/setup.c	2006-10-31 18:44:46.098133313 -0800
+++ linux/arch/ia64/sn/kernel/setup.c	2006-11-07 10:44:30.486080375 -0800
@@ -765,3 +765,11 @@ int sn_prom_feature_available(int id)
 }
 EXPORT_SYMBOL(sn_prom_feature_available);
 
+void
+sn_kernel_launch_event(void)
+{
+	/* ignore status until we understand possible failures, if any */
+	if (ia64_sn_kernel_launch_event())
+		printk(KERN_ERR "KEXEC is not supported in this PROM. Please update the PROM.\n");
+}
+
Index: linux/arch/ia64/kernel/machine_kexec.c
===================================================================
--- linux.orig/arch/ia64/kernel/machine_kexec.c	2006-10-31 18:44:46.110133461 -0800
+++ linux/arch/ia64/kernel/machine_kexec.c	2006-11-07 10:38:36.654033757 -0800
@@ -18,6 +18,7 @@
 #include <asm/setup.h>
 #include <asm/delay.h>
 #include <asm/meminit.h>
+#include <asm/machvec.h>
 
 typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
 		struct ia64_boot_param *, unsigned long);
@@ -125,6 +126,7 @@ static void ia64_machine_kexec(struct un
 		ia64_eoi();
 		vector = ia64_get_ivr();
 	}
+	platform_kernel_launch_event();
 	rnk = (relocate_new_kernel_t)&code_addr;
 	(*rnk)(image->head, image->start, ia64_boot_param,
 		     GRANULEROUNDDOWN((unsigned long) pal_addr));


--------------040304020604000502020103--
