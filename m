From: Pete Wyckoff <pw@osc.edu>
Date: Thu, 02 Nov 2000 19:37:34 +0000
Subject: [Linux-ia64] gdb null ptr
Message-Id: <marc-linux-ia64-105590678205646@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This is probably the wrong place to fix the bug, but it keeps gdb
from crashing on codes created using sgif90 (Version 0.01.0-11).

The type structure which causes the problem has null for both name and
tag_name.  I didn't look far enough to figure out why.  Code in question
is tag_type_to_type called from die_type.

Patch against snap-001024 with patches from README.glibc213 and
patch.02[7-9].

How was I using it?  Start the mpi code, attach it with gdb, wait for
the FPE to arrive, "Segmentation fault" without patch.  With patch,

    Program received signal SIGFPE, Arithmetic exception.
    0x400000000002c292 in output (ISTATE=CAnnot access memory at address 0x0
    ) at put.F:91
    91                    gf(i,ic) =3D gf(i,ic) +

istate is an (implicit) integer*4 parameter passed to subroutine output.

		-- Pete


--- src/gdb/dwarf2read.c.orig	Thu Nov  2 14:28:21 2000
+++ src/gdb/dwarf2read.c	Thu Nov  2 14:28:34 2000
@@ -4522,7 +4522,7 @@
 	    {
 	      const char *nameoftype;
 	      nameoftype =3D TYPE_NAME(dwarf2_cached_types[hashval]) =3D NULL ? T=
YPE_TAG_NAME(dwarf2_cached_types[hashval]) : TYPE_NAME(dwarf2_cached_types[=
hashval]);
-	      if (strcmp(attrname, nameoftype) =3D 0)
+	      if (nameoftype && strcmp(attrname, nameoftype) =3D 0)
 		{
 		  die->type=3Ddwarf2_cached_types[hashval];
 		}

