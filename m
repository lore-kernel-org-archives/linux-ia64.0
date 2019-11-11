From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 11 Nov 2019 10:29:40 +0000
Subject: Re: [PATCH 11/21] asm-generic: don't provide ioremap for CONFIG_MMU
Message-Id: <CAK8P3a36-afn--XqG0ddj6VSPCzA_cfZqRxQXDuan7yk8CKg4w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-1-hch@lst.de> <20191029064834.23438-12-hch@lst.de>
In-Reply-To: <20191029064834.23438-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, the arch/x86 maintainers <x86@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, "moderated list:NIOS2 ARCHITECTURE" <nios2-dev@lists.rocketboards.org>, openrisc@lists.librecores.org, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv@lists.infradead.org, linux-s390 <linux-s390@vger.kernel.org>

On Tue, Oct 29, 2019 at 7:49 AM Christoph Hellwig <hch@lst.de> wrote:
>
> All MMU-enabled ports have a non-trivial ioremap and should thus provide
> the prototype for their implementation instead of providing a generic
> one unless a different symbol is not defined.  Note that this only
> affects sparc32 nds32 as all others do provide their own version.
>
> Also update the kerneldoc comments in asm-generic/io.h to explain the
> situation around the default ioremap* implementations correctly.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
