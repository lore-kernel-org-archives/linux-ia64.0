From: Greg KH <gregkh@suse.de>
Date: Thu, 12 Jan 2006 17:17:09 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <20060112171709.GA28821@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222171621.8240.71918.22618@lnx-maule.americas.sgi.com>
In-Reply-To: <20051222171621.8240.71918.22618@lnx-maule.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 12, 2006 at 08:55:15AM -0800, Joe Perches wrote:
> On Thu, 2006-01-12 at 00:33 -0700, Grant Grundler wrote:
> > On Thu, Jan 12, 2006 at 04:47:27PM +1100, Paul Mackerras wrote:
> > > Grant Grundler writes:
> > > > > +	if ((status = msi_arch_init()) < 0) {
> > > > Willy told me I should always complain about assignment in if() statements :)
> > > We are getting incredibly politically correct these days, aren't we.
> > I'm not asking greg to reject the patch nor dictating Mark Mauler change it.
> > Since greg is willing to accept a patch to "fix" it, I'm willing to provide 
> > the patch in this case. I think that's fairly normal way to clean things up.
> 
> (me too)
> 
> Here's a patch for drivers/pci

-ENOCHANGELOGANDSIGNEDOFFBYLINE  :(

