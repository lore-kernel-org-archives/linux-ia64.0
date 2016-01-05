From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 05 Jan 2016 09:30:19 +0000
Subject: Re: [PATCH v2 22/32] s390: define __smp_xxx
Message-Id: <20160105105335-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-23-git-send-email-mst@redhat.com>
 <20160104134525.GA6344@twins.programming.kicks-ass.net>
 <20160104221323-mutt-send-email-mst@redhat.com>
 <20160105091319.59ddefc7@mschwide>
In-Reply-To: <20160105091319.59ddefc7@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Heiko Carstens <heiko.carstens@de.ibm.com>, Ingo Molnar <mingo@kernel.o>

On Tue, Jan 05, 2016 at 09:13:19AM +0100, Martin Schwidefsky wrote:
> On Mon, 4 Jan 2016 22:18:58 +0200
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > On Mon, Jan 04, 2016 at 02:45:25PM +0100, Peter Zijlstra wrote:
> > > On Thu, Dec 31, 2015 at 09:08:38PM +0200, Michael S. Tsirkin wrote:
> > > > This defines __smp_xxx barriers for s390,
> > > > for use by virtualization.
> > > > 
> > > > Some smp_xxx barriers are removed as they are
> > > > defined correctly by asm-generic/barriers.h
> > > > 
> > > > Note: smp_mb, smp_rmb and smp_wmb are defined as full barriers
> > > > unconditionally on this architecture.
> > > > 
> > > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > > Acked-by: Arnd Bergmann <arnd@arndb.de>
> > > > ---
> > > >  arch/s390/include/asm/barrier.h | 15 +++++++++------
> > > >  1 file changed, 9 insertions(+), 6 deletions(-)
> > > > 
> > > > diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
> > > > index c358c31..fbd25b2 100644
> > > > --- a/arch/s390/include/asm/barrier.h
> > > > +++ b/arch/s390/include/asm/barrier.h
> > > > @@ -26,18 +26,21 @@
> > > >  #define wmb()				barrier()
> > > >  #define dma_rmb()			mb()
> > > >  #define dma_wmb()			mb()
> > > > -#define smp_mb()			mb()
> > > > -#define smp_rmb()			rmb()
> > > > -#define smp_wmb()			wmb()
> > > > -
> > > > -#define smp_store_release(p, v)						\
> > > > +#define __smp_mb()			mb()
> > > > +#define __smp_rmb()			rmb()
> > > > +#define __smp_wmb()			wmb()
> > > > +#define smp_mb()			__smp_mb()
> > > > +#define smp_rmb()			__smp_rmb()
> > > > +#define smp_wmb()			__smp_wmb()
> > > 
> > > Why define the smp_*mb() primitives here? Would not the inclusion of
> > > asm-generic/barrier.h do this?
> > 
> > No because the generic one is a nop on !SMP, this one isn't.
> > 
> > Pls note this patch is just reordering code without making
> > functional changes.
> > And at the moment, on s390 smp_xxx barriers are always non empty.
> 
> The s390 kernel is SMP to 99.99%, we just didn't bother with a
> non-smp variant for the memory-barriers. If the generic header
> is used we'd get the non-smp version for free. It will save a
> small amount of text space for CONFIG_SMP=n. 

OK, so I'll queue a patch to do this then?

Just to make sure: the question would be, are smp_xxx barriers ever used
in s390 arch specific code to flush in/out memory accesses for
synchronization with the hypervisor?

I went over s390 arch code and it seems to me the answer is no
(except of course for virtio).

But I also see a lot of weirdness on this architecture.

I found these calls:

arch/s390/include/asm/bitops.h: smp_mb__before_atomic();
arch/s390/include/asm/bitops.h: smp_mb();

Not used in arch specific code so this is likely OK.

arch/s390/kernel/vdso.c:        smp_mb();

Looking at
	Author: Christian Borntraeger <borntraeger@de.ibm.com>
	Date:   Fri Sep 11 16:23:06 2015 +0200

	    s390/vdso: use correct memory barrier

	    By definition smp_wmb only orders writes against writes. (Finish all
	    previous writes, and do not start any future write). To protect the
	    vdso init code against early reads on other CPUs, let's use a full
	    smp_mb at the end of vdso init. As right now smp_wmb is implemented
	    as full serialization, this needs no stable backport, but this change
	    will be necessary if we reimplement smp_wmb.

ok from hypervisor point of view, but it's also strange:
1. why isn't this paired with another mb somewhere?
   this seems to violate barrier pairing rules.
2. how does smp_mb protect against early reads on other CPUs?
   It normally does not: it orders reads from this CPU versus writes
   from same CPU. But init code does not appear to read anything.
   Maybe this is some s390 specific trick?

I could not figure out the above commit.


arch/s390/kvm/kvm-s390.c:       smp_mb();

Does not appear to be paired with anything.


arch/s390/lib/spinlock.c:               smp_mb();
arch/s390/lib/spinlock.c:                       smp_mb();

Seems ok, and appears paired properly.
Just to make sure - spinlock is not paravirtualized on s390, is it?

rch/s390/kernel/time.c:        smp_wmb();
arch/s390/kernel/time.c:        smp_wmb();
arch/s390/kernel/time.c:        smp_wmb();
arch/s390/kernel/time.c:        smp_wmb();

It's all around vdso, so I'm guessing userspace is using this,
this is why there's no pairing.



> > Some of this could be sub-optimal, but
> > since on s390 Linux always runs on a hypervisor,
> > I am not sure it's safe to use the generic version -
> > in other words, it just might be that for s390 smp_ and virt_
> > barriers must be equivalent.
> 
> The definition of the memory barriers is independent from the fact
> if the system is running on an hypervisor or not.
> Is there really
> an architecture where you need special virt_xxx barriers?!? 

It is whenever host and guest or two guests access memory at
the same time.

The optimization where smp_xxx barriers are compiled out when
CONFIG_SMP is cleared means that two UP guests running
on an SMP host can not use smp_xxx barriers for communication.

See explanation here:
http://thread.gmane.org/gmane.linux.kernel.virtualization/26555

> -- 
> blue skies,
>    Martin.
> 
> "Reality continues to ruin my life." - Calvin.
