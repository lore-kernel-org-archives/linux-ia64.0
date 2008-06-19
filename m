From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Thu, 19 Jun 2008 02:37:21 +0000
Subject: RE: [PATCH 06/27] ia64/xen: define NET_SKB_NET to 18 if xen.
Message-Id: <13C8D1B5662635takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840432829-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840432829-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, Tony

>> Resolve it by increasing NET_SKB_NET from the default value 16 to 18.
>
>Typo?  You mean NET_SKB_PAD here?
>
I think so. :-)

>But in include/linux/skbuff.h it says: "It must be a power of 2".
>
>Explain why 18 is ok.
It's supposed to add NET_IP_ALIGN when network driver allocs 
skb with netdev_alloc_skb(). For example, e1000 do like the below, too.

struct sk_buff *new_skb = netdev_alloc_skb(netdev, length + NET_IP_ALIGN);

In the case of xen, xen-frontend.c also uses __netdev_alloc_skb(),
so we need to add 16 + NET_IP_ALIGN for padding.
I think we use NET_SKB_PAD+NET_IP_ALIGN or
we add it to length of __netdev_alloc_skb().

The below is my patch being relative to this.
http://xenbits.xensource.com/xen-unstable.hg?csy7430d25f1b

Best Regards,

Akio Takebe

