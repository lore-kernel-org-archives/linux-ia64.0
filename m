From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 21 Jan 2005 18:48:46 +0000
Subject: RE: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <200501211848.j0LImkg32357@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.2168.388519.26567@napali.hpl.hp.com>
In-Reply-To: <16878.2168.388519.26567@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger  wrote on Thursday, January 20, 2005 9:53 AM:
> Please disregard the patch named in $SUBJECT.  It appears to be
> breaking light-weight syscalls.  That's rather odd, but since Rohit
> has some better ideas on how to fix this issue, I'd rather drop this
> patch for the time being (the root problem is still there and IMHO,
> needs to be fixed urgently).
>

Seth, Rohit wrote on Thursday, January 20, 2005 11:01 AM
> I will send out the first rev of patch today to address the
> functionality issue.  This patch will not worry about exporting the NAT
> bits in r8-r11 to user.  So, the ld.fills will be replaced by simple ld.
>
> Though, as per the disussions with David, there is scope of further
> optimization in the way we are saving/restoring r8-r11 in this code.
> This will probably need little more analysis to ensure best
> placement/scheduling of new code. Will send that later...


Here is the first part of the patch that Rohit mentioned earlier.

--- 1.1/arch/ia64/kernel/entry.S	Mon Oct 18 14:53:44 2004
+++ edited/arch/ia64/kernel/entry.S	Thu Jan 20 15:21:50 2005
@@ -614,8 +614,8 @@
 	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
 	adds r3=3DPT(R10)+16,sp			// r3 =3D &pt_regs.r10
 	;;
-.mem.offset 0,0; (p6) st8.spill [r2]=3Dr8	// store return value in slot fo=
r r8 and set unat bit
-.mem.offset 8,0; (p6) st8.spill [r3]=3Dr0	// clear error indication in slo=
t for r10 and set unat bit
+.mem.offset 0,0; (p6) st8 [r2]=3Dr8		// store return value in slot for r8
+.mem.offset 8,0; (p6) st8 [r3]=3Dr0		// clear error indication in slot for=
 r10
 (p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
 END(ia64_ret_from_syscall)
 	// fall through
@@ -708,12 +708,12 @@
 (p6)	br.cond.spnt .work_pending
 	;;
 	// start restoring the state saved on the kernel stack (struct pt_regs):
-	ld8.fill r8=3D[r16],16
-	ld8.fill r9=3D[r17],16
+	ld8 r8=3D[r16],16
+	ld8 r9=3D[r17],16
 	mov f6=F0		// clear f6
 	;;
-	ld8.fill r10=3D[r16],16
-	ld8.fill r11=3D[r17],16
+	ld8 r10=3D[r16],16
+	ld8 r11=3D[r17],16
 	mov f7=F0		// clear f7
 	;;
 	ld8 r29=3D[r16],16	// load cr.ipsr

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Signed-off-by: Rohit Seth <rohit.seth@intel.com>


