From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 06 May 2005 00:12:45 +0000
Subject: [RFC] pcibus_to_node implementation for ia64
Message-Id: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a patch against 2.6.11-rc3-mm3. The mm tree contains a patch
x86-x86_64-pcibus_to_node.patch that introduces the ability to determine
the node number for a pci bus id. pcibus_to_node() is used by these
two patches

numa-aware-block-device-control-structure-allocation.patch
numa-aware-block-device-control-structure-allocation-tidy.patch

in order to allocate blockdev control structures on the node that the
device is connected to.

This patch only provides an actual implementation of pcibus_to_node for
Altix not for other subarches since I have no idea how to do that on these
arches. I would appreciate patches that allow the implementation on the
other ia64 subarches.

This is the first time I have modified the machvec.h file and the related
things so I may have missed something.

Index: linux-2.6.11/arch/ia64/sn/kernel/io_init.c
=================================--- linux-2.6.11.orig/arch/ia64/sn/kernel/io_init.c	2005-05-05 10:59:08.000000000 -0700
+++ linux-2.6.11/arch/ia64/sn/kernel/io_init.c	2005-05-05 16:33:19.000000000 -0700
@@ -67,7 +67,7 @@ static struct sn_pcibus_provider sn_pci_
 };

 /*
- * Retrieve the DMA Flush List given nasid.  This list is needed
+ * Retrieve the DMA Flush List given nasid.  This list is needed
  * to implement the WAR - Flush DMA data on PIO Reads.
  */
 static inline uint64_t
@@ -122,7 +122,7 @@ static inline uint64_t sal_get_pcibus_in
  * Retrieve the pci device information given the bus and device|function number.
  */
 static inline uint64_t
-sal_get_pcidev_info(u64 segment, u64 bus_number, u64 devfn, u64 pci_dev,
+sal_get_pcidev_info(u64 segment, u64 bus_number, u64 devfn, u64 pci_dev,
 			u64 sn_irq_info)
 {
 	struct ia64_sal_retval ret_stuff;
@@ -131,13 +131,22 @@ sal_get_pcidev_info(u64 segment, u64 bus

 	SAL_CALL_NOLOCK(ret_stuff,
 			(u64) SN_SAL_IOIF_GET_PCIDEV_INFO,
-			(u64) segment, (u64) bus_number, (u64) devfn,
+			(u64) segment, (u64) bus_number, (u64) devfn,
 			(u64) pci_dev,
 			sn_irq_info, 0, 0);
 	return ret_stuff.v0;
 }

 /*
+ * Figure out the node on which a given pci bus resides
+ */
+int sn_pcibus_to_node(struct pci_bus *bus)
+{
+	return nasid_to_cnodeid(NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base));
+}
+EXPORT_SYMBOL(sn_pcibus_to_node);
+
+/*
  * sn_alloc_pci_sysdata() - This routine allocates a pci controller
  *	which is expected as the pci_dev and pci_bus sysdata by the Linux
  *	PCI infrastructure.
Index: linux-2.6.11/include/asm-ia64/topology.h
=================================--- linux-2.6.11.orig/include/asm-ia64/topology.h	2005-05-05 11:01:46.000000000 -0700
+++ linux-2.6.11/include/asm-ia64/topology.h	2005-05-05 16:55:00.000000000 -0700
@@ -29,6 +29,15 @@
 #define node_to_cpumask(node) (node_to_cpu_mask[node])

 /*
+ * Returns the cpus local to a given PCI device.
+ * pcibus_to_node is defined in asm/pci.h
+ */
+#define pcibus_to_cpumask(bus) (pcibus_to_node(bus) = -1 ? \
+					CPU_MASK_ALL : \
+					node_to_cpumask(pcibus_to_node(bus)) \
+				)
+
+/*
  * Returns the number of the node containing Node 'nid'.
  * Not implemented here. Multi-level hierarchies detected with
  * the help of node_distance().
Index: linux-2.6.11/arch/ia64/kernel/topology.c
=================================--- linux-2.6.11.orig/arch/ia64/kernel/topology.c	2005-05-05 11:01:24.000000000 -0700
+++ linux-2.6.11/arch/ia64/kernel/topology.c	2005-05-05 16:44:11.000000000 -0700
@@ -31,7 +31,7 @@ static struct ia64_cpu *sysfs_cpus;
 int arch_register_cpu(int num)
 {
 	struct node *parent = NULL;
-
+
 #ifdef CONFIG_NUMA
 	parent = &sysfs_nodes[cpu_to_node(num)];
 #endif /* CONFIG_NUMA */
