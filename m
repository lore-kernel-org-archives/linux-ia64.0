From: Andrew Morton <akpm@osdl.org>
Date: Sat, 10 Jan 2004 07:23:26 +0000
Subject: ia64 problems with NR_CPUS > 256
Message-Id: <20040109232326.38dd1e95.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Rusty Russell <rusty@rustcorp.com.au> wrote:
>
> In message <20040109141236.4bcf7293.akpm@osdl.org> you write:
> > jbarnes@sgi.com (Jesse Barnes) wrote:
> > >
> > > Thanks, this patch works.  However, it appears that something (not you
> > > Pat!) broke cpumasks again--I got failures when I tried a 512p build.
> >=20
> > That's probably Rusty breaking stuff again.  The relevant patches are:
> >=20
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6=
.1-mm1/broken-out/make-for_each_cpu-iterator-more-friendly.patch
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6=
.1-mm1/broken-out/make-for_each_cpu-iterator-more-friendly-fix.patch
>=20
> Probably.  Paul Jackson acked them though, so I'm a little surprised.
>=20

OK, here's the scoop.   ia64 with NR_CPUSQ2:

  /usr/local/gcc-3.3.1/bin/gcc -Wp,-MD,kernel/.sched.o.d -nostdinc -iwithpr=
efix include -D__KERNEL__ -Iinclude   -D__KERNEL__ -Iinclude   -Wall -Wstri=
ct-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -pipe  -ffixe=
d-r13 -mfixed-range=F12-f15,f32-f127 -falign-functions2 -frename-registers =
-O2 -fomit-frame-pointer    -mconstant-gp -DKBUILD_BASENAME=3Dsched -DKBUIL=
D_MODNAME=3Dsched -c -o kernel/.tmp_sched.o kernel/sched.c
kernel/sched.c: In function `nr_uninterruptible':
kernel/sched.c:905: error: structure has no member named `val'
kernel/sched.c:905: error: structure has no member named `val'
kernel/sched.c: In function `nr_context_switches':

The problem is that Rusty's patch _used_ for_each_cpu().  It is already
broken.

In cpumask_const_reference.h we have stuff like:

#define cpus_and_const(dst,src1,src2)     cpus_and(dst,*(src1).val,*(src2).=
val)

But include/linux/cpumask.h never defines a version of struct cpumask which
has a `val' member in it.

So somewhere along the line, the pass-by-reference stuff got broken.

Bill, how is this actually supposed to work?  Is `val' supposed to be in
struct cpumask, or is the cpumask_const_reference.h code wrong?

Thanks.

