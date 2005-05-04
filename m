From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 04 May 2005 20:25:15 +0000
Subject: [patch] speed up lfetch.fault [NULL] (take 3)
Message-Id: <17017.12203.283489.395534@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 4 May 2005 13:15:25 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> David Mosberger wrote on Wednesday, May 04, 2005 7:50 AM
  >> This is a resend of the patch from March 26, with slight tweaking
  >> to omit the instruction needed to initialize p6.  Please apply to
  >> test-2.6.

  Ken> David, the pr register need to be restored in the fast path ;-)
  Ken> otherwise, p6 is clobbered.

Duh, makes you wonder how it worked so well (even with "prefetch"
defined to lfetch.fault I observed no errors).

Thanks for catching this -- the patch below is hopefully better.

	--david

--
[IA64] Speed up lfetch.fault [NULL]

This patch greatly speeds up the handling of lfetch.fault instructions
which result in NaT consumption. Due to the NaT-page mapped at address
0, this is guaranteed to happen when lfetch.fault'ing a NULL pointer.
With this patch in place, we can even define prefetch()/prefetchw() as
lfetch.fault without significant performance degradation.  More
importantly, it allows compilers to be more aggressive with using
lfetch.fault on pointers that might be NULL.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/kernel/ivt.S
=================================--- f52dd11fe8741b6589019c9fa6cff53491e9e853/arch/ia64/kernel/ivt.S  (mode:100644 sha1:d9c05d53435bd1d541538494336cffcc65df83c4)
+++ uncommitted/arch/ia64/kernel/ivt.S  (mode:100644)
@@ -1199,6 +1199,25 @@
 // 0x5600 Entry 26 (size 16 bundles) Nat Consumption (11,23,37,50)
 ENTRY(nat_consumption)
 	DBG_FAULT(26)
+
+	mov r16=cr.ipsr
+	mov r17=cr.isr
+	mov r31=pr				// save PR
+	;;
+	and r18=0xf,r17				// r18 = cr.ipsr.code{3:0}
+	tbit.z p6,p0=r17,IA64_ISR_NA_BIT
+	;;
+	cmp.ne.or p6,p0=IA64_ISR_CODE_LFETCH,r18
+	dep r16=-1,r16,IA64_PSR_ED_BIT,1
+(p6)	br.cond.spnt 1f		// branch if (cr.ispr.na = 0 || cr.ipsr.code{3:0} != LFETCH)
+	;;
+	mov cr.ipsr=r16		// set cr.ipsr.na
+	mov pr=r31,-1
+	;;
+	rfi
+
+1:	mov pr=r31,-1
+	;;
 	FAULT(26)
 END(nat_consumption)
 

