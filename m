From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:50:31 +0000
Subject: syscall improvement patch [4/12]
Message-Id: <200503240050.j2O0oV6s022280@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

ia64: On return from syscall, hint b7 with __kernel_syscall_via_epc().

Why is this a good idea?  Clearing b7 to 0 is guaranteed to do us no
good and writing it with __kernel_syscall_via_epc() yields a 6 cycle
improvement _if_ the application performs another EPC-based system-
call without overwriting b7, which is not all that uncommon.  Well
worth the minimal cost of 1 bundle of code.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-03-23 13:28:12 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-03-23 13:28:12 -08:00
@@ -692,7 +692,7 @@
 	;;
 (p6)	ld4 r31=3D[r18]				// load current_thread_info()->flags
 	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
-	mov b7=3Dr0		// clear b7
+	nop.i 0
 	;;
 	ld8 r23=3D[r3],PT(R11)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbag=
e)
 	ld8 r18=3D[r2],PT(R9)-PT(B6)		// load b6
@@ -754,7 +754,14 @@
 (pUStk)	ld4 r17=3D[r3]		// r17 =3D cpu_data->phys_stacked_size_p8
 	mov.m ar.csd=3Dr0		// M2 clear ar.csd
 	mov f10=F0		// clear f10
+
+	nop.m 0
+	movl r14=3D__kernel_syscall_via_epc	// X
 	;;
+	nop.m 0
+	nop.m 0
+	mov b7=3Dr14		// I0   clear b7 (hint with __kernel_syscall_via_epc)
+
 	mov r14=3Dr0		// clear r14
 	mov f11=F0		// clear f11
 (pKStk) br.cond.dpnt.many skip_rbs_switch
