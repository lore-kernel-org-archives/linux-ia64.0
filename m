From: Russ Anderson <rja@sgi.com>
Date: Fri, 27 Apr 2007 21:29:08 +0000
Subject: [patch] Support multiple CPUs going through OS_MCA
Message-Id: <200704272129.l3RLT8Ob64391823@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Support multiple CPUs going through OS_MCA

Linux does not gracefully deal with multiple processors going
through OS_MCA aa part of the same MCA event.  The first cpu
into OS_MCA grabs the ia64_mca_serialize lock.  Subsequent
cpus wait for that lock, preventing them from reporting in as
rendezvoused.  The first cpu waits 5 seconds then complains
that all the cpus have not rendezvoused.  The first cpu then
handles its MCA and frees up all the rendezvoused cpus and
releases the ia64_mca_serialize lock.  One of the subsequent
cpus going thought OS_MCA then gets the ia64_mca_serialize
lock, waits another 5 seconds and then complains that none of
the other cpus have rendezvoused.  

This patch allows multiple CPUs to gracefully go through OS_MCA.

The first CPU into ia64_mca_handler() grabs a mca_count lock.  
Subsequent CPUs into ia64_mca_handler() are added to a list of cpus 
that need to go through OS_MCA (a bit set in mca_cpu), and report
in as rendezvoused, and but spin waiting their turn.

The first CPU sees everyone rendezvous, handles his MCA, wakes up
one of the other CPUs waiting to process their MCA (by clearing
one mca_cpu bit), and then waits for the other cpus to complete
their MCA handling.  The next CPU handles his MCA and the process
repeats until all the CPUs have handled their MCA.  When the last
CPU has handled it's MCA, it sets monarch_cpu to -1, releasing all
the CPUs.

In testing this works more reliably and faster. 

Thanks to Keith Owens for suggesting numerous improvements
to this code.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/kernel/mca.c     |   61 +++++++++++++++++++++++++++++++++++++++------
 arch/ia64/kernel/mca_asm.S |   12 --------
 include/asm-ia64/mca.h     |    1 
 3 files changed, 55 insertions(+), 19 deletions(-)

Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2007-04-13 13:28:52.822883294 -0500
+++ test/arch/ia64/kernel/mca.c	2007-04-27 10:39:46.880158709 -0500
@@ -57,6 +57,9 @@
  *
  * 2006-09-15 Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
  * 	      Add printing support for MCA/INIT.
+ *
+ * 2007-04-27 Russ Anderson <rja@sgi.com>
+ *	      Support multiple cpus going through OS_MCA in the same event.
  */
 #include <linux/types.h>
 #include <linux/init.h>
@@ -97,7 +100,6 @@
 #endif
 
 /* Used by mca_asm.S */
-u32				ia64_mca_serialize;
 DEFINE_PER_CPU(u64, ia64_mca_data); /* = __per_cpu_mca[smp_processor_id()] */
 DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area */
 DEFINE_PER_CPU(u64, ia64_mca_pal_pte);	    /* PTE to map PAL code */
@@ -963,11 +965,12 @@ ia64_mca_modify_original_stack(struct pt
 		goto no_mod;
 	}
 
