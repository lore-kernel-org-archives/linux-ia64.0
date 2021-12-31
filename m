From: Niklas Schnelle <schnelle@linux.ibm.com>
Date: Fri, 31 Dec 2021 11:28:23 +0000
Subject: Re: [RFC 02/32] Kconfig: introduce HAS_IOPORT option and select it as necessary
Message-Id: <072b9080be4a408052bf2c2cc1a9be0089cce5cc.camel@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211227164317.4146918-1-schnelle@linux.ibm.com>
         <20211227164317.4146918-3-schnelle@linux.ibm.com>
         <CAMuHMdXk6VcDryekkMJ3aGFnw4LLWOWMi8M2PwjT81PsOsOBMQ@mail.gmail.com>
         <d406b93a-0f76-d056-3380-65d459d05ea9@gmail.com>
         <CAK8P3a2j-OFUUp+haHoV4PyL-On4EASZ9+59SDqNqmL8Gv_k7Q@mail.gmail.com>
         <1f90f145-219e-1cad-6162-9959d43a27ad@gmail.com>
         <CAK8P3a3NqU-3nUZ9ve=QyPPB5Uep3eK+_hicjjSiP8VuL4FYfA@mail.gmail.com>
         <0211719b-8402-9865-8e5d-5c0a35715816@gmail.com>
In-Reply-To: <0211719b-8402-9865-8e5d-5c0a35715816@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Schmitz <schmitzmic@gmail.com>, Arnd Bergmann <arnd@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Bjorn Helgaas <bhelgaas@google.com>, John Garry <john.garry@huawei.com>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Guo Ren <guoren@kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, Chris Zankel <chris@zankel.net>, Karol Gugala <kgugala@antmicro.com>, Jeff Dike <jdike@addtoit.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Brian Cain <bcain@codeaurora.org>, Heiko Carstens <hca@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-pci@vger.kernel.org, linux-riscv@lists.infradead.org, linux-csky@vger.kernel.org, linux-xtensa@linux-xtensa.org, openrisc@lists.librecores.org, linux-s390@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Greg Ungerer <gerg@linux-m68k.org>

On Thu, 2021-12-30 at 16:44 +1300, Michael Schmitz wrote:
> Hi Arnd,
> 
> Am 30.12.2021 um 14:48 schrieb Arnd Bergmann:
> > On Tue, Dec 28, 2021 at 11:15 PM Michael Schmitz <schmitzmic@gmail.com> wrote:
> > > Am 29.12.2021 um 16:41 schrieb Arnd Bergmann:
> > > > On Tue, Dec 28, 2021 at 8:20 PM Michael Schmitz <schmitzmic@gmail.com> wrote:
---8<---
> 
> > What some other architectures do is to rely on inb()/outb() to have a
> > zero-based offset, and use an io_offset in PCI buses to ensure that a
> > low port number on the bus gets translated into a pointer value for the
> > virtual mapping in the kernel, which is then represented as an unsigned
> > int.
> 
> M54xx does just that for Coldfire:
> 
> arch/m68k/include/asm/io_no.h:
> #define PCI_IO_PA	0xf8000000		/* Host physical address */
> 
> (used to set PCI BAR mappings, so matches your definition above).
> 
> All other (MMU) m68k users of inb()/outb() apply an io_offset in the 
> platform specific address translation:
> 
> 
---8<---
> So as long as support for any of the m68k PCI or ISA bridges is selected 
> in the kernel config, the appropriate IO space mapping is applied. If no 
> support for PCI or ISA bridges is selected, we already fall back to zero 
> offset mapping (but as far as I can tell, it shouldn't be possible to 
> build a kernel without bridge support but drivers that require it).
> 
> > As this is indistinguishable from architectures that just don't have
> > a base address for I/O ports (we unfortunately picked 0 as the default
> > PCI_IOBASE value), my suggestion was to start marking architectures
> > that may have this problem as using HAS_IOPORT in order to keep
> > the existing behavior unchanged. If m68k does not suffer from this,
> > making HAS_IOPORT conditional on those config options that actually
> > need it would of course be best.
> 
> Following your description, HAS_IOPORT would be required for neither of 
> PCI, ISA or ATARI_ROM_ISA ??
> 

No, HAS_IOPORT being set just means that inb() etc. exist and are
functional be it as special instructions like on x86 or via an I/O
address offset. As I understand it if you do have PCI, ISA or
ATARI_ROM_ISA they are functional. If none of them are set and your
zero offset mapping means these accessors can't actually be used you
could make the declerations ifdeffed on CONFIG_HAS_IOPORT to detect the
cases where somone managed to build drivers that require them and that
would result in a compile time error instead of silently, or with a
NULL pointer warning, compiling code that won't work.
