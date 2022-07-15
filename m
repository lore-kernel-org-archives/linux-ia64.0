From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 15 Jul 2022 07:40:10 +0000
Subject: Re: [RFC PATCH 1/2] asm-generic: Remove pci.h copying code out to architectures
Message-Id: <CAK8P3a3S5crDdUcO0kAgOLVGYgXnkU9D3uo44Wrcu5LdAWCGoQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220714214657.2402250-1-shorne@gmail.com> <20220714214657.2402250-2-shorne@gmail.com>
 <CAMo8BfKkGRHiFq1vu1ZKkURkUqC+Ee7D42yuKrCeDF+578s9cw@mail.gmail.com>
In-Reply-To: <CAMo8BfKkGRHiFq1vu1ZKkURkUqC+Ee7D42yuKrCeDF+578s9cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: Stafford Horne <shorne@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Bjorn Helgaas <bhelgaas@google.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Nick Child <nick.child@ibm.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Matthew Rosato <mjrosato@linux.ibm.com>, Pierre Morel <pmorel@linux.ibm.com>, Kees Cook <keescook@chromium.org>, "Gustavo A. R. Silva" <gustavoars@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "open list:IA64 (Itanium) PL..." <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, "open list:SPARC + UltraSPAR..." <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linux-pci <linux-pci@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>

On Fri, Jul 15, 2022 at 3:45 AM Max Filippov <jcmvbkbc@gmail.com> wrote:
> On Thu, Jul 14, 2022 at 2:47 PM Stafford Horne <shorne@gmail.com> wrote:
>
> > +static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
> > +{
> > +       return channel ? 15 : 14;
> > +}
>
> This addition does not make sense for the xtensa as it isn't even possible
> to enable PNP support (the only user of this function) on xtensa.

Nice catch! I had looked at this function earlier and only tried to infer
which architectures might have this based on who has those interrupt
numbers reserved for ISA devices, but looking at CONFIG_PNP is clearly
better here.

PNP depends on "ISA || ACPI", and this already rules out most
architectures. The remaining ones are:

* x86, ia64, alpha: These clearly use PNP based on-board devices on
   common machines, and use PC-style interrupts

* arm64, loongarch: These select PNP when ACPI is enabled. I don't
   think they actually use PNP, but for the moment the function needs to
  be defined, probably returning 0. Loongarch still lacks PCI support
  though, so asm/pci.h is not yet there.

* arm, mips, powerpc: Only a few older machines in each of these
  support ISA devices, and the function is probably machine specific.
  These all have a custom pci.h already and don't use the asm-generic
  version.

* m68k: there are two that enable CONFIG_ISA and one that enables
  CONFIG_PCI, but nothing that has both, so we don't need this
  function.

In summary, I think only x86 actually uses this function, and it is
correct there, everything else either has its own implementation
or does not need it, so the existing asm-generic/pci.h file can
just be folded into the x86 asm/pci.h. That is a great cleanup.

        Arnd
