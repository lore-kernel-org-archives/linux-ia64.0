From: Andrey Konovalov <andreyknvl@google.com>
Date: Sun, 02 Aug 2015 15:11:04 +0000
Subject: [PATCH v2] arch: use WRITE_ONCE/READ_ONCE in smp_store_release/smp_load_acquire
Message-Id: <1438528264-714-1-git-send-email-andreyknvl@google.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, Andre Przywara <andre.przywara@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Borislav Petkov <bp@suse.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Davidlohr Bueso <dave@stgolabs.net>

Replace ACCESS_ONCE() macro in smp_store_release() and smp_load_acquire()
with WRITE_ONCE() and READ_ONCE() on x86, arm, arm64, ia64, metag, mips,
powerpc, s390, sparc and asm-generic since ACCESS_ONCE does not work
reliably on non-scalar types.

WRITE_ONCE() and READ_ONCE() were introduced in the commits 230fa253df63
("kernel: Provide READ_ONCE and ASSIGN_ONCE") and 43239cbe79fc ("kernel:
Change ASSIGN_ONCE(val, x) to WRITE_ONCE(x, val)").

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
Changed in v2:
  - Other archs besides x86.

 arch/arm/include/asm/barrier.h      | 4 ++--
 arch/arm64/include/asm/barrier.h    | 4 ++--
 arch/ia64/include/asm/barrier.h     | 4 ++--
 arch/metag/include/asm/barrier.h    | 4 ++--
 arch/mips/include/asm/barrier.h     | 4 ++--
 arch/powerpc/include/asm/barrier.h  | 4 ++--
 arch/s390/include/asm/barrier.h     | 4 ++--
 arch/sparc/include/asm/barrier_64.h | 4 ++--
 arch/x86/include/asm/barrier.h      | 8 ++++----
 include/asm-generic/barrier.h       | 4 ++--
 10 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/arch/arm/include/asm/barrier.h b/arch/arm/include/asm/barrier.h
index 6c2327e..7039357 100644
--- a/arch/arm/include/asm/barrier.h
+++ b/arch/arm/include/asm/barrier.h
@@ -67,12 +67,12 @@
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
 	___p1;								\
diff --git a/arch/arm64/include/asm/barrier.h b/arch/arm64/include/asm/barrier.h
index 0fa47c4..ef93b20 100644
--- a/arch/arm64/include/asm/barrier.h
+++ b/arch/arm64/include/asm/barrier.h
@@ -44,12 +44,12 @@
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	___p1;								\
diff --git a/arch/ia64/include/asm/barrier.h b/arch/ia64/include/asm/barrier.h
index 843ba43..df896a1 100644
--- a/arch/ia64/include/asm/barrier.h
+++ b/arch/ia64/include/asm/barrier.h
@@ -66,12 +66,12 @@
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	___p1;								\
diff --git a/arch/metag/include/asm/barrier.h b/arch/metag/include/asm/barrier.h
index 5a696e5..172b7e5 100644
--- a/arch/metag/include/asm/barrier.h
+++ b/arch/metag/include/asm/barrier.h
@@ -90,12 +90,12 @@ static inline void fence(void)
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
 	___p1;								\
diff --git a/arch/mips/include/asm/barrier.h b/arch/mips/include/asm/barrier.h
index 7ecba84..752e0b8 100644
--- a/arch/mips/include/asm/barrier.h
+++ b/arch/mips/include/asm/barrier.h
@@ -133,12 +133,12 @@
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
 	___p1;								\
diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
index 51ccc72..0eca6ef 100644
--- a/arch/powerpc/include/asm/barrier.h
+++ b/arch/powerpc/include/asm/barrier.h
@@ -76,12 +76,12 @@
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	smp_lwsync();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	smp_lwsync();							\
 	___p1;								\
diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
index e6f8615..d48fe01 100644
--- a/arch/s390/include/asm/barrier.h
+++ b/arch/s390/include/asm/barrier.h
@@ -42,12 +42,12 @@
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	___p1;								\
diff --git a/arch/sparc/include/asm/barrier_64.h b/arch/sparc/include/asm/barrier_64.h
index 809941e..14a9286 100644
--- a/arch/sparc/include/asm/barrier_64.h
+++ b/arch/sparc/include/asm/barrier_64.h
@@ -60,12 +60,12 @@ do {	__asm__ __volatile__("ba,pt	%%xcc, 1f\n\t" \
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	___p1;								\
diff --git a/arch/x86/include/asm/barrier.h b/arch/x86/include/asm/barrier.h
index e51a8f8..d2bcfbe 100644
--- a/arch/x86/include/asm/barrier.h
+++ b/arch/x86/include/asm/barrier.h
@@ -57,12 +57,12 @@
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
 	___p1;								\
@@ -74,12 +74,12 @@ do {									\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	___p1;								\
diff --git a/include/asm-generic/barrier.h b/include/asm-generic/barrier.h
index 55e3abc..b42afad 100644
--- a/include/asm-generic/barrier.h
+++ b/include/asm-generic/barrier.h
@@ -108,12 +108,12 @@
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
-	ACCESS_ONCE(*p) = (v);						\
+	WRITE_ONCE(*p, v);						\
 } while (0)
 
 #define smp_load_acquire(p)						\
 ({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	typeof(*p) ___p1 = READ_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
 	___p1;								\
-- 
2.5.0.rc2.392.g76e840b

