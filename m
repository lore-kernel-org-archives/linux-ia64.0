From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:20:34 +0000
Subject: [PATCH v3 29/41] Revert "virtio_ring: Update weak barriers to use dma_wmb/rmb"
Message-Id: <1452426622-4471-30-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.orgAlexanderDuyckal

This reverts commit 9e1a27ea42691429e31f158cce6fc61bc79bb2e9.

While that commit optimizes !CONFIG_SMP, it mixes
up DMA and SMP concepts, making the code hard
to figure out.

A better way to optimize this is with the new __smp_XXX
barriers.

As a first step, go back to full rmb/wmb barriers
for !SMP.
We switch to __smp_XXX barriers in the next patch.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/virtio_ring.h | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index 8e50888..67e06fe 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -21,20 +21,19 @@
  * actually quite cheap.
  */
 
+#ifdef CONFIG_SMP
 static inline void virtio_mb(bool weak_barriers)
 {
-#ifdef CONFIG_SMP
 	if (weak_barriers)
 		smp_mb();
 	else
-#endif
 		mb();
 }
 
 static inline void virtio_rmb(bool weak_barriers)
 {
 	if (weak_barriers)
-		dma_rmb();
+		smp_rmb();
 	else
 		rmb();
 }
@@ -42,10 +41,26 @@ static inline void virtio_rmb(bool weak_barriers)
 static inline void virtio_wmb(bool weak_barriers)
 {
 	if (weak_barriers)
-		dma_wmb();
+		smp_wmb();
 	else
 		wmb();
 }
+#else
+static inline void virtio_mb(bool weak_barriers)
+{
+	mb();
+}
+
+static inline void virtio_rmb(bool weak_barriers)
+{
+	rmb();
+}
+
+static inline void virtio_wmb(bool weak_barriers)
+{
+	wmb();
+}
+#endif
 
 struct virtio_device;
 struct virtqueue;
-- 
MST

