From: David Miller <davem@davemloft.net>
Date: Wed, 10 Dec 2008 06:41:08 +0000
Subject: Re: next-20081209: build problem at arch/ia64/hp/sim/simeth.c
Message-Id: <20081209.224108.265455718.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
In-Reply-To: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: a.beregalov@gmail.com
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org, linux-ia64@vger.kernel.org

From: "Alexander Beregalov" <a.beregalov@gmail.com>
Date: Tue, 9 Dec 2008 17:11:17 +0300

>   CC      arch/ia64/hp/sim/simeth.o
> arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
> arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no
> member named 'open'
> arch/ia64/hp/sim/simeth.c:213: error: 'struct net_device' has no
> member named 'stop'
> arch/ia64/hp/sim/simeth.c:214: error: 'struct net_device' has no
> member named 'hard_start_xmit'
> arch/ia64/hp/sim/simeth.c:215: error: 'struct net_device' has no
> member named 'get_stats'
> arch/ia64/hp/sim/simeth.c:216: error: 'struct net_device' has no
> member named 'set_multicast_list'

The only way for this to happen is if CONFIG_COMPAT_NET_DEV_OPS
is not set.

And we force it on in net/Kconfig:

config COMPAT_NET_DEV_OPS
       def_bool y

Perhaps you simply need to update your config properly or something
like that.
