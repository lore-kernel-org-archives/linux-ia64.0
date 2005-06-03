From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 03 Jun 2005 19:26:47 +0000
Subject: RE: Initialization of cr.dcr
Message-Id: <200506031926.j53JQkg31275@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A01CA2.8010209@hob.de>
In-Reply-To: <42A01CA2.8010209@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Friday, June 03, 2005 12:11 PM
> >>> On Fri, 3 Jun 2005 13:27:54 -0500 (CDT), Russ Anderson <rja@sgi.com> said:
> 
> Russ> Ken Chen wrote:
> >>  Christian Hildner wrote on Friday, June 03, 2005 2:02 AM >
> >> playing around with speculation I found that on initialization
> >> dcr.dm is > not set, while the comment says "Initialize default
> >> control register to > defer all speculative faults". To be
> >> conform to the comment (and also to > the expected behavior) the
> >> value IA64_DCR_DM should be added in > arch/ia64/kernel/setup.c.
> 
> >> It should be the other way around: update the comments to reflect
> >> what the code does.  Turning off dcr.dm is a big win for
> >> speculative load where you do want the tlb miss to be serviced up
> >> front.
> 
> That's correct.  We changed this a long time ago and apparently forgot
> to update the comment.

Patch to update the comments to reflect the actual code in cpu_init().

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Acked-by: David Mosberger-Tang <davidm@hpl.hp.com>

--- linux-2.6.11/arch/ia64/kernel/setup.c.orig	2005-06-03 12:21:00.891940166 -0700
+++ linux-2.6.11/arch/ia64/kernel/setup.c	2005-06-03 12:22:36.036470251 -0700
@@ -720,7 +720,7 @@ cpu_init (void)
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(ia64_imva(empty_zero_page)));
 
 	/*
-	 * Initialize default control register to defer all speculative faults.  The
+	 * Initialize default control register not to defer speculative faults.  The
 	 * kernel MUST NOT depend on a particular setting of these bits (in other words,
 	 * the kernel must have recovery code for all speculative accesses).  Turn on
 	 * dcr.lc as per recommendation by the architecture team.  Most IA-32 apps


