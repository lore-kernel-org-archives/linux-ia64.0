From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 18 Jul 2022 08:22:13 +0000
Subject: Re: [PATCH v3 1/2] asm-generic: Remove pci.h copying remaining code to x86
Message-Id: <CAMuHMdVP=1ovo62oXaOXT4ipA9Qb61XQ1e4XVVi1gEi+s+wtTQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220718004114.3925745-1-shorne@gmail.com> <20220718004114.3925745-2-shorne@gmail.com>
In-Reply-To: <20220718004114.3925745-2-shorne@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stafford Horne <shorne@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Bjorn Helgaas <bhelgaas@google.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Nick Child <nick.child@ibm.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Matthew Rosato <mjrosato@linux.ibm.com>, Pierre Morel <pmorel@linux.ibm.com>, "Gustavo A. R. Silva" <gustavoars@kernel.org>, Kees Cook <keescook@chromium.org>, alpha <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, linux-pci <linux-pci@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>

On Mon, Jul 18, 2022 at 2:41 AM Stafford Horne <shorne@gmail.com> wrote:
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
> ---
> Since v2:
>  - Remove pci_get_legacy_ide_irq in m68k
> Since v1:
>  - Remove pci_get_legacy_ide_irq for most architectures as its not needed.

>  arch/m68k/include/asm/pci.h    |  2 --

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
