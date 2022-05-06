From: Niklas Schnelle <schnelle@linux.ibm.com>
Date: Fri, 06 May 2022 13:15:16 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <1424b9289049d0ad8b5c37a4e23ef70f0ef0f83d.camel@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a0sJgMSpZB_Butx2gO0hapYZy-Dm_QH-hG5rOaq_ZgsXg@mail.gmail.com>
         <20220505161028.GA492600@bhelgaas>
         <CAK8P3a3fmPExr70+fVb564hZdGAuPtYa-QxgMMe5KLpnY_sTrQ@mail.gmail.com>
         <alpine.DEB.2.21.2205061058540.52331@angie.orcam.me.uk>
         <CAK8P3a0NzG=3tDLCdPj2=A__2r_+xiiUTW=WJCBNp29x_A63Og@mail.gmail.com>
         <alpine.DEB.2.21.2205061314110.52331@angie.orcam.me.uk>
         <CAK8P3a0EMK0gHOmb-jvtfVLb1dun72kYUMKpb11T_GgXiuR9Mw@mail.gmail.com>
In-Reply-To: <CAK8P3a0EMK0gHOmb-jvtfVLb1dun72kYUMKpb11T_GgXiuR9Mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, "Maciej W. Rozycki" <macro@orcam.me.uk>
Cc: Bjorn Helgaas <helgaas@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>

On Fri, 2022-05-06 at 14:53 +0200, Arnd Bergmann wrote:
> On Fri, May 6, 2022 at 2:27 PM Maciej W. Rozycki <macro@orcam.me.uk> wrote:
> > On Fri, 6 May 2022, Arnd Bergmann wrote:
> > 
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
> Not sure. My best guess is that it would actually work as you'd expect,
> but is deliberately left out of the architecture specification so they don't
> have to to validate the correctness.  Note that only a small number of
> PCIe cards are actually supported by IBM, and I think the firmware
> only passes devices to the OS if they are whitelisted.
> 
>         Arnd

Yes, though in Linux we do try hard to work with whatever is plugged
in. We did benefit from this in the past working with a new NIC from a
different vendor with 0 additional changes. Also you can use vfio-pci
to pass-through arbitrary PCI devices to a QEMU emulating s390x.
