From: Niklas Schnelle <schnelle@linux.ibm.com>
Date: Thu, 05 May 2022 08:10:15 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <ce5510ff230fe76d9a74d0368d7d5be22011ff88.camel@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220429135108.2781579-2-schnelle@linux.ibm.com>
         <20220504210840.GA469916@bhelgaas>
         <CAK8P3a0sJgMSpZB_Butx2gO0hapYZy-Dm_QH-hG5rOaq_ZgsXg@mail.gmail.com>
In-Reply-To: <CAK8P3a0sJgMSpZB_Butx2gO0hapYZy-Dm_QH-hG5rOaq_ZgsXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Arnd Bergmann <arnd@kernel.org>, Bjorn Helgaas <helgaas@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>

On Wed, 2022-05-04 at 23:31 +0200, Arnd Bergmann wrote:
> On Wed, May 4, 2022 at 11:08 PM Bjorn Helgaas <helgaas@kernel.org> wrote:
> > On Fri, Apr 29, 2022 at 03:49:59PM +0200, Niklas Schnelle wrote:
> > > We introduce a new HAS_IOPORT Kconfig option to indicate support for
> > > I/O Port access. In a future patch HAS_IOPORT=3Dn will disable compil=
ation
> > > of the I/O accessor functions inb()/outb() and friends on architectur=
es
> > > which can not meaningfully support legacy I/O spaces such as s390 or
> > > where such support is optional.
> >=20
> > So you plan to drop inb()/outb() on architectures where I/O port space
> > is optional?  So even platforms that have I/O port space may not be
> > able to use it?
> >=20
> > This feels like a lot of work where the main benefit is to keep
> > Kconfig from offering drivers that aren't of interest on s390.
> >=20
> > Granted, there may be issues where inb()/outb() does the wrong thing
> > such as dereferencing null pointers when I/O port space isn't
> > implemented.  I think that's a defect in inb()/outb() and could be
> > fixed there.
>=20
> The current implementation in asm-generic/io.h implements inb()/outb()
> using readb()/writeb() with a fixed architecture specific offset.
>=20
> There are three possible things that can happen here:
>=20
> a) there is a host bridge driver that maps its I/O ports to this window,
>     and everything works
> b) the address range is reserved and accessible but no host bridge
>    driver has mapped its registers there, so an access causes a
>    page fault
> c) the architecture does not define an offset, and accessing low I/O
>     ports ends up as a NULL pointer dereference
>=20
> The main goal is to avoid c), which is what happens on s390, but
> can also happen elsewhere. Catching b) would be nice as well,
> but is much harder to do from generic code as you'd need an
> architecture specific inline asm statement to insert a ex_table
> fixup, or a runtime conditional on each access.
>=20
>          Arnd

Yes and to add to this, we did try a local solution in inb()/outb()
before. This added a warning when they are used and we know at compile
time that we're dealing with case c). This approach was nacked by Linus
though as we were turning a compile time known broken case into a
runtime one:

https://lore.kernel.org/lkml/CAHk-=3Dwg80je=3DK7madF4e7WrRNp37e3qh6y10Svhdc=
7O8SZ_-8g@mail.gmail.com/

I do agree with this assesment and think this is the right=E2=84=A2 approach
but it is more churn as can be seen by the size of this series. I think
longer term it could be valuable though especially if more platforms
phase out I/O port support like POWER9 for which this also allows
filtering what drivers will never work.
