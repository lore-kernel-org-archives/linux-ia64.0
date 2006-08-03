From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Aug 2006 19:18:40 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200608031918.k73JIe6x014364@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/sim/simscsi.c        |    4 +-
 arch/ia64/kernel/efi.c            |    6 +--
 arch/ia64/kernel/head.S           |    2 -
 arch/ia64/kernel/ia64_ksyms.c     |    2 -
 arch/ia64/kernel/pal.S            |   18 +++++-----
 arch/ia64/kernel/palinfo.c        |   34 +++++++------------
 arch/ia64/lib/Makefile            |    2 -
 arch/ia64/mm/contig.c             |   16 ++++++--
 arch/ia64/mm/discontig.c          |   68 ++-------------------------------=
-----
 arch/ia64/mm/init.c               |   55 ++++++++++++++++++++++++++++++
 arch/ia64/mm/ioremap.c            |    6 +--
 arch/ia64/sn/kernel/xpc_main.c    |    2 -
 arch/ia64/sn/pci/tioce_provider.c |    6 +--
 drivers/char/snsc.c               |    7 +++
 include/asm-ia64/meminit.h        |    7 +++
 include/asm-ia64/pal.h            |    7 +++
 include/asm-ia64/sn/xpc.h         |    4 +-
 include/asm-ia64/system.h         |    2 -
 18 files changed, 128 insertions(+), 120 deletions(-)

Bob Picco:
      [IA64] align high endpoint of VIRTUAL_MEM_MAP
      [IA64] fix show_mem for VIRTUAL_MEM_MAP+FLATMEM

Greg Edwards:
      [IA64] add platform check to snsc driver init

Keith Owens:
      [IA64] sparse cleanups

Matthew Wilcox:
      [IA64] Format /proc/pal/*/version_info correctly

Prarit Bhargava:
      Fix RAID5 + IA64 compile

Tony Luck:
      [IA64] Fix breakage in simscsi.c

Zou Nan hai:
      [IA64] Do not assume output registers be reservered.
      [IA64] Don't alloc empty frame in ia64_switch_mode_phys

commit e44e41d0c832ebbda7311a1fe43584d844026357
Author: Bob Picco <bob.picco@hp.com>
Date:   Wed Jun 28 12:55:43 2006 -0400

    [IA64] fix show_mem for VIRTUAL_MEM_MAP+FLATMEM
   =20
    contig.c (FLATMEM) requires the same optimization as in discontig.c for=
 show_mem
    when VIRTUAL_MEM_MAP is in use. Otherwise FLATMEM has softlockup timeou=
ts.
    This was boot tested for memory configuration: SPARSEMEM,
    DISCONTIG+VIRTUAL_MEM_MAP, FLATMEM, FLATMEM+VIRTUAL_MEM_MAP and
    FLATMEM+VIRTUAL_MEM_MAP with largest memory gap less than LARGE_GAP by
    using boot parameter "mem=3D".
   =20
    This was boot tested and "echo m >/proc/sysrq-trigger" output evaluated=
 for
    : FLATMEM, FLATMEM+VIRTUAL_MEM_MAP, DISCONTIGMEM+VIRTUAL_MEM_MAP and
    SPARSEMEM.
   =20
    Signed-off-by: Bob Picco <bob.picco@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 8919fed..e004143 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -27,6 +27,7 @@ #include <asm/mca.h>
=20
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 static unsigned long num_dma_physpages;
+static unsigned long max_gap;
 #endif
=20
 /**
@@ -45,9 +46,15 @@ show_mem (void)
=20
 	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
 	i =3D max_mapnr;
-	while (i-- > 0) {
-		if (!pfn_valid(i))
+	for (i =3D 0; i < max_mapnr; i++) {
+		if (!pfn_valid(i)) {
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+			if (max_gap < LARGE_GAP)
+				continue;
+			i =3D vmemmap_find_next_valid_pfn(0, i) - 1;
+#endif
 			continue;
+		}
 		total++;
 		if (PageReserved(mem_map+i))
 			reserved++;
@@ -234,7 +241,6 @@ paging_init (void)
 	unsigned long zones_size[MAX_NR_ZONES];
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 	unsigned long zholes_size[MAX_NR_ZONES];
-	unsigned long max_gap;
 #endif
=20
 	/* initialize mem_map[] */
