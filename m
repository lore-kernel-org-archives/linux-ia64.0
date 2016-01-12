From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 12 Jan 2016 16:31:02 +0000
Subject: Re: [PATCH v3 05/41] powerpc: reuse asm-generic/barrier.h
Message-Id: <20160112163102.GE3818@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
	<1452426622-4471-6-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-6-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, virtualization@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orglinux

On Sun, Jan 10, 2016 at 04:17:09PM +0200, Michael S. Tsirkin wrote:
> On powerpc read_barrier_depends, smp_read_barrier_depends
> smp_store_mb(), smp_mb__before_atomic and smp_mb__after_atomic match the
> asm-generic variants exactly. Drop the local definitions and pull in
> asm-generic/barrier.h instead.
> 
> This is in preparation to refactoring this code area.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Looks sane to me.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  arch/powerpc/include/asm/barrier.h | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
> index a7af5fb..980ad0c 100644
> --- a/arch/powerpc/include/asm/barrier.h
> +++ b/arch/powerpc/include/asm/barrier.h
> @@ -34,8 +34,6 @@
>  #define rmb()  __asm__ __volatile__ ("sync" : : : "memory")
>  #define wmb()  __asm__ __volatile__ ("sync" : : : "memory")
> 
> -#define smp_store_mb(var, value) do { WRITE_ONCE(var, value); smp_mb(); } while (0)
> -
>  #ifdef __SUBARCH_HAS_LWSYNC
>  #    define SMPWMB      LWSYNC
>  #else
> @@ -60,9 +58,6 @@
>  #define smp_wmb()	barrier()
>  #endif /* CONFIG_SMP */
> 
> -#define read_barrier_depends()		do { } while (0)
> -#define smp_read_barrier_depends()	do { } while (0)
> -
>  /*
>   * This is a barrier which prevents following instructions from being
>   * started until the value of the argument x is known.  For example, if
> @@ -87,8 +82,8 @@ do {									\
>  	___p1;								\
>  })
> 
> -#define smp_mb__before_atomic()     smp_mb()
> -#define smp_mb__after_atomic()      smp_mb()
>  #define smp_mb__before_spinlock()   smp_mb()
> 
> +#include <asm-generic/barrier.h>
> +
>  #endif /* _ASM_POWERPC_BARRIER_H */
> -- 
> MST
> 

