From: "Maciej W. Rozycki" <macro@orcam.me.uk>
Date: Sun, 01 May 2022 22:40:39 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <alpine.DEB.2.21.2205012335020.9383@angie.orcam.me.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220429135108.2781579-1-schnelle@linux.ibm.com> <20220429135108.2781579-2-schnelle@linux.ibm.com>
In-Reply-To: <20220429135108.2781579-2-schnelle@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Niklas Schnelle <schnelle@linux.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-pci@vger.kernel.org, Arnd Bergmann <arnd@kernel.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>

On Fri, 29 Apr 2022, Niklas Schnelle wrote:

> We introduce a new HAS_IOPORT Kconfig option to indicate support for
> I/O Port access. In a future patch HAS_IOPORT=n will disable compilation
> of the I/O accessor functions inb()/outb() and friends on architectures
> which can not meaningfully support legacy I/O spaces such as s390 or
> where such support is optional. The "depends on" relations on HAS_IOPORT
> in drivers as well as ifdefs for HAS_IOPORT specific sections will be
> added in subsequent patches on a per subsystem basis.
[...]
> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
> index de3b32a507d2..4c55df08d6f1 100644
> --- a/arch/mips/Kconfig
> +++ b/arch/mips/Kconfig
> @@ -47,6 +47,7 @@ config MIPS
>  	select GENERIC_SMP_IDLE_THREAD
>  	select GENERIC_TIME_VSYSCALL
>  	select GUP_GET_PTE_LOW_HIGH if CPU_MIPS32 && PHYS_ADDR_T_64BIT
> +	select HAS_IOPORT
>  	select HAVE_ARCH_COMPILER_H
>  	select HAVE_ARCH_JUMP_LABEL
>  	select HAVE_ARCH_KGDB if MIPS_FP_SUPPORT

 NAK, not all MIPS systems have the port I/O space, and we have it already 
handled via the NO_IOPORT_MAP option.  We'll need to have HAS_IOPORT set 
to !NO_IOPORT_MAP (or vice versa) for the MIPS architecture.

  Maciej
