From: Pierre Morel <pmorel@linux.ibm.com>
Date: Tue, 19 Jul 2022 12:02:39 +0000
Subject: Re: [PATCH v3 1/2] asm-generic: Remove pci.h copying remaining code to x86
Message-Id: <38027ee9-bc70-6a2c-202c-1b4d2c9bdc74@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220718004114.3925745-1-shorne@gmail.com>
 <20220718004114.3925745-2-shorne@gmail.com>
In-Reply-To: <20220718004114.3925745-2-shorne@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stafford Horne <shorne@gmail.com>, LKML <linux-kernel@vger.kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Bjorn Helgaas <bhelgaas@google.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Nick Child <nick.child@ibm.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Matthew Rosato <mjrosato@linux.ibm.com>, "Gustavo A. R. Silva" <gustavoars@kernel.org>, Kees Cook <keescook@chromium.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-pci@vger.kernel.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org



On 7/18/22 02:41, Stafford Horne wrote:
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
>   - Remove pci_get_legacy_ide_irq in m68k
> Since v1:
>   - Remove pci_get_legacy_ide_irq for most architectures as its not needed.
> 
>   arch/alpha/include/asm/pci.h   |  1 -
>   arch/ia64/include/asm/pci.h    |  1 -
>   arch/m68k/include/asm/pci.h    |  2 --
>   arch/powerpc/include/asm/pci.h |  1 -
>   arch/s390/include/asm/pci.h    |  1 -
>   arch/sparc/include/asm/pci.h   |  9 ---------
>   arch/x86/include/asm/pci.h     |  6 ++++--
>   arch/xtensa/include/asm/pci.h  |  3 ---
>   include/asm-generic/pci.h      | 17 -----------------
>   9 files changed, 4 insertions(+), 37 deletions(-)
>   delete mode 100644 include/asm-generic/pci.h
> 
> diff --git a/arch/alpha/include/asm/pci.h b/arch/alpha/include/asm/pci.h
> index cf6bc1e64d66..8ac5af0fc4da 100644
> --- a/arch/alpha/include/asm/pci.h
> +++ b/arch/alpha/include/asm/pci.h
> @@ -56,7 +56,6 @@ struct pci_controller {
>   
>   /* IOMMU controls.  */
>   
> -/* TODO: integrate with include/asm-generic/pci.h ? */
>   static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
>   {
>   	return channel ? 15 : 14;
> diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
> index 8c163d1d0189..218412d963c2 100644
> --- a/arch/ia64/include/asm/pci.h
> +++ b/arch/ia64/include/asm/pci.h
> @@ -63,7 +63,6 @@ static inline int pci_proc_domain(struct pci_bus *bus)
>   	return (pci_domain_nr(bus) != 0);
>   }
>   
> -#define HAVE_ARCH_PCI_GET_LEGACY_IDE_IRQ
>   static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
>   {
>   	return channel ? isa_irq_to_vector(15) : isa_irq_to_vector(14);
> diff --git a/arch/m68k/include/asm/pci.h b/arch/m68k/include/asm/pci.h
> index 5a4bc223743b..ccdfa0dc8413 100644
> --- a/arch/m68k/include/asm/pci.h
> +++ b/arch/m68k/include/asm/pci.h
> @@ -2,8 +2,6 @@
>   #ifndef _ASM_M68K_PCI_H
>   #define _ASM_M68K_PCI_H
>   
> -#include <asm-generic/pci.h>
> -
>   #define	pcibios_assign_all_busses()	1
>   
>   #define	PCIBIOS_MIN_IO		0x00000100
> diff --git a/arch/powerpc/include/asm/pci.h b/arch/powerpc/include/asm/pci.h
> index 915d6ee4b40a..f9da506751bb 100644
> --- a/arch/powerpc/include/asm/pci.h
> +++ b/arch/powerpc/include/asm/pci.h
> @@ -39,7 +39,6 @@
>   #define pcibios_assign_all_busses() \
>   	(pci_has_flag(PCI_REASSIGN_ALL_BUS))
>   
> -#define HAVE_ARCH_PCI_GET_LEGACY_IDE_IRQ
>   static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
>   {
>   	if (ppc_md.pci_get_legacy_ide_irq)
> diff --git a/arch/s390/include/asm/pci.h b/arch/s390/include/asm/pci.h
> index fdb9745ee998..5889ddcbc374 100644
> --- a/arch/s390/include/asm/pci.h
> +++ b/arch/s390/include/asm/pci.h
> @@ -6,7 +6,6 @@
>   #include <linux/mutex.h>
>   #include <linux/iommu.h>
>   #include <linux/pci_hotplug.h>
> -#include <asm-generic/pci.h>
>   #include <asm/pci_clp.h>
>   #include <asm/pci_debug.h>
>   #include <asm/sclp.h>

Did not notice any problem for S390.

Acked-by: Pierre Morel <pmorel@linux.ibm.com>



-- 
Pierre Morel
IBM Lab Boeblingen
