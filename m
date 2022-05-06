From: John Garry <john.garry@huawei.com>
Date: Fri, 06 May 2022 11:07:26 +0000
Subject: Re: [RFC v2 01/39] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <7b8d7c1a-58c3-4ba9-a4f0-d0e051f3ffdc@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220505195342.GA509942@bhelgaas>
 <157602011a72061dd31f92bd699e8c1f9a81c988.camel@linux.ibm.com>
In-Reply-To: <157602011a72061dd31f92bd699e8c1f9a81c988.camel@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Niklas Schnelle <schnelle@linux.ibm.com>, Bjorn Helgaas <helgaas@kernel.org>, Arnd Bergmann <arnd@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:ALPHA PORT" <linux-alpha@vger.kernel.org>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:M68K ARCHITECTURE" <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:RISC-V ARCHITECTURE" <linux-riscv@lists.infradead.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>

On 06/05/2022 10:38, Niklas Schnelle wrote:
> Another argument I see is that as shown by POWER9 we might start to see
> more platforms that just can't do I/O port access. E.g. I would also be
> surprised if Apple's M1 has I/O port access. Sooner or later I expect
> distributions on some platforms to only support such systems. For
> example on ppc a server distribution might only support IBM POWER
> without I/O port support before too long. Then having HAS_IOPORT allows
> to get rid of drivers that won't work anyway.
> 
> There are also reports of probing a driver with I/O ports causing a
> system crash on systems without I/O port support. For example in this
> answer by John Garry (added so he may supply more information):
> 
> https://lore.kernel.org/lkml/db043b76-880d-5fad-69cf-96abcd9cd34f@huawei.com/
> 
> .

That issue is that drivers like hwmon f71805f use inb/outb accessors 
with hardcoded IO port addresses to probe the driver. On archs like 
arm64 or powerpc - which do not natively support inb et al - this may 
crash the system when no PCI IO space is mapped [0]. Indeed, when PCI IO 
space is mapped, it is preferable these those drivers still would not 
access these ports.

So this series from Niklas could be used as a basis to solve that 
problem, in that we could also introduce something like HARDCODED_IOPORT 
[1] to stop those drivers being built at all for arm64.

[0] 
https://lore.kernel.org/linux-input/20210112055129.7840-1-song.bao.hua@hisilicon.com/T/#mf86445470160c44ac110e9d200b09245169dc5b6
[1] 
https://lore.kernel.org/lkml/CAK8P3a3HHeP+Gw_k2P7Qtig0OmErf0HN30G22+qHic_uZTh11Q@mail.gmail.com/

Thanks,
John