+	if (r13 != sos->prev_IA64_KR_CURRENT) {
+		msg = "inconsistent previous current and r13";
+		goto no_mod;
+	}
+
 	if (!mca_recover_range(ms->pmsa_iip)) {
-		if (r13 != sos->prev_IA64_KR_CURRENT) {
-			msg = "inconsistent previous current and r13";
-			goto no_mod;
-		}
 		if ((r12 - r13) >= KERNEL_STACK_SIZE) {
 			msg = "inconsistent r12 and r13";
 			goto no_mod;
@@ -1187,6 +1190,13 @@ all_in:
  *	further MCA logging is enabled by clearing logs.
  *	Monarch also has the duty of sending wakeup-IPIs to pull the
  *	slave processors out of rendezvous spinloop.
+ *
+ *	If multiple processors call into OS_MCA, the first will become
+ *	the monarch.  Subsequent cpus will be recorded in the mca_cpu
+ *	bitmask.  After the first monarch has processed its MCA, it
+ *	will wake up the next cpu in the mca_cpu bitmask and then go
+ *	into the rendezvous loop.  When all processors have serviced
+ *	their MCA, the last monarch frees up the rest of the processors.
  */
 void
 ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
@@ -1196,16 +1206,32 @@ ia64_mca_handler(struct pt_regs *regs, s
 	struct task_struct *previous_current;
 	struct ia64_mca_notify_die nd  		{ .sos = sos, .monarch_cpu = &monarch_cpu };
+	static atomic_t mca_count;
+	static cpumask_t mca_cpu;
 
+	if (atomic_add_return(1, &mca_count) = 1) {
+		monarch_cpu = cpu;
+		sos->monarch = 1;
+	} else {
+		cpu_set(cpu, mca_cpu);
+		sos->monarch = 0;
+	}
 	mprintk(KERN_INFO "Entered OS MCA handler. PSP=%lx cpu=%d "
 		"monarch=%ld\n", sos->proc_state_param, cpu, sos->monarch);
 
 	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "MCA");
-	monarch_cpu = cpu;
+
 	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
-	ia64_wait_for_slaves(cpu, "MCA");
+	if (sos->monarch) {
+		ia64_wait_for_slaves(cpu, "MCA");
+	} else {
+		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_CONCURRENT_MCA;
+		while (cpu_isset(cpu, mca_cpu))
+	       		cpu_relax();	/* spin until monarch wakes us */
+		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
+        }
 
 	/* Wakeup all the processors which are spinning in the rendezvous loop.
 	 * They will leave SAL, then spin in the OS with interrupts disabled
@@ -1232,6 +1258,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 		rh->severity = sal_log_severity_corrected;
 		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
 		sos->os_status = IA64_MCA_CORRECTED;
+		ia64_mlogbuf_dump();
 	} else {
 		/* Dump buffered message to console */
 		ia64_mlogbuf_finish(1);
@@ -1244,6 +1271,26 @@ ia64_mca_handler(struct pt_regs *regs, s
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
+
+	if (atomic_dec_return(&mca_count) > 0) {
+		int i;
+
+		/* wake up the next monarch cpu,
+		 * and put this cpu in the rendez loop.
+		 */
+		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_CONCURRENT_MCA;
+		for_each_online_cpu(i) {
+			if (cpu_isset(i, mca_cpu)) {
+				monarch_cpu = i;
+				cpu_clear(i, mca_cpu);	/* wake next cpu */
+				while (monarch_cpu != -1)
+					cpu_relax();	/* spin until last cpu leaves */
+				ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
+				set_curr_task(cpu, previous_current);
+				return;
+			}
+		}
+	}
 	set_curr_task(cpu, previous_current);
 	monarch_cpu = -1;
 }
Index: test/arch/ia64/kernel/mca_asm.S
=================================--- test.orig/arch/ia64/kernel/mca_asm.S	2007-04-13 13:28:52.830884267 -0500
+++ test/arch/ia64/kernel/mca_asm.S	2007-04-13 18:05:19.565878142 -0500
@@ -141,14 +141,6 @@ ia64_do_tlb_purge:
 //StartMain////////////////////////////////////////////////////////////////////
 
 ia64_os_mca_dispatch:
-	// Serialize all MCA processing
-	mov	r3=1;;
-	LOAD_PHYSICAL(p0,r2,ia64_mca_serialize);;
-ia64_os_mca_spin:
-	xchg4	r4=[r2],r3;;
-	cmp.ne	p6,p0=r4,r0
-(p6)	br ia64_os_mca_spin
-
 	mov r3=IA64_MCA_CPU_MCA_STACK_OFFSET	// use the MCA stack
 	LOAD_PHYSICAL(p0,r2,1f)			// return address
 	mov r19=1				// All MCA events are treated as monarch (for now)
@@ -314,10 +306,6 @@ END(ia64_os_mca_virtual_begin)
 1:
 
 	mov		b0=r12			// SAL_CHECK return address
-
-	// release lock
-	LOAD_PHYSICAL(p0,r3,ia64_mca_serialize);;
-	st4.rel		[r3]=r0
 
 	br		b0
 
Index: test/include/asm-ia64/mca.h
=================================--- test.orig/include/asm-ia64/mca.h	2007-04-09 13:24:38.000000000 -0500
+++ test/include/asm-ia64/mca.h	2007-04-13 17:54:55.935180331 -0500
@@ -48,6 +48,7 @@ enum {
 	IA64_MCA_RENDEZ_CHECKIN_NOTDONE	=	0x0,
 	IA64_MCA_RENDEZ_CHECKIN_DONE	=	0x1,
 	IA64_MCA_RENDEZ_CHECKIN_INIT	=	0x2,
+	IA64_MCA_RENDEZ_CHECKIN_CONCURRENT_MCA	=	0x3,
 };
 
 /* Information maintained by the MC infrastructure */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
