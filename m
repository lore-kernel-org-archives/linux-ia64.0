From: Jack Steiner <steiner@sgi.com>
Date: Fri, 28 May 2004 17:35:22 +0000
Subject: Re: [PATCH] don't udelay() in sn_mmiob
Message-Id: <20040528173522.GH11576@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405261749.02254.jbarnes@engr.sgi.com>
In-Reply-To: <200405261749.02254.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 28, 2004 at 12:28:55PM -0500, Jack Steiner wrote:
> On Thu, May 27, 2004 at 05:06:31PM -0400, Jesse Barnes wrote:
> > On Thursday, May 27, 2004 4:46 pm, David Mosberger wrote:
> > > Wouldn't you want at least a cpu_relax() in that loop?
> > 
> > That'll cause the CPU to switch to the other thread if it's SMT so it won't 
> > spin waiting for the access to complete?  If so, then yes.  Here's an updated 
> > patch.

Whoops, I posted this response to the wrong mail. I was replying to the question
about whether the code should have a "cpu_relax()".

> 
> I didn't think the code would actually spin.
> 
> sn_mmiob() is something like:
> 
>     1:	ld.acq r8=...
>     	;;
> 	cmp.eq p8,p0=r8,r9
>    (p8)	br 1b
> 
> The "load" is an uncached load. Won't the pipeline stall on the cmp
> waiting for data to arrive. I would not have expected that a cpu_relax()
> would have been needed here. 
> 
> Data takes a few hundred nsec to be loaded from the chipset.
> 
> 
> If we were spinning on a CACHED memory address, I agree that cpu_relax() 
> is need.
> 
> 
> 
> > 
> > sn_mmiob is a lightweight way to ensure PCI write ordering, intended to be 
> > used as an alternative to doing a PIO read. Unfortunately, with the udelay() 
> > in there, it ends up being slower than a PCI read on small configurations, so 
> > remove it in favor of a simple cpu_relax() so that we're HT-friendly.
> > 
> > Thanks,
> > Jesse
> 
> 
> 
> -- 
> Thanks
> 
> Jack Steiner (steiner@sgi.com)          651-683-5302
> Principal Engineer                      SGI - Silicon Graphics, Inc.
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


