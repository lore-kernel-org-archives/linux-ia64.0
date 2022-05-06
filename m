From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 06 May 2022 15:02:06 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <CAMuHMdV1HpUNKdZDqd0e5BKfr-FqGrwGJJ_xTKw5Z55bdEJa+Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a0sJgMSpZB_Butx2gO0hapYZy-Dm_QH-hG5rOaq_ZgsXg@mail.gmail.com>
 <20220505161028.GA492600@bhelgaas> <CAK8P3a3fmPExr70+fVb564hZdGAuPtYa-QxgMMe5KLpnY_sTrQ@mail.gmail.com>
 <alpine.DEB.2.21.2205061058540.52331@angie.orcam.me.uk> <CAK8P3a0NzG=3tDLCdPj2=A__2r_+xiiUTW=WJCBNp29x_A63Og@mail.gmail.com>
 <alpine.DEB.2.21.2205061314110.52331@angie.orcam.me.uk> <5239892986c94239a122ab2f7a18a7a5@AcuMS.aculab.com>
 <CAMuHMdWj5rmrP941DF7bsUXbiiemE-o2=8XqnAS-chgmpFFPQg@mail.gmail.com> <62c1bf6687ac4abc98d4015852930241@AcuMS.aculab.com>
In-Reply-To: <62c1bf6687ac4abc98d4015852930241@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@aculab.com>
Cc: "Maciej W. Rozycki" <macro@orcam.me.uk>, Arnd Bergmann <arnd@kernel.org>, Rich Felker <dalias@libc.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, "open list:MIPS" <linux-mips@vger.kernel.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, Will Deacon <will@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, linux-pci <linux-pci@vger.kernel.org>, Bjorn Helgaas <helgaas@kernel.org>, Matt Turner <mattst88@gmail.com>, Albert Ou <aou@eecs.berkeley.edu>, Arnd Bergmann <arnd@arndb.de>, Niklas Schnelle <schnelle@linux.ibm.com>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Paul Walmsley <paul.walmsley@sifive.com>, Thomas Gleixner <tglx@linutronix.de>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, Richard Henderson <rth@twiddle.net>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

Hi David

On Fri, May 6, 2022 at 4:05 PM David Laight <David.Laight@aculab.com> wrote:
> From: Geert Uytterhoeven
> > Sent: 06 May 2022 14:09
> > > The same is really true for other bus type - including ISA and EISA.
> > > (Ignoring the horrid of probing ISI bus devices - hopefully they
> > > are in the ACPI tables??_
> > > If a driver is probed on a ISA bus there ought to be functions
> > > equivalent to pci_ioremap() (for both memory and IO addresses)
> > > that return tokens appropriate for the specific bus.
> > >
> > > That is all a different load of churn.
> >
> > A loooong time ago,  it was suggested to add register accessor
> > functions to struct device, so e.g. readl(dev, offset) would call
> > into these accessors, which would implement the bus-specific behavior.
> > No more worries about readl(), __raw_readl(), ioread32b(), or whatever
> > quirk is needed, at the (small on nowadays' machines) expense of
> > some indirection...
>
> I was just thinking that the access functions might need a 'device'.
> Although you also need the BAR (or equivalent).
> So readl(dev, bar_token, offset) or readl(dev, bar_token + offset).

Note that we do have such a system: regmap.

> Clearly the 'dev' parameter could be compiled out for non-DEBUG
> build on x86 - leaving the current(ish) object code.

Assumed all devices are PCI devices.
E.g. USB devices would still need the indirection.

> You don't want an indirect call (this year), but maybe real
> function call and a few tests won't make that much difference.
> They might affect PCIe writes, but PCIe reads are so slow you
> need to avoid them whenever possible.
> I've not timed reads into something like an ethernet chip,
> but into our fpga they are probably 1000 clocks+.
>
> OTOH I wouldn't want any overhead on the PIO fifo reads
> on one of our small ppc devices.
> We push a lot of data though that fifo and anything extra
> would kill performance.

Right.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
