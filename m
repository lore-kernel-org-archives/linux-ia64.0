From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 04 May 2005 14:49:54 +0000
Subject: [patch] speed up lfetch.fault [NULL] (take 2)
Message-Id: <17016.57618.59637.485411@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a resend of the patch from March 26, with slight tweaking to
omit the instruction needed to initialize p6.  Please apply to
test-2.6.

Thanks,

	--david

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
@@ -1199,6 +1199,24 @@
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
+	;;
+	rfi
+
+1:	mov pr=r31,-1
+	;;
 	FAULT(26)
 END(nat_consumption)
 
