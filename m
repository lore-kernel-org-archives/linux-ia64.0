From: Bob Picco <bob.picco@hp.com>
Date: Wed, 15 Jun 2005 16:55:50 +0000
Subject: Re: updated libunwind patch for v2.6 kernel
Message-Id: <20050615165550.GK23911@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506100531.j5A5VYSB001927@napali.hpl.hp.com>
In-Reply-To: <200506100531.j5A5VYSB001927@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger wrote:	[Fri Jun 10 2005, 01:31:34AM EDT]
> An updated version of the libunwind patch for the 2.6-kernel is now
> available at:
>=20
>  ftp://ftp.hpl.hp.com/pub/linux-ia64/unwind-2.6-050609.diff.gz
>=20
> The only change is that the libunwind API has been exported to
> modules.  The problem I reported earlier with strace'ing an x86 task
> apparently had nothing to do with the libunwind changes as it went
> away before I even had a chance to investigate.
>=20
> This patch passes all my testing so far.  The only thing that I
> haven't tested (at all) is the oprofile call-stack tracing.  I'd be
> interested to hear if/how that works.  (I did drop the old compiler
> support there --- I hope nobody uses such old compilers anymore and
> the code was just gross; but if we have to, we can resurrect it).
>=20
> Tony, I know you're in the middle of making the test-2.6 tree work
> better for you.  For now, the patch above is relative to Linus 2.6
> tree, but if you have no objections, I'd like to feed it into your
> test-2.6 as soon as possible (just let me know when you're ready and I
> will respin the patch relative to test-2.6).
>=20
> Thanks,
>=20
> 	--david
> -
Hi David,

I have build problems after applying this patch against
rsync://rsync.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git.
I've also have kgdb patches applied but don't believe they are the
offending issue.

Appended is the relevant part of the kernel make output.

thanks,

bob


  ia64-linux-gcc -Wp,-MD,arch/ia64/unwind/.init_local.o.d  -nostdinc -isyst=
em /usr/local/lib/gcc-lib/ia64-linux/3.3/include -D__KERNEL__ -Iinclude  -D=
HAVE_BUGGY_SEGREL -DHAVE_ATOMIC_H  -Wall -Wstrict-prototypes -Wno-trigraphs=
 -fno-strict-aliasing -fno-common -ffreestanding -O2     -fomit-frame-point=
er -g -pipe  -ffixed-r13 -mfixed-range=F12-f15,f32-f127 -falign-functions2 =
-frename-registers -fno-optimize-sibling-calls     -mconstant-gp -DKBUILD_B=
ASENAME=3Dinit_local -DKBUILD_MODNAME=3Dinit_local -c -o arch/ia64/unwind/i=
nit_local.o arch/ia64/unwind/init_local.c
In file included from arch/ia64/unwind/init.h:26,
                 from arch/ia64/unwind/init_local.c:26:
arch/ia64/unwind/unwind_i.h:33:25: libunwind_i.h: No such file or directory
In file included from arch/ia64/unwind/unwind_i.h:34,
                 from arch/ia64/unwind/init.h:26,
                 from arch/ia64/unwind/init_local.c:26:
arch/ia64/unwind/rse.h:13:23: libunwind.h: No such file or directory
In file included from arch/ia64/unwind/init.h:26,
                 from arch/ia64/unwind/init_local.c:26:
arch/ia64/unwind/unwind_i.h:52: error: syntax error before "void"
arch/ia64/unwind/unwind_i.h: In function `inlined_sw_addr':
arch/ia64/unwind/unwind_i.h:55: error: `unw_word_t' undeclared (first use i=
n this function)
[snip]