@@ -266,7 +272,6 @@ #ifdef CONFIG_VIRTUAL_MEM_MAP
 		}
 	}
=20
-	max_gap =3D 0;
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
 		vmem_map =3D (struct page *) 0;
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 8eeb669..d260bff 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -534,68 +534,6 @@ void __cpuinit *per_cpu_init(void)
 }
 #endif /* CONFIG_SMP */
=20
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-static inline int find_next_valid_pfn_for_pgdat(pg_data_t *pgdat, int i)
-{
-	unsigned long end_address, hole_next_pfn;
-	unsigned long stop_address;
-
-	end_address =3D (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
-	end_address =3D PAGE_ALIGN(end_address);
-
-	stop_address =3D (unsigned long) &vmem_map[
-		pgdat->node_start_pfn + pgdat->node_spanned_pages];
-
-	do {
-		pgd_t *pgd;
-		pud_t *pud;
-		pmd_t *pmd;
-		pte_t *pte;
-
-		pgd =3D pgd_offset_k(end_address);
-		if (pgd_none(*pgd)) {
-			end_address +=3D PGDIR_SIZE;
-			continue;
-		}
-
-		pud =3D pud_offset(pgd, end_address);
-		if (pud_none(*pud)) {
-			end_address +=3D PUD_SIZE;
-			continue;
-		}
-
-		pmd =3D pmd_offset(pud, end_address);
-		if (pmd_none(*pmd)) {
-			end_address +=3D PMD_SIZE;
-			continue;
-		}
-
-		pte =3D pte_offset_kernel(pmd, end_address);
-retry_pte:
-		if (pte_none(*pte)) {
-			end_address +=3D PAGE_SIZE;
-			pte++;
-			if ((end_address < stop_address) &&
-			    (end_address !=3D ALIGN(end_address, 1UL << PMD_SHIFT)))
-				goto retry_pte;
-			continue;
-		}
-		/* Found next valid vmem_map page */
-		break;
-	} while (end_address < stop_address);
-
-	end_address =3D min(end_address, stop_address);
-	end_address =3D end_address - (unsigned long) vmem_map + sizeof(struct pa=
ge) - 1;
-	hole_next_pfn =3D end_address / sizeof(struct page);
-	return hole_next_pfn - pgdat->node_start_pfn;
-}
-#else
-static inline int find_next_valid_pfn_for_pgdat(pg_data_t *pgdat, int i)
-{
-	return i + 1;
-}
-#endif
-
 /**
  * show_mem - give short summary of memory stats
  *
@@ -625,7 +563,8 @@ void show_mem(void)
 			if (pfn_valid(pgdat->node_start_pfn + i))
 				page =3D pfn_to_page(pgdat->node_start_pfn + i);
 			else {
-				i =3D find_next_valid_pfn_for_pgdat(pgdat, i) - 1;
+				i =3D vmemmap_find_next_valid_pfn(pgdat->node_id,
+					 i) - 1;
 				continue;
 			}
 			if (PageReserved(page))
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 2f50c06..30617cc 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -415,6 +415,61 @@ #endif
 }
=20
 #ifdef CONFIG_VIRTUAL_MEM_MAP
+int vmemmap_find_next_valid_pfn(int node, int i)
+{
+	unsigned long end_address, hole_next_pfn;
+	unsigned long stop_address;
+	pg_data_t *pgdat =3D NODE_DATA(node);
+
+	end_address =3D (unsigned long) &vmem_map[pgdat->node_start_pfn + i];
+	end_address =3D PAGE_ALIGN(end_address);
+
+	stop_address =3D (unsigned long) &vmem_map[
+		pgdat->node_start_pfn + pgdat->node_spanned_pages];
+
+	do {
+		pgd_t *pgd;
+		pud_t *pud;
+		pmd_t *pmd;
+		pte_t *pte;
+
+		pgd =3D pgd_offset_k(end_address);
+		if (pgd_none(*pgd)) {
+			end_address +=3D PGDIR_SIZE;
+			continue;
+		}
+
+		pud =3D pud_offset(pgd, end_address);
+		if (pud_none(*pud)) {
+			end_address +=3D PUD_SIZE;
+			continue;
+		}
+
+		pmd =3D pmd_offset(pud, end_address);
+		if (pmd_none(*pmd)) {
+			end_address +=3D PMD_SIZE;
+			continue;
+		}
+
+		pte =3D pte_offset_kernel(pmd, end_address);
+retry_pte:
+		if (pte_none(*pte)) {
+			end_address +=3D PAGE_SIZE;
+			pte++;
+			if ((end_address < stop_address) &&
+			    (end_address !=3D ALIGN(end_address, 1UL << PMD_SHIFT)))
+				goto retry_pte;
+			continue;
+		}
+		/* Found next valid vmem_map page */
+		break;
+	} while (end_address < stop_address);
+
+	end_address =3D min(end_address, stop_address);
+	end_address =3D end_address - (unsigned long) vmem_map + sizeof(struct pa=
ge) - 1;
+	hole_next_pfn =3D end_address / sizeof(struct page);
+	return hole_next_pfn - pgdat->node_start_pfn;
+}
=20
 int __init
 create_mem_map_page_table (u64 start, u64 end, void *arg)
diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
index 894bc4d..6a33a07 100644
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
@@ -56,6 +56,11 @@ # define LARGE_GAP	0x40000000 /* Use vir
   extern struct page *vmem_map;
   extern int find_largest_hole (u64 start, u64 end, void *arg);
   extern int create_mem_map_page_table (u64 start, u64 end, void *arg);
+  extern int vmemmap_find_next_valid_pfn(int, int);
+#else
+static inline int vmemmap_find_next_valid_pfn(int node, int i)
+{
+	return i + 1;
+}
 #endif
-
 #endif /* meminit_h */

commit 921eea1cdf6ce7f0db88e4579474a04b1fb0fe6d
Author: Bob Picco <bob.picco@hp.com>
Date:   Wed Jun 28 12:54:55 2006 -0400

    [IA64] align high endpoint of VIRTUAL_MEM_MAP
   =20
    Assure that vmem_map's high endpoint is MAX_ORDER aligned. Not doing so=
 violates
    the buddy allocator algorithm. Also anyone using mem=3DXXX on boot line=
 and
    not aligned to MAX_ORDER requires this patch in order to satisfy buddy
    allocator. vmem_map always starts at pfn 0. The potentially large MAX_O=
RDER
    on ia64 (due to hugetlbfs) requires that the end of vmem_map be aligned
    to MAX_ORDER_NR_PAGES.
   =20
    This was boot tested for: FLATMEM, FLATMEM+VIRTUAL_MEM_MAP,
    DISCONTIGMEM+VIRTUAL_MEM_MAP and SPARSEMEM.
   =20
    Signed-off-by: Bob Picco <bob.picco@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 2a88cdd..8919fed 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -277,7 +277,8 @@ #ifdef CONFIG_VIRTUAL_MEM_MAP
=20
 		/* allocate virtual_mem_map */
=20
-		map_size =3D PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+		map_size =3D PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
+			sizeof(struct page));
 		vmalloc_end -=3D map_size;
 		vmem_map =3D (struct page *) vmalloc_end;
 		efi_memmap_walk(create_mem_map_page_table, NULL);
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 99bd9e3..8eeb669 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -751,7 +751,8 @@ void __init paging_init(void)
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
=20
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-	vmalloc_end -=3D PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+	vmalloc_end -=3D PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *
+		sizeof(struct page));
 	vmem_map =3D (struct page *) vmalloc_end;
 	efi_memmap_walk(create_mem_map_page_table, NULL);
 	printk("Virtual mem_map starts at 0x%p\n", vmem_map);

