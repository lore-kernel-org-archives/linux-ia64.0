From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 12 Feb 2020 09:23:07 +0000
Subject: Re: [PATCH v2] asm-generic: Fix unistd_32.h generation format
Message-Id: <CAMuHMdXt1CUqRjOyz9i0uVzQUJJU3UsFGzDaoTBcWVF=qTH48g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <dcdd615f77dacf8a98e18950b66fb5a675277f38.1581498987.git.michal.simek@xilinx.com>
In-Reply-To: <dcdd615f77dacf8a98e18950b66fb5a675277f38.1581498987.git.michal.simek@xilinx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Simek <michal.simek@xilinx.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Simek <monstr@monstr.eu>, git@xilinx.com, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Stefan Asserhall <stefan.asserhall@xilinx.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, alpha <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Parisc List <linux-parisc@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, linux-xtensa@linux-xtensa.org, sparclinux <sparclinux@vger.kernel.org>

Hi Michal,

On Wed, Feb 12, 2020 at 10:16 AM Michal Simek <michal.simek@xilinx.com> wrote:
> Generated files are also checked by sparse that's why add newline
> to remove sparse (C=1) warning.
>
> The issue was found on Microblaze and reported like this:
> ./arch/microblaze/include/generated/uapi/asm/unistd_32.h:438:45:
> warning: no newline at end of file
>
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> Reviewed-by: Stefan Asserhall <stefan.asserhall@xilinx.com>

Thanks for your patch!

>  arch/alpha/kernel/syscalls/syscallhdr.sh      | 1 +
>  arch/ia64/kernel/syscalls/syscallhdr.sh       | 1 +
>  arch/m68k/kernel/syscalls/syscallhdr.sh       | 1 +

Bummer, I had noticed that before
https://lore.kernel.org/lkml/CAMuHMdVsBwL9vcqejfc47GN793wMXdQ=SwEsSUP1fbpMt-OoWw@mail.gmail.com/
and even claimed I fixed it while applying
https://lore.kernel.org/lkml/CAMuHMdW6JiponxLiGNEXUX4xJk3hK4b8dTOCNvVBr7s2LyfhJw@mail.gmail.com/
but something must have gone wrong...

>  arch/microblaze/kernel/syscalls/syscallhdr.sh | 1 +
>  arch/parisc/kernel/syscalls/syscallhdr.sh     | 1 +
>  arch/sh/kernel/syscalls/syscallhdr.sh         | 1 +
>  arch/sparc/kernel/syscalls/syscallhdr.sh      | 1 +
>  arch/xtensa/kernel/syscalls/syscallhdr.sh     | 1 +
>  8 files changed, 8 insertions(+)
>
> diff --git a/arch/alpha/kernel/syscalls/syscallhdr.sh b/arch/alpha/kernel/syscalls/syscallhdr.sh
> index e5b99bd2e5e7..524c69fbcab7 100644
> --- a/arch/alpha/kernel/syscalls/syscallhdr.sh
> +++ b/arch/alpha/kernel/syscalls/syscallhdr.sh
> @@ -33,4 +33,5 @@ grep -E "^[0-9A-Fa-fXx]+[[:space:]]+${my_abis}" "$in" | sort -n | (
>         printf "#endif\n"
>         printf "\n"
>         printf "#endif /* %s */" "${fileguard}"
> +       printf "\n"

Why not add the "\n" to the end of the previous line?

Anyway,
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
