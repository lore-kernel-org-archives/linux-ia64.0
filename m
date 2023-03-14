From: "Arnd Bergmann" <arnd@arndb.de>
Date: Tue, 14 Mar 2023 13:29:18 +0000
Subject: Re: [PATCH v3 01/38] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <f8bdc245-38b0-4973-bd01-34f594a0ede4@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230314121216.413434-1-schnelle@linux.ibm.com>
 <20230314121216.413434-2-schnelle@linux.ibm.com>
In-Reply-To: <20230314121216.413434-2-schnelle@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Niklas Schnelle <schnelle@linux.ibm.com>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S . Miller" <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, =?UTF-8?Q?Uwe_Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Alan Stern <stern@rowland.harvard.edu>, "Rafael J . Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-pci@vger.kernel.org, Arnd Bergmann <arnd@kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org

On Tue, Mar 14, 2023, at 13:11, Niklas Schnelle wrote:
> We introduce a new HAS_IOPORT Kconfig option to indicate support for I/O
> Port access. In a future patch HAS_IOPORT=n will disable compilation of
> the I/O accessor functions inb()/outb() and friends on architectures
> which can not meaningfully support legacy I/O spaces such as s390. Also
> add dependencies on HAS_IOPORT for the ISA and HAVE_EISA config options
> as these busses always go along with HAS_IOPORT.
>
> The "depends on" relations on HAS_IOPORT in drivers as well as ifdefs
> for HAS_IOPORT specific sections will be added in subsequent patches on
> a per subsystem basis.

I think it would be helpful to enumerate which architectures
do not get HAS_IOPORT added, as they will be affected more.

> Co-developed-by: Arnd Bergmann <arnd@kernel.org>
> Signed-off-by: Niklas Schnelle <schnelle@linux.ibm.com>

If there are no objections, I could send this first patch for the
asm-generic tree as a preparation for 6.3, so we are able to merge
the other patches through subsystem maintainer tree for 6.4.

arch/loongarch/ will now also need to select HAS_IOPORT
uncontitionally, this architecture was added after you
sent v2.

> diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
> index a98940e64243..5eeacc72e4da 100644
> --- a/arch/parisc/Kconfig
> +++ b/arch/parisc/Kconfig
> @@ -47,6 +47,7 @@ config PARISC
>  	select MODULES_USE_ELF_RELA
>  	select CLONE_BACKWARDS
>  	select TTY # Needed for pdc_cons.c
> +	select HAS_IOPORT if PCI

It's also needed for EISA and I think you should select it
from CONFIG_GSC in drivers/parisc/Kconfig for this purpose.

This could also be 'select HAS_IOPORT if PCI || EISA', but
that would require removing the 'depends on HAS_IOPORT'
under drivers/eisa/.

>  	select HAVE_DEBUG_STACKOVERFLOW
>  	select HAVE_ARCH_AUDITSYSCALL
>  	select HAVE_ARCH_HASH
> @@ -131,6 +132,7 @@ config STACKTRACE_SUPPORT
> 
>  config ISA_DMA_API
>  	bool
> +	depends on HAS_IOPORT
> 

This line is not really needed since there is no way to
enable ISA_DMA_API.

> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index a6c4407d3ec8..f7de646c074a 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -188,6 +188,7 @@ config PPC
>  	select GENERIC_SMP_IDLE_THREAD
>  	select GENERIC_TIME_VSYSCALL
>  	select GENERIC_VDSO_TIME_NS
> +	select HAS_IOPORT			if PCI
>  	select HAVE_ARCH_AUDITSYSCALL
>  	select HAVE_ARCH_HUGE_VMALLOC		if HAVE_ARCH_HUGE_VMAP
>  	select HAVE_ARCH_HUGE_VMAP		if PPC_RADIX_MMU || PPC_8xx
> @@ -1070,7 +1071,6 @@ menu "Bus options"
> 
>  config ISA
>  	bool "Support for ISA-bus hardware"
> -	depends on PPC_CHRP
>  	select PPC_I8259
>  	help
>  	  Find out whether you have ISA slots on your motherboard.  ISA is the

This line looks wrong, I think we should keep that dependency.
Did you get a circular dependency if you leave it in?

> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index a825bf031f49..634dd42532f3 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -162,6 +162,7 @@ config X86
>  	select GUP_GET_PXX_LOW_HIGH		if X86_PAE
>  	select HARDIRQS_SW_RESEND
>  	select HARDLOCKUP_CHECK_TIMESTAMP	if X86_64
> +	select HAS_IOPORT
>  	select HAVE_ACPI_APEI			if ACPI
>  	select HAVE_ACPI_APEI_NMI		if ACPI
>  	select HAVE_ALIGNED_STRUCT_PAGE		if SLUB
> @@ -2893,6 +2894,7 @@ if X86_32
> 
>  config ISA
>  	bool "ISA support"
> +	depends on HAS_IOPORT
>  	help

HAS_IOPORT is selected unconditionally already, so this doesn't
really do anything.

> diff --git a/lib/Kconfig.kgdb b/lib/Kconfig.kgdb
> index 3b9a44008433..c68e4d9dcecb 100644
> --- a/lib/Kconfig.kgdb
> +++ b/lib/Kconfig.kgdb
> @@ -121,7 +121,8 @@ config KDB_DEFAULT_ENABLE
> 
>  config KDB_KEYBOARD
>  	bool "KGDB_KDB: keyboard as input device"
> -	depends on VT && KGDB_KDB && !PARISC
> +	depends on HAS_IOPORT
> +	depends on VT && KGDB_KDB
>  	default n

This loses the !PARISC dependency, which I don't think is
intentional. The added HAS_IOPORT dependency makes sense
here, but I think this should be in a different patch
and not in the preparation.

    Arnd
