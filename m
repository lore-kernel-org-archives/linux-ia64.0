From: Jack Steiner <steiner@sgi.com>
Date: Wed, 01 Dec 2004 20:40:00 +0000
Subject: SN support for new chipset - [3 of 4]
Message-Id: <20041201204000.GA26313@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Add support for a future SGI chipset (shub2).
(All code is SN-specific)

Change the IPI & TLB flushing code so that it works on
both shub1 & shub2.






Index: linux/include/asm-ia64/sn/rw_mmr.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/include/asm-ia64/sn/rw_mmr.h	2004-12=
-01 14:15:15.714071672 -0600
+++ linux/include/asm-ia64/sn/rw_mmr.h	2004-12-01 14:29:25.604960698 -0600
@@ -14,8 +14,8 @@
  * uncached physical addresses.
  * 	pio_phys_read_mmr  - read an MMR
  * 	pio_phys_write_mmr - write an MMR
- * 	pio_atomic_phys_write_mmrs - atomically write 2 MMRs with psr.ic=3D0
- * 		(interrupt collection)
+ * 	pio_atomic_phys_write_mmrs - atomically write 1 or 2 MMRs with psr.ic=
=3D0
+ *		Second MMR will be skipped if address is NULL
  *
  * Addresses passed to these routines should be uncached physical addresses
  * ie., 0x80000....
@@ -61,13 +61,14 @@ pio_atomic_phys_write_mmrs(volatile long
         asm volatile
             ("mov r2=3Dpsr;;"
              "rsm psr.i | psr.dt | psr.ic;;"
+	     "cmp.ne p9,p0=3D%2,r0;"
              "srlz.i;;"
              "st8.rel [%0]=3D%1;"
-             "st8.rel [%2]=3D%3;;"
+             "(p9) st8.rel [%2]=3D%3;;"
              "mov psr.l=3Dr2;;"
              "srlz.i;;"
 	     :: "r"(mmr1), "r"(val1), "r"(mmr2), "r"(val2)
-             : "r2", "memory");
+             : "p9", "r2", "memory");
 }           =20
=20
 #endif /* _ASM_IA64_SN_RW_MMR_H */
Index: linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	20=
04-12-01 14:29:11.722651870 -0600
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-12-01 14:30:09.133525029 -=
0600
@@ -38,7 +38,8 @@
 #include <asm/sn/nodepda.h>
 #include <asm/sn/rw_mmr.h>
=20
-void sn2_ptc_deadlock_recovery(unsigned long data0, unsigned long data1);
+void sn2_ptc_deadlock_recovery(volatile unsigned long *, unsigned long dat=
a0,=20
+	volatile unsigned long *, unsigned long data1);
=20
 static spinlock_t sn2_global_ptc_lock __cacheline_aligned =3D SPIN_LOCK_UN=
LOCKED;
=20
@@ -46,14 +47,14 @@ static unsigned long sn2_ptc_deadlock_co
=20
 static inline unsigned long wait_piowc(void)
 {
-	volatile unsigned long *piows, piows_val;
+	volatile unsigned long *piows, zeroval;
 	unsigned long ws;
=20
 	piows =3D pda->pio_write_status_addr;
-	piows_val =3D pda->pio_write_status_val;
+	zeroval =3D pda->pio_write_status_val;
 	do {
 		cpu_relax();
-	} while (((ws =3D *piows) & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK)=
 !=3D piows_val);
+	} while (((ws =3D *piows) & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK)=
 !=3D zeroval);
 	return ws;
 }
