From: Christoph Hellwig <hch@lst.de>
Date: Fri, 30 Aug 2019 16:07:05 +0000
Subject: Re: [PATCH 05/26] openrisc: map as uncached in ioremap
Message-Id: <20190830160705.GF26887@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de> <20190817073253.27819-6-hch@lst.de> <20190823135539.GC24874@lianli.shorne-pla.net>
In-Reply-To: <20190823135539.GC24874@lianli.shorne-pla.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stafford Horne <shorne@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.k

On Fri, Aug 23, 2019 at 10:55:39PM +0900, Stafford Horne wrote:
> On Sat, Aug 17, 2019 at 09:32:32AM +0200, Christoph Hellwig wrote:
> > Openrisc is the only architecture not mapping ioremap as uncached,
> > which has been the default since the Linux 2.6.x days.  Switch it
> > over to implement uncached semantics by default.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  arch/openrisc/include/asm/io.h      | 20 +++-----------------
> >  arch/openrisc/include/asm/pgtable.h |  2 +-
> >  arch/openrisc/mm/ioremap.c          |  8 ++++----
> >  3 files changed, 8 insertions(+), 22 deletions(-)
> 
> Acked-by: Stafford Horne <shorne@gmail.com>

Can you send this one to Linus for 5.4?  That would help with the
possibility to remove ioremap_nocache after that.
