From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 22 Oct 2004 03:05:50 +0000
Subject: Re: [PATCH] I/O space write barrier
Message-Id: <200410212205.51672.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410211613.19601.jbarnes@engr.sgi.com> <20041022010150.GH3878@cup.hp.com>
In-Reply-To: <20041022010150.GH3878@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Thursday, October 21, 2004 8:01 pm, Grant Grundler wrote:
> > +<programlisting>
> > +       sp->flags |= SRB_SENT;
> > +       ha->actthreads++;
> > +       WRT_REG_WORD(&amp;reg->mailbox4, ha->req_ring_index);
> > +
> > +       /*
> > +        * A Memory Mapped I/O Write Barrier is needed to ensure that
> > this write +        * of the request queue in register is ordered ahead
> > of writes issued +        * after this one by other CPUs.  Access to the
> > register is protected +        * by the host_lock.  Without the mmiowb,
> > however, it is possible for +        * this CPU to release the host lock,
> > another CPU acquire the host lock, +        * and write to the request
> > queue in, and have the second write make it +        * to the chip first.
> > +        */
> > +       mmiowb(); /* posted write ordering */
> > +</programlisting>
>
> This is the example code I'd like to see replaced with your
> synthetic example above.

Ok, that makes sense.  I'd like to update the documentation with a separate 
patch though, if that's ok with you.  I think Greg had some ideas about other 
things to cover as well.  Greg?

Thanks,
Jesse
