From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 19:05:45 +0000
Subject: [PATCH v2 01/32] lcoking/barriers, arch: Use smp barriers in smp_store_release()
Message-Id: <1451572003-2440-2-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, virtualization@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dbueso@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net

From: Davidlohr Bueso <dave@stgolabs.net>

With commit b92b8b35a2e ("locking/arch: Rename set_mb() to smp_store_mb()")
it was made clear that the context of this call (and thus set_mb)
is strictly for CPU ordering, as opposed to IO. As such all archs
should use the smp variant of mb(), respecting the semantics and
saving a mandatory barrier on UP.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: <linux-arch@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: dave@stgolabs.net
Link: http://lkml.kernel.org/r/1445975631-17047-3-git-send-email-dave@stgolabs.net
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/ia64/include/asm/barrier.h    | 2 +-
 arch/powerpc/include/asm/barrier.h | 2 +-
 arch/s390/include/asm/barrier.h    | 2 +-
 include/asm-generic/barrier.h      | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/include/asm/barrier.h b/arch/ia64/include/asm/barrier.h
index df896a1..209c4b8 100644
--- a/arch/ia64/include/asm/barrier.h
+++ b/arch/ia64/include/asm/barrier.h
@@ -77,7 +77,7 @@ do {									\
 	___p1;								\
 })
 
-#define smp_store_mb(var, value)	do { WRITE_ONCE(var, value); mb(); } while (0)
+#define smp_store_mb(var, value) do { WRITE_ONCE(var, value); smp_mb(); } while (0)
 
 /*
  * The group barrier in front of the rsm & ssm are necessary to ensure
diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
index 0eca6ef..a7af5fb 100644
--- a/arch/powerpc/include/asm/barrier.h
+++ b/arch/powerpc/include/asm/barrier.h
@@ -34,7 +34,7 @@
 #define rmb()  __asm__ __volatile__ ("sync" : : : "memory")
 #define wmb()  __asm__ __volatile__ ("sync" : : : "memory")
 
-#define smp_store_mb(var, value)	do { WRITE_ONCE(var, value); mb(); } while (0)
+#define smp_store_mb(var, value) do { WRITE_ONCE(var, value); smp_mb(); } while (0)
 
 #ifdef __SUBARCH_HAS_LWSYNC
 #    define SMPWMB      LWSYNC
diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
index d68e11e..7ffd0b1 100644
--- a/arch/s390/include/asm/barrier.h
+++ b/arch/s390/include/asm/barrier.h
@@ -36,7 +36,7 @@
 #define smp_mb__before_atomic()		smp_mb()
 #define smp_mb__after_atomic()		smp_mb()
 
-#define smp_store_mb(var, value)		do { WRITE_ONCE(var, value); mb(); } while (0)
+#define smp_store_mb(var, value)	do { WRITE_ONCE(var, value); smp_mb(); } while (0)
 
 #define smp_store_release(p, v)						\
 do {									\
diff --git a/include/asm-generic/barrier.h b/include/asm-generic/barrier.h
index b42afad..0f45f93 100644
--- a/include/asm-generic/barrier.h
+++ b/include/asm-generic/barrier.h
@@ -93,7 +93,7 @@
 #endif	/* CONFIG_SMP */
 
 #ifndef smp_store_mb
-#define smp_store_mb(var, value)  do { WRITE_ONCE(var, value); mb(); } while (0)
+#define smp_store_mb(var, value)  do { WRITE_ONCE(var, value); smp_mb(); } while (0)
 #endif
 
 #ifndef smp_mb__before_atomic
-- 
MST

