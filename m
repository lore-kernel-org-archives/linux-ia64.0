From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 09 Aug 2004 21:08:27 +0000
Subject: Re: [PATCH] QLogic ISP2x00: remove needless busyloop
Message-Id: <200408091508.27773.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408091252.58547.bjorn.helgaas@hp.com> <200408091419.20029.bjorn.helgaas@hp.com> <20040809212147.A9919@infradead.org>
In-Reply-To: <20040809212147.A9919@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, grif@cs.ucr.edu, linux-kernel@vger.kernel.org

> > In general, I think if a driver is in the tree, it should be fair
> > game for bugfixes.  In fact, I see you did the most recent one to
> > qlogicfc :-)
> 
> That wasn't a bugfix, look harder.

My apologies.  I should have written "if a driver is in the
tree, it should be fair game to improve it."

I think I'm missing something in this exchange.  Are you

1) Pointing out that the qlogicfc is obsolete and shouldn't
be used?  If so, thanks for the tip.

2) Suggesting that no changes to qlogicfc should be made?  If so,
I think it should be removed from the tree altogether.

3) Objecting to my patch because it is incorrect?  If so, please
give me a hint about what the problem is.

4) Something else?
