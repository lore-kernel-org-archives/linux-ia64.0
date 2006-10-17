From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 17 Oct 2006 23:04:58 +0000
Subject: RE: [Patch] remove some rsm psr.dt in ivt.S
Message-Id: <1161126298.2592.67.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1161123027.2592.63.camel@linux-znh>
In-Reply-To: <1161123027.2592.63.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-10-18 at 08:30, Chen, Kenneth W wrote:
> Zou Nan hai wrote on Tuesday, October 17, 2006 3:10 PM
> > The rsm psr.dt in page_not_present, key_permission, iaccess_rights
> and
> > daccess_right are not necessary. 
> > Since there is no data access between those points to page_fault,
> and
> > page_fault will enable psr.dt at the beginning.
> > 
> > @@ -1221,10 +1219,8 @@ END(page_not_present)
> >  ENTRY(key_permission)
> >       DBG_FAULT(21)
> >       mov r16=cr.ifa
> > -     rsm psr.dt
> >       mov r31=pr
> >       ;;
> > -     srlz.d
> >       br.sptk.many page_fault
> >  END(key_permission)
> 
> 
> You can get rid of that stop bit too.  Same for two other instances.
> And your changelog mentioned daccess_right, but patch missed that
> hunk.
> 
> - Ken
> 
Ok, daccess_right hunk was in the patch...

--- linux-2.6.18/arch/ia64/kernel/ivt.S	2006-10-18 00:15:11.000000000 +0800
+++ linux-2.6.18-fix/arch/ia64/kernel/ivt.S	2006-10-18 01:30:14.000000000 +0800
@@ -1201,7 +1201,6 @@ END(dispatch_to_fault_handler)
 ENTRY(page_not_present)
 	DBG_FAULT(20)
 	mov r16=cr.ifa
-	rsm psr.dt
 	/*
 	 * The Linux page fault handler doesn't expect non-present pages to be in
 	 * the TLB.  Flush the existing entry now, so we meet that expectation.
@@ -1209,9 +1208,7 @@ ENTRY(page_not_present)
 	mov r17=PAGE_SHIFT<<2
 	;;
 	ptc.l r16,r17
-	;;
 	mov r31=pr
-	srlz.d
 	br.sptk.many page_fault
 END(page_not_present)
 
@@ -1221,10 +1218,7 @@ END(page_not_present)
 ENTRY(key_permission)
 	DBG_FAULT(21)
 	mov r16=cr.ifa
-	rsm psr.dt
 	mov r31=pr
-	;;
-	srlz.d
 	br.sptk.many page_fault
 END(key_permission)
 
@@ -1234,10 +1228,7 @@ END(key_permission)
 ENTRY(iaccess_rights)
 	DBG_FAULT(22)
 	mov r16=cr.ifa
-	rsm psr.dt
 	mov r31=pr
-	;;
-	srlz.d
 	br.sptk.many page_fault
 END(iaccess_rights)
 
@@ -1247,10 +1238,7 @@ END(iaccess_rights)
 ENTRY(daccess_rights)
 	DBG_FAULT(23)
 	mov r16=cr.ifa
-	rsm psr.dt
 	mov r31=pr
-	;;
-	srlz.d
 	br.sptk.many page_fault
 END(daccess_rights)
 

