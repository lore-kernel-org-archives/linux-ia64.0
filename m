From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 11 Nov 2002 08:49:49 +0000
Subject: Re: [Linux-ia64] [PATCH] Performance Patch for TLB misses
Message-Id: <marc-linux-ia64-105590709805380@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805350@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805350@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Mario Smarduch schrieb:

> Christian Hildner wrote:
>
> > Hi,
> >
> > I created a patch that will (hopefully) increase the performance for TLB
> > miss handling.
> >
> > - enlarge the distance between rsm psr.dt and srlz (the movl do not need
> > data access)
> >
> > - let the processor check for the case of page not present (because for
> > useable systems the common case is that the page is present, so optimize
> > for that and drop the conditional branch)
> >
> > - let the processor also check for privilege level because it's very
> > very rare
>
> Wouldn't removal of this possibly cause cached and uncahced mappings
> to same page?

Yes, but for the kernel it is allowed also without the patch and the the user could insert a
duplicate mapping for the same physical page but this useless for him because of the access
rights and also the kernel would not use these pages (because the kernel has no knowledge of
this pages).

Christian


