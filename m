From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Fri, 06 Feb 2004 17:34:35 +0000
Subject: RE: gcc problems
Message-Id: <A06801158AE07847B27A52C1A074BC1D0247BC58@fmsmsx404.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> >> -  unsigned long int sc_rsvd[16];/* reserved for future use */
> >> +  unsigned long int sc_rbs_base;/* NULL or new base of 
> sighandler's rbs */
> >> +  unsigned long int sc_loadrs;	/* see description above */
> >> +  unsigned long int sc_ar25;	/* cmp8xchg16 uses this */
> >> +  unsigned long int sc_ar26;	/* rsvd for scratch use */
> >> +  unsigned long int sc_rsvd[12];/* reserved for future use */
> >>
> >> > The easiest workaround is probably to install libunwind 
> on your system
> >>
> >> The right fix is not to use a 2 years old glibc.
> > 
> > 
> > That's not very old.  One shouldn't have to upgrade libc 
> just to build gcc?
> 
> Did the two-year-old libc really support ia64 well?   I guess 
> Itanium 1 was out then, but those were early days...

If it's a question of glibc 2.2.x vs. 2.3.x, there are
ia64 Linux distributions based on glibc 2.2 that work
pretty well - SUSE's SLES8, for example.  The glibc
used there is somewhere in between the two extremes
noted here (sc_rsvd is 14, and the sc_rbs_base and
sc_loadrs fields are defined).

It's kind of painful when we have to have these lockstep
dependencies but I guess things have to be moved forward
somehow.

