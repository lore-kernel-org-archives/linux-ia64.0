From: Russ Anderson <rja@sgi.com>
Date: Tue, 15 May 2007 18:32:30 +0000
Subject: Re: Fix section conflict of ia64_mlogbuf_finish
Message-Id: <200705151832.l4FIWUIN82299760@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070515164202.GA19839@deprecation.cyrius.com>
In-Reply-To: <20070515164202.GA19839@deprecation.cyrius.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
>
> >  CC      arch/ia64/kernel/mca.o
> > arch/ia64/kernel/mca.c:275: error: __ksymtab_ia64_mlogbuf_finish causes a section type conflict
> >
> > This is because ia64_mlogbuf_finish is both declared static and exported.
> 
> Why is it exported?  mca_drv.c (our only mca related module) doesn't
> use it.  Perhaps the fix should be to drop the EXPORT?

I suspect EXPORT is left over from the initial development/debug.
Either change is fine with me.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
