From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 17 Feb 2022 08:13:43 +0000
Subject: Re: [PATCH v2 00/18] clean up asm/uaccess.h, kill set_fs for good
Message-Id: <CAK8P3a3QBWDYjr6VpPdjTBGFg88DdH3SHVgxEowgScgJOkNguQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Dinh Nguyen <dinguyen@kernel.org>, Stafford Horne <shorne@gmail.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Heiko Carstens <hca@linux.ibm.com>, Rich Felker <dalias@libc.org>, David Miller <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, the arch/x86 maintainers <x86@kernel.org>, Max Filippov <jcmvbkbc@gmail.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, linux-csky@vger.kernel.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Openrisc <openrisc@lists.librecores.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

On Wed, Feb 16, 2022 at 2:13 PM Arnd Bergmann <arnd@kernel.org> wrote:
>
> From: Arnd Bergmann <arnd@arndb.de>
>
> Christoph Hellwig and a few others spent a huge effort on removing
> set_fs() from most of the important architectures, but about half the
> other architectures were never completed even though most of them don't
> actually use set_fs() at all.
>
> I did a patch for microblaze at some point, which turned out to be fairly
> generic, and now ported it to most other architectures, using new generic
> implementations of access_ok() and __{get,put}_kernel_nocheck().
>
> Three architectures (sparc64, ia64, and sh) needed some extra work,
> which I also completed.
>
> The final series contains extra cleanup changes that touch all
> architectures. Please review and test these, so we can merge them
> for v5.18.
>
> The series is available at
> https://git.kernel.org/pub/scm/linux/kernel/git/arnd/playground.git/log/?h=set_fs-2
> for testing.

I've added the updated contents to my asm-generic tree now to put them
into linux-next.

         Arnd
