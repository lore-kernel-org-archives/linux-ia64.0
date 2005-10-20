From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 20 Oct 2005 20:36:36 +0000
Subject: [PATCH 1/1] ia64:  numa emulation
Message-Id: <1129840596.6182.37.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This patch subdivides an ia64 SMP platform into 2 or more emulated NUMA
nodes.  Applies to kernel 2.6.14-rc4.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

---
This patch is a "work in progress" [sort of--I'm not really doing much
work on it recently].  You'll note a number of TODO's noting
questions/deferred decisions/... =20

Also, the changes to mm/discontig.c could be eliminated.  Minor
"cleanup" [subjective, I know] that I left in. =20

A few other changes to eliminate trailing whitespace in the files I
touched.

 arch/ia64/Kconfig        |   18 +
 arch/ia64/kernel/acpi.c  |  479 +++++++++++++++++++++++++++++++++++++++
+++++++-
 arch/ia64/kernel/efi.c   |  109 ++++++++++
 arch/ia64/mm/discontig.c |    9=20
 fs/Kconfig               |    4=20
 include/linux/efi.h      |    8=20
 6 files changed, 616 insertions(+), 11 deletions(-)


--- fakenuma-2.6.14-rc4/arch/ia64/kernel/acpi.c~original	2005-10-17 11:56:5=
1.000000000 -0400
+++ fakenuma-2.6.14-rc4/arch/ia64/kernel/acpi.c	2005-10-19 10:54:34.0000000=
00 -0400
@@ -54,6 +54,10 @@
 #include <asm/sal.h>
 #include <asm/cyclone.h>
=20
+#ifdef CONFIG_NUMA_EMU
+#include <asm/pgtable.h>	/* for IA64_GRANULE_SIZE */
+#endif
+
 #define BAD_MADT_ENTRY(entry, end) (                                      =
  \
 		(!entry) || (unsigned long)entry + sizeof(*entry) > end ||  \
 		((acpi_table_entry_header *)entry)->length !=3D sizeof(*entry))
@@ -174,6 +178,10 @@ static int available_cpus __initdata;
 struct acpi_table_madt *acpi_madt __initdata;
 static u8 has_8259;
=20
+#ifdef CONFIG_NUMA_EMU
+static int __initdata already_parsed_lsapic =3D 0;
+#endif
+
 static int __init
 acpi_parse_lapic_addr_ovr(acpi_table_entry_header * header,
 			  const unsigned long end)
