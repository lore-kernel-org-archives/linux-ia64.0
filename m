From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 18 Oct 2006 22:25:49 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061018222549.GE20590@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack,

On Wed, Oct 18, 2006 at 04:55:30PM -0500, Jack Steiner wrote:
> On Wed, Oct 18, 2006 at 02:44:13PM -0700, Stephane Eranian wrote:
> > Jack,
> > 
> > The perfmon subsystem will not work correctly if you mix
> > Madison and Montecito in the same box. And there is not an
> > easy way to make it work with such configuration. Performance
> > counters are different between the two models.
>  
> The failing case that I ran into was a mixture of rev 5 & rev 7
> montecitos:
>         Intel(r) Itanium(r) 2 Processor 1.6GHz with 24M L3 Cache for 533MHz Platforms
>         Intel(r) Itanium(r) 2 Processor 1.6GHz with 18M L3 Cache for 533MHz Platforms
> 
> I assume that will work ok. Right?
> 
Yes, I think for this you are ok.

> However, there is also a patch that Russ Anderson pushed last week (at least
> I think he pushed it). We are planning to support systems with mixtures of both
> madison & montecito. Sounds like we have a problem :-(
> 
Yes, I recall seeing something along those lines not too long ago...
With the existing perfmon v2.0, All the PMU description tables are compiled in.

I think what we could do is to detect we have a mixed (family) configuration
and drop to the generic (architected) PMU with only 4 counters and 2 events. That
is, I am afraid, the best we could do.

--
-Stephane
