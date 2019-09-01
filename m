From: Christoph Hellwig <hch@lst.de>
Date: Sun, 01 Sep 2019 08:02:27 +0000
Subject: Re: [PATCH 24/26] riscv: use the generic ioremap code
Message-Id: <20190901080227.GB12035@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de> <20190817073253.27819-25-hch@lst.de> <alpine.DEB.2.21.9999.1908171421560.4130@viisi.sifive.com>
In-Reply-To: <alpine.DEB.2.21.9999.1908171421560.4130@viisi.sifive.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Walmsley <paul.walmsley@sifive.com>
Cc: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Guo Ren <guoren@kernel.org>, Michal Simek <monstr@monstr.eu>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, linux-mtd@lists.infradead.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, nios2-dev@lists.rocketboards.org, linux-riscv@lists.infradead.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infr

On Sat, Aug 17, 2019 at 02:22:15PM -0700, Paul Walmsley wrote:
> Reviewed-by: Paul Walmsley <paul.walmsley@sifive.com>
> Tested-by: Paul Walmsley <paul.walmsley@sifive.com> # rv32, rv64 boot
> Acked-by: Paul Walmsley <paul.walmsley@sifive.com> # arch/riscv

Can you also take a look at the patch adding the generic code?
