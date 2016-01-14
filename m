From: Will Deacon <will.deacon@arm.com>
Date: Thu, 14 Jan 2016 12:14:50 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160114121449.GC15828@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com>
 <56945366.2090504@imgtec.com>
 <20160112092711.GP6344@twins.programming.kicks-ass.net>
 <20160112102555.GV6373@twins.programming.kicks-ass.net>
 <20160112104012.GW6373@twins.programming.kicks-ass.net>
 <20160112114111.GB15737@arm.com>
 <569565DA.2010903@imgtec.com>
 <20160113104516.GE25458@arm.com>
 <5696CF08.8080700@imgtec.com>
In-Reply-To: <5696CF08.8080700-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

On Wed, Jan 13, 2016 at 02:26:16PM -0800, Leonid Yegoshin wrote:
> On 01/13/2016 02:45 AM, Will Deacon wrote:
> >>
> >I don't think the address dependency is enough on its own. By that
> >reasoning, the following variant (WRC+addr+addr) would work too:
> >
> >
> >P0:
> >Wx = 1
> >
> >P1:
> >Rx = 1
> ><address dep>
> >Wy = 1
> >
> >P2:
> >Ry = 1
> ><address dep>
> >Rx = 0
> >
> >
> >So are you saying that this is also forbidden?
> >Imagine that P0 and P1 are two threads that share a store buffer. What
> >then?
> 
> OK, I collected answers and it is:
> 
>     In MIPS R6 this test passes OK, I mean - P2: Rx = 1 if Ry is read as 1.
> By design.
> 
>     However, it is unclear that happens in MIPS R2 1004K.

How can it be unclear? If, for example, the outcome is permitted on that
CPU, then your original reasoning for the WRC+sync+addr doesn't apply
there and SYNC is not transitive. That's what I'm trying to get to the
bottom of.

Does the MIPS kernel target a particular CPU at compile time?

>     Moreover, there are voices against guarantee that it will be in future
> and that voices point me to Documentation/memory-barriers.txt section "DATA
> DEPENDENCY BARRIERS" examples which require SYNC_RMB between loading
> address/index and using that for loading data based on that address or index
> for shared data (look on CPU2 pseudo-code):
> >To deal with this, a data dependency barrier or better must be inserted
> >between the address load and the data load:
> >
> >        CPU 1                 CPU 2
> >        ========       =======> >        { A = 1, B = 2, C = 3, P = &A, Q = &C }
> >        B = 4;
> >        <write barrier>
> >        WRITE_ONCE(P, &B);
> >                              Q = READ_ONCE(P);
> >                              <data dependency barrier> <-----------
> >SYNC_RMB is here
> >                              D = *Q;
> ...
> >Another example of where data dependency barriers might be required is
> >where a
> >number is read from memory and then used to calculate the index for an
> >array
> >access:
> >
> >        CPU 1                 CPU 2
> >        ========       =======> >        { M[0] = 1, M[1] = 2, M[3] = 3, P = 0, Q = 3 }
> >        M[1] = 4;
> >        <write barrier>
> >        WRITE_ONCE(P, 1);
> >                              Q = READ_ONCE(P);
> >                              <data dependency barrier> <------------
> >SYNC_RMB is here
> >                              D = M[Q];
> 
> That voices say that there is a legitimate reason to relax HW here for
> performance if SYNC_RMB is needed anyway to work with this sequence of
> shared data.

Are you saying that MIPS needs to implement [smp_]read_barrier_depends?

> And all that is out-of-topic here in my mind. I just want to be sure that
> this patchset still provides a use of a specific lightweight SYNCs on MIPS
> vs bold and heavy generalized "SYNC 0" in any case.

We may be highjacking the thread slightly, but there are much bigger
issues at play here if you want to start using lightweight barriers to
implement relaxed kernel primitives such as smp_load_acquire and
smp_store_release.

Will
