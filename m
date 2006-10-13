From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 00:32:42 +0000
Subject: [RFC] Variable Kernel Page size support
Message-Id: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This patch is necessary for variable pagesize memmap support. Lots of asm=20
that seems to work fine but may be in need of streamlining.


IA64: Variable Kernel Page size support

This patch adds the capability to manage pages of varying sizes for the
kernel in region 7. This is done by setting special bits in bits 54 to 60.

54-59 Page size.

If set then the default pagesize of region 7 is overridden on a fault
and a TLB of the requested size is inserted. This may be used to
manually control the coverage of a single TLB. A macro SET_TLB_SIZE
is provide that can be used upon a kernel address to encode the
desired page size. Code must refer to the address range through
this address in order to get the desired TLB size.

60 Page table enable.

If set then a lookup is performed using the region7_pgdir table.
That table is segmented into 8 section for the varying page
sizes supported.

0 =3D _PAGE_SIZE_64K
1 =3D _PAGE_SIZE_256K
2 =3D _PAGE_SIZE_1M
3 =3D _PAGE_SIZE_4M
4 =3D _PAGE_SIZE_16M
5 =3D _PAGE_SIZE_64M
6 =3D _PAGE_SIZE_256M and _PAGE_SIZE_4K and _PAGE_SIZE_8K
7 =3D _PAGE_SIZE_1G and PAGE_SIZE_16k

