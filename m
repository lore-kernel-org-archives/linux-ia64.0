From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Mar 2005 00:15:57 +0000
Subject: [patch] fix typos caught by new assembler
Message-Id: <200503250015.j2P0FvBS026786@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

[Resend with cc to linux-ia64...]

Patch below fixes 3 trivial typos which are caught by the new
assembler (v2.169.90).  Please apply.

Thanks,

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=3D=3D=3D arch/ia64/kernel/entry.S 1.89 vs edited =3D=3D--- 1.89/arch/ia64/=
kernel/entry.S	2005-03-24 14:08:31 -08:00
+++ edited/arch/ia64/kernel/entry.S	2005-03-24 15:59:33 -08:00
@@ -777,7 +777,7 @@
 	st8.spill [r2]=3Dr8	// store return value in slot for r8 and set unat bit
 	.mem.offset 8,0
 	st8.spill [r3]=3Dr0	// clear error indication in slot for r10 and set una=
t bit
-END(ia64_ret_from_ia32_execve_syscall)
+END(ia64_ret_from_ia32_execve)
 	// fall through
 #endif /* CONFIG_IA32_SUPPORT */
 GLOBAL_ENTRY(ia64_leave_kernel)
=3D=3D=3D arch/ia64/lib/memcpy_mck.S 1.7 vs edited =3D=3D--- 1.7/arch/ia64/=
lib/memcpy_mck.S	2005-03-18 16:07:39 -08:00
+++ edited/arch/ia64/lib/memcpy_mck.S	2005-03-24 14:39:37 -08:00
@@ -75,6 +75,7 @@
 	mov	f6=F0
 	br.cond.sptk .common_code
 	;;
+END(memcpy)
 GLOBAL_ENTRY(__copy_user)
 	.prologue
 // check dest alignment
@@ -524,7 +525,6 @@
 #undef B
 #undef C
 #undef D
-END(memcpy)
=20
 /*
  * Due to lack of local tag support in gcc 2.x assembler, it is not clear =
which
=3D=3D=3D arch/ia64/lib/memset.S 1.7 vs edited =3D=3D--- 1.7/arch/ia64/lib/=
memset.S	2004-01-15 17:51:26 -08:00
+++ edited/arch/ia64/lib/memset.S	2005-03-24 14:40:09 -08:00
@@ -57,10 +57,10 @@
 { .mmi
 	.prologue
 	alloc	tmp =3D ar.pfs, 3, 0, 0, 0
-	.body
 	lfetch.nt1 [dest]			//
 	.save   ar.lc, save_lc
 	mov.i	save_lc =3D ar.lc
+	.body
 } { .mmi
 	mov	ret0 =3D dest			// return value
 	cmp.ne	p_nz, p_zr =3D value, r0		// use stf.spill if value is zero
=20
