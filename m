From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Fri, 04 Apr 2003 14:43:29 +0000
Subject: RE: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705417@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jes,

I think I have a decent understanding, but every time I start to
think that my brain explodes on another case...

> I have been tracing a problem with tty->count hitting an unidenfied
> state and I am starting to ponder if our current spin_unlock()
> implementation is sufficient.
>
> Currently the spin_unlock() implementation looks like this:

> #define spin_unlock(x)  do { barrier(); ((spinlock_t *) x)->lock
= 0;} while (0)

> barrier() doesn't guarantee memory ordering, in other words, we are not
> guaranteed that writes have been flushed to physical memory on exit. Now
> Jesse pointed out to me that spin_lock() uses aquire semantics which
> should take care of this, however this is only the case if the other CPU
> grabs a spin lock before reading the variable we wrote while holding the
> lock.

Yes, I think spin_unlock should have release semantics.
barrier() is used to prevent the compiler from reordering loads/stores,
but does not stop the processor from doing so.

...

> With our weak memory ordering, b might have been written back to memory
> while a still hasn't made it out. Or am I missing something here?

> The question is, shouldn't our spin_unlock() implementation call wmb()
> instead of barrier()? I noticed Alpha calls mb() in their spin_unlock()
> implementation.

The first example you gave certainly should work (but may not due to
the missing release on unlock); the second one you gave is NOT guaranteed
to work without you changing the code: the store to b can pass
the unlock, even with release semantics, and hence also the store to a,
(although it cannot pass the spin_lock).  (Note: if you use a wbm,
it will work, since that implements fence semantics instead of just release
semantics)

Kevin

