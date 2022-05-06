From: Niklas Schnelle <schnelle@linux.ibm.com>
Date: Fri, 06 May 2022 12:42:58 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <48b81eb280d949e9321eb304d0ee36abb0075709.camel@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a0sJgMSpZB_Butx2gO0hapYZy-Dm_QH-hG5rOaq_ZgsXg@mail.gmail.com>
         <20220505161028.GA492600@bhelgaas>
         <CAK8P3a3fmPExr70+fVb564hZdGAuPtYa-QxgMMe5KLpnY_sTrQ@mail.gmail.com>
         <alpine.DEB.2.21.2205061058540.52331@angie.orcam.me.uk>
         <CAK8P3a0NzG=3tDLCdPj2=A__2r_+xiiUTW=WJCBNp29x_A63Og@mail.gmail.com>
In-Reply-To: <CAK8P3a0NzG=3tDLCdPj2=A__2r_+xiiUTW=WJCBNp29x_A63Og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, "Maciej W. Rozycki" <macro@orcam.me.uk>
Cc: Bjorn Helgaas <helgaas@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>

On Fri, 2022-05-06 at 13:33 +0200, Arnd Bergmann wrote:
> On Fri, May 6, 2022 at 12:20 PM Maciej W. Rozycki <macro@orcam.me.uk> wrote:
> > On Thu, 5 May 2022, Arnd Bergmann wrote:
> >  I think I'm missing something here.  IIUC we're talking about a PCI/PCIe
> > bus used with s390 hardware, right?
> > 
> >  (It has to be PCI/PCIe, because other than x86/IA-64 host buses there are
> > only PCI/PCIe and EISA/ISA buses out there that define I/O access cycles
> > and EISA/ISA have long been obsoleted except perhaps from some niche use.)
> > 
> >  If this is PCI/PCIe indeed, then an I/O access is just a different bit
> > pattern put on the bus/in the TLP in the address phase.  So what is there
> > inherent to the s390 architecture that prevents that different bit pattern
> > from being used?
> 
> The hardware design for PCI on s390 is very different from any other
> architecture, and more abstract. Rather than implementing MMIO register
> access as pointer dereference, this is a separate CPU instruction that
> takes a device/bar plus offset as arguments rather than a pointer, and
> Linux encodes this back into a fake __iomem token.

Correct, we have since gained new PCI load/store instructions that
actually do take a virtual address that gets address translated to a
"physical address" for the PCI BARs. The "physical address" we get from
the platform (again via special instructions). I put "physical address"
in quotes because while they are conceptually physical addresses and
they are translated to by MMU translation tables, accessing their
virtual mapping with any instruction other then the special PCI
load/store instructions will cause addressing exceptions. So we still
don't have real MMIO but something that looks a lot more like MMIO than
we used to.

> 
> >  If anything, I could imagine the same limitation as with current POWER9
> > implementations, that is whatever glue is used to wire PCI/PCIe to the
> > rest of the system does not implement a way to use said bit pattern (which
> > has nothing to do with the POWER9 processor instruction set).
> > 
> >  But that has nothing to do with the presence or absence of any specific
> > processor instructions.  It's just a limitation of bus glue.  So I guess
> > it's just that all PCI/PCIe glue logic implementations for s390 have such
> > a limitation, right?
> 
> There are separate instructions for PCI memory and config space, but
> no instructions for I/O space, or for non-PCI MMIO that it could be mapped
> into.
> 
>        Arnd

The config space is still accessed with the old style PCI load/store
instructions via a special extra BAR.

But yes overall on s390x we can only access PCI(e) devices via special
instructions not via real MMIO and also the OS has no direct access to
the registers of the PHB which are only accessible to firmware. 

Maybe as a bit of further background it's also important to note that
on s390x all Operating Systems run inside a hypervisor. On the lowest
level any OS can run this is a non-paging machine level hypervisor. For
PCI that means that we always have a kind of pass-through access though
without paging and hardware support for the memory partitioning this is
of course relatively simple.
