From: Finn Thain <fthain@linux-m68k.org>
Date: Sun, 08 May 2022 00:15:31 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <e01fac8a-7568-14b6-84-affc4a40c6d@linux-m68k.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220505195342.GA509942@bhelgaas> <22bec167-241f-2cbe-829f-a3f65e40e71@linux-m68k.org> <105ccec439f709846e82b69cb854ac825d7a6a49.camel@linux.ibm.com> <7dfa7578-039-e132-c573-ad89bd3215@linux-m68k.org> <CAK8P3a3tds8O+Gg2nF3MfrVVcmtLbtdQ2TnCJaDYz28cyhhWkg@mail.gmail.com>
 <6f33385-5612-7042-e1b3-aa32895e91e0@linux-m68k.org>
In-Reply-To: <6f33385-5612-7042-e1b3-aa32895e91e0@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Niklas Schnelle <schnelle@linux.ibm.com>, Bjorn Helgaas <helgaas@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>


On Sun, 8 May 2022, I wrote:

> 
> That suggests to me that we need a "bool CONFIG_WARINGS_INTO_ERRORS" to 
> control -Werror, which could be disabled for .config files (like make 
> allmodconfig) where it is not helping.
> 

I just noticed that we already have CONFIG_WERROR. So perhaps something 
like this would help.

diff --git a/init/Kconfig b/init/Kconfig
index ddcbefe535e9..765d83fb148e 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -150,6 +150,8 @@ config WERROR
 
 	  However, if you have a new (or very old) compiler with odd and
 	  unusual warnings, or you have some architecture with problems,
+	  or if you are using a compiler that doesn't happen to interpret
+	  the C standards in quite the same way as some other compilers,
 	  you may need to disable this config option in order to
 	  successfully build the kernel.
 
