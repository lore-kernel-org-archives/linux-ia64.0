From: Greg KH <gregkh@suse.de>
Date: Tue, 05 Apr 2005 16:46:48 +0000
Subject: [03/08] fix ia64 syscall auditing
Message-Id: <20050405164647.GD17299@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405164539.GA17299@kroah.com>
In-Reply-To: <20050405164539.GA17299@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kernel@vger.kernel.org, stable@kernel.org
Cc: amy.griffis@hp.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dwmw2@infradead.org

-stable review patch.  If anyone has any objections, please let us know.

------------------

Attached is a patch against David's audit.17 kernel that adds checks
for the TIF_SYSCALL_AUDIT thread flag to the ia64 system call and
signal handling code paths.  The patch enables auditing of system
calls set up via fsys_bubble_down, as well as ensuring that
audit_syscall_exit() is called on return from sigreturn.

Neglecting to check for TIF_SYSCALL_AUDIT at these points results in
incorrect information in audit_context, causing frequent system panics
when system call auditing is enabled on an ia64 system.

I have tested this patch and have seen no problems with it.

[Original patch from Amy Griffis ported to current kernel by David Woodhous=
e]

From: Amy Griffis <amy.griffis@hp.com>
From: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Chris Wright <chrisw@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

--- 1.34/arch/ia64/kernel/fsys.S	2005-01-22 22:19:11 +00:00
+++ edited/arch/ia64/kernel/fsys.S	2005-04-01 00:20:32 +01:00
@@ -611,8 +611,10 @@
 	movl r2=3Dia64_ret_from_syscall
 	;;
 	mov rp=3Dr2				// set the real return addr
-	tbit.z p8,p0=3Dr3,TIF_SYSCALL_TRACE
+	and r3=3D_TIF_SYSCALL_TRACEAUDIT,r3
 	;;
+	cmp.eq p8,p0=3Dr3,r0
+
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// p10=3Dtrue means out regi=
sters are more than 8
 (p8)	br.call.sptk.many b6=B6		// ignore this return addr
 	br.cond.sptk ia64_trace_syscall
=3D=3D=3D arch/ia64/kernel/signal.c 1.49 vs edited =3D=3D--- 1.49/arch/ia64=
/kernel/signal.c	2005-01-25 20:23:45 +00:00
+++ edited/arch/ia64/kernel/signal.c	2005-04-01 00:18:29 +01:00
@@ -224,7 +224,8 @@
 	 * could be corrupted.
 	 */
 	retval =3D (long) &ia64_leave_kernel;
-	if (test_thread_flag(TIF_SYSCALL_TRACE))
+	if (test_thread_flag(TIF_SYSCALL_TRACE)=20
+	    || test_thread_flag(TIF_SYSCALL_AUDIT))
 		/*
 		 * strace expects to be notified after sigreturn returns even though the
 		 * context to which we return may not be in the middle of a syscall.
