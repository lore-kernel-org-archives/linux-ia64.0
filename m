From: Mauro Carvalho Chehab <mchehab@kernel.org>
Date: Tue, 28 Dec 2021 16:32:02 +0000
Subject: Re: [RFC 02/32] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <20211228173202.678baa44@coco.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211227164317.4146918-1-schnelle@linux.ibm.com>
        <20211227164317.4146918-3-schnelle@linux.ibm.com>
In-Reply-To: <20211227164317.4146918-3-schnelle@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Niklas Schnelle <schnelle@linux.ibm.com>
Cc: Arnd Bergmann <arnd@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, John Garry <john.garry@huawei.com>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Guo Ren <guoren@kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, Chris Zankel <chris@zankel.net>, Karol Gugala <kgugala@antmicro.com>, Jeff Dike <jdike@addtoit.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Brian Cain <bcain@codeaurora.org>, Heiko Carstens <hca@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-pci@vger.kernel.org, linux-riscv@lists.infradead.org, linux-csky@vger.kernel.org, linux-xtensa@linux-xtensa.org, openrisc@lists.librecores.org, linux-s390@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

Em Mon, 27 Dec 2021 17:42:47 +0100
Niklas Schnelle <schnelle@linux.ibm.com> escreveu:

> We introduce a new HAS_IOPORT Kconfig option to gate support for
> I/O port access. In a future patch HAS_IOPORT=n will disable compilation
> of the I/O accessor functions inb()/outb() and friends on architectures
> which can not meaningfully support legacy I/O spaces. On these platforms
> inb()/outb() etc are currently just stubs in asm-generic/io.h which when
> called will cause a NULL pointer access which some compilers actually
> detect and warn about.
> 
> The dependencies on HAS_IOPORT in drivers as well as ifdefs for
> HAS_IOPORT specific sections will be added in subsequent patches on
> a per subsystem basis. Then a final patch will ifdef the I/O access
> functions on HAS_IOPORT thus turning any use not gated by HAS_IOPORT
> into a compile-time warning.
> 
> Link: https://lore.kernel.org/lkml/CAHk-=wg80je=K7madF4e7WrRNp37e3qh6y10Svhdc7O8SZ_-8g@mail.gmail.com/
> Co-developed-by: Arnd Bergmann <arnd@kernel.org>
> Signed-off-by: Arnd Bergmann <arnd@kernel.org>
> Signed-off-by: Niklas Schnelle <schnelle@linux.ibm.com>

...

> @@ -486,6 +487,9 @@ config HAS_IOMEM
>  	depends on !NO_IOMEM
>  	default y
>  
> +config HAS_IOPORT
> +	def_bool ISA || LEGACY_PCI
> +

That doesn't sound right. 

The only dependency for LEGACY_PCI is PCI. If one selects LEGACY_PCI
on an architecture that doesn't support it, this will cause problems.

Instead, HAS_IOPORT should be selected at architecture level, and
the dependency here should be just the opposite: LEGACY_API should
depends on HAS_IOPORT.

Thanks,
Mauro
