From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 04 Jan 2016 13:20:42 +0000
Subject: Re: [PATCH v2 06/32] s390: reuse asm-generic/barrier.h
Message-Id: <20160104132042.GW6344@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-7-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-7-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-

On Thu, Dec 31, 2015 at 09:06:30PM +0200, Michael S. Tsirkin wrote:
> On s390 read_barrier_depends, smp_read_barrier_depends
> smp_store_mb(), smp_mb__before_atomic and smp_mb__after_atomic match the
> asm-generic variants exactly. Drop the local definitions and pull in
> asm-generic/barrier.h instead.
> 
> This is in preparation to refactoring this code area.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  arch/s390/include/asm/barrier.h | 10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
> index 7ffd0b1..c358c31 100644
> --- a/arch/s390/include/asm/barrier.h
> +++ b/arch/s390/include/asm/barrier.h
> @@ -30,14 +30,6 @@
>  #define smp_rmb()			rmb()
>  #define smp_wmb()			wmb()
>  
> -#define read_barrier_depends()		do { } while (0)
> -#define smp_read_barrier_depends()	do { } while (0)
> -
> -#define smp_mb__before_atomic()		smp_mb()
> -#define smp_mb__after_atomic()		smp_mb()

As per:

  lkml.kernel.org/r/20150921112252.3c2937e1@mschwide

s390 should change this to barrier() instead of smp_mb() and hence
should not use the generic versions.
