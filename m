From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 11 May 2020 15:25:45 +0000
Subject: Re: sort out the flush_icache_range mess
Message-Id: <CAMuHMdU1xAmyWysi5xRoaRL7PFurPncvEL0CcEY0V_sUz3EJPw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-1-hch@lst.de> <CAMuHMdXazsBw0mjJd0uFHQud7qbb5-Uw-PTDB3+-M=huRWOfgQ@mail.gmail.com>
 <20200511151356.GB28634@lst.de>
In-Reply-To: <20200511151356.GB28634@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>, Linux-Arch <linux-arch@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Michal Simek <monstr@monstr.eu>, Jessica Yu <jeyu@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, Linux-sh list <linux-sh@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-um <linux-um@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.o>

Hi Christoph,

On Mon, May 11, 2020 at 5:14 PM Christoph Hellwig <hch@lst.de> wrote:
> On Mon, May 11, 2020 at 09:46:17AM +0200, Geert Uytterhoeven wrote:
> > On Sun, May 10, 2020 at 9:55 AM Christoph Hellwig <hch@lst.de> wrote:
> > > none of which really are used by a typical MMU enabled kernel, as a.out can
> > > only be build for alpha and m68k to start with.
> >
> > Quoting myself:
> > "I think it's safe to assume no one still runs a.out binaries on m68k."
> > http://lore.kernel.org/r/CAMuHMdW+m0Q+j3rsQdMXnrEPm+XB5Y2AQrxW5sD1mZAKgmEqoA@mail.gmail.com
>
> Do you want to drop the:
>
>     select HAVE_AOUT if MMU
>
> for m68k then?

If that helps to reduce maintenance, it's fine for me.
That leaves alpha as the sole user?

> Note that we'll still need flush_icache_user_range for m68k with mmu,
> as it also allows binfmt_flat for mmu configs.

Understood.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
