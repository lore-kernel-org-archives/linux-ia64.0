From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 23 Feb 2004 21:43:39 +0000
Subject: Re: SAL version checking
Message-Id: <20040223214339.GA8778@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040223210103.GG25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040223210103.GG25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 09:21:01PM +0000, Matthew Wilcox wrote:
> On Mon, Feb 23, 2004 at 01:09:20PM -0800, Jesse Barnes wrote:
> > It looks reasonable to me, though I thought we were the only ones that
> > cared about PROM revisions ;).  If you go ahead and push this in, we
> > could use it in arch/ia64/sn/kernel/setup.c, where we check for
> > incompatibilties bad enough to cause us to bail out...
> 
> Well, you *were* the only ones who cared about SAL revisions ;-)
> Actually, this isn't quite what you want.  I'm asking the firmware
> what rev of the SAL spec it reports; you want version number of the
> prom.  I want sal_rev_major/minor; you want sal_b_rev_major/minor.

Right, I realized that after I sent the mail...

> I don't see why we shouldn't do both, and possibly even print both.
> I've occasionally wondered what rev of firmware I'm running and
> rebooting to figure that out is less satisfactory than grovelling through
> /var/log/dmesg.

Yeah, it would be nice to have it more generally available.  It's one of
those few printk's which is actually useful. :)

Jesse
