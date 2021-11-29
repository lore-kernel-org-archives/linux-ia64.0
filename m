From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 29 Nov 2021 17:46:54 +0000
Subject: [PATCH 11/11] locking: Allow to include asm/spinlock_types.h from linux/spinlock_types_raw.h
Message-Id: <20211129174654.668506-12-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211129174654.668506-1-bigeasy@linutronix.de>
In-Reply-To: <20211129174654.668506-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-kernel@vger.kernel.org
Cc: Ben Segall <bsegall@google.com>, Boqun Feng <boqun.feng@gmail.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Ingo Molnar <mingo@redhat.com>, Juri Lelli <juri.lelli@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Vincent Guittot <vincent.guittot@linaro.org>, Waiman Long <longman@redhat.com>, Will Deacon <will@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Albert Ou <aou@eecs.berkeley.edu>, Alexander Gordeev <agordeev@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Brian Cain <bcain@codeaurora.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Christian Borntraeger <borntraeger@linux.ibm.com>, Guo Ren <guoren@kernel.org>, Heiko Carstens <hca@linux.ibm.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Palmer Dabbelt <palmer@dabbelt.com>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Russell King <linux@armlinux.org.uk>, Vasily Gorbik <gor@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org

The printk header file includes ratelimit_types.h for its __ratelimit()
based usage. It is required for the static initializer used in
printk_ratelimited(). It uses a raw_spinlock_t and includes the
spinlock_types.h.

PREEMPT_RT substitutes spinlock_t with a rtmutex based implementation and so
its spinlock_t implmentation (provided by spinlock_rt.h) includes rtmutex.h and
atomic.h which leads to recursive includes where defines are missing.

By including only the raw_spinlock_t defines it avoids the atomic.h
related includes at this stage.

An example on powerpc:

