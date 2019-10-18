From: Paul Walmsley <paul.walmsley@sifive.com>
Date: Fri, 18 Oct 2019 03:42:14 +0000
Subject: Re: [PATCH 18/21] riscv: use the generic ioremap code
Message-Id: <alpine.DEB.2.21.9999.1910172038040.3156@viisi.sifive.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191017174554.29840-1-hch@lst.de>
 <20191017174554.29840-19-hch@lst.de>
In-Reply-To: <20191017174554.29840-19-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, Vincent Chen <deanbo422@gmail.com>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, Arnd Bergmann <arnd@arndb.de>, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Greentime Hu <green.hu@gmail.com>, linux-mtd@lists.infradead.org, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-mips@vger.kernel.org, linux-alpha@vger.kernel.org, nios2-dev@lists.rocketboards.org

On Thu, 17 Oct 2019, Christoph Hellwig wrote:

> Use the generic ioremap code instead of providing a local version.
> Note that this relies on the asm-generic no-op definition of
> pgprot_noncached.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

According to the series introduction E-mail:

https://lore.kernel.org/linux-riscv/20191017174554.29840-1-hch@lst.de/T/#m9ac4010fd725c8c84179fa99aa391a6f701a32de

nothing substantive related to RISC-V or the common code has changed since 
the first version of this series, and this RISC-V-specific patch appears 
to be quite close (if not identical) to the first version of the patch:

https://lore.kernel.org/linux-riscv/alpine.DEB.2.21.9999.1908171421560.4130@viisi.sifive.com/

Thus the Tested-by, Reviewed-by, and Acked-by for RISC-V should all still 
apply:

https://lore.kernel.org/linux-riscv/alpine.DEB.2.21.9999.1908171421560.4130@viisi.sifive.com/


- Paul
