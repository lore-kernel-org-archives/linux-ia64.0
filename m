From: "Alexander Beregalov" <a.beregalov@gmail.com>
Date: Tue, 09 Dec 2008 14:11:17 +0000
Subject: next-20081209: build problem at arch/ia64/hp/sim/simeth.c
Message-Id: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-next@vger.kernel.org, Netdev <netdev@vger.kernel.org>, linux-ia64@vger.kernel.org

  CC      arch/ia64/hp/sim/simeth.o
arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no
member named 'open'
arch/ia64/hp/sim/simeth.c:213: error: 'struct net_device' has no
member named 'stop'
arch/ia64/hp/sim/simeth.c:214: error: 'struct net_device' has no
member named 'hard_start_xmit'
arch/ia64/hp/sim/simeth.c:215: error: 'struct net_device' has no
member named 'get_stats'
arch/ia64/hp/sim/simeth.c:216: error: 'struct net_device' has no
member named 'set_multicast_list'
