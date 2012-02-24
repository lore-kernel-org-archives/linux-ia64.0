From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 24 Feb 2012 13:45:52 +0000
Subject: [PATCH 01/11] arch/ia64/hp/sim/simeth.c: print MAC via printk format specifier
Message-Id: <1330091162-8141-2-git-send-email-danny.kukawka@bisect.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Danny Kukawka <dkukawka@suse.de>, "David S. Miller" <davem@davemloft.net>, Jiri Pirko <jpirko@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Print MAC/dev_addr via printk extended format specifier %pm
instead of custom code.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 arch/ia64/hp/sim/simeth.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 47afcc6..440001e 100644
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
+	printk(KERN_INFO "%s: hosteth=%s simfd=%d, HwAddr=%pm, IRQ %d\n",
+	       dev->name, simeth_device, local->simfd, dev->dev_addr, dev->irq);
 
 	return 0;
 }
-- 
1.7.8.3

