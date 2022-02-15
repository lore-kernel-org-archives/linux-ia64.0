From: Ard Biesheuvel <ardb@kernel.org>
Date: Tue, 15 Feb 2022 09:21:16 +0000
Subject: Re: [PATCH 08/14] arm64: simplify access_ok()
Message-Id: <CAMj1kXGkG0KMD2rnKAJc3V7X9LP1grbcHTNYMnj_q4GiYfG2pQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org> <20220214163452.1568807-9-arnd@kernel.org>
 <CAMj1kXHixUFjV=4m3tzfGz7AiRWc-VczymbKuZq7dyZZNuLKxQ@mail.gmail.com> <CAK8P3a2VfvDkueaJNTA9SiB+PFsi_Q17AX+aL46ueooW2ahmQw@mail.gmail.com>
In-Reply-To: <CAK8P3a2VfvDkueaJNTA9SiB+PFsi_Q17AX+aL46ueooW2ahmQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch <linux-arch@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Dinh Nguyen <dinguyen@kernel.org>, Stafford Horne <shorne@gmail.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Heiko Carstens <hca@linux.ibm.com>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, X86 ML <x86@kernel.org>, Max Filippov <jcmvbkbc@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-csky@vger.kernel.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:MIPS" <linux-mips@vger.kernel.org>, Openrisc <openrisc@lists.librecores.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-riscv <linux-riscv@lists.infradead.org>, "open list:S390" <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, "open list:SPARC + UltraSPARC (sparc/sparc64)" <sparclinux@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Robin Murphy <robin.murphy@arm.com>

On Tue, 15 Feb 2022 at 10:13, Arnd Bergmann <arnd@kernel.org> wrote:
>
> On Tue, Feb 15, 2022 at 9:17 AM Ard Biesheuvel <ardb@kernel.org> wrote:
> > On Mon, 14 Feb 2022 at 17:37, Arnd Bergmann <arnd@kernel.org> wrote:
> > > From: Arnd Bergmann <arnd@arndb.de>
> > >
> >
> > With set_fs() out of the picture, wouldn't it be sufficient to check
> > that bit #55 is clear? (the bit that selects between TTBR0 and TTBR1)
> > That would also remove the need to strip the tag from the address.
> >
> > Something like
> >
> >     asm goto("tbnz  %0, #55, %2     \n"
> >              "tbnz  %1, #55, %2     \n"
> >              :: "r"(addr), "r"(addr + size - 1) :: notok);
> >     return 1;
> > notok:
> >     return 0;
> >
> > with an additional sanity check on the size which the compiler could
> > eliminate for compile-time constant values.
>
> That should work, but I don't see it as a clear enough advantage to
> have a custom implementation. For the constant-size case, it probably
> isn't better than a compiler-scheduled comparison against a
> constant limit, but it does hurt maintainability when the next person
> wants to change the behavior of access_ok() globally.
>

arm64 also has this leading up to the range check, and I think we'd no
longer need it:

    if (IS_ENABLED(CONFIG_ARM64_TAGGED_ADDR_ABI) &&
        (current->flags & PF_KTHREAD || test_thread_flag(TIF_TAGGED_ADDR)))
            addr = untagged_addr(addr);

> If we want to get into micro-optimizing uaccess, I think a better target
> would be a CONFIG_CC_HAS_ASM_GOTO_OUTPUT version
> of __get_user()/__put_user as we have on x86 and powerpc.
>
>          Arnd
