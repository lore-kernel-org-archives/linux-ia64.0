From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 23 Sep 2003 00:34:18 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106427735209595@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


OK, a patch for the driver in 2.6.0-test5 is appended.

I suspect that there are other architectures that don't like unaligned
accesses...  feel free to add them to the #ifdef.
This is based on code I found in the revision history.  It seems to
work.

Without this patch, the console messages saying `unaligned access'
would come out fast enough and often enough to delay and or miss
interrupts, leading to an eventual machine hangup on I2000.

=== drivers/net/ns83820.c 1.30 vs edited ==--- 1.30/drivers/net/ns83820.c	Thu Sep 11 09:46:45 2003
+++ edited/drivers/net/ns83820.c	Mon Sep 22 12:49:18 2003
@@ -793,6 +793,25 @@
 	}
 }
 
+#if defined(__ia64__)
+static inline struct sk_buff *skb_realign_iphdr(struct sk_buff *skb, int len, struct ns83820 *dev)
+{
+	struct sk_buff *tmp = __dev_alloc_skb(len+2, GFP_ATOMIC);
+	if (!tmp)
+		return NULL;
+	tmp->dev = &dev->net_dev;
+	skb_reserve(tmp, 2);
+	memcpy(skb_put(tmp, len), skb->data, len);
+	kfree_skb(skb);
+	return tmp;
+}
+#else
+static inline  struct sk_buff *skb_realign_iphdr(struct sk_buff *skb, int len, struct ns83820 *dev)
+{
+	return skb;
+}
+#endif
+
 static void FASTCALL(ns83820_rx_kick(struct ns83820 *dev));
 static void ns83820_rx_kick(struct ns83820 *dev)
 {
@@ -862,6 +881,7 @@
 		if (likely(CMDSTS_OK & cmdsts)) {
 			int len = cmdsts & 0xffff;
 			skb_put(skb, len);
+			skb = skb_realign_iphdr(skb, len, dev);
 			if (unlikely(!skb))
 				goto netdev_mangle_me_harder_failed;
 			if (cmdsts & CMDSTS_DEST_MULTI)
