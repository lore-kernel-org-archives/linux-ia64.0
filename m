From: "Peter Keilty" <Peter.Keilty@hp.com>
Date: Thu, 27 Oct 2005 17:28:14 +0000
Subject: ia64 get_mmu_context patch
Message-Id: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_NextPart_000_002C_01C5DAFA.54FB9460"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_002C_01C5DAFA.54FB9460
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

 
 
Gentleman,

Please find attached IA64 context_id patch and supporting data for your
Review and consideration.

Regards,
pete

------=_NextPart_000_002C_01C5DAFA.54FB9460
Content-Type: text/plain;
	name="ctx_bitmap.patch3"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="ctx_bitmap.patch3"



Signed-off-by:

--- linux-2.6.14-rc3/include/asm-ia64/mmu_context.h	2005-10-26 =
10:54:53.000000000 -0400
+++ linux-2.6.14-rc3pmk/include/asm-ia64/mmu_context.h	2005-10-06 =
16:39:27.000000000 -0400
@@ -34,11 +34,13 @@
 	unsigned int next;	/* next context number to use */
 	unsigned int limit;	/* next >=3D limit =3D> must call =
wrap_mmu_context() */
 	unsigned int max_ctx;	/* max. context value supported by all CPUs */
+	unsigned long *bitmap;	/* bitmap size is max_ctx+1 */
 };
=20
 extern struct ia64_ctx ia64_ctx;
 DECLARE_PER_CPU(u8, ia64_need_tlb_flush);
=20
+extern void mmu_context_init (void);
 extern void wrap_mmu_context (struct mm_struct *mm);
=20
 static inline void
@@ -86,6 +88,7 @@
 				if (ia64_ctx.next >=3D ia64_ctx.limit)
 					wrap_mmu_context(mm);
 				mm->context =3D context =3D ia64_ctx.next++;
+	 			set_bit(context, ia64_ctx.bitmap);
 			}
 		}
 		spin_unlock_irqrestore(&ia64_ctx.lock, flags);
--- linux-2.6.14-rc3/include/asm-ia64/tlbflush.h	2005-08-28 =
19:41:01.000000000 -0400
+++ linux-2.6.14-rc3pmk/include/asm-ia64/tlbflush.h	2005-10-06 =
16:15:47.000000000 -0400
@@ -51,6 +51,7 @@
 	if (!mm)
 		return;
=20
+	clear_bit(mm->context, ia64_ctx.bitmap);
 	mm->context =3D 0;
=20
 	if (atomic_read(&mm->mm_users) =3D=3D 0)
--- linux-2.6.14-rc3/arch/ia64/mm/tlb.c	2005-08-28 19:41:01.000000000 =
-0400
+++ linux-2.6.14-rc3pmk/arch/ia64/mm/tlb.c	2005-10-25 14:55:25.000000000 =
-0400
@@ -16,12 +16,14 @@
 #include <linux/sched.h>
 #include <linux/smp.h>
 #include <linux/mm.h>
+#include <linux/bootmem.h>
=20
 #include <asm/delay.h>
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 #include <asm/pal.h>
 #include <asm/tlbflush.h>
