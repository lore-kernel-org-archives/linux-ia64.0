From: Horms <horms@verge.net.au>
Date: Fri, 06 Oct 2006 04:11:17 +0000
Subject: [patch] Obtain PAGE_OFFSET from running kernel
Message-Id: <20061006042056.472194000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Currently the page offset is hard coded to 0xe000000000000000UL
at compile time of kexec-tools. This patch changes things around
so the page offset is handed to purgatory by the kexecing kernel.

Note that this changes the ABI between purgatory (part of kexec-tools)
and the kernel kexec code. There is an accomanying kexec-tools patch.

Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: kexec-ia64-2.6/arch/ia64/kernel/relocate_kernel.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- kexec-ia64-2.6.orig/arch/ia64/kernel/relocate_k=
ernel.S	2006-10-05 11:56:24.000000000 +0900
+++ kexec-ia64-2.6/arch/ia64/kernel/relocate_kernel.S	2006-10-05 11:57:24.0=
00000000 +0900
@@ -22,7 +22,7 @@
 */
 GLOBAL_ENTRY(relocate_new_kernel)
 	.prologue
-	alloc r31=3Dar.pfs,4,0,0,0
+	alloc r31=3Dar.pfs,4,0,1,0
 	.body
 .reloc_entry:
 {
@@ -180,6 +180,7 @@
 	;;
 	srlz.d
 	;;
+	movl out0=3DPAGE_OFFSET;;
 	br.call.sptk.many b0=B6;;
=20
 .align 32

--

--=20
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

