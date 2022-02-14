From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 14 Feb 2022 19:25:24 +0000
Subject: Re: [PATCH 07/14] uaccess: generalize access_ok()
Message-Id: <CAK8P3a36U35DK22UT6id=WawWaJa-2+_W9HFgmwdDJ_tVYE5NQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org>
 <20220214163452.1568807-8-arnd@kernel.org>
 <YgqOLZbFK7/B2HJT@zeniv-ca.linux.org.uk>
In-Reply-To: <YgqOLZbFK7/B2HJT@zeniv-ca.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Dinh Nguyen <dinguyen@kernel.org>, Stafford Horne <shorne@gmail.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Heiko Carstens <hca@linux.ibm.com>, Rich Felker <dalias@libc.org>, David Miller <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, the arch/x86 maintainers <x86@kernel.org>, Max Filippov <jcmvbkbc@gmail.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-csky@vger.kernel.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Openrisc <openrisc@lists.librecores.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

On Mon, Feb 14, 2022 at 6:15 PM Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On Mon, Feb 14, 2022 at 05:34:45PM +0100, Arnd Bergmann wrote:
>
> > diff --git a/arch/csky/kernel/signal.c b/arch/csky/kernel/signal.c
> > index c7b763d2f526..8867ddf3e6c7 100644
> > --- a/arch/csky/kernel/signal.c
> > +++ b/arch/csky/kernel/signal.c
> > @@ -136,7 +136,7 @@ static inline void __user *get_sigframe(struct ksignal *ksig,
> >  static int
> >  setup_rt_frame(struct ksignal *ksig, sigset_t *set, struct pt_regs *regs)
> >  {
> > -     struct rt_sigframe *frame;
> > +     struct rt_sigframe __user *frame;
> >       int err = 0;
> >
> >       frame = get_sigframe(ksig, regs, sizeof(*frame));
>
> Minor nit: might make sense to separate annotations (here, on nios2, etc.) from the rest...

Done.

> > -}
> > -
> > -static inline int access_ok(const void __user * addr, unsigned long size)
> > -{
> > -     return 1;
> > -}
> > +#define __range_not_ok(addr, size, limit) (!__access_ok(addr, size))
>
> is really wrong.  For sparc64, access_ok() should always be true.
> This __range_not_ok() thing is used *only* for valid_user_frame() in
> arch/sparc/kernel/perf_event.c - it's not a part of normal access_ok()
> there.
>
> sparc64 has separate address spaces for kernel and for userland; access_ok()
> had never been useful there.

Ok, fixed as well now. I had the access_ok() bit right, the definition just
moved around here so it comes before the #include, but I missed the
bit about __range_not_ok(), which I have now reverted back to the
correct version in my tree.

        Arnd
