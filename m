From: Niklas Schnelle <schnelle@linux.ibm.com>
Date: Fri, 06 May 2022 11:18:51 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <105ccec439f709846e82b69cb854ac825d7a6a49.camel@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220505195342.GA509942@bhelgaas>
         <22bec167-241f-2cbe-829f-a3f65e40e71@linux-m68k.org>
In-Reply-To: <22bec167-241f-2cbe-829f-a3f65e40e71@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Finn Thain <fthain@linux-m68k.org>, Bjorn Helgaas <helgaas@kernel.org>
Cc: Arnd Bergmann <arnd@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>

On Fri, 2022-05-06 at 19:12 +1000, Finn Thain wrote:
> 
> On Thu, 5 May 2022, Bjorn Helgaas wrote:
> 
> > On Thu, May 05, 2022 at 07:39:42PM +0200, Arnd Bergmann wrote:
> > > On Thu, May 5, 2022 at 6:10 PM Bjorn Helgaas <helgaas@kernel.org> wrote:
> > > > On Wed, May 04, 2022 at 11:31:28PM +0200, Arnd Bergmann wrote:
> > > > > The main goal is to avoid c), which is what happens on s390, but
> > > > > can also happen elsewhere. Catching b) would be nice as well,
> > > > > but is much harder to do from generic code as you'd need an
> > > > > architecture specific inline asm statement to insert a ex_table
> > > > > fixup, or a runtime conditional on each access.
> > > > 
> > > > Or s390 could implement its own inb().
> > > > 
> > > > I'm hearing that generic powerpc kernels have to run both on machines
> > > > that have I/O port space and those that don't.  That makes me think
> > > > s390 could do something similar.
> > > 
> > > No, this is actually the current situation, and it makes absolutely no
> > > sense. s390 has no way of implementing inb()/outb() because there
> > > are no instructions for it and it cannot tunnel them through a virtual
> > > address mapping like on most of the other architectures. (it has special
> > > instructions for accessing memory space, which is not the same as
> > > a pointer dereference here).
> > > 
> > > The existing implementation gets flagged as a NULL pointer dereference
> > > by a compiler warning because it effectively is.
> > 
> > I think s390 currently uses the inb() in asm-generic/io.h, i.e.,
> > "__raw_readb(PCI_IOBASE + addr)".  I understand that's a NULL pointer
> > dereference because the default PCI_IOBASE is 0.
> > 
> > I mooted a s390 inb() implementation like "return ~0" because that's
> > what happens on most arches when there's no device to respond to the
> > inb().
> > 
> > The HAS_IOPORT dependencies are fairly ugly IMHO, and they clutter
> > drivers that use I/O ports in some cases but not others.  But maybe
> > it's the most practical way.
> > 
> 
> Do you mean, "the most practical way to avoid a compiler warning on s390"? 
> What about "#pragma GCC diagnostic ignored"?

This actually happens with clang. Apart from that, I think this would
also fall under the same argument as the original patch Linus unpulled.
We would just paint over someting that we know at compile time won't
work:

https://lore.kernel.org/lkml/CAHk-=wg80je=K7madF4e7WrRNp37e3qh6y10Svhdc7O8SZ_-8g@mail.gmail.com/
