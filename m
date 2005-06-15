From: Bob Picco <bob.picco@hp.com>
Date: Wed, 15 Jun 2005 17:55:30 +0000
Subject: Re: updated libunwind patch for v2.6 kernel
Message-Id: <20050615175530.GL23911@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506100531.j5A5VYSB001927@napali.hpl.hp.com>
In-Reply-To: <200506100531.j5A5VYSB001927@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger wrote:	[Wed Jun 15 2005, 01:35:44PM EDT]
> Bob,
>=20
> >>>>> On Wed, 15 Jun 2005 12:55:50 -0400, Bob Picco <bob.picco@hp.com> sa=
id:
>=20
>   Bob> ia64-linux-gcc -Wp,-MD,arch/ia64/unwind/.init_local.o.d  -nostdinc=
 -isystem /usr/local/lib/gcc-lib/ia64-linux/3.3/include -D__KERNEL__ -Iincl=
ude  -DHAVE_BUGGY_SEGREL -DHAVE_ATOMIC_H  -Wall -Wstrict-prototypes -Wno-tr=
igraphs -fno-strict-aliasing -fno-common -ffreestanding -O2     -fomit-fram=
e-pointer -g -pipe  -ffixed-r13 -mfixed-range=F12-f15,f32-f127 -falign-func=
tions2 -frename-registers -fno-optimize-sibling-calls     -mconstant-gp -DK=
BUILD_BASENAME=3Dinit_local -DKBUILD_MODNAME=3Dinit_local -c -o arch/ia64/u=
nwind/init_local.o arch/ia64/unwind/init_local.c
>   Bob> In file included from arch/ia64/unwind/init.h:26,
>   Bob> from arch/ia64/unwind/init_local.c:26:
>   Bob> arch/ia64/unwind/unwind_i.h:33:25: libunwind_i.h: No such file or =
directory
>=20
> Looks like the compiler command is missing the -Iinclude/linux, which
> should get added via CPPFLAGS in arch/ia64/unwind/Makefile:
>=20
> CPPFLAGS        +=3D -DHAVE_ATOMIC_H $(call addtree,-Iinclude/linux)
>=20
> are you building in the source tree itself?  If so, can you try
Normal kernel build and build tree.
> building with make O=3Dobjdir and see if that fixes the problem.  I'm
> unsure if addtree is safe to be called from the Makefile, but I didn't
> want to worry about relatively minor build questions at this time.
No problem. I just hacked around it.
CPPFLAGS        +=3D -DHAVE_ATOMIC_H -Iinclude/linux
>=20
> Thanks,
>=20
> 	--david
thanks,

bob
