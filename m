From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sat, 02 Apr 2016 01:17:53 +0000
Subject: Re: [PATCH 02/11] locking, rwsem: drop explicit memory barriers
Message-Id: <20160402011753.GB5329@linux-uzut.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
 <1459508695-14915-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459508695-14915-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Fri, 01 Apr 2016, Michal Hocko wrote:

>From: Michal Hocko <mhocko@suse.com>
>
>sh and xtensa seem to be the only architectures which use explicit
>memory barriers for rw_semaphore operations even though they are not
>really needed because there is the full memory barrier is always implied
>by atomic_{inc,dec,add,sub}_return resp. cmpxchg. Remove them.

Heh, and sh even defines smp_store_mb() with xchg(), which makes the above
even more so.

>
>Signed-off-by: Michal Hocko <mhocko@suse.com>
>---
> arch/sh/include/asm/rwsem.h     | 14 ++------------
> arch/xtensa/include/asm/rwsem.h | 14 ++------------
> 2 files changed, 4 insertions(+), 24 deletions(-)

I think we can actually get rid of these files altogether. While I don't know the archs,
it does not appear to be implementing any kind of workaround/optimization, which is obviously
the whole purpose of defining per-arch rwsem internals, unless the redundant barriers are
actually the purpose. So we could use the generic rwsem.h (which has optimizations and ACQUIRE/
RELEASE semantics, although nops for either sh or xtensa specifically). A first inspection shows
that the code is in fact the same and continue to use 32bit rwsems.

Thanks,
Davidlohr


