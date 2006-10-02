From: Horms <horms@verge.net.au>
Date: Mon, 02 Oct 2006 04:14:25 +0000
Subject: [patch 3/3] [IA64] kexec/kdump: Whitespace fixes
Message-Id: <20061002041424.GE3034@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> Date: Fri, 29 Sep 2006 14:46:23 -0700
> From: Tony Luck <tony.luck@intel.com>
> Message-Id: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
> To: linux-ia64@vger.kernel.org
> Subject: kexec/kdump and the ia64 test tree
> Cc: akpm@osdl.org, horms@verge.net.au
>
> The kexec/kdump patch in my test tree is very stale, plus it is time
> for some git maintenance on the test tree (to clean away all the
> "Auto-update from upstream" commits that my workflow generates). So
> I'm planning on resetting my "test" branch to Linus-latest + kdump/kexec
> (so git pull/fetch will barf on my test tree, you'll need to re-clone).
>
> Below I've include what I believe to be the latest version of the
> patch produced by:
>
> 1) Take 2.6.18
> 2) Apply Nan Hai patch for 2.6.18 (posted Sept 20th)
> 3) Pull in Linus-latest (c972398b ...) and resolve conflicts in smp.h, sy=
sctl.h
> 4) Apply Nan hai's "Fix OS_INIT" patch that fixed Indou-san's deadlock is=
sue
> +(Sept 28th)
> 5) Fix a few warnings:
>         arch/ia64/kernel/iosapic.c:
>                 `vec' may be used before set in kexec_disable_iosapic() .=
.. I'm
>                 not totally confident that I fixed this right. Please look
> +closely
>                 at what I did.
>         arch/ia64/kernel/smp.c:
>                 Trivial fixes to stop compiler complaining that
> +kdump_smp_send_stop()
>                 and kdump_smp_send_init() definitions were not prototypes.
> 6) Lots of white-space cleanup (mostly multiple spaces that should be tab=
s, but
> +I
>    also threw the whole kdump_find_rsvd_region() in arch/ia64/kernel/efi.c
> +through
>    scripts/Lindent as it was only using two-spaces for indentation.)
>
> Let me know if I've goofed up the patch during this process.
>
> I'm planning to reset my test tree on Monday (Oct 2nd).
>
> -Tony

This is the whitespace and formating portion of the above patch.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Zou Nan hai <nanhai.zou@intel.com>
Signed-Off-By: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/efi.c             |   78 +++---
 arch/ia64/kernel/machine_kexec.c   |   16 -
 arch/ia64/kernel/relocate_kernel.S |  431 +++++++++++++++++---------------=
----
 arch/ia64/kernel/setup.c           |   11=20
 arch/ia64/kernel/smp.c             |    4=20
 include/asm-ia64/kexec.h           |    6=20
 include/linux/kexec.h              |    1=20
 kernel/irq/manage.c                |    1=20
 8 files changed, 273 insertions(+), 275 deletions(-)

1ddb2ba2f841518c40d8eb55837e8c2223c0646b
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 9b96e7d..a01ba73 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -1124,8 +1124,8 @@ efi_initialize_iomem_resources(struct re
 			insert_resource(res, code_resource);
 			insert_resource(res, data_resource);
 #ifdef CONFIG_KEXEC
-                        insert_resource(res, &efi_memmap_res);
-                        insert_resource(res, &boot_param_res);
+			insert_resource(res, &efi_memmap_res);
+			insert_resource(res, &boot_param_res);
 			if (crashk_res.end > crashk_res.start)
 				insert_resource(res, &crashk_res);
 #endif
@@ -1135,46 +1135,46 @@ #endif
=20
 #ifdef CONFIG_KEXEC
 /* find a block of memory aligned to 64M exclude reserved regions
-   rsvd_regions are sorted
+ * rsvd_regions are sorted
  */
 unsigned long
-kdump_find_rsvd_region (unsigned long size,
-		struct rsvd_region *r, int n)
+kdump_find_rsvd_region(unsigned long size, struct rsvd_region *r, int n)
 {
-  int i;
-  u64 start, end;
-  u64 alignment =3D 1UL << _PAGE_SIZE_64M;
-  void *efi_map_start, *efi_map_end, *p;
-  efi_memory_desc_t *md;
-  u64 efi_desc_size;
-
-  efi_map_start =3D __va(ia64_boot_param->efi_memmap);
-  efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
-  efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
-
-  for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
-	  md =3D p;
-	  if (!efi_wb(md))
-		  continue;
-	  start =3D ALIGN(md->phys_addr, alignment);
-	  end =3D efi_md_end(md);
-	  for (i =3D 0; i < n; i++) {
-		if (__pa(r[i].start) >=3D start && __pa(r[i].end) < end) {
-			if (__pa(r[i].start) > start + size)
-				return start;
-			start =3D ALIGN(__pa(r[i].end), alignment);
-			if (i < n-1 && __pa(r[i+1].start) < start + size)
-				continue;
-			else
-				break;
+	int i;
+	u64 start, end;
+	u64 alignment =3D 1UL << _PAGE_SIZE_64M;
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
+
+	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
+		md =3D p;
+		if (!efi_wb(md))
+			continue;
+		start =3D ALIGN(md->phys_addr, alignment);
+		end =3D efi_md_end(md);
+		for (i =3D 0; i < n; i++) {
+			if (__pa(r[i].start) >=3D start && __pa(r[i].end) < end) {
+				if (__pa(r[i].start) > start + size)
+					return start;
+				start =3D ALIGN(__pa(r[i].end), alignment);
+				if (i < n - 1
+				    && __pa(r[i + 1].start) < start + size)
+					continue;
+				else
+					break;
+			}
 		}
-	  }
-	  if (end > start + size)
-		return start;
-  }
-
-  printk(KERN_WARNING "Cannot reserve 0x%lx byte of memory for crashdump\n=
",
-	size);
-  return ~0UL;
+		if (end > start + size)
+			return start;
+	}
+
+	printk(KERN_WARNING
+	       "Cannot reserve 0x%lx byte of memory for crashdump\n", size);
+	return ~0UL;
 }
 #endif
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_ke=
xec.c
index 3673f97..2bbdabe 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -25,17 +25,17 @@ typedef void (*relocate_new_kernel_t)(un
 struct kimage *ia64_kimage;
=20
 struct resource efi_memmap_res =3D {
-        .name  =3D "EFI Memory Map",
-        .start =3D 0,
-        .end   =3D 0,
-        .flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
+	.name  =3D "EFI Memory Map",
+	.start =3D 0,
+	.end   =3D 0,
+	.flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
 };
=20
 struct resource boot_param_res =3D {
-        .name  =3D "Boot parameter",
-        .start =3D 0,
-        .end   =3D 0,
-        .flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
+	.name  =3D "Boot parameter",
+	.start =3D 0,
+	.end   =3D 0,
+	.flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
 };
=20
=20
diff --git a/arch/ia64/kernel/relocate_kernel.S b/arch/ia64/kernel/relocate=
_kernel.S
index ffc1bde..4c6ada4 100644
--- a/arch/ia64/kernel/relocate_kernel.S
+++ b/arch/ia64/kernel/relocate_kernel.S
@@ -17,12 +17,13 @@ #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/mca_asm.h>
=20
-       /* Must be relocatable PIC code callable as a C function
-        */
+/*
+ * Must be relocatable PIC code callable as a C function
+*/
 GLOBAL_ENTRY(relocate_new_kernel)
 	.prologue
 	alloc r31=3Dar.pfs,4,0,0,0
-        .body
+	.body
 .reloc_entry:
 {
 	rsm psr.i| psr.ic
@@ -30,16 +31,16 @@ GLOBAL_ENTRY(relocate_new_kernel)
 }
 	;;
 {
-        flushrs                         // must be first insn in group
-        srlz.i
+	flushrs				// must be first insn in group
+	srlz.i
 }
 	;;
-	dep r2=3D0,r2,61,3		//to physical address
+	dep r2=3D0,r2,61,3		// to physical address
 	;;
 	//first switch to physical mode
 	add r3=1F-.reloc_entry, r2
 	movl r16 =3D IA64_PSR_AC|IA64_PSR_BN|IA64_PSR_IC
-	mov ar.rsc=3D0	          	// put RSE in enforced lazy mode
+	mov ar.rsc=3D0			// put RSE in enforced lazy mode
 	;;
 	add sp=3D(memory_stack_end - 16 - .reloc_entry),r2
 	add r8=3D(register_stack - .reloc_entry),r2
@@ -47,9 +48,9 @@ GLOBAL_ENTRY(relocate_new_kernel)
 	mov r18=3Dar.rnat
 	mov ar.bspstore=3Dr8
 	;;
-        mov cr.ipsr=3Dr16
-        mov cr.iip=3Dr3
-        mov cr.ifs=3Dr0
+	mov cr.ipsr=3Dr16
+	mov cr.iip=3Dr3
+	mov cr.ifs=3Dr0
 	srlz.i
 	;;
 	mov ar.rnat=3Dr18
@@ -61,91 +62,91 @@ GLOBAL_ENTRY(relocate_new_kernel)
 	dep r28=3D0,in2,61,3	//to physical address
=20
 	// purge all TC entries
-#define O(member)       IA64_CPUINFO_##member##_OFFSET
-        GET_THIS_PADDR(r2, cpu_info)    // load phys addr of cpu_info into=
 r2
-        ;;
-        addl r17=3DO(PTCE_STRIDE),r2
-        addl r2=3DO(PTCE_BASE),r2
-        ;;
-        ld8 r18=3D[r2],(O(PTCE_COUNT)-O(PTCE_BASE));;    	// r18=3Dptce_ba=
se
-        ld4 r19=3D[r2],4                                  // r19=3Dptce_co=
unt[0]
-        ld4 r21=3D[r17],4                                 // r21=3Dptce_st=
ride[0]
-        ;;
-        ld4 r20=3D[r2]                                    // r20=3Dptce_co=
unt[1]
-        ld4 r22=3D[r17]                                   // r22=3Dptce_st=
ride[1]
-        mov r24=3Dr0
-        ;;
-        adds r20=3D-1,r20
-        ;;
+#define O(member)	IA64_CPUINFO_##member##_OFFSET
+	GET_THIS_PADDR(r2, cpu_info)	// load phys addr of cpu_info into r2
+	;;
+	addl r17=3DO(PTCE_STRIDE),r2
+	addl r2=3DO(PTCE_BASE),r2
+	;;
+	ld8 r18=3D[r2],(O(PTCE_COUNT)-O(PTCE_BASE));;	// r18=3Dptce_base
+	ld4 r19=3D[r2],4					// r19=3Dptce_count[0]
+	ld4 r21=3D[r17],4					// r21=3Dptce_stride[0]
+	;;
+	ld4 r20=3D[r2]					// r20=3Dptce_count[1]
+	ld4 r22=3D[r17]					// r22=3Dptce_stride[1]
+	mov r24=3Dr0
+	;;
+	adds r20=3D-1,r20
+	;;
 #undef O
 2:
-        cmp.ltu p6,p7=3Dr24,r19
-(p7)    br.cond.dpnt.few 4f
-        mov ar.lc=3Dr20
+	cmp.ltu p6,p7=3Dr24,r19
+(p7)	br.cond.dpnt.few 4f
+	mov ar.lc=3Dr20
 3:
-        ptc.e r18
-        ;;
-        add r18=3Dr22,r18
-        br.cloop.sptk.few 3b
-        ;;
-        add r18=3Dr21,r18
-        add r24=3D1,r24
-        ;;
-        br.sptk.few 2b
+	ptc.e r18
+	;;
+	add r18=3Dr22,r18
+	br.cloop.sptk.few 3b
+	;;
+	add r18=3Dr21,r18
+	add r24=3D1,r24
+	;;
+	br.sptk.few 2b
 4:
-        srlz.i
-        ;;
+	srlz.i
+	;;
 	//purge TR entry for kernel text and data
-        movl r16=3DKERNEL_START
-        mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
-        ;;
-        ptr.i r16, r18
-        ptr.d r16, r18
-        ;;
-        srlz.i
-        ;;
+	movl r16=3DKERNEL_START
+	mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
+	;;
+	ptr.i r16, r18
+	ptr.d r16, r18
+	;;
+	srlz.i
+	;;
=20
 	// purge TR entry for percpu data
-        movl r16=3DPERCPU_ADDR
-        mov r18=3DPERCPU_PAGE_SHIFT<<2
-        ;;
-        ptr.d r16,r18
-        ;;
-        srlz.d
+	movl r16=3DPERCPU_ADDR
+	mov r18=3DPERCPU_PAGE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.d
 	;;
=20
-        // purge TR entry for pal code
-        mov r16=3Din3
-        mov r18=3DIA64_GRANULE_SHIFT<<2
-        ;;
-        ptr.i r16,r18
-        ;;
-        srlz.i
+	// purge TR entry for pal code
+	mov r16=3Din3
+	mov r18=3DIA64_GRANULE_SHIFT<<2
+	;;
+	ptr.i r16,r18
+	;;
+	srlz.i
 	;;
=20
-        // purge TR entry for stack
-        mov r16=3DIA64_KR(CURRENT_STACK)
-        ;;
-        shl r16=3Dr16,IA64_GRANULE_SHIFT
-        movl r19=3DPAGE_OFFSET
-        ;;
-        add r16=3Dr19,r16
-        mov r18=3DIA64_GRANULE_SHIFT<<2
-        ;;
-        ptr.d r16,r18
-        ;;
-        srlz.i
+	// purge TR entry for stack
+	mov r16=3DIA64_KR(CURRENT_STACK)
+	;;
+	shl r16=3Dr16,IA64_GRANULE_SHIFT
+	movl r19=3DPAGE_OFFSET
+	;;
+	add r16=3Dr19,r16
+	mov r18=3DIA64_GRANULE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.i
 	;;
=20
 	//copy segments
 	movl r16=3DPAGE_MASK
-        mov  r30=3Din0                    // in0 is page_list
-        br.sptk.few .dest_page
+	mov  r30=3Din0			// in0 is page_list
+	br.sptk.few .dest_page
 	;;
 .loop:
 	ld8  r30=3D[in0], 8;;
 .dest_page:
-	tbit.z p0, p6=3Dr30, 0;;    	// 0x1 dest page
+	tbit.z p0, p6=3Dr30, 0;;		// 0x1 dest page
 (p6)	and r17=3Dr30, r16
 (p6)	br.cond.sptk.few .loop;;
=20
@@ -181,12 +182,12 @@ (p6)	br.cond.sptk.few .loop
 	;;
 	br.call.sptk.many b0=B6;;
=20
-.align  32
+.align 32
 memory_stack:
-	.fill           8192, 1, 0
+	.fill	8192, 1, 0
 memory_stack_end:
 register_stack:
-	.fill           8192, 1, 0
+	.fill	8192, 1, 0
 register_stack_end:
 relocate_new_kernel_end:
 END(relocate_new_kernel)
@@ -204,10 +205,10 @@ GLOBAL_ENTRY(kexec_fake_sal_rendez)
 		srlz.i
 	}
 	;;
-       /* See where I am running, and compute gp */
+	/* See where I am running, and compute gp */
 	{
-		mov     ar.rsc =3D 0      /* Put RSE in enforce lacy, LE mode */
-		mov     gp =3D ip         /* gp =3D relocate_new_kernel */
+		mov ar.rsc =3D 0		/* Put RSE in enforce lacy, LE mode */
+		mov gp =3D ip		/* gp =3D relocate_new_kernel */
 	}
=20
 	movl r8=3D0x00000100000000
@@ -228,7 +229,7 @@ GLOBAL_ENTRY(kexec_fake_sal_rendez)
 	rfi
 	;;
 5:
-	mov     b6=3Din0			/* _start addr */
+	mov	b6=3Din0			/* _start addr */
 	mov	r8=3Din1			/* ap_wakeup_vector */
 	mov	r26=3Din2			/* PAL addr */
 	;;
@@ -285,16 +286,16 @@ GLOBAL_ENTRY(kexec_fake_sal_rendez)
 	shl	r10=3Dr10,r8		/* bit mask off irr we want */
 	cmp.eq	p6,p0=3D0,r9
 	;;
-(p6)	br.cond.sptk.few        check_irr0
+(p6)	br.cond.sptk.few	check_irr0
 	cmp.eq	p7,p0=3D1,r9
 	;;
-(p7)	br.cond.sptk.few        check_irr1
+(p7)	br.cond.sptk.few	check_irr1
 	cmp.eq	p8,p0=3D2,r9
 	;;
-(p8)	br.cond.sptk.few        check_irr2
+(p8)	br.cond.sptk.few	check_irr2
 	cmp.eq	p9,p0=3D3,r9
 	;;
-(p9)	br.cond.sptk.few        check_irr3
+(p9)	br.cond.sptk.few	check_irr3
=20
 check_irr0:
 	mov	r8=3Dcr.irr0
@@ -352,139 +353,137 @@ relocate_new_kernel_size:
 	data8	kexec_fake_sal_rendez_end - relocate_new_kernel
=20
 GLOBAL_ENTRY(ia64_dump_cpu_regs)
-        .prologue
-        alloc loc0=3Dar.pfs,1,2,0,0
-        .body
-        mov     ar.rsc=3D0                // put RSE in enforced lazy mode
-        add     loc1=3D4*8, in0           // save r4 and r5 first
-        ;;
+	.prologue
+	alloc loc0=3Dar.pfs,1,2,0,0
+	.body
+	mov	ar.rsc=3D0		// put RSE in enforced lazy mode
+	add	loc1=3D4*8, in0		// save r4 and r5 first
+	;;
 {
-        flushrs                         // flush dirty regs to backing sto=
re
-        srlz.i
+	flushrs				// flush dirty regs to backing store
+	srlz.i
 }
-        st8 [loc1]=3Dr4, 8
-        ;;
-        st8 [loc1]=3Dr5, 8
-        ;;
-        add loc12*8, in0
-        mov r4=3Dar.rnat
-        ;;
-        st8 [in0]=3Dr0, 8			// r0
-        st8 [loc1]=3Dr4, 8		// rnat
-        mov r5=3Dpr
-        ;;
-        st8 [in0]=3Dr1, 8			// r1
-        st8 [loc1]=3Dr5, 8		// pr
-        mov r4=B0
-        ;;
-        st8 [in0]=3Dr2, 8			// r2
-        st8 [loc1]=3Dr4, 8		// b0
-        mov r5=B1;
-        ;;
-        st8 [in0]=3Dr3, 24		// r3
-        st8 [loc1]=3Dr5, 8		// b1
-        mov r4=B2
-        ;;
-        st8 [in0]=3Dr6, 8			// r6
-        st8 [loc1]=3Dr4, 8		// b2
+	st8 [loc1]=3Dr4, 8
+	;;
+	st8 [loc1]=3Dr5, 8
+	;;
+	add loc12*8, in0
+	mov r4=3Dar.rnat
+	;;
+	st8 [in0]=3Dr0, 8			// r0
+	st8 [loc1]=3Dr4, 8		// rnat
+	mov r5=3Dpr
+	;;
+	st8 [in0]=3Dr1, 8			// r1
+	st8 [loc1]=3Dr5, 8		// pr
+	mov r4=B0
+	;;
+	st8 [in0]=3Dr2, 8			// r2
+	st8 [loc1]=3Dr4, 8		// b0
+	mov r5=B1;
+	;;
+	st8 [in0]=3Dr3, 24		// r3
+	st8 [loc1]=3Dr5, 8		// b1
+	mov r4=B2
+	;;
+	st8 [in0]=3Dr6, 8			// r6
+	st8 [loc1]=3Dr4, 8		// b2
 	mov r5=B3
-        ;;
-        st8 [in0]=3Dr7, 8			// r7
-        st8 [loc1]=3Dr5, 8		// b3
-        mov r4=B4
-        ;;
-        st8 [in0]=3Dr8, 8			// r8
-        st8 [loc1]=3Dr4, 8		// b4
-        mov r5=B5
-        ;;
-        st8 [in0]=3Dr9, 8			// r9
-        st8 [loc1]=3Dr5, 8		// b5
-        mov r4=B6
-        ;;
-        st8 [in0]=3Dr10, 8		// r10
-        st8 [loc1]=3Dr5, 8		// b6
-        mov r5=B7
-        ;;
-        st8 [in0]=3Dr11, 8		// r11
-        st8 [loc1]=3Dr5, 8		// b7
-        mov r4=B0
-        ;;
-        st8 [in0]=3Dr12, 8		// r12
-        st8 [loc1]=3Dr4, 8		// ip
-        mov r5=3Dloc0
-	;;
-        st8 [in0]=3Dr13, 8		// r13
-        extr.u r5=3Dr5, 0, 38		// ar.pfs.pfm
+	;;
+	st8 [in0]=3Dr7, 8			// r7
+	st8 [loc1]=3Dr5, 8		// b3
+	mov r4=B4
+	;;
+	st8 [in0]=3Dr8, 8			// r8
+	st8 [loc1]=3Dr4, 8		// b4
+	mov r5=B5
+	;;
+	st8 [in0]=3Dr9, 8			// r9
+	st8 [loc1]=3Dr5, 8		// b5
+	mov r4=B6
+	;;
+	st8 [in0]=3Dr10, 8		// r10
+	st8 [loc1]=3Dr5, 8		// b6
+	mov r5=B7
+	;;
+	st8 [in0]=3Dr11, 8		// r11
+	st8 [loc1]=3Dr5, 8		// b7
+	mov r4=B0
+	;;
+	st8 [in0]=3Dr12, 8		// r12
+	st8 [loc1]=3Dr4, 8		// ip
+	mov r5=3Dloc0
+	;;
+	st8 [in0]=3Dr13, 8		// r13
+	extr.u r5=3Dr5, 0, 38		// ar.pfs.pfm
 	mov r4=3Dr0			// user mask
-        ;;
-        st8 [in0]=3Dr14, 8		// r14
-        st8 [loc1]=3Dr5, 8		// cfm
-        ;;
-        st8 [in0]=3Dr15, 8		// r15
-        st8 [loc1]=3Dr4, 8        	// user mask
+	;;
+	st8 [in0]=3Dr14, 8		// r14
+	st8 [loc1]=3Dr5, 8		// cfm
+	;;
+	st8 [in0]=3Dr15, 8		// r15
+	st8 [loc1]=3Dr4, 8		// user mask
 	mov r5=3Dar.rsc
-        ;;
-        st8 [in0]=3Dr16, 8		// r16
-        st8 [loc1]=3Dr5, 8        	// ar.rsc
-        mov r4=3Dar.bsp
-        ;;
-        st8 [in0]=3Dr17, 8		// r17
-        st8 [loc1]=3Dr4, 8        	// ar.bsp
-        mov r5=3Dar.bspstore
-        ;;
-        st8 [in0]=3Dr18, 8		// r18
-        st8 [loc1]=3Dr5, 8        	// ar.bspstore
-        mov r4=3Dar.rnat
-        ;;
-        st8 [in0]=3Dr19, 8		// r19
-        st8 [loc1]=3Dr4, 8        	// ar.rnat
-        mov r5=3Dar.ccv
-        ;;
-        st8 [in0]=3Dr20, 8		// r20
-	st8 [loc1]=3Dr5, 8        	// ar.ccv
-        mov r4=3Dar.unat
-        ;;
-        st8 [in0]=3Dr21, 8		// r21
-        st8 [loc1]=3Dr4, 8        	// ar.unat
-        mov r5 =3D ar.fpsr
-        ;;
-        st8 [in0]=3Dr22, 8		// r22
-        st8 [loc1]=3Dr5, 8        	// ar.fpsr
-        mov r4 =3D ar.unat
-        ;;
-        st8 [in0]=3Dr23, 8		// r23
-        st8 [loc1]=3Dr4, 8        	// unat
-        mov r5 =3D ar.fpsr
-        ;;
-        st8 [in0]=3Dr24, 8		// r24
-        st8 [loc1]=3Dr5, 8        	// fpsr
-        mov r4 =3D ar.pfs
-        ;;
-        st8 [in0]=3Dr25, 8		// r25
-        st8 [loc1]=3Dr4, 8        	// ar.pfs
-        mov r5 =3D ar.lc
-        ;;
-        st8 [in0]=3Dr26, 8		// r26
-        st8 [loc1]=3Dr5, 8        	// ar.lc
-        mov r4 =3D ar.ec
-        ;;
-        st8 [in0]=3Dr27, 8		// r27
-        st8 [loc1]=3Dr4, 8        	// ar.ec
-        mov r5 =3D ar.csd
-        ;;
-        st8 [in0]=3Dr28, 8		// r28
-        st8 [loc1]=3Dr5, 8        	// ar.csd
-        mov r4 =3D ar.ssd
-        ;;
-        st8 [in0]=3Dr29, 8		// r29
-        st8 [loc1]=3Dr4, 8        	// ar.ssd
-        ;;
-        st8 [in0]=3Dr30, 8		// r30
-        ;;
+	;;
+	st8 [in0]=3Dr16, 8		// r16
+	st8 [loc1]=3Dr5, 8		// ar.rsc
+	mov r4=3Dar.bsp
+	;;
+	st8 [in0]=3Dr17, 8		// r17
+	st8 [loc1]=3Dr4, 8		// ar.bsp
+	mov r5=3Dar.bspstore
+	;;
+	st8 [in0]=3Dr18, 8		// r18
+	st8 [loc1]=3Dr5, 8		// ar.bspstore
+	mov r4=3Dar.rnat
+	;;
+	st8 [in0]=3Dr19, 8		// r19
+	st8 [loc1]=3Dr4, 8		// ar.rnat
+	mov r5=3Dar.ccv
+	;;
+	st8 [in0]=3Dr20, 8		// r20
+	st8 [loc1]=3Dr5, 8		// ar.ccv
+	mov r4=3Dar.unat
+	;;
+	st8 [in0]=3Dr21, 8		// r21
+	st8 [loc1]=3Dr4, 8		// ar.unat
+	mov r5 =3D ar.fpsr
+	;;
+	st8 [in0]=3Dr22, 8		// r22
+	st8 [loc1]=3Dr5, 8		// ar.fpsr
+	mov r4 =3D ar.unat
+	;;
+	st8 [in0]=3Dr23, 8		// r23
+	st8 [loc1]=3Dr4, 8		// unat
+	mov r5 =3D ar.fpsr
+	;;
+	st8 [in0]=3Dr24, 8		// r24
+	st8 [loc1]=3Dr5, 8		// fpsr
+	mov r4 =3D ar.pfs
+	;;
+	st8 [in0]=3Dr25, 8		// r25
+	st8 [loc1]=3Dr4, 8		// ar.pfs
+	mov r5 =3D ar.lc
+	;;
+	st8 [in0]=3Dr26, 8		// r26
+	st8 [loc1]=3Dr5, 8		// ar.lc
+	mov r4 =3D ar.ec
+	;;
+	st8 [in0]=3Dr27, 8		// r27
+	st8 [loc1]=3Dr4, 8		// ar.ec
+	mov r5 =3D ar.csd
+	;;
+	st8 [in0]=3Dr28, 8		// r28
+	st8 [loc1]=3Dr5, 8		// ar.csd
+	mov r4 =3D ar.ssd
+	;;
+	st8 [in0]=3Dr29, 8		// r29
+	st8 [loc1]=3Dr4, 8		// ar.ssd
+	;;
+	st8 [in0]=3Dr30, 8		// r30
+	;;
 	st8 [in0]=3Dr31, 8		// r31
-        mov ar.pfs=3Dloc0
-        ;;
-        br.ret.sptk.many rp
+	mov ar.pfs=3Dloc0
+	;;
+	br.ret.sptk.many rp
 END(ia64_dump_cpu_regs)
-
-
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index eaf6782..1bdb3b6 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -283,11 +283,11 @@ #ifdef CONFIG_KEXEC
 			}
 		}
 		efi_memmap_res.start =3D ia64_boot_param->efi_memmap;
-                efi_memmap_res.end =3D efi_memmap_res.start +
-                        ia64_boot_param->efi_memmap_size;
-                boot_param_res.start =3D __pa(ia64_boot_param);
-                boot_param_res.end =3D boot_param_res.start +
-                        sizeof(*ia64_boot_param);
+		efi_memmap_res.end =3D efi_memmap_res.start +
+			ia64_boot_param->efi_memmap_size;
+		boot_param_res.start =3D __pa(ia64_boot_param);
+		boot_param_res.end =3D boot_param_res.start +
+			sizeof(*ia64_boot_param);
 	}
 #endif
 	/* end of memory marker */
@@ -301,7 +301,6 @@ #endif
 	sort_regions(rsvd_region, num_rsvd_regions);
 }
=20
-
 /**
  * find_initrd - get initrd parameters from the boot parameter structure
  *
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 82cc471..deb47d7 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -249,13 +249,13 @@ send_IPI_self (int op)
=20
 #ifdef CONFIG_CRASH_DUMP
 void
-kdump_smp_send_stop()
+kdump_smp_send_stop(void)
 {
  	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
 }
=20
 void
-kdump_smp_send_init()
+kdump_smp_send_init(void)
 {
 	unsigned int cpu, self_cpu;
 	self_cpu =3D smp_processor_id();
diff --git a/include/asm-ia64/kexec.h b/include/asm-ia64/kexec.h
index f389e2a..7eb8ca2 100644
--- a/include/asm-ia64/kexec.h
+++ b/include/asm-ia64/kexec.h
@@ -21,9 +21,9 @@ #define vmlpt_bits	(impl_va_bits - PAGE_
 #define POW2(n)		(1ULL << (n))
=20
 #define kexec_flush_icache_page(page) do { \
-                unsigned long page_addr =3D (unsigned long)page_address(pa=
ge); \
-                flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
-        } while(0)
+		unsigned long page_addr =3D (unsigned long)page_address(page); \
+		flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
+	} while(0)
=20
 extern struct kimage *ia64_kimage;
 DECLARE_PER_CPU(u64, ia64_mca_pal_base);
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index 75fbb7e..c790e08 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -135,7 +135,6 @@ extern struct resource crashk_res;
 typedef u32 note_buf_t[MAX_NOTE_BYTES/4];
 extern note_buf_t *crash_notes;
=20
-
 #else /* !CONFIG_KEXEC */
 struct pt_regs;
 struct task_struct;
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index a795d6f..92be519 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -475,3 +475,4 @@ #endif
 	return retval;
 }
 EXPORT_SYMBOL(request_irq);
+