@@ -63,6 +63,16 @@ EXPORT_SYMBOL(arch_register_cpu);
 EXPORT_SYMBOL(arch_unregister_cpu);
 #endif /*CONFIG_HOTPLUG_CPU*/

+int ia64_pcibus_to_node(struct pci_bus *bus)
+{
+	/*
+	 * Confess our ignorance about the location of a
+	 * pci bus.
+	 */
+	return -1;
+}
+EXPORT_SYMBOL(ia64_pcibus_to_node);
+

 static int __init topology_init(void)
 {
Index: linux-2.6.11/include/asm-ia64/machvec.h
=================================--- linux-2.6.11.orig/include/asm-ia64/machvec.h	2005-03-01 23:38:10.000000000 -0800
+++ linux-2.6.11/include/asm-ia64/machvec.h	2005-05-05 16:40:25.000000000 -0700
@@ -34,6 +34,7 @@ typedef int ia64_mv_pci_legacy_read_t (s
 				       u8 size);
 typedef int ia64_mv_pci_legacy_write_t (struct pci_bus *, u16 port, u32 val,
 					u8 size);
+typedef int ia64_mv_pcibus_to_node(struct pci_bus *);

 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
@@ -131,6 +132,7 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_pci_get_legacy_mem	ia64_mv.pci_get_legacy_mem
 #  define platform_pci_legacy_read	ia64_mv.pci_legacy_read
 #  define platform_pci_legacy_write	ia64_mv.pci_legacy_write
+#  define platform_pcibus_to_node	ia64_mv.pcibus_to_node
 #  define platform_inb		ia64_mv.inb
 #  define platform_inw		ia64_mv.inw
 #  define platform_inl		ia64_mv.inl
@@ -179,6 +181,7 @@ struct ia64_machine_vector {
 	ia64_mv_pci_get_legacy_mem_t *pci_get_legacy_mem;
 	ia64_mv_pci_legacy_read_t *pci_legacy_read;
 	ia64_mv_pci_legacy_write_t *pci_legacy_write;
+	ia64_mv_pcibus_to_node *pcibus_to_node;
 	ia64_mv_inb_t *inb;
 	ia64_mv_inw_t *inw;
 	ia64_mv_inl_t *inl;
@@ -223,6 +226,7 @@ struct ia64_machine_vector {
 	platform_pci_get_legacy_mem,		\
 	platform_pci_legacy_read,		\
 	platform_pci_legacy_write,		\
+	platform_pcibus_to_node,		\
 	platform_inb,				\
 	platform_inw,				\
 	platform_inl,				\
@@ -341,6 +345,9 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_pci_legacy_write
 # define platform_pci_legacy_write	ia64_pci_legacy_write
 #endif
+#ifndef platform_pcibus_to_node
+# define platform_pcibus_to_node	ia64_pcibus_to_node
+#endif
 #ifndef platform_inb
 # define platform_inb		__ia64_inb
 #endif
Index: linux-2.6.11/include/asm-ia64/machvec_sn2.h
=================================--- linux-2.6.11.orig/include/asm-ia64/machvec_sn2.h	2005-05-05 16:42:45.000000000 -0700
+++ linux-2.6.11/include/asm-ia64/machvec_sn2.h	2005-05-05 16:45:23.000000000 -0700
@@ -44,7 +44,7 @@ extern ia64_mv_local_vector_to_irq sn_lo
 extern ia64_mv_pci_get_legacy_mem_t sn_pci_get_legacy_mem;
 extern ia64_mv_pci_legacy_read_t sn_pci_legacy_read;
 extern ia64_mv_pci_legacy_write_t sn_pci_legacy_write;
-extern ia64_mv_pcibus_to_node sn_pcibus_to_node
+extern ia64_mv_pcibus_to_node sn_pcibus_to_node;
 extern ia64_mv_inb_t __sn_inb;
 extern ia64_mv_inw_t __sn_inw;
 extern ia64_mv_inl_t __sn_inl;
