From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 04 Apr 2003 04:51:04 +0000
Subject: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705414@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have been tracing a problem with tty->count hitting an unidenfied
state and I am starting to ponder if our current spin_unlock()
implementation is sufficient.

Currently the spin_unlock() implementation looks like this:

#define spin_unlock(x)		do { barrier(); ((spinlock_t *) x)->lock = 0;} while (0)

barrier() doesn't guarantee memory ordering, in other words, we are not
guaranteed that writes have been flushed to physical memory on exit. Now
Jesse pointed out to me that spin_lock() uses aquire semantics which
should take care of this, however this is only the case if the other CPU
grabs a spin lock before reading the variable we wrote while holding the
lock.

Consider the following example:

cpu1()
{
   spin_lock(&bleh);
   *a = foo;
   *b = bar;
   spin_unlock(&bleh);
}

cpu2()
{
   if (*b = bar)
      boink(*a);
}

With our weak memory ordering, b might have been written back to memory
while a still hasn't made it out. Or am I missing something here?

The question is, shouldn't our spin_unlock() implementation call wmb()
instead of barrier()? I noticed Alpha calls mb() in their spin_unlock()
implementation.

Cheers,
Jes

