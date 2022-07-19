From: Stafford Horne <shorne@gmail.com>
Date: Tue, 19 Jul 2022 10:51:43 +0000
Subject: Re: [PATCH v2 1/2] asm-generic: Remove pci.h copying remaining code to x86
Message-Id: <YtaMv2kfdxFyDsis@antec>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220717033453.2896843-1-shorne@gmail.com>
 <20220717033453.2896843-2-shorne@gmail.com>
 <YtTif+vNq+gkfqsc@infradead.org>
 <CAK8P3a02R651U9Md8DHT33FgSp56Baiw4sNCWCFBPcMi0bB1-g@mail.gmail.com>
In-Reply-To: <CAK8P3a02R651U9Md8DHT33FgSp56Baiw4sNCWCFBPcMi0bB1-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Bjorn Helgaas <bhelgaas@google.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Nick Child <nick.child@ibm.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Matthew Rosato <mjrosato@linux.ibm.com>, Pierre Morel <pmorel@linux.ibm.com>, Kees Cook <keescook@chromium.org>, "Gustavo A. R. Silva" <gustavoars@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linux-pci <linux-pci@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>

On Mon, Jul 18, 2022 at 10:40:34AM +0200, Arnd Bergmann wrote:
> On Mon, Jul 18, 2022 at 6:33 AM Christoph Hellwig <hch@infradead.org> wrote:
> >
> > On Sun, Jul 17, 2022 at 12:34:52PM +0900, Stafford Horne wrote:
> > > The generic pci.h header now only provides a definition of
> > > pci_get_legacy_ide_irq which is used by architectures that support PNP.
> > > Of the architectures that use asm-generic/pci.h this is only x86.
> >
> > Please move this into a separate header, ike legacy-ide.h.  It doens't
> > have anyting to do with actual PCI support.
> 
> It looks like asm/libata-portmap.h is meant to have this information already,
> and this is what libata uses, while drivers/ide used the
> pci_get_legacy_ide_irq()
> function for the same purpose.
> 
> Only ia64 and powerpc have interesting definitions of both, and they
> return the same thing, so I think this is sufficient to remove the last caller:
> 
> diff --git a/drivers/pnp/resource.c b/drivers/pnp/resource.c
> index 2fa0f7d55259..d7a6250589d6 100644
> --- a/drivers/pnp/resource.c
> +++ b/drivers/pnp/resource.c
> @@ -16,7 +16,7 @@
>  #include <asm/io.h>
>  #include <asm/dma.h>
>  #include <asm/irq.h>
> -#include <linux/pci.h>
> +#include <linux/libata.h>
>  #include <linux/ioport.h>
>  #include <linux/init.h>
> 
> @@ -322,8 +322,8 @@ static int pci_dev_uses_irq(struct pnp_dev *pnp,
> struct pci_dev *pci,
>                  * treat the compatibility IRQs as busy.
>                  */
>                 if ((progif & 0x5) != 0x5)
> -                       if (pci_get_legacy_ide_irq(pci, 0) = irq ||
> -                           pci_get_legacy_ide_irq(pci, 1) = irq) {
> +                       if (ATA_PRIMARY_IRQ(pci) = irq ||
> +                           ATA_SECONDARY_IRQ(pci) = irq) {
>                                 pnp_dbg(&pnp->dev, "  legacy IDE device %s "
>                                         "using irq %d\n", pci_name(pci), irq);
>                                 return 1;
> 
> This is fine on the architectures that currently return an error from
> pci_get_legacy_ide_irq() but will change to returning 15/14 instead,
> because they do not support ISA devices, so pci_dev_uses_irq()
> will never be called either.

I like this, I didn't know about the ATA_PRIMARY_IRQ/ATA_SECONDARY_IRQ macro.
Let me add this to the series before 1/2.  I will keep you as the author via
Signed-off-by annotation.

-Stafford
