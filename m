From: Christoph Hellwig <hch@lst.de>
Date: Mon, 11 May 2020 16:35:04 +0000
Subject: Re: sort out the flush_icache_range mess
Message-Id: <20200511163503.GA32228@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-1-hch@lst.de>
 <CAMuHMdXazsBw0mjJd0uFHQud7qbb5-Uw-PTDB3+-M=huRWOfgQ@mail.gmail.com>
 <20200511151356.GB28634@lst.de>
 <CAMuHMdU1xAmyWysi5xRoaRL7PFurPncvEL0CcEY0V_sUz3EJPw@mail.gmail.com>
In-Reply-To: <CAMuHMdU1xAmyWysi5xRoaRL7PFurPncvEL0CcEY0V_sUz3EJPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Roman Zippel <zippel@linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-riscv@lists.infradead.org, Christoph Hellwig <hch@lst.de>, Linux-Arch <linux-arch@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Arnd Bergmann <arnd@arndb.de>, Jessica Yu <jeyu@kernel.org>, linux-um <linux-um@lists.infradead.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Openrisc <openrisc@lists.librecores.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Michal Simek <monstr@monstr.eu>, Linux

On Mon, May 11, 2020 at 05:25:45PM +0200, Geert Uytterhoeven wrote:
> > Do you want to drop the:
> >
> >     select HAVE_AOUT if MMU
> >
> > for m68k then?
> 
> If that helps to reduce maintenance, it's fine for me.
> That leaves alpha as the sole user?

Yes.  And for alpha it isn't classic Linux a.out, but the OSF/1 ECOFF
format, which might lead to further cleanups eventually.