commit 0a69ca91be2b36f99a48daacd1f12d9d49ecaf87
Author: Prarit Bhargava <prarit@redhat.com>
Date:   Mon Jul 31 09:12:11 2006 -0400

    [PATCH] Fix RAID5 + IA64 compile
   =20
    CONFIG_MD_RAID5 became CONFIG_MD_RAID456 in drivers/md/Kconfig.  Make
    the same change in arch/ia64
   =20
    Signed-off-by: Prarit Bhargava <prarit@redhat.com>
    Signed-off-by: Aron Griffis <aron@hp.com>
    Acked-by: Jes Sorenson <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index b7cf651..3ead20f 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -62,7 +62,7 @@ EXPORT_SYMBOL(__udivdi3);
 EXPORT_SYMBOL(__moddi3);
 EXPORT_SYMBOL(__umoddi3);
=20
-#if defined(CONFIG_MD_RAID5) || defined(CONFIG_MD_RAID5_MODULE)
+#if defined(CONFIG_MD_RAID456) || defined(CONFIG_MD_RAID456_MODULE)
 extern void xor_ia64_2(void);
 extern void xor_ia64_3(void);
 extern void xor_ia64_4(void);
diff --git a/arch/ia64/lib/Makefile b/arch/ia64/lib/Makefile
index d8536a2..38fa6e4 100644
--- a/arch/ia64/lib/Makefile
+++ b/arch/ia64/lib/Makefile
@@ -14,7 +14,7 @@ lib-y :=3D __divsi3.o __udivsi3.o __modsi3
 lib-$(CONFIG_ITANIUM)	+=3D copy_page.o copy_user.o memcpy.o
 lib-$(CONFIG_MCKINLEY)	+=3D copy_page_mck.o memcpy_mck.o
 lib-$(CONFIG_PERFMON)	+=3D carta_random.o
-lib-$(CONFIG_MD_RAID5)	+=3D xor.o
+lib-$(CONFIG_MD_RAID456)	+=3D xor.o
=20
 AFLAGS___divdi3.o	 AFLAGS___udivdi3.o	=3D -DUNSIGNED

commit e55ce456155813ca34e105d0e05306edad05cf6e
Author: Zou Nan hai <nanhai.zou@intel.com>
Date:   Wed Jul 26 07:36:40 2006 +0800

    [IA64] Don't alloc empty frame in ia64_switch_mode_phys
   =20
    I think ia64_switch_mode_phys and ia64_switch_mode_virt
    does not need to alloc an empty frame.
    An empty frame is required by loadrs but flushrs
    does not need that.
   =20
    Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 561b8f1..29236f0 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -853,7 +853,6 @@ END(__ia64_init_fpu)
  */
 GLOBAL_ENTRY(ia64_switch_mode_phys)
  {
-	alloc r2=3Dar.pfs,0,0,0,0
 	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
 	mov r15=3Dip
  }
@@ -902,7 +901,6 @@ END(ia64_switch_mode_phys)
  */
 GLOBAL_ENTRY(ia64_switch_mode_virt)
  {
-	alloc r2=3Dar.pfs,0,0,0,0
 	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
 	mov r15=3Dip
  }

commit acb15c85de57d81d773b6e4184b7cb143ce83eba
Author: Zou Nan hai <nanhai.zou@intel.com>
Date:   Wed Jul 26 07:26:51 2006 +0800

    [IA64] Do not assume output registers be reservered.
   =20
    We found an issue in pal.S.
   =20
    According to the software runtime SPEC,
    The caller's output registers do not need to be preserved for
    caller. The callee may reuse input registers for any other
    purpose within the procedure.
   =20
    in ia64_pal_call_phys_stacked,
   =20
    input registers are copied to output registers before call
    into ia64_switch_mode_phys, then used to call into PAL. This
    assumes output registers are preserved in ia64_switch_mode_phys,
    which may not be true.
   =20
    In this particular case, ia64_switch_mode_phys alloc a null frame
    , and mask off psr.i.
    If an interrupt comes at this small window,
    or an MCA comes inside the procedure, output registers
    maybe changed,
    then the pal call may got some staled input registers.
   =20
    This patch moves the copies from input to output
    after ia64_switch_mode_phys to follow the software
    runtime convention.
   =20
    It  also removed some unused labels in
    ia64_pal_call_phys_stacked.
   =20
    Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
