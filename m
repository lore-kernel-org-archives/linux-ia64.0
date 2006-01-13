From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 13 Jan 2006 16:25:23 +0000
Subject: Re: Bug in ia64 specific down() function??
Message-Id: <43C7D473.8010706@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601120138.k0C1cEg03582@unix-os.sc.intel.com>
In-Reply-To: <200601120138.k0C1cEg03582@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> The memory order semantics for include/asm-ia64/semaphore.h:down()
> doesn't look right.  It is using atomic_dec_return, which eventually
> translate into ia64_fetch_and_add() that uses release semantics.
> Shouldn't it use acquire semantics?

What about this one:

--- linux-2.6.15-test/include/asm-ia64/semaphore.h	2006-01-10 13:54:31.000000000 +0100
+++ linux-2.6.15-test-down/include/asm-ia64/semaphore.h	2006-01-13 16:16:04.000000000 +0100
@@ -61,7 +61,7 @@ down (struct semaphore * sem)
 down (struct semaphore *sem)
 {
 	might_sleep();
-	if (atomic_dec_return(&sem->count) < 0)
+	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
 		__down(sem);
 }
 
@@ -75,7 +75,7 @@ down_interruptible (struct semaphore * sem)
 	int ret = 0;
 
 	might_sleep();
-	if (atomic_dec_return(&sem->count) < 0)
+	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
 		ret = __down_interruptible(sem);
 	return ret;
 }
@@ -85,7 +85,7 @@ down_trylock (struct semaphore *sem)
 {
 	int ret = 0;
 
-	if (atomic_dec_return(&sem->count) < 0)
+	if (ia64_fetchadd(-1, &sem->count.counter, acq) < 1)
 		ret = __down_trylock(sem);
 	return ret;
 }
@@ -93,7 +93,7 @@ up (struct semaphore *sem)
 static inline void
 up (struct semaphore * sem)
 {
-	if (atomic_inc_return(&sem->count) <= 0)
+	if (ia64_fetchadd(1, &sem->count.counter, rel) <= -1)
 		__up(sem);
 }

I do not like the too long chains of the macro definitions which --
as the example shows -- hide how the things work.
This is why I used "ia64_fetchadd()".
("IA64_FETCHADD()" is a bit nasty.)

"__down_interruptible()" and "__down()" could be cleaned up too, but
the atomic operation on the semaphore is followed by a wakeup, that
includes taking a lock, that provides the ".acq" semantics.

"__down_trylock()" is called on failure, the data area protected
by the semaphore will not be touched by the caller.

Zoltan Menyhart
