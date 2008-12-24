From: Shaohua Li <shaohua.li@intel.com>
Date: Wed, 24 Dec 2008 00:54:55 +0000
Subject: Re: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <20081224005455.GB24488@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Dec 23, 2008 at 10:35:49PM +0800, Steven Rostedt wrote:
>=20
> On Tue, 2008-12-23 at 14:08 +0800, Shaohua Li wrote:
> > IA64 dynamic ftrace support. The main tricky thing here is to support m=
odule.
> > In a module, each routine's mcount call will call a PLT stub, which
> > will call kernel mcount. We can't simply make the mcount call call into
> > kernel mcount, as kernel and mocule have different gp and the
> > instruction just supports 25bit offset. So I introduced a new PLT stub,
> > which will call into kernel ftrace_caller. When module loading, all
> > mcount call will be converted to nop. When the nop is converted to call,
> > we make the call to the new PLT stub instead of old mcount PLT stub.
> >
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > ---
> >  arch/ia64/Kconfig              |    2
> >  arch/ia64/include/asm/ftrace.h |   17 ++
> >  arch/ia64/include/asm/module.h |    4
> >  arch/ia64/kernel/Makefile      |    5
> >  arch/ia64/kernel/entry.S       |   37 ++++++
> >  arch/ia64/kernel/ftrace.c      |  234 ++++++++++++++++++++++++++++++++=
+++++++++
> >  arch/ia64/kernel/module.c      |   15 ++
> >  scripts/recordmcount.pl        |    7 +
> >  8 files changed, 321 insertions(+)
> >
> > Index: linux/arch/ia64/Kconfig
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> > --- linux.orig/arch/ia64/Kconfig      200=
8-12-23 13:13:17.000000000 +0800
> > +++ linux/arch/ia64/Kconfig   2008-12-23 13:30:09.000000000 +0800
> > @@ -21,6 +21,8 @@ config IA64
> >       select HAVE_OPROFILE
> >       select HAVE_KPROBES
> >       select HAVE_KRETPROBES
> > +     select HAVE_FTRACE_MCOUNT_RECORD
> > +     select HAVE_DYNAMIC_FTRACE
> >       select HAVE_FUNCTION_TRACER
> >       select HAVE_DMA_ATTRS
> >       select HAVE_KVM
> > Index: linux/arch/ia64/kernel/Makefile
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> > --- linux.orig/arch/ia64/kernel/Makefile =
     2008-12-23 13:11:27.000000000 +0800
> > +++ linux/arch/ia64/kernel/Makefile   2008-12-23 13:30:09.000000000 +08=
00
> > @@ -2,6 +2,10 @@
> >  # Makefile for the linux kernel.
> >  #
> >
> > +ifdef CONFIG_DYNAMIC_FTRACE
> > +CFLAGS_REMOVE_ftrace.o =3D -pg
> > +endif
> > +
> >  extra-y      :=3D head.o init_task.o vmlinux.lds
> >
> >  obj-y :=3D acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksy=
ms.o irq.o irq_ia64.o    \
> > @@ -28,6 +32,7 @@ obj-$(CONFIG_IA64_CYCLONE)  +=3D cyclone.o
> >  obj-$(CONFIG_CPU_FREQ)               +=3D cpufreq/
> >  obj-$(CONFIG_IA64_MCA_RECOVERY)      +=3D mca_recovery.o
> >  obj-$(CONFIG_KPROBES)                +=3D kprobes.o jprobes.o
> > +obj-$(CONFIG_DYNAMIC_FTRACE) +=3D ftrace.o
> >  obj-$(CONFIG_KEXEC)          +=3D machine_kexec.o relocate_kernel.o cr=
ash.o
> >  obj-$(CONFIG_CRASH_DUMP)     +=3D crash_dump.o
> >  obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)        +=3D uncached.o
> > Index: linux/arch/ia64/kernel/ftrace.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> > --- /dev/null 1970-01-01 00:00:00.0000000=
00 +0000
> > +++ linux/arch/ia64/kernel/ftrace.c   2008-12-23 13:30:09.000000000 +08=
00
> > @@ -0,0 +1,234 @@
> > +/*
> > + * Dynamic function tracing support.
> > + *
> > + * Copyright (C) 2008 Shaohua Li <shaohua.li@intel.com>
> > + *
> > + * For licencing details, see COPYING.
> > + *
> > + * Defines low-level handling of mcount calls when the kernel
> > + * is compiled with the -pg flag. When using dynamic ftrace, the
> > + * mcount call-sites get patched lazily with NOP till they are
> > + * enabled. All code mutation routines here take effect atomically.
> > + */
> > +
> > +#include <linux/uaccess.h>
> > +#include <linux/ftrace.h>
> > +
> > +#include <asm/cacheflush.h>
> > +#include <asm/ftrace.h>
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
> As I stated before, you can not have a multi-line nop. The best you can
> do is add a jump over the entire call, and only if that jump is a single
> instruction.
>=20
> Think about it, lets do a simple scenario.
>=20
> Some process is running inside the kernel and starts to execute one of
> these 'nop' sequences. After executing the third nop, it is preempted
> (before finishing the other nops). During this preemption, you happen to
> start the tracer. Kstop_machine is called and all processes are now
> stopped.  The kstop_machine changes the nop to the call of a function
> tracer and resumes.  Now that original process gets scheduled back in,
> but the code is no longer nops, it has actual code and a call. But we
> missed the first 3 commands. Not to mention, it looks like the op codes
> are not even 4 or 8 byte aligned. So we could be executing something
> that is not even a command. BAM! Crash! kernel oops! ;-)
Makes sense, I'll try a jump approach.

> > +static unsigned char *ftrace_nop_replace(void)
> > +{
> > +     return ftrace_nop_code;
> > +}
> > +
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
>=20
> If you made your own PLT stub, could you just change the one line to
> jump to that stub?
A simple jump to PLT stub doesn't work in IA64, as a lot of registers
should be saved. I'll do more investigation.

> > Index: linux/scripts/recordmcount.pl
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> > --- linux.orig/scripts/recordmcount.pl   =
     2008-12-23 13:24:59.000000000 +0800
> > +++ linux/scripts/recordmcount.pl     2008-12-23 13:30:09.000000000 +08=
00
> > @@ -206,6 +206,13 @@ if ($arch eq "x86_64") {
> >      $alignment =3D 2;
> >      $section_type =3D '%progbits';
> >
> > +} elsif ($arch eq "ia64") {
> > +    $mcount_regex =3D "^\\s*([0-9a-fA-F]+):.*\\s_mcount\$";
> > +    $type =3D "data8";
> > +
> > +    if ($is_module eq "0") {
> > +        $cc .=3D " -mconstant-gp";
> > +    }
>=20
> I wonder if it would be better to pass in CFLAGS and then be able to
> parse that instead. Then we can find out a lot more about what we are
> working on.
CFLAGS seems have a lot of useless flags here.

Thanks,
Shaohua
