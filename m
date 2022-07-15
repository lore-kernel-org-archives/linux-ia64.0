From: Max Filippov <jcmvbkbc@gmail.com>
Date: Fri, 15 Jul 2022 01:45:27 +0000
Subject: Re: [RFC PATCH 1/2] asm-generic: Remove pci.h copying code out to architectures
Message-Id: <CAMo8BfKkGRHiFq1vu1ZKkURkUqC+Ee7D42yuKrCeDF+578s9cw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220714214657.2402250-1-shorne@gmail.com> <20220714214657.2402250-2-shorne@gmail.com>
In-Reply-To: <20220714214657.2402250-2-shorne@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stafford Horne <shorne@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Bjorn Helgaas <bhelgaas@google.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Nick Child <nick.child@ibm.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Matthew Rosato <mjrosato@linux.ibm.com>, Pierre Morel <pmorel@linux.ibm.com>, Kees Cook <keescook@chromium.org>, "Gustavo A. R. Silva" <gustavoars@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "open list:IA64 (Itanium) PL..." <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, linuxppc-dev@lists.ozlabs.org, linux-s390 <linux-s390@vger.kernel.org>, "open list:SPARC + UltraSPAR..." <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linux-pci@vger.kernel.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>

On Thu, Jul 14, 2022 at 2:47 PM Stafford Horne <shorne@gmail.com> wrote:
>
> The generic pci.h header provides a definition of pci_get_legacy_ide_irq
> which is used by architectures that use PC-style interrupt numbers.
>
> This patch removes the old pci.h in order to make room for a new
> pci.h to be used by arm64, riscv, openrisc, etc.
>
> The existing code in pci.h is moved out to architectures.
>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Link: https://lore.kernel.org/lkml/CAK8P3a0JmPeczfmMBE__vn=Jbvf=nkbpVaZCycyv40pZNCJJXQ@mail.gmail.com/
> Signed-off-by: Stafford Horne <shorne@gmail.com>
> ---
>  arch/alpha/include/asm/pci.h   |  1 -
>  arch/ia64/include/asm/pci.h    |  1 -
>  arch/m68k/include/asm/pci.h    |  7 +++++--
>  arch/powerpc/include/asm/pci.h |  1 -
>  arch/s390/include/asm/pci.h    |  6 +++++-
>  arch/sparc/include/asm/pci.h   |  5 ++++-
>  arch/x86/include/asm/pci.h     |  6 ++++--
>  arch/xtensa/include/asm/pci.h  |  6 ++++--
>  include/asm-generic/pci.h      | 17 -----------------
>  9 files changed, 22 insertions(+), 28 deletions(-)
>  delete mode 100644 include/asm-generic/pci.h

[...]

> diff --git a/arch/xtensa/include/asm/pci.h b/arch/xtensa/include/asm/pci.h
> index 8e2b48a268db..f57ede61f5db 100644
> --- a/arch/xtensa/include/asm/pci.h
> +++ b/arch/xtensa/include/asm/pci.h
> @@ -43,7 +43,9 @@
>  #define ARCH_GENERIC_PCI_MMAP_RESOURCE 1
>  #define arch_can_pci_mmap_io()         1
>
> -/* Generic PCI */
> -#include <asm-generic/pci.h>

Ok.

> +static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
> +{
> +       return channel ? 15 : 14;
> +}

This addition does not make sense for the xtensa as it isn't even possible
to enable PNP support (the only user of this function) on xtensa.

-- 
Thanks.
-- Max
