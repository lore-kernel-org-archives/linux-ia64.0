From: Andreas Schwab <schwab@suse.de>
Date: Tue, 03 Sep 2002 19:00:41 +0000
Subject: Re: [Linux-ia64] latest glibc snapshot does not build on ia64?
Message-Id: <marc-linux-ia64-105590701906012@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906009@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906009@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Randolph Chung <randolph@tausq.org> writes:

|> In reference to a message from Wichmann, Mats D, dated Sep 03:
|> >=20
|> > > Haven't dug into this too much yet; wanted to see if anyone else has
|> > > seen this?
|> >=20
|> > Yup.
|> >=20
|> > There's a short glibc patch which takes care of this (should be on the
|> > Debian lists, else I can mail it to you once I get my machine back up).
|> > It's an "unofficial"  patch because it's felt the problem really lies =

|> > with binutils and not glibc, so it's not in glibc cvs.   The change
|> > is to dl-machine.h if it helps search...
|>=20
|> there was a IA64_RELOC_NONE patch, but in a different area of glibc...
|> looks like we just hit it again at a different spot now...

It's actually the same spot, but the context has changed a bit.  Here is
an updated patch:

Index: dl-machine.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3DRCS file: /cvs/glibc/libc/sysdeps/ia64/dl-machine.h=
,v
retrieving revision 1.20
diff -u -p -a -u -p -a -r1.20 dl-machine.h
--- dl-machine.h	6 Apr 2002 00:33:23 -0000	1.20
+++ dl-machine.h	3 Sep 2002 18:58:59 -0000
@@ -546,12 +546,11 @@ elf_machine_rela (struct link_map *map,
 # endif
         value +=3D map->l_addr;
     }
-# ifndef RTLD_BOOTSTRAP
-  else if (r_type =3D R_IA64_NONE)
-    return;
-# endif
   else
 #endif
+  if (r_type =3D R_IA64_NONE)
+    return;
+  else
     {
       struct link_map *sym_map;
=20

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

