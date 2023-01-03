From: Heiko Carstens <hca@linux.ibm.com>
Date: Tue, 03 Jan 2023 10:02:09 +0000
Subject: Re: [PATCH v3] arch: rename all internal names __xchg to __arch_xchg
Message-Id: <Y7P9IcR7/jgYWMcq@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <202212300642.6pdgegGO-lkp@intel.com>
 <20221230141552.128508-1-andrzej.hajda@intel.com>
In-Reply-To: <20221230141552.128508-1-andrzej.hajda@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrzej Hajda <andrzej.hajda@intel.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Arnd Bergmann <arnd@arndb.de>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, Mark Rutland <mark.rutland@arm.com>

On Fri, Dec 30, 2022 at 03:15:52PM +0100, Andrzej Hajda wrote:
> __xchg will be used for non-atomic xchg macro.
> 
> Signed-off-by: Andrzej Hajda <andrzej.hajda@intel.com>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
> ---
> v2: squashed all arch patches into one
> v3: fixed alpha/xchg_local, thx to lkp@intel.com
> ---
...
>  arch/s390/include/asm/cmpxchg.h      | 4 ++--
> diff --git a/arch/s390/include/asm/cmpxchg.h b/arch/s390/include/asm/cmpxchg.h
> index 84c3f0d576c5b1..efc16f4aac8643 100644
> --- a/arch/s390/include/asm/cmpxchg.h
> +++ b/arch/s390/include/asm/cmpxchg.h
> @@ -14,7 +14,7 @@
>  
>  void __xchg_called_with_bad_pointer(void);
>  
> -static __always_inline unsigned long __xchg(unsigned long x,
> +static __always_inline unsigned long __arch_xchg(unsigned long x,
>  					    unsigned long address, int size)

Please adjust the alignment of the second line.

> @@ -77,7 +77,7 @@ static __always_inline unsigned long __xchg(unsigned long x,
>  	__typeof__(*(ptr)) __ret;					\
>  									\
>  	__ret = (__typeof__(*(ptr)))					\
> -		__xchg((unsigned long)(x), (unsigned long)(ptr),	\
> +		__arch_xchg((unsigned long)(x), (unsigned long)(ptr),	\
>  		       sizeof(*(ptr)));					\

Same here.

The same is true for a couple of other architectures - not sure if
they care however.
