From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:16:44 +0000
Subject: [PATCH v3 02/41] asm-generic: guard smp_store_release/load_acquire
Message-Id: <1452426622-4471-3-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org

Allow architectures to override smp_store_release
and smp_load_acquire by guarding the defines
in asm-generic/barrier.h with ifndef directives.

This is in preparation to reusing asm-generic/barrier.h
on architectures which have their own definition
of these macros.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 include/asm-generic/barrier.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/asm-generic/barrier.h b/include/asm-generic/barrier.h
index 0f45f93..987b2e0 100644
--- a/include/asm-generic/barrier.h
+++ b/include/asm-generic/barrier.h
@@ -104,13 +104,16 @@
 #define smp_mb__after_atomic()	smp_mb()
 #endif
 
+#ifndef smp_store_release
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	smp_mb();							\
 	WRITE_ONCE(*p, v);						\
 } while (0)
+#endif
 
+#ifndef smp_load_acquire
 #define smp_load_acquire(p)						\
 ({									\
 	typeof(*p) ___p1 = READ_ONCE(*p);				\
@@ -118,6 +121,7 @@ do {									\
 	smp_mb();							\
 	___p1;								\
 })
+#endif
 
 #endif /* !__ASSEMBLY__ */
 #endif /* __ASM_GENERIC_BARRIER_H */
-- 
MST

