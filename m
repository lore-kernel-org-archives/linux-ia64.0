From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 29 Mar 2006 06:54:38 +0000
Subject: Prefetch mmap_sem in ia64_do_page_fault()
Message-Id: <Pine.LNX.4.64.0603282251410.20180@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Take a hint from an x86_64 optimization by Arjan van de Ven and use it
for ia64.

See http://www.kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;=
a=3Dcommit;h=A9ba9a3b3897561d01e04cd21433746df46548c0

Prefetch the mmap_sem, which is critical for the performance of the page fa=
ult
handler. Maybe we can offset the damage done by the kprobes notifier?

Note: mm may be NULL but I guess that is safe. See=20
http://www.kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;hE8f935527372499b714bf4f8e646a68bb0f52e3

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16/arch/ia64/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.16.orig/arch/ia64/mm/fault.c	2006-03-=
19 21:53:29.000000000 -0800
+++ linux-2.6.16/arch/ia64/mm/fault.c	2006-03-28 22:44:01.000000000 -0800
@@ -60,6 +60,9 @@ ia64_do_page_fault (unsigned long addres
 	struct siginfo si;
 	unsigned long mask;
=20
+	/* mmap_sem is performance critical.... */
+	prefetchw(&mm->mmap_sem);
+
 	/*
 	 * If we're in an interrupt or have no user context, we must not take the=
 fault..
 	 */
