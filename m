From: Domen Puncer <domen@coderock.org>
Date: Wed, 29 Dec 2004 19:44:30 +0000
Subject: [patch] ia64: remove casts in hp/sim/simeth.c
Message-Id: <20041229194430.GA25967@nd47.coderock.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove unneeded casts of (void *) pointers.

Signed-off-by: Domen Puncer <domen@coderock.org>

--- c/arch/ia64/hp/sim/simeth.c	2004-11-15 13:42:06.000000000 +0100
+++ a/arch/ia64/hp/sim/simeth.c	2004-12-03 14:11:21.000000000 +0100
@@ -286,7 +286,7 @@ static __inline__ int dev_is_ethdev(stru
 static int
 simeth_device_event(struct notifier_block *this,unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = ptr;
 	struct simeth_local *local;
 	struct in_device *in_dev;
 	struct in_ifaddr **ifap = NULL;
@@ -382,7 +382,7 @@ frame_print(unsigned char *from, unsigne
 static int
 simeth_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct simeth_local *local = (struct simeth_local *)dev->priv;
+	struct simeth_local *local = dev->priv;
 
 #if 0
 	/* ensure we have at least ETH_ZLEN bytes (min frame size) */
@@ -446,7 +446,7 @@ simeth_rx(struct net_device *dev)
 	int			len;
 	int			rcv_count = SIMETH_RECV_MAX;
 
-	local = (struct simeth_local *)dev->priv;
+	local = dev->priv;
 	/*
 	 * the loop concept has been borrowed from other drivers
 	 * looks to me like it's a throttling thing to avoid pushing to many
@@ -515,7 +515,7 @@ simeth_interrupt(int irq, void *dev_id, 
 static struct net_device_stats *
 simeth_get_stats(struct net_device *dev)
 {
-	struct simeth_local  *local = (struct simeth_local *) dev->priv;
+	struct simeth_local *local = dev->priv;
 
 	return &local->stats;
 }