=20
@@ -87,9 +88,9 @@ void
 sn2_global_tlb_purge(unsigned long start, unsigned long end,
 		     unsigned long nbits)
 {
-	int i, cnode, mynasid, cpu, lcpu =3D 0, nasid, flushed =3D 0;
+	int i, shub1, cnode, mynasid, cpu, lcpu =3D 0, nasid, flushed =3D 0;
 	volatile unsigned long *ptc0, *ptc1;
-	unsigned long flags =3D 0, data0, data1;
+	unsigned long flags =3D 0, data0 =3D 0, data1 =3D 0;
 	struct mm_struct *mm =3D current->active_mm;
 	short nasids[NR_NODES], nix;
 	DECLARE_BITMAP(nodes_flushed, NR_NODES);
@@ -128,28 +129,42 @@ sn2_global_tlb_purge(unsigned long start
 	     cnode =3D find_next_bit(&nodes_flushed, NR_NODES, ++cnode))
 		nasids[nix++] =3D cnodeid_to_nasid(cnode);
=20
-	data0 =3D (1UL << SH1_PTC_0_A_SHFT) |
-	    (nbits << SH1_PTC_0_PS_SHFT) |
-	    ((ia64_get_rr(start) >> 8) << SH1_PTC_0_RID_SHFT) |
-	    (1UL << SH1_PTC_0_START_SHFT);
-
-	ptc0 =3D (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_0);
-	ptc1 =3D (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_1);
+	shub1 =3D is_shub1();
+	if (shub1) {
+		data0 =3D (1UL << SH1_PTC_0_A_SHFT) |
+		    	(nbits << SH1_PTC_0_PS_SHFT) |
+		    	((ia64_get_rr(start) >> 8) << SH1_PTC_0_RID_SHFT) |
+		    	(1UL << SH1_PTC_0_START_SHFT);
+		ptc0 =3D (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_0);
+		ptc1 =3D (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_1);
+	} else {
+		data0 =3D (1UL << SH2_PTC_A_SHFT) |
+			(nbits << SH2_PTC_PS_SHFT) |
+		    	(1UL << SH2_PTC_START_SHFT);
+		ptc0 =3D (long *)GLOBAL_MMR_PHYS_ADDR(0, SH2_PTC +=20
+			((ia64_get_rr(start) >> 8) << SH2_PTC_RID_SHFT) );
+		ptc1 =3D NULL;
+	}
+=09
=20
 	mynasid =3D get_nasid();
=20
 	spin_lock_irqsave(&sn2_global_ptc_lock, flags);
=20
 	do {
-		data1 =3D start | (1UL << SH1_PTC_1_START_SHFT);
+		if (shub1)
+			data1 =3D start | (1UL << SH1_PTC_1_START_SHFT);
+		else
+			data0 =3D (data0 & ~SH2_PTC_ADDR_MASK) | (start & SH2_PTC_ADDR_MASK);
 		for (i =3D 0; i < nix; i++) {
 			nasid =3D nasids[i];
-			if (likely(nasid =3D mynasid)) {
+			if (unlikely(nasid =3D mynasid)) {
 				ia64_ptcga(start, nbits << 2);
 				ia64_srlz_i();
 			} else {
 				ptc0 =3D CHANGE_NASID(nasid, ptc0);
-				ptc1 =3D CHANGE_NASID(nasid, ptc1);
+				if (ptc1)
+					ptc1 =3D CHANGE_NASID(nasid, ptc1);
 				pio_atomic_phys_write_mmrs(ptc0, data0, ptc1,
 							   data1);
 				flushed =3D 1;
@@ -159,7 +174,7 @@ sn2_global_tlb_purge(unsigned long start
 		if (flushed
 		    && (wait_piowc() &
 			SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK)) {
-			sn2_ptc_deadlock_recovery(data0, data1);
+			sn2_ptc_deadlock_recovery(ptc0, data0, ptc1, data1);
 		}
=20
 		start +=3D (1UL << nbits);
@@ -178,18 +193,19 @@ sn2_global_tlb_purge(unsigned long start
  * TLB flush transaction.  The recovery sequence is somewhat tricky & is
  * coded in assembly language.
  */
-void sn2_ptc_deadlock_recovery(unsigned long data0, unsigned long data1)
+void sn2_ptc_deadlock_recovery(volatile unsigned long *ptc0, unsigned long=
 data0,
+	volatile unsigned long *ptc1, unsigned long data1)
 {
-	extern void sn2_ptc_deadlock_recovery_core(long *, long, long *, long,
-						   long *);
+	extern void sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsi=
gned long,
+	        volatile unsigned long *, unsigned long, volatile unsigned long *=
, unsigned long);
 	int cnode, mycnode, nasid;
-	long *ptc0, *ptc1, *piows;
+	volatile unsigned long *piows;
+	volatile unsigned long zeroval;
=20
 	sn2_ptc_deadlock_count++;
=20
-	ptc0 =3D (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_0);
-	ptc1 =3D (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_1);
-	piows =3D (long *)pda->pio_write_status_addr;
+	piows =3D pda->pio_write_status_addr;
+	zeroval =3D pda->pio_write_status_val;
=20
 	mycnode =3D numa_node_id();
=20
@@ -198,8 +214,9 @@ void sn2_ptc_deadlock_recovery(unsigned=20
 			continue;
 		nasid =3D cnodeid_to_nasid(cnode);
 		ptc0 =3D CHANGE_NASID(nasid, ptc0);
-		ptc1 =3D CHANGE_NASID(nasid, ptc1);
-		sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows);
+		if (ptc1)
+			ptc1 =3D CHANGE_NASID(nasid, ptc1);
+		sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows, zeroval);
 	}
 }
=20
Index: linux/arch/ia64/sn/kernel/sn2/ptc_deadlock.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/sn/kernel/sn2/ptc_deadlock=
.S	2004-12-01 14:29:11.725581245 -0600
+++ linux/arch/ia64/sn/kernel/sn2/ptc_deadlock.S	2004-12-01 14:29:25.626442=
783 -0600
@@ -8,9 +8,8 @@
=20
 #include <asm/sn/shub_mmr.h>
=20
-#define ZEROVAL		0x3f		// "zero" value for outstanding PIO requests
 #define DEADLOCKBIT	SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_SHFT
-#define WRITECOUNT	SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_SHFT
+#define WRITECOUNTMASK	SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK
 #define ALIAS_OFFSET	(SH1_PIO_WRITE_STATUS_0_ALIAS-SH1_PIO_WRITE_STATUS_0)
=20
=20
@@ -18,24 +17,24 @@
 	.proc  	sn2_ptc_deadlock_recovery_core
=20
 sn2_ptc_deadlock_recovery_core:
-	.regstk 5,0,0,0
+	.regstk 6,0,0,0
=20
 	ptc0  	 =3D in0
 	data0 	 =3D in1
 	ptc1  	 =3D in2
 	data1 	 =3D in3
 	piowc 	 =3D in4
+	zeroval  =3D in5
 	piowcphy =3D r30
 	psrsave  =3D r2
-	zeroval  =3D r3
 	scr1	 =3D r16
 	scr2	 =3D r17
+	mask	 =3D r18
=20
=20
 	extr.u	piowcphy=3Dpiowc,0,61;;	// Convert piowc to uncached physical addr=
ess
 	dep	piowcphy=3D-1,piowcphy,63,1
-
-	mov	zeroval=3DZEROVAL		// "zero" value for PIO write count
+	movl	mask=3DWRITECOUNTMASK
=20
 1:
 	add	scr2=3DALIAS_OFFSET,piowc	// Address of WRITE_STATUS alias register=20
@@ -43,7 +42,7 @@ sn2_ptc_deadlock_recovery_core:
 	st8.rel	[scr2]=3Dscr1;;
=20
 5:	ld8.acq	scr1=3D[piowc];;		// Wait for PIOs to complete.
-	extr.u	scr2=3Dscr1,WRITECOUNT,7;;// PIO count
+	and	scr2=3Dscr1,mask;;	// mask of writecount bits
 	cmp.ne	p6,p0=3Dzeroval,scr2
 (p6)	br.cond.sptk 5b
 =09
@@ -57,16 +56,17 @@ sn2_ptc_deadlock_recovery_core:
 	st8.rel [ptc0]=DAta0		// Write PTC0 & wait for completion.
=20
 5:	ld8.acq	scr1=3D[piowcphy];;	// Wait for PIOs to complete.
-	extr.u	scr2=3Dscr1,WRITECOUNT,7;;// PIO count
+	and	scr2=3Dscr1,mask;;	// mask of writecount bits
 	cmp.ne	p6,p0=3Dzeroval,scr2
 (p6)	br.cond.sptk 5b;;
=20
 	tbit.nz	p8,p7=3Dscr1,DEADLOCKBIT;;// Test for DEADLOCK
+(p7)	cmp.ne p7,p0=3Dr0,ptc1;;		// Test for non-null ptc1
 =09
 (p7)	st8.rel [ptc1]=DAta1;;		// Now write PTC1.
=20
 5:	ld8.acq	scr1=3D[piowcphy];;	// Wait for PIOs to complete.
-	extr.u	scr2=3Dscr1,WRITECOUNT,7;;// PIO count
+	and	scr2=3Dscr1,mask;;	// mask of writecount bits
 	cmp.ne	p6,p0=3Dzeroval,scr2
 (p6)	br.cond.sptk 5b
 =09
--=20
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


