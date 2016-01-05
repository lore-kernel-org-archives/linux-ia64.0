From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 05 Jan 2016 13:04:43 +0000
Subject: Re: [PATCH v2 22/32] s390: define __smp_xxx
Message-Id: <20160105144842-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-23-git-send-email-mst@redhat.com>
 <20160104134525.GA6344@twins.programming.kicks-ass.net>
 <20160104221323-mutt-send-email-mst@redhat.com>
 <20160105091319.59ddefc7@mschwide>
 <20160105105335-mutt-send-email-mst@redhat.com>
 <20160105130852.11148a7f@mschwide>
In-Reply-To: <20160105130852.11148a7f@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo@kernel.o>

On Tue, Jan 05, 2016 at 01:08:52PM +0100, Martin Schwidefsky wrote:
> On Tue, 5 Jan 2016 11:30:19 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Tue, Jan 05, 2016 at 09:13:19AM +0100, Martin Schwidefsky wrote:
> > > On Mon, 4 Jan 2016 22:18:58 +0200
> > > "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > > 
> > > > On Mon, Jan 04, 2016 at 02:45:25PM +0100, Peter Zijlstra wrote:
> > > > > On Thu, Dec 31, 2015 at 09:08:38PM +0200, Michael S. Tsirkin wrote:
> > > > > > This defines __smp_xxx barriers for s390,
> > > > > > for use by virtualization.
> > > > > > 
> > > > > > Some smp_xxx barriers are removed as they are
> > > > > > defined correctly by asm-generic/barriers.h
> > > > > > 
> > > > > > Note: smp_mb, smp_rmb and smp_wmb are defined as full barriers
> > > > > > unconditionally on this architecture.
> > > > > > 
> > > > > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > > > > Acked-by: Arnd Bergmann <arnd@arndb.de>
> > > > > > ---
> > > > > >  arch/s390/include/asm/barrier.h | 15 +++++++++------
> > > > > >  1 file changed, 9 insertions(+), 6 deletions(-)
> > > > > > 
> > > > > > diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
> > > > > > index c358c31..fbd25b2 100644
> > > > > > --- a/arch/s390/include/asm/barrier.h
> > > > > > +++ b/arch/s390/include/asm/barrier.h
> > > > > > @@ -26,18 +26,21 @@
> > > > > >  #define wmb()				barrier()
> > > > > >  #define dma_rmb()			mb()
> > > > > >  #define dma_wmb()			mb()
> > > > > > -#define smp_mb()			mb()
> > > > > > -#define smp_rmb()			rmb()
> > > > > > -#define smp_wmb()			wmb()
> > > > > > -
> > > > > > -#define smp_store_release(p, v)						\
> > > > > > +#define __smp_mb()			mb()
> > > > > > +#define __smp_rmb()			rmb()
> > > > > > +#define __smp_wmb()			wmb()
> > > > > > +#define smp_mb()			__smp_mb()
> > > > > > +#define smp_rmb()			__smp_rmb()
> > > > > > +#define smp_wmb()			__smp_wmb()
> > > > > 
> > > > > Why define the smp_*mb() primitives here? Would not the inclusion of
> > > > > asm-generic/barrier.h do this?
> > > > 
> > > > No because the generic one is a nop on !SMP, this one isn't.
> > > > 
> > > > Pls note this patch is just reordering code without making
> > > > functional changes.
> > > > And at the moment, on s390 smp_xxx barriers are always non empty.
> > > 
> > > The s390 kernel is SMP to 99.99%, we just didn't bother with a
> > > non-smp variant for the memory-barriers. If the generic header
> > > is used we'd get the non-smp version for free. It will save a
> > > small amount of text space for CONFIG_SMP=n. 
> > 
> > OK, so I'll queue a patch to do this then?
> 
> Yes please.

OK, I'll add a patch on top in v3.

> > Just to make sure: the question would be, are smp_xxx barriers ever used
> > in s390 arch specific code to flush in/out memory accesses for
> > synchronization with the hypervisor?
> > 
> > I went over s390 arch code and it seems to me the answer is no
> > (except of course for virtio).
> 
> Correct. Guest to host communication either uses instructions which
> imply a memory barrier or QDIO which uses atomics.

And atomics imply a barrier on s390, right?

