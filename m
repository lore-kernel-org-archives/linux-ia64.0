From: "Sistla, Krishnakanth V" <krishnakanth.v.sistla@intel.com>
Date: Tue, 08 May 2001 02:00:03 +0000
Subject: [Linux-ia64] Linker error : linking constant-gp files with non-constant gp fil
Message-Id: <marc-linux-ia64-105590693005546@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi all,

	I am trying to write a miscellanious driver and compile it into the
linux
	kernel. When i try to link two object files created by the below
mentioned=20
	commands (during a build) i get the following error. could some help
me=20
      please ?

Thanx in advance
KK



---------------------------------------------
kernel version=20

linux-2.4.0test10-001115

--------------------------command sequence--

gcc -D__KERNEL__ -I/usr/src/linux/include -Wall -Wstrict-prototypes -O2
-fno-strict-aliasing=20
-fomit-frame-pointer -pipe -Wa,-x -ffixed-r13 -mfixed-range=F10-f15,f32-f127
-funwind-tables=20
-mconstant-gp   -c -o ia64pmon.o test.c

gcc  -D__KERNEL__ -I/usr/src/linux/include  -c -o ia64pmon_s.o test_s.S


ld  -r -o misc.o test.o test_s.o


ld: test_s.o: linking constant-gp files with non-constant-gp files
Bad value: failed to merge target specific data of the file test_s.o

----------------------------------------------------------------------------
------------------


