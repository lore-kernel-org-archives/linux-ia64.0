From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 01 Sep 2004 16:27:54 +0000
Subject: [PATCH] iosapic NUMA interrupt locality
Message-Id: <1094056074.4678.6.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   This patch associates IOSAPICs with NUMA nodes such that interrupts
gets assigned to a reasonably good default CPU.  The patch does not
depend on the pxm_to_nid_map fixup, but results will be strange in some
configurations without it.  This should work on any NUMA box that
exposes IOSAPICs with _MAT & _PXM methods, but it's only been tested on
an rx8620.  There should be no change in behavior for boxes that don't
export both of these in ACPI namespace.  Thanks,

	Alex

-- 
Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/kernel/acpi.c 1.74 vs edited ==--- 1.74/arch/ia64/kernel/acpi.c	2004-08-05 22:40:29 -06:00
+++ edited/arch/ia64/kernel/acpi.c	2004-08-31 15:03:53 -06:00
@@ -649,4 +649,70 @@
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
+acpi_status __init
+acpi_map_iosapic (acpi_handle handle, u32 depth, void *context, void **ret)
+{
+	struct acpi_buffer buffer = {ACPI_ALLOCATE_BUFFER, NULL};
+	union acpi_object *obj;
+	struct acpi_table_iosapic *iosapic;
+	unsigned int gsi_base;
+	int node;
+
+	/* Only care about objects w/ a method that returns the MADT */
+	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
+		return AE_OK;
+
+	if (!buffer.length || !buffer.pointer)
+		return AE_OK;
+
+	obj = buffer.pointer;
+	if (obj->type != ACPI_TYPE_BUFFER ||
+	    obj->buffer.length < sizeof(*iosapic)) {
+		acpi_os_free(buffer.pointer);
+		return AE_OK;
+	}
+
+	iosapic = (struct acpi_table_iosapic *)obj->buffer.pointer;
+
+	if (iosapic->header.type != ACPI_MADT_IOSAPIC) {
+		acpi_os_free(buffer.pointer);
+		return AE_OK;
+	}
+
+	gsi_base = iosapic->global_irq_base;
+
+	acpi_os_free(buffer.pointer);
+	buffer.length = ACPI_ALLOCATE_BUFFER;
+	buffer.pointer = NULL;
+
+	/*
+	 * OK, it's an IOSAPIC MADT entry, look for a _PXM method to tell
+	 * us which node to associate this with.
+	 */
+	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_PXM", NULL, &buffer)))
+		return AE_OK;
+
+	if (!buffer.length || !buffer.pointer)
+		return AE_OK;
+
+	obj = buffer.pointer;
+
+	if (obj->type != ACPI_TYPE_INTEGER) {
+		acpi_os_free(buffer.pointer);
+		return AE_OK;
+	}
+
+	node = pxm_to_nid_map[obj->integer.value];
+	acpi_os_free(buffer.pointer);
+
+	if (node >= MAX_NUMNODES || !node_online(node) ||
+	    cpus_empty(node_to_cpumask(node)))
+		return AE_OK;
+
+	/* We know a gsi to node mapping! */
+	map_iosapic_to_node(gsi_base, node);
+	return AE_OK;
+}
+#endif /* CONFIG_NUMA */
 #endif /* CONFIG_ACPI_BOOT */
=== arch/ia64/kernel/iosapic.c 1.46 vs edited ==--- 1.46/arch/ia64/kernel/iosapic.c	2004-06-29 20:06:03 -06:00
+++ edited/arch/ia64/kernel/iosapic.c	2004-09-01 10:17:58 -06:00
@@ -117,6 +117,9 @@
 	char		*addr;		/* base address of IOSAPIC */
 	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
 	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
+#ifdef CONFIG_NUMA
+	unsigned short	node;		/* numa node association via pxm */
+#endif
 } iosapic_lists[NR_IOSAPICS];
 
 static int num_iosapic;
@@ -488,7 +491,7 @@
 }
 
 static unsigned int
