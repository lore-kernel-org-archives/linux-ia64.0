From: Robin Holt <holt@sgi.com>
Date: Tue, 11 Jan 2005 18:26:29 +0000
Subject: Re: [patch] Altix BTE error handling fix
Message-Id: <20050111182629.GA19355@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501102333.j0ANXJ4p068948@efs.americas.sgi.com>
In-Reply-To: <200501102333.j0ANXJ4p068948@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 11, 2005 at 09:49:02AM -0800, Jesse Barnes wrote:
> On Tuesday, January 11, 2005 4:12 am, Robin Holt wrote:
> > > I thought this went in months ago.  I guess I need to check on
> > > where this change currently is.
> >
> > I/O Reorg patch blew this away.  Let's talk about the ieclr thing
> > when you get I get into the office today and then resubmit.  This
> > will be the third time we have submitted the spin_unlock() fix :(
> 
> Ugg.  That reorg really shouldn't have touched much beyond the I/O files, but 
> for some reason it hit like everything in the tree.  I mistakenly assumed 
> that it was just lindenting everything, which would have been fine 
> (unfortunately, real changes mixed with lindent are pretty hard to pick up).  
> Sorry about that, I'll keep a closer eye on things.

It was a difficult change to detect this sort of thing on.  The I/O
group was maintaining their patches out of sync with the kernel bk
tree.  We checked changes into the bk tree.  They removed that file
and moved it to a new directory.  When they hit the conflict, they
just assumed their version was correct even though it was out of
date.  Those things happen.  My only regret is we do not have the
time to fully test the error handling on the bte code routinely.
We don't even have the time to put together an automated test.
Sort of stinks.

I have not had a chance to talk with Russ.  I think his patch was
actually correct and I over reacted.  I just want to verify one
thing with him first.

Thanks,
Robin
