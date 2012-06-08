From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 08 Jun 2012 08:03:59 +0000
Subject: Re: [PATCH] IA64: Export <asm/cmpxchg.h> to userland
Message-Id: <20120608080359.GB24167@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1339041112.21665.77.camel@deadeye.wl.decadent.org.uk>
In-Reply-To: <1339041112.21665.77.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 08, 2012 at 03:09:50AM +0100, Ben Hutchings wrote:
> On Fri, 2012-06-08 at 10:43 +0900, Greg Kroah-Hartman wrote:
> > On Thu, Jun 07, 2012 at 09:07:13PM +0100, Ben Hutchings wrote:
> > > On Thu, Jun 07, 2012 at 04:54:56PM +0000, Luck, Tony wrote:
> > > > > Parts of <asm/intrinsics.h> were moved to <asm/cmpxchg.h>, and the
> > > > > former now includes the latter.  The former is exported to userland
> > > > > so the latter must be too.
> > > > 
> > > > Already received and applied a patch that does this (though it added
> > > > the cmpxchg.h a few lines earlier that you did).
> > > > 
> > > > See commit: 98e4cff73
> > > > 
> > > > It didn't get marked for stable though ... so if you need this to
> > > > get pulled into the stable branches you'll need to poke Greg etc.
> > > > manually.
> > > 
> > > Greg, please cherry-pick commit
> > > 85f8f7759e418c814ee2ceacf73eddb9bed39492 ('[IA64] Add cmpxchg.h to
> > > exported userspace headers') for 3.4.y.
> > 
> > I tried, but it doesn't apply properly.  Can someone backport it and
> > send it to me?
> 
> Sorry, I mean 98e4cff73a18af27f0d40d0b0d37f105dfc1994a; the former
> commit is already in 3.4 and resulted in this breakage.

Ah, that's better, now applied.

greg k-h
