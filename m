From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 03 Apr 2006 13:45:13 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <443126E9.6080209@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010804060108000001050100"
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010804060108000001050100
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

Chen, Kenneth W wrote:

> Can you do some stress test experiments and let us know how many time ptc.l
> was actually executed in vhpt_miss/tlb_miss/dirty/access
> handler? Thanks.

Here is a patch that adds a small syscall to display or clear (./stat -clear)
the statistics.
Please verify if this is what you wanted (and the potential bugs...).

The 1st version (indicated by "#if 0") I tried, should have worked in virtual
mode. Unfortunately, I could not make it work (having this short deadline).
Could you have a look at it why it fails to work?

I ran a "make -j 16" of the kernel on an 8 processor machine.
(It is actually 2 Tiger boxes connected via a Scalability Port Switch.)
Unfortunately, the I/O is subsystem weak: a single SCSI disk.

Here is what I got:

             VHPT miss counter: 1674978
       VHPT miss - hash purged:       0
        VHPT miss - PTE purged:       0
             ITLB miss counter:     293
            ITLB miss - purged:       0
             DTLB miss counter:    3806
            DTLB miss - purged:       0
            DIRTY trap counter:     224
                DIRTY - purged:       0
         I-ACCESS trap counter:       2
             I-ACCESS - purged:       0
         D-ACCESS trap counter:  173227
             D-ACCESS - purged:       0

Unless I am mistaken, there is no purge observed.
It is very much curious having so few dirty and i-access traps...

Have you got some good & stressing tests?

Zoltan


--------------010804060108000001050100
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="stat.diff"
Content-Disposition: inline;
 filename="stat.diff"

--- save/arch/ia64/kernel/entry.S	2006-03-15 11:07:38.000000000 +0100
+++ linux-2.6.16/arch/ia64/kernel/entry.S	2006-04-03 12:48:03.000000000 +0200
@@ -1619,5 +1619,6 @@ sys_call_table:
 	data8 sys_ni_syscall			// reserved for pselect
 	data8 sys_ni_syscall			// 1295 reserved for ppoll
 	data8 sys_unshare
+	data8 sys_trap_statistics		// 1297
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
--- save/arch/ia64/kernel/ivt.S	2006-03-30 16:19:18.000000000 +0200
+++ linux-2.6.16/arch/ia64/kernel/ivt.S	2006-04-03 14:58:20.000000000 +0200
@@ -108,6 +108,36 @@ ENTRY(vhpt_miss)
 	movl r18=PAGE_SHIFT
 	mov r25=cr.itir
 #endif
+#if 0
+	/*
+	 * Increment the VHPT miss counter - must be identity mapped.
+	 */
+	LOAD_PHYSICAL(p0, r17, fault_statistics + VHPT_idx * _ENTRY_SIZE_)
+	movl r21=(((1 << IA64_MAX_PHYS_BITS) - 1) & ~0xfff)
+	movl r19=PAGE_OFFSET
+	movl r20=PAGE_SHIFT << 2		// ... and protection key == 0
+	movl r22=PAGE_KERNEL
+	;;
+	or r19=r19,r17				// __va(&fault_statistics[VHPT_idx]
+	and r21=r21,r17				// Clear ed, reserved bits, and PTE control bits
+	;;
+	mov cr.ifa=r19
+	mov cr.itir=r20
+	or r21=r21,r22				// Insert control bits
+	;;
+	itc.d r21
+	;;
+	srlz.d
+	// Unsafe: the translation can be killed in the mean time
+	ld8.bias.nta r17=[r19]			// = fault_statistics[VHPT_idx]
+	;;
+	add r17=1,r17
+	mov cr.ifa=r16				// Restore
+	mov cr.itir=r25
+	;;
+	// Unsafe: the translation can be killed in the mean time
+	st8 [r19]=r17				// Not atomic increment - who cares?
+#endif
 	;;
 	rsm psr.dt				// use physical addressing for data
 	mov r31=pr				// save the predicate registers