> > But I also see a lot of weirdness on this architecture.
> 
> Mostly historical, s390 actually is one of the easiest architectures in
> regard to memory barriers.
> 
> > I found these calls:
> > 
> > arch/s390/include/asm/bitops.h: smp_mb__before_atomic();
> > arch/s390/include/asm/bitops.h: smp_mb();
> > 
> > Not used in arch specific code so this is likely OK.
> 
> This has been introduced with git commit 5402ea6af11dc5a9, the smp_mb
> and smp_mb__before_atomic are used in clear_bit_unlock and
> __clear_bit_unlock which are 1:1 copies from the code in
> include/asm-generic/bitops/lock.h. Only test_and_set_bit_lock differs
> from the generic implementation.

something to keep in mind, but
I'd rather not touch bitops at the moment - this patchset is already too big.

> > arch/s390/kernel/vdso.c:        smp_mb();
> > 
> > Looking at
> > 	Author: Christian Borntraeger <borntraeger@de.ibm.com>
> > 	Date:   Fri Sep 11 16:23:06 2015 +0200
> > 
> > 	    s390/vdso: use correct memory barrier
> > 
> > 	    By definition smp_wmb only orders writes against writes. (Finish all
> > 	    previous writes, and do not start any future write). To protect the
> > 	    vdso init code against early reads on other CPUs, let's use a full
> > 	    smp_mb at the end of vdso init. As right now smp_wmb is implemented
> > 	    as full serialization, this needs no stable backport, but this change
> > 	    will be necessary if we reimplement smp_wmb.
> > 
> > ok from hypervisor point of view, but it's also strange:
> > 1. why isn't this paired with another mb somewhere?
> >    this seems to violate barrier pairing rules.
> > 2. how does smp_mb protect against early reads on other CPUs?
> >    It normally does not: it orders reads from this CPU versus writes
> >    from same CPU. But init code does not appear to read anything.
> >    Maybe this is some s390 specific trick?
> > 
> > I could not figure out the above commit.
> 
> That smp_mb can be removed. The initial s390 vdso code is heavily influenced
> by the powerpc version which does have a smp_wmb in vdso_init right before
> the vdso_ready=1 assignment. s390 has no need for that.
>  
> > 
> > arch/s390/kvm/kvm-s390.c:       smp_mb();
> > 
> > Does not appear to be paired with anything.
> 
> This one does not make sense to me. Imho can be removed as well. 
>  
> > arch/s390/lib/spinlock.c:               smp_mb();
> > arch/s390/lib/spinlock.c:                       smp_mb();
> > 
> > Seems ok, and appears paired properly.
> > Just to make sure - spinlock is not paravirtualized on s390, is it?
> 
> s390 just uses the compare-and-swap instruction for the basic lock/unlock
> operation, this implies the memory barrier. We do call the hypervisor for
> contended locks if the lock can not be acquired after a number of retries.
> 
> A while ago we did play with ticket spinlocks but they behaved badly in
> out usual virtualized environments. If we find the time we might take a
> closer look at the para-virtualized queued spinlocks.
> 
> > rch/s390/kernel/time.c:        smp_wmb();
> > arch/s390/kernel/time.c:        smp_wmb();
> > arch/s390/kernel/time.c:        smp_wmb();
> > arch/s390/kernel/time.c:        smp_wmb();
> > 
> > It's all around vdso, so I'm guessing userspace is using this,
> > this is why there's no pairing.
> 
> Correct, this is the update count mechanics with the vdso user space code.
> 
> > > > Some of this could be sub-optimal, but
> > > > since on s390 Linux always runs on a hypervisor,
> > > > I am not sure it's safe to use the generic version -
> > > > in other words, it just might be that for s390 smp_ and virt_
> > > > barriers must be equivalent.
> > > 
> > > The definition of the memory barriers is independent from the fact
> > > if the system is running on an hypervisor or not.
> > > Is there really
> > > an architecture where you need special virt_xxx barriers?!? 
> > 
> > It is whenever host and guest or two guests access memory at
> > the same time.
> > 
> > The optimization where smp_xxx barriers are compiled out when
> > CONFIG_SMP is cleared means that two UP guests running
> > on an SMP host can not use smp_xxx barriers for communication.
> > 
> > See explanation here:
> > http://thread.gmane.org/gmane.linux.kernel.virtualization/26555
> 
> Got it, makes sense.

An ack would be appreciated.

> -- 
> blue skies,
>    Martin.
> 
> "Reality continues to ruin my life." - Calvin.
