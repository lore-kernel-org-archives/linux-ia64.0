From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 03 Mar 2004 22:21:16 +0000
Subject: Re: Fix staircase effect on Altix serial console.
Message-Id: <20040303222116.GA5481@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1xoa7qtb.fsf@sykes.suse.de>
In-Reply-To: <je1xoa7qtb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 03, 2004 at 12:44:49PM -0800, Jesse Barnes wrote:
> On Wed, Mar 03, 2004 at 06:36:21PM +0100, Andreas Schwab wrote:
> > > I've filed a bug with our system controller group to make the behavior
> > > of the L2 and L1 system controllers consistent (I believe you're using
> > > an L1), which I think is the proper fix.
> > 
> > No, it is the *wrong* thing to do.  If you do stty -onlcr you should get
> > just one NL, nothing else.  It's the job of the tty layer and the serial
> > console write function to translate NL to CRNL, nobody else should mangle
> > the output in any way.
> 
> Right, that's why I'm saying that the l2 shouldn't mangle output, nor
> should the PROM.  They should just pass through whatever the serial
> driver hands them.  I think we're in agreement here?

Sorry, I should have been clearer:  our L2 system controller will be
fixed to *not* add CRs, as will our PROM, so we'll need your fix.
David, can you please apply it?  Sorry for the runaround.

Andreas, does that sound right?

Thanks,
Jesse