@@ -132,6 +162,17 @@ ENTRY(vhpt_miss)
 (p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
 
 	srlz.d
+	/*
+	 * Increment the VHPT miss counter.
+	 */
+	LOAD_PHYSICAL(p0, r19, fault_statistics + VHPT_idx * _ENTRY_SIZE_)
+	;;
+	ld8.bias.nta r28=[r19]
+	;;
+	add r28=1,r28
+	;;
+	st8 [r19]=r28				// Not atomic increment - who cares?
+
 	LOAD_PHYSICAL(p6, r19, swapper_pg_dir)	// region 5 is rooted at swapper_pg_dir
 
 	.pred.rel "mutex", p6, p7
@@ -197,11 +238,12 @@ ENTRY(vhpt_miss)
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * We make sure the visibility of itc.* to generated purges (like ptc.ga)
+	 * before we re-read the *pgd ... PTE.
+	 * Having itc.i-d a new translation, there is no need for srlz.i, the rfi below
+	 * will do the serialization.
 	 */
-	dv_serialize_data
-
+(p7)	srlz.d
 	/*
 	 * Re-check pagetable entry.  If they changed, we may have received a ptc.g
 	 * between reading the pagetable and the "itc".  If so, flush the entry we
@@ -229,9 +271,34 @@ ENTRY(vhpt_miss)
 	mov r27=PAGE_SHIFT<<2
 	;;
 (p6)	ptc.l r22,r27				// purge PTE page translation
+	/*
+	 * Increment the VHPT miss - purge PTE page counter.
+	 * It is the next long. Accessed via its physical address.
+	 */
+	dv_serialize_data
+	LOAD_PHYSICAL(p6, r19, fault_statistics + (VHPT_idx + 1) * _ENTRY_SIZE_)
+	;;
+(p6)	ld8.bias.nta r17=[r19]
+	;;
+(p6)	add r17=1,r17
+	;;
+(p6)	st8 [r19]=r17				// Not atomic increment - who cares?
+
 (p7)	cmp.ne.or.andcm p6,p7=r25,r18		// did *pte change
 	;;
 (p6)	ptc.l r16,r27				// purge translation
+	/*
+	 * Increment the VHPT miss - purge PTE page counter.
+	 * It is in the 2nd next long. Accessed via its physical address.
+	 */
+	dv_serialize_data
+	LOAD_PHYSICAL(p6, r19, fault_statistics + (VHPT_idx + 2) * _ENTRY_SIZE_)
+	;;
+(p6)	ld8.bias.nta r17=[r19]
+	;;
+(p6)	add r17=1,r17
+	;;
+(p6)	st8 [r19]=r17				// Not atomic increment - who cares?
 #endif
 
 	mov pr=r31,-1				// restore predicate registers
@@ -266,16 +333,36 @@ ENTRY(itlb_miss)
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * We make sure the visibility of itc.i to generated purges (like ptc.ga)
+	 * before we re-read the PTE.
+	 * There is no need for srlz.i, the rfi below will do the serialization.
 	 */
-	dv_serialize_data
-
+	srlz.d
 	ld8 r19=[r17]				// read *pte again and see if same
 	mov r20=PAGE_SHIFT<<2			// setup page size for purge
 	;;
 	cmp.ne p7,p0=r18,r19
 	;;
+	/*
+	 * Increment the ITLB miss counters.
+	 */
+	rsm psr.dt				// use physical addressing for data
+	;;
+	srlz.d
+	LOAD_PHYSICAL(p0, r19, fault_statistics + ITLB_idx * _ENTRY_SIZE_)
+	;;
+	ld8.bias.nta r28=[r19]
+	;;
+	add r28=1,r28
+	;;
+	st8 [r19]=r28,8				// Not atomic increment - who cares?
+	;;
+(p7)	ld8.bias.nta r28=[r19]			// Next long: ITLB miss - purged
+	;;
+(p7)	add r28=1,r28
+	;;
+(p7)	st8 [r19]=r28				// Not atomic increment - who cares?
+
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=r31,-1
@@ -310,16 +397,35 @@ dtlb_fault:
 	;;
 #ifdef CONFIG_SMP
 	/*
-	 * Tell the assemblers dependency-violation checker that the above "itc" instructions
-	 * cannot possibly affect the following loads:
+	 * We make sure the visibility of itc.d to generated purges (like ptc.ga)
+	 * before we re-read the PTE.
 	 */
-	dv_serialize_data
-
+	srlz.d
 	ld8 r19=[r17]				// read *pte again and see if same
 	mov r20=PAGE_SHIFT<<2			// setup page size for purge
 	;;
 	cmp.ne p7,p0=r18,r19
 	;;
+	/*
+	 * Increment the DTLB miss counters.
+	 */
+	rsm psr.dt				// use physical addressing for data
+	;;
+	srlz.d
+	LOAD_PHYSICAL(p0, r19, fault_statistics + DTLB_idx * _ENTRY_SIZE_)
+	;;
+	ld8.bias.nta r28=[r19]
+	;;
+	add r28=1,r28
+	;;
+	st8 [r19]=r28,8				// Not atomic increment - who cares?
+	;;
+(p7)	ld8.bias.nta r28=[r19]			// Next long: DTLB miss - purged
+	;;
+(p7)	add r28=1,r28
+	;;
+(p7)	st8 [r19]=r28				// Not atomic increment - who cares?
+
 (p7)	ptc.l r16,r20
 #endif
 	mov pr=r31,-1
@@ -589,6 +695,26 @@ ENTRY(dirty_bit)
 	 *     very same dirty bit as we wanted to => our new translation is correct)
 	 */
 (p7)	ptc.l r16,r24