|  CALL    scripts/atomic/check-atomics.sh
|In file included from include/linux/bug.h:5,
|                 from include/linux/page-flags.h:10,
|                 from kernel/bounds.c:10:
|arch/powerpc/include/asm/page_32.h: In function ‘clear_page’:
|arch/powerpc/include/asm/bug.h:87:4: error: implicit declaration of function ‘__WARN’ [-Werror=implicit-function-declaration]
|   87 |    __WARN();    \
|      |    ^~~~~~
|arch/powerpc/include/asm/page_32.h:48:2: note: in expansion of macro ‘WARN_ON’
|   48 |  WARN_ON((unsigned long)addr & (L1_CACHE_BYTES - 1));
|      |  ^~~~~~~
|arch/powerpc/include/asm/bug.h:58:17: error: invalid application of ‘sizeof’ to incomplete type ‘struct bug_entry’
|   58 |     "i" (sizeof(struct bug_entry)), \
|      |                 ^~~~~~
|arch/powerpc/include/asm/bug.h:89:3: note: in expansion of macro ‘BUG_ENTRY’
|   89 |   BUG_ENTRY(PPC_TLNEI " %4, 0",   \
|      |   ^~~~~~~~~
|arch/powerpc/include/asm/page_32.h:48:2: note: in expansion of macro ‘WARN_ON’
|   48 |  WARN_ON((unsigned long)addr & (L1_CACHE_BYTES - 1));
|      |  ^~~~~~~
|In file included from arch/powerpc/include/asm/ptrace.h:298,
|                 from arch/powerpc/include/asm/hw_irq.h:12,
|                 from arch/powerpc/include/asm/irqflags.h:12,
|                 from include/linux/irqflags.h:16,
|                 from include/asm-generic/cmpxchg-local.h:6,
|                 from arch/powerpc/include/asm/cmpxchg.h:526,
|                 from arch/powerpc/include/asm/atomic.h:11,
|                 from include/linux/atomic.h:7,
|                 from include/linux/rwbase_rt.h:6,
|                 from include/linux/rwlock_types.h:55,
|                 from include/linux/spinlock_types.h:74,
|                 from include/linux/ratelimit_types.h:7,
|                 from include/linux/printk.h:10,
|                 from include/asm-generic/bug.h:22,
|                 from arch/powerpc/include/asm/bug.h:109,
|                 from include/linux/bug.h:5,
|                 from include/linux/page-flags.h:10,
|                 from kernel/bounds.c:10:
|include/linux/thread_info.h: In function ‘copy_overflow’:
|include/linux/thread_info.h:210:2: error: implicit declaration of function ‘WARN’ [-Werror=implicit-function-declaration]
|  210 |  WARN(1, "Buffer overflow detected (%d < %lu)!\n", size, count);
|      |  ^~~~

The WARN / BUG include pulls in printk.h and then ptrace.h expects WARN
(from bug.h) which is not yet complete. Even hw_irq.h has WARN_ON()
statements.

On POWERPC64 there are missing atomic64 defines while building 32bit
VDSO:
|  VDSO32C arch/powerpc/kernel/vdso32/vgettimeofday.o
|In file included from include/linux/atomic.h:80,
|                 from include/linux/rwbase_rt.h:6,
|                 from include/linux/rwlock_types.h:55,
|                 from include/linux/spinlock_types.h:74,
|                 from include/linux/ratelimit_types.h:7,
|                 from include/linux/printk.h:10,
|                 from include/linux/kernel.h:19,
|                 from arch/powerpc/include/asm/page.h:11,
|                 from arch/powerpc/include/asm/vdso/gettimeofday.h:5,
|                 from include/vdso/datapage.h:137,
|                 from lib/vdso/gettimeofday.c:5,
|                 from <command-line>:
|include/linux/atomic-arch-fallback.h: In function ‘arch_atomic64_inc’:
|include/linux/atomic-arch-fallback.h:1447:2: error: implicit declaration of function ‘arch_atomic64_add’; did you mean ‘arch_atomic_add’? [-Werror=impl
|icit-function-declaration]
| 1447 |  arch_atomic64_add(1, v);
|      |  ^~~~~~~~~~~~~~~~~
|      |  arch_atomic_add

The generic fallback is not included, atomics itself are not used. If
kernel.h does not include printk.h then it comes later from the bug.h
include.

Allow asm/spinlock_types.h to be included from
linux/spinlock_types_raw.h.

Cc: Albert Ou <aou@eecs.berkeley.edu>
Cc: Alexander Gordeev <agordeev@linux.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Brian Cain <bcain@codeaurora.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Chris Zankel <chris@zankel.net>
Cc: Christian Borntraeger <borntraeger@linux.ibm.com>
Cc: Guo Ren <guoren@kernel.org>
Cc: Heiko Carstens <hca@linux.ibm.com>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Palmer Dabbelt <palmer@dabbelt.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>
Cc: Rich Felker <dalias@libc.org>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: linux-alpha@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-csky@vger.kernel.org
Cc: linux-hexagon@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-riscv@lists.infradead.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 arch/alpha/include/asm/spinlock_types.h          | 2 +-
 arch/arm/include/asm/spinlock_types.h            | 2 +-
 arch/arm64/include/asm/spinlock_types.h          | 2 +-
 arch/csky/include/asm/spinlock_types.h           | 2 +-
 arch/hexagon/include/asm/spinlock_types.h        | 2 +-
 arch/ia64/include/asm/spinlock_types.h           | 2 +-
 arch/powerpc/include/asm/simple_spinlock_types.h | 2 +-
 arch/powerpc/include/asm/spinlock_types.h        | 2 +-
 arch/riscv/include/asm/spinlock_types.h          | 2 +-
 arch/s390/include/asm/spinlock_types.h           | 2 +-
 arch/sh/include/asm/spinlock_types.h             | 2 +-
 arch/xtensa/include/asm/spinlock_types.h         | 2 +-
 include/linux/ratelimit_types.h                  | 2 +-
 include/linux/spinlock_types_up.h                | 2 +-
 14 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/arch/alpha/include/asm/spinlock_types.h b/arch/alpha/include/asm/spinlock_types.h
index 1d5716bc060be..2526fd3be5fd7 100644
--- a/arch/alpha/include/asm/spinlock_types.h
+++ b/arch/alpha/include/asm/spinlock_types.h
@@ -2,7 +2,7 @@
 #ifndef _ALPHA_SPINLOCK_TYPES_H
 #define _ALPHA_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/arm/include/asm/spinlock_types.h b/arch/arm/include/asm/spinlock_types.h
index 5976958647fe1..0c14b36ef1013 100644
--- a/arch/arm/include/asm/spinlock_types.h
+++ b/arch/arm/include/asm/spinlock_types.h
@@ -2,7 +2,7 @@
 #ifndef __ASM_SPINLOCK_TYPES_H
 #define __ASM_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/arm64/include/asm/spinlock_types.h b/arch/arm64/include/asm/spinlock_types.h
index 18782f0c47212..11ab1c0776977 100644
--- a/arch/arm64/include/asm/spinlock_types.h
+++ b/arch/arm64/include/asm/spinlock_types.h
@@ -5,7 +5,7 @@
 #ifndef __ASM_SPINLOCK_TYPES_H
 #define __ASM_SPINLOCK_TYPES_H
 
-#if !defined(__LINUX_SPINLOCK_TYPES_H) && !defined(__ASM_SPINLOCK_H)
+#if !defined(__LINUX_SPINLOCK_TYPES_RAW_H) && !defined(__ASM_SPINLOCK_H)
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/csky/include/asm/spinlock_types.h b/arch/csky/include/asm/spinlock_types.h
index 8ff0f6ff3a006..db87a12c3827d 100644
--- a/arch/csky/include/asm/spinlock_types.h
+++ b/arch/csky/include/asm/spinlock_types.h
@@ -3,7 +3,7 @@
 #ifndef __ASM_CSKY_SPINLOCK_TYPES_H
 #define __ASM_CSKY_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/hexagon/include/asm/spinlock_types.h b/arch/hexagon/include/asm/spinlock_types.h
index 19d233497ba52..d5f66495b670f 100644
--- a/arch/hexagon/include/asm/spinlock_types.h
+++ b/arch/hexagon/include/asm/spinlock_types.h
@@ -8,7 +8,7 @@
 #ifndef _ASM_SPINLOCK_TYPES_H
 #define _ASM_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/ia64/include/asm/spinlock_types.h b/arch/ia64/include/asm/spinlock_types.h
index 6e345fefcdcab..14b8a161c1652 100644
--- a/arch/ia64/include/asm/spinlock_types.h
+++ b/arch/ia64/include/asm/spinlock_types.h
@@ -2,7 +2,7 @@
 #ifndef _ASM_IA64_SPINLOCK_TYPES_H
 #define _ASM_IA64_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/powerpc/include/asm/simple_spinlock_types.h b/arch/powerpc/include/asm/simple_spinlock_types.h
index 0f3cdd8faa959..08243338069d2 100644
--- a/arch/powerpc/include/asm/simple_spinlock_types.h
+++ b/arch/powerpc/include/asm/simple_spinlock_types.h
@@ -2,7 +2,7 @@
 #ifndef _ASM_POWERPC_SIMPLE_SPINLOCK_TYPES_H
 #define _ASM_POWERPC_SIMPLE_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/powerpc/include/asm/spinlock_types.h b/arch/powerpc/include/asm/spinlock_types.h
index c5d742f18021d..d5f8a74ed2e8c 100644
--- a/arch/powerpc/include/asm/spinlock_types.h
+++ b/arch/powerpc/include/asm/spinlock_types.h
@@ -2,7 +2,7 @@
 #ifndef _ASM_POWERPC_SPINLOCK_TYPES_H
 #define _ASM_POWERPC_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/riscv/include/asm/spinlock_types.h b/arch/riscv/include/asm/spinlock_types.h
index f398e7638dd63..5a35a49505da2 100644
--- a/arch/riscv/include/asm/spinlock_types.h
+++ b/arch/riscv/include/asm/spinlock_types.h
@@ -6,7 +6,7 @@
 #ifndef _ASM_RISCV_SPINLOCK_TYPES_H
 #define _ASM_RISCV_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/s390/include/asm/spinlock_types.h b/arch/s390/include/asm/spinlock_types.h
index a2bbfd7df85fa..b69695e399574 100644
--- a/arch/s390/include/asm/spinlock_types.h
+++ b/arch/s390/include/asm/spinlock_types.h
@@ -2,7 +2,7 @@
 #ifndef __ASM_SPINLOCK_TYPES_H
 #define __ASM_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/sh/include/asm/spinlock_types.h b/arch/sh/include/asm/spinlock_types.h
index e82369f286a20..907bda4b1619a 100644
--- a/arch/sh/include/asm/spinlock_types.h
+++ b/arch/sh/include/asm/spinlock_types.h
@@ -2,7 +2,7 @@
 #ifndef __ASM_SH_SPINLOCK_TYPES_H
 #define __ASM_SH_SPINLOCK_TYPES_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
diff --git a/arch/xtensa/include/asm/spinlock_types.h b/arch/xtensa/include/asm/spinlock_types.h
index 64c9389254f13..797aed7df3dd8 100644
--- a/arch/xtensa/include/asm/spinlock_types.h
+++ b/arch/xtensa/include/asm/spinlock_types.h
@@ -2,7 +2,7 @@
 #ifndef __ASM_SPINLOCK_TYPES_H
 #define __ASM_SPINLOCK_TYPES_H
 
-#if !defined(__LINUX_SPINLOCK_TYPES_H) && !defined(__ASM_SPINLOCK_H)
+#if !defined(__LINUX_SPINLOCK_TYPES_RAW_H) && !defined(__ASM_SPINLOCK_H)
 # error "please don't include this file directly"
 #endif
 
diff --git a/include/linux/ratelimit_types.h b/include/linux/ratelimit_types.h
index b676aa419eef8..c21c7f8103e2b 100644
--- a/include/linux/ratelimit_types.h
+++ b/include/linux/ratelimit_types.h
@@ -4,7 +4,7 @@
 
 #include <linux/bits.h>
 #include <linux/param.h>
-#include <linux/spinlock_types.h>
+#include <linux/spinlock_types_raw.h>
 
 #define DEFAULT_RATELIMIT_INTERVAL	(5 * HZ)
 #define DEFAULT_RATELIMIT_BURST		10
diff --git a/include/linux/spinlock_types_up.h b/include/linux/spinlock_types_up.h
index c09b6407ae1b3..7f86a2016ac5c 100644
--- a/include/linux/spinlock_types_up.h
+++ b/include/linux/spinlock_types_up.h
@@ -1,7 +1,7 @@
 #ifndef __LINUX_SPINLOCK_TYPES_UP_H
 #define __LINUX_SPINLOCK_TYPES_UP_H
 
-#ifndef __LINUX_SPINLOCK_TYPES_H
+#ifndef __LINUX_SPINLOCK_TYPES_RAW_H
 # error "please don't include this file directly"
 #endif
 
-- 
2.34.0
