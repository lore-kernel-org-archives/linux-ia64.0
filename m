From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 25 Oct 2021 10:06:07 +0000
Subject: Re: [PATCH] locking: remove spin_lock_flags() etc
Message-Id: <YXaBj4YTMrZLOPD/@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211022120058.1031690-1-arnd@kernel.org>
 <cc8e3c58-457d-fdf3-6a62-98bde0cefdea@redhat.com>
 <CAK8P3a0YjaRS+aUCOKGjsfkR3TM49PrG6U4ftG_Fz+OFuyCb0w@mail.gmail.com>
 <YXZ/iLB7BvZtzDMp@hirez.programming.kicks-ass.net>
In-Reply-To: <YXZ/iLB7BvZtzDMp@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Boqun Feng <boqun.feng@gmail.com>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Openrisc <openrisc@lists.librecores.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>

On Mon, Oct 25, 2021 at 11:57:28AM +0200, Peter Zijlstra wrote:
> On Sat, Oct 23, 2021 at 06:04:57PM +0200, Arnd Bergmann wrote:
> > On Sat, Oct 23, 2021 at 3:37 AM Waiman Long <longman@redhat.com> wrote:
> > >> On 10/22/21 7:59 AM, Arnd Bergmann wrote:
> > > > From: Arnd Bergmann <arnd@arndb.de>
> > > >
> > > > As this is all dead code, just remove it and the helper functions built
> > > > around it. For arch/ia64, the inline asm could be cleaned up, but
> > > > it seems safer to leave it untouched.
> > > >
> > > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > >
> > > Does that mean we can also remove the GENERIC_LOCKBREAK config option
> > > from the Kconfig files as well?
> > 
> >  I couldn't figure this out.
> > 
> > What I see is that the only architectures setting GENERIC_LOCKBREAK are
> > nds32, parisc, powerpc, s390, sh and sparc64, while the only architectures
> > implementing arch_spin_is_contended() are arm32, csky and ia64.
> > 
> > The part I don't understand is whether the option actually does anything
> > useful any more after commit d89c70356acf ("locking/core: Remove break_lock
> > field when CONFIG_GENERIC_LOCKBREAK=y").
> 
> Urgh, what a mess.. AFAICT there's still code in
> kernel/locking/spinlock.c that relies on it. Specifically when
> GENERIC_LOCKBREAK=y we seem to create _lock*() variants that are
> basically TaS locks which drop preempt/irq disable while spinning.
> 
> Anybody having this on and not having native TaS locks is in for a rude
> surprise I suppose... sparc64 being the obvious candidate there :/

Something like the *totally*untested* patch below would rip it all out.

---
 arch/ia64/Kconfig                |  3 --
 arch/nds32/Kconfig               |  4 --
 arch/parisc/Kconfig              |  5 ---
 arch/powerpc/Kconfig             |  5 ---
 arch/s390/Kconfig                |  3 --
 arch/sh/Kconfig                  |  4 --
 arch/sparc/Kconfig               |  6 ---
 include/linux/rwlock_api_smp.h   |  4 +-
 include/linux/spinlock_api_smp.h |  4 +-
 kernel/Kconfig.locks             | 26 ++++++------
 kernel/locking/spinlock.c        | 90 ----------------------------------------
 11 files changed, 17 insertions(+), 137 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 1e33666fa679..5ec3abba3c81 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -81,9 +81,6 @@ config MMU
 config STACKTRACE_SUPPORT
 	def_bool y
 
-config GENERIC_LOCKBREAK
-	def_bool n
-
 config GENERIC_CALIBRATE_DELAY
 	bool
 	default y
diff --git a/arch/nds32/Kconfig b/arch/nds32/Kconfig
index aea26e739543..699008dbd6c2 100644
--- a/arch/nds32/Kconfig
+++ b/arch/nds32/Kconfig
@@ -59,10 +59,6 @@ config GENERIC_CSUM
 config GENERIC_HWEIGHT
 	def_bool y
 
-config GENERIC_LOCKBREAK
-	def_bool y
-	depends on PREEMPTION
-
 config STACKTRACE_SUPPORT
 	def_bool y
 
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 27a8b49af11f..afe70bcdde2c 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -86,11 +86,6 @@ config ARCH_DEFCONFIG
 	default "arch/parisc/configs/generic-32bit_defconfig" if !64BIT
 	default "arch/parisc/configs/generic-64bit_defconfig" if 64BIT
 
-config GENERIC_LOCKBREAK
-	bool
-	default y
-	depends on SMP && PREEMPTION
-
 config ARCH_HAS_ILOG2_U32
 	bool
 	default n
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index ba5b66189358..e782c9ea3f81 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -98,11 +98,6 @@ config LOCKDEP_SUPPORT
 	bool
 	default y
 
-config GENERIC_LOCKBREAK
-	bool
-	default y
-	depends on SMP && PREEMPTION
-
 config GENERIC_HWEIGHT
 	bool
 	default y
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index b86de61b8caa..e4ff05f5393b 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -26,9 +26,6 @@ config GENERIC_BUG
 config GENERIC_BUG_RELATIVE_POINTERS
 	def_bool y
 
-config GENERIC_LOCKBREAK
-	def_bool y if PREEMPTION
-
 config PGSTE
 	def_bool y if KVM
 
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 6904f4bdbf00..26f1cf2c69a3 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -86,10 +86,6 @@ config GENERIC_HWEIGHT
 config GENERIC_CALIBRATE_DELAY
 	bool
 
-config GENERIC_LOCKBREAK
-	def_bool y
-	depends on SMP && PREEMPTION
-
 config ARCH_SUSPEND_POSSIBLE
 	def_bool n
 
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index b120ed947f50..e77e7254eaa0 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -246,12 +246,6 @@ config US3_MC
 
 	  If in doubt, say Y, as this information can be very useful.
 
-# Global things across all Sun machines.
-config GENERIC_LOCKBREAK
-	bool
-	default y
-	depends on SPARC64 && SMP && PREEMPTION
-
 config NUMA
 	bool "NUMA support"
 	depends on SPARC64 && SMP
diff --git a/include/linux/rwlock_api_smp.h b/include/linux/rwlock_api_smp.h
index abfb53ab11be..a281d81ef8ee 100644
--- a/include/linux/rwlock_api_smp.h
+++ b/include/linux/rwlock_api_smp.h
@@ -141,7 +141,7 @@ static inline int __raw_write_trylock(rwlock_t *lock)
  * even on CONFIG_PREEMPT, because lockdep assumes that interrupts are
  * not re-enabled during lock-acquire (which the preempt-spin-ops do):
  */
-#if !defined(CONFIG_GENERIC_LOCKBREAK) || defined(CONFIG_DEBUG_LOCK_ALLOC)
+#if defined(CONFIG_DEBUG_LOCK_ALLOC)
 
 static inline void __raw_read_lock(rwlock_t *lock)
 {
@@ -211,7 +211,7 @@ static inline void __raw_write_lock(rwlock_t *lock)
 	LOCK_CONTENDED(lock, do_raw_write_trylock, do_raw_write_lock);
 }
 
-#endif /* !CONFIG_GENERIC_LOCKBREAK || CONFIG_DEBUG_LOCK_ALLOC */
+#endif /* CONFIG_DEBUG_LOCK_ALLOC */
 
 static inline void __raw_write_unlock(rwlock_t *lock)
 {
diff --git a/include/linux/spinlock_api_smp.h b/include/linux/spinlock_api_smp.h
index 6b8e1a0b137b..fb437243eb2e 100644
--- a/include/linux/spinlock_api_smp.h
+++ b/include/linux/spinlock_api_smp.h
@@ -99,7 +99,7 @@ static inline int __raw_spin_trylock(raw_spinlock_t *lock)
  * even on CONFIG_PREEMPTION, because lockdep assumes that interrupts are
  * not re-enabled during lock-acquire (which the preempt-spin-ops do):
  */
-#if !defined(CONFIG_GENERIC_LOCKBREAK) || defined(CONFIG_DEBUG_LOCK_ALLOC)
+#if defined(CONFIG_DEBUG_LOCK_ALLOC)
 
 static inline unsigned long __raw_spin_lock_irqsave(raw_spinlock_t *lock)
 {
@@ -143,7 +143,7 @@ static inline void __raw_spin_lock(raw_spinlock_t *lock)
 	LOCK_CONTENDED(lock, do_raw_spin_trylock, do_raw_spin_lock);
 }
 
-#endif /* !CONFIG_GENERIC_LOCKBREAK || CONFIG_DEBUG_LOCK_ALLOC */
+#endif /* CONFIG_DEBUG_LOCK_ALLOC */
 
 static inline void __raw_spin_unlock(raw_spinlock_t *lock)
 {
diff --git a/kernel/Kconfig.locks b/kernel/Kconfig.locks
index 4198f0273ecd..8e0b501189e8 100644
--- a/kernel/Kconfig.locks
+++ b/kernel/Kconfig.locks
@@ -93,7 +93,7 @@ config UNINLINE_SPIN_UNLOCK
 
 #
 # lock_* functions are inlined when:
-#   - DEBUG_SPINLOCK=n and GENERIC_LOCKBREAK=n and ARCH_INLINE_*LOCK=y
+#   - DEBUG_SPINLOCK=n and ARCH_INLINE_*LOCK=y
 #
 # trylock_* functions are inlined when:
 #   - DEBUG_SPINLOCK=n and ARCH_INLINE_*LOCK=y
@@ -119,19 +119,19 @@ config INLINE_SPIN_TRYLOCK_BH
 
 config INLINE_SPIN_LOCK
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_SPIN_LOCK
+	depends on ARCH_INLINE_SPIN_LOCK
 
 config INLINE_SPIN_LOCK_BH
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_SPIN_LOCK_BH
+	depends on ARCH_INLINE_SPIN_LOCK_BH
 
 config INLINE_SPIN_LOCK_IRQ
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_SPIN_LOCK_IRQ
+	depends on ARCH_INLINE_SPIN_LOCK_IRQ
 
 config INLINE_SPIN_LOCK_IRQSAVE
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_SPIN_LOCK_IRQSAVE
+	depends on ARCH_INLINE_SPIN_LOCK_IRQSAVE
 
 config INLINE_SPIN_UNLOCK_BH
 	def_bool y
@@ -152,19 +152,19 @@ config INLINE_READ_TRYLOCK
 
 config INLINE_READ_LOCK
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_READ_LOCK
+	depends on ARCH_INLINE_READ_LOCK
 
 config INLINE_READ_LOCK_BH
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_READ_LOCK_BH
+	depends on ARCH_INLINE_READ_LOCK_BH
 
 config INLINE_READ_LOCK_IRQ
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_READ_LOCK_IRQ
+	depends on ARCH_INLINE_READ_LOCK_IRQ
 
 config INLINE_READ_LOCK_IRQSAVE
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_READ_LOCK_IRQSAVE
+	depends on ARCH_INLINE_READ_LOCK_IRQSAVE
 
 config INLINE_READ_UNLOCK
 	def_bool y
@@ -189,19 +189,19 @@ config INLINE_WRITE_TRYLOCK
 
 config INLINE_WRITE_LOCK
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_WRITE_LOCK
+	depends on ARCH_INLINE_WRITE_LOCK
 
 config INLINE_WRITE_LOCK_BH
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_WRITE_LOCK_BH
+	depends on ARCH_INLINE_WRITE_LOCK_BH
 
 config INLINE_WRITE_LOCK_IRQ
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_WRITE_LOCK_IRQ
+	depends on ARCH_INLINE_WRITE_LOCK_IRQ
 
 config INLINE_WRITE_LOCK_IRQSAVE
 	def_bool y
-	depends on !GENERIC_LOCKBREAK && ARCH_INLINE_WRITE_LOCK_IRQSAVE
+	depends on ARCH_INLINE_WRITE_LOCK_IRQSAVE
 
 config INLINE_WRITE_UNLOCK
 	def_bool y
diff --git a/kernel/locking/spinlock.c b/kernel/locking/spinlock.c
index c5830cfa379a..d94ee95585fc 100644
--- a/kernel/locking/spinlock.c
+++ b/kernel/locking/spinlock.c
@@ -29,19 +29,6 @@ EXPORT_PER_CPU_SYMBOL(__mmiowb_state);
 #endif
 #endif
 
-/*
- * If lockdep is enabled then we use the non-preemption spin-ops
- * even on CONFIG_PREEMPT, because lockdep assumes that interrupts are
- * not re-enabled during lock-acquire (which the preempt-spin-ops do):
- */
-#if !defined(CONFIG_GENERIC_LOCKBREAK) || defined(CONFIG_DEBUG_LOCK_ALLOC)
-/*
- * The __lock_function inlines are taken from
- * spinlock : include/linux/spinlock_api_smp.h
- * rwlock   : include/linux/rwlock_api_smp.h
- */
-#else
-
 /*
  * Some architectures can relax in favour of the CPU owning the lock.
  */
@@ -55,83 +42,6 @@ EXPORT_PER_CPU_SYMBOL(__mmiowb_state);
 # define arch_spin_relax(l)	cpu_relax()
 #endif
 
-/*
- * We build the __lock_function inlines here. They are too large for
- * inlining all over the place, but here is only one user per function
- * which embeds them into the calling _lock_function below.
- *
- * This could be a long-held lock. We both prepare to spin for a long
- * time (making _this_ CPU preemptible if possible), and we also signal
- * towards that other CPU that it should break the lock ASAP.
- */
-#define BUILD_LOCK_OPS(op, locktype)					\
-void __lockfunc __raw_##op##_lock(locktype##_t *lock)			\
-{									\
-	for (;;) {							\
-		preempt_disable();					\
-		if (likely(do_raw_##op##_trylock(lock)))		\
-			break;						\
-		preempt_enable();					\
-									\
-		arch_##op##_relax(&lock->raw_lock);			\
-	}								\
-}									\
-									\
-unsigned long __lockfunc __raw_##op##_lock_irqsave(locktype##_t *lock)	\
-{									\
-	unsigned long flags;						\
-									\
-	for (;;) {							\
-		preempt_disable();					\
-		local_irq_save(flags);					\
-		if (likely(do_raw_##op##_trylock(lock)))		\
-			break;						\
-		local_irq_restore(flags);				\
-		preempt_enable();					\
-									\
-		arch_##op##_relax(&lock->raw_lock);			\
-	}								\
-									\
-	return flags;							\
-}									\
-									\
-void __lockfunc __raw_##op##_lock_irq(locktype##_t *lock)		\
-{									\
-	_raw_##op##_lock_irqsave(lock);					\
-}									\
-									\
-void __lockfunc __raw_##op##_lock_bh(locktype##_t *lock)		\
-{									\
-	unsigned long flags;						\
-									\
-	/*							*/	\
-	/* Careful: we must exclude softirqs too, hence the	*/	\
-	/* irq-disabling. We use the generic preemption-aware	*/	\
-	/* function:						*/	\
-	/**/								\
-	flags = _raw_##op##_lock_irqsave(lock);				\
-	local_bh_disable();						\
-	local_irq_restore(flags);					\
-}									\
-
-/*
- * Build preemption-friendly versions of the following
- * lock-spinning functions:
- *
- *         __[spin|read|write]_lock()
- *         __[spin|read|write]_lock_irq()
- *         __[spin|read|write]_lock_irqsave()
- *         __[spin|read|write]_lock_bh()
- */
-BUILD_LOCK_OPS(spin, raw_spinlock);
-
-#ifndef CONFIG_PREEMPT_RT
-BUILD_LOCK_OPS(read, rwlock);
-BUILD_LOCK_OPS(write, rwlock);
-#endif
-
-#endif
-
 #ifndef CONFIG_INLINE_SPIN_TRYLOCK
 int __lockfunc _raw_spin_trylock(raw_spinlock_t *lock)
 {
