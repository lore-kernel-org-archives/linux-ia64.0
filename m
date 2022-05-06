From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 06 May 2022 13:08:46 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <CAMuHMdWj5rmrP941DF7bsUXbiiemE-o2=8XqnAS-chgmpFFPQg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a0sJgMSpZB_Butx2gO0hapYZy-Dm_QH-hG5rOaq_ZgsXg@mail.gmail.com>
 <20220505161028.GA492600@bhelgaas> <CAK8P3a3fmPExr70+fVb564hZdGAuPtYa-QxgMMe5KLpnY_sTrQ@mail.gmail.com>
 <alpine.DEB.2.21.2205061058540.52331@angie.orcam.me.uk> <CAK8P3a0NzG=3tDLCdPj2=A__2r_+xiiUTW=WJCBNp29x_A63Og@mail.gmail.com>
 <alpine.DEB.2.21.2205061314110.52331@angie.orcam.me.uk> <5239892986c94239a122ab2f7a18a7a5@AcuMS.aculab.com>
In-Reply-To: <5239892986c94239a122ab2f7a18a7a5@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@aculab.com>
Cc: "Maciej W. Rozycki" <macro@orcam.me.uk>, Arnd Bergmann <arnd@kernel.org>, Rich Felker <dalias@libc.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, "open list:MIPS" <linux-mips@vger.kernel.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, Will Deacon <will@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, linux-pci <linux-pci@vger.kernel.org>, Bjorn Helgaas <helgaas@kernel.org>, Matt Turner <mattst88@gmail.com>, Albert Ou <aou@eecs.berkeley.edu>, Arnd Bergmann <arnd@arndb.de>, Niklas Schnelle <schnelle@linux.ibm.com>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Paul Walmsley <paul.walmsley@sifive.com>, Thomas Gleixner <tglx@linutronix.de>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, Richard Henderson <rth@twiddle.net>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

On Fri, May 6, 2022 at 2:56 PM David Laight <David.Laight@aculab.com> wrote:
> From: Maciej W. Rozycki
> > Sent: 06 May 2022 13:27
> > On Fri, 6 May 2022, Arnd Bergmann wrote:
> > > >  If this is PCI/PCIe indeed, then an I/O access is just a different bit
> > > > pattern put on the bus/in the TLP in the address phase.  So what is there
> > > > inherent to the s390 architecture that prevents that different bit pattern
> > > > from being used?
> > >
> > > The hardware design for PCI on s390 is very different from any other
> > > architecture, and more abstract. Rather than implementing MMIO register
> > > access as pointer dereference, this is a separate CPU instruction that
> > > takes a device/bar plus offset as arguments rather than a pointer, and
> > > Linux encodes this back into a fake __iomem token.
> >
> >  OK, that seems to me like a reasonable and quite a clean design (on the
> > hardware side).
> >
> >  So what happens if the instruction is given an I/O rather than memory BAR
> > as the relevant argument?  Is the address space indicator bit (bit #0)
> > simply ignored or what?
>
> You don't understand something...
>
> For a memory BAR pci_ioremap() returns a token that can be used with readl().
> On most architectures readl() is just a memory access.
> This all fails on an I/O BAR.
>
> For an I/O BAR you want a similar pair of functions.
> On x86 the access function would need to use the 'in/out' instructions but
> there is no requirement for the token to be the native io port number.
> On many non-x86 architectures the access function would be a simple memory
> access - but a specific system (eg many ppc) may never actually allow
> such mappings to succeed.
>
> You might also want a third PCI mapping function that can map a memory
> BAR or an I/O BAR - with a suitable access function.
> On x86 this would need something like ioread8() for accesses.
> Except that function uses small integers for io port numbers
> (which is inherently dangerous).
>
> Nothing except the architecture specific implementation of the function
> to access an io BAR would ever go near a function called inb().
>
> The same is really true for other bus type - including ISA and EISA.
> (Ignoring the horrid of probing ISI bus devices - hopefully they
> are in the ACPI tables??_
> If a driver is probed on a ISA bus there ought to be functions
> equivalent to pci_ioremap() (for both memory and IO addresses)
> that return tokens appropriate for the specific bus.
>
> That is all a different load of churn.

A loooong time ago,  it was suggested to add register accessor
functions to struct device, so e.g. readl(dev, offset) would call
into these accessors, which would implement the bus-specific behavior.
No more worries about readl(), __raw_readl(), ioread32b(), or whatever
quirk is needed, at the (small on nowadays' machines) expense of
some indirection...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
