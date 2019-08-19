From: Will Deacon <will@kernel.org>
Date: Mon, 19 Aug 2019 07:36:02 +0000
Subject: Re: [PATCH 19/26] arm64: remove __iounmap
Message-Id: <20190819073601.4yxjvmyjtpi7tk56@willie-the-truck>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de>
 <20190817073253.27819-20-hch@lst.de>
In-Reply-To: <20190817073253.27819-20-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mtd@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Aug 17, 2019 at 09:32:46AM +0200, Christoph Hellwig wrote:
> No need to indirect iounmap for arm64.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/arm64/include/asm/io.h | 3 +--
>  arch/arm64/mm/ioremap.c     | 4 ++--
>  2 files changed, 3 insertions(+), 4 deletions(-)

Not sure why we did it like this...

Acked-by: Will Deacon <will@kernel.org>

Will