-get_target_cpu (void)
+get_target_cpu (unsigned int gsi, int vector)
 {
 #ifdef CONFIG_SMP
 	static int cpu = -1;
@@ -507,6 +510,34 @@
 	if (!cpu_online(smp_processor_id()))
 		return hard_smp_processor_id();
 
+#ifdef CONFIG_NUMA
+	{
+		int num_cpus, cpu_index, iosapic_index, numa_cpu, i = 0;
+		cpumask_t cpu_mask;
+
+		iosapic_index = find_iosapic(gsi);
+		if (iosapic_index < 0 ||
+		    iosapic_lists[iosapic_index].node = MAX_NUMNODES)
+			goto skip_numa_setup;
+
+		cpu_mask = node_to_cpumask(iosapic_lists[iosapic_index].node);
+		
+		num_cpus = cpus_weight(cpu_mask);
+
+		if (!num_cpus)
+			goto skip_numa_setup;
+
+		/* Use vector assigment to distribute across cpus in node */
+		cpu_index = vector % num_cpus;
+
+		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
+			numa_cpu = next_cpu(numa_cpu, cpu_mask);
+
+		if (numa_cpu != NR_CPUS)
+			return cpu_physical_id(numa_cpu);
+	}
+skip_numa_setup:
+#endif
 	/*
 	 * Otherwise, round-robin interrupt vectors across all the
 	 * processors.  (It'd be nice if we could be smarter in the
@@ -550,7 +581,7 @@
 		}
 
 		vector = assign_irq_vector(AUTO_ASSIGN);
-		dest = get_target_cpu();
+		dest = get_target_cpu(gsi, vector);
 		register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
 			polarity, trigger);
 	}
@@ -680,6 +711,9 @@
 	iosapic_lists[num_iosapic].addr = addr;
 	iosapic_lists[num_iosapic].gsi_base = gsi_base;
 	iosapic_lists[num_iosapic].num_rte = num_rte;
+#ifdef CONFIG_NUMA
+	iosapic_lists[num_iosapic].node = MAX_NUMNODES;
+#endif
 	num_iosapic++;
 
 	if ((gsi_base = 0) && pcat_compat) {
@@ -692,3 +726,20 @@
 			iosapic_override_isa_irq(isa_irq, isa_irq, IOSAPIC_POL_HIGH, IOSAPIC_EDGE);
 	}
 }
+
+#ifdef CONFIG_NUMA
+void __init
+map_iosapic_to_node(unsigned int gsi_base, int node)
+{
+	int index;
+
+	index = find_iosapic(gsi_base);
+	if (index < 0) {
+		printk(KERN_WARNING "%s: No IOSAPIC for GSI %u\n",
+		       __FUNCTION__, gsi_base);
+		return;
+	}
+	iosapic_lists[index].node = node;
+	return;
+}
+#endif
=== arch/ia64/pci/pci.c 1.51 vs edited ==--- 1.51/arch/ia64/pci/pci.c	2004-08-04 06:44:53 -06:00
+++ edited/arch/ia64/pci/pci.c	2004-08-27 16:16:59 -06:00
@@ -136,6 +136,11 @@
 
 	printk(KERN_INFO "PCI: Using ACPI for IRQ routing\n");
 
+#ifdef CONFIG_NUMA
+extern acpi_status acpi_map_iosapic (acpi_handle, u32, void*, void**);
+
+	acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
+#endif
 	/*
 	 * PCI IRQ routing is set up by pci_enable_device(), but we
 	 * also do it here in case there are still broken drivers that
=== include/asm-ia64/iosapic.h 1.15 vs edited ==--- 1.15/include/asm-ia64/iosapic.h	2004-06-29 20:06:03 -06:00
+++ edited/include/asm-ia64/iosapic.h	2004-08-27 15:09:26 -06:00
@@ -90,6 +90,9 @@
 extern unsigned int iosapic_version (char *addr);
 
 extern void iosapic_pci_fixup (int);
+#ifdef CONFIG_NUMA
+extern void __init map_iosapic_to_node (unsigned int, int);
+#endif
 #else
 #define iosapic_system_init(pcat_compat)			do { } while (0)
 #define iosapic_init(address,gsi_base)				do { } while (0)


