From: Linas Vepstas <linas@austin.ibm.com>
Date: Tue, 01 Mar 2005 19:27:11 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <20050301192711.GE1220@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <20050301144211.GI28741@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050301144211.GI28741@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Luck, Tony" <tony.luck@intel.com>

On Tue, Mar 01, 2005 at 02:42:11PM +0000, Matthew Wilcox was heard to remark:
> On Tue, Mar 01, 2005 at 05:33:48PM +0900, Hidetoshi Seto wrote:
> > Today's patch is 3rd one - iochk_clear/read() interface.
> > - This also adds pair-interface, but not to sandwich only readX().
> >   Depends on platform, starting with ioreadX(), inX(), writeX()
> >   if possible... and so on could be target of error checking.
> 
> I'd prefer to see it as ioerr_clear(), ioerr_read() ...

I'd prefer pci_io_start() and pci_io_check_err()

The names should have "pci" in them.

I don't like "ioerr_clear" because it implies we are clearing the 
io error; we are not; we are clearing the checker for io errors.

> > - Additionally adds special token - abstract "iocookie" structure
> >   to control/identifies/manage I/Os, by passing it to OS.
> >   Actual type of "iocookie" could be arch-specific. Device drivers
> >   could use the iocookie structure without knowing its detail.
> 
> Fine.

Do we really need a cookie?

> > If arch doesn't(or cannot) have its io-checking strategy, these
> > interfaces could be used as a replacement of local_irq_save/restore
> > pair. Therefore, driver maintainer can write their driver code with
> > these interfaces for all arch, even where checking is not implemented.
> 
> But many drivers don't need to save/restore interrupts around IO accesses.
> I think defaulting these to disable and restore interrupts is a very bad idea.
> They should probably be no-ops in the generic case.

Yes, they should be no-ops. save/resotre interrupts would be a bad idea.

--linas
