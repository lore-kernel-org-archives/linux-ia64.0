From: "Arnd Bergmann" <arnd@arndb.de>
Date: Thu, 11 May 2023 07:04:36 +0000
Subject: Re: [PATCH] cachestat: wire up cachestat for other architectures
Message-Id: <0d8e2503-5d4f-4b60-84ff-01a23bcf557f@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510195806.2902878-1-nphamcs@gmail.com>
In-Reply-To: <20230510195806.2902878-1-nphamcs@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nhat Pham <nphamcs@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, kernel-team@meta.com, Linux-Arch <linux-arch@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Heiko Carstens <hca@linux.ibm.com>, gor@linux.ibm.com, Alexander Gordeev <agordeev@linux.ibm.com>, borntraeger@linux.ibm.com, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S . Miller" <davem@davemloft.net>, chris@zankel.net, Max Filippov <jcmvbkbc@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Wed, May 10, 2023, at 21:58, Nhat Pham wrote:
> cachestat is previously only wired in for x86 (and architectures using
> the generic unistd.h table):
>
> https://lore.kernel.org/lkml/20230503013608.2431726-1-nphamcs@gmail.com/
>
> This patch wires cachestat in for all the other architectures.
>
> Signed-off-by: Nhat Pham <nphamcs@gmail.com>

The changes you did here look good, but you missed one
file that has never been converted to the syscall.tbl format:
arch/arm64/include/asm/unistd32.h along with the __NR_compat_syscalls
definition in arch/arm64/include/asm/unistd.h, please add those
as well, and then

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
