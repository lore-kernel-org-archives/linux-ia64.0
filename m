From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 11 Oct 2005 21:57:04 +0000
Subject: Re: [PATCH] set altix preferred console
Message-Id: <200510111557.05019.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 11 October 2005 3:31 pm, Mark Maule wrote:
> On Tue, Oct 11, 2005 at 03:19:39PM -0600, Bjorn Helgaas wrote:
> > On Tuesday 11 October 2005 2:00 pm, Mark Maule wrote:
> > > So we will dup some of the PCDP scan code in sn/kernel/setup.c for the time
> > > being.  Does anyone have a problem with moving drivers/firmware/pcdp.h under
> > > include/asm-ia64 so that I don't also have to dup the structure definitions?
> > 
> > I don't want to move pcdp.h under asm-ia64.  EFI (and, I hope,
> > PCDP) is coming to x86 soon.  There's nothing ia64-specific
> > in pcdp.h or pcdp.c, so I think it would be a mistake to
> > move it to an arch-specific directory.
> 
> Ok, thanks Bjorn.  I was under the impression that stuff under dig64.org
> was ia64 specific ...
> 
> Would moving it to include/linux be an option?

I sort of hate to put it in include/linux, too, but I guess
it's already a dumping ground for all sorts of miscellaneous
stuff, so one more wouldn't make it much worse.

And I can't think of any better options.
