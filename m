From: Olof Johansson <olof@lixom.net>
Date: Fri, 23 Dec 2005 20:48:22 +0000
Subject: Re: [PATCH] - Fix memory ordering problem in wake_futex()
Message-Id: <20051223204822.GC24601@pb15.lixom.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051223163816.GA30906@sgi.com>
In-Reply-To: <20051223163816.GA30906@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, Dec 23, 2005 at 10:38:16AM -0600, Jack Steiner wrote:
> 
> Here is a fix for a ugly race condition that occurs in wake_futex() on IA64.
> 
> On IA64, locks are released using a "st.rel" instruction. This ensures that
> preceding "stores" are visible before the lock is released but does NOT prevent
> a "store" that follows the "st.rel" from becoming visible before the "st.rel".
> The result is that the task that owns the futex_q continues prematurely. 
> 
> The failure I saw is the task that owned the futex_q resumed prematurely and
> was context-switch off of the cpu. The task's switch_stack occupied the same
> space of the futex_q. The store to q->lock_ptr overwrote the ar.bspstore in the
> switch_stack. When the task resumed, it ran with a corrupted ar.bspstore.
> Things went downhill from there.
> 
> Without the fix, the application fails roughly every 10 minutes. With
> the fix, it ran 16 hours without a failure.

So what happened to what the comment 10 lines above your patch says?

        /*
         * The lock in wake_up_all() is a crucial memory barrier after
         * the list_del_init() and also before assigning to q->lock_ptr.
         */

On PPC64, the spinlock unlock path has a sync in there for the very
purpose of adding the write barrier. Maybe the ia64 unlock path is
missing something similar?


-Olof
