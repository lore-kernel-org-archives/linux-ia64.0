From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 05 Jan 2016 16:16:48 +0000
Subject: Re: [PATCH v2 15/32] powerpc: define __smp_xxx
Message-Id: <20160105180938-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-16-git-send-email-mst@redhat.com>
 <20160105013648.GA1256@fixme-laptop.cn.ibm.com>
 <20160105085117.GA11858@redhat.com>
 <20160105095341.GA5321@fixme-laptop.cn.ibm.com>
In-Reply-To: <20160105095341.GA5321-nNqVUaWX1rAq6Sbylg4iGasjOiXwFzmk@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Boqun Feng <boqun.feng-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, Paul Mackerras <paul>

On Tue, Jan 05, 2016 at 05:53:41PM +0800, Boqun Feng wrote:
> On Tue, Jan 05, 2016 at 10:51:17AM +0200, Michael S. Tsirkin wrote:
> > On Tue, Jan 05, 2016 at 09:36:55AM +0800, Boqun Feng wrote:
> > > Hi Michael,
> > > 
> > > On Thu, Dec 31, 2015 at 09:07:42PM +0200, Michael S. Tsirkin wrote:
> > > > This defines __smp_xxx barriers for powerpc
> > > > for use by virtualization.
> > > > 
> > > > smp_xxx barriers are removed as they are
> > > > defined correctly by asm-generic/barriers.h
> > 
> > I think this is the part that was missed in review.
> > 
> 
> Yes, I realized my mistake after reread the series. But smp_lwsync() is
> not defined in asm-generic/barriers.h, right?

It isn't because as far as I could tell it is not used
outside arch/powerpc/include/asm/barrier.h
smp_store_release and smp_load_acquire.

And these are now gone.

Instead there are __smp_store_release and __smp_load_acquire
which call __smp_lwsync.
These are only used for virt and on SMP.
UP variants are generic - they just call barrier().


> > > > This reduces the amount of arch-specific boiler-plate code.
> > > > 
> > > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > > Acked-by: Arnd Bergmann <arnd@arndb.de>
> > > > ---
> > > >  arch/powerpc/include/asm/barrier.h | 24 ++++++++----------------
> > > >  1 file changed, 8 insertions(+), 16 deletions(-)
> > > > 
> > > > diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
> > > > index 980ad0c..c0deafc 100644
> > > > --- a/arch/powerpc/include/asm/barrier.h
> > > > +++ b/arch/powerpc/include/asm/barrier.h
> > > > @@ -44,19 +44,11 @@
> > > >  #define dma_rmb()	__lwsync()
> > > >  #define dma_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
> > > >  
> > > > -#ifdef CONFIG_SMP
> > > > -#define smp_lwsync()	__lwsync()
> > > > +#define __smp_lwsync()	__lwsync()
> > > >  
> > > 
> > > so __smp_lwsync() is always mapped to lwsync, right?
> > 
> > Yes.
> > 
> > > > -#define smp_mb()	mb()
> > > > -#define smp_rmb()	__lwsync()
> > > > -#define smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
> > > > -#else
> > > > -#define smp_lwsync()	barrier()
> > > > -
> > > > -#define smp_mb()	barrier()
> > > > -#define smp_rmb()	barrier()
> > > > -#define smp_wmb()	barrier()
> > > > -#endif /* CONFIG_SMP */
> > > > +#define __smp_mb()	mb()
> > > > +#define __smp_rmb()	__lwsync()
> > > > +#define __smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
> > > >  
> > > >  /*
> > > >   * This is a barrier which prevents following instructions from being
> > > > @@ -67,18 +59,18 @@
> > > >  #define data_barrier(x)	\
> > > >  	asm volatile("twi 0,%0,0; isync" : : "r" (x) : "memory");
> > > >  
> > > > -#define smp_store_release(p, v)						\
> > > > +#define __smp_store_release(p, v)						\
> > > >  do {									\
> > > >  	compiletime_assert_atomic_type(*p);				\
> > > > -	smp_lwsync();							\
> > > > +	__smp_lwsync();							\
> > > 
> > > , therefore this will emit an lwsync no matter SMP or UP.
> > 
> > Absolutely. But smp_store_release (without __) will not.
> > 
> > Please note I did test this: for ppc code before and after
> > this patch generates exactly the same binary on SMP and UP.
> > 
> 
> Yes, you're right, sorry for my mistake...
> 
> > 
> > > Another thing is that smp_lwsync() may have a third user(other than
> > > smp_load_acquire() and smp_store_release()):
> > > 
> > > http://article.gmane.org/gmane.linux.ports.ppc.embedded/89877
> > > 
> > > I'm OK to change my patch accordingly, but do we really want
> > > smp_lwsync() get involved in this cleanup? If I understand you
> > > correctly, this cleanup focuses on external API like smp_{r,w,}mb(),
> > > while smp_lwsync() is internal to PPC.
> > > 
> > > Regards,
> > > Boqun
> > 
> > I think you missed the leading ___ :)
> > 
> 
> What I mean here was smp_lwsync() was originally internal to PPC, but
> never mind ;-)
> 
> > smp_store_release is external and it needs __smp_lwsync as
> > defined here.
> > 
> > I can duplicate some code and have smp_lwsync *not* call __smp_lwsync
> 
> You mean bringing smp_lwsync() back? because I haven't seen you defining
> in asm-generic/barriers.h in previous patches and you just delete it in
> this patch.
> 
> > but why do this? Still, if you prefer it this way,
> > please let me know.
> > 
> 
> I think deleting smp_lwsync() is fine, though I need to change atomic
> variants patches on PPC because of it ;-/
> 
> Regards,
> Boqun

Sorry, I don't understand - why do you have to do anything?
I changed all users of smp_lwsync so they
use __smp_lwsync on SMP and barrier() on !SMP.

This is exactly the current behaviour, I also tested that
generated code does not change at all.

Is there a patch in your tree that conflicts with this?


> > > >  	WRITE_ONCE(*p, v);						\
> > > >  } while (0)
> > > >  
> > > > -#define smp_load_acquire(p)						\
> > > > +#define __smp_load_acquire(p)						\
> > > >  ({									\
> > > >  	typeof(*p) ___p1 = READ_ONCE(*p);				\
> > > >  	compiletime_assert_atomic_type(*p);				\
> > > > -	smp_lwsync();							\
> > > > +	__smp_lwsync();							\
> > > >  	___p1;								\
> > > >  })
> > > >  
> > > > -- 
> > > > MST
> > > > 
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > Please read the FAQ at  http://www.tux.org/lkml/
