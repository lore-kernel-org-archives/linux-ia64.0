From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 29 Jun 2004 15:13:32 +0000
Subject: RE: Why large stack frame for PAL call
Message-Id: <200406291511.i5TFBkY12582@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
In-Reply-To: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Monday, June 28, 2004 10:50 PM
>
>   Ken> Does anyone know why we need such large stack frame for PAL
>   Ken> static call?  PAL isn't even suppose to touch any stack
>   Ken> register for static calling convention.  Is it for legacy
>   Ken> reason or something?
>
> Good question.  I was able to track the source down to a patch that
> was sent to me by Walt Drummond on Aug 11, 1999.  The authors listed
> in the relevant file (it was called palcall.S back then) were Don
> Dugger and Walt Drummond (in this order), so my guess is the code was
> originally written by Don.  At that time, the primary target for Don
> would have been SoftSDV.  Perhaps it was to work around a bug in
> SoftSDV, though I suspect it's just as likely that the code came about
> by a misunderstood/misdocumented PAL-requirement.
>
> Perhaps Don or Asit remember how this came about?
>
> I also cannot find a requirement that would demand allocating 96
> stacked registers before making a PAL call and I'd be in favor of
> cleaning that up.

Checked with Asit. Yes, this was more of a conservative code just like
what Don said.  Patch to clean it up.

--------
Clean up unnecessary large register stack frame for PAL static/stacked calls.

=== arch/ia64/kernel/pal.S 1.8 vs edited ==--- 1.8/arch/ia64/kernel/pal.S	Mon Jun 28 22:07:49 2004
+++ edited/arch/ia64/kernel/pal.S	Mon Jun 28 23:13:49 2004
@@ -55,7 +55,7 @@
  */
 GLOBAL_ENTRY(ia64_pal_call_static)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
-	alloc loc1 = ar.pfs,6,90,0,0
+	alloc loc1 = ar.pfs,5,5,0,0
 	movl loc2 = pal_entry_point
 1:	{
 	  mov r28 = in0
@@ -66,7 +66,9 @@
 	ld8 loc2 = [loc2]		// loc2 <- entry point
 	tbit.nz p6,p7 = in4, 0
 	adds r8 = 1f-1b,r8
+	mov loc4=ar.rsc			// save RSE configuration
 	;;
+	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
 	mov loc3 = psr
 	mov loc0 = rp
 	.body
@@ -82,6 +84,7 @@
 	mov rp = r8
 	br.cond.sptk.many b7
 1:	mov psr.l = loc3
+	mov ar.rsc = loc4		// restore RSE configuration
 	mov ar.pfs = loc1
 	mov rp = loc0
 	;;
@@ -98,7 +101,7 @@
  */
 GLOBAL_ENTRY(ia64_pal_call_stacked)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
-	alloc loc1 = ar.pfs,5,4,87,0
+	alloc loc1 = ar.pfs,4,4,4,0
 	movl loc2 = pal_entry_point

 	mov r28  = in0			// Index MUST be copied to r28
@@ -145,7 +148,7 @@

 GLOBAL_ENTRY(ia64_pal_call_phys_static)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
-	alloc loc1 = ar.pfs,6,90,0,0
+	alloc loc1 = ar.pfs,4,7,0,0
 	movl loc2 = pal_entry_point
 1:	{
 	  mov r28  = in0		// copy procedure index



