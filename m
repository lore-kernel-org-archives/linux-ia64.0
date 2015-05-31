From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 31 May 2015 19:20:08 +0000
Subject: Re: [PATCH] ia64: make cpu_callin_map non-volatile.
Message-Id: <CA+55aFxCvBV-7PZRyQ_5_X1ASVJR1QV-S6zTJs1jK-Pu4Q3Naw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <646392f4ff5b292164cd53c2a08cbced6b96171e.1432850232.git.tony.luck@intel.com>
In-Reply-To: <646392f4ff5b292164cd53c2a08cbced6b96171e.1432850232.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 26, 2015 at 6:18 PM, Luck, Tony <tony.luck@intel.com> wrote:
>
> cpumask_test_cpu() doesn't take volatile, unlike the obsoleted
> cpu_isset.  The only place ia64 really cares is the spin waiting for a
> bit; udelay() is probably a barrier but insert rmb() to be sure.

Hmm. udelay() definitely should be a barrier, so this patch shouldn't
matter. But even if it weren't, rmb() would be the wrong barrier to
use here.

rmb() is a "CPU or IO read barrier" to order reads wrt other cores or
DMA, and needs to be paired with a wmb() on other cores (and for DMA
it is assumed that there is sufficiently write ordering for the DMA
itself).

If it's about just other CPU's, it would be "smp_rmb()", which is
often much cheaper (due to no IO serialization, particularly on
POWER).

But in this case it doesn't seem to be about other agents at all
(CPU's or DMA), you literally are just looking for a compiler barrier
to make sure the read doesn't get moved out of the loop. And the
function for that is just "barrier()".

So I'm skipping this patch, because I dont' think it changes anything
real, and from a "let's be careful" standpoint it's actually doing the
wrong thing.

                       Linus