+	/*
+	 * Increment the DIRTY trap counters.
+	 */
+	rsm psr.dt				// use physical addressing for data
+	;;
+	srlz.d
+	LOAD_PHYSICAL(p0, r19, fault_statistics + DIRTY_idx * _ENTRY_SIZE_)
+	;;
+	ld8.bias.nta r27=[r19]
+	;;
+	add r27=1,r27
+	;;
+	st8 [r19]=r27,8				// Not atomic increment - who cares?
+	;;
+(p7)	ld8.bias.nta r27=[r19]			// Next long: DIRTY - purged
+	;;
+(p7)	add r27=1,r27
+	;;
+(p7)	st8 [r19]=r27				// Not atomic increment - who cares?
+
 	mov b0=r29				// restore b0
 	mov ar.ccv=r28
 #else
@@ -650,6 +776,26 @@ ENTRY(iaccess_bit)
 	mov r24=PAGE_SHIFT << 2
 	;;
 (p7)	ptc.l r16,r24
+	/*
+	 * Increment the I-ACCESS trap counters.
+	 */
+	rsm psr.dt				// use physical addressing for data
+	;;
+	srlz.d
+	LOAD_PHYSICAL(p0, r19, fault_statistics + IACC_idx * _ENTRY_SIZE_)
+	;;
+	ld8.bias.nta r27=[r19]
+	;;
+	add r27=1,r27
+	;;
+	st8 [r19]=r27,8				// Not atomic increment - who cares?
+	;;
+(p7)	ld8.bias.nta r27=[r19]			// Next long: I-ACCESS - purged
+	;;
+(p7)	add r27=1,r27
+	;;
+(p7)	st8 [r19]=r27				// Not atomic increment - who cares?
+
 	mov b0=r29				// restore b0
 	mov ar.ccv=r28
 #else
@@ -700,6 +846,26 @@ ENTRY(daccess_bit)
 	mov r24=PAGE_SHIFT << 2
 	;;
 (p7)	ptc.l r16,r24
+	/*
+	 * Increment the D-ACCESS trap counters.
+	 */
+	rsm psr.dt				// use physical addressing for data
+	;;
+	srlz.d
+	LOAD_PHYSICAL(p0, r19, fault_statistics + DACC_idx * _ENTRY_SIZE_)
+	;;
+	ld8.bias.nta r27=[r19]
+	;;
+	add r27=1,r27
+	;;
+	st8 [r19]=r27,8				// Not atomic increment - who cares?
+	;;
+(p7)	ld8.bias.nta r27=[r19]			// Next long: D-ACCESS - purged
+	;;
+(p7)	add r27=1,r27
+	;;
+(p7)	st8 [r19]=r27				// Not atomic increment - who cares?
+
 	mov b0=r29				// restore b0
 	mov ar.ccv=r28
 #else
--- save/kernel/sched.c	2006-03-15 11:09:03.000000000 +0100
+++ linux-2.6.16/kernel/sched.c	2006-04-03 15:06:57.000000000 +0200
@@ -199,6 +192,26 @@ struct prio_array {
 	struct list_head queue[MAX_PRIO];
 };
 
+
+long fault_statistics[MAX_TRAP_idx];
+
+
+/*
+ * Read / clear trap statistics
+ */
+asmlinkage long sys_trap_statistics(int index)
+{
+	if (index >= 0 && index < MAX_TRAP_idx)
+		return fault_statistics[index];
+	if (index == -1){
+		for (index = 0; index < MAX_TRAP_idx; index++)
+			fault_statistics[index] = 0;
+		return 0;
+	}
+	return -EINVAL;
+}
+
+
 /*
  * This is the main, per-CPU runqueue data structure.
  *
--- save/include/asm-ia64/system.h	2006-03-15 11:08:53.000000000 +0100
+++ linux-2.6.16/include/asm-ia64/system.h	2006-04-03 14:26:19.000000000 +0200
@@ -262,4 +262,28 @@ void sched_cacheflush(void);
 
 #endif /* __ASSEMBLY__ */
 
