From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 20 May 2004 15:18:05 +0000
Subject: Re: [PATCH] early console registration
Message-Id: <200405200918.05821.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405141425.59867.jbarnes@engr.sgi.com>
In-Reply-To: <200405141425.59867.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 20 May 2004 7:03 am, Jesse Barnes wrote:
> On Wednesday, May 19, 2004 9:17 pm, David Mosberger wrote:
> > >>>>> On Fri, 14 May 2004 14:25:59 -0700, Jesse Barnes
> > >>>>> <jbarnes@engr.sgi.com> said:
> >
> >   Jesse> Is this reasonable?  I've tested it on a couple of machines
> >   Jesse> here and it works well.  It's really useful for debugging
> >   Jesse> setup_arch problems.
> >
> > I don't like the #ifdef's very much, but I suppose I can live with
> > them in this case.  IIRC, Bjorn also has been working on some
> > early-printk changes so I'd be interested in his opinion.
> 
> Yeah, me neither, but I like the alternative even less--ia64_platform_is 
> and .weak symbols or something.  I *think* this approach will work for Bjorn 
> too (and any other driver that's ok with being called early), but it would be 
> nice to hear it. :)

Well, you could always implement a PCDP (primary console & debug
port device table -- an extension of HCDP).  That would remove the
need for the ia64_platform_is() in your driver and move the #ifdefs
into the pcdp setup routine.  That wouldn't solve the problem for
legacy firmware, though, so what you've got is probably the best
we can do for now.

The interesting bit to me is setting CPU 0 online early.  We've
already set up I/O port space and the machine vector, so that
should be OK.  We haven't done cpu_init() yet, so the per-CPU
data mapping isn't set up yet.  I guess it's probably reasonable
to prohibit early console drivers from using per-CPU data.

Bjorn