index 5018c7f..ebaf1e6 100644
--- a/arch/ia64/kernel/pal.S
+++ b/arch/ia64/kernel/pal.S
@@ -217,12 +217,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	.body
 	;;
 	ld8 loc2 =3D [loc2]		// loc2 <- entry point
-	mov out0 =3D in0		// first argument
-	mov out1 =3D in1		// copy arg2
-	mov out2 =3D in2		// copy arg3
-	mov out3 =3D in3		// copy arg3
-	;;
-	mov loc3 =3D psr		// save psr
+	mov loc3 =3D psr			// save psr
 	;;
 	mov loc4=3Dar.rsc			// save RSE configuration
 	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
@@ -236,18 +231,23 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	;;
 	andcm r16=3Dloc3,r16		// removes bits to clear from psr
 	br.call.sptk.many rp=3Dia64_switch_mode_phys
-.ret6:
+
+	mov out0 =3D in0			// first argument
+	mov out1 =3D in1			// copy arg2
+	mov out2 =3D in2			// copy arg3
+	mov out3 =3D in3			// copy arg3
 	mov loc5 =3D r19
 	mov loc6 =3D r20
+
 	br.call.sptk.many rp=B7		// now make the call
-.ret7:
+
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
 	mov r19=3Dloc5
 	mov r20=3Dloc6
 	br.call.sptk.many rp=3Dia64_switch_mode_virt	// return to virtual mode
=20
-.ret8:	mov psr.l  =3D loc3		// restore init PSR
+	mov psr.l  =3D loc3		// restore init PSR
 	mov ar.pfs =3D loc1
 	mov rp =3D loc0
 	;;

commit c7c17423b9ea3c5559cfb480a00844f1df9eed06
Author: Greg Edwards <edwardsg@sgi.com>
Date:   Fri Jul 28 10:03:55 2006 -0500

    [IA64] add platform check to snsc driver init
   =20
    Add a platform check to the snsc driver init function, to prevent
    loading on non-sn2 systems.
   =20
    Signed-off-by: Greg Edwards <edwardsg@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/drivers/char/snsc.c b/drivers/char/snsc.c
index afc6eda..07e0b75 100644
--- a/drivers/char/snsc.c
+++ b/drivers/char/snsc.c
@@ -374,7 +374,12 @@ scdrv_init(void)
 	struct sysctl_data_s *scd;
 	void *salbuf;
 	dev_t first_dev, dev;
-	nasid_t event_nasid =3D ia64_sn_get_console_nasid();
+	nasid_t event_nasid;
+
+	if (!ia64_platform_is("sn2"))
+		return -ENODEV;
+
+	event_nasid =3D ia64_sn_get_console_nasid();
=20
 	if (alloc_chrdev_region(&first_dev, 0, num_cnodes,
 				SYSCTL_BASENAME) < 0) {

commit e037cda559547e6353c5a792802963572d0b750e
Author: Keith Owens <kaos@sgi.com>
Date:   Mon Jul 17 15:41:59 2006 +1000

    [IA64] sparse cleanups
   =20
    Fix some sparse warnings on ia64.  Large constants that should be long
    instead of int.  Use NULL instead of 0.  Add some missing __iomem
    casts.  Replace a non-C99 structure assignment.
   =20
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index e4bfa9d..bb8770a 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -632,7 +632,7 @@ kern_memory_descriptor (unsigned long ph
 		if (phys_addr - md->start < (md->num_pages << EFI_PAGE_SHIFT))
 			 return md;
 	}
-	return 0;
+	return NULL;
 }
=20
 static efi_memory_desc_t *
@@ -652,7 +652,7 @@ efi_memory_descriptor (unsigned long phy
 		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
 			 return md;
 	}
