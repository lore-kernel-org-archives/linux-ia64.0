From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 14 May 2003 03:38:23 +0000
Subject: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705774@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

When I try a parallel make, make seems to get it's dependencies out of
order. =20

For example, here's a make oldconfig ; make -j4 output on a fresh 2.5.69

ianw@tartufi:/usr/src/ianw/linux-2.5.69$ make -j4
make -f scripts/Makefile.build obj=3Dscripts
  gcc -Wp,-MD,scripts/.empty.o.d -D__KERNEL__ -Iinclude -Wall -Wstrict-prot=
otypes -Wno-trigraphs -g -O2 -fno-strict-aliasing -fno-common -pipe  -ffixe=
d-r13 -mfixed-range=F10-f15,f32-f127 -falign-functions2 -fomit-frame-pointe=
r -nostdinc -iwithprefix include -mconstant-gp   -DKBUILD_BASENAME=3Dempty
-DKBUILD_MODNAME=3Dempty -c -o scripts/empty.o scripts/empty.c
  scripts/mk_elfconfig ia64 < scripts/empty.o > scripts/elfconfig.h
  gcc -Wp,-MD,scripts/.file2alias.o.d -Wall -Wstrict-prototypes -O2 -fomit-=
frame-pointer   -c -o scripts/file2alias.o scripts/file2alias.c
  gcc -Wp,-MD,scripts/.modpost.o.d -Wall -Wstrict-prototypes -O2 -fomit-fra=
me-pointer   -c -o scripts/modpost.o scripts/modpost.c
  gcc  -o scripts/modpost scripts/modpost.o scripts/file2alias.o
  SPLIT   include/linux/autoconf.h -> include/config/*
  gcc -E -Wp,-MD,arch/ia64/.vmlinux.lds.s.d -D__ASSEMBLY__ -D__KERNEL__ -Ii=
nclude -mconstant-gp -nostdinc -iwithprefix include   -P -C -Uia64   -o arc=
h/ia64/vmlinux.lds.s arch/ia64/vmlinux.lds.S
In file included from arch/ia64/vmlinux.lds.S:4:
include/asm/ptrace.h:56:25: asm/offsets.h: No such file or directory
make: *** [arch/ia64/vmlinux.lds.s] Error 1
make: *** Waiting for unfinished jobs....
make: *** Waiting for unfinished jobs....

At first I thought it might be because the all target depends on
vmlinux, but this isn't it.  Currently I'm stumped.  'Single' make works
fine, and if you run parallel make a few times eventually offsets.h
gets generated and the build continues on fine.

Is it just me?

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au


