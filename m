From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 29 Jun 2004 17:32:18 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406291032.18435.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_iea4AiI4OPutRyN"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
To: linux-ia64@vger.kernel.org


--Boundary-00=_iea4AiI4OPutRyN
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday, June 29, 2004 8:34 am, Chen, Kenneth W wrote:
> To follow up the other bug in head.S, here is the fix.
>
> ---------
> For BP, we are not installing any region 7 DTLB mapping for init_task.
> However, kr(stack) is being initialized to a legal kernel granule that
> the kernel resides.  If the first task context switch out of this
> init_task happens to have its task struct in that very same granule,
> the stack will not be mapped by any DTLB.  Patch to properly initialize
> kr(stack) for BP.

I tried both of these on a machine that doesn't have memory at the stock 
kernel load address, and it failed very early on.  However, it works with the 
attached patch.

Linux version 2.6.7 (jbarnes@tomahawk.engr.sgi.com) (gcc version 3.2.3 
20030502 (Red Hat Linux 3.2.3-24)) #3 SMP Tue Jun 29 10:01:08 PDT 2004
EFI v1.02 by SGI: SALsystab=0x230047e5150 ACPI 2.0=0x230047e5920
ACPI: RSDP (v002    SGI                                    ) @ 
0x00000230047e5920
ACPI: XSDT (v001    SGI  XSDTSN2 0x00010001  0x00000001) @ 0x00000230047e5960
ACPI: MADT (v001    SGI  APICSN2 0x00010001  0x00000001) @ 0x00000230047e59c0
ACPI: SRAT (v001    SGI  SRATSN2 0x00010001  0x00000001) @ 0x00000230047e5a30
ACPI: SLIT (v001    SGI  SLITSN2 0x00010001  0x00000001) @ 0x00000230047e5b00
ACPI: FADT (v003    SGI  FACPSN2 0x00030001  0x00000001) @ 0x00000230047e5c00
ACPI: DSDT (v001    SGI  DSDTSN2 0x00010001  0x00000001) @ 0x00000230047e5bc0
ACPI: DSDT (v001    SGI  DSDTSN2 0x00010001  0x00000001) @ 0x0000000000000000
ACPI: SRAT revision 0
ACPI: SLIT localities 6x6
Number of logical nodes in system = 2
Number of memory chunks in system = 2
SAL 2.9: SGI SN2 version 3.32
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12

Jesse

--Boundary-00=_iea4AiI4OPutRyN
Content-Type: text/plain;
  charset="iso-8859-1";
  name="init-task-region-5-revert.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="init-task-region-5-revert.patch"

===== arch/ia64/kernel/entry.S 1.61 vs edited =====
--- 1.61/arch/ia64/kernel/entry.S	Wed Jun 16 18:09:33 2004
+++ edited/arch/ia64/kernel/entry.S	Thu Jun 24 12:12:01 2004
@@ -179,19 +179,17 @@
 	.body
 
 	adds r22=IA64_TASK_THREAD_KSP_OFFSET,r13
-	movl r25=init_task
 	mov r27=IA64_KR(CURRENT_STACK)
-	adds r21=IA64_TASK_THREAD_KSP_OFFSET,in0
 	dep r20=0,in0,61,3		// physical address of "current"
 	;;
 	st8 [r22]=sp			// save kernel stack pointer of old task
 	shr.u r26=r20,IA64_GRANULE_SHIFT
-	cmp.eq p7,p6=r25,in0
+	adds r21=IA64_TASK_THREAD_KSP_OFFSET,in0
 	;;
 	/*
 	 * If we've already mapped this task's page, we can skip doing it again.
 	 */
-(p6)	cmp.eq p7,p6=r26,r27
+	cmp.eq p7,p6=r26,r27
 (p6)	br.cond.dpnt .map
 	;;
 .done:
===== arch/ia64/kernel/head.S 1.24 vs edited =====
--- 1.24/arch/ia64/kernel/head.S	Wed Jun 16 18:09:33 2004
+++ edited/arch/ia64/kernel/head.S	Thu Jun 24 12:12:02 2004
@@ -154,10 +154,6 @@
 #endif
 	;;
 	tpa r3=r2		// r3 == phys addr of task struct
-	;;
-	shr.u r16=r3,IA64_GRANULE_SHIFT
-(isBP)	br.cond.dpnt .load_current // BP stack is on region 5 --- no need to map it
-
 	// load mapping for stack (virtaddr in r2, physaddr in r3)
 	rsm psr.ic
 	movl r17=PAGE_KERNEL
@@ -169,6 +165,7 @@
 	dep r2=-1,r3,61,3	// IMVA of task
 	;;
 	mov r17=rr[r2]
+	shr.u r16=r3,IA64_GRANULE_SHIFT
 	;;
 	dep r17=0,r17,8,24
 	;;
@@ -183,7 +180,6 @@
 	srlz.d
   	;;
 
-.load_current:
 	// load the "current" pointer (r13) and ar.k6 with the current task
 	mov IA64_KR(CURRENT)=r2		// virtual address
 	mov IA64_KR(CURRENT_STACK)=r16

--Boundary-00=_iea4AiI4OPutRyN--