>diff --git a/arch/sh/include/asm/rwsem.h b/arch/sh/include/asm/rwsem.h
>index a5104bebd1eb..f6c951c7a875 100644
>--- a/arch/sh/include/asm/rwsem.h
>+++ b/arch/sh/include/asm/rwsem.h
>@@ -24,9 +24,7 @@
>  */
> static inline void __down_read(struct rw_semaphore *sem)
> {
>-	if (atomic_inc_return((atomic_t *)(&sem->count)) > 0)
>-		smp_wmb();
>-	else
>+	if (atomic_inc_return((atomic_t *)(&sem->count)) <= 0)
> 		rwsem_down_read_failed(sem);
> }
>
>@@ -37,7 +35,6 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
> 	while ((tmp = sem->count) >= 0) {
> 		if (tmp = cmpxchg(&sem->count, tmp,
> 				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
>-			smp_wmb();
> 			return 1;
> 		}
> 	}
>@@ -53,9 +50,7 @@ static inline void __down_write(struct rw_semaphore *sem)
>
> 	tmp = atomic_add_return(RWSEM_ACTIVE_WRITE_BIAS,
> 				(atomic_t *)(&sem->count));
>-	if (tmp = RWSEM_ACTIVE_WRITE_BIAS)
>-		smp_wmb();
>-	else
>+	if (tmp != RWSEM_ACTIVE_WRITE_BIAS)
> 		rwsem_down_write_failed(sem);
> }
>
>@@ -65,7 +60,6 @@ static inline int __down_write_trylock(struct rw_semaphore *sem)
>
> 	tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> 		      RWSEM_ACTIVE_WRITE_BIAS);
>-	smp_wmb();
> 	return tmp = RWSEM_UNLOCKED_VALUE;
> }
>
>@@ -76,7 +70,6 @@ static inline void __up_read(struct rw_semaphore *sem)
> {
> 	int tmp;
>
>-	smp_wmb();
> 	tmp = atomic_dec_return((atomic_t *)(&sem->count));
> 	if (tmp < -1 && (tmp & RWSEM_ACTIVE_MASK) = 0)
> 		rwsem_wake(sem);
>@@ -87,7 +80,6 @@ static inline void __up_read(struct rw_semaphore *sem)
>  */
> static inline void __up_write(struct rw_semaphore *sem)
> {
>-	smp_wmb();
> 	if (atomic_sub_return(RWSEM_ACTIVE_WRITE_BIAS,
> 			      (atomic_t *)(&sem->count)) < 0)
> 		rwsem_wake(sem);
>@@ -108,7 +100,6 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
> {
> 	int tmp;
>
>-	smp_wmb();
> 	tmp = atomic_add_return(-RWSEM_WAITING_BIAS, (atomic_t *)(&sem->count));
> 	if (tmp < 0)
> 		rwsem_downgrade_wake(sem);
>@@ -119,7 +110,6 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
>  */
> static inline int rwsem_atomic_update(int delta, struct rw_semaphore *sem)
> {
>-	smp_mb();
> 	return atomic_add_return(delta, (atomic_t *)(&sem->count));
> }
>
>diff --git a/arch/xtensa/include/asm/rwsem.h b/arch/xtensa/include/asm/rwsem.h
>index 249619e7e7f2..593483f6e1ff 100644
>--- a/arch/xtensa/include/asm/rwsem.h
>+++ b/arch/xtensa/include/asm/rwsem.h
>@@ -29,9 +29,7 @@
>  */
> static inline void __down_read(struct rw_semaphore *sem)
> {
>-	if (atomic_add_return(1,(atomic_t *)(&sem->count)) > 0)
>-		smp_wmb();
>-	else
>+	if (atomic_add_return(1,(atomic_t *)(&sem->count)) <= 0)
> 		rwsem_down_read_failed(sem);
> }
>
>@@ -42,7 +40,6 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
> 	while ((tmp = sem->count) >= 0) {
> 		if (tmp = cmpxchg(&sem->count, tmp,
> 				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
>-			smp_wmb();
> 			return 1;
> 		}
> 	}
>@@ -58,9 +55,7 @@ static inline void __down_write(struct rw_semaphore *sem)
>
> 	tmp = atomic_add_return(RWSEM_ACTIVE_WRITE_BIAS,
> 				(atomic_t *)(&sem->count));
>-	if (tmp = RWSEM_ACTIVE_WRITE_BIAS)
>-		smp_wmb();
>-	else
>+	if (tmp != RWSEM_ACTIVE_WRITE_BIAS)
> 		rwsem_down_write_failed(sem);
> }
>
>@@ -70,7 +65,6 @@ static inline int __down_write_trylock(struct rw_semaphore *sem)
>
> 	tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> 		      RWSEM_ACTIVE_WRITE_BIAS);
>-	smp_wmb();
> 	return tmp = RWSEM_UNLOCKED_VALUE;
> }
>
>@@ -81,7 +75,6 @@ static inline void __up_read(struct rw_semaphore *sem)
> {
> 	int tmp;
>
>-	smp_wmb();
> 	tmp = atomic_sub_return(1,(atomic_t *)(&sem->count));
> 	if (tmp < -1 && (tmp & RWSEM_ACTIVE_MASK) = 0)
> 		rwsem_wake(sem);
>@@ -92,7 +85,6 @@ static inline void __up_read(struct rw_semaphore *sem)
>  */
> static inline void __up_write(struct rw_semaphore *sem)
> {
>-	smp_wmb();
> 	if (atomic_sub_return(RWSEM_ACTIVE_WRITE_BIAS,
> 			      (atomic_t *)(&sem->count)) < 0)
> 		rwsem_wake(sem);
>@@ -113,7 +105,6 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
> {
> 	int tmp;
>
>-	smp_wmb();
> 	tmp = atomic_add_return(-RWSEM_WAITING_BIAS, (atomic_t *)(&sem->count));
> 	if (tmp < 0)
> 		rwsem_downgrade_wake(sem);
>@@ -124,7 +115,6 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
>  */
> static inline int rwsem_atomic_update(int delta, struct rw_semaphore *sem)
> {
>-	smp_mb();
> 	return atomic_add_return(delta, (atomic_t *)(&sem->count));
> }
>
>-- 
>2.8.0.rc3
>
