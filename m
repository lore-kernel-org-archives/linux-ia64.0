From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 15 Feb 2005 13:27:53 +0000
Subject: Re: [PATCH 2.6.11-rc2 1/1] altix: Device driver support for the CX port of SGI's TIO chip
Message-Id: <20050215132753.GA21988@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
In-Reply-To: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I tried to do that, for some reason the first patch (0/1) didn't make it
> to the mailing list.    Is it important to separate the #include lines
> as well as the actual file moves?

In general we prefer to have separate patches for just moving things
around and real new functionality.

> 
> > >  DEFINE_PER_CPU(struct pda_s, pda_percpu);
> > > +EXPORT_PER_CPU_SYMBOL(pda_percpu);
> > 
> > As mentioned the last time you posted it please use a proper accessor.
> > 
> 
> I don't understand what you want.   The symbol is exported so that I can
> use existing macros from the tiocx code if it's built as a module. 

What macros are that?  You should probably just turn them into normal
functions unless they're performance-critical.

In fact I don't like the SGI pda at all - DEFINE_PER_CPU for each individual
member isn't anything less performant but much more managable.  But
that's not a complaint to you but the core SGI plattform people.

> > With the above issues fixed it's fine to be queued up until you submit
> > an actual user of this interface.
> > 
> 
> I will work on providing an acceptable, meaningful, driver but it will
> take a bit.   Would it be feasible for this code to go in now and for
> me to follow up with the driver later?

What users are this?

