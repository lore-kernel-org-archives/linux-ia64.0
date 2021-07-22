From: Christoph Hellwig <hch@lst.de>
Date: Thu, 22 Jul 2021 13:00:42 +0000
Subject: Re: [PATCH v3 4/9] arc: use generic strncpy/strnlen from_user
Message-Id: <20210722130042.GD26225@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210722124814.778059-1-arnd@kernel.org> <20210722124814.778059-5-arnd@kernel.org>
In-Reply-To: <20210722124814.778059-5-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Al Viro <viro@zeniv.linux.org.uk>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Brian Cain <bcain@codeaurora.org>, Chris Zankel <chris@zankel.net>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoph Hellwig <hch@lst.de>, Guo Ren <guoren@kernel.org>, Heiko Carstens <hca@linux.ibm.com>, Helge Deller <deller@gmx.de>, Jeff Dike <jdike@addtoit.com>, Linus Walleij <linus.walleij@linaro.org>, Max Filippov <jcmvbkbc@gmail.com>, Michal Simek <monstr@monstr.eu>, Richard Weinberger <richard@nod.at>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Vasily Gorbik <gor@linux.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, uclinux-h8-devel@lists.sourceforge.jp

On Thu, Jul 22, 2021 at 02:48:09PM +0200, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> Remove the arc implemenation of strncpy/strnlen and instead use the
> generic versions.  The arc version is fairly slow because it always does
> byte accesses even for aligned data, and its checks for user_addr_max()
> differ from the generic code.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
