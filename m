From: Steffen Persvold <sp@scali.com>
Date: Sat, 22 Jun 2002 09:53:40 +0000
Subject: [Linux-ia64] Compiler warnings.
Message-Id: <marc-linux-ia64-105590701905704@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi all,

For some time I've been compiling applications and kernels on IA64.=20
Sometimes the assembler gives me warnings about "RAW dependencies" which=20
makes me wonder about the quality of the gcc compiler. Is this something=20
that should be paid attention to ?

Here's a warning (and not the only one) I get when I compile the latest=20
2.4.18 patchset with gcc 2.96 (gcc version 2.96 20000731 (Debian GNU/Linux =

IA64 experimental)) :

gcc -D__KERNEL__ -I/usr/src/linux-2.4.18-020622/include=20
-Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer=20
-fno-strict-aliasing -fno-common -pipe  -ffixed-r13=20
-mfixed-range=F10-f15,f32-f127 -falign-functions2 -mconstant-gp =20
-DKBUILD_BASENAME=3Dvmscan  -c -o vmscan.o vmscan.c
{standard input}: Assembler messages:
{standard input}:594: Warning: Use of 'st8' violates RAW dependency 'DTC' (=
data)
{standard input}:594: Warning: Only the first path encountering the conflic=
t is reported
{standard input}:581: Warning: This is the location of the conflicting usage

I haven't tried the 3.0.1 compiler yet.

Thanks,
 --=20
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementati=
on:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS laten=
cy


