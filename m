From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 18 Mar 2005 22:32:50 +0000
Subject: PATCH: 2.6: Fix END(memcpy)
Message-Id: <20050318223250.GA2992@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The new assembler doesn't like

	.proc memcpy
	.proc __copy_user
	.endp memcpy
	.endp __copy_user

This patch changes it to

	.proc memcpy
	.endp memcpy
	.proc __copy_user
	.endp __copy_user


H.J.
-----
--- linux-2.6.9/arch/ia64/lib/memcpy_mck.S.endp	2004-10-18 14:54:08.0000000=
00 -0700
+++ linux-2.6.9/arch/ia64/lib/memcpy_mck.S	2005-03-18 14:10:23.627318625 -0=
800
@@ -84,6 +84,7 @@ GLOBAL_ENTRY(memcpy)
 	mov	f6=F0
 	br.cond.sptk .common_code
 	;;
+END(memcpy)
 GLOBAL_ENTRY(__copy_user)
 	.prologue
 // check dest alignment
@@ -533,7 +534,6 @@ EK(.ex_handler,  (p17)	st8	[dst1]=3Dr39,8)
 #undef B
 #undef C
 #undef D
-END(memcpy)
=20
 /*
  * Due to lack of local tag support in gcc 2.x assembler, it is not clear =
which
