From: Greg KH <greg@kroah.com>
Date: Fri, 18 Apr 2003 23:19:04 +0000
Subject: [Linux-ia64] Re: USB deadlock in v2.5.67
Message-Id: <marc-linux-ia64-105590723705569@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705560@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705560@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 18, 2003 at 08:46:56AM -0700, David Brownell wrote:
> Greg KH wrote:
> >On Thu, Apr 17, 2003 at 07:02:07PM -0700, David Mosberger wrote:
> >
> >><hcd_free_dev+0x140> translates into line 1249 in hcd.c, where it
> >>does:
> >>
> >>	spin_lock_irqsave (&hcd_data_lock, flags);
> >>
> >>The deadlock is pretty obvious: the same lock has already been
> >>acquired urb_unlink(), 4 levels up in the call-chain.
> >>
> >>Anybody have a fix for this?
> >
> >
> >David (Brownell, that is), does this help with the trace I sent you a
> >few hours ago?
> 
> Seems to be a different problem.  The patch below should
> resolve the keyboard problem -- just reorders two lines
> so the lock isn't held after the device's records get
> deleted, so the order is what it should always have been.

Applied to my trees, thanks.

greg k-h

