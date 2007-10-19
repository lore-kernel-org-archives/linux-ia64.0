From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 19 Oct 2007 04:34:48 +0000
Subject: Re: [IA64] Reduce __clear_bit_unlock overhead
Message-Id: <200710191434.48445.nickpiggin@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 19 October 2007 13:38, Christoph Lameter wrote:
> On Fri, 19 Oct 2007, Nick Piggin wrote:
> > I'm not sure, I had an idea it was relatively expensive on ia64,
> > but I didn't really test with a good workload (a microbenchmark
> > probably isn't that good because it won't generate too much out
> > of order memory traffic that needs to be fenced).
>
> Its expensive on IA64. Is it any less expensive on x86?

Probably relatively less because x86 has only a very small amount of
possible reordering, perhaps. (it can only reorder loads past
earlier stores).

Of course, we can avoid the fence altogether on x86 as well, because
it simply isn't needed for release semantics.


> > > Where can I find your patchset? I looked through lkml but did not see
> > > it.
> >
> > Infrastructure in -mm, starting at bitops-introduce-lock-ops.patch.
> > bit_spin_lock-use-lock-bitops.patch and ia64-lock-bitops.patch are
> > ones to look at.
>
> ia64-lock-bitops.patch defines:
>
> static __inline__ void
> clear_bit_unlock (int nr, volatile void *addr)
> {
>        __u32 mask, old, new;
>        volatile __u32 *m;
>        CMPXCHG_BUGCHECK_DECL
>
>        m = (volatile __u32 *) addr + (nr >> 5);
>        mask = ~(1 << (nr & 31));
>        do {
>                CMPXCHG_BUGCHECK(m);
>                old = *m;
>                new = old & mask;
>        } while (cmpxchg_rel(m, old, new) != old);
> }
>
> /**
>  * __clear_bit_unlock - Non-atomically clear a bit with release
>  *
>  * This is like clear_bit_unlock, but the implementation may use a
> non-atomic * store (this one uses an atomic, however).
>  */
> #define __clear_bit_unlock clear_bit_unlock
>
>
> A non atomic store is a misaligned store on IA64. That is not
> relevant here. The data is properly aligned. I guess it was intended to
> refer to the cmpxchg.

Well it's just saying that it _can_ be non-atomic, but the implementation
here is actually atomic, because....


> How about this patch? [Works fine on IA64 simulator...]
>
>
>
>
> IA64: Slim down __clear_bit_unlock
>
> __clear_bit_unlock does not need to perform atomic operations on the
> variable. Avoid a cmpxchg and simply do a store with release semantics. Add
> a barrier to be safe that the compiler does not do funky things.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
> ---
>  include/asm-ia64/bitops.h |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> Index: linux-2.6.23-mm1/include/asm-ia64/bitops.h
> =================================> --- linux-2.6.23-mm1.orig/include/asm-ia64/bitops.h	2007-10-18
> 19:37:22.000000000 -0700 +++
> linux-2.6.23-mm1/include/asm-ia64/bitops.h	2007-10-18 19:50:22.000000000
> -0700 @@ -124,10 +124,21 @@ clear_bit_unlock (int nr, volatile void
>  /**
>   * __clear_bit_unlock - Non-atomically clear a bit with release
>   *
> - * This is like clear_bit_unlock, but the implementation may use a
> non-atomic - * store (this one uses an atomic, however).
> + * This is like clear_bit_unlock, but the implementation uses a store
> + * with release semantics. See also __raw_spin_unlock().
>   */
> -#define __clear_bit_unlock clear_bit_unlock
> +static __inline__ void
> +__clear_bit_unlock (int nr, volatile void *addr)
> +{
> +	__u32 mask, new;
> +	volatile __u32 *m;
> +
> +	m = (volatile __u32 *) addr + (nr >> 5);
> +	mask = ~(1 << (nr & 31));
> +	new = *m & mask;
> +	barrier();
> +	asm volatile ("st4.rel.nta [%0] = %1\n\t" :: "r"(m), "r"(new));
> +}

.... I didn't realise ia64 could do plain stores with release
semantics -- I should have looked closer at spinlock.h. Yes,
this is exactly what we want here. This patch will now apply
upstream, so if you want to send it to Linus, that would be
nice. Thanks!

Acked-by: Nick Piggin <npiggin@suse.de>
