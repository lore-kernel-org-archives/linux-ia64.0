From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Tue, 29 Mar 2005 20:25:15 +0000
Subject: RE: syscall improvement patch [9/12]
Message-Id: <8126E4F969BA254AB43EA03C59F44E8401B74ECD@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <200503240051.j2O0pNx1022310@napali.hpl.hp.com>
In-Reply-To: <200503240051.j2O0pNx1022310@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch has a problem.

r29 is used to store psr, but it should get psr value after rsm psr.i. You patch reverses the sequence. If there is an interrupt happening and psr might be changed, such like IA64_PSR_MFH.

>>-----Original Message-----
>>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-owner@vger.kernel.org]
>>On Behalf Of David Mosberger
>>Sent: 2005年3月23日 16:51
>>To: Luck, Tony
>>Cc: linux-ia64@vger.kernel.org
>>Subject: syscall improvement patch [9/12]
>>
>>ia64: Reschedule __kernel_syscall_via_epc().
>>
>>Avoid some stalls, which is good for about 2 cycles when invoking a
>>light-weight handler.  When invoking a heavy-weight handler, this
>>helps by about 7 cycles, with most of the improvement coming from the
>>improved branch-prediction achieved by splitting the BBB bundle into
>>two MIB bundles.
>>
>>Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
>>
>>diff -Nru a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
>>--- a/arch/ia64/kernel/gate.S	2005-03-23 15:36:10 -08:00
>>+++ b/arch/ia64/kernel/gate.S	2005-03-23 15:36:10 -08:00
>>@@ -79,31 +79,34 @@
>> 	;;
>> 	rsm psr.be // note: on McKinley "rsm psr.be/srlz.d" is slightly faster than "rum
>>psr.be"
>> 	LOAD_FSYSCALL_TABLE(r14)
>>-
>>+	;;
>> 	mov r16=IA64_KR(CURRENT)		// 12 cycle read latency
>>-	tnat.nz p10,p9=r15
>>+	shladd r18=r17,3,r14
>> 	mov r19=NR_syscalls-1
>> 	;;
>>-	shladd r18=r17,3,r14
>>-
>>-	srlz.d
>>-	cmp.ne p8,p0=r0,r0			// p8 <- FALSE
>>+	lfetch [r18]				// M0|1
>>+	mov r29=psr				// read psr (12 cyc load latency)
>> 	/* Note: if r17 is a NaT, p6 will be set to zero.  */
>> 	cmp.geu p6,p7=r19,r17			// (syscall > 0 && syscall <
>>1024+NR_syscalls)?
>> 	;;
>>-(p6)	ld8 r18=[r18]
>> 	mov r21=ar.fpsr
>>-	add r14=-8,r14				// r14 <- addr of fsys_bubble_down entry
>>+	tnat.nz p10,p9=r15
>>+	mov r26=ar.pfs
>> 	;;
>>+	srlz.d
>>+(p6)	ld8 r18=[r18]
>>+	nop.i 0
>>+	;;
>>+	nop.m 0
>> (p6)	mov b7=r18
>>-(p6)	tbit.z p8,p0=r18,0
>>+(p6)	tbit.z.unc p8,p0=r18,0
>>+
>>+	nop.m 0
>>+	nop.i 0
>> (p8)	br.dptk.many b7
>>
>>-(p6)	rsm psr.i
>> 	mov r27=ar.rsc
>>-	mov r26=ar.pfs
>>-	;;
>>-	mov r29=psr				// read psr (12 cyc load latency)
>>+(p6)	rsm psr.i
>> /*
>>  * brl.cond doesn't work as intended because the linker would convert this branch
>>  * into a branch to a PLT.  Perhaps there will be a way to avoid this with some
>>@@ -111,6 +114,8 @@
>>  * instead.
>>  */
>> #ifdef CONFIG_ITANIUM
>>+	add r14=-8,r14				// r14 <- addr of fsys_bubble_down entry
>>+	;;
>> (p6)	ld8 r14=[r14]				// r14 <- fsys_bubble_down
>> 	;;
>> (p6)	mov b7=r14
>>-
>>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
