From: Keith Owens <kaos@sgi.com>
Date: Mon, 12 Dec 2005 03:04:56 +0000
Subject: Re: [patch 2.6.15-rc5] Define an ia64 version of __raw_read_trylock
Message-Id: <5252.1134356696@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17916.1134185068@ocs3.ocs.com.au>
In-Reply-To: <17916.1134185068@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 11 Dec 2005 18:34:18 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>IA64 is using the generic version of __raw_read_trylock, which always
>>waits for the lock to be free instead of returning when the lock is in
>>use.
>
>That sounds like a bug in the generic code.  A locking function
>with "try" in its name has some pretty obvious semantics!

Agreed, but there is too much variation in the rw lock implementations
for any generic version to handle them all, so generic__raw_read_trylock
has to default to a plain lock.

include/asm-alpha/spinlock_types.h:typedef struct {
include/asm-alpha/spinlock_types.h:	volatile unsigned int lock;
include/asm-alpha/spinlock_types.h:} raw_rwlock_t;
--
include/asm-arm/spinlock_types.h:typedef struct {
include/asm-arm/spinlock_types.h:	volatile unsigned int lock;
include/asm-arm/spinlock_types.h:} raw_rwlock_t;
--
include/asm-i386/spinlock_types.h:typedef struct {
include/asm-i386/spinlock_types.h:	volatile unsigned int lock;
include/asm-i386/spinlock_types.h:} raw_rwlock_t;
--
include/asm-ia64/spinlock_types.h:typedef struct {
include/asm-ia64/spinlock_types.h:	volatile unsigned int read_counter	: 31;
include/asm-ia64/spinlock_types.h:	volatile unsigned int write_lock	:  1;
include/asm-ia64/spinlock_types.h:} raw_rwlock_t;
--
include/asm-m32r/spinlock_types.h:typedef struct {
include/asm-m32r/spinlock_types.h:	volatile int lock;
include/asm-m32r/spinlock_types.h:} raw_rwlock_t;
--
include/asm-mips/spinlock_types.h:typedef struct {
include/asm-mips/spinlock_types.h:	volatile unsigned int lock;
include/asm-mips/spinlock_types.h:} raw_rwlock_t;
--
include/asm-parisc/spinlock_types.h:typedef struct {
include/asm-parisc/spinlock_types.h:	raw_spinlock_t lock;
include/asm-parisc/spinlock_types.h:	volatile int counter;
include/asm-parisc/spinlock_types.h:} raw_rwlock_t;
--
include/asm-powerpc/spinlock_types.h:typedef struct {
include/asm-powerpc/spinlock_types.h:	volatile signed int lock;
include/asm-powerpc/spinlock_types.h:} raw_rwlock_t;
--
include/asm-s390/spinlock_types.h:typedef struct {
include/asm-s390/spinlock_types.h:	volatile unsigned int lock;
include/asm-s390/spinlock_types.h:	volatile unsigned int owner_pc;
include/asm-s390/spinlock_types.h:} raw_rwlock_t;
--
include/asm-sh/spinlock_types.h:typedef struct {
include/asm-sh/spinlock_types.h:	raw_spinlock_t lock;
include/asm-sh/spinlock_types.h:	atomic_t counter;
include/asm-sh/spinlock_types.h:} raw_rwlock_t;
--
include/asm-sparc64/spinlock_types.h:typedef struct {
include/asm-sparc64/spinlock_types.h:	volatile unsigned int lock;
include/asm-sparc64/spinlock_types.h:} raw_rwlock_t;
--
include/asm-sparc/spinlock_types.h:typedef struct {
include/asm-sparc/spinlock_types.h:	volatile unsigned int lock;
include/asm-sparc/spinlock_types.h:} raw_rwlock_t;
--
include/asm-x86_64/spinlock_types.h:typedef struct {
include/asm-x86_64/spinlock_types.h:	volatile unsigned int lock;
include/asm-x86_64/spinlock_types.h:} raw_rwlock_t;

We should kill the generic__raw_read_trylock() and force each
implementation to define its own __raw_read_trylock().  IA64 is done,
who's next?

include/asm-arm/spinlock.h:#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
include/asm-ia64/spinlock.h:#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
include/asm-m32r/spinlock.h:#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
include/asm-mips/spinlock.h:#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
include/asm-parisc/spinlock.h:#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
include/asm-sh/spinlock.h:#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
include/asm-sparc64/spinlock.h:#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)

