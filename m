From: Alex Williamson <alex_williamson@hp.com>
Date: Wed, 06 Nov 2002 15:09:57 +0000
Subject: [Linux-ia64] [PATCH] 2.5.45 generic kernel build
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------B52C0AA423CC2415B38ABAE0"
Message-Id: <marc-linux-ia64-105590709805339@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------B52C0AA423CC2415B38ABAE0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   This fixes some bad initialization of the machvec struct for
a "generic" kernel and initializes the iommu on zx1 in the right
place.  Works on zx2000.

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO
--------------B52C0AA423CC2415B38ABAE0
Content-Type: text/plain; charset=us-ascii;
 name="generic_zx1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="generic_zx1.diff"

Index: arch/ia64/hp/zx1/hpzx1_misc.c
===================================================================
RCS file: /var/cvs/linux-2.5/arch/ia64/hp/zx1/hpzx1_misc.c,v
retrieving revision 1.2
diff -u -p -r1.2 hpzx1_misc.c
--- arch/ia64/hp/zx1/hpzx1_misc.c	9 Oct 2002 20:42:02 -0000	1.2
+++ arch/ia64/hp/zx1/hpzx1_misc.c	6 Nov 2002 05:15:18 -0000
@@ -345,4 +345,4 @@ hpzx1_init (void)
 	sba_init();
 }
 
-subsys_initcall(hpzx1_init);
+device_initcall(hpzx1_init);
Index: include/asm-ia64/machvec.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/asm-ia64/machvec.h,v
retrieving revision 1.2
diff -u -p -r1.2 machvec.h
--- include/asm-ia64/machvec.h	9 Oct 2002 20:43:32 -0000	1.2
+++ include/asm-ia64/machvec.h	6 Nov 2002 05:15:22 -0000
@@ -23,8 +23,6 @@ struct page;
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t(void);
 typedef void ia64_mv_irq_init_t (void);
-typedef void ia64_mv_pci_fixup_t (int);
-typedef unsigned long ia64_mv_map_nr_t (unsigned long);
 typedef void ia64_mv_mca_init_t (void);
 typedef void ia64_mv_mca_handler_t (void);
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
@@ -120,8 +118,6 @@ struct ia64_machine_vector {
 	ia64_mv_setup_t *setup;
 	ia64_mv_cpu_init_t *cpu_init;
 	ia64_mv_irq_init_t *irq_init;
-	ia64_mv_pci_fixup_t *pci_fixup;
-	ia64_mv_map_nr_t *map_nr;
 	ia64_mv_mca_init_t *mca_init;
 	ia64_mv_mca_handler_t *mca_handler;
 	ia64_mv_cmci_handler_t *cmci_handler;
Index: include/asm-ia64/machvec_dig.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/asm-ia64/machvec_dig.h,v
retrieving revision 1.2
diff -u -p -r1.2 machvec_dig.h
--- include/asm-ia64/machvec_dig.h	9 Oct 2002 20:43:32 -0000	1.2
+++ include/asm-ia64/machvec_dig.h	6 Nov 2002 05:15:22 -0000
@@ -3,8 +3,6 @@
 
 extern ia64_mv_setup_t dig_setup;
 extern ia64_mv_irq_init_t dig_irq_init;
-extern ia64_mv_pci_fixup_t iosapic_pci_fixup;
-extern ia64_mv_map_nr_t map_nr_dense;
 
 /*
  * This stuff has dual use!
Index: include/asm-ia64/machvec_hpsim.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/asm-ia64/machvec_hpsim.h,v
retrieving revision 1.2
diff -u -p -r1.2 machvec_hpsim.h
--- include/asm-ia64/machvec_hpsim.h	9 Oct 2002 20:43:32 -0000	1.2
+++ include/asm-ia64/machvec_hpsim.h	6 Nov 2002 05:15:22 -0000
@@ -3,7 +3,6 @@
 
 extern ia64_mv_setup_t hpsim_setup;
 extern ia64_mv_irq_init_t hpsim_irq_init;
-extern ia64_mv_map_nr_t map_nr_dense;
 
 /*
  * This stuff has dual use!
Index: include/asm-ia64/machvec_hpzx1.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/asm-ia64/machvec_hpzx1.h,v
retrieving revision 1.2
diff -u -p -r1.2 machvec_hpzx1.h
--- include/asm-ia64/machvec_hpzx1.h	9 Oct 2002 20:43:32 -0000	1.2
+++ include/asm-ia64/machvec_hpzx1.h	6 Nov 2002 05:15:22 -0000
@@ -2,8 +2,6 @@
 #define _ASM_IA64_MACHVEC_HPZX1_h
 
 extern ia64_mv_setup_t dig_setup;
-extern ia64_mv_pci_fixup_t hpzx1_pci_fixup;
-extern ia64_mv_map_nr_t map_nr_dense;
 extern ia64_mv_pci_alloc_consistent sba_alloc_consistent;
 extern ia64_mv_pci_free_consistent sba_free_consistent;
 extern ia64_mv_pci_map_single sba_map_single;
Index: include/asm-ia64/machvec_sn1.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/asm-ia64/machvec_sn1.h,v
retrieving revision 1.2
diff -u -p -r1.2 machvec_sn1.h
--- include/asm-ia64/machvec_sn1.h	9 Oct 2002 20:43:32 -0000	1.2
+++ include/asm-ia64/machvec_sn1.h	6 Nov 2002 05:15:22 -0000
@@ -36,10 +36,8 @@
 extern ia64_mv_setup_t sn1_setup;
 extern ia64_mv_cpu_init_t sn_cpu_init;
 extern ia64_mv_irq_init_t sn1_irq_init;
-extern ia64_mv_map_nr_t sn1_map_nr;
 extern ia64_mv_send_ipi_t sn1_send_IPI;
 extern ia64_mv_global_tlb_purge_t sn1_global_tlb_purge;
-extern ia64_mv_pci_fixup_t sn1_pci_fixup;
 extern ia64_mv_inb_t sn1_inb;
 extern ia64_mv_inw_t sn1_inw;
 extern ia64_mv_inl_t sn1_inl;
Index: include/asm-ia64/machvec_sn2.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/asm-ia64/machvec_sn2.h,v
retrieving revision 1.2
diff -u -p -r1.2 machvec_sn2.h
--- include/asm-ia64/machvec_sn2.h	9 Oct 2002 20:43:32 -0000	1.2
+++ include/asm-ia64/machvec_sn2.h	6 Nov 2002 05:15:22 -0000
@@ -36,14 +36,12 @@
 extern ia64_mv_setup_t sn1_setup;
 extern ia64_mv_cpu_init_t sn_cpu_init;
 extern ia64_mv_irq_init_t sn1_irq_init;
-extern ia64_mv_map_nr_t sn2_map_nr;
 extern ia64_mv_send_ipi_t sn2_send_IPI;
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
 extern ia64_mv_irq_desc sn1_irq_desc;
 extern ia64_mv_irq_to_vector sn1_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn1_local_vector_to_irq;
 extern ia64_mv_valid_irq sn1_valid_irq;
-extern ia64_mv_pci_fixup_t sn1_pci_fixup;
 #ifdef Colin /* We are using the same is Generic IA64 calls defined in io.h */
 extern ia64_mv_inb_t sn1_inb;
 extern ia64_mv_inw_t sn1_inw;

--------------B52C0AA423CC2415B38ABAE0--