-	return 0;
+	return NULL;
 }
=20
 u32
@@ -923,7 +923,7 @@ find_memmap_space (void)
 void
 efi_memmap_init(unsigned long *s, unsigned long *e)
 {
-	struct kern_memdesc *k, *prev =3D 0;
+	struct kern_memdesc *k, *prev =3D NULL;
 	u64	contig_low=3D0, contig_high=3D0;
 	u64	as, ae, lim;
 	void *efi_map_start, *efi_map_end, *p, *q;
diff --git a/arch/ia64/mm/ioremap.c b/arch/ia64/mm/ioremap.c
index 07bd02b..4280c07 100644
--- a/arch/ia64/mm/ioremap.c
+++ b/arch/ia64/mm/ioremap.c
@@ -32,7 +32,7 @@ ioremap (unsigned long offset, unsigned=20
 	 */
 	attr =3D kern_mem_attribute(offset, size);
 	if (attr & EFI_MEMORY_WB)
-		return phys_to_virt(offset);
+		return (void __iomem *) phys_to_virt(offset);
 	else if (attr & EFI_MEMORY_UC)
 		return __ioremap(offset, size);
=20
@@ -43,7 +43,7 @@ ioremap (unsigned long offset, unsigned=20
 	gran_base =3D GRANULEROUNDDOWN(offset);
 	gran_size =3D GRANULEROUNDUP(offset + size) - gran_base;
 	if (efi_mem_attribute(gran_base, gran_size) & EFI_MEMORY_WB)
-		return phys_to_virt(offset);
+		return (void __iomem *) phys_to_virt(offset);
=20
 	return __ioremap(offset, size);
 }
@@ -53,7 +53,7 @@ void __iomem *
 ioremap_nocache (unsigned long offset, unsigned long size)
 {
 	if (kern_mem_attribute(offset, size) & EFI_MEMORY_WB)
-		return 0;
+		return NULL;
=20
 	return __ioremap(offset, size);
 }
diff --git a/arch/ia64/sn/kernel/xpc_main.c b/arch/ia64/sn/kernel/xpc_main.c
index 99b123a..5e8e59e 100644
--- a/arch/ia64/sn/kernel/xpc_main.c
+++ b/arch/ia64/sn/kernel/xpc_main.c
@@ -480,7 +480,7 @@ xpc_activating(void *__partid)
 	partid_t partid =3D (u64) __partid;
 	struct xpc_partition *part =3D &xpc_partitions[partid];
 	unsigned long irq_flags;
-	struct sched_param param =3D { sched_priority: MAX_RT_PRIO - 1 };
+	struct sched_param param =3D { .sched_priority =3D MAX_RT_PRIO - 1 };
 	int ret;
=20
=20
diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_pro=
vider.c
index 17cd342..af7171a 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -74,7 +74,7 @@ tioce_mmr_war_pre(struct tioce_kernel *k
 		else
 			mmr_war_offset =3D 0x158;
=20
-		readq_relaxed((void *)(mmr_base + mmr_war_offset));
+		readq_relaxed((void __iomem *)(mmr_base + mmr_war_offset));
 	}
 }
=20
@@ -92,8 +92,8 @@ tioce_mmr_war_post(struct tioce_kernel *
=20
 	if (mmr_offset < 0x45000) {
 		if (mmr_offset =3D 0x100)
-			readq_relaxed((void *)(mmr_base + 0x38));
-		readq_relaxed((void *)(mmr_base + 0xb050));
+			readq_relaxed((void __iomem *)(mmr_base + 0x38));
+		readq_relaxed((void __iomem *)(mmr_base + 0xb050));
 	}
 }
=20
diff --git a/include/asm-ia64/sn/xpc.h b/include/asm-ia64/sn/xpc.h
index 8406f1e..b72af59 100644
--- a/include/asm-ia64/sn/xpc.h
+++ b/include/asm-ia64/sn/xpc.h
@@ -1124,8 +1124,8 @@ #define	XPC_IPI_MSGREQUEST	0x10
 #define XPC_GET_IPI_FLAGS(_amo, _c)	((u8) (((_amo) >> ((_c) * 8)) & 0xff))
 #define XPC_SET_IPI_FLAGS(_amo, _c, _f)	(_amo) |=3D ((u64) (_f) << ((_c) *=
 8))