+#include <asm/dma.h>
=20
 static struct {
 	unsigned long mask;	/* mask of supported purge page-sizes */
@@ -38,13 +40,32 @@
 DEFINE_PER_CPU(u8, ia64_need_tlb_flush);
=20
 /*
+ * Initializes the ia64_ctx.bitmap array based on max_ctx+1.
+ * Called after cpu_init() has setup ia64_ctx.max_ctx based on
+ * maximum RID that is supported by all CPUs.
+ */
+void __init
+mmu_context_init (void)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&ia64_ctx.lock, flags);
+	if (ia64_ctx.bitmap =3D=3D NULL) {
+		ia64_ctx.bitmap =3D (unsigned long *)__alloc_bootmem(
+							(ia64_ctx.max_ctx+1)>>3,
+							PAGE_SIZE,
+							__pa(MAX_DMA_ADDRESS));
+	}
+	spin_unlock_irqrestore(&ia64_ctx.lock, flags);
+}
+
+/*
  * Acquire the ia64_ctx.lock before calling this function!
  */
 void
 wrap_mmu_context (struct mm_struct *mm)
 {
-	unsigned long tsk_context, max_ctx =3D ia64_ctx.max_ctx;
-	struct task_struct *tsk;
+	unsigned int next_ctx, max_ctx =3D ia64_ctx.max_ctx;
 	int i;
=20
 	if (ia64_ctx.next > max_ctx)
@@ -52,28 +73,23 @@
 	ia64_ctx.limit =3D max_ctx + 1;
=20
 	/*
-	 * Scan all the task's mm->context and set proper safe range
+	 * Scan the ia64_ctx bitmap and set proper safe range
 	 */
+repeat:
+	next_ctx =3D find_next_zero_bit(ia64_ctx.bitmap, ia64_ctx.limit, =
ia64_ctx.next);
+	if (next_ctx >=3D ia64_ctx.limit) {
+		smp_mb();
+		ia64_ctx.next =3D 300;	/* skip daemons */
+		goto repeat;
+	}
+	ia64_ctx.next =3D next_ctx;
=20
-	read_lock(&tasklist_lock);
-  repeat:
-	for_each_process(tsk) {
-		if (!tsk->mm)
-			continue;
-		tsk_context =3D tsk->mm->context;
-		if (tsk_context =3D=3D ia64_ctx.next) {
-			if (++ia64_ctx.next >=3D ia64_ctx.limit) {
-				/* empty range: reset the range limit and start over */
-				if (ia64_ctx.next > max_ctx)
-					ia64_ctx.next =3D 300;
-				ia64_ctx.limit =3D max_ctx + 1;
-				goto repeat;
-			}
-		}
-		if ((tsk_context > ia64_ctx.next) && (tsk_context < ia64_ctx.limit))
-			ia64_ctx.limit =3D tsk_context;
+	next_ctx =3D find_next_bit(ia64_ctx.bitmap, ia64_ctx.limit, =
ia64_ctx.next);
+	if (next_ctx >=3D ia64_ctx.limit) {
+		next_ctx =3D ia64_ctx.limit;
 	}
-	read_unlock(&tasklist_lock);
+	ia64_ctx.limit =3D next_ctx;
+
 	/* can't call flush_tlb_all() here because of race condition with O(1) =
scheduler [EF] */
 	{
 		int cpu =3D get_cpu(); /* prevent preemption/migration */
--- linux-2.6.14-rc3/arch/ia64/kernel/setup.c	2005-10-26 =
10:54:06.000000000 -0400
+++ linux-2.6.14-rc3pmk/arch/ia64/kernel/setup.c	2005-10-25 =
14:53:59.000000000 -0400
@@ -419,6 +419,7 @@
 #endif
=20
 	cpu_init();	/* initialize the bootstrap CPU */
+	mmu_context_init();	/* initialize context_id bitmap */
=20
 #ifdef CONFIG_ACPI
 	acpi_boot_init();
@@ -798,9 +799,13 @@
 #endif
=20
 	/* set ia64_ctx.max_rid to the maximum RID that is supported by all =
CPUs: */
-	if (ia64_pal_vm_summary(NULL, &vmi) =3D=3D 0)
+	if (ia64_pal_vm_summary(NULL, &vmi) =3D=3D 0) {
 		max_ctx =3D (1U << (vmi.pal_vm_info_2_s.rid_size - 3)) - 1;
-	else {
+		if (max_ctx > (1U << 21)) {
+			max_ctx =3D (1U << 21) - 1;	/* limit to 2^21  */
+			printk(KERN_WARNING "cpu_init: max_ctx limited to 21 RID bits for =
bitmap size\n");
+		}
+	} else {
 		printk(KERN_WARNING "cpu_init: PAL VM summary failed, assuming 18 RID =
bits\n");
 		max_ctx =3D (1U << 15) - 1;	/* use architected minimum */
 	}

------=_NextPart_000_002C_01C5DAFA.54FB9460
Content-Type: message/rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment

From: "Peter Keilty" <Peter.Keilty@hp.com>
To: <tony.luck@intel.com>
Subject: FW: Proprosed patch for get_mmu_context issue.
Date: Wed, 5 Oct 2005 13:36:39 -0400
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0029_01C5DAFA.54FA0DC0"
X-Mailer: Microsoft Office Outlook, Build 11.0.6353
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2900.2180
Thread-Index: AcXJ0pHL5bVaRU8PQu6bsCIVOn2/+QAAI/jQ

This is a multi-part message in MIME format.

------=_NextPart_000_0029_01C5DAFA.54FA0DC0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

 

Hi Tony,

I have attached a patch for an issue with get_mmu_context() seen seen with
RHEL 2.6.9-15 base code.
I would like you to take a look review and comment on it's merits.
Bob Picco has review the patch prior to me senting it to you.
 
Data on problem:

Here is the results of modifing the code using a bitmap for looking up new
context_id.

Updated png showing AIM7 shared run with before, after and clm data.   

Lockstat Data:
There are 4 sets of lockstat data, one each for loads of 40K, 30K, 20K and
40K with no fork test. The lockstat data shows that as loading increases the
lock contention on the task lock with wrap_mmu_context and higher
utilization of the ia64_ctx lock and the ia64_global_tlb_purge lock. 

Get_mmu_context() is called to get a new process context id number to
uniquely identify it's address space and tbl entries. If the limit is
reached the wrap_mmu_context is called to reset and flush the tlb's.
 
Wrap_mmu_context()  uses ia64_ctx.max_ctx which is set based on ia64 arch.
rid size minus 3 bits used for region number. For Itanium the size is 24
bits, so there are 21 bits used as an increment number. This number and the
region register number (3bits) is used as the process address space number
and is used in the tbl to identify tbl's associated with this process. So
about 2^21 new processes can run before context_id wrapping occurs and the
systems tbl's are flushed.

The difference in the number of times the ia64_ctx  was acquired between
running the fork test and not at 40K load is: 
Lock                         Fork              No Fork
ia64_ctx	                   9,111,760        1,162,555
ia64_global_tlb_purge        101,371,392       33,888,711

Read Task Lock per second for wrap_mmu_context()
Load       Locks/Sec  Contention
20,000         5.8           20%
30,000        10.2           31%
40,000        14.6           39%
40,000          .0001         0%  No Fork or Exec test

Notice the utilization percent for the ia64_ctx and tasklist_lock locks for
the 4 runs.
20K    10%
30K    27%
40K    54%
40K     1%  nofork  
This utilization is based on the number of cycles the lock was busy for the
measurement period.  

Modified the number of bits used in the region id reg for context increment
from 21 to 20 bits. This would cause wrap_mmu_context to be done sooner at
2^21.

Aim7 shared with fork:
Load  21bits   20bits
20K    66K      58K  jobs/min
30K    58K      38K  jobs/min
40K    44K      25K  jobs/min
So now a load of 20K acts like 30K at 21bits and a load of 30K acts like 40K
at 21bits.

The cost of having to search the entire task_list to find a free context
number increases with number of processes in the tests. The following are
the measure times for the wrap_mmu_context function.

Before:
Aim7 shared with fork/exec tests time spent in wrap_mmu_context() walking
task loop.
Load  Jobs/min    Calls  Maxprocs  Cumulative Time  Time/call  Total Run
Time
30K      53279    33828     38198        864.0 sec    25.5 ms     62 min   
40K      42378    79840     52496       2667.4 sec    33.4 ms    108 min
50K      31955   141000     75472       6011.5 sec    42.6 ms    180 min

Modified patch:
Aim7 shared with fork/exec tests time spent in wrap_mmu_context() using 128K
bitmap.
Load  Jobs/min     Calls  Maxprocs  Cumulative Time  Time/call  Total Run
Time      
30K	   61350   1764278     na	     .312 sec      177 ns      48
min    
40K	   60858   3203092     na	     .561 sec	 175 ns      64 min
50K	   60826   5110677     na	     .887 sec      174 ns      80 in

Making the bitmap 512K reduced the tlb flush substantially but the jobs/min
only increased by about 100-150. The 512k size is 1/4 of the max it could
be, 2^21. The patch uses the total 2^21 size.

Lockstat data shows 0% contention of the rwlock task_list in
wrap_mmu_context() and the utilization goes from 54% to 1.6%.
The ia64_ctx lock utlization goes from 54% to 0.1% and the contention down
to 0.3%.

Regards,
pete

------=_NextPart_000_0029_01C5DAFA.54FA0DC0
Content-Type: application/octet-stream;
	name="my-ctx_bitmap.patch2"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="my-ctx_bitmap.patch2"

--- linux-2.6.9_base/include/asm-ia64/mmu_context.h	2005-09-02 =
14:56:31.000000000 -0400
+++ linux-2.6.9/include/asm-ia64/mmu_context.h	2005-10-05 =
10:10:36.000000000 -0400
@@ -33,11 +33,13 @@
 	unsigned int next;	/* next context number to use */
 	unsigned int limit;	/* next >=3D limit =3D> must call =
wrap_mmu_context() */
 	unsigned int max_ctx;	/* max. context value supported by all CPUs */
+	unsigned long *bitmap;	/* bitmap size is max_ctx+1 */
 };
=20
 extern struct ia64_ctx ia64_ctx;
 DECLARE_PER_CPU(u8, ia64_need_tlb_flush);
=20
+extern void mmu_context_init (void);
 extern void wrap_mmu_context (struct mm_struct *mm);
=20
 static inline void
@@ -80,6 +82,7 @@
 			if (ia64_ctx.next >=3D ia64_ctx.limit)
 				wrap_mmu_context(mm);
 			mm->context =3D context =3D ia64_ctx.next++;
+			set_bit(context, ia64_ctx.bitmap);
 		}
 	}
 	spin_unlock_irqrestore(&ia64_ctx.lock, flags);
--- linux-2.6.9_base/include/asm-ia64/tlbflush.h	2005-09-02 =
14:56:31.000000000 -0400
+++ linux-2.6.9/include/asm-ia64/tlbflush.h	2005-09-30 =
11:11:11.000000000 -0400
@@ -51,6 +51,7 @@
 	if (!mm)
 		return;
=20
+	clear_bit(mm->context, ia64_ctx.bitmap);
 	mm->context =3D 0;
=20
 	if (atomic_read(&mm->mm_users) =3D=3D 0)
--- linux-2.6.9_base/arch/ia64/mm/tlb.c	2005-09-02 14:56:53.000000000 =
-0400
+++ linux-2.6.9/arch/ia64/mm/tlb.c	2005-10-05 10:10:48.000000000 -0400
@@ -16,12 +16,14 @@
 #include <linux/sched.h>
 #include <linux/smp.h>
 #include <linux/mm.h>
+#include <linux/bootmem.h>
=20
 #include <asm/delay.h>
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 #include <asm/pal.h>
 #include <asm/tlbflush.h>
+#include <asm/dma.h>
=20
 static struct {
 	unsigned long mask;	/* mask of supported purge page-sizes */
@@ -32,19 +34,39 @@
 	.lock =3D		SPIN_LOCK_UNLOCKED,
 	.next =3D		1,
 	.limit =3D	(1 << 15) - 1,		/* start out with the safe (architected) =
limit */
-	.max_ctx =3D	~0U
+	.max_ctx =3D	~0U,
+	.bitmap =3D 	NULL
 };
=20
 DEFINE_PER_CPU(u8, ia64_need_tlb_flush);
=20
 /*
+ * Initializes the ia64_ctx.bitmap array based on max_ctx+1.
+ * Called after cpu_init() has setup ia64_ctx.max_ctx based on
+ * maximum RID that is supported by all CPUs.
+ */
+void __init
+mmu_context_init (void)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&ia64_ctx.lock, flags);
+	if (ia64_ctx.bitmap =3D=3D NULL) {
+		ia64_ctx.bitmap =3D (unsigned long *)__alloc_bootmem(
+							ia64_ctx.max_ctx+1,
+							PAGE_SIZE,
+							__pa(MAX_DMA_ADDRESS));
+	}
+	spin_unlock_irqrestore(&ia64_ctx.lock, flags);
+}
+
+/*
  * Acquire the ia64_ctx.lock before calling this function!
  */
 void
 wrap_mmu_context (struct mm_struct *mm)
 {
-	unsigned long tsk_context, max_ctx =3D ia64_ctx.max_ctx;
-	struct task_struct *tsk;
+	unsigned int next_ctx, max_ctx =3D ia64_ctx.max_ctx;
 	int i;
=20
 	if (ia64_ctx.next > max_ctx)
@@ -52,28 +74,23 @@
 	ia64_ctx.limit =3D max_ctx + 1;
=20
 	/*
-	 * Scan all the task's mm->context and set proper safe range
+	 * Scan the ia64_ctx bitmap and set proper safe range
 	 */
+repeat:
+	next_ctx =3D find_next_zero_bit(ia64_ctx.bitmap, ia64_ctx.limit, =
ia64_ctx.next);
+	if (next_ctx >=3D ia64_ctx.limit) {
+		smp_mb();
+		ia64_ctx.next =3D 300;	/* skip daemons */
+		goto repeat;
+	}
+	ia64_ctx.next =3D next_ctx;
=20
-	read_lock(&tasklist_lock);
-  repeat:
-	for_each_process(tsk) {
-		if (!tsk->mm)
-			continue;
-		tsk_context =3D tsk->mm->context;
-		if (tsk_context =3D=3D ia64_ctx.next) {
-			if (++ia64_ctx.next >=3D ia64_ctx.limit) {
-				/* empty range: reset the range limit and start over */
-				if (ia64_ctx.next > max_ctx)
-					ia64_ctx.next =3D 300;
-				ia64_ctx.limit =3D max_ctx + 1;
-				goto repeat;
-			}
-		}
-		if ((tsk_context > ia64_ctx.next) && (tsk_context < ia64_ctx.limit))
-			ia64_ctx.limit =3D tsk_context;
+	next_ctx =3D find_next_bit(ia64_ctx.bitmap, ia64_ctx.limit, =
ia64_ctx.next);
+	if (next_ctx >=3D ia64_ctx.limit) {
+		next_ctx =3D ia64_ctx.limit;
 	}
-	read_unlock(&tasklist_lock);
+	ia64_ctx.limit =3D next_ctx;
+
 	/* can't call flush_tlb_all() here because of race condition with O(1) =
scheduler [EF] */
 	{
 		int cpu =3D get_cpu(); /* prevent preemption/migration */
--- linux-2.6.9_base/arch/ia64/kernel/setup.c	2005-09-02 =
14:56:49.000000000 -0400
+++ linux-2.6.9/arch/ia64/kernel/setup.c	2005-09-30 11:07:46.000000000 =
-0400
@@ -345,6 +345,7 @@
 #endif
=20
 	cpu_init();	/* initialize the bootstrap CPU */
+	mmu_context_init();	/* initialize context_id bitmap */
=20
 #ifdef CONFIG_ACPI_BOOT
 	acpi_boot_init();

------=_NextPart_000_0029_01C5DAFA.54FA0DC0
Content-Type: image/png;
	name="shared_ctx_bitmap_2meg.png"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="shared_ctx_bitmap_2meg.png"

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

------=_NextPart_000_0029_01C5DAFA.54FA0DC0
Content-Type: image/png;
	name="shared_ctx_bitmap_all.png"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="shared_ctx_bitmap_all.png"

iVBORw0KGgoAAAANSUhEUgAAAxgAAAJkCAMAAAClNHdYAAAAOVBMVEX///8AAAD/AAAA/wAAAP//
/wC8j4/c3NyUANMA////AP//pQByIbxnB0hA4NAAiwDAwMCBgYFCQkITWeDyAAAACXBIWXMAAAsT
AAALEwEAmpwYAAAAQHRFWHRUaXRsZQAvaG9tZS9wa2VpbHR5L2NvbnRleHRfaWQuZC9zaGFyZWRf
Yml0bWFwXzEyOGtfMm1lZ19jbG0uYWdysliU6AAAAA50RVh0QXV0aG9yAHBrZWlsdHnJNmX/AAAA
FXRFWHRTb2Z0d2FyZQBHcmFjZS01LjEuMTjb5nWBAAAADHRFWHREZXNjcmlwdGlvbgATCSEjAAAg
AElEQVR4Xu2d3bajIAyF66xenSv1/R92TAKIRC0KiOj+Zs2pjRppml1+VPx8AAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAhj40HGUYyIW46U94G0IDAPUZOrfYCcNAf8d5k57N9pU38VeO0w7DSKZhsSYKOlZoA6A+Xef9
yI/mHUlgNlPy0jsWDDOv60VBoyjCvByhhzDADekXdcNgs3RRK5AU+NXoYfRS2S5zjTHtf1gYHwgD
3JAxrBtkoRvnfJ2ynd9wV4JXetlvN+tZXhAGeAZ99/HrhlkY/WzmTofbhDbyGl9uMwgDPIhhmMVA
b50wqCqRxUk7S2H4LSnXKxFIGNPGoxmimqujYaR3tqNi1EPrR/QxwA2ZctWrG3xhOPO41M6yJcXd
9LmTQsNT42A01ZMQWA089CSCIM2MskdP72l/tzsA92CgDF10J5wwKJFpaaowlsJYtKTMGK6VyiA1
hP1LJvt3+PRTJ0X66Ga9kQeEAe4G52k/t4Z8YZgkH8dAGIuW1Mc0mEzjyfQx5GUpDNlWXlhJVmAQ
BrgbLk9tY8gXhjGbppDZgAyqf00tJcnyhTAYUyEYB7wlMwsMwgB3Y+oPEHMHeiEMrjK4seULI2hJ
CVRp0GsojMH2rY2DhcAgDHBTOtYFjcbaRPaFwVWGHUkye+iWlDCKi6UwBmpgQRigNbg2IFz3eykM
Gk01pyfm5F22pJx9RRgioUAY894QBrgprlHkhmaXwnBXTHnCCFpSg010LQyzvBDGYHszQ+9EAmGA
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
+JTsojgAAAAASUVORK5CYII=

------=_NextPart_000_0029_01C5DAFA.54FA0DC0--

------=_NextPart_000_002C_01C5DAFA.54FB9460--


