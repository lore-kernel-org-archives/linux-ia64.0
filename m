From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 16:47:41 +0000
Subject: Re: [patch 1/3] spinlock fix #1, *_can_lock() primitives
Message-Id: <20050120164741.GA16660@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.9678.73202.771962@wombat.chubb.wattle.id.au> <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au> <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org> <20050120160839.GA13067@elte.hu> <Pine.LNX.4.58.0501200823010.8178@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501200823010.8178@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


* Linus Torvalds <torvalds@osdl.org> wrote:

> I can do ppc64 myself, can others fix the other architectures (Ingo,
> shouldn't the UP case have the read/write_can_lock() cases too? And
> wouldn't you agree that it makes more sense to have the rwlock test
> variants in asm/rwlock.h?):

(untested) ia64 version below. Differs from x86/x64.

	Ingo

Signed-off-by: Ingo Molnar <mingo@elte.hu>

--- linux/include/asm-ia64/spinlock.h.orig
+++ linux/include/asm-ia64/spinlock.h
@@ -128,8 +128,27 @@ typedef struct {
 #define RW_LOCK_UNLOCKED (rwlock_t) { 0, 0 }
 
 #define rwlock_init(x)		do { *(x) = RW_LOCK_UNLOCKED; } while(0)
-#define rwlock_is_locked(x)	(*(volatile int *) (x) != 0)
 
+/**
+ * read_can_lock - would read_trylock() succeed?
+ * @lock: the rwlock in question.
+ */
+static inline int read_can_lock(rwlock_t *rw)
+{
+	return *(volatile int *)rw >= 0;
+}
+
+/**
+ * write_can_lock - would write_trylock() succeed?
+ * @lock: the rwlock in question.
+ */
+static inline int write_can_lock(rwlock_t *rw)
+{
+	return *(volatile int *)rw = 0;
+}
+ 
+ /*
+  * On x86, we implement read-write locks as a 32-bit counter
 #define _raw_read_lock(rw)								\
 do {											\
 	rwlock_t *__read_lock_ptr = (rw);						\