One should only use one page size per section.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.19-rc1-mm1.orig/arch/ia64/kernel/ivt.=
S	2006-10-04 19:57:05.000000000 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/kernel/ivt.S	2006-10-12 11:50:22.0951853=
40 -0700
@@ -374,18 +374,21 @@ ENTRY(alt_dtlb_miss)
 	movl r19=3D(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
 	mov r21=3Dcr.ipsr
 	mov r31=3Dpr
+	mov r18=3Dcr.itir
 	;;
-#ifdef CONFIG_DISABLE_VHPT
 	shr.u r22=3Dr16,61			// get the region number into r21
+	extr.u r23=3Dr16,54,7			// Get address flags
 	;;
 	cmp.gt p8,p0=3D6,r22			// access to region 0-5
+	cmp.ne p6,p0=3Dr23,r0			// addresss flags set?
+(p6) 	br.cond.spnt .set_address_options
 	;;
+.alt_dtlb_miss_continue:
 (p8)	thash r17=3Dr16
 	;;
 (p8)	mov cr.iha=3Dr17
 (p8)	mov r29=B0				// save b0
 (p8)	br.cond.dptk dtlb_fault
-#endif
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
 	and r22=3DIA64_ISR_CODE_MASK,r20		// get the isr.code field
 	tbit.nz p6,p7=3Dr20,IA64_ISR_SP_BIT	// is speculation bit on?
@@ -407,6 +410,42 @@ ENTRY(alt_dtlb_miss)
 (p7)	itc.d r19		// insert the TLB entry
 	mov pr=3Dr31,-1
 	rfi
+
+.set_address_options:
+	//
+	// Process address options that may have been set in the high
+	// bits of region 7:
+	//
+	// bit 60    =3D page table enable
+	// bit 54-59 =3D override page size
+	//
+	// The following fixups are performed:
+	// 1. Update cr.itir if page size override is set. This  will result
+	//    in a TLB entry of the specified size being inserted.
+	// 2. Switching page table lookup to region7_pg_dir if page table set
+	// 3. We set up a fake region in r16 bits 63 to 61 based on
+	//    bits 1 to 3 of the requested page size in order to partition
+	//    the page table per large page size. However, we cannot
+	//    fake region 5 since the nested_dtlb handler would switch
+	//    to using swapper_pg_dir, so we just replace 5 with 0.
+	//
+	tbit.nz p6,p0=3Dr23,6		// Check for page table bit
+	cmp.ne p7,p0=3D7,r22		// Only do this for region 7
+(p7)	br.cond.spnt .alt_dtlb_miss_continue
+	;;
+(p6)	mov cr.iha=3Dr16
+(p6)	mov r29=B0			// save b0
+(p6)	br.cond.spnt dtlb_fault
+	dep r18=3Dr23,r18,2,6
+	;;
+	dep r16=3D0,r16,54,7		// Clear address flag bits
+	mov cr.itir=3Dr18			// Override region page size
+	br.cond.spnt .alt_dtlb_miss_continue
+
+.alt_dtlb_page_table:
+	mov cr.iha=3Dr16
+	mov r29=B0			// save b0
+	br.cond.spnt dtlb_fault
 END(alt_dtlb_miss)
=20
 	.org ia64_ivt+0x1400
@@ -439,26 +478,41 @@ ENTRY(nested_dtlb_miss)
 	mov r19=3DIA64_KR(PT_BASE)		// get the page table base address
 	shl r21=3Dr16,3				// shift bit 60 into sign bit
 	mov r18=3Dcr.itir
-	;;
 	shr.u r17=3Dr16,61			// get the region number into r17
+	tbit.nz p9,p6=3Dr16,60			// Special region 7 processing?
+	;;
+(p9)	extr.u r17=3Dr16,54,6			// Get page size bits
+	;;
+(p9)	dep r18=3Dr17,r18,2,6			// Modify ITIR
+(p6)	cmp.ge p6,p7=3D5,r17			// is faulting address in region 5, 6 and 7?
+	;;
+(p9)	mov cr.itir=3Dr18
+	;;
 	extr.u r18=3Dr18,2,6			// get the faulting page size
 	;;
-	cmp.eq p6,p7=3D5,r17			// is faulting address in region 5?
-	add r22=3D-PAGE_SHIFT,r18			// adjustment for hugetlb address
+	add r22=3D-PAGE_SHIFT,r18			// adjustment for page size
 	add r18=3DPGDIR_SHIFT-PAGE_SHIFT,r18
+(p9)	dep r16=3D0,r16,PGDIR_SHIFT+PAGE_SHIFT-6,64-(PGDIR_SHIFT+PAGE_SHIFT-6)
+(p9)	shr r17=3Dr17,1				// Prepare page table index
+	;;
+	shr.u r22=3Dr16,r22			// addr >> page_order
+	shr.u r18=3Dr16,r18			// addr >> pgdir shift
 	;;
-	shr.u r22=3Dr16,r22
-	shr.u r18=3Dr16,r18
-(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
-
 	srlz.d
+	.pred.rel "mutex", p6, p9
 	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_p=
g_dir
+	LOAD_PHYSICAL(p9, r19, region7_pg_dir)
+(p7)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+(p9)	dep r17=3Dr17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
=20
-	.pred.rel "mutex", p6, p7
+	.pred.rel "mutex", p6, p7, p9
 (p6)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT
 (p7)	shr.u r21=3Dr21,PGDIR_SHIFT+PAGE_SHIFT-3
+(p9)	mov r21=3Dr0
 	;;
+	.pred.rel "mutex", p6, p7, p9
 (p6)	dep r17=3Dr18,r19,3,(PAGE_SHIFT-3)	// r17=3Dpgd_offset for region 5
+(p9)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3Dpgd_offset for region 7
 (p7)	dep r17=3Dr18,r17,3,(PAGE_SHIFT-6)	// r17=3Dpgd_offset for region[0-4]
 	cmp.eq p7,p6=3D0,r21			// unused address bits all zeroes?
 #ifdef CONFIG_PGTABLE_4
Index: linux-2.6.19-rc1-mm1/arch/ia64/kernel/head.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.19-rc1-mm1.orig/arch/ia64/kernel/head=
.S	2006-10-04 19:57:05.000000000 -0700
+++ linux-2.6.19-rc1-mm1/arch/ia64/kernel/head.S	2006-10-12 11:50:22.096161=
842 -0700
@@ -174,6 +174,15 @@ empty_zero_page:
 swapper_pg_dir:
 	.skip PAGE_SIZE
=20
+	//
+	// Special pg_dir for variable kernel page sizes. The table is
+	// segmented into 8 sections of equal size that provide the lookups
+	// for each supported page size.
+	//
+	.global region7_pg_dir
+region7_pg_dir:
+	.skip PAGE_SIZE
+
 	.rodata
 halt_msg:
 	stringz "Halting kernel\n"
Index: linux-2.6.19-rc1-mm1/include/asm-ia64/pgtable.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.19-rc1-mm1.orig/include/asm-ia64/pgta=
ble.h	2006-10-12 11:50:18.445996183 -0700
+++ linux-2.6.19-rc1-mm1/include/asm-ia64/pgtable.h	2006-10-12 11:52:50.605=
563552 -0700
@@ -153,6 +153,62 @@
=20
 #define VIRTUAL_MEM_MAP		(RGN_BASE(RGN_GATE) + 0x200000000)
=20
+
+/*
+ * Definitions to support various sizes of kernel pages in region 7
+ * that can be used to reduce TLB pressure and create pagetables with
+ * varying page sizes.
+ *
+ * All page sizes are supported through this interfaces. Note that the
+ * processor also must support the specified shift.
+ */
+#define TLB_SIZE_SHIFT		54
+#define TLB_SIZE_MASK		0x1f
+#define TLB_SIZE_OFFSET		(__IA64_UL(1) << TLB_SIZE_SHIFT)
+
+#define ENABLE_PAGE_TABLE_SHIFT	60
+
+#define TLB_SIZE(shift)		(__IA64_UL(shift) << TLB_SIZE_SHIFT)
+#define ENABLE_PAGE_TABLE	(__IA64_UL(1) << ENABLE_PAGE_TABLE_SHIFT)
+
+#define SET_TLB_SIZE(addr, page_shift)	(RGN_BASE(RGN_KERNEL) | TLB_SIZE(pa=
ge_shift) | (addr))
+
+#define VKP_AREA(shift)		(RGN_BASE(RGN_KERNEL) | TLB_SIZE(shift) | ENABLE_=
PAGE_TABLE)
+
+/* Extract various things from a VKP address */
+#define VKP_ADDR_TO_SHIFT(addr)	(((addr) >> TLB_SIZE_SHIFT) & TLB_SIZE_MAS=
K)
+
+#define VKP_ADDR_TO_OFFSET(addr) ((addr) & (TLB_SIZE_OFFSET-1))
+#define VKP_ADDR_TO_AREA(addr)	((addr) & ~(TLB_SIZE_OFFSET-1))
+
+#define VKP_PAGE_TO_PAGE(addr) (VKP_ADDR_TO_OFFSET(addr) >> (VKP_ADDR_TO_S=
HIFT(addr) - PAGE_SHIFT) | \
+				VKP_ADDR_TO_AREA(addr))
+
+#define VKP_VALID(addr)		(REGION_NUMBER(addr) =3D RGN_KERNEL && VKP_ADDR_T=
O_SHIFT(addr))
+
+/* Map of page sizes to page tables. We take only bits 1 to 3 from the page
+ * size in order to get a somewhat sane arrangement. Then there is this
+ * special casing for 64M because the bits would point to region 5 (for
+ * which the nested_dtbl_miss handler would override our page table)
+ *
+ * The 8 sub sections of region7_pgdir have to be used for the following s=
izes:
+ *
+ * 0 =3D _PAGE_SIZE_64K
+ * 1 =3D _PAGE_SIZE_256K
+ * 2 =3D _PAGE_SIZE_1M
+ * 3 =3D _PAGE_SIZE_4M
+ * 4 =3D _PAGE_SIZE_16M
+ * 5 =3D _PAGE_SIZE_64M
+ * 6 =3D _PAGE_SIZE_256M and _PAGE_SIZE_4K and _PAGE_SIZE_8K
+ * 7 =3D _PAGE_SIZE_1G and PAGE_SIZE_16k
+ *
+ * One should only use one page size per section.
+ */
+#define VKP_SHIFT_TO_PT(shift)	((shift) >> 1 & 7)
+
+#define pgd_offset_vkp(addr)	&region7_pg_dir[VKP_SHIFT_TO_PT(VKP_ADDR_TO_S=
HIFT(addr))]\
+				[VKP_ADDR_TO_OFFSET(addr) >> PGDIR_SHIFT]
+
 # ifndef __ASSEMBLY__
=20
 #include <linux/sched.h>	/* for mm_struct */
@@ -462,6 +518,7 @@ pte_same (pte_t a, pte_t b)
 #define update_mmu_cache(vma, address, pte) do { } while (0)
=20
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
+extern pgd_t region7_pg_dir[8][PTRS_PER_PGD];
 extern void paging_init (void);
=20
 /*
