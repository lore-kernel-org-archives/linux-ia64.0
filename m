From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 01 Nov 2004 19:02:29 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <200411011102.29277.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, November 1, 2004 10:53 am, Luck, Tony wrote:
> >> >  if (numnodes <= SMALL_SYSTEM_THRESHOLD) {
> >> >   SD_NODES_PER_DOMAIN = numnodes;
> >> >   build_node_domains(); /* each one spans the system */
> >> >  } else {
> >> >   SD_NODES_PER_DOMAIN = 4; /* or whatever */
>
> Ugh!  The magic '4' is going to be different for different machines,
> so there is no value that will make all of the people happy all of
> the time.

Right.

> >Yeah, but still the same number of CPUs/FSB.  I agree that
> >autotuning would be
> >best (the above is a crude example of that).  Any suggestions?
>
> Can't you use the SLIT table to build a hierachy of scheduler
> domains that matches the actual hardware configuration, instead
> of using compiled in constants or even boot-time command line
> parameters?

Maybe, but that will get complex very quickly I think.  Right now we have 
three domains on ia64, the cpu domain, the node domain, which contains 
several nodes worth of CPUs, and the top level domain, which spans the whole 
machine.

So there are two questions, how big should the node domain be and should it 
span the whole machine (avoiding the need for a top level domain)?  Obviously 
the answer is pretty machine specific, and I'm not sure the SLIT helps us 
much since its values are arbitrary distance values, not anything concrete.

Jesse
