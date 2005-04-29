From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 29 Apr 2005 00:50:53 +0000
Subject: RE: write_unlock: replace clear_bit with byte store
Message-Id: <Pine.LNX.4.58.0504281744500.25133@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 28 Apr 2005, Chen, Kenneth W wrote:

> Christoph Lameter wrote on Thursday, April 28, 2005 5:22 PM
> > How do I do a store with release and nontemporal semantics without asm?
>
> Use ia64_st1_rel(), and add a wrapper in gcc_intrin.h.  Though that only
> takes care of store with release semantics.

Hmm... How about this one. Its still better than the cmpxchg for C and you
can do all the tricks you want with the C code later. I hope the bitfields
allocate the lowest bits first?

---

write_lock uses a cmpxchg like the regular spin_lock but write_unlock uses
clear_bit which requires a load and then a loop over a cmpxchg. The
following patch makes write_unlock simply use a nontemporal store to clear
the highest 8 bits. We will then still have the lower 3 bytes (24 bits)
left to count the readers.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/include/asm-ia64/spinlock.h
=================================--- linux-2.6.11.orig/include/asm-ia64/spinlock.h	2005-03-01 23:37:48.000000000 -0800
+++ linux-2.6.11/include/asm-ia64/spinlock.h	2005-04-28 17:48:11.000000000 -0700
@@ -117,8 +117,8 @@ do {											\
 #define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)

 typedef struct {
-	volatile unsigned int read_counter	: 31;
-	volatile unsigned int write_lock	:  1;
+	volatile unsigned int read_counter	: 24;
+	volatile unsigned int write_lock	:  8;
 #ifdef CONFIG_PREEMPT
 	unsigned int break_lock;
 #endif
@@ -174,6 +174,13 @@ do {										\
 	(result = 0);								\
 })

+static inline void _raw_write_unlock(rwlock_t *x)
+{
+	u8 *y = (u8 *)x;
+	barrier();
+	asm volatile ("st1.rel.nta [%0] = r0\n\t" :: "r"(y+3) : "memory" );
+}
+
 #else /* !ASM_SUPPORTED */

 #define _raw_write_lock(l)								\
@@ -195,14 +202,14 @@ do {										\
 	(ia64_val = 0);						\
 })

+static inline void _raw_write_unlock(rwlock_t *x)
+{
+	barrier();
+	x->write_lock = 0;
+}
+
 #endif /* !ASM_SUPPORTED */

 #define _raw_read_trylock(lock) generic_raw_read_trylock(lock)

-#define _raw_write_unlock(x)								\
-({											\
-	smp_mb__before_clear_bit();	/* need barrier before releasing lock... */	\
-	clear_bit(31, (x));								\
-})
-
 #endif /*  _ASM_IA64_SPINLOCK_H */

