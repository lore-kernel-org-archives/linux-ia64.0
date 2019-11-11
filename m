From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 11 Nov 2019 10:36:22 +0000
Subject: Re: [PATCH 03/21] ia64: rename ioremap_nocache to ioremap_uc
Message-Id: <CAK8P3a3k2KRyhCy4OWJkToNBiw_mw0e_A=Ta6UANMMF3EXnhmA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-1-hch@lst.de> <20191029064834.23438-4-hch@lst.de>
In-Reply-To: <20191029064834.23438-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, the arch/x86 maintainers <x86@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, "moderated list:NIOS2 ARCHITECTURE" <nios2-dev@lists.rocketboards.org>, openrisc@lists.librecores.org, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv@lists.infradead.org, linux-s390 <linux-s390@vger.kernel.org>

On Tue, Oct 29, 2019 at 7:48 AM Christoph Hellwig <hch@lst.de> wrote:
>
> On ia64 ioremap_nocache fails if attributes don't match.  Not other
> architectures does this, and we plan to get rid of ioremap_nocache.
> So get rid of the special semantics and define ioremap_nocache in
> terms of ioremap as no portable driver could rely on the behavior
> anyway.
>
> However x86 implements ioremap_uc in a similar way as the ia64
> version of ioremap_nocache, in that it ignores the firmware tables.
> Switch ia64 to override ioremap_uc instead.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Good idea,

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
