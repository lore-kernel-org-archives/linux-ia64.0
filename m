From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:21:07 +0000
Subject: [PATCH v3 33/41] virtio_ring: use virt_store_mb
Message-Id: <1452426622-4471-34-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org

We need a full barrier after writing out event index, using
virt_store_mb there seems better than open-coding.  As usual, we need a
wrapper to account for strong barriers.

It's tempting to use this in vhost as well, for that, we'll
need a variant of smp_store_mb that works on __user pointers.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/virtio_ring.h  | 11 +++++++++++
 drivers/virtio/virtio_ring.c | 15 +++++++++------
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index f3fa55b..a156e2b 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -45,6 +45,17 @@ static inline void virtio_wmb(bool weak_barriers)
 		wmb();
 }
 
+static inline void virtio_store_mb(bool weak_barriers,
+				   __virtio16 *p, __virtio16 v)
+{
+	if (weak_barriers) {
+		virt_store_mb(*p, v);
+	} else {
+		WRITE_ONCE(*p, v);
+		mb();
+	}
+}
+
 struct virtio_device;
 struct virtqueue;
 
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index ee663c4..e12e385 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -517,10 +517,10 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 	/* If we expect an interrupt for the next entry, tell host
 	 * by writing event index and flush out the write before
 	 * the read in the next get_buf call. */
-	if (!(vq->avail_flags_shadow & VRING_AVAIL_F_NO_INTERRUPT)) {
-		vring_used_event(&vq->vring) = cpu_to_virtio16(_vq->vdev, vq->last_used_idx);
-		virtio_mb(vq->weak_barriers);
-	}
+	if (!(vq->avail_flags_shadow & VRING_AVAIL_F_NO_INTERRUPT))
+		virtio_store_mb(vq->weak_barriers,
+				&vring_used_event(&vq->vring),
+				cpu_to_virtio16(_vq->vdev, vq->last_used_idx));
 
 #ifdef DEBUG
 	vq->last_add_time_valid = false;
@@ -653,8 +653,11 @@ bool virtqueue_enable_cb_delayed(struct virtqueue *_vq)
 	}
 	/* TODO: tune this threshold */
 	bufs = (u16)(vq->avail_idx_shadow - vq->last_used_idx) * 3 / 4;
-	vring_used_event(&vq->vring) = cpu_to_virtio16(_vq->vdev, vq->last_used_idx + bufs);
-	virtio_mb(vq->weak_barriers);
+
+	virtio_store_mb(vq->weak_barriers,
+			&vring_used_event(&vq->vring),
+			cpu_to_virtio16(_vq->vdev, vq->last_used_idx + bufs));
+
 	if (unlikely((u16)(virtio16_to_cpu(_vq->vdev, vq->vring.used->idx) - vq->last_used_idx) > bufs)) {
 		END_USE(vq);
 		return false;
-- 
MST

