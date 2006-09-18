From: Russ Anderson <rja@sgi.com>
Date: Mon, 18 Sep 2006 23:37:15 +0000
Subject: Re: [patch] ar.fpsr not set on MCA/INIT kernel entry
Message-Id: <200609182337.k8INbGsw5984977@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609182118.k8ILISN85963198@clink.americas.sgi.com>
In-Reply-To: <200609182118.k8ILISN85963198@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> Russ Anderson (on Mon, 18 Sep 2006 16:18:28 -0500 (CDT)) wrote:
> >[patch] ar.fpsr not set on MCA/INIT kernel entry
> >Index: test/arch/ia64/kernel/mca_asm.S
> >=================================> >--- test.orig/arch/ia64/kernel/mca_asm.S	2006-09-18 16:10:06.058062990 -0500
> >+++ test/arch/ia64/kernel/mca_asm.S	2006-09-18 16:10:29.628971888 -0500
> >@@ -1063,7 +1063,9 @@ ia64_set_kernel_registers:
> > 	;;
> > 	mov IA64_KR(CURRENT_STACK)=r16
> > 	or r21=r20,r21				// construct PA | page properties
> >+	movl r17=FPSR_DEFAULT
> > 	;;
> >+	mov.m ar.fpsr=r17			// set ar.fpsr to kernel default value
> > 	mov cr.itir=r18
> > 	mov cr.ifa=r13
> > 	mov r20=IA64_TR_CURRENT_STACK
> 
> Any particular reason to place those instructions in the middle of the
> code that wires IA64_TR_CURRENT_STACK?  I tried to keep the tr code as
> standard as possible, to make it easier to change in future.  This code
> is not performance sensitive, readability counts more than a couple of
> unused slots here.

Those lines can be shifted up or down.   
Does this look better?

---
 arch/ia64/kernel/mca_asm.S |    4 ++++
 1 file changed, 4 insertions(+)

Index: test/arch/ia64/kernel/mca_asm.S
=================================--- test.orig/arch/ia64/kernel/mca_asm.S	2006-09-18 16:10:06.058062990 -0500
+++ test/arch/ia64/kernel/mca_asm.S	2006-09-18 18:35:41.232092232 -0500
@@ -1067,6 +1067,10 @@ ia64_set_kernel_registers:
 	mov cr.itir=r18
 	mov cr.ifa=r13
 	mov r20=IA64_TR_CURRENT_STACK
+
+	movl r17=FPSR_DEFAULT
+	;;
+	mov.m ar.fpsr=r17			// set ar.fpsr to kernel default value
 	;;
 	itr.d dtr[r20]=r21
 	;;
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
