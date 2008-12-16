From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 16 Dec 2008 08:02:56 +0000
Subject: [mmotm][PATCH] ia64: typo fix of implement interrupt-enabling rwlocks
Message-Id: <20081216170020.DBB4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>, Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com



Applied after: ia64-implement-interrupt-enabling-rwlocks.patch
=
Recently, __raw_read_lock_flags and __raw_write_lock_flags for ia64 was implemented.

But its patch has typo. then following warnings happend.

  CC      lib/spinlock_debug.o
lib/spinlock_debug.c: In function '_raw_read_lock':
lib/spinlock_debug.c:199: warning: passing argument 1 of '__raw_read_lock_flags' from incompatible pointer type
lib/spinlock_debug.c: In function '_raw_write_lock':
lib/spinlock_debug.c:274: warning: passing argument 1 of '__raw_write_lock_flags' from incompatible pointer type


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Petr Tesarik <ptesarik@suse.cz>
CC: Robin Holt <holt@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "Luck, Tony" <tony.luck@intel.com>
---
 arch/ia64/include/asm/spinlock.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: b/arch/ia64/include/asm/spinlock.h
=================================--- a/arch/ia64/include/asm/spinlock.h
+++ b/arch/ia64/include/asm/spinlock.h
@@ -123,7 +123,7 @@ do {											\
 #ifdef ASM_SUPPORTED
 
 static __always_inline void
-__raw_read_lock_flags(raw_spinlock_t *lock, unsigned long flags)
+__raw_read_lock_flags(raw_rwlock_t *lock, unsigned long flags)
 {
 	__asm__ __volatile__ (
 		"tbit.nz p6, p0 = %1,%2\n"
@@ -174,7 +174,7 @@ do {								\
 #ifdef ASM_SUPPORTED
 
 static __always_inline void
-__raw_write_lock_flags(raw_spinlock_t *lock, unsigned long flags)
+__raw_write_lock_flags(raw_rwlock_t *lock, unsigned long flags)
 {
 	__asm__ __volatile__ (
 		"tbit.nz p6, p0 = %1, %2\n"


