From: Boqun Feng <boqun.feng@gmail.com>
Date: Tue, 05 Jan 2016 01:36:55 +0000
Subject: Re: [PATCH v2 15/32] powerpc: define __smp_xxx
Message-Id: <20160105013648.GA1256@fixme-laptop.cn.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-16-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-16-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paul>

Hi Michael,

On Thu, Dec 31, 2015 at 09:07:42PM +0200, Michael S. Tsirkin wrote:
> This defines __smp_xxx barriers for powerpc
> for use by virtualization.
> 
> smp_xxx barriers are removed as they are
> defined correctly by asm-generic/barriers.h
> 
> This reduces the amount of arch-specific boiler-plate code.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  arch/powerpc/include/asm/barrier.h | 24 ++++++++----------------
>  1 file changed, 8 insertions(+), 16 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
> index 980ad0c..c0deafc 100644
> --- a/arch/powerpc/include/asm/barrier.h
> +++ b/arch/powerpc/include/asm/barrier.h
> @@ -44,19 +44,11 @@
>  #define dma_rmb()	__lwsync()
>  #define dma_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
>  
> -#ifdef CONFIG_SMP
> -#define smp_lwsync()	__lwsync()
> +#define __smp_lwsync()	__lwsync()
>  

so __smp_lwsync() is always mapped to lwsync, right?

> -#define smp_mb()	mb()
> -#define smp_rmb()	__lwsync()
> -#define smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
> -#else
> -#define smp_lwsync()	barrier()
> -
> -#define smp_mb()	barrier()
> -#define smp_rmb()	barrier()
> -#define smp_wmb()	barrier()
> -#endif /* CONFIG_SMP */
> +#define __smp_mb()	mb()
> +#define __smp_rmb()	__lwsync()
> +#define __smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
>  
>  /*
>   * This is a barrier which prevents following instructions from being
> @@ -67,18 +59,18 @@
>  #define data_barrier(x)	\
>  	asm volatile("twi 0,%0,0; isync" : : "r" (x) : "memory");
>  
> -#define smp_store_release(p, v)						\
> +#define __smp_store_release(p, v)						\
>  do {									\
>  	compiletime_assert_atomic_type(*p);				\
> -	smp_lwsync();							\
> +	__smp_lwsync();							\

, therefore this will emit an lwsync no matter SMP or UP.

Another thing is that smp_lwsync() may have a third user(other than
smp_load_acquire() and smp_store_release()):

http://article.gmane.org/gmane.linux.ports.ppc.embedded/89877

I'm OK to change my patch accordingly, but do we really want
smp_lwsync() get involved in this cleanup? If I understand you
correctly, this cleanup focuses on external API like smp_{r,w,}mb(),
while smp_lwsync() is internal to PPC.

Regards,
Boqun

>  	WRITE_ONCE(*p, v);						\
>  } while (0)
>  
> -#define smp_load_acquire(p)						\
> +#define __smp_load_acquire(p)						\
>  ({									\
>  	typeof(*p) ___p1 = READ_ONCE(*p);				\
>  	compiletime_assert_atomic_type(*p);				\
> -	smp_lwsync();							\
> +	__smp_lwsync();							\
>  	___p1;								\
>  })
>  
> -- 
> MST
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
