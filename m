From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Wed, 05 Jun 2002 15:28:54 +0000
Subject: [Linux-ia64] Back to the future: which gcc for kernel 2.4.18 ?
Message-Id: <marc-linux-ia64-105590701905641@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Building kernel 2.4.18 for ia64 with gcc version 2.96 20000731 , it
seems that there is some problem with code generation in the=20
ia64_log_rec_header_print() routine that prints MCA informations:
year appears to be 18002 :-)

Looking at the code with gdb, it seems that the generated code uses
the f6 register without ininitializing:
...
0xe0000000044351f1 <ia64_log_rec_header_print+337>:	xmpy.l f6=3Df6,f7
...

+BEGIN HARDWARE ERROR STATE AT MCA
SAL RECORD HEADER:  Record buffer =3D e000000000007000,  header size =3D 40
e000000000007000 00 00 00 00 98 70 c5 04 02 00 01 00 28 07 00 00=20
e000000000007010 48 04 14 00 05 06 02 20 50 6c 61 74 66 6f 72 6d=20
e000000000007020 20 69 64 2d 20 4f 45 4d=20
Total record length =3D 1832
End of SAL RECORD HEADER
+Err Record ID: 0    SAL Rev:  0.02
+Time: 06/05/18002/ 14:04:48    Severity 1
             XXXXX

I tried using gcc3 (gcc version 3.0.2 20010905), but I get an internal=20
compiler error when I build the kernel.

smpboot.o smpboot.c
smpboot.c: In function `smp_callin':
smpboot.c:370: Internal compiler error in itanium_reorder, at config/ia64/i=
a64.c:5652
Please submit a full bug report,
with preprocessed source if appropriate.


--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

