From: Steffen Persvold <sp@scali.com>
Date: Sat, 22 Jun 2002 09:58:26 +0000
Subject: Re: [Linux-ia64] Compiler warnings.
Message-Id: <marc-linux-ia64-105590701905705@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905704@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905704@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, 22 Jun 2002, Steffen Persvold wrote:

>=20
> Hi all,
>=20
> For some time I've been compiling applications and kernels on IA64.=20
> Sometimes the assembler gives me warnings about "RAW dependencies" which =

> makes me wonder about the quality of the gcc compiler. Is this something =

> that should be paid attention to ?
>=20
> Here's a warning (and not the only one) I get when I compile the latest=20
> 2.4.18 patchset with gcc 2.96 (gcc version 2.96 20000731 (Debian GNU/Linu=
x=20
> IA64 experimental)) :
>=20
> gcc -D__KERNEL__ -I/usr/src/linux-2.4.18-020622/include=20
> -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer=20
> -fno-strict-aliasing -fno-common -pipe  -ffixed-r13=20
> -mfixed-range=F10-f15,f32-f127 -falign-functions2 -mconstant-gp =20
> -DKBUILD_BASENAME=3Dvmscan  -c -o vmscan.o vmscan.c
> {standard input}: Assembler messages:
> {standard input}:594: Warning: Use of 'st8' violates RAW dependency 'DTC'=
 (data)
> {standard input}:594: Warning: Only the first path encountering the confl=
ict is reported
> {standard input}:581: Warning: This is the location of the conflicting us=
age
>=20
> I haven't tried the 3.0.1 compiler yet.
>=20

I forgot, I've also been seeing "WAW dependencies" :

gcc -D__KERNEL__ -I/usr/src/linux-2.4.18-020622/include -Wall=20
-Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer=20
-fno-strict-aliasing -fno-common -pipe  -ffixed-r13=20
-mfixed-range=F10-f15,f32-f127 -falign-functions2 -DMODULE -DMODVERSIONS=20
-include /usr/src/linux-2.4.18-020622/include/linux/modversions.h -DDBG=3D0=
=20
-DT3_JUMBO_RCV_RCB_ENTRY_COUNT%6 -DNICE_SUPPORT=20
-DPCIX_TARGET_WORKAROUND=3D1 -DINCLUDE_TBI_SUPPORT -DINCLUDE_5701_AX_FIX=3D=
1=20
-DKBUILD_BASENAME=B57um  -c -o b57um.o b57um.c
{standard input}: Assembler messages:
{standard input}:13085: Warning: Use of 'cmp.ne' violates WAW dependency 'P=
R%, % in 1 - 15' (impliedf), specific resource number is 7
{standard input}:13085: Warning: Only the first path encountering the confl=
ict is reported
{standard input}:13081: Warning: This is the location of the conflicting us=
age

Regards,
 --=20
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementati=
on:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS laten=
cy


