From: Jessica Yu <jeyu@kernel.org>
Date: Mon, 18 May 2020 13:04:44 +0000
Subject: Re: [PATCH 29/29] module: move the set_fs hack for flush_icache_range to m68k
Message-Id: <20200518130444.GA21096@linux-8ccs.fritz.box>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200515143646.3857579-1-hch@lst.de>
 <20200515143646.3857579-30-hch@lst.de>
In-Reply-To: <20200515143646.3857579-30-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

+++ Christoph Hellwig [15/05/20 16:36 +0200]:
>flush_icache_range generally operates on kernel addresses, but for some
>reason m68k needed a set_fs override.  Move that into the m68k code
>insted of keeping it in the module loader.
>
>Signed-off-by: Christoph Hellwig <hch@lst.de>
>Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
>Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
>---
> arch/m68k/mm/cache.c | 4 ++++
> kernel/module.c      | 8 --------
> 2 files changed, 4 insertions(+), 8 deletions(-)

Thanks for cleaning this up. For module.c:

Acked-by: Jessica Yu <jeyu@kernel.org>
