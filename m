From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 13 Dec 2006 18:28:16 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <Pine.LNX.4.64.0612131024510.19913@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Dec 2006, Zoltan Menyhart wrote:

> How much is the probability that the bit is not set?

Depends on the load on the system. Typically very much near 100%

> Adding a test can cost only a few cycles, say max 4.

But it reduces the performance of the commonly taken code path.

> For an atomic operation, you need to go out and snoop.
> 
> Let's have a look at e.g. the "bit_spin_lock()":
> 
> static inline void bit_spin_lock(int bitnum, unsigned long *addr)
> {
>        preempt_disable();
>        while (test_and_set_bit(bitnum, addr)) {
>                while (test_bit(bitnum, addr)) {
>                        preempt_enable();
>                        cpu_relax();
>                        preempt_disable();
>                }
>        }
>        __acquire(bitlock);
> }
> 
> By executing the atomic operation unconditionally, you kill
> the cache line all the other waiting processors looping at.

But note also that we optimize the common case, the case that the test and 
set bit are successful. Only if it was not successful will we do non 
atomic loads. This is done to avoid cachelines bouncing while the lock is 
contended.

