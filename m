From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 09 Dec 2008 15:08:27 +0000
Subject: [PATCH] simnet: convert to net_device_ops
Message-Id: <20081209150827.GA8134@x200.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
In-Reply-To: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Beregalov <a.beregalov@gmail.com>, davem@davemloft.net
Cc: linux-next@vger.kernel.org, Netdev <netdev@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tue, Dec 09, 2008 at 05:11:17PM +0300, Alexander Beregalov wrote:
>   CC      arch/ia64/hp/sim/simeth.o
> arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
> arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no member named 'open'

[PATCH] simeth: convert to net_device_ops

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/ia64/hp/sim/simeth.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -167,6 +167,15 @@ netdev_read(int fd, unsigned char *buf, unsigned int len)
 	return ia64_ssc(fd, __pa(buf), len, 0, SSC_NETDEV_RECV);
 }
 
+static const struct net_device_ops simeth_netdev_ops = {
+	.ndo_open		= simeth_open,
+	.ndo_stop		= simeth_close,
+	.ndo_start_xmit		= simeth_tx,
+	.ndo_get_stats		= simeth_get_stats,
+	.ndo_set_multicast_list	= set_multicast_list, /* not yet used */
+
+};
+
 /*
  * Function shared with module code, so cannot be in init section
  *
@@ -209,11 +218,7 @@ simeth_probe1(void)
 	local = netdev_priv(dev);
 	local->simfd = fd; /* keep track of underlying file descriptor */
 
-	dev->open		= simeth_open;
-	dev->stop		= simeth_close;
-	dev->hard_start_xmit	= simeth_tx;
-	dev->get_stats		= simeth_get_stats;
-	dev->set_multicast_list = set_multicast_list; /* no yet used */
+	dev->netdev_ops = &simeth_netdev_ops;
 
 	err = register_netdev(dev);
 	if (err) {
