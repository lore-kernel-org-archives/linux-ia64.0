From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 00:05:14 +0000
Subject: GENERIC still failing?
Message-Id: <marc-linux-ia64-106617635106445@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

According to this page:

	http://www.gelato.unsw.edu.au/kerncomp/

GENERIC builds are still failing:

  gcc -Wp,-MD,fs/ext2/.balloc.o.d -nostdinc -iwithprefix include -D__KERNEL=
__ -Iinclude   -D__KERNEL__ -Iinclude   -Wall -Wstrict-prototypes -Wno-trig=
raphs -O2 -fno-strict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-range=
=F12-f15,f32-f127 -falign-functions2 -frename-registers -fomit-frame-pointe=
r    -mconstant-gp -DKBUILD_BASENAME=BAlloc -DKBUILD_MODNAME=3Dext2 -c -o f=
s/ext2/balloc.o fs/ext2/balloc.c
arch/ia64/sn/kernel/setup.c:94: error: `MAX_PHYSNODE_ID' undeclared here (n=
ot in a function)
arch/ia64/sn/kernel/setup.c:94: error: conflicting types for `physical_node=
_map'
include/asm/sn/sn_cpuid.h:126: error: previous declaration of `physical_nod=
e_map'

Anybody care to send me a fix for this?

	--david
