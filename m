From: Hirokazu Takata <takata@linux-m32r.org>
Date: Thu, 02 Jun 2011 05:44:13 +0000
Subject: Re: [PATCHv3] atomic: add *_dec_not_zero
Message-Id: <swffwnsdbyq.wl%hirokazu.takata.wj@renesas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1305748194-23351-1-git-send-email-sven@narfation.org>
 <1306653200-19176-1-git-send-email-sven@narfation.org>
In-Reply-To: <1306653200-19176-1-git-send-email-sven@narfation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Eckelmann <sven@narfation.org>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m32r@ml.linux-m32r.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org

From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCHv3] atomic: add *_dec_not_zero
Date: Sun, 29 May 2011 09:13:20 +0200
> Introduce an *_dec_not_zero operation.  Make this a special case of
> *_add_unless because batman-adv uses atomic_dec_not_zero in different
> places like re-broadcast queue or aggregation queue management. There
> are other non-final patches which may also want to use this macro.
> 
> Reported-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> Acked-by: Mike Frysinger <vapier@gentoo.org>
> Acked-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> Acked-by: Ingo Molnar <mingo@elte.hu>
> Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
> Acked-by: Ralf Baechle <ralf@linux-mips.org>
> Acked-by: David Howells <dhowells@redhat.com>
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Acked-by: Will Deacon <will.deacon@arm.com>
> Acked-by: Matt Turner <mattst88@gmail.com>
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Acked-by: Paul Mundt <lethal@linux-sh.org>
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: Hirokazu Takata <takata@linux-m32r.org>
> Cc: linux-m32r@ml.linux-m32r.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-arch@vger.kernel.org
> ---
> Sry, had to rebase the patch because some lines bellow my patch in
> arch/tile/include/asm/atomic.h changed.
> 
> I am still waiting for (n)acks for ia64, m32r and generic... and someone
> who is willing to apply it in his tree (maybe Arnd Bermann?).
> 
>  arch/alpha/include/asm/atomic.h    |    2 ++
>  arch/alpha/include/asm/local.h     |    1 +
>  arch/arm/include/asm/atomic.h      |    2 ++
>  arch/avr32/include/asm/atomic.h    |    1 +
>  arch/blackfin/include/asm/atomic.h |    1 +
>  arch/cris/include/asm/atomic.h     |    1 +
>  arch/frv/include/asm/atomic.h      |    1 +
>  arch/h8300/include/asm/atomic.h    |    1 +
>  arch/ia64/include/asm/atomic.h     |    2 ++
>  arch/m32r/include/asm/atomic.h     |    1 +
>  arch/m32r/include/asm/local.h      |    1 +
>  arch/m68k/include/asm/atomic.h     |    1 +
>  arch/mips/include/asm/atomic.h     |    2 ++
>  arch/mips/include/asm/local.h      |    1 +
>  arch/mn10300/include/asm/atomic.h  |    1 +
>  arch/parisc/include/asm/atomic.h   |    2 ++
>  arch/powerpc/include/asm/atomic.h  |    2 ++
>  arch/powerpc/include/asm/local.h   |    1 +
>  arch/s390/include/asm/atomic.h     |    2 ++
>  arch/sh/include/asm/atomic.h       |    1 +
>  arch/sparc/include/asm/atomic_32.h |    1 +
>  arch/sparc/include/asm/atomic_64.h |    2 ++
>  arch/tile/include/asm/atomic.h     |    9 +++++++++
>  arch/tile/include/asm/atomic_32.h  |    1 +
>  arch/x86/include/asm/atomic.h      |    1 +
>  arch/x86/include/asm/atomic64_64.h |    1 +
>  arch/xtensa/include/asm/atomic.h   |    1 +
>  include/asm-generic/atomic-long.h  |    2 ++
>  include/asm-generic/atomic.h       |    1 +
>  include/asm-generic/atomic64.h     |    1 +
>  include/asm-generic/local.h        |    1 +
>  include/asm-generic/local64.h      |    2 ++
>  32 files changed, 50 insertions(+), 0 deletions(-)

Acked-by: Hirokazu Takata <takata@linux-m32r.org>

Thank you.
