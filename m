From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 24 Jan 2014 01:52:56 +0000
Subject: [PATCH 2/5] ia64 simeth: fix bugs in the ski emulator ethernet driver
Message-Id: <alpine.LRH.2.02.1401232044180.16873@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LRH.2.02.1401232041520.16873@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1401232043320.16873@file01.intranet.prod.int.rdu2.redhat.com>
In-Reply-To: <alpine.LRH.2.02.1401232043320.16873@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This patch fixes the following bugs:

* Lockup when out of memory: If we are out of memory, we must actually
  read the data and drop it. If we don't read the data, the interrupt is
  still pending and the data are still in the emulator's queue. The guest
  system locks up, processing the interrupt forever and trying to allocate
  a sk_buff.

* Fix a memory leak. If the emulator has no more packets for us, it
  returns zero. We need to free the allocated skbuf, otherwise it is
  leaked.

* There was double warning when out of memory.

* Two nested loops on receive - not a bug, but they are useless.
  The upper loop in simeth_interrupt is unconditional, it loops until some
  data were read. The lower loop in simeth_rx loops SIMETH_RECV_MAX times.
  I replaced them with just one loop in simeth_rx that loops as long as
  some data were read.

* Removed some informational printks that happen under normal operation.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 arch/ia64/hp/sim/simeth.c |   41 ++++++++++++-----------------------------
 1 file changed, 12 insertions(+), 29 deletions(-)

Index: linux-2.6-ia64/arch/ia64/hp/sim/simeth.c
=================================--- linux-2.6-ia64.orig/arch/ia64/hp/sim/simeth.c	2014-01-24 02:02:52.000000000 +0100
+++ linux-2.6-ia64/arch/ia64/hp/sim/simeth.c	2014-01-24 02:32:40.000000000 +0100
@@ -25,8 +25,6 @@
 
 #include "hpsim_ssc.h"
 
-#define SIMETH_RECV_MAX	10
-
 /*
  * Maximum possible received frame for Ethernet.
  * We preallocate an sk_buff of that size to avoid costly
@@ -48,7 +46,7 @@ static int simeth_probe1(void);
 static int simeth_open(struct net_device *dev);
 static int simeth_close(struct net_device *dev);
 static int simeth_tx(struct sk_buff *skb, struct net_device *dev);
-static int simeth_rx(struct net_device *dev);
+static void simeth_rx(struct net_device *dev);
 static struct net_device_stats *simeth_get_stats(struct net_device *dev);
 static irqreturn_t simeth_interrupt(int irq, void *dev_id);
 static void set_multicast_list(struct net_device *dev);
@@ -299,13 +297,9 @@ simeth_device_event(struct notifier_bloc
 			if (strcmp(dev->name, ifa->ifa_label) = 0) break;
 	}
 	if ( ifa = NULL ) {
-		printk(KERN_ERR "simeth_open: can't find device %s's ifa\n", dev->name);
 		return NOTIFY_DONE;
 	}
 
-	printk(KERN_INFO "simeth_device_event: %s ipaddr=0x%x\n",
-	       dev->name, ntohl(ifa->ifa_local));
-
 	/*
 	 * XXX Fix me
 	 * if the device was up, and we're simply reconfiguring it, not sure
@@ -318,9 +312,6 @@ simeth_device_event(struct notifier_bloc
 		netdev_attach(local->simfd, dev->irq, ntohl(ifa->ifa_local)):
 		netdev_detach(local->simfd);
 
-	printk(KERN_INFO "simeth: netdev_attach/detach: event=%s ->%d\n",
-	       event = NETDEV_UP ? "attach":"detach", r);
-
 	return NOTIFY_DONE;
 }
 
@@ -408,7 +399,6 @@ make_new_skb(struct net_device *dev)
 	 */
 	nskb = dev_alloc_skb(SIMETH_FRAME_SIZE + 2);
 	if ( nskb = NULL ) {
-		printk(KERN_NOTICE "%s: memory squeeze. dropping packet.\n", dev->name);
 		return NULL;
 	}
 
@@ -422,34 +412,30 @@ make_new_skb(struct net_device *dev)
 /*
  * called from interrupt handler to process a received frame
  */
-static int
+static void
 simeth_rx(struct net_device *dev)
 {
 	struct simeth_local	*local;
 	struct sk_buff		*skb;
 	int			len;
-	int			rcv_count = SIMETH_RECV_MAX;
+	static u8		oom_sink[SIMETH_FRAME_SIZE];
 
 	local = netdev_priv(dev);
-	/*
-	 * the loop concept has been borrowed from other drivers
-	 * looks to me like it's a throttling thing to avoid pushing to many
-	 * packets at one time into the stack. Making sure we can process them
-	 * upstream and make forward progress overall
-	 */
-	do {
+	while (1) {
 		if ( (skb=make_new_skb(dev)) = NULL ) {
 			printk(KERN_NOTICE "%s: memory squeeze. dropping packet.\n", dev->name);
-			local->stats.rx_dropped++;
-			return 0;
+			while (netdev_read(local->simfd, oom_sink, SIMETH_FRAME_SIZE))
+				local->stats.rx_dropped++;
+			return;
 		}
 		/*
 		 * Read only one frame at a time
 		 */
 		len = netdev_read(local->simfd, skb->data, SIMETH_FRAME_SIZE);
 		if ( len = 0 ) {
-			if ( simeth_debug > 0 ) printk(KERN_WARNING "%s: count=%d netdev_read=0\n",
-						       dev->name, SIMETH_RECV_MAX-rcv_count);
+			kfree_skb(skb);
+			if ( simeth_debug > 0 ) printk(KERN_WARNING "%s: netdev_read=0\n",
+						       dev->name);
 			break;
 		}
 #if 0
@@ -471,9 +457,7 @@ simeth_rx(struct net_device *dev)
 		local->stats.rx_packets++;
 		local->stats.rx_bytes += len;
 
-	} while ( --rcv_count );
-
-	return len; /* 0 = nothing left to read, otherwise, we can try again */
+	}
 }
 
 /*
@@ -487,7 +471,7 @@ simeth_interrupt(int irq, void *dev_id)
 	/*
 	 * very simple loop because we get interrupts only when receiving
 	 */
-	while (simeth_rx(dev));
+	simeth_rx(dev);
 	return IRQ_HANDLED;
 }
 
@@ -503,7 +487,6 @@ simeth_get_stats(struct net_device *dev)
 static void
 set_multicast_list(struct net_device *dev)
 {
-	printk(KERN_WARNING "%s: set_multicast_list called\n", dev->name);
 }
 
 __initcall(simeth_probe);

