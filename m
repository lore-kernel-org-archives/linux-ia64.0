From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Date: Mon, 28 Dec 2009 22:24:38 +0000
Subject: [PATCH] simeth.c: use %pM to shown MAC address
Message-Id: <BD79186B4FD85F4B8E60E381CAEE19090200F4B7@mi8nycmail19.Mi8.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: David Miller <davem@davemloft.net>

Use the %pM kernel extension to display the HwAddr.

The only difference in the output is that the MAC address is
shown in the usual colon-separated hex notation instead of
space-separated.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 7e81966..3489b0d 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -193,7 +193,7 @@ simeth_probe1(void)
 	unsigned char mac_addr[ETH_ALEN];
 	struct simeth_local *local;
 	struct net_device *dev;
-	int fd, i, err, rc;
+	int fd, err, rc;
 
 	/*
 	 * XXX Fix me
@@ -236,12 +236,8 @@ simeth_probe1(void)
 	 */
 	netdev_connect(dev->irq);
 
-	printk(KERN_INFO "%s: hosteth=%s simfd=%d, HwAddr",
-	       dev->name, simeth_device, local->simfd);
-	for(i = 0; i < ETH_ALEN; i++) {
-		printk(" %2.2x", dev->dev_addr[i]);
-	}
-	printk(", IRQ %d\n", dev->irq);
+	printk(KERN_INFO "%s: hosteth=%s simfd=%d, HwAddr %pM, IRQ %d\n",
+	       dev->name, simeth_device, local->simfd, dev->dev_addr, dev->irq);
 
 	return 0;
 } 
