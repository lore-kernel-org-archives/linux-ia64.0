From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Sat, 31 Mar 2012 16:54:01 +0000
Subject: Re: [PATCH RFC] Simplify the Linux kernel by reducing its state space
Message-Id: <20120331165401.GD2450@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120331163321.GA15809@linux.vnet.ibm.com>
 <CAMuHMdWTB+_AtqM6JixY=Oo_zmzX_dNxnivpARBYSbPJzp4t6A@mail.gmail.com>
In-Reply-To: <CAMuHMdWTB+_AtqM6JixY=Oo_zmzX_dNxnivpARBYSbPJzp4t6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-arm-kernel@lists.infradead.org

On Sat, Mar 31, 2012 at 06:40:30PM +0200, Geert Uytterhoeven wrote:
> Hi Paul,
>=20
> On Sat, Mar 31, 2012 at 18:33, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > Although there have been numerous complaints about the complexity of
> > parallel programming (especially over the past 5-10 years), the plain
> > truth is that the incremental complexity of parallel programming over
> > that of sequential programming is not as large as is commonly believed.
> > Despite that you might have heard, the mind-numbing complexity of modern
> > computer systems is not due so much to there being multiple CPUs, but
> > rather to there being any CPUs at all. =A0In short, for the ultimate in
> > computer-system simplicity, the optimal choice is NR_CPUS=3D0.
> >
> > This commit therefore limits kernel builds to zero CPUs. =A0This change
> > has the beneficial side effect of rendering all kernel bugs harmless.
> > Furthermore, this commit enables additional beneficial changes, for
> > example, the removal of those parts of the kernel that are not needed
> > when there are zero CPUs.
> >
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> > ---
> >
> > =A0alpha/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 +++++=
+-----
> > =A0arm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 +=
++---
> > =A0blackfin/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 ++-
> > =A0hexagon/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A09 +++++=
----
> > =A0ia64/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 +=
++++----
> > =A0m32r/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 +++=
+++----
> > =A0mips/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 21 +++=
++++++++----------
> > =A0mn10300/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 ++-
> > =A0parisc/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A06 +++=
---
> > =A0powerpc/platforms/Kconfig.cputype | =A0 =A08 ++++----
> > =A0s390/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 12 +++=
++++-----
> > =A0sh/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +=
+++++-----
> > =A0sparc/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A08 +++=
+----
> > =A0tile/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 +=
++++----
> > =A0x86/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 16 +++=
++++++-------
> > =A015 files changed, 78 insertions(+), 64 deletions(-)
>=20
> You forgot to fix half of the architectures, a.o. m68k?

I must confess that I fixed only the SMP-capable architectures.

I of course would welcome additions for UP-only architectures.

							Thanx, Paul

