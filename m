From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 09 Aug 2004 20:21:47 +0000
Subject: Re: [PATCH] QLogic ISP2x00: remove needless busyloop
Message-Id: <20040809212147.A9919@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408091252.58547.bjorn.helgaas@hp.com> <20040809210335.A9711@infradead.org> <200408091419.20029.bjorn.helgaas@hp.com>
In-Reply-To: <200408091419.20029.bjorn.helgaas@hp.com>; from bjorn.helgaas@hp.com on Mon, Aug 09, 2004 at 02:19:20PM -0600
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-ia64@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, grif@cs.ucr.edu, linux-kernel@vger.kernel.org

On Mon, Aug 09, 2004 at 02:19:20PM -0600, Bjorn Helgaas wrote:
> I don't use it (note the "there's no isp2x00" bit above).  But it's
> still part of ia64 defconfig (which I don't maintain), and it's easier
> to tell people "use generic_defconfig" than to tell them to remove
> CONFIG_SCSI_QLOGIC_FC by hand.

So tell David to fix up the defconfig..

> In general, I think if a driver is in the tree, it should be fair
> game for bugfixes.  In fact, I see you did the most recent one to
> qlogicfc :-)

That wasn't a bugfix, look harder.
