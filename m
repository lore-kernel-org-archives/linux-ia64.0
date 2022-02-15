From: Arnd Bergmann <arnd@kernel.org>
Date: Tue, 15 Feb 2022 08:10:05 +0000
Subject: Re: [PATCH 14/14] uaccess: drop set_fs leftovers
Message-Id: <CAK8P3a1DPxgti+aRVUABQFZz-yT0KNU9QZpB9iGNCPkBHnv_xg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org> <20220214163452.1568807-15-arnd@kernel.org>
 <YgsYD2nW9GjWJtn5@zeniv-ca.linux.org.uk> <215c0ddc-54b1-bcb1-c5aa-bd17c6b100a8@gmx.de>
In-Reply-To: <215c0ddc-54b1-bcb1-c5aa-bd17c6b100a8@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Helge Deller <deller@gmx.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Dinh Nguyen <dinguyen@kernel.org>, Stafford Horne <shorne@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Heiko Carstens <hca@linux.ibm.com>, Rich Felker <dalias@libc.org>, David Miller <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, the arch/x86 maintainers <x86@kernel.org>, Max Filippov <jcmvbkbc@gmail.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-csky@vger.kernel.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Openrisc <openrisc@lists.librecores.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

On Tue, Feb 15, 2022 at 8:46 AM Helge Deller <deller@gmx.de> wrote:
>
> On 2/15/22 04:03, Al Viro wrote:
> > On Mon, Feb 14, 2022 at 05:34:52PM +0100, Arnd Bergmann wrote:
> >> diff --git a/arch/parisc/include/asm/futex.h b/arch/parisc/include/asm/futex.h
> >> index b5835325d44b..2f4a1b1ef387 100644
> >> --- a/arch/parisc/include/asm/futex.h
> >> +++ b/arch/parisc/include/asm/futex.h
> >> @@ -99,7 +99,7 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
> >>      /* futex.c wants to do a cmpxchg_inatomic on kernel NULL, which is
> >>       * our gateway page, and causes no end of trouble...
> >>       */
> >> -    if (uaccess_kernel() && !uaddr)
> >> +    if (!uaddr)
> >>              return -EFAULT;
> >
> >       Huh?  uaccess_kernel() is removed since it becomes always false now,
> > so this looks odd.
> >
> >       AFAICS, the comment above that check refers to futex_detect_cmpxchg()
> > -> cmpxchg_futex_value_locked() -> futex_atomic_cmpxchg_inatomic() call chain.
> > Which had been gone since commit 3297481d688a (futex: Remove futex_cmpxchg
> > detection).  The comment *and* the check should've been killed off back
> > then.
> >       Let's make sure to get both now...
>
> Right. Arnd, can you drop this if() and the comment above it?

Done.

       Arnd
