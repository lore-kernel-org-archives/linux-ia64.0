From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 10 Sep 2004 08:32:06 +0000
Subject: Re: [RFC 0/4] Add SN2 Special Memory driver.
Message-Id: <20040910093206.A22171@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
In-Reply-To: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 10, 2004 at 03:31:13AM -0500, Robin Holt wrote:
> On Fri, Sep 10, 2004 at 08:33:57AM +0100, Christoph Hellwig wrote:
> > On Thu, Sep 09, 2004 at 12:59:37PM -0500, Robin Holt wrote:
> > > I am not sure how to read this.  The fetchop function is a feature specifically
> > > in the SN2 memory controller.  Are you saying we should have a driver that
> > > provides fetchops for all ia64?  That seems wrong since it is a hardware feature.
> > > 
> > > If, on the other hand, you are saying that the uncached and cached drivers
> > > should be available for all ia64 and the fetchop only if you are on sn2, I
> > > can understand that.  That actually seems rather reasonable.
> > 
> > Yes, that's what I meant.  Even if it's mostly useful for SGI's userland
> > it's implementation shouldn't depend on a SN2 kernel if it doesn't use any
> > SN2-specific functionality.
> 
> Do any other processors have the write combining features of the ia64?  Is this
> type of memory useable by any other processor?  If not, does this driver belong
> in the arch/ia64/kernel directory?

Umm, yes I guess it'll be ia64-specific at least as a start,  I just wanted to
avoid having it SN2-specific.

