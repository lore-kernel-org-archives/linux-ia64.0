From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Mar 2005 23:35:22 +0000
Subject: [patch] lfetch.fault [NULL] speedup
Message-Id: <16964.41018.199600.952301@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that we have a kernel that boots with prefetch()/prefetchw()
expanding into lfetch.fault, I figured I might just as well run
LMbench3 on it.  Turns out many latency benchmarks did substantially
worse because of the high frequency of prefetching NULL pointers.

It may actually make sense to care about this case: if we could speed
up "lfetch.fault [NULL]", then a compiler could be more aggressive and
use lfetch.fault whenever it knows that a pointer is either valid _or_
NULL.  The attached patch does that by checking for lfetch.fault
directly in the nat_consumption handler (remember, page 0 is normally
mapped as a NaT page).  This saves the substantial overhead of
switching into full kernel mode and as a result, LMbench3 now shows
virtually no degradation.

To be clear: I'm _not_ recommending to change prefetch() and
prefetchw() to use lfetch.fault.  Given the blind prefetching that the
Linux kernel sometimes does, that's probably just not a good idea.

I'd like to recommend to put the patch below in the "test" repo for
now and then feed it into 2.6.13 when it comes around.

Thanks,

	--david

--
ia64: Speed up lfetch.fault [NULL]

This patch greatly speeds up the handling of lfetch.fault instructions
which result in NaT consumption (as always happens when
lfetch.fault'ing a NULL pointer).  With this patch in place, we can
even define prefetch()/prefetchw() as lfetch.fault without significant
performance degradation.  More importantly, it allows compilers to be
more aggressive with using lfetch.fault on pointers that might be
NULL.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/ivt.S 1.34 vs edited ==--- 1.34/arch/ia64/kernel/ivt.S	2005-03-24 14:06:40 -08:00
+++ edited/arch/ia64/kernel/ivt.S	2005-03-25 15:13:07 -08:00
@@ -1235,6 +1235,25 @@
 // 0x5600 Entry 26 (size 16 bundles) Nat Consumption (11,23,37,50)
 ENTRY(nat_consumption)
 	DBG_FAULT(26)
+
+	mov r16=cr.ipsr
+	mov r17=cr.isr
+	mov r31=pr				// save PR
+	cmp.ne p6=r0,r0				// p6 = FALSE
+	;;
+	and r18=0xf,r17				// r18 = cr.ipsr.code{3:0}
+	tbit.z.or p6,p0=r17,IA64_ISR_NA_BIT
+	;;
+	cmp.ne.or p6,p0=IA64_ISR_CODE_LFETCH,r18
+	dep r16=-1,r16,IA64_PSR_ED_BIT,1
+(p6)	br.cond.spnt 1f		// branch if (cr.ispr.na = 0 || cr.ipsr.code{3:0} != LFETCH)
+	;;
+	mov cr.ipsr=r16		// set cr.ipsr.na
+	;;
+	rfi
+
+1:	mov pr=r31
+	;;
 	FAULT(26)
 END(nat_consumption)
 
