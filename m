From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Mon, 04 Jul 2005 18:26:32 +0000
Subject: RE: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <516F50407E01324991DD6D07B0531AD54FA3A2@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Thanks for the reply and very useful feedback!

> > but also run natively on hardware (called "transparent
> > paravirtualization").  This should be appealing to Linux/ia64
>=20
> Very cool, and I think xen/x86 will have to adopt that model
> aswell if it wants to get in mainline.  Maybe you can clean up
> the ia64 patches soon enough so we get xen/ia64 merged before
> xen/x86?

Yes, but this is much harder on Xen/x86 as the memory model is
somewhat different on Xen/x86 than on Linux/x86.  On Xen/ia64,
the differences can be completely hidden from Linux because
all mapping is done through the TLB (which requires a privileged
instruction that can be trapped).  The Xen/x86 guys have proposed
some ideas (e.g. a special linker that links in both Xen and
standard Linux routines and selects at runtime) but I don't think
anyone has tried to do it.

In any case, I agree that getting the xen/ia64 changes merged
in can be done prior to the xen/x86 changes.

> > I would like to submit a series of CONFIG_XEN patches to
> > this list for review over the next few weeks.  The first
> > patch will be a few syntactic changes that will make
> > subsequent patches easier.  For example, there are a number of
> > places where ia64_getreg(REG_X) is used where abstracting
> > at a slightly higher level, e.g. with ia64_get_regX() would
> > make CONFIG_XEN easier.
>=20
> Yes, absolutely.  That's always a good thing and the ifdef mess
> in the current patch is quite bad.

Understood.  This was just a "get it to work" patch and intended
to solicit useful feedback (like yours below).
=20
> > For preliminary discussion, I have attached the current
> > patch for existing files for 2.6.11.  There are many other
> > files required (in arch/ia64/xen, include/asm-ia64/xen, and
> > drivers/xen) for everything to work, but I'd like to
> > initiate discussion and review on existing Linux/ia64 files
> > that would change.
>=20
> Can you please post those bits aswell, at least the per-arch bits -
> the last time I saw a patch for drivers/xen the code there was
> really horrible, but I hope it has changed by now.  I also think
> IA64 Xen arch bits can be merged before it, we support botting with
> initrd and out of tree drivers quite well these days.

The code in drivers/xen is still x86-specific.  We are working
on merging in some changes to accommodate ia64 (and other future
architectures) but they're not quite ready yet.

The arch/ia64/xen code includes a 95% identical IVT and 95%
identical ia64_leave_kernel/ia64_leave_syscall and a few others.
(The switch between the original and xen versions is handled
dynamically because the impact on the real IVT would be very
ugly.)  These are still evolving somewhat as I tune performance.
I can send you the current versions (off-list) if you like.

> --- 1.10/include/asm-ia64/delay.h	Thu Dec 16 12:57:15 2004
> +++ 1.12/include/asm-ia64/delay.h	Wed Jun 29 13:46:08 2005
> @@ -20,12 +20,17 @@
>  #include <asm/intrinsics.h>
>  #include <asm/processor.h>
> =20
> +#ifdef CONFIG_XEN
> +extern void xen_set_itm (unsigned long);
> +#define ia64_set_itm(val) xen_set_itm(val)
>=20
> Any reason you don't call the Xen version ia64_set_itm directly?

Do you mean just change the code in arch/ia64/time.c?  Actually,
what I was going to try was to move this out of delay.h and
into processor.h (or privop.h, see below).
=20
> +#ifdef CONFIG_XEN
> +	flag =3D xen_get_eflag();
> +#else
>  	flag =3D ia64_getreg(_IA64_REG_AR_EFLAG);
> +#endif
>=20
> So this is repeated all over, and an ia64_get_eflag() would be
> cool (I suspect you're already planning it, but I'd like to offer
> my opinion on the abstractions anyway, feel free to disacard them
> if they're boring and duplicate what you already plan)

Yep, that was the direction I am headed.  I'm glad you are
offering your opinion as it helps to reinforce the direction.
However, I am sure I will get some of the details wrong (or at
least that there will be varied opinions about the "right" way).

> --- 1.74/arch/ia64/Makefile	Fri Jan 28 16:32:45 2005
> +++ 1.80/arch/ia64/Makefile	Tue Jun 28 16:59:42 2005
> @@ -11,6 +11,8 @@
>  NM :=3D $(CROSS_COMPILE)nm -B
>  READELF :=3D $(CROSS_COMPILE)readelf
> =20
> +NOSTDINC_FLAGS +=3D -Iinclude/asm-xen
>=20
> Please don't do that.  Use '#include <asm-xen/foo.h>', but in reality
> that stuff shouldn't be in include/asm-xen anyway but include/xen/.

Yeah the Xen team is still debating how best to structure the xen
code in the linux tree.  Hopefully that will be resolved at OLS.
In the meantime, I have a problem because there are two "asm" trees
that need to be include'd.  IOW, the NOSTDINC_FLAGS should go away.

>  drivers-$(CONFIG_PCI)		+=3D arch/ia64/pci/
> +ifneq ($(CONFIG_XEN),y)
>  drivers-$(CONFIG_IA64_HP_SIM)	+=3D arch/ia64/hp/sim/
> +endif
> +drivers-$(CONFIG_XEN)		+=3D arch/ia64/hp/sim/
>=20
> I think you can =FEave two drivers- lines for different symbols and let
> the build system sort it out. Atleast it works for obj-, if it doesn't
> work for drivers- ask the build system maintainers for a little
> help.
>=20
> Any particular reason you use the HP SIM bits but Xen/x86 doesn't?
> their far less messy then what xen/x86 uses at least, and a=20
> lot simpler..

Actually I'm using both (the x86-based and the HP SIM).  One of my
side projects is to turn the HP SIM code into a ia64 CONFIG_ option rather
than a machvec (similar to what Greg Edwards just did with the
SGI simulator).

>  /*
>   * Architecture-specific setup.
>   *
> @@ -270,6 +271,16 @@
>  static inline int __init
>  early_console_setup (char *cmdline)
>  {
> +#ifdef CONFIG_XEN
> +#ifndef CONFIG_IA64_HP_SIM
> +	extern int running_on_xen;
> +	if (running_on_xen) {
> +		extern struct console hpsim_cons;
> +		register_console(&hpsim_cons);
> +		return 0;
> +	}
> +#endif
>=20
> why the #ifndef CONFIG_IA64_HP_SIM? =20

Because I am doing some debugging on the HP simulator :-) and CONFIG_IA64_H=
P_SIM
is currently required to build a Linux that runs on the simulator.  Hopeful=
ly
this will become unnecessary.

> =3D=3D=3D include/asm-ia64/processor.h 1.72 vs 1.79 =3D=3D> --- 1.72/incl=
ude/asm-ia64/processor.h	Wed Jan 26 11:01:41 2005
> +#define ia64_eoi xen_eoi
>=20
> Same comment as for xen_set_itm().
> =20
> +#define ia64_get_ivr xen_get_ivr
>=20
> Dito. It might also be useful to regroup the inlines so all that
> are overriden by Xen are in a single place.

Yes.  Actually, does it make sense to pull these into a separate
include file (e.g. asm/privop.h)?  Then I think I can get rid
of all CONFIG_XEN in processor.h... and privop.h may be more
appropriate since it is privileged operations that Xen is primarily
concerned with.
 =20
>  #endif /* !__ASSEMBLY__ */
> +
> +#ifdef CONFIG_XEN
> +#include <asm/xen/processor.h>
> +#endif
>=20
> This is a bit ugly.  How big is asm/xen/processor.h? Can you=20
> just inline
> it here, or maybe some of this should become machvecs?

I don't think machvec is an option as CONFIG_XEN should work
regardless of the machvec.

xen/processor.h is not real big but it is ugly

> --- 1.6/drivers/acpi/motherboard.c	Wed Nov 10 15:57:35 2004
> +++ 1.7/drivers/acpi/motherboard.c	Fri Apr 22 16:47:41 2005
> @@ -120,6 +120,9 @@
>  static void __init
>  acpi_reserve_resources (void)
>  {
> +#ifdef CONFIG_XEN
> +	if (!acpi_gbl_FADT) return;
> +#endif
>=20
> Should be unconditional.

Agreed.  Should I submit a patch to the ACPI maintainer?

> --- 1.85/arch/ia64/Kconfig	Fri Jan 28 16:32:25 2005
> +++ 1.86/arch/ia64/Kconfig	Fri Apr 22 16:52:50 2005
> @@ -46,6 +46,10 @@
>  	bool
>  	default y
> =20
> +config XEN
> +	bool
> +	default y
>=20
> You should make it user-selectable by adding a prompt text, and while
> you're at it also add a help text.

Will do.  Haven't gotten around to many aesthetics yet as I was primarily
focused on proving that transparent paravirtualization would work.

Thanks again for the great feedback.  After I make another round
of cleanups, I will send the patch (at least phase 1) for another
review.

Dan
