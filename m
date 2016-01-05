From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Tue, 05 Jan 2016 15:39:37 +0000
Subject: Re: [PATCH v2 22/32] s390: define __smp_xxx
Message-Id: <568BE3B9.8020901@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-23-git-send-email-mst@redhat.com>
 <20160104134525.GA6344@twins.programming.kicks-ass.net>
 <20160104221323-mutt-send-email-mst@redhat.com>
 <20160105091319.59ddefc7@mschwide>
 <20160105105335-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160105105335-mutt-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo@kernel.o>

On 01/05/2016 10:30 AM, Michael S. Tsirkin wrote:

> 
> arch/s390/kernel/vdso.c:        smp_mb();
> 
> Looking at
> 	Author: Christian Borntraeger <borntraeger@de.ibm.com>
> 	Date:   Fri Sep 11 16:23:06 2015 +0200
> 
> 	    s390/vdso: use correct memory barrier
> 
> 	    By definition smp_wmb only orders writes against writes. (Finish all
> 	    previous writes, and do not start any future write). To protect the
> 	    vdso init code against early reads on other CPUs, let's use a full
> 	    smp_mb at the end of vdso init. As right now smp_wmb is implemented
> 	    as full serialization, this needs no stable backport, but this change
> 	    will be necessary if we reimplement smp_wmb.
> 
> ok from hypervisor point of view, but it's also strange:
> 1. why isn't this paired with another mb somewhere?
>    this seems to violate barrier pairing rules.
> 2. how does smp_mb protect against early reads on other CPUs?
>    It normally does not: it orders reads from this CPU versus writes
>    from same CPU. But init code does not appear to read anything.
>    Maybe this is some s390 specific trick?
> 
> I could not figure out the above commit.

It was probably me misreading the code. I change a wmb into a full mb here
since I was changing the defintion of wmb to a compiler barrier. I tried to
fixup all users of wmb that really pair with other code. I assumed that there
must be some reader (as there was a wmb before) but I could not figure out
which. So I just played safe here.

But it probably can be removed.

> arch/s390/kvm/kvm-s390.c:       smp_mb();

This can go. If you have a patch, I can carry that via the kvms390 tree,
or I will spin a new patch with you as suggested-by.

Christian

