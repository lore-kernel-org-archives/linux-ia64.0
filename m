From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 11 May 2020 07:46:17 +0000
Subject: Re: sort out the flush_icache_range mess
Message-Id: <CAMuHMdXazsBw0mjJd0uFHQud7qbb5-Uw-PTDB3+-M=huRWOfgQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-1-hch@lst.de>
In-Reply-To: <20200510075510.987823-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>, Linux-Arch <linux-arch@vger.kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Michal Simek <monstr@monstr.eu>, Jessica Yu <jeyu@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, Linux-sh list <linux-sh@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-um <linux-um@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.o>

Hi Christoph,

On Sun, May 10, 2020 at 9:55 AM Christoph Hellwig <hch@lst.de> wrote:
> none of which really are used by a typical MMU enabled kernel, as a.out can
> only be build for alpha and m68k to start with.

Quoting myself:
"I think it's safe to assume no one still runs a.out binaries on m68k."
http://lore.kernel.org/r/CAMuHMdW+m0Q+j3rsQdMXnrEPm+XB5Y2AQrxW5sD1mZAKgmEqoA@mail.gmail.com

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
