From: Arnd Bergmann <arnd@kernel.org>
Date: Sat, 07 May 2022 13:14:16 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <CAK8P3a3tds8O+Gg2nF3MfrVVcmtLbtdQ2TnCJaDYz28cyhhWkg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220505195342.GA509942@bhelgaas> <22bec167-241f-2cbe-829f-a3f65e40e71@linux-m68k.org>
 <105ccec439f709846e82b69cb854ac825d7a6a49.camel@linux.ibm.com> <7dfa7578-039-e132-c573-ad89bd3215@linux-m68k.org>
In-Reply-To: <7dfa7578-039-e132-c573-ad89bd3215@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Finn Thain <fthain@linux-m68k.org>
Cc: Niklas Schnelle <schnelle@linux.ibm.com>, Bjorn Helgaas <helgaas@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>

On Sat, May 7, 2022 at 2:01 AM Finn Thain <fthain@linux-m68k.org> wrote:
> On Fri, 6 May 2022, Niklas Schnelle wrote:
> > On Fri, 2022-05-06 at 19:12 +1000, Finn Thain wrote:
> > > On Thu, 5 May 2022, Bjorn Helgaas wrote:
> > > >
> > > > I mooted a s390 inb() implementation like "return ~0" because that's
> > > > what happens on most arches when there's no device to respond to the
> > > > inb().
> > > >
> > > > The HAS_IOPORT dependencies are fairly ugly IMHO, and they clutter
> > > > drivers that use I/O ports in some cases but not others.  But maybe
> > > > it's the most practical way.
> > > >
> > >
> > > Do you mean, "the most practical way to avoid a compiler warning on
> > > s390"? What about "#pragma GCC diagnostic ignored"?
> >
> > This actually happens with clang.
>
> That suggests a clang bug to me. If you believe GCC should behave like
> clang, then I guess the pragma above really is the one you want. If you
> somehow feel that the kernel should cater to gcc and clang even where they
> disagree then you would have to use "#pragma clang diagnostic ignored".

I don't see how you can blame the compiler for this. On architectures
with a zero PCI_IOBASE, an inb(0x2f8) literally becomes

        var = *(u8*)((NULL + 0x2f8);

If you run a driver that does this, the kernel gets a page fault for
the NULL page
and reports an Oops. clang tells you 'warning: performing pointer
arithmetic on a null pointer has undefined behavior', which is not exactly
spot on, but close enough to warn you that you probably shouldn't do this. gcc
doesn't warn here, but it does warn about an array out-of-bounds access when
you pass such a pointer into memcpy or another string function.

> > Apart from that, I think this would also fall under the same argument as
> > the original patch Linus unpulled. We would just paint over someting
> > that we know at compile time won't work:
> >
> > https://lore.kernel.org/lkml/CAHk-=wg80je=K7madF4e7WrRNp37e3qh6y10Svhdc7O8SZ_-8g@mail.gmail.com/
> >
>
> I wasn't advocating adding any warnings.
>
> If you know at compile time that a driver won't work, the usual solution
> is scripts/config -d CONFIG_SOME_UNDESIRED_DRIVER. Why is that no
> longer appropriate for drivers that use IO ports?

This was never an option, we rely on 'make allmodconfig' to build without
warnings on all architectures for finding regressions. Any driver that depends
on architecture specific interfaces must not get selected on architectures that
don't have those interfaces.

         Arnd
