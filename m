From: Philip Mucci <mucci@cs.utk.edu>
Date: Tue, 07 Dec 2004 10:21:05 +0000
Subject: Re: [Gelato-technical] RE: q-tools v0.2 released
Message-Id: <1102414865.3969.6.camel@muccislaptop.pdc.kth.se>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ken,

If you want an overall system profile, why not use oprofile? That's what
it's made for....tools like q-tools, hpctoolkit, psrun, vprof, and papi-
like tools are application tools...

Phil


On Mon, 2004-12-06 at 18:38 -0800, Chen, Kenneth W wrote:
> David Mosberger wrote on Monday, October 11, 2004 8:53 AM
> > I'm happy to announce that q-tools v0.2 has been released.  q-tools is
> > a collection of Linux performance analysis tools.  In particular, they
> > include q-syscollect and q-view, which can be thought of as being more
> > powerful than gprof, without its pain (no recompilation needed;
> > multi-threaded apps and shared libraries are supported;
> > kernel-execution can be profiled; any Itanium 2 PMU event can be
> > profiled, etc.).
> >
> 
> I'm craving for more, is there a q-merge kind of utility out there? i.e.,
> merge all the cpu .hist files into one to get an overall system profile.  I
> can do that right now by hand (cat cpu*.hist into one file and then generate
> corresponding .info file).  I hope someone already had such tool so I don't
> have to reinvent the wheel.
> 
> - Ken
> 
> 
> 
> _______________________________________________
> Gelato-technical mailing list
> Gelato-technical@gelato.unsw.edu.au
> https://www.gelato.unsw.edu.au/mailman/listinfo/gelato-technical

