From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 09 Aug 2004 21:16:20 +0000
Subject: Re: [PATCH] QLogic ISP2x00: remove needless busyloop
Message-Id: <20040809221620.B10454@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408091252.58547.bjorn.helgaas@hp.com> <200408091419.20029.bjorn.helgaas@hp.com> <20040809212147.A9919@infradead.org> <200408091508.27773.bjorn.helgaas@hp.com>
In-Reply-To: <200408091508.27773.bjorn.helgaas@hp.com>; from bjorn.helgaas@hp.com on Mon, Aug 09, 2004 at 03:08:27PM -0600
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, grif@cs.ucr.edu, linux-kernel@vger.kernel.org

On Mon, Aug 09, 2004 at 03:08:27PM -0600, Bjorn Helgaas wrote:
> > > In general, I think if a driver is in the tree, it should be fair
> > > game for bugfixes.  In fact, I see you did the most recent one to
> > > qlogicfc :-)
> > 
> > That wasn't a bugfix, look harder.
> 
> My apologies.  I should have written "if a driver is in the
> tree, it should be fair game to improve it."

I don't object to the patch.  But it was a _very_ _strong_ _hint_ that you
did something wrong if the patch actually matters for you.

