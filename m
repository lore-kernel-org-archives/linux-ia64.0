From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 05 Jan 2016 16:04:00 +0000
Subject: Re: [PATCH v2 22/32] s390: define __smp_xxx
Message-Id: <20160105180225-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-23-git-send-email-mst@redhat.com>
 <20160104134525.GA6344@twins.programming.kicks-ass.net>
 <20160104221323-mutt-send-email-mst@redhat.com>
 <20160105091319.59ddefc7@mschwide>
 <20160105105335-mutt-send-email-mst@redhat.com>
 <568BE3B9.8020901@de.ibm.com>
In-Reply-To: <568BE3B9.8020901@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Heiko Carstens <heiko.cars>

On Tue, Jan 05, 2016 at 04:39:37PM +0100, Christian Borntraeger wrote:
> On 01/05/2016 10:30 AM, Michael S. Tsirkin wrote:
> 
> > 
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
> It was probably me misreading the code. I change a wmb into a full mb here
> since I was changing the defintion of wmb to a compiler barrier. I tried to
> fixup all users of wmb that really pair with other code. I assumed that there
> must be some reader (as there was a wmb before) but I could not figure out
> which. So I just played safe here.
> 
> But it probably can be removed.
> 
> > arch/s390/kvm/kvm-s390.c:       smp_mb();
> 
> This can go. If you have a patch, I can carry that via the kvms390 tree,
> or I will spin a new patch with you as suggested-by.
> 
> Christian

I have both, will post shortly.

-- 
MST
