From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 23 Mar 2005 20:02:48 +0000
Subject: Re: [PATCH 3/3] SGI Altix cross partition functionality (2nd
Message-Id: <20050323120248.03755d6b.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4241C391.mailxHNA15A8V0@aqua.americas.sgi.com>
	<20050323195139.GC21418@sgi.com>
In-Reply-To: <20050323195139.GC21418@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: tony.luck@intel.com, netdev@oss.sgi.com, linux-ia64@vger.kernel.org

On Wed, 23 Mar 2005 13:51:39 -0600
Dean Nelson <dcn@sgi.com> wrote:

> This patch contains the cross partition pseudo-ethernet driver (XPNET)
> functional support module.
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>

Only a NIT or two.  You should be setting the last_rx
value.  Also, NETIF_F_HIGHDMA is pointless unless you
support NETIF_F_SG and thus paged SKBs.  skb->data will
never be placed in high memory, only non-linear SKB
scatterlist pages will.

I should probably add a debugging check at device
registration time, like we already do to make sure
NETIF_F_SG is not set unless some checksumming
capability is there as well.
