From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 11 May 2020 15:24:30 +0000
Subject: Re: [PATCH 31/31] module: move the set_fs hack for flush_icache_range to m68k
Message-Id: <CAMuHMdW1S91i3x0unNcJnypHse7ifynGb4dZcVhJaemR3GH1Pg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-1-hch@lst.de> <20200510075510.987823-32-hch@lst.de>
 <CAMuHMdU_OxNoKfO=i903kx0mgk0-i2h4u2ase3m9_dn6oFh_5g@mail.gmail.com> <20200511151120.GA28634@lst.de>
In-Reply-To: <20200511151120.GA28634@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>, Jessica Yu <jeyu@kernel.org>, Michal Simek <monstr@monstr.eu>, the arch/x86 maintainers <x86@kernel.org>, alpha <linux-alpha@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Openrisc <openrisc@lists.librecores.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.orgLinux-shlistlinu

Hi Christoph,

On Mon, May 11, 2020 at 5:11 PM Christoph Hellwig <hch@lst.de> wrote:
> On Mon, May 11, 2020 at 09:40:39AM +0200, Geert Uytterhoeven wrote:
> > On Sun, May 10, 2020 at 9:57 AM Christoph Hellwig <hch@lst.de> wrote:
> > >
> > > flush_icache_range generally operates on kernel addresses, but for some
> > > reason m68k needed a set_fs override.  Move that into the m68k code
> > > insted of keeping it in the module loader.
> > >
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> >
> > Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
> Btw, do you know what part of flush_icache_range relied on set_fs?
> Do any of the m68k maintainers have an idea how to handle that in
> a nicer way when we can split the implementations?

arch/m68k/mm/cache.c:virt_to_phys_slow()

All instructions that look up addresses in the page tables look at the
source/destination function codes (SFC/DFC) to know if they have to use
the supervisor or user page tables.
So the actual implementation is the same: set_fs() merely configures
SFC/DFC, to select the address space to use.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
