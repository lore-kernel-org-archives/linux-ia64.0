From: Bruce Losure <blosure@sgi.com>
Date: Tue, 15 Feb 2005 15:45:39 +0000
Subject: Re: [PATCH 2.6.11-rc2 1/1] altix: Device driver support for the CX
Message-Id: <Pine.LNX.4.44.0502150926120.20276-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
In-Reply-To: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Feb 2005, Christoph Hellwig wrote:

> > I tried to do that, for some reason the first patch (0/1) didn't make it
> > to the mailing list.    Is it important to separate the #include lines
> > as well as the actual file moves?
> 
> In general we prefer to have separate patches for just moving things
> around and real new functionality.
> 

Ok, I will separate it out more thoroughly.

> > 
> > > >  DEFINE_PER_CPU(struct pda_s, pda_percpu);
> > > > +EXPORT_PER_CPU_SYMBOL(pda_percpu);
> > > 
> > > As mentioned the last time you posted it please use a proper accessor.
> > > 
> > 
> > I don't understand what you want.   The symbol is exported so that I can
> > use existing macros from the tiocx code if it's built as a module. 
> 
> What macros are that?  You should probably just turn them into normal
> functions unless they're performance-critical.
> 
> In fact I don't like the SGI pda at all - DEFINE_PER_CPU for each individual
> member isn't anything less performant but much more managable.  But
> that's not a complaint to you but the core SGI plattform people.

I think I (finally) understand what you're looking for.   I can avoid the
export of pda_percpu and replace it with a new, exported, function that
accomplishes the same thing.   I believe someone else is moving in that
direction anyway so they may get there first.

> 
> > > With the above issues fixed it's fine to be queued up until you submit
> > > an actual user of this interface.
> > > 
> > 
> > I will work on providing an acceptable, meaningful, driver but it will
> > take a bit.   Would it be feasible for this code to go in now and for
> > me to follow up with the driver later?
> 
> What users are this?
> 

If I understand what you're asking...   SGI has FPGA based h/w into which
users load their application-specific bitstreams.  We are also providing
some FPGA logic for dma engines, various MMR's and h/w interfaces.
The driver I referenced above is for that FPGA logic.  Basically a char
device driver, on top of the tiocx code, to drive the dma engines and
start the user supplied algorithm.

-- 
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121

