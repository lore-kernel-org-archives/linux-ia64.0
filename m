From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 10 May 2021 10:16:13 +0000
Subject: Re: [RFC 01/12] asm-generic: use asm-generic/unaligned.h for most architectures
Message-Id: <CAMuHMdV1=mJzbr1cLwo-zUnThh9J8BmdW870dJCvp_Kft8kM2w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210507220813.365382-1-arnd@kernel.org> <20210507220813.365382-2-arnd@kernel.org>
In-Reply-To: <20210507220813.365382-2-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vineet Gupta <vgupta@synopsys.com>, Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Michal Simek <monstr@monstr.eu>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, alpha <linux-alpha@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Parisc List <linux-parisc@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

Hi Arnd,

On Sat, May 8, 2021 at 12:09 AM Arnd Bergmann <arnd@kernel.org> wrote:
> From: Arnd Bergmann <arnd@arndb.de>
>
> There are several architectures that just duplicate the contents
> of asm-generic/unaligned.h, so change those over to use the
> file directly, to make future modifications easier.
>
> The exceptions are:
>
> - arm32 sets HAVE_EFFICIENT_UNALIGNED_ACCESS, but wants the
>   unaligned-struct version
>
> - ppc64le disables HAVE_EFFICIENT_UNALIGNED_ACCESS but includes
>   the access-ok version
>
> - m68k (non-dragonball) also uses the access-ok version without
>   setting HAVE_EFFICIENT_UNALIGNED_ACCESS.

This not only applies to dragonball, which has the CPU32 core, but also
to plain 68000, and any SoCs including the 68EC000 core.

It also applies to early Coldfire, but AFAIK Linux doesn't support these
(see dfe1d26d4a90287e ("m68knommu: Allow ColdFire CPUs to use unaligned
 accesses")).

 > - sh4a has a custom inline asm version
>
> - openrisc is the only one using the memmove version that
>   generally leads to worse code.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

>  arch/m68k/include/asm/unaligned.h       |  9 +-------

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
