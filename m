From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 28 Apr 2005 22:51:45 +0000
Subject: RE: write_unlock: replace clear_bit with byte store
Message-Id: <Pine.LNX.4.58.0504281543030.24648@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 29 Apr 2005, Zou, Nanhai wrote:

> > +static inline void _raw_write_unlock(spinlock_t *x) {
>
> Shouldn't that an rwlock_t?

Correct. CC does not check types when doing inline functions? If I mispell
the type name then the compilation fails. I can put u64 * in there or
anything else and CC  happily allows the passing of a rwlock_t *? Weird...
Maybe because of the type cast?

----------------------------------------------------------
write_lock uses a cmpxchg like the regular spin_lock but write_unlock uses
clear_bit which requires a load and then a loop over a cmpxchg. The
following patch makes write_unlock simply use a nontemporal store to clear
the highest 8 bits. We will then still have the lower 3 bytes (24 bits)
left to count the readers.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/include/asm-ia64/spinlock.h
=================================--- linux-2.6.11.orig/include/asm-ia64/spinlock.h	2005-03-01 23:37:48.000000000 -0800
+++ linux-2.6.11/include/asm-ia64/spinlock.h	2005-04-28 15:44:30.000000000 -0700
@@ -199,10 +199,10 @@ do {										\

 #define _raw_read_trylock(lock) generic_raw_read_trylock(lock)

-#define _raw_write_unlock(x)								\
-({											\
-	smp_mb__before_clear_bit();	/* need barrier before releasing lock... */	\
-	clear_bit(31, (x));								\
-})
+static inline void _raw_write_unlock(rwlock_t *x) {
+	u8 *y = (u8 *)x;
+	barrier();
+	asm volatile ("st1.rel.nta [%0] = r0\n\t" :: "r"(y+3) : "memory" );
+}

 #endif /*  _ASM_IA64_SPINLOCK_H */
