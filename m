From: Volker Birk <vb@ebios.de>
Date: Fri, 14 Feb 2003 09:02:57 +0000
Subject: [Linux-ia64] strange performance behaviour with floats
MIME-Version: 1
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Message-Id: <marc-linux-ia64-105590709805852@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I'm wondering about the strange behaviour of the Linux scheduling on my
rx5670:

---------------------------- snip --------------------------------------
bronto:~ # cat dingens.c
#include <stdio.h>

int main()
{      =20
        int i;
        double x, y;

        x =3D rand(); y =3D rand();

        printf("x =3D %.2g, y =3D %.2g\n", x, y);

        for (i=3D0;i<1000000000;i++) {
                x *=3D y;
//              y /=3D x;
        }
}

bronto:~ # gcc -O2 -o dingens dingens.c
bronto:~ # time ./dingens
x =3D 1.8e+09, y =3D 8.5e+08

real    0m1.486s
user    0m1.485s
sys     0m0.001s
bronto:~ # time ./dingens
x =3D 1.8e+09, y =3D 8.5e+08

real    0m4.450s
user    0m4.450s
sys     0m0.000s
bronto:~ #=20
---------------------------- snap --------------------------------------

There is really no I/O while that time (so it may not be a problem with
the scheduling on the CPU which handles the interrupts).

No load at all, time and dingens are the only processes which do not
sleep.

Sometimes that computing consumes 1.5 sec. CPU time, sometimes 4.5 sec.
I cannot find a rule for that, nor can I predict when it will last how
long.

Some machine info:

---------------------------- snip --------------------------------------
bronto:~ # uname -a
Linux bronto 2.4.19 #11 SMP Sat Nov 2 18:47:02 CET 2002 ia64   GNU/Linux
bronto:~ # head -n 13 /proc/cpuinfo=20
processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 0
revision   : 7
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 900.000000
itc MHz    : 900.000000
BogoMIPS   : 1346.37
bronto:~ # grep ^processor /proc/cpuinfo
processor  : 0
processor  : 1
processor  : 2
processor  : 3
bronto:~ #=20
---------------------------- snap --------------------------------------

Does anybody know what's up with that machine?

Volker Birk
--=20
*** ebios Informationssysteme, Germany      ***
*** Gut-Betha-Platz 1, 88339 Bad Waldsee    ***
*** Phone +49-7524-93421 Fax +49-7524-93423 ***
*** mailto:vb@ebios.de                      ***

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQE+TLDBq2Wx34LtkcYRAr1nAJ0aKLGkKjCKjY8hOA3au87S5oZswwCgnxei
eVmxO0dm4mC1ZmaYjutln9I=
=t8lR
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--

