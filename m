From: Will Deacon <will.deacon@arm.com>
Date: Thu, 14 Jan 2016 12:04:45 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160114120445.GB15828@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <56945366.2090504@imgtec.com>
 <20160112092711.GP6344@twins.programming.kicks-ass.net>
 <20160112102555.GV6373@twins.programming.kicks-ass.net>
 <20160112104012.GW6373@twins.programming.kicks-ass.net>
 <20160112114111.GB15737@arm.com>
 <569565DA.2010903@imgtec.com>
 <20160113104516.GE25458@arm.com>
 <56969F4B.7070001@imgtec.com>
 <20160113204844.GV6357@twins.programming.kicks-ass.net>
 <5696BA6E.4070508@imgtec.com>
In-Reply-To: <5696BA6E.4070508-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

On Wed, Jan 13, 2016 at 12:58:22PM -0800, Leonid Yegoshin wrote:
> On 01/13/2016 12:48 PM, Peter Zijlstra wrote:
> >On Wed, Jan 13, 2016 at 11:02:35AM -0800, Leonid Yegoshin wrote:
> >
> >>I ask HW team about it but I have a question - has it any relationship with
> >>replacing MIPS SYNC with lightweight SYNCs (SYNC_WMB etc)?
> >Of course. If you cannot explain the semantics of the primitives you
> >introduce, how can we judge the patch.
> >
> >
> You missed a point - it is a question about replacement of SYNC with
> lightweight primitives. It is NOT a question about multithread system
> behavior without any SYNC. The answer on a latest Will's question lies in
> different area.

The reason we (Peter and I) care about this isn't because we enjoy being
obstructive. It's because there is a whole load of core (i.e. portable)
kernel code that is written to the *kernel* memory model. For example,
the scheduler, RCU, mutex implementations, perf, drivers, you name it.

Consequently, it's important that the architecture back-ends implement
these portable primitives (e.g. smp_mb()) in a way that satisfies the
kernel memory model so that core code doesn't need to worry about the
underlying architecture for synchronisation purposes. You could turn
around and say "but if MIPS gets it wrong, then that's MIPS's problem",
but actually not having a general understanding of the ordering guarantees
provided by each architecture makes it very difficult for us to extend
the kernel memory model in such a way that it can be implemented
efficiently across the board *and* relied upon by core code.

The virtio patch at the start of the thread doesn't particularly concern
me. It's the other patches you linked to that implement acquire/release
that have me worried.

Will
