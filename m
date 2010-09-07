From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 07 Sep 2010 13:17:41 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201009071517.43009.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <AANLkTikZRiQ5jCpgp42LxtXb_S52sSUy7KP_=vZ3z4Tf@mail.gmail.com> <201009061647.02345.ptesarik@suse.cz>
In-Reply-To: <201009061647.02345.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi all,

On Monday 06 of September 2010 16:47:01 Petr Tesarik wrote:
>[...]
> To sum it up:
>
>[...]
> 2. So far, the problem has been observed only after the spinlock value
> changes to zero.

I thought about this point for a while, and then I decided to test this with 
brute force. Why not simply skip the zero? If I shift the head position to 
the right within the lock, I can iterate over odd numbers only. 
Unfortunately, the ia64 platform does not have a fetchadd4 variant with an 
increment of 2, so I had to reduce the size of the head/tail to 14 bits, but 
that's still sufficient for all today's machines. Anyway, I do NOT propose 
this as a solution, rather as a proof of concept.

Anyway, after applying the following patch, the test case provided by Hedi has 
been running for a few hours already. Now, I'm confident this is a hardware 
bug.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

diff --git a/arch/ia64/include/asm/spinlock.h 
b/arch/ia64/include/asm/spinlock.h
index f0816ac..01be28e 100644
--- a/arch/ia64/include/asm/spinlock.h
+++ b/arch/ia64/include/asm/spinlock.h
@@ -26,23 +26,28 @@
  * The pad bits in the middle are used to prevent the next_ticket number
  * overflowing into the now_serving number.
  *
- *   31             17  16    15  14                    0
+ *   31             18  17    16  15               2  1 0
  *  +----------------------------------------------------+
- *  |  now_serving     | padding |   next_ticket         |
+ *  |  now_serving     | padding |   next_ticket     | - |
  *  +----------------------------------------------------+
  */
 
-#define TICKET_SHIFT	17
-#define TICKET_BITS	15
+#define TICKET_HSHIFT	2
+#define TICKET_TSHIFT	18
+#define TICKET_BITS	14
 #define	TICKET_MASK	((1 << TICKET_BITS) - 1)
 
+#define __ticket_spin_is_unlocked(ticket, serve) \
+	(!((((serve) >> (TICKET_TSHIFT - TICKET_HSHIFT)) ^ (ticket)) \
+	   & (TICKET_MASK << TICKET_HSHIFT)))
+
 static __always_inline void __ticket_spin_lock(arch_spinlock_t *lock)
 {
 	int	*p = (int *)&lock->lock, ticket, serve;
 
-	ticket = ia64_fetchadd(1, p, acq);
+	ticket = ia64_fetchadd(1 << TICKET_HSHIFT, p, acq);
 
-	if (!(((ticket >> TICKET_SHIFT) ^ ticket) & TICKET_MASK))
+	if (__ticket_spin_is_unlocked(ticket, ticket))
 		return;
 
 	ia64_invala();
@@ -50,7 +55,7 @@ static __always_inline void 
__ticket_spin_lock(arch_spinlock_t *lock)
 	for (;;) {
 		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(serve) : "r"(p) : "memory");
 
-		if (!(((serve >> TICKET_SHIFT) ^ ticket) & TICKET_MASK))
+		if (__ticket_spin_is_unlocked(ticket, serve))
 			return;
 		cpu_relax();
 	}
@@ -60,8 +65,8 @@ static __always_inline int 
__ticket_spin_trylock(arch_spinlock_t *lock)
 {
 	int tmp = ACCESS_ONCE(lock->lock);
 
-	if (!(((tmp >> TICKET_SHIFT) ^ tmp) & TICKET_MASK))
-		return ia64_cmpxchg(acq, &lock->lock, tmp, tmp + 1, sizeof (tmp)) = tmp;
+	if (__ticket_spin_is_unlocked(tmp, tmp))
+		return ia64_cmpxchg(acq, &lock->lock, tmp, tmp + (1 << TICKET_HSHIFT), 
sizeof (tmp)) = tmp;
 	return 0;
 }
 
@@ -70,7 +75,7 @@ static __always_inline void 
__ticket_spin_unlock(arch_spinlock_t *lock)
 	unsigned short	*p = (unsigned short *)&lock->lock + 1, tmp;
 
 	asm volatile ("ld2.bias %0=[%1]" : "=r"(tmp) : "r"(p));
-	ACCESS_ONCE(*p) = (tmp + 2) & ~1;
+	ACCESS_ONCE(*p) = (tmp + (1 << (TICKET_TSHIFT - 16))) & ~1;
 }
 
 static __always_inline void __ticket_spin_unlock_wait(arch_spinlock_t *lock)
@@ -81,7 +86,7 @@ static __always_inline void 
__ticket_spin_unlock_wait(arch_spinlock_t *lock)
 
 	for (;;) {
 		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(ticket) : "r"(p) : "memory");
-		if (!(((ticket >> TICKET_SHIFT) ^ ticket) & TICKET_MASK))
+		if (__ticket_spin_is_unlocked(ticket, ticket))
 			return;
 		cpu_relax();
 	}
@@ -91,14 +96,14 @@ static inline int __ticket_spin_is_locked(arch_spinlock_t 
*lock)
 {
 	long tmp = ACCESS_ONCE(lock->lock);
 
-	return !!(((tmp >> TICKET_SHIFT) ^ tmp) & TICKET_MASK);
+	return !__ticket_spin_is_unlocked(tmp, tmp);
 }
 
 static inline int __ticket_spin_is_contended(arch_spinlock_t *lock)
 {
 	long tmp = ACCESS_ONCE(lock->lock);
 
-	return ((tmp - (tmp >> TICKET_SHIFT)) & TICKET_MASK) > 1;
+	return (((tmp >> TICKET_HSHIFT) - (tmp >> TICKET_TSHIFT)) & TICKET_MASK) > 
1;
 }
 
 static inline int arch_spin_is_locked(arch_spinlock_t *lock)
diff --git a/arch/ia64/include/asm/spinlock_types.h 
b/arch/ia64/include/asm/spinlock_types.h
index e2b42a5..4275cd3 100644
--- a/arch/ia64/include/asm/spinlock_types.h
+++ b/arch/ia64/include/asm/spinlock_types.h
@@ -9,7 +9,7 @@ typedef struct {
 	volatile unsigned int lock;
 } arch_spinlock_t;
 
-#define __ARCH_SPIN_LOCK_UNLOCKED	{ 0 }
+#define __ARCH_SPIN_LOCK_UNLOCKED	{ 1 }
 
 typedef struct {
 	volatile unsigned int read_counter	: 31;
