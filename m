From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 23 Mar 2005 20:54:37 +0000
Subject: Re: [PATCH 3/3] SGI Altix cross partition functionality (2nd
Message-Id: <20050323125437.76c865ad.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050323195139.GC21418@sgi.com>
In-Reply-To: <20050323195139.GC21418@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 23 Mar 2005 14:50:03 -0600
Dean Nelson <dcn@sgi.com> wrote:

> On Wed, Mar 23, 2005 at 12:02:48PM -0800, David S. Miller wrote:
> >
> > Only a NIT or two.  You should be setting the last_rx
> > value.  Also, NETIF_F_HIGHDMA is pointless unless you
> > support NETIF_F_SG and thus paged SKBs.  skb->data will
> > never be placed in high memory, only non-linear SKB
> > scatterlist pages will.
> 
> Dave, I've made the changes you indicated and the new patch follows.

Looks great.