=20
-#define	XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(_amo) ((_amo) & 0x0f0f0f0f0f0f0f0f)
-#define XPC_ANY_MSG_IPI_FLAGS_SET(_amo)       ((_amo) & 0x1010101010101010)
+#define	XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(_amo) ((_amo) & __IA64_UL_CONST(0x=
0f0f0f0f0f0f0f0f))
+#define XPC_ANY_MSG_IPI_FLAGS_SET(_amo)       ((_amo) & __IA64_UL_CONST(0x=
1010101010101010))
=20
=20
 static inline void
diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
index fc9677b..384fbf7 100644
--- a/include/asm-ia64/system.h
+++ b/include/asm-ia64/system.h
@@ -24,7 +24,7 @@ #define GATE_ADDR		RGN_BASE(RGN_GATE)
  * 0xa000000000000000+2*PERCPU_PAGE_SIZE
  * - 0xa000000000000000+3*PERCPU_PAGE_SIZE remain unmapped (guard page)
  */
-#define KERNEL_START		 (GATE_ADDR+0x100000000)
+#define KERNEL_START		 (GATE_ADDR+__IA64_UL_CONST(0x100000000))
 #define PERCPU_ADDR		(-PERCPU_PAGE_SIZE)
=20
 #ifndef __ASSEMBLY__

commit 4f2ef124b274baac80f64e290aa44e87a7753933
Author: Tony Luck <tony.luck@intel.com>
Date:   Fri Jul 28 13:20:23 2006 -0700

    [IA64] Fix breakage in simscsi.c
   =20
    arch/ia64/hp/sim/simscsi.c: In function `simscsi_sg_readwrite':
    arch/ia64/hp/sim/simscsi.c:154: error: structure has no member named `b=
uffer'
    arch/ia64/hp/sim/simscsi.c: In function `simscsi_fillresult':
    arch/ia64/hp/sim/simscsi.c:247: error: structure has no member named `b=
