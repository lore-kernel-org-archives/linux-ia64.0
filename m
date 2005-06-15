From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Jun 2005 17:35:44 +0000
Subject: Re: updated libunwind patch for v2.6 kernel
Message-Id: <17072.26352.66968.954556@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506100531.j5A5VYSB001927@napali.hpl.hp.com>
In-Reply-To: <200506100531.j5A5VYSB001927@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bob,

>>>>> On Wed, 15 Jun 2005 12:55:50 -0400, Bob Picco <bob.picco@hp.com> said:

  Bob> ia64-linux-gcc -Wp,-MD,arch/ia64/unwind/.init_local.o.d  -nostdinc -=
isystem /usr/local/lib/gcc-lib/ia64-linux/3.3/include -D__KERNEL__ -Iinclud=
e  -DHAVE_BUGGY_SEGREL -DHAVE_ATOMIC_H  -Wall -Wstrict-prototypes -Wno-trig=
raphs -fno-strict-aliasing -fno-common -ffreestanding -O2     -fomit-frame-=
pointer -g -pipe  -ffixed-r13 -mfixed-range=F12-f15,f32-f127 -falign-functi=
ons2 -frename-registers -fno-optimize-sibling-calls     -mconstant-gp -DKBU=
ILD_BASENAME=3Dinit_local -DKBUILD_MODNAME=3Dinit_local -c -o arch/ia64/unw=
ind/init_local.o arch/ia64/unwind/init_local.c
  Bob> In file included from arch/ia64/unwind/init.h:26,
  Bob> from arch/ia64/unwind/init_local.c:26:
  Bob> arch/ia64/unwind/unwind_i.h:33:25: libunwind_i.h: No such file or di=
rectory

Looks like the compiler command is missing the -Iinclude/linux, which
should get added via CPPFLAGS in arch/ia64/unwind/Makefile:

CPPFLAGS        +=3D -DHAVE_ATOMIC_H $(call addtree,-Iinclude/linux)

are you building in the source tree itself?  If so, can you try
building with make O=3Dobjdir and see if that fixes the problem.  I'm
unsure if addtree is safe to be called from the Makefile, but I didn't
want to worry about relatively minor build questions at this time.

Thanks,

	--david
