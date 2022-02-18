From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 18 Feb 2022 09:00:39 +0000
Subject: Re: [PATCH v2 10/18] m68k: fix access_ok for coldfire
Message-Id: <CAMuHMdWMhP5WgZ7CvOz53SyfizaAvLkHbeuds8G+_nZkwzhWWw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org> <20220216131332.1489939-11-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-11-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Linux-Arch <linux-arch@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Dinh Nguyen <dinguyen@kernel.org>, Stafford Horne <shorne@gmail.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Heiko Carstens <hca@linux.ibm.com>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, the arch/x86 maintainers <x86@kernel.org>, Max Filippov <jcmvbkbc@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, alpha <linux-alpha@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, linux-csky@vger.kernel.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Openrisc <openrisc@lists.librecores.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv <linux-riscv@lists.infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

Hi Arnd,

On Wed, Feb 16, 2022 at 2:17 PM Arnd Bergmann <arnd@kernel.org> wrote:
> From: Arnd Bergmann <arnd@arndb.de>
>
> While most m68k platforms use separate address spaces for user
> and kernel space, at least coldfire does not, and the other
> ones have a TASK_SIZE that is less than the entire 4GB address
> range.
>
> Using the default implementation of __access_ok() stops coldfire
> user space from trivially accessing kernel memory.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks for your patch!

> --- a/arch/m68k/include/asm/uaccess.h
> +++ b/arch/m68k/include/asm/uaccess.h
> @@ -12,14 +12,21 @@
>  #include <asm/extable.h>
>
>  /* We let the MMU do all checking */
> -static inline int access_ok(const void __user *addr,
> +static inline int access_ok(const void __user *ptr,
>                             unsigned long size)
>  {
> +       unsigned long limit = TASK_SIZE;
> +       unsigned long addr = (unsigned long)ptr;
> +
>         /*
>          * XXX: for !CONFIG_CPU_HAS_ADDRESS_SPACES this really needs to check
>          * for TASK_SIZE!
> +        * Removing this helper is probably sufficient.
>          */

Shouldn't the above comment block be removed completely,
as this is now implemented below?

> -       return 1;
> +       if (IS_ENABLED(CONFIG_CPU_HAS_ADDRESS_SPACES))
> +               return 1;
> +
> +       return (size <= limit) && (addr <= (limit - size));
>  }

Any pesky compilers that warn (or worse with -Werror) about
"condition always true" for TASK_SIZE = 0xFFFFFFFFUL?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
