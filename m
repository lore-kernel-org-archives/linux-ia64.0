From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 07 May 2021 10:05:36 +0000
Subject: Re: [PATCH] mm: update legacy flush_tlb_* to use vma
Message-Id: <CAMuHMdWapV4ZypzpC0gvS01BKRQvPjsiD2uS7odb78dEeP=63Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0oaq311.wl-chenli@uniontech.com>
In-Reply-To: <87k0oaq311.wl-chenli@uniontech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: chenli@uniontech.com
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, Russell King <linux@armlinux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Jonas Bonn <jonas@southpole.se>, Openrisc <openrisc@lists.librecores.org>, Chris Zankel <chris@zankel.net>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>

On Fri, May 7, 2021 at 11:58 AM Chen Li <chenli@uniontech.com> wrote:
> 1. These tlb flush functions  have been using vma instead mm long time ago, but there
> is still some coments use mm as parameter.
>
> 2. the actual struct we use is vm_area_struct instead of vma_struct.
>
> 3. remove unused flush_kern_tlb_page.
>
> Signed-off-by: Chen Li <chenli@uniontech.com>

>  arch/m68k/include/asm/tlbflush.h     |  2 +-

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
