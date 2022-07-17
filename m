From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun, 17 Jul 2022 09:23:24 +0000
Subject: Re: [PATCH v2 1/2] asm-generic: Remove pci.h copying remaining code to x86
Message-Id: <CAMuHMdUT6nEft8v30sq0WP49RW2qUn+1sunk+ow2_EEyVEieEQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220717033453.2896843-1-shorne@gmail.com> <20220717033453.2896843-2-shorne@gmail.com>
In-Reply-To: <20220717033453.2896843-2-shorne@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stafford Horne <shorne@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Bjorn Helgaas <bhelgaas@google.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Nick Child <nick.child@ibm.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Matthew Rosato <mjrosato@linux.ibm.com>, Pierre Morel <pmorel@linux.ibm.com>, Kees Cook <keescook@chromium.org>, "Gustavo A. R. Silva" <gustavoars@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linux-pci <linux-pci@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>

Hi Stafford,

On Sun, Jul 17, 2022 at 5:35 AM Stafford Horne <shorne@gmail.com> wrote:
> The generic pci.h header now only provides a definition of
> pci_get_legacy_ide_irq which is used by architectures that support PNP.
> Of the architectures that use asm-generic/pci.h this is only x86.
>
> This patch removes the old pci.h in order to make room for a new
> pci.h to be used by arm64, riscv, openrisc, etc.
>
> The existing code in pci.h is moved out to x86.  On other architectures
> we clean up any outstanding references.
>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Link: https://lore.kernel.org/lkml/CAK8P3a0JmPeczfmMBE__vn=Jbvf=nkbpVaZCycyv40pZNCJJXQ@mail.gmail.com/
> Signed-off-by: Stafford Horne <shorne@gmail.com>

Thanks for your patch!

> --- a/arch/m68k/include/asm/pci.h
> +++ b/arch/m68k/include/asm/pci.h
> @@ -2,11 +2,14 @@
>  #ifndef _ASM_M68K_PCI_H
>  #define _ASM_M68K_PCI_H
>
> -#include <asm-generic/pci.h>
> -
>  #define        pcibios_assign_all_busses()     1
>
>  #define        PCIBIOS_MIN_IO          0x00000100
>  #define        PCIBIOS_MIN_MEM         0x02000000
>
> +static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
> +{
> +       return channel ? 15 : 14;
> +}
> +

I thought you were not going to add this?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
