From: Christoph Hellwig <hch@lst.de>
Date: Wed, 27 May 2020 05:10:11 +0000
Subject: Re: [PATCH] media: omap3isp: Shuffle cacheflush.h and include mm.h
Message-Id: <20200527051011.GB16317@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200515143646.3857579-7-hch@lst.de> <20200527043426.3242439-1-natechancellor@gmail.com>
In-Reply-To: <20200527043426.3242439-1-natechancellor@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nathan Chancellor <natechancellor@gmail.com>
Cc: hch@lst.de, akpm@linux-foundation.org, arnd@arndb.de, jeyu@kernel.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-fsdevel@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, monstr@monstr.eu, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, x86@kernel.org, zippel@linux-m68k.org

On Tue, May 26, 2020 at 09:34:27PM -0700, Nathan Chancellor wrote:
> After mm.h was removed from the asm-generic version of cacheflush.h,
> s390 allyesconfig shows several warnings of the following nature:

Hmm, I'm pretty sure I sent the same fix a few days ago in response to
a build bot report.  But if that didn't get picked up I'm fine with
your version of it as well of course:

Acked-by: Christoph Hellwig <hch@lst.de>