uffer'
   =20
    hch said:
    >Just change it to access the request_buffer member instead.  buffer
    >and request_buffer have been synonymous 99% of the time, and a driver
    >never even wants to access buffer.
   =20
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
index a3fe975..8a4f0d0 100644
--- a/arch/ia64/hp/sim/simscsi.c
+++ b/arch/ia64/hp/sim/simscsi.c
@@ -151,7 +151,7 @@ static void
 simscsi_sg_readwrite (struct scsi_cmnd *sc, int mode, unsigned long offset)
 {
 	int list_len =3D sc->use_sg;
-	struct scatterlist *sl =3D (struct scatterlist *)sc->buffer;
+	struct scatterlist *sl =3D (struct scatterlist *)sc->request_buffer;
 	struct disk_stat stat;
 	struct disk_req req;
=20
@@ -244,7 +244,7 @@ static void simscsi_fillresult(struct sc
=20
 	if (scatterlen =3D 0)
 		memcpy(sc->request_buffer, buf, len);
-	else for (slp =3D (struct scatterlist *)sc->buffer; scatterlen-- > 0 && l=
en > 0; slp++) {
+	else for (slp =3D (struct scatterlist *)sc->request_buffer; scatterlen-- =
> 0 && len > 0; slp++) {
 		unsigned thislen =3D min(len, slp->length);
=20
 		memcpy(page_address(slp->page) + slp->offset, buf, thislen);

commit 1bf1eba74ec14bc10966a8ddb23bc8deeb91facd
Author: Matthew Wilcox <matthew@wil.cx>
Date:   Fri Jun 23 13:15:55 2006 -0600

    [IA64] Format /proc/pal/*/version_info correctly
   =20
    /proc/pal/*/version_info is a bit confusing.  HP firmware, at least,
    reports 07.31 instead of 0.7.31.  Also, the comment is out of place;
    it's an internal detail about the implementation of ia64_pal_version.
    Since the 2.2 revision of the SDM still states that PAL_VERSION can
    be called in virtual mode, correct the comment to be more accurate.
   =20
    Signed-off-by: Matthew Wilcox <matthew@wil.cx>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index 3f5bac5..ce9f199 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -566,29 +566,23 @@ version_info(char *page)
 	pal_version_u_t min_ver, cur_ver;
 	char *p =3D page;
=20
-	/* The PAL_VERSION call is advertised as being able to support
-	 * both physical and virtual mode calls. This seems to be a documentation
-	 * bug rather than firmware bug. In fact, it does only support physical m=
ode.
-	 * So now the code reflects this fact and the pal_version() has been upda=
ted
-	 * accordingly.
-	 */
-	if (ia64_pal_version(&min_ver, &cur_ver) !=3D 0) return 0;
+	if (ia64_pal_version(&min_ver, &cur_ver) !=3D 0)
+		return 0;
=20
 	p +=3D sprintf(p,
 		     "PAL_vendor : 0x%02x (min=3D0x%02x)\n"
-		     "PAL_A      : %x.%x.%x (min=3D%x.%x.%x)\n"
-		     "PAL_B      : %x.%x.%x (min=3D%x.%x.%x)\n",
-		     cur_ver.pal_version_s.pv_pal_vendor, min_ver.pal_version_s.pv_pal_v=
endor,
-
-		     cur_ver.pal_version_s.pv_pal_a_model>>4,
-		     cur_ver.pal_version_s.pv_pal_a_model&0xf, cur_ver.pal_version_s.pv_=
pal_a_rev,
-		     min_ver.pal_version_s.pv_pal_a_model>>4,
-		     min_ver.pal_version_s.pv_pal_a_model&0xf, min_ver.pal_version_s.pv_=
pal_a_rev,
-
-		     cur_ver.pal_version_s.pv_pal_b_model>>4,
-		     cur_ver.pal_version_s.pv_pal_b_model&0xf, cur_ver.pal_version_s.pv_=
pal_b_rev,
-		     min_ver.pal_version_s.pv_pal_b_model>>4,
-		     min_ver.pal_version_s.pv_pal_b_model&0xf, min_ver.pal_version_s.pv_=
pal_b_rev);
+		     "PAL_A      : %02x.%02x (min=3D%02x.%02x)\n"
+		     "PAL_B      : %02x.%02x (min=3D%02x.%02x)\n",
+		     cur_ver.pal_version_s.pv_pal_vendor,
+		     min_ver.pal_version_s.pv_pal_vendor,
+		     cur_ver.pal_version_s.pv_pal_a_model,
+		     cur_ver.pal_version_s.pv_pal_a_rev,
+		     min_ver.pal_version_s.pv_pal_a_model,
+		     min_ver.pal_version_s.pv_pal_a_rev,
+		     cur_ver.pal_version_s.pv_pal_b_model,
+		     cur_ver.pal_version_s.pv_pal_b_rev,
+		     min_ver.pal_version_s.pv_pal_b_model,
+		     min_ver.pal_version_s.pv_pal_b_rev);
 	return p - page;
 }
=20
diff --git a/include/asm-ia64/pal.h b/include/asm-ia64/pal.h
index 37e52a2..20a8d61 100644
--- a/include/asm-ia64/pal.h
+++ b/include/asm-ia64/pal.h
@@ -1433,7 +1433,12 @@ typedef union  pal_version_u {
 } pal_version_u_t;
=20
=20
-/* Return PAL version information */
+/*
+ * Return PAL version information.  While the documentation states that
+ * PAL_VERSION can be called in either physical or virtual mode, some
+ * implementations only allow physical calls.  We don't call it very often,
+ * so the overhead isn't worth eliminating.
+ */
 static inline s64
 ia64_pal_version (pal_version_u_t *pal_min_version, pal_version_u_t *pal_c=
ur_version)
 {
