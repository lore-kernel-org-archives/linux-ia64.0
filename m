From: Martin Hicks <mort@wildopensource.com>
Date: Fri, 23 May 2003 17:52:46 +0000
Subject: [Linux-ia64] [PATCH] 2.5 - Change mmu_gathers into per-cpu data
MIME-Version: 1
Content-Type: multipart/mixed; boundary="76DTJ5CE0DCVQemd"
Message-Id: <marc-linux-ia64-105590723706004@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--76DTJ5CE0DCVQemd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hello,

Here is a patch to move the mmu_gathers struct into the per-cpu data
region.

The patch is against the linux-ia64-2.5 tree.

--=20
Wild Open Source Inc.                  mort@wildopensource.com


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1100  -> 1.1101=20
#	include/asm-ia64/tlb.h	1.13    -> 1.14  =20
#	 arch/ia64/mm/init.c	1.36    -> 1.37  =20
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/22	mort@green.i.bork.org	1.1101
# per-cpu-mmu_gathers.diff
# --------------------------------------------
#
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Fri May 23 13:48:36 2003
+++ b/arch/ia64/mm/init.c	Fri May 23 13:48:36 2003
@@ -29,7 +29,7 @@
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
=20
-struct mmu_gather mmu_gathers[NR_CPUS];
+DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
 /* References to section boundaries: */
 extern char _stext, _etext, _edata, __init_begin, __init_end;
diff -Nru a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
--- a/include/asm-ia64/tlb.h	Fri May 23 13:48:36 2003
+++ b/include/asm-ia64/tlb.h	Fri May 23 13:48:36 2003
@@ -63,7 +63,7 @@
 };
=20
 /* Users of the generic TLB shootdown code must declare this storage space=
=2E */
-extern struct mmu_gather	mmu_gathers[NR_CPUS];
+DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
 /*
  * Flush the TLB for address range START to END and, if not in fast mode, =
release the
@@ -125,7 +125,7 @@
 static inline struct mmu_gather *
 tlb_gather_mmu (struct mm_struct *mm, unsigned int full_mm_flush)
 {
-	struct mmu_gather *tlb =3D &mmu_gathers[smp_processor_id()];
+	struct mmu_gather *tlb =3D &per_cpu(mmu_gathers, smp_processor_id());
=20
 	tlb->mm =3D mm;
 	/*

--76DTJ5CE0DCVQemd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE+zl/u0ZUZrUx/K+4RAu3UAKCpyNHxlqtuUB1l3IArqMtKjP7EWACgspzT
XI+od8T4m0z1aUKIT8CMHnA=
=7V5y
-----END PGP SIGNATURE-----

--76DTJ5CE0DCVQemd--