@@ -371,6 +379,12 @@ static void __init acpi_madt_oem_check(c
=20
 static int __init acpi_parse_madt(unsigned long phys_addr, unsigned long s=
ize)
 {
+
+#ifdef CONFIG_NUMA_EMU
+	if (already_parsed_lsapic)
+		return 0;	/* been there, done that */
+#endif
+
 	if (!phys_addr || !size)
 		return -EINVAL;
=20
@@ -485,20 +499,478 @@ acpi_numa_memory_affinity_init(struct ac
 	num_node_memblks++;
 }
=20
+#ifdef CONFIG_NUMA_EMU
+
+#undef NUMA_EMU_DEBUG
+
+// TODO:  compute from page size and max order?
+#define NUMA_EMU_MIN_PER_NODE_MEM (1 << 30)	/* arbitrary:  1GB/node min */
+
+static int __initdata numa_fake =3D 0;	/* # of emulated nodes */
+
+struct acpi_table_slit_emu {
+	struct acpi_table_slit table;
+	u8                     entry[MAX_NUMNODES*MAX_NUMNODES];
+};
+static struct acpi_table_slit_emu __initdata acpi_table_slit_emu;
+
+/*
+ * Need a count of cpus to validate requested NUMA Emulation, but
+ * parse of lsapic doesn't happen until later.  So, count the
+ * cpus here, and let acpi_boot_init() know that we've already
+ * done it.
+ */
+static int __init
+acpi_numa_emu_count_cpus(void)
+{
+
+	if (acpi_table_parse(ACPI_APIC, acpi_parse_madt) < 1) {
+		printk(KERN_ERR PREFIX "Can't find MADT\n");
+		return 0;
+	}
+
+	if (acpi_table_parse_madt(ACPI_MADT_LSAPIC, acpi_parse_lsapic, NR_CPUS)
+		< 1) {
+		printk(KERN_ERR PREFIX
+			 "Error parsing MADT - no LAPIC entries\n");
+		return 0;
+	}
+	already_parsed_lsapic =3D 1;	/* skip it in acpi_boot_init() */
+
+#ifdef NUMA_EMU_DEBUG
+	printk("NUMA Emulation:  "
+		"%s found %d cpus\n", __FUNCTION__, available_cpus);
+#endif
+
+	return available_cpus;	/* counted by acpi_parse_lsapic() */
+}
+
+/*
+ * Callback for efi.c:efi_numa_emu_find_physmem()
+ * Add contiguous range of physical memory to node_memblk[].
+ * We'll assign affinity after all have been collected.
+ * Ranges arrive in address order from the efi memory map.
+ */
+static int __init
+acpi_numa_emu_add_memblk(unsigned long start, unsigned long end, void *arg)
+{
+	struct node_memblk_s *p =3D &node_memblk[num_node_memblks];
+
+	if (num_node_memblks >=3D NR_NODE_MEMBLKS)
+		return -1;	/* too many blocks */
+
+	p->start_paddr =3D start;
+	p->size        =3D end - start;
+	++num_node_memblks;
+
+	return 0;
+}
+
+/*
+ * acpi_numa_emu_memory_affinity():
+ *
+ * Use physical memory from SRAT [single node platform] or walk
+ * EFI memory map to find physical memory.  Distribute memory
+ * among emulated nodes.  Must distribute on "order boundary"
+ * to maintain sanity.
+ */
+//TODO:  make order boundary stuff conditional on VIRTUAL_MEM_MAP?
+#define ORDER_BOUNDARY (PAGE_SIZE << MAX_ORDER)
+#define ORDER_MASK     (ORDER_BOUNDARY-1)
+#define ORDERROUNDUP(n) (((n)+ORDER_MASK) & ~ORDER_MASK)
+
+static int __init
+acpi_numa_emu_memory_affinity(void)
+{
+	unsigned long total_mem =3D 0, per_node_mem, node_0_mem;
+	struct node_memblk_s *p, *pend;
+	int pxm =3D 0;
+
+	if (num_node_memblks > 0) {
+		/*
+		 * use info from SRAT
+		 */
+		for(p =3D &node_memblk[0]; p < &node_memblk[num_node_memblks];
+			 ++p) {
+			total_mem +=3D p->size;
+		}
+	} else {
+		if(efi_numa_emu_find_physmem(acpi_numa_emu_add_memblk,
+						 &total_mem))
+			return -1;
+	}
+
+	pend =3D &node_memblk[num_node_memblks];
+	per_node_mem =3D GRANULEROUNDDOWN(total_mem / numa_fake);
+
+	if (per_node_mem < NUMA_EMU_MIN_PER_NODE_MEM)
+		return -1;
+
+	/*
+	 * give the left over to node 0
+	 */
+	node_0_mem =3D per_node_mem + (total_mem - (per_node_mem * numa_fake));
+
+#ifdef NUMA_EMU_DEBUG
+	printk("NUMA Emulation:  "
+		"total_mem %luMB, node_0_mem %luMB, per_node_mem %luMB\n"
+		"                 "
+		"before memblk affinitization:  num_node_memblks=3D%d\n",
+		(total_mem >> 20), (node_0_mem >> 20), (per_node_mem >> 20),
+		num_node_memblks);
+
+	for(p =3D &node_memblk[0]; p < pend; ++p) {
+		printk("NUMA Emulation:  "
+			"node_memblk[%lu]:  nid:  %d, range=3D[0x%016lx-0x%016lx)"
+			"(%luMB)\n",
+				p-node_memblk, p->nid, p->start_paddr,
+				p->start_paddr+p->size, p->size >> 20);
+	}
+#endif
+
+	/*
+	 * Now, distribute memblk's over nodes.  Splitting as needed.
+	 * re:  pxm:  we're assigning memory to [emulated] proximity domains
+	 */
+	for(p =3D &node_memblk[0]; p < pend && total_mem > 0; ++p, ++pxm) {
+		long need;
+
+		if(pxm =3D 0) {
+			need =3D node_0_mem;
+		} else {
+			if((need =3D min(per_node_mem, total_mem)) <=3D 0)
+				return -1; /* because of order alignment */
+		}
+		total_mem -=3D need;	/* remaining after this pxm */
+
+		p->nid =3D pxm; /* assign this memblk to node */
+		need  -=3D p->size;
+
+		/*
+		 * fulfill this pxm's need in this pass of the for loop
+		 */
+		while (need > 0) {
+			(++p)->nid =3D pxm; /* assign next block */
+			need  -=3D p->size;
+		}
+
+		if (need < 0) {
+			/*
+			 * may need to split p on "order boundary"
+			 * Needed because of funky phymem layout on
+			 * HP rx2600/rx46xx platforms. [maybe others?]
+			 * Note:  we reduce default CONFIG_FORCE_MAX_ZONEORDER
+			 * for NUMA Emulation so this works for < 8GB or so.
+			 */
+			unsigned long next_start, adjust;
+			long excess =3D 0 - need;
+
+			next_start =3D p->start_paddr + p->size - excess;
+			adjust =3D ORDERROUNDUP(next_start) - next_start;
+			next_start +=3D adjust;
+			excess     -=3D adjust;
+			total_mem  -=3D min(adjust, total_mem);
+			if (excess > 0) {
+				/*
+				 * split memblk 'p'
+				 */
+				struct node_memblk_s *q;
+				for (q =3D pend; q > p; --q)
+					*q =3D *(q - 1);	/* make room */
+
+				(++q)->start_paddr =3D next_start;
+				q->size =3D  excess;
+
+				p->size =3D  q->start_paddr - p->start_paddr;
+
+				if (++num_node_memblks > NR_NODE_MEMBLKS) {
+					printk(KERN_WARNING
+						"%s:  NUMA Emulation would "
+						"exceed NR_NODE_MEMBLKS %d\n",
+					   __FUNCTION__, NR_NODE_MEMBLKS);
+					num_node_memblks =3D 0;
+					return -1; /* abandons numa emulation */
+				}
+				++pend;
+				continue;	/* aligned on order boundary */
+			}
+			/*
+			 * else let this pxm/node have all of 'p'
+			 */
+		}
+
+		/*
+		 * TODO:
+		 * Technically, we should ensure that following memblks, if any,
+		 * [these will be assigned to next pxm/node] wouldn't cause
+		 * memmap overlap when rounded down to "order boundary".
+		 * ??? SPARSEMEM interaction?
+		 */
+
+	} /* for each memblk */
+
+	/*
+	 * TODO:
+	 * Should check that all fake nodes got some minimal memory after
+	 * all the order alignment.
+	 */
+
+#ifdef NUMA_EMU_DEBUG
+	printk("NUMA Emulation:  "
+		"after memblk affinitization:  num_node_memblks=3D%d\n",
+	        	num_node_memblks);
+	for(p =3D &node_memblk[0]; p < pend; ++p) {
+		printk("NUMA Emulation:  "
+			"node_memblk[%lu]:  nid:  %d, range=3D[0x%016lx-0x%016lx)"
+			" (%luMB)\n",
+				p-node_memblk, p->nid, p->start_paddr,
+				p->start_paddr+p->size, p->size >> 20);
+	}
+#endif
+	return 0;
+
+}
+
+/*
+ * acpi_numa_emu_processor_affinity() - assign cpus to fake nodes.
+ * VERY simple round robin algorithm [except cpu 0--see below].
+ * TODO:  will need rework for SMT/multi-core to ensure that siblings
+ *        end up on same node.
+ */
+static void __init
+acpi_numa_emu_processor_affinity(void)
+{
+	int cpu, pxm, i;
+
+	/*
+	 * distribute cpus over emulated proximity domains in a similar
+	 * fashion to acpi_boot_init() when srat_num_cpus =3D 0.
+	 * But first, boot cpu =3D logical id 0 on pxm/node 0.
+	 * Note:  the real acpi_numa_processor_affinity() function
+	 * doesn't do anything special for cpu/pxm 0.  Perhaps the
+	 * SRAT presents the boot pxm first?
+	 */
+	node_cpuid[0].phys_id =3D hard_smp_processor_id();
+	node_cpuid[0].nid     =3D 0;
+	pxm_bit_set(0);		/* emulated pxm/node 0 */
+
+#ifdef NUMA_EMU_DEBUG
+		printk("NUMA Emulation:  "
+			"cpu 0 [phys 0x%x] assigned to proximity domain 0\n",
+		        node_cpuid[0].phys_id);
+#endif
+
+	pxm =3D i =3D 1;
+	for(cpu=3D0; cpu < available_cpus; ++cpu) {
+		if (smp_boot_data.cpu_phys_id[cpu] =3D hard_smp_processor_id())
+			continue;	/* boot cpu is "special" */
+
+		if (!pxm_bit_test(pxm))
+			pxm_bit_set(pxm);
+
+		/*
+		 * Use phys_id from lsapic scan.
+		 * Only because the real acpi_numa_processor_affinity_init()
+		 * does so.
+		 */
+		node_cpuid[i].phys_id =3D smp_boot_data.cpu_phys_id[cpu];
+
+		/*
+		 * fake proximity domain id
+		 */
+		node_cpuid[i].nid =3D pxm;
+
+#ifdef NUMA_EMU_DEBUG
+		printk("NUMA Emulation:  "
+			"cpu %d [phys 0x%x] assigned to proximity domain %d\n",
+		        i, node_cpuid[i].phys_id, node_cpuid[i].nid);
+#endif
+
+		++i;
+		if (++pxm =3D numa_fake)
+			pxm =3D 0;	/* wrap */
+	}
+
+	/*
+	 * Mark any remaining [non-existent] cpus as on node 0.
+	 * That's where their [unused] per cpu data will be allocated.
+	 */
+	for (cpu=3Davailable_cpus; cpu < NR_CPUS; ++cpu) {
+		node_cpuid[cpu].nid   =3D 0;
+		node_cpuid[i].phys_id =3D 0;
+	}
+
+	srat_num_cpus =3D available_cpus;
+
+}
+
+#define NUMA_EMU_INTRANODE_DISTANCE 10
+#define NUMA_EMU_INTERNODE_DISTANCE 20  // TODO:  ???
+static void __init
+acpi_numa_emu_slit(void)
+{
+	struct acpi_table_slit* slit;
+	int ifrom, ito;
+
+	slit =3D (struct acpi_table_slit*)&acpi_table_slit_emu;
+
+	/*
+	 * We only need to initialize slit table members:
+	 * localities and the corresponding entry[]'s
+	 */
+	slit->localities =3D numa_fake;
+
+	for(ifrom =3D 0; ifrom < numa_fake; ++ifrom) {
+		for(ito =3D 0; ito < numa_fake; ++ito) {
+			slit->entry[ifrom*numa_fake + ito] +			      (ifrom =3D ito) ? NUMA_EMU=
_INTRANODE_DISTANCE
+			                     : NUMA_EMU_INTERNODE_DISTANCE;
+		}
+	}
+
+	slit_table =3D slit;
+}
+
+#define NUMA_FIXUP_CONTINUE 0 /* multi-node:  real or emulated */
+#define NUMA_FIXUP_DONE 1     /* single node */
+static int __init
+acpi_numa_emulation_init(void)
+{
+	char *cp;
+
+	/*
+	 * Don't attempt fake numa if SRAT exists and contains more than
+	 * one proximity domain.
+	 */
+	if (srat_num_cpus !=3D 0) {
+		int i, pxm_id, npxm=3D0;
+
+		for (i =3D 0; i < MAX_PXM_DOMAINS; ++i) {
+			if (pxm_bit_test(i) && ++npxm > 1 )
+				break;	/* no need to look further */
+			pxm_id =3D i;
+		}
+
+		if (npxm > 1) {
+			printk(KERN_INFO
+				"> 1 proximity domain =3D> no NUMA emulation\n");
+			return NUMA_FIXUP_CONTINUE;
+		}
+
+		/*
+		 * Clear the pxm flag for the only pxm.
+		 * We'll reassign a fake one when we emulate processor affinity.
+		 * TODO:  will this adversly impact the SGI SN platform?
+		 *        See:  sn/kernel/setup.c:sn_init_pdas() which uses
+		 *        nid_to_pxm_map[].  Or is boot pxm always zero in SRAT?
+		 */
+		clear_bit(pxm_id, (void *)pxm_flag);
+	}
+
+	/*
+	 * Still too early to use the standard kernel command line support...
+	 */
+	for (cp =3D saved_command_line; *cp; ) {
+		if (memcmp(cp, "numa=FAke", 9) =3D 0) {
+			cp +=3D 9;
+			if (*(cp++) =3D '=3D') {
+				numa_fake =3D simple_strtoul(cp, NULL, 0);
+			} else {
+				numa_fake =3D 2;	/* default */
+			}
+			break;
+		} else {
+			while (*cp !=3D ' ' && *cp)
+				++cp;
+			while (*cp =3D ' ')
+				++cp;
+		}
+	}
+
+	if (numa_fake < 2)
+		goto one_node;
+
+	printk(KERN_INFO "%s:  NUMA Emulation requested:  %d nodes\n",
+	       __FUNCTION__, numa_fake);
+
+	/*
+	 * Validate/sanitize numa_fake and setup numa emulation so that
+	 * the rest of acpi_numa_arch_fixup() "just works".
+	 */
+	if ((!srat_num_cpus && acpi_numa_emu_count_cpus() < 2)
+			|| srat_num_cpus =3D 1) {
+		printk(KERN_WARNING
+		   "%s:  abandoning NUMA Emulation because we have < 2 cpus\n",
+		   __FUNCTION__);
+		/*
+		 * could also be because parse of MADT failed...
+		 */
+		goto one_node;
+	}
+
+	if (numa_fake > available_cpus) {
+		numa_fake =3D available_cpus;
+		printk(KERN_INFO
+		   "%s:  reducing NUMA Emulation to available cpus: %d\n",
+		   __FUNCTION__, numa_fake);
+	}
+
+	if (numa_fake > MAX_NUMNODES) {  /* VERY unlikely, at this point */
+		numa_fake =3D MAX_NUMNODES;
+		printk(KERN_INFO
+		   "%s:  reducing NUMA Emulation to MAX_NUMNODES: %d\n",
+		   __FUNCTION__, numa_fake);
+	}
+
+	/*
+	 * Do memory affinity emulation before processors because
+	 * this can fail.  Don't want to touch srat_num_cpus nor
+	 * node_cpuid[] unless we're sure we're going to emulate
+	 * multiple nodes.  Else bad things happen later.
+	 */
+	if (acpi_numa_emu_memory_affinity()) {
+		printk(KERN_WARNING
+		   "%s:  abandoning NUMA Emulation because memory"
+		   " affinity emulation failed\n", __FUNCTION__);
+		goto one_node;
+	}
+
+	acpi_numa_emu_processor_affinity();
+
+	acpi_numa_emu_slit();
+
+	return NUMA_FIXUP_CONTINUE;
+
+one_node:
+	num_node_memblks =3D 0;  /* in case we've mucked with it */
+	node_set_online(0);
+	node_cpuid[0].phys_id =3D hard_smp_processor_id();
+	// TODO:  anything else?
+	return NUMA_FIXUP_DONE;
+
+}
+#endif /* ! CONFIG_NUMA_EMU */
+
 void __init acpi_numa_arch_fixup(void)
 {
 	int i, j, node_from, node_to;
=20
+#ifndef CONFIG_NUMA_EMU
 	/* If there's no SRAT, fix the phys_id and mark node 0 online */
 	if (srat_num_cpus =3D 0) {
 		node_set_online(0);
 		node_cpuid[0].phys_id =3D hard_smp_processor_id();
 		return;
 	}
+#else
+	if (acpi_numa_emulation_init() =3D NUMA_FIXUP_DONE)
+		return;
+#endif
=20
 	/*
-	 * MCD - This can probably be dropped now.  No need for pxm ID to node ID
-	 * mapping with sparse node numbering iff MAX_PXM_DOMAINS <=3D MAX_NUMNOD=
ES.
+	 * MCD - This can probably be dropped now.  No need for pxm ID to node
+	 * ID mapping with sparse node numbering iff MAX_PXM_DOMAINS <+	 * MAX_NU=
MNODES.
 	 */
 	/* calculate total number of nodes in system from PXM bitmap */
 	memset(pxm_to_nid_map, -1, sizeof(pxm_to_nid_map));
@@ -649,6 +1121,9 @@ int __init acpi_boot_init(void)
 		printk(KERN_ERR PREFIX
 		       "Error parsing LAPIC address override entry\n");
=20
+#ifdef CONFIG_NUMA_EMU
+	if (!already_parsed_lsapic)
+#endif
 	if (acpi_table_parse_madt(ACPI_MADT_LSAPIC, acpi_parse_lsapic, NR_CPUS)
 	    < 1)
 		printk(KERN_ERR PREFIX
--- fakenuma-2.6.14-rc4/arch/ia64/kernel/efi.c~original	2005-08-28 19:41:01=
.000000000 -0400
+++ fakenuma-2.6.14-rc4/arch/ia64/kernel/efi.c	2005-10-19 10:54:55.00000000=
0 -0400
@@ -862,3 +862,112 @@ efi_uart_console_only(void)
 	printk(KERN_ERR "Malformed %s value\n", name);
 	return 0;
 }
+
+#ifdef CONFIG_NUMA_EMU
+/*
+ * efi_numa_emu_find_physmem()
+ *
+ * walk efi memory map to find contiguous ranges of physical memory to emu=
late
+ * SRAT info.  Can't use existing efi_memmap_walk() because it doesn't rep=
ort
+ * all memory, and we don't want to be making assumptions about what physi=
cal
+ * memory REALLY exists, from the chunks passed to the callback.
+ *
+ * We'll use that same callback prototype as efi_memmap_walk() to avoid
+ * introducing new inter-module types for numa emulation.
+ */
+
+//TODO:  verify this:
+#define is_physmem(MD) \
+	((MD)->type !=3D EFI_MEMORY_MAPPED_IO  && \
+	 (MD)->type !=3D EFI_MEMORY_MAPPED_IO_PORT_SPACE )
+
+int __init
+efi_numa_emu_find_physmem(efi_freemem_callback_t callback, void *arg)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	u64 efi_desc_size, start =3D 0, end, prev_end =3D 0;
+	unsigned long total_mem =3D 0, *total_mem_p =3D arg;
+	int prev_is_physmem =3D 0;
+
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
+	*total_mem_p =3D 0;
+
+	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
+		efi_memory_desc_t *md =3D p;
+		int physmem_after_gap =3D 0;
+
+		if(is_physmem(md)) {
+			if(!prev_is_physmem) {
+				/*
+				 * start a new physmem segment
+				 */
+				start  =3D md->phys_addr;
+				prev_end =3D start +
+					(md->num_pages << EFI_PAGE_SHIFT);
+				prev_is_physmem =3D 1;
+				continue;
+			} else if(prev_end =3D md->phys_addr) {
+				/*
+				 * accumulate contiguous physmem
+				 */
+				prev_end +=3D (md->num_pages << EFI_PAGE_SHIFT);
+				continue;
+			} else {
+				/*
+				 * report prev segment and start a new one
+				 */
+				physmem_after_gap =3D 1;
+			}
+		}
+
+		/*
+		 * md represents a non-physmem descriptor or
+		 * phys memory after a gap in the map
+		 */
+		if(prev_is_physmem) {
+
+			/*
+			 * no sense in reporting phys mem that
+			 * efi_memmap_walk() will trim
+			 */
+			start =3D GRANULEROUNDUP(start);
+			end   =3D GRANULEROUNDDOWN(prev_end);
+			if(start < end) {
+				total_mem +=3D end - start;
+				if((*callback)(start, end, NULL))
+					return -1;
+			}
+
+			if (physmem_after_gap) {
+				start  =3D md->phys_addr;
+				prev_end =3D start +
+					(md->num_pages << EFI_PAGE_SHIFT);
+				prev_is_physmem =3D 1;
+			} else
+				prev_is_physmem =3D 0;
+
+		}
+
+	} /* for each map descriptor */
+
+	if(prev_is_physmem) {
+
+		/*
+		 * no sense in reporting phys mem that
+		 * efi_memmap_walk() will trim
+		 */
+		start =3D GRANULEROUNDUP(start);
+		end   =3D GRANULEROUNDDOWN(prev_end);
+		if(start < end) {
+			total_mem +=3D end - start;
+			if ((*callback)(start, end, NULL))
+				return -1;
+		}
+	}
+
+	*total_mem_p =3D total_mem;
+	return 0;
+}
+#endif  /* CONFIG_NUMA_EMU */
--- fakenuma-2.6.14-rc4/arch/ia64/mm/discontig.c~original	2005-08-28 19:41:=
01.000000000 -0400
+++ fakenuma-2.6.14-rc4/arch/ia64/mm/discontig.c	2005-10-19 10:48:52.000000=
000 -0400
@@ -201,8 +201,8 @@ static void __init fill_pernode(int node
  *   |                        |
  *   |~~~~~~~~~~~~~~~~~~~~~~~~| <-- NODEDATA_ALIGN(start, node) for the fi=
rst
  *   |    PERCPU_PAGE_SIZE *  |     start and length big enough
- *   |    cpus_on_this_node   | Node 0 will also have entries for all non-=
existent cpus.
- *   |------------------------|
+ *   |    cpus_on_this_node   | Node 0 will also have entries for all
+ *   |------------------------| non-existent cpus.
  *   |   local pg_data_t *    |
  *   |------------------------|
  *   |  local ia64_node_data  |
@@ -224,9 +224,6 @@ static int __init find_pernode_space(uns
=20
 	epfn =3D (start + len) >> PAGE_SHIFT;
=20
-	pages =3D bdp->node_low_pfn - (bdp->node_boot_start >> PAGE_SHIFT);
-	mapsize =3D bootmem_bootmap_pages(pages) << PAGE_SHIFT;
-
 	/*
 	 * Make sure this memory falls within this node's usable memory
 	 * since we may have thrown some away in build_maps().
@@ -242,6 +239,8 @@ static int __init find_pernode_space(uns
 	 * Calculate total size needed, incl. what's necessary
 	 * for good alignment and alias prevention.
 	 */
+	pages =3D bdp->node_low_pfn - (bdp->node_boot_start >> PAGE_SHIFT);
+	mapsize =3D bootmem_bootmap_pages(pages) << PAGE_SHIFT;
 	pernodesize =3D compute_pernodesize(node);
 	pernode =3D NODEDATA_ALIGN(start, node);
=20
--- fakenuma-2.6.14-rc4/arch/ia64/Kconfig~original	2005-10-17 11:56:51.0000=
00000 -0400
+++ fakenuma-2.6.14-rc4/arch/ia64/Kconfig	2005-10-17 13:49:26.000000000 -04=
00
@@ -186,6 +186,15 @@ config NUMA
 	  Access).  This option is for configuring high-end multiprocessor
 	  server systems.  If in doubt, say N.
=20
+# move to Kconfig.debug?
+config NUMA_EMU
+	bool "NUMA emulation support"
+	depends on NUMA
+	help
+	  Enable NUMA emulation. A flat machine will be split
+	  into virtual nodes when booted with "numa=FAke=3DN", where N is the
+	  number of nodes. This is only useful for debugging.
+
 config VIRTUAL_MEM_MAP
 	bool "Virtual mem map"
 	default y if !IA64_HP_SIM
@@ -233,7 +242,14 @@ config IA64_SGI_SN_XP
=20
 config FORCE_MAX_ZONEORDER
 	int
-	default "18"
+	range 11 20
+	default "18" if !NUMA_EMU
+	default "14" if NUMA_EMU
+	help
+	  This parameter affects on pagesize of HugetlbFS and SectionSize.
+	  Max pagesize of HugetlbFS is PAGE_SIZE << MAX_ORDER.
+	  If using SPARSEMEM, Min SectionSize is PAGESIZE << MAX_ORDER.
+	  SectionSize is a unit of Hotpluggable Memory Size.
=20
 config SMP
 	bool "Symmetric multi-processing support"
--- fakenuma-2.6.14-rc4/include/linux/efi.h~original	2005-10-17 11:56:54.00=
0000000 -0400
+++ fakenuma-2.6.14-rc4/include/linux/efi.h	2005-10-19 10:55:37.000000000 -=
0400
@@ -166,8 +166,8 @@ typedef efi_status_t efi_get_variable_t=20
 					 unsigned long *data_size, void *data);
 typedef efi_status_t efi_get_next_variable_t (unsigned long *name_size, ef=
i_char16_t *name,
 					      efi_guid_t *vendor);
-typedef efi_status_t efi_set_variable_t (efi_char16_t *name, efi_guid_t *v=
endor,=20
-					 unsigned long attr, unsigned long data_size,=20
+typedef efi_status_t efi_set_variable_t (efi_char16_t *name, efi_guid_t *v=
endor,
+					 unsigned long attr, unsigned long data_size,
 					 void *data);
 typedef efi_status_t efi_get_next_high_mono_count_t (u32 *count);
 typedef void efi_reset_system_t (int reset_type, efi_status_t status,
@@ -324,6 +324,10 @@ static inline int efi_range_is_wc(unsign
 extern int __init efi_setup_pcdp_console(char *);
 #endif
=20
+#ifdef CONFIG_NUMA_EMU
+extern int efi_numa_emu_find_physmem(efi_freemem_callback_t, void*);
+#endif
+
 /*
  * We play games with efi_enabled so that the compiler will, if possible, =
remove
  * EFI-related code altogether.
--- fakenuma-2.6.14-rc4/fs/Kconfig~original	2005-10-17 11:56:53.000000000 -=
0400
+++ fakenuma-2.6.14-rc4/fs/Kconfig	2005-10-17 13:49:26.000000000 -0400
@@ -808,9 +808,11 @@ config TMPFS
=20
 	  See <file:Documentation/filesystems/tmpfs.txt> for details.
=20
+# disallow HUGETLBFS when emulating numa because we reduce MAX_ORDER
+# evenutally, may address by adjusting hpage_shift
 config HUGETLBFS
 	bool "HugeTLB file system support"
-	depends X86 || IA64 || PPC64 || SPARC64 || SUPERH || X86_64 || BROKEN
+	depends X86 || IA64 || PPC64 || SPARC64 || SUPERH || X86_64 || BROKEN && =
!NUMA_EMU
=20
 config HUGETLB_PAGE
 	def_bool HUGETLBFS


