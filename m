From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 28 Dec 2020 09:40:53 +0000
Subject: Re: Build regressions/improvements in v5.11-rc1
Message-Id: <CAMuHMdURjQ0pTaOoj1zQEz6_Z4F0X6zxqskmo=_AppTapUkY6A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201228093636.893535-1-geert@linux-m68k.org>
In-Reply-To: <20201228093636.893535-1-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Mike Rapoport <rppt@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Mon, Dec 28, 2020 at 10:38 AM Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> Below is the list of build error/warning regressions/improvements in
> v5.11-rc1[1] compared to v5.10[2].
>
> Summarized:
>   - build errors: +1/-3
>   - build warnings: +12/-132
>
> Happy fixing! ;-)
>
> Thanks to the linux-next team for providing the build service.
>
> [1] http://kisskb.ellerman.id.au/kisskb/branch/linus/head/5c8fe583cce542aa0b84adc939ce85293de36e5e/ (all 192 configs)
> [2] http://kisskb.ellerman.id.au/kisskb/branch/linus/head/2c85ebc57b3e1817b6ce1a6b703928e113a90442/ (all 192 configs)
>
>
> *** ERRORS ***
>
> 1 error regressions:
>   + /kisskb/src/include/linux/mmzone.h: error: #error Allocator MAX_ORDER exceeds SECTION_SIZE:  => 1156:2

ia64-defconfig (fix available)

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
