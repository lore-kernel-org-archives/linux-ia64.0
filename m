From: Shaohua Li <shaohua.li@intel.com>
Date: Thu, 18 Dec 2008 06:28:12 +0000
Subject: Re: [RFC 2/2] dyn ftrace porting of IA64
Message-Id: <1229581692.20991.41.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1229570241.28616.32.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1229570241.28616.32.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 2008-12-18 at 13:19 +0800, Steven Rostedt wrote:
> On Thu, 2008-12-18 at 11:17 +0800, Shaohua Li wrote:
> > This is the IA64 port of dyn ftrace. In IA64, there are some issues we
> > must solve.
> > 1. kernel compile has different option against module compile, so I
> > extend the Makefile.build/recordmcount.pl script to distinct the two
> > cases.
> > 2. in a module, each routine's mcount call will call a PLT stub, which
> > will call kernel mcount. We can't simply make the mcount call call into
> > kernel mcount, as kernel and mocule have different gp and the
> > instruction just supports 25bit offset. So I introduced a new PLT stub,
> > which will call into kernel ftrace_caller. When module loading, all
> > mcount call will be converted to nop. When the nop is converted to call,
> > we make the call to the new PLT stub instead of old mcount PLT stub.
>=20
> Have you taken a look at how powerpc64 does it?
>=20
> You can look at Ingo's tip tree under the branch tip/tracing/powerpc, or
> my own tree under tip/ftrace/ppc.
>=20
> My tree is at:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git
Thanks for your time. Is my implementation wrong or just not matches
with ppc's? Adding a new PLT entry is easy and nice solution for ia64 to
me.

I had quick look at your patch, it appears you are using
ftrace_make_call and something, are there any generic ftrace code
changes related them?

> > +
> > +static unsigned char ftrace_nop_code[MCOUNT_INSN_SIZE] =3D {
> > +     0x00, 0x00, 0x00, 0x00, 0x01, 0x00,     /* nop.m 0x0 */
> > +     0x00, 0x00, 0x00, 0x02, 0x00, 0x00,     /* nop.i 0x0 */
> > +     0x00, 0x00, 0x04, 0x00,                 /* nop.i 0x0 */
> > +     0x01, 0x00, 0x00, 0x00, 0x01, 0x00,     /* nop.m 0x0 */
> > +     0x00, 0x00, 0x00, 0x02, 0x00, 0x00,     /* nop.i 0x0 */
> > +     0x00, 0x00, 0x04, 0x00                  /* nop.i 0x0;; */
> > +};
>=20
> Is that an atomic operation?  That is, will it all get executed at once?
> If not, the task can be preempted in the middle of the nop and if the
> change happens then, when that task starts again, it may crash.
>=20
> Another option to nop, is a jump over the rest of the code.
No, this isn't an atomic operation, but why it should be atomic? As far
as I know, the code modification is called in stop_machine. Preempt is
impossible. Actually x86's mcount is 5 bytes, and not an atomic too.


> > +/* In IA64, each function will be added below two bundles with -pg opt=
ion */
> > +static unsigned char __attribute__((aligned(8)))
> > +ftrace_call_code[MCOUNT_INSN_SIZE] =3D {
> > +     0x02, 0x40, 0x31, 0x10, 0x80, 0x05, /* alloc r40=3Dar.pfs,12,8,0 =
*/
> > +     0xb0, 0x02, 0x00, 0x00, 0x42, 0x40, /* mov r43=3Dr0;; */
> > +     0x05, 0x00, 0xc4, 0x00,             /* mov r42=B0 */
> > +     0x11, 0x48, 0x01, 0x02, 0x00, 0x21, /* mov r41=3Dr1 */
> > +     0x00, 0x00, 0x00, 0x02, 0x00, 0x00, /* nop.i 0x0 */
> > +     0x08, 0x00, 0x00, 0x50              /* br.call.sptk.many b0 =3D _=
mcount;; */
> > +};
>=20
> ia64 adds that much code with -pg??  This may be a problem with respect
> to preemption. I think the way we solved this with powerpc, was just to
> change the first line into a jump.
>=20
> You can also look at the powerpc patches I did here:
>=20
>   http://lkml.org/lkml/2008/11/20/356
>=20
> and
>=20
>   http://lkml.org/lkml/2008/11/26/434
Yes, these are what ia64 added. A simple jump doesn't work, because we
must save some registers.

> >
> > +} elsif ($arch eq "ia64") {
> > +    $section_regex =3D "Disassembly of section\\s+(\\S+):";
> > +    $function_regex =3D "^([0-9a-fA-F]+)\\s+<(.*?)>:";
> > +    $mcount_regex =3D "^\\s*([0-9a-fA-F]+):.*\\s_mcount\$";
> > +    $type =3D "data8";
> > +
> > +    if ($is_module eq "0") {
> > +        $cc .=3D " -mconstant-gp";
>=20
> Again, take a look at the powerpc code to handle the 24 bit jumps, and
> see if you can solve this with that.
this flag isn't related with the jump. Instead, ia64 requires all
modules build without the option.

> > +    }
> >  } else {
> >      die "Arch $arch is not supported with CONFIG_FTRACE_MCOUNT_RECORD";
> >  }
> > Index: linux/arch/ia64/include/asm/ftrace.h
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> > --- linux.orig/arch/ia64/include/asm/ftra=
ce.h 2008-12-17 17:14:49.000000000 +0800
> > +++ linux/arch/ia64/include/asm/ftrace.h      2008-12-17 17:15:10.00000=
0000 +0800
> > @@ -7,6 +7,18 @@
> >  #ifndef __ASSEMBLY__
> >  extern void _mcount(unsigned long pfs, unsigned long r1, unsigned long=
 b0, unsigned long r0);
> >  #define mcount _mcount
> > +#define ftrace_call ftrace_caller
> > +
> > +#include <asm/kprobes.h>
> > +/* In IA64, MCOUNT_ADDR is set in link time, so it's not a constant at=
 compile time */
> > +#define MCOUNT_ADDR (((struct fnptr *)mcount)->ip)
>=20
> Again, powerpc64 does pretty much the same thing. I'm thinking you may
> be able to avoid this.
I know nothing about ppc64, but in ia64, a function pointer actually is
a structure (struct fnptr), which has two members. One is gp (GOT
pointer) the other is the function address.

Thanks,
Shaohua

