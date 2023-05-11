From: Heiko Carstens <hca@linux.ibm.com>
Date: Thu, 11 May 2023 07:57:11 +0000
Subject: Re: [PATCH] cachestat: wire up cachestat for other architectures
Message-Id: <ZFyf195PuoBmaV2N@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510195806.2902878-1-nphamcs@gmail.com>
In-Reply-To: <20230510195806.2902878-1-nphamcs@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nhat Pham <nphamcs@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-api@vger.kernel.org, kernel-team@meta.com, linux-arch@vger.kernel.org, hannes@cmpxchg.org, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux@armlinux.org.uk, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, glaubitz@physik.fu-berlin.de, davem@davemloft.net, chris@zankel.net, jcmvbkbc@gmail.com, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Wed, May 10, 2023 at 12:58:06PM -0700, Nhat Pham wrote:
> cachestat is previously only wired in for x86 (and architectures using
> the generic unistd.h table):
> 
> https://lore.kernel.org/lkml/20230503013608.2431726-1-nphamcs@gmail.com/
> 
> This patch wires cachestat in for all the other architectures.
> 
> Signed-off-by: Nhat Pham <nphamcs@gmail.com>
> ---
...
>  arch/s390/kernel/syscalls/syscall.tbl       | 1 +

Acked-by: Heiko Carstens <hca@linux.ibm.com> (s390)
