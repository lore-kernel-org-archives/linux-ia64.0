From: Arnd Bergmann <arnd@kernel.org>
Date: Tue, 15 Feb 2022 10:02:10 +0000
Subject: Re: [PATCH 09/14] m68k: drop custom __access_ok()
Message-Id: <CAK8P3a0t-dnJXvXH0Mx5L-AeVQe1mYzRi0sQjYxzMQw-mVPv0Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org> <20220214163452.1568807-10-arnd@kernel.org>
 <Ygr11RGjj3C9uAUg@zeniv-ca.linux.org.uk> <20220215062942.GA12551@lst.de> <YgtSpk0boDjsyjFK@zeniv-ca.linux.org.uk>
In-Reply-To: <YgtSpk0boDjsyjFK@zeniv-ca.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Dinh Nguyen <dinguyen@kernel.org>, Stafford Horne <shorne@gmail.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Heiko Carstens <hca@linux.ibm.com>, Rich Felker <dalias@libc.org>, David Miller <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, the arch/x86 maintainers <x86@kernel.org>, Max Filippov <jcmvbkbc@gmail.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-csky@vger.kernel.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Openrisc <openrisc@lists.librecores.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

On Tue, Feb 15, 2022 at 8:13 AM Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Tue, Feb 15, 2022 at 07:29:42AM +0100, Christoph Hellwig wrote:
> > On Tue, Feb 15, 2022 at 12:37:41AM +0000, Al Viro wrote:
> > > Perhaps simply wrap that sucker into #ifdef CONFIG_CPU_HAS_ADDRESS_SPACES
> > > (and trim the comment down to "coldfire and 68000 will pick generic
> > > variant")?
> >
> > I wonder if we should invert CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE,
> > select the separate address space config for s390, sparc64, non-coldfire
> > m68k and mips with EVA and then just have one single access_ok for
> > overlapping address space (as added by Arnd) and non-overlapping ones
> > (always return true).
>
> parisc is also such...  How about
>
>         select ALTERNATE_SPACE_USERLAND
>
> for that bunch?

Either of those works for me. My current version has this keyed off
TASK_SIZE_MAX=ULONG_MAX, but a CONFIG_ symbol does
look more descriptive.

>  While we are at it, how many unusual access_ok() instances are
> left after this series?  arm64, itanic, um, anything else?

x86 adds a WARN_ON_IN_IRQ() check in there. This could be
made generic, but it's not obvious what exactly the exceptions are
that other architectures need. The arm64 tagged pointers could
probably also get integrated into the generic version.

> FWIW, sparc32 has a slightly unusual instance (see uaccess_32.h there); it's
> obviously cheaper than generic and I wonder if the trick is legitimate (and
> applicable elsewhere, perhaps)...

Right, a few others have the same, but I wasn't convinced that this
is actually safe for call possible cases: it's trivial to construct a caller
that works on other architectures but not this one, if you pass a large
enough size value and don't access the contents in sequence.

Also, like the ((addr | (addr + size)) & MASK) check on some other
architectures, it is less portable because it makes assumptions about
the actual layout beyond a fixed address limit.

        Arnd
