From: Arnd Bergmann <arnd@kernel.org>
Date: Wed, 04 May 2022 21:31:28 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <CAK8P3a0sJgMSpZB_Butx2gO0hapYZy-Dm_QH-hG5rOaq_ZgsXg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220429135108.2781579-2-schnelle@linux.ibm.com> <20220504210840.GA469916@bhelgaas>
In-Reply-To: <20220504210840.GA469916@bhelgaas>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: Niklas Schnelle <schnelle@linux.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>

On Wed, May 4, 2022 at 11:08 PM Bjorn Helgaas <helgaas@kernel.org> wrote:
>
> On Fri, Apr 29, 2022 at 03:49:59PM +0200, Niklas Schnelle wrote:
> > We introduce a new HAS_IOPORT Kconfig option to indicate support for
> > I/O Port access. In a future patch HAS_IOPORT=n will disable compilation
> > of the I/O accessor functions inb()/outb() and friends on architectures
> > which can not meaningfully support legacy I/O spaces such as s390 or
> > where such support is optional.
>
> So you plan to drop inb()/outb() on architectures where I/O port space
> is optional?  So even platforms that have I/O port space may not be
> able to use it?
>
> This feels like a lot of work where the main benefit is to keep
> Kconfig from offering drivers that aren't of interest on s390.
>
> Granted, there may be issues where inb()/outb() does the wrong thing
> such as dereferencing null pointers when I/O port space isn't
> implemented.  I think that's a defect in inb()/outb() and could be
> fixed there.

The current implementation in asm-generic/io.h implements inb()/outb()
using readb()/writeb() with a fixed architecture specific offset.

There are three possible things that can happen here:

a) there is a host bridge driver that maps its I/O ports to this window,
    and everything works
b) the address range is reserved and accessible but no host bridge
   driver has mapped its registers there, so an access causes a
   page fault
c) the architecture does not define an offset, and accessing low I/O
    ports ends up as a NULL pointer dereference

The main goal is to avoid c), which is what happens on s390, but
can also happen elsewhere. Catching b) would be nice as well,
but is much harder to do from generic code as you'd need an
architecture specific inline asm statement to insert a ex_table
fixup, or a runtime conditional on each access.

         Arnd
