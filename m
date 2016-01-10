From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:22:14 +0000
Subject: [PATCH v3 41/41] s390: more efficient smp barriers
Message-Id: <1452426622-4471-42-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Martin

As per: lkml.kernel.org/r/20150921112252.3c2937e1@mschwide
atomics imply a barrier on s390, so s390 should change
smp_mb__before_atomic and smp_mb__after_atomic to barrier() instead of
smp_mb() and hence should not use the generic versions.

Suggested-by: Peter Zijlstra <peterz@infradead.org>
Suggested-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 arch/s390/include/asm/barrier.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
index 4d26fa4..5c8db3c 100644
--- a/arch/s390/include/asm/barrier.h
+++ b/arch/s390/include/asm/barrier.h
@@ -45,6 +45,9 @@ do {									\
 	___p1;								\
 })
 
+#define __smp_mb__before_atomic()	barrier()
+#define __smp_mb__after_atomic()	barrier()
+
 #include <asm-generic/barrier.h>
 
 #endif /* __ASM_BARRIER_H */
-- 
MST

