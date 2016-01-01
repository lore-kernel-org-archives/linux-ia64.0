From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 01 Jan 2016 09:39:40 +0000
Subject: [PATCH v2 30/32] virtio_ring: update weak barriers to use __smp_xxx
Message-Id: <1451572003-2440-31-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Alexander Duyck <alexander.duyck@gmail.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>

virtio ring uses smp_wmb on SMP and wmb on !SMP,
the reason for the later being that it might be
talking to another kernel on the same SMP machine.

This is exactly what __smp_XXX barriers do,
so switch to these instead of homegrown ifdef hacks.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/virtio_ring.h | 25 ++++---------------------
 1 file changed, 4 insertions(+), 21 deletions(-)

diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index 67e06fe..f3fa55b 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -12,7 +12,7 @@
  * anyone care?
  *
  * For virtio_pci on SMP, we don't need to order with respect to MMIO
- * accesses through relaxed memory I/O windows, so smp_mb() et al are
+ * accesses through relaxed memory I/O windows, so virt_mb() et al are
  * sufficient.
  *
  * For using virtio to talk to real devices (eg. other heterogeneous
@@ -21,11 +21,10 @@
  * actually quite cheap.
  */
 
-#ifdef CONFIG_SMP
 static inline void virtio_mb(bool weak_barriers)
 {
 	if (weak_barriers)
-		smp_mb();
+		virt_mb();
 	else
 		mb();
 }
@@ -33,7 +32,7 @@ static inline void virtio_mb(bool weak_barriers)
 static inline void virtio_rmb(bool weak_barriers)
 {
 	if (weak_barriers)
-		smp_rmb();
+		virt_rmb();
 	else
 		rmb();
 }
@@ -41,26 +40,10 @@ static inline void virtio_rmb(bool weak_barriers)
 static inline void virtio_wmb(bool weak_barriers)
 {
 	if (weak_barriers)
-		smp_wmb();
+		virt_wmb();
 	else
 		wmb();
 }
-#else
-static inline void virtio_mb(bool weak_barriers)
-{
-	mb();
-}
-
-static inline void virtio_rmb(bool weak_barriers)
-{
-	rmb();
-}
-
-static inline void virtio_wmb(bool weak_barriers)
-{
-	wmb();
-}
-#endif
 
 struct virtio_device;
 struct virtqueue;
-- 
MST