+
+/*
+ * For trap statistics
+ */
+#define	VHPT_idx		0		// VHPT miss counter
+#define	VHPT_HASH_PTC_idx	1		// VHPT miss - hash purged
+#define	VHPT_PTE_PTC_idx	2		// VHPT miss - PTE purged
+#define	ITLB_idx		3		// ITLB miss counter
+#define	ITLB_PTC_idx		4		// ITLB miss - purged
+#define	DTLB_idx		5		// DTLB miss counter
+#define	DTLB_PTC_idx		6		// DTLB miss - purged
+#define	DIRTY_idx		7		// DIRTY trap counter
+#define	DIRTY_PTC_idx		8		// DIRTY - purged
+#define	IACC_idx		9		// I-ACCESS trap counter
+#define	IACC_PTC_idx		10		// I-ACCESS - purged
+#define	DACC_idx		11		// D-ACCESS trap counter
+#define	DACC_PTC_idx		12		// D-ACCESS - purged
+
+
+#define	MAX_TRAP_idx		13
+
+#define	_ENTRY_SIZE_		8
+
+
 #endif /* _ASM_IA64_SYSTEM_H */
--- save/include/asm-ia64/unistd.h	2006-03-15 11:08:53.000000000 +0100
+++ linux-2.6.16/include/asm-ia64/unistd.h	2006-04-03 12:46:40.000000000 +0200
@@ -290,7 +290,7 @@
 
 #include <linux/config.h>
 
-#define NR_syscalls			273 /* length of syscall table */
+#define NR_syscalls			274 /* length of syscall table */
 
 #define __ARCH_WANT_SYS_RT_SIGACTION
 

--------------010804060108000001050100
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="stat.c"
Content-Disposition: inline;
 filename="stat.c"

#include <sys/syscall.h>
#include <unistd.h>


/*
 * For trap statistics
 * Use "-1" to clear the counters
 */
#define	VHPT_idx		0		// VHPT miss counter
#define	VHPT_HASH_PTC_idx	1		// VHPT miss - hash purged
#define	VHPT_PTE_PTC_idx	2		// VHPT miss - PTE purged
#define	ITLB_idx		3		// ITLB miss counter
#define	ITLB_PTC_idx		4		// ITLB miss - purged
#define	DTLB_idx		5		// DTLB miss counter
#define	DTLB_PTC_idx		6		// DTLB miss - purged
#define	DIRTY_idx		7		// DIRTY trap counter
#define	DIRTY_PTC_idx		8		// DIRTY - purged
#define	IACC_idx		9		// I-ACCESS trap counter
#define	IACC_PTC_idx		10		// I-ACCESS - purged
#define	DACC_idx		11		// D-ACCESS trap counter
#define	DACC_PTC_idx		12		// D-ACCESS - purged


#define	MAX_TRAP_idx		13

#define	_ENTRY_SIZE_		8


#define	sys_trap_statistics	1297


char *names[] = {
	"VHPT miss counter",
	"VHPT miss - hash purged",
	"VHPT miss - PTE purged",
	"ITLB miss counter",
	"ITLB miss - purged",
	"DTLB miss counter",
	"DTLB miss - purged",
	"DIRTY trap counter",
	"DIRTY - purged",
	"I-ACCESS trap counter",
	"I-ACCESS - purged",
	"D-ACCESS trap counter",
	"D-ACCESS - purged",
};


main(int cnt, char *args[])
{
	int index;
	long count;

	if (cnt == 2 && strcmp(args[1], "-clear") == 0){
		if (syscall(sys_trap_statistics, -1) == -1){
			perror("sys_trap_statistics");
			exit(1);
		}
		exit(0);
	}
	for (index = 0; index < MAX_TRAP_idx; index++){
		count = syscall(sys_trap_statistics, index);
		if (count == -1){
			perror("sys_trap_statistics");
			exit(1);
		}
		printf("%30s: %7ld\n", names[index], count);
	}
	exit(0);
}

--------------010804060108000001050100--
