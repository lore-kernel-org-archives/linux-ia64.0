From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 04 Jul 2005 15:24:23 +0000
Subject: Re: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <20050704152423.GA4196@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Jun 29, 2005 at 01:16:34PM -0700, Magenheimer, Dan (HP Labs Fort Co=
llins) wrote:
> to ia64, which is currently approaching its Beta release, and
> currently has contributors from Intel, SGI, CERN, and Bull.
> I have also been co-developing "xenlinux" for ia64, the
> paravirtualized version of Linux/ia64.  Like Xen/x86, the
> required linux changes are small but -- unlike Xen/x86 --
> the required changes for Linux/ia64 are entirely archdep;
> no common files need to be changed.  Also unlike Xen/x86,
> Linux/ia64 with CONFIG_XEN enabled runs successfully on Xen,
> but also run natively on hardware (called "transparent
> paravirtualization").  This should be appealing to Linux/ia64
> distributors as different kernels need not be shipped for
> running on Xen or running native.

Very cool, and I think xen/x86 will have to adopt that model
aswell if it wants to get in mainline.  Maybe you can clean up
the ia64 patches soon enough so we get xen/ia64 merged before
xen/x86?

> I would like to submit a series of CONFIG_XEN patches to
> this list for review over the next few weeks.  The first
> patch will be a few syntactic changes that will make
> subsequent patches easier.  For example, there are a number of
> places where ia64_getreg(REG_X) is used where abstracting
> at a slightly higher level, e.g. with ia64_get_regX() would
> make CONFIG_XEN easier.

Yes, absolutely.  That's always a good thing and the ifdef mess
in the current patch is quite bad.

> For preliminary discussion, I have attached the current
> patch for existing files for 2.6.11.  There are many other
> files required (in arch/ia64/xen, include/asm-ia64/xen, and
> drivers/xen) for everything to work, but I'd like to
> initiate discussion and review on existing Linux/ia64 files
> that would change.

Can you please post those bits aswell, at least the per-arch bits -
the last time I saw a patch for drivers/xen the code there was
really horrible, but I hope it has changed by now.  I also think
IA64 Xen arch bits can be merged before it, we support botting with
initrd and out of tree drivers quite well these days.

> For those who can't wait, a pre-beta version of Xen/ia64 and
> the transparently paravirtualized 2.6.11 xenlinux/ia64 can be
> found at xen-ia64.bkbits.net (and soon in a repository for
> a different SCM).

A patch would be much nicer..

--- 1.10/include/asm-ia64/delay.h	Thu Dec 16 12:57:15 2004
+++ 1.12/include/asm-ia64/delay.h	Wed Jun 29 13:46:08 2005
@@ -20,12 +20,17 @@
 #include <asm/intrinsics.h>
 #include <asm/processor.h>
=20
+#ifdef CONFIG_XEN
+extern void xen_set_itm (unsigned long);
+#define ia64_set_itm(val) xen_set_itm(val)

Any reason you don't call the Xen version ia64_set_itm directly?

+#ifdef CONFIG_XEN
+	flag =3D xen_get_eflag();
+#else
 	flag =3D ia64_getreg(_IA64_REG_AR_EFLAG);
+#endif

So this is repeated all over, and an ia64_get_eflag() would be
cool (I suspect you're already planning it, but I'd like to offer
my opinion on the abstractions anyway, feel free to disacard them
if they're boring and duplicate what you already plan)

--- 1.74/arch/ia64/Makefile	Fri Jan 28 16:32:45 2005
+++ 1.80/arch/ia64/Makefile	Tue Jun 28 16:59:42 2005
@@ -11,6 +11,8 @@
 NM :=3D $(CROSS_COMPILE)nm -B
 READELF :=3D $(CROSS_COMPILE)readelf
=20
+NOSTDINC_FLAGS +=3D -Iinclude/asm-xen

Please don't do that.  Use '#include <asm-xen/foo.h>', but in reality
that stuff shouldn't be in include/asm-xen anyway but include/xen/.

 drivers-$(CONFIG_PCI)		+=3D arch/ia64/pci/
+ifneq ($(CONFIG_XEN),y)
 drivers-$(CONFIG_IA64_HP_SIM)	+=3D arch/ia64/hp/sim/
+endif
+drivers-$(CONFIG_XEN)		+=3D arch/ia64/hp/sim/

I think you can =FEave two drivers- lines for different symbols and let
the build system sort it out. Atleast it works for obj-, if it doesn't
work for drivers- ask the build system maintainers for a little
help.

Any particular reason you use the HP SIM bits but Xen/x86 doesn't?
their far less messy then what xen/x86 uses at least, and a lot simpler..

 /*
  * Architecture-specific setup.
  *
@@ -270,6 +271,16 @@
 static inline int __init
 early_console_setup (char *cmdline)
 {
+#ifdef CONFIG_XEN
+#ifndef CONFIG_IA64_HP_SIM
+	extern int running_on_xen;
+	if (running_on_xen) {
+		extern struct console hpsim_cons;
+		register_console(&hpsim_cons);
+		return 0;
+	}
+#endif

why the #ifndef CONFIG_IA64_HP_SIM? =20

=3D=3D=3D include/asm-ia64/processor.h 1.72 vs 1.79 =3D=3D--- 1.72/include/=
asm-ia64/processor.h	Wed Jan 26 11:01:41 2005
+++ 1.79/include/asm-ia64/processor.h	Wed Jun 29 13:46:08 2005
@@ -551,12 +551,17 @@
 	ia64_srlz_i();
 }
=20
+#ifdef CONFIG_XEN
+extern void xen_eoi (void);
+#define ia64_eoi xen_eoi
+#else
 static inline void
 ia64_eoi (void)
 {
 	ia64_setreg(_IA64_REG_CR_EOI, 0);
 	ia64_srlz_d();
 }
+#endif

Same comment as for xen_set_itm().
=20
 #define cpu_relax()	ia64_hint(ia64_hint_pause)
=20
+#ifdef CONFIG_XEN
+extern __u64 xen_get_ivr (void);
+#define ia64_get_ivr xen_get_ivr
+#else
 static inline __u64
 ia64_get_ivr (void)
 {
@@ -630,6 +639,7 @@
 	ia64_srlz_d();
 	return r;
 }
+#endif

Dito. It might also be useful to regroup the inlines so all that
are overriden by Xen are in a single place.
=20
 #endif /* !__ASSEMBLY__ */
+
+#ifdef CONFIG_XEN
+#include <asm/xen/processor.h>
+#endif

This is a bit ugly.  How big is asm/xen/processor.h? Can you just inline
it here, or maybe some of this should become machvecs?
=20
--- 1.6/drivers/acpi/motherboard.c	Wed Nov 10 15:57:35 2004
+++ 1.7/drivers/acpi/motherboard.c	Fri Apr 22 16:47:41 2005
@@ -120,6 +120,9 @@
 static void __init
 acpi_reserve_resources (void)
 {
+#ifdef CONFIG_XEN
+	if (!acpi_gbl_FADT) return;
+#endif

Should be unconditional.

--- 1.85/arch/ia64/Kconfig	Fri Jan 28 16:32:25 2005
+++ 1.86/arch/ia64/Kconfig	Fri Apr 22 16:52:50 2005
@@ -46,6 +46,10 @@
 	bool
 	default y
=20
+config XEN
+	bool
+	default y

You should make it user-selectable by adding a prompt text, and while
you're at it also add a help text.

