From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:26:47 +0000
Subject: [PATCH] xen-netfront: Avoid unaligned accesses to IP header.
Message-Id: <20080826052647.GC1496%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Jeremy Fitzhardinge <jeremy@goop.org>
Cc: virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, xen-ia64-devel@lists.xensource.com, linux-ia64@vger.kernel.org

Align ip header to a 16 byte boundary to avoid unaligned
access like other drivers.
Without this patch, xen-netfront doesn't work well on ia64.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/net/xen-netfront.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 3c3dd40..7416f41 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -239,11 +239,14 @@ static void xennet_alloc_rx_buffers(struct net_device *dev)
 	 */
 	batch_target = np->rx_target - (req_prod - np->rx.rsp_cons);
 	for (i = skb_queue_len(&np->rx_batch); i < batch_target; i++) {
-		skb = __netdev_alloc_skb(dev, RX_COPY_THRESHOLD,
+		skb = __netdev_alloc_skb(dev, RX_COPY_THRESHOLD + NET_IP_ALIGN,
 					 GFP_ATOMIC | __GFP_NOWARN);
 		if (unlikely(!skb))
 			goto no_skb;
 
+		/* Align ip header to a 16 bytes boundary */
+		skb_reserve(skb, NET_IP_ALIGN);
+
 		page = alloc_page(GFP_ATOMIC | __GFP_NOWARN);
 		if (!page) {
 			kfree_skb(skb);
-- 
1.6.0.rc0.42.g186458
